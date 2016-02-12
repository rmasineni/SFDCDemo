/****************************************************************************
Author  : Raghu Masineni (rmasineni@sunrunhome.com)
Date    : April 2012

Description: This trigger updates/verifies the following Contact fields
           -- Checks for unique email
           -- Set 10 digit Contact_Number__c field

*****************************************************************************/

trigger Contact_SetContactFields on Contact (before insert, before update) {
    
  Boolean skipValidations = False;
  skipValidations = SkipTriggerValidation.performTriggerValidations();
  if(skipValidations == false){
    
    try{
    
    User loginUser = PRMContactUtil.getLoginUser();
    List<Contact> contactsForRecordType = new List<Contact>();
    Boolean skipEmailValidation = false;
    Boolean updateInactiveContacts = false;
    //Map<Id, RecordType> contactRecordTypeMap = PRMLibrary.getContactRecordTypes();
    RecordType residentialRecordType = PRMLibrary.getResidentialContactRecordType();
    Map<String, SunRunTriggerManager__c> customSettings = SunRunTriggerManager__c.getall();
    SunRunTriggerManager__c customSetting = customSettings.get('SkipUniqueContactEmailValidation');
    if(customSetting != null && customSetting.Active__c == true){
        skipEmailValidation = true;
    }

    SunRunTriggerManager__c customSetting2 = customSettings.get('UpdateInactiveContacts');
    if(customSetting2 != null && customSetting2.Active__c == true){
        updateInactiveContacts = true;
    }
    
    Map<Id, String> contactEmails = new Map<Id, String>();
    Set<Id> accountIds = new Set<Id>();
    Integer size = 0;
    Integer counter = 0;
    Contact oldContactObj;    
    Set<Id> contactIdsForProposals = new Set<Id>();
    Set<Id> conNullMemberIDSet = new Set<Id>();
    Map<Id,Id> optycontactIdsMap = new Map<Id, Id>();
    Map<Id,Boolean> opptySRApprovedProposalMap = new Map<Id, Boolean>(); 
    Contact tempCon;
    Map<Id,Contact> conIdRecMap = new Map<Id,Contact>(); 
         
    for(Contact contactObj: Trigger.new){
        accountIds.add(contactObj.accountId);
        //Check for unique email
        if(Trigger.isInsert){
            oldContactObj = null;
            if(contactObj.Email != null){
                contactEmails.put(contactObj.Id, contactObj.email);
                contactsForRecordType.add(contactObj);
            }
         }else if(Trigger.isUpdate){
            oldContactObj = Trigger.oldMap.get(contactObj.id);
            
            if(oldContactObj.accountId != contactObj.accountId){
                contactsForRecordType.add(contactObj);
            }
            
            if(contactObj.email != null && oldContactObj.email != contactObj.email){
                contactEmails.put(contactObj.Id, contactObj.email);     
            }   

            if(contactObj.RecordTypeId == residentialRecordType.Id && (ContactUtil.isContactInfoChanged(contactObj, oldContactObj))){
                contactIdsForProposals.add(contactObj.Id);
            }

            if(contactObj.RecordTypeId == residentialRecordType.Id && (ContactUtil.isMemberIdWipedOut(contactObj, oldContactObj))){
                conNullMemberIDSet.add(contactObj.id);
                conIdRecMap.put(contactObj.id, contactObj);     
            }
    }
    }
  
  System.debug('contactIdsForProposals: ' + contactIdsForProposals);
    if(contactIdsForProposals.size() > 0){
        Map<Id, Boolean> contactToContractResultMap = ServiceContractUtil.checkForCompletedServiceContracts('Contact', contactIdsForProposals);
        for(Id contactId : contactToContractResultMap.keySet()){
            Boolean result = contactToContractResultMap.get(contactId);
            if(result == true && loginUser.contactId != null){
                Contact tempContactObj = Trigger.newmap.get(contactId);
                String errormessage = SunrunErrorMessage.getErrorMessage('ERROR_000018').error_message__c;
                tempContactObj.adderror(errormessage);              
            }
        }
        
        Map<Id, Map<Id, Proposal__C>> contactProposalMap = ProposalUtil.getActiveProposalsForContacts(contactIdsForProposals);
        if(contactProposalMap != null && contactProposalMap.size() > 0){
            for(Id contactId : contactProposalMap.keySet()){
                Map<Id, Proposal__c> activeProposalMap = contactProposalMap.get(contactId);
                Contact tempContactObj = Trigger.newmap.get(contactId);
                //if(activeProposalMap.size() > 0 && !contactToContractResultMap.containsKey(contactId)){
                if(activeProposalMap.size() > 0){
                    if(tempContactObj.Void_Proposals__c == true || ContactUtil.eligibleForVoid.contains(tempContactObj.Id)){
                        ContactUtil.eligibleForVoid.add(tempContactObj.Id);
                        tempContactObj.Void_Proposals__c = false;
                    }else{
                        String errormessage = SunrunErrorMessage.getErrorMessage('ERROR_000017').error_message__c;
                        tempContactObj.adderror(errormessage);              
                    }                   
                }
            }
        }
    }

    if(!conNullMemberIDSet.isEmpty()){
       optycontactIdsMap = EDPUtil.getOpptyIdsForContactIds(conNullMemberIDSet); 
       opptySRApprovedProposalMap = ProposalUtil.getCostcoOpptySRApprovedProposalMap(optycontactIdsMap.keySet()); 
       for(Id opptyId: opptySRApprovedProposalMap.keySet()){
           tempCon = conIdRecMap.get(optycontactIdsMap.get(opptyId));
           tempCon.addError('Member ID is mandatory as Proposal associated with this contact is SR Approved', false);
       }
    }

    Map<String, List<Contact>> existingContacts = new Map<String, List<Contact>>();
    if(skipEmailValidation == false && contactEmails.size() > 0){
        existingContacts = PRMLibrary.getExistingContactsByEmail(contactEmails.values());
    }

    Map<Id, String> contactsWithInvalidDomain = new Map<Id, String>();
    if(contactEmails.size() > 0){
        contactsWithInvalidDomain = PRMLibrary.getContactsWithInvalidDomain(contactEmails);
        System.debug('contactsWithInvalidDomain: ' + contactsWithInvalidDomain);
        for(Id contactId : contactsWithInvalidDomain.keySet()){
            Contact tempContactObj = Trigger.newmap.get(contactId);
            String tempValidDomainlist = contactsWithInvalidDomain.get(contactId);
            tempContactObj.adderror('Email doesn\'t contain a valid partner domain. Please select one of the valid domains : ' + tempValidDomainlist);
        }
    }
    
    
    Map<Id, Account> accountMap = new Map<Id, Account>();
    if(accountIds.size() > 0){
        accountMap = PRMLibrary.getAccounts(accountIds);
    }
    
    if(contactsForRecordType.size() > 0){
        PRMLibrary.setContactType(contactsForRecordType);
    }
    
    List<Contact> contactList = new List<Contact>();
    Set<String> emailSet = new Set<String>();
    for(Contact contactObj: Trigger.new){
        
        if(Trigger.isUpdate && contactObj.Void_Proposals__c == true){
            contactObj.Void_Proposals__c = false;
        }
        
        if(Trigger.isUpdate && 
            contactObj.Contact_Type__c != null && 
            contactObj.Contact_Type__c == PRMLibrary.partner){
            oldContactObj = Trigger.oldMap.get(contactObj.id);      
            if(updateInactiveContacts == false 
                && oldContactObj.active__c == false 
                && oldContactObj.Active__c == contactObj.Active__c){
                contactObj.adderror('First activate the contact to make modifications');
            }
        }
        //Verify Contact number
        if(contactObj.contact_Number__c == null || contactObj.contact_Number__c == ''){
            size++;
        }  
        
        if(contactObj.RecordTypeId != null 
            && contactObj.RecordTypeId == residentialRecordType.Id){
            if(Trigger.isInsert && contactObj.email != null && contactObj.email != ''){
                contactList.add(contactObj);
                emailSet.add(contactObj.email);
            }else if(Trigger.isUpdate){
                oldContactObj = Trigger.oldMap.get(contactObj.id);
                if(contactObj.email != oldContactObj.email){
                    if(contactObj.email == null || contactObj.email == ''){
                        contactObj.Credit_Status__c = '';
                    }
                    if(contactObj.email != null && contactObj.email != ''){
                        emailSet.add(contactObj.email);
                    }
                    contactList.add(contactObj);
                }
            }
        }
    }
    
    Map<String, Customer_Credit__c> ccMap = new Map<String, Customer_Credit__c>();
    if(emailSet != null && !emailSet.isEmpty()){
      for(Customer_Credit__c ccObj : [Select Id, Customer_Email__c, Contact__c, type__c, Sunrun_Credit_Status__c,Credit_Decision_on_Portal__c, status__c, Date_Pulled__c, Date_Approved__c, Date_Submitted__c from 
                                          Customer_Credit__c where Customer_Email__c in :emailSet and type__c != 'Sunrun' ]){
          if(ccMap.containsKey(ccObj.Customer_Email__c)){
              Customer_Credit__c ccObj1 = ccMap.get(ccObj.Customer_Email__c);
              if(ccObj.Date_Approved__c != null && ccObj1.Date_Approved__c != null
                  && ccObj.Date_Approved__c > ccObj1.Date_Approved__c){
                  ccMap.put(ccObj.Customer_Email__c, ccObj);
              }else if(ccObj.Date_Pulled__c > ccObj1.Date_Pulled__c){
                  ccMap.put(ccObj.Customer_Email__c, ccObj);
              }
              
          }else{
              ccMap.put(ccObj.Customer_Email__c, ccObj);
          }
      }
    }
    
    for(Contact tempContact: contactList){
        Customer_Credit__c ccObj1 = ccMap.get(tempContact.email);
        if(ccObj1 != null && (ccObj1.type__c != 'Sunrun' || (ccObj1.type__c == 'Sunrun' && ccObj1.Contact__c == tempContact.Id))){
            tempContact.Credit_Status__c = ccObj1.status__c;
            tempContact.credit_received__c = ccObj1.Date_Pulled__c;
            tempContact.credit_submitted__c = ccObj1.Date_Submitted__c;
      tempContact.Sunrun_Credit_Status__c = ccObj1.Sunrun_Credit_Status__c;
           // tempContact.Credit_Status_on_Portal__c = ccObj1.Credit_Decision_on_Portal__c;
      if(tempContact.credit_submitted__c != null 
        && (tempContact.credit_status__c == null || tempContact.credit_status__c == '')){
        tempContact.credit_status__c = 'Sent';  
      }
    }
        System.debug('Credit Status: ' + tempContact.Credit_Status__c);
    }

    List<String> randomNumners = null;
    if(size > 0){
        randomNumners = PRMLibrary.getUniqueContactNumbers(size);
    }


    for(Contact contactObj: Trigger.new){    
        
        if((counter < size)  
            && (contactObj.contact_Type__c != null) 
            && (contactObj.contact_Type__c == PRMLibrary.PARTNER || contactObj.contact_Type__c == PRMLibrary.CUSTOMER || contactObj.contact_Type__c == PRMLibrary.EMPLOYEE)
            && (contactObj.Contact_Number__c == null || contactObj.Contact_Number__c == '')){
            contactObj.Contact_Number__c = randomNumners[counter];
            counter++;
        }

        //Check for unique email
        
        if(existingContacts != null && existingContacts.size() > 0
                && contactObj.email != null){
            List<Contact> contacts = null;
            if(existingContacts.containsKey(contactObj.email)){
                if(accountMap.containsKey(contactObj.accountId)){
                    Account updatedContactAccount = accountMap.get(contactObj.accountId);
                    contacts = existingContacts.get(contactObj.email);
                    
                    if(updatedContactAccount != null && 
                        updatedContactAccount.Account_Type__c != null && 
                        updatedContactAccount.Account_Type__c == PRMLibrary.partner){
                        //contactObj.addError('The email \'' + contactObj.email + '\' is associated with other Contact record1(s)');
                        for(Contact existingContact: contacts){
                            if((contactObj.FirstName != existingContact.FirstName || contactObj.lastname != existingContact.lastname)) {
                                contactObj.addError('The email \'' + contactObj.email + '\' is associated with other Contact record1(s)');
                                break;
                            }
                        } 
 
                    }else{
                        for(Contact existingContact: contacts){
                            if((existingContact.account.Account_Type__c != null && 
                                existingContact.account.Account_Type__c == PRMLibrary.PARTNER) && (contactObj.FirstName != existingContact.FirstName || contactObj.lastname != existingContact.lastname)) {
                                contactObj.addError('The email \'' + contactObj.email + '\' is associated with other Contact record2(s)');
                                break;
                            }
                        }
                    }
                } 
            }
        }
        
                
        if(contactObj.Contact_Type__c != null && 
            contactObj.Contact_Type__c ==  PRMLibrary.PARTNER && 
            contactObj.Active__c != null){
            if(contactObj.Active__c == false ){
                if(contactObj.Deactivation_Reason__c == null  || contactObj.Deactivation_Reason__c == ''){
                    contactObj.adderror('To deactivate a Contact, select \'Deactivation Reason\'');
                }
                if((oldContactObj == null) 
                    || (oldContactObj != null && oldContactObj.Active__c != contactObj.Active__c)){
                    Account accountObj = accountMap.get(contactObj.accountId);
                    Boolean solarUniverseAcount = false;
                    if(accountObj.name == PRMContactUtil.SOLAR_UNIVERSE){
                        solarUniverseAcount = true;
                    }
                    PRMContactUtil.revokeToolsAccess(contactObj, solarUniverseAcount);
                }               
                
            }else if(contactObj.Active__c == true){ 
                Account tempAccount = accountMap.get(contactObj.accountId);
                if(Trigger.isInsert && tempAccount.Active__c != null && tempAccount.Active__c == false){
                    //contactObj.Active__c = false;
                    //contactObj.Deactivation_Reason__c = 'Account Deactivated';
                    contactObj.adderror('Activate \''+ tempAccount.name + '\' account to add a new contact');
                }else if(oldContactObj != null && oldContactObj.Active__c != contactObj.Active__c){
                    if(tempAccount.Active__c != null && tempAccount.Active__c == false){
                        contactObj.adderror('Activate \''+ tempAccount.name + '\' account to activate the contact');
                    }
                } 
            }
        }
        
        if(contactObj.Contact_Type__c != null && 
            contactObj.Contact_Type__c ==  PRMLibrary.PARTNER){
            Account partnerAccount = accountMap.get(contactObj.accountId);
            PRMContactUtil.performAccreditationProcess(contactObj, oldContactObj, partnerAccount);
            PRMContactUtil.checkToolsAccess(contactObj, oldContactObj, partnerAccount);         
        }
     }
    }catch(Exception expObj){
        System.debug('Contact_SetContactFields: Contact Exception: ' + new BaseClass().getStackTrace(expObj));
        for(Contact contactObj : Trigger.new){
            contactObj.adderror(expObj.getMessage());
        }
    }
  }  
}