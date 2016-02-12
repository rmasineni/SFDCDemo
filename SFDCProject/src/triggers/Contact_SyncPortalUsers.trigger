trigger Contact_SyncPortalUsers on Contact (after update, after insert) {

   Boolean skipValidations = False;
   skipValidations = SkipTriggerValidation.performTriggerValidations();
   if(skipValidations == false){
    
    Set<Id> accountIds = new Set<Id>();
    Set<Id> contactIdsForLMSInfo = new Set<Id>();
    Set<Id> statusChangeContactIds = new Set<Id>();
    Set<Id> activateContactIds = new Set<Id>();
    Set<Id> deActivateContactIds = new Set<Id>();

    Map<Id, Set<Id>> accountContactMap = new Map<Id, Set<Id>>();    
    Set<Id> contactIds = new Set<Id>();
    Map<Id, string> contactEmailmap = new Map<Id, string>();
    Set<Id> accountModifiedContactIds = new Set<Id>();
    Set<Id> contactRoleContactIds;
    Set<Id> contactIdsForPartnerPortal = new Set<Id>();
    Set<Id> revokePartnerPortalIDs = new Set<Id>();
    Map<Id, Id> contactPrposalMap = new Map<Id, Id>();
    User loginUser = PRMContactUtil.getLoginUser();
    Set<Id> modifiedRelatedObjectIds = new Set<Id>();
    Set<Id> proposalIdsForVoid = new Set<Id>();
    Map<Id, Map<Id, Proposal__C>> contactProposalmap;
    Map<Id, Proposal__c> voidedProposals = new Map<Id, Proposal__c>();
    RecordType residentialRecordType = PRMLibrary.getResidentialContactRecordType();
    if(Trigger.isUpdate){
        if(ContactUtil.eligibleForVoid != null && ContactUtil.eligibleForVoid.size() > 0){
            contactProposalmap = ProposalUtil.getActiveProposalsForContacts(null);
        }
    }

    for(Contact contactObj: Trigger.new){
        Contact oldContactObj = null;

        if(Trigger.isUpdate){
            oldContactObj = Trigger.oldMap.get(contactObj.id);
            if(ContactUtil.eligibleForVoid.contains(contactObj.Id) 
                && !ContactUtil.voidedContactIds.contains(contactObj.Id)){
                ContactUtil.voidedContactIds.add(contactObj.Id);
                System.debug('Business logic to void the proposals ...' + ContactUtil.voidedContactIds);
                if(contactProposalmap != null && contactProposalmap.size() > 0){
                    Map<Id, Proposal__C> proposalMap = contactProposalmap.get(contactObj.Id);
                    System.debug('proposalMap: '  + proposalMap);
                    if(proposalMap != null && !proposalMap.isEmpty()){
                        voidedProposals.putAll(proposalMap);
                    }
                }
            }
            
            if(contactObj.RecordTypeId == residentialRecordType.Id ){
                modifiedRelatedObjectIds.add(contactObj.Id);
            }
        }
        if((contactObj.Contact_Type__c != null && contactObj.Contact_Type__c == PRMLibrary.PARTNER)){

            if(Trigger.isInsert && contactObj.Ultimate_Parent_Account__c != null 
                && contactObj.active__c == true){
                accountIds.add(contactObj.Ultimate_Parent_Account__c);
                contactIdsForLMSInfo.add(contactObj.Id);
            }
            
            if(oldContactObj != null){

                if(LMSInfoManager.hasCertificationProfileModified(contactObj, oldContactObj) 
                    && contactObj.Ultimate_Parent_Account__c != null){
                    accountIds.add(contactObj.Ultimate_Parent_Account__c);
                    contactIdsForLMSInfo.add(contactObj.Id);
                }

                if(contactObj.Email != null && 
                    contactObj.Email != oldContactObj.Email){
                    contactIds.add(contactObj.Id);
                }else if(contactObj.firstname != null && 
                        contactObj.firstname != oldContactObj.firstname){
                    contactIds.add(contactObj.Id);
                }else if(contactObj.lastname != null && 
                        contactObj.lastname != oldContactObj.lastname){
                    contactIds.add(contactObj.Id);
                }else if(contactObj.title != null && 
                        contactObj.title != oldContactObj.title){
                    contactIds.add(contactObj.Id);
                }else if(contactObj.Phone != oldContactObj.Phone){
                    contactIds.add(contactObj.Id);
                }else if(contactObj.MobilePhone != oldContactObj.MobilePhone){
                    contactIds.add(contactObj.Id);
                }else if(contactObj.fax != oldContactObj.fax){
                    contactIds.add(contactObj.Id);
                }else if(contactObj.MailingStreet != oldContactObj.MailingStreet){
                    contactIds.add(contactObj.Id);
                }else if(contactObj.MailingCity != oldContactObj.MailingCity){
                    contactIds.add(contactObj.Id);
                }else if(contactObj.MailingState != oldContactObj.MailingState){
                    contactIds.add(contactObj.Id);
                }else if(contactObj.MailingCountry != oldContactObj.MailingCountry){
                    contactIds.add(contactObj.Id);
                }else if(contactObj.MailingPostalCode != oldContactObj.MailingPostalCode){
                    contactIds.add(contactObj.Id);
                }else if(contactObj.timeZoneSidKey__c != oldContactObj.timeZoneSidKey__c){
                    contactIds.add(contactObj.Id);
                }
                
                System.debug('contactIds: '  +contactIds );
                System.debug('contactObj.fax: '  +contactObj.fax );
                System.debug('oldContactObj.fax: '  +oldContactObj.fax );
            }
            
            if((contactObj.Contact_Type__c != null && 
                contactObj.Contact_Type__c == PRMLibrary.PARTNER) &&
                (oldContactObj == null || (oldContactObj.AccountId != contactObj.AccountId))){
                
                contactRoleContactIds = accountContactMap.containsKey(contactObj.AccountId) ? 
                                    accountContactMap.get(contactObj.AccountId) : new set<Id>();
                contactRoleContactIds.add(contactObj.Id);
                accountContactMap.put(contactObj.AccountId, contactRoleContactIds);
                accountModifiedContactIds.add(contactObj.Id);
            }
            Id contactId = PRMContactUtil.checkPartnerPortalAccess(contactObj, oldContactObj);
            system.debug('ContactId:' + ContactId);
            
            if(contactId != null && PRMContactUtil.GRANTED == contactObj.Partner_Portal_Access__c){
                contactIdsForPartnerPortal.add(contactId);
            }else if(contactId != null){
                revokePartnerPortalIDs.add(contactId);
            }
        }
        
        if((Trigger.isInsert && contactObj.proposal__c != null) 
            || (Trigger.isUpdate && contactObj.proposal__c != null 
                && oldContactObj.proposal__c != contactObj.proposal__c)){
            contactPrposalMap.put(contactObj.Id, contactObj.proposal__c);
        }
        
     }

    if(voidedProposals != null && !voidedProposals.isEmpty()){
        Map<Id, String> reasonMap = new Map<Id, String>();
        for(Proposal__c tempProposalObj : voidedProposals.values()){
            reasonMap.put(tempProposalObj.Id, ProposalUtil.CONTACT_NAME_CHANGE);
        }
        ProposalUtil.voidProposals(voidedProposals, reasonMap, true);
    }
    
    if(modifiedRelatedObjectIds != null && !modifiedRelatedObjectIds.isEmpty()){
        ServiceContractUtil.updateServiceContractsForContacts(modifiedRelatedObjectIds, datetime.now());
    }
    
     if(contactIds.size() > 0){
        Set<Id> updateContactIds = new Set<Id>();
        for(User userObj: [Select Id, firstname, title, lastname, email, contactId, MobilePhone,
                                Phone, Fax, Street, City, State, Country, PostalCode, TimeZoneSidKey 
                                from User 
                                where ContactId in :contactIds]){
            Contact contactObj = Trigger.newmap.get(userObj.contactId);
            if(contactObj != null && 
                ((userObj.FirstName != contactObj.firstname) || 
                (userObj.lastname != contactObj.lastname) || 
                (userObj.title != contactObj.title) || 
                (userObj.Phone != contactObj.Phone) ||
                (userObj.Fax != contactObj.Fax) ||
                (userObj.MobilePhone != contactObj.MobilePhone) ||
                (userObj.Street != contactObj.MailingStreet) ||
                (userObj.City != contactObj.MailingCity) ||
                (userObj.State != contactObj.MailingState) ||
                (userObj.Country != contactObj.MailingCountry) ||
                (userObj.PostalCode != contactObj.MailingPostalCode) ||
                (userObj.email != contactObj.email) ||
                (userObj.TimeZoneSidKey != contactObj.timeZoneSidKey__c))){
                updateContactIds.add(contactObj.Id);    
            }
            System.debug('updateContactIds: '  +updateContactIds );
        }
        if(updateContactIds.size() > 0){
            PRMLibrary.updatePartneruserEmails(updateContactIds);
        }
     }
    
    if(accountContactMap != null && accountContactMap.size() > 0){
        //System.debug('Creating Contact Roles');
        PRMLibrary.createContactRoles(accountContactMap, accountModifiedContactIds);
     }
     
     if(contactIdsForPartnerPortal.size() > 0){
        System.debug('contactIdsForPartnerPortal: ' + contactIdsForPartnerPortal);
        PRMContactUtil.managePortalUsers(contactIdsForPartnerPortal);
     }
     
     if(revokePartnerPortalIDs.size() > 0){
        if(loginUser == null || loginUser.Username != Label.BatchUserId){
            System.debug('revokePartnerPortalIDs1: ' + revokePartnerPortalIDs);
            //Code added 3/3/2014---Do not call future class from batch apex---Prashanth Veloori
             if(system.isFuture() == false && system.isBatch() == false)
            PRMContactUtil.revokePartnerPortalAccess(revokePartnerPortalIDs);   
        }else{
            //System.debug('revokePartnerPortalIDs2: ' + revokePartnerPortalIDs);
            //PRMContactUtil.portalAccessRevokeAction(revokePartnerPortalIDs);  
        }
     }
     
     System.debug('contactPrposalMap: ' + contactPrposalMap);
     if(contactPrposalMap.size() > 0){
        ProposalUtil.shareContactsByProposal(contactPrposalMap);
     }
    
    System.debug('contactIdsForLMSInfo: ' + contactIdsForLMSInfo);
     if(contactIdsForLMSInfo.size() > 0 ){
        
        Map<Id, Account> accountsMapForLMSInfo = new Map<Id, Account>();
        if(accountIds.size() > 0){
            accountsMapForLMSInfo = PRMLibrary.getAccounts(accountIds);
        }
        
        Set<Id> lmsInfoContactIds = new Set<Id>();
        for(Id contactId : contactIdsForLMSInfo){
            Contact oldContactObj = null;
            if(Trigger.isUpdate){
                oldContactObj = Trigger.oldMap.get(contactId);
            }
            Contact contactObj = Trigger.newMap.get(contactId);
            Account accountObj = accountsMapForLMSInfo.get(contactObj.Ultimate_Parent_Account__c);
            if(accountObj != null && accountObj.stage__c != null && 
                (accountObj.stage__c == 'Confirmed' || accountObj.stage__c.contains('Contract Negotiation'))){
                
               System.debug('LMSInfoManager.processedContactIds: ' + LMSInfoManager.processedContactIds);
                if(!LMSInfoManager.processedContactIds.contains(contactObj.Id)){
                    lmsInfoContactIds.add(contactObj.Id);
                }


                if((contactObj.sells_sunrun__c == PRMContactUtil.YES && contactObj.active__C == true) 
                    && (Trigger.isInsert || (oldContactObj != null && 
                        ((contactObj.active__C == true && contactObj.active__C != oldContactObj.active__C)
                            ||(contactObj.sells_sunrun__c != oldContactObj.sells_sunrun__c)
                            ||(oldContactObj.Ultimate_Parent_Account__c == null &&
                                contactObj.Ultimate_Parent_Account__c != oldContactObj.Ultimate_Parent_Account__c))))){
                    
                    System.debug('LMSInfoManager.contactTriggerActiveIds: ' +LMSInfoManager.contactTriggerActiveIds);
                    if(!LMSInfoManager.contactTriggerActiveIds.contains(contactObj.Id)){
                        activateContactIds.add(contactObj.Id);
                        LMSInfoManager.contactTriggerActiveIds.add(contactObj.Id);
                    }
                    
                }else if(oldContactObj != null && contactObj.active__C == false
                    && contactObj.active__C != oldContactObj.active__C){
                    System.debug('LMSInfoManager.contactTriggerInActiveIds: ' +LMSInfoManager.contactTriggerInActiveIds);
                    if(!LMSInfoManager.contactTriggerInActiveIds.contains(contactObj.Id)){
                        deactivateContactIds.add(contactObj.Id);    
                        LMSInfoManager.contactTriggerInActiveIds.add(contactObj.Id);
                    }
                }
                System.debug('activateContactIds2: ' + activateContactIds);
            }
        }
        if(lmsInfoContactIds.size() > 0 || deactivateContactIds.size() > 0){
            If(!Test.isRunningTest()){
                //Code added 3/3/2014---Do not call future class from batch apex---Prashanth Veloori
                if(system.isFuture() == false && system.isBatch() == false)
                NetExamWebServiceAPIHelper7.SendContactFromTrigger(lmsInfoContactIds, activateContactIds, deactivateContactIds);
                }
        }
        
     }
   }
}