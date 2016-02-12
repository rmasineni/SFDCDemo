public class ProposalUtil {
    
    public static string INVALID = 'Invalid';
    public static string SUNRUN_VOID = 'Voided';
    public static string SUNRUN_VOID_ACTION = 'Void';
    public static string BLACK_BIRD = 'BB';
    public static string PROPOSAL_TOOL = 'PT';
    public static string SUCCESS = 'SUCCESS';
    public static string FAILURE = 'Failure';
    public static string WARNING = 'Warning';
    public static string ERROR = 'Error';
    
    public static string NODE = 'Node';
    public static string SEED = 'Seed';
        
    public static string FULL_PROPOSAL = 'FULL_PROPOSAL';
    public static string NO_SIGNATURES_REQUIRED = 'NO_SIGNATURES_REQUIRED';
    public static string CUSTOMER_CHANGE_ORDER = 'CUSTOMER_CHANGE_ORDER';
    public static string EPC_CHANGE_ORDER = 'EPC_CHANGE_ORDER';
    public static string CUSTOMER_EPC_CHANGE_ORDER = 'CUSTOMER_CHANGE_ORDER;EPC_CHANGE_ORDER';
    public static string EPC_CUSTOMER_CHANGE_ORDER = 'EPC_CHANGE_ORDER;CUSTOMER_CHANGE_ORDER';
    public static string SALES_PARTNER_CHANGE_ORDER = 'SALES_PARTNER_CHANGE_ORDER';
    
    public static String SIGNED_DOCS = 'SIGNED_DOCS';
    public static String UN_SIGNED_DOCS = 'UN_SIGNED_DOCS';
    public static String PROPOSAL_TOOL_GEN_DOCS = 'PROPOSAL_TOOL_GEN_DOCS';
    public static String SIGN_PROPOSAL = 'Sign Proposal';
    
    public static String CONTACT_NAME_CHANGE = 'CONTACT NAME CHANGE';
    public static String ACCOUNT_ADDRESS_CHANGE = 'ACCOUNT ADDRESS CHANGE';
    public static String OPPORTUNITY_CHANGE = 'OPPORTUNITY CHANGE';
    public static String UTILITY_CHANGE = 'UTILITY CHANGE';
    public static String MONTHLY_USAGE_CHANGE = 'MONTHLY USAGE CHANGE';
    public static String CUST_OWNED_FULL_UPFRONT = 'Customer Owned - Full Upfront';
    public static String CUST_OWNED_BANK_FINANCE = 'Customer Owned - Bank Financed';
    public static String SUNRUN_CUSTOMER_CREDIT = 'Sunrun';
    public static String AS_BUILT = 'AS_BUILT';
    public static set<String> ignoreVoidReasons = new set<String>();
    
        public static Set<String> getIgnoreVoidReasons(){
        if(ignoreVoidReasons.isEmpty()){
            ignoreVoidReasons.add('CONTACT NAME CHANGE');
            ignoreVoidReasons.add('ACCOUNT ADDRESS CHANGE');
           // ignoreVoidReasons.add('UTILITY CHANGE');
            ignoreVoidReasons.add('MONTHLY USAGE CHANGE');        
        }
        return ignoreVoidReasons;
    }
    
  public static Set<Id> inProgressProposalIds = new Set<Id>();
    public static Set<Id> copyCreditInfoProposalIds = new Set<Id>();
    public static Set<Id> cusomerCreditProposalIds = new Set<Id>();
    public static Map<String, Proposal__C> getProposalMapForGenAsset(){
        return proposalMapForGenAsset;
    }
    public static Map<String, Proposal__C> proposalMapForGenAsset = new Map<String, Proposal__C>();
    public static Map<String, Proposal__C> getProposalMapByName(Set<String> proposalNmaes){
        proposalMapForGenAsset.clear();
        if(proposalNmaes.size() > 0 ){
      for(Proposal__c propObj : [Select Id, Opportunity__c, name, Stage__C, cost_stack__c, Total_Solar_Prepay_Required__c, Conditional_Approval__c, ACH_Required__c, Sunrun_Credit_Status__c,Agreement_Type__c,Sales_Partner__c,Finance_Type__c,
                                            Primary_Customer__c,Credit_Status__c, Credit_team_notes__c,  Current_Customer_Credit_Report__c, home_type__c, Customer_Signoff_Date__c,
                                            Conditional_Approval_Amount__c, Original_Proposal_ID__c, Partner_Financed__c, Original_Proposal_ID__r.Id, Install_Partner__c,
                                            Original_Proposal_ID__r.Conditional_Approval__c, Original_Proposal_ID__r.ACH_Required__c, Name_on_Credit_Verified__c, Date_Time_Ops_Received_Proposal_back__c,
                                            Original_Proposal_ID__r.Primary_Customer__c, Original_Proposal_ID__r.Credit_Status__c, Original_Proposal_ID__r.Name_on_Credit_Verified__c,
                                            Original_Proposal_ID__r.Credit_team_notes__c,Original_Proposal_ID__r.Current_Customer_Credit_Report__c, Original_Proposal_ID__r.Date_Time_Ops_Received_Proposal_back__c,
                                            Original_Proposal_ID__r.Conditional_Approval_Amount__c, Original_Proposal_ID__r.Partner_Financed__c, Original_Proposal_ID__r.Customer_Signoff_Date__c,
                                            Original_Proposal_ID__r.Sunrun_Credit_Status__c, Original_Proposal_ID__r.Total_Solar_Prepay_Required__c 
                                            from Proposal__c where name in :proposalNmaes]){
                proposalMapForGenAsset.put(propObj.Name, propObj);
            }           
        }
        return proposalMapForGenAsset;
    }

    public static void updateCreditInformationForChangeOrders(Map<String, Proposal__C> proposalMap){
        List<Proposal__c> modifiedProposals = new List<Proposal__c>();
        for(Proposal__C proposalObj : proposalMap.values()){
            if(proposalObj.Original_Proposal_ID__c != null && ((proposalObj.name.indexOf('H') == 0 ) || (proposalObj.name.indexOf('C') == 0 ))){
                Proposal__c parentProposalObj =  proposalObj.Original_Proposal_ID__r;
                if(parentProposalObj != null ){
                    proposalObj.change_order__c = true;
                    proposalObj.original_proposal_Id__c = parentProposalObj.Id;
                }
            }
            modifiedProposals.add(proposalObj);
        }
        
        if(modifiedProposals != null && !modifiedProposals.isEmpty()){
            update modifiedProposals;
        }
    }


    public static void notifyPartnerOperations(List<Proposal__C> proposalList){
        for(Proposal__C proposalObj : proposalList){
            
        }
    }


    public static Map<Id, Opportunity> opportunityMap;
    
    public static Map<Id, Opportunity> optyAndContactSharingForInstallPartners(Map<Id, Proposal__c> proposalMap, Map<Id, Proposal__c> oldProposalMap){
        set<Id> setAssigneUserId = new Set<Id>();
        Set<Id> setOpps = new Set<Id>();
        Map<Id, Id> mapUser = new Map<Id, Id>();
        Map<Id, Id> mapContact = new Map<Id, Id>();
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Set<Id>> installPartnerToOptyMap = new Map<Id, Set<Id>>();
        Map<Id, Id> proposalToAssigneeMap = new Map<Id, Id>();
        //Map<Id, Opportunity> optyMap = new Map<Id, Opportunity>();
        Set<Id> opportunityIdsForProposals = new Set<Id>();
        
        List<Proposal__c> proposalListForAssignedUsers = new List<Proposal__c>();
        Set<String> salesRepsEmails = new Set<String>();
        Set<Id> assigneeIds = new Set<Id>();    
        Set<Id> modifiedProposalIds = new Set<Id>();
        for(Proposal__c propObj : proposalMap.values()){
          modifyRECInfo(propObj);
            if(propObj.Install_Partner__c != null && propObj.Install_Partner__c != OldProposalMap.get(propObj.Id).Install_Partner__c){
                Set<Id> optyIds = (installPartnerToOptyMap.containsKey(propObj.Install_Partner__c)) ? 
                                    installPartnerToOptyMap.get(propObj.Install_Partner__c) : new Set<Id>();
                optyIds.add(propObj.Opportunity__c);
                installPartnerToOptyMap.put(propObj.Install_Partner__c, optyIds);
                setOpps.add(propObj.Opportunity__c);    
              if(propObj.Sales_Rep_Email__c != null && propObj.Sales_Rep_Email__c != ''){
                  salesRepsEmails.add(propObj.Sales_Rep_Email__c);
                  modifiedProposalIds.add(propObj.Id);
              }
      }
            if(propObj.Assigne__c != null && propObj.Assigne__c != OldProposalMap.get(propObj.Id).Assigne__c ){
                assigneeIds.add(propObj.Assigne__c);
                proposalListForAssignedUsers.add(propObj);
            }
            
            if(propObj.Opportunity__C != null){
                opportunityIdsForProposals.add(propObj.Opportunity__C);
            }
        }


    Set<Id> recordTypeIds = PRMLibrary.getPartnerAndEmployeeRecordTypes();
        if(salesRepsEmails != null && !salesRepsEmails.isEmpty()) {
          Map<String, Contact> contactMap = new Map<String, Contact>();
            for(Contact contact : [select id,Email,Name,Account.Id,Account.Name,Account.Partner_Type__c, Location__c, Sunrun_User__c, division__c from contact 
                                    where (email in: salesRepsEmails)
                                    and recordTypeId in :recordTypeIds ]){
              contactMap.put(contact.email, contact);
            }
            for(Id proposalId : modifiedProposalIds){
              Proposal__c tempProposal = proposalMap.get(proposalId);
              Contact tempContact = contactMap.get(tempProposal.Sales_Rep_Email__c);
              if(tempProposal != null && tempContact != null){
                calculateProposalCostStack(tempProposal, tempContact);
              }
            }
            
        }
                                
        if(opportunityIdsForProposals != null && opportunityIdsForProposals.size() > 0){
            Boolean createOptyMap = false;
            if(opportunityMap != null && !opportunityMap.isEmpty()){
                for(Id tempOptyId : opportunityIdsForProposals){
                    if(!opportunityMap.containsKey(tempOptyId)){
                        createOptyMap = true;
                        break;
                    }
                }
            }
            if(createOptyMap == true || opportunityMap == null){
                opportunityMap = new Map<Id, Opportunity>([Select Id, Payment_Mode__c,Channel_2__c,Lead_Source_2__c, Billing_State__c, Home_Type__c,SalesOrganizationName__c from Opportunity where Id in :opportunityIdsForProposals]);
            }
            
        }

        Set<Id> partnerIds = (installPartnerToOptyMap.keySet() != null) ? installPartnerToOptyMap.keySet() : new Set<Id>();
        Map<Id, Partner_Location__c> partnerHQLocations = EDPUtil.getHeadquartersLocation(installPartnerToOptyMap.keySet());
        if(partnerIds.size() > 0){
            for(Contact conctList :[select id,Email,Name,Account.Id,Account.Name,Account.Partner_Type__c,Install_Rep__c, Sunrun_User__c, Location__c from contact 
                                        where AccountId in:installPartnerToOptyMap.keySet() ]){
                                        //and Install_Rep__c = true]){
                mapContact.put(conctList.id,conctList.AccountId);
            }
        }
        
        Set <Id> conctkeySet = new Set<Id>();
        conctkeySet = mapContact.keySet();
        Map<Id, Set<Id> > opportunityContactRoles = new Map<Id, Set<Id> >();
        if(setOpps != null && !setOpps.isEmpty()){
            opportunityContactRoles = EDPUtil.getContactIdsForOpportunities(setOpps);
        }
        List<ContactShare> contactShareList = new List<ContactShare>();
        List<OpportunityShare> opportunityShareList = new List<OpportunityShare>();
        if(conctkeySet != null && conctkeySet.size() > 0){
            for(User accUserList :[select Id, Name,ContactId, contact.name, contact.accountid from user where contactid IN :conctkeySet AND isactive = true]){
        Set<Id> optyIds = installPartnerToOptyMap.get(accUserList.contact.accountid);
                for(Id optyId : optyIds){
    
                    //OpportunityShare oppShare= new OpportunityShare();
                    //oppShare.OpportunityAccessLevel = 'Edit';
                    //oppShare.OpportunityId = optyId;
                    //oppShare.UserOrGroupId =  accUserList.id;
                     Id userOrGroupId = (Test.isRunningTest()) ? UserInfo.getUserId() : accUserList.id;
                     OpportunityShare oppShare = createOpportunitySharing(userOrGroupId, optyId);                    
          boolean createSharing = true;
                    if(opportunityMap.containsKey(optyId)){
                        Opportunity tempShareOpty = opportunityMap.get(optyId);
                        createSharing = (tempShareOpty.Channel_2__c=='Partner' && tempShareOpty.Lead_Source_2__c=='Partner: Legacy') ? false : true;
                    }
          if(createSharing == true){
                      opportunityShareList.add(oppShare);                 
                    }
    
                    Set<Id> optyContactIds = opportunityContactRoles.get(optyId);
                    //Share the Opty Contacts
                    if(optyContactIds != null && optyContactIds.size() > 0){
                        for(Id optyContactId : optyContactIds){
                            //ContactShare contactShareObj = new ContactShare();
                            //contactShareObj.ContactAccessLevel = 'Edit';
                            //contactShareObj.ContactId = optyContactId;
                             //contactShareObj.UserOrGroupId =  accUserList.id;
              userOrGroupId = (Test.isRunningTest()) ? UserInfo.getUserId() : accUserList.id;
                           ContactShare contactShareObj = createContactSharing(userOrGroupId, optyContactId);            
              contactShareList.add(contactShareObj);                          
                        }
                    }
                    
                }
                
                if(Test.isRunningTest())
                  break;
            }
        }
        if(opportunityShareList.size() > 0) {
            Database.SaveResult[] result = database.insert(opportunityShareList,false);
        }
        if(contactShareList.size() > 0){
            database.upsert(contactShareList,false);
        }
        
        if(proposalListForAssignedUsers.size() > 0){
            optyAndContactSharingByAssignee(proposalListForAssignedUsers, assigneeIds);
        }
        return opportunityMap;
    }

  public static ContactShare createContactSharing(Id groupId, Id contactId){
    ContactShare share = new ContactShare();
    share.ContactId = contactId;
    share.UserOrGroupId = groupId;
    share.ContactAccessLevel = 'edit';  
    return share;
  }
  
  public static OpportunityShare createOpportunitySharing(Id groupId, Id optyId){
    OpportunityShare share = new OpportunityShare();
    share.OpportunityId = optyId;
    share.UserOrGroupId = groupId;
    share.OpportunityAccessLevel = 'edit';  
    return share;
  }
    
    public static void optyAndContactSharingForProposals(List<Proposal__c> proposalsList){

        Map<Id, String> optySalesRepMap = new Map<Id, String>();
        Map<Id, Id> optySalesRepUserIdMap = new Map<Id, Id>();
        Set<Id> optyIds = new Set<Id>();
        Set<Id> parentProposalIds = new Set<Id>();
        for(Proposal__c propObj : proposalsList){
            optyIds.add(propObj.Opportunity__c);
            if(propObj.Sales_Rep_Email__c != null && propObj.Sales_Rep_Email__c != ''){
                optySalesRepMap.put(propObj.Opportunity__c, propObj.Sales_Rep_Email__c);
            }
            if(propObj.Original_Proposal_ID__c != null && ((propObj.name.indexOf('H') == 0 ) || (propObj.name.indexOf('C') == 0 ))){
                parentProposalIds.add(propObj.Original_Proposal_ID__c);
            }
 
        }

        //Map<Id, List<OpportunityContactRole> > opportunityContactRoles = EDPUtil.getContactRoles(optyIds);
        Map<Id, Opportunity>  optyMap = EDPUtil.getOpportunitiesAndRoles(optyIds);
        
        Map<Id, Set<Id>> optyContactRoleMap = new Map<Id, Set<Id>>();
        Set<Id> contactIds = new Set<Id>();
        Set<String> dealIds = new Set<String>();
        for(Opportunity optyObj : optyMap.values()){
            if(optyObj.SalesRep__c != null){
                optySalesRepUserIdMap.put(optyObj.Id, optyObj.SalesRep__c);
            }
            List<OpportunityContactRole> contactRoles = (optyObj.OpportunityContactRoles != null) ? optyObj.OpportunityContactRoles : new List<OpportunityContactRole>();
            if(contactRoles != null && contactRoles.size() > 0){
                Set<Id> tempContactIds = new Set<Id>();
                for(OpportunityContactRole contactRoleObj : contactRoles){
                    contactIds.add(contactRoleObj.contactId);
                    tempContactIds.add(contactRoleObj.contactId);
                }
                if(tempContactIds.size() > 0){
                    optyContactRoleMap.put(optyObj.Id, tempContactIds);
                }
            }
            if(optyObj.deal_Id__c != null && optyObj.deal_Id__c != ''){
                dealIds.add(optyObj.deal_Id__c);
            }
        }
        Map<String, Map<String, Customer_Credit__c>> tempCreaditDealIdMap = new Map<String, Map<String, Customer_Credit__c>>();
        if(dealIds != null && !dealIds.isEmpty()){
            tempCreaditDealIdMap = getCustomerCreditsForDealIds(dealIds);
            System.debug('tempCreaditDealIdMap: ' + tempCreaditDealIdMap);
        }

        List<Contact> contactList = [Select Id, firstname, Sunrun_User__c, lastname, email from Contact where Id in :contactIds];
        for(Proposal__c propObj : proposalsList){
            Opportunity optyObj = optyMap.get(propObj.Opportunity__c);
            modifyRECInfo(optyObj);
            List<OpportunityContactRole> contactRoles;
            if(optyObj != null){
                contactRoles = (optyObj.OpportunityContactRoles != null) ? optyObj.OpportunityContactRoles : new List<OpportunityContactRole>();
                
                if(propObj.home_type__c == null || propObj.home_type__c == ''){
                    propObj.home_type__c = optyObj.home_type__c;
                }
                if(propObj.Proposal_Source__c != null && propObj.Proposal_Source__c == ProposalUtil.BLACK_BIRD){
                    propObj.Sales_Partner__c = optyObj.Sales_Partner__c;
                    propObj.Install_Partner__c = optyObj.Install_Partner__c;
                }
                modifyRECInfo(propObj);
                if(tempCreaditDealIdMap != null && (optyObj.deal_Id__c != null && optyObj.deal_Id__c != '')){
                    Map<String, Customer_Credit__c> creditMapByEmail = tempCreaditDealIdMap.get(optyObj.deal_Id__c );
                    if(creditMapByEmail != null && creditMapByEmail.containsKey(propObj.Homeowner_Email__c)){
                        Customer_Credit__c tempCCObj = creditMapByEmail.get(propObj.Homeowner_Email__c);
                        if(tempCCObj != null){
                            propObj.Current_Customer_Credit_Report__c = tempCCObj.Id;
                        }
                    }
                }
            }
            
            if(propObj.Proposal_Source__c != null && propObj.Proposal_Source__c == ProposalUtil.BLACK_BIRD){
                if(contactRoles != null && contactRoles.size() > 0){
                    for(OpportunityContactRole contactRoleObj : contactRoles){
                        if(contactRoleObj.IsPrimary == true){
                            propObj.Primary_Customer__c = contactRoleObj.contactId;
                        }
                    }
                }               
                                
            }else{          
                for(Contact contactObj : contactList){
                    if(contactObj.email == propObj.Homeowner_Email__c){
                        propObj.Primary_Customer__c = contactObj.Id;
                        break;
                    }
                }
            }
        }
        implementSharingForProposals(proposalsList, optySalesRepMap,optyContactRoleMap, optySalesRepUserIdMap, optyMap);
    }
    
    public static Map<Id, User> staticUserMapForSharing = new Map<Id, User>();
    public static void optyAndContactSharingByAssignee(List<Proposal__c> proposalsList, Set<Id> userIds){
        Map<Id, User> userMap = new Map<Id, User>();
        Map<Id, String> optySalesRepMap = new Map<Id, String>();
        Set<Id> tempUserIds = new Set<Id>();
        if(userIds != null && !userIds.isEmpty()){
            for(Id userId : userIds){
                if(staticUserMapForSharing.containsKey(userId)){
                    User tempUserObj = staticUserMapForSharing.get(userId);
                    userMap.put(userId, tempUserObj);
                }else{
                    tempUserIds.add(userId);
                }
            }
            if(!tempUserIds.isempty() && !Test.isRunningTest()){
                for(User userObj : [Select Id, contactId,email from User where Id in :tempUserIds and contactId != null and isactive = true]){
                    userMap.put(userObj.Id, userObj);
                    staticUserMapForSharing.put(userObj.Id, userObj);
                }                   
            }           
        }
        List<Proposal__c> proposalsListForSharing = new List<Proposal__c>();
        Set<Id> optyIds = new Set<Id>();
        for(Proposal__c  proposalObj: proposalsList){
            optyIds.add(proposalObj.Opportunity__c);
            Id assigneedId = proposalObj.Assigne__c;
            User userObj = userMap.get(assigneedId);
            if(userObj != null && userObj.contactId != null){
                proposalsListForSharing.add(proposalObj);
                optySalesRepMap.put(proposalObj.Opportunity__c, userObj.email);
            }
        }

        Map<Id, Opportunity>  optyMap = EDPUtil.getOpportunitiesAndRoles(optyIds);
        Map<Id, Set<Id>> opportunityContactRoles = new Map<Id, Set<Id>>();
        Map<Id, Id> optySalesRepUserIdMap = new Map<Id, Id>();
        Set<Id> contactIds = new Set<Id>();
        for(Opportunity optyObj : optyMap.values()){
            if(optyObj.SalesRep__c != null){
                optySalesRepUserIdMap.put(optyObj.Id, optyObj.SalesRep__c);
            }
            List<OpportunityContactRole> contactRoles = (optyObj.OpportunityContactRoles != null) ? optyObj.OpportunityContactRoles : new List<OpportunityContactRole>();
            if(contactRoles != null && contactRoles.size() > 0){
                Set<Id> tempContactIds = new Set<Id>();
                for(OpportunityContactRole contactRoleObj : contactRoles){
                    contactIds.add(contactRoleObj.contactId);
                    tempContactIds.add(contactRoleObj.contactId);
                }
                if(tempContactIds.size() > 0){
                    opportunityContactRoles.put(optyObj.Id, tempContactIds);
                }
            }
        }
        implementSharingForProposals(proposalsList, optySalesRepMap, opportunityContactRoles, optySalesRepUserIdMap, optyMap);
    }
    
    public static Map<Id, Id> getSalesRepToContactMap(List<Id> userIds){
        Map<Id, Id> userContactMap = new Map<Id, Id>();
        if(userIds != null && !userIds.isEmpty()){
            for(User userObj : [Select Id, contactId from User where id in :userIds and contactId != null]){
                userContactMap.put(userObj.Id, userObj.ContactId);
            }
        }
        return userContactMap;
    }
    
    
    public static void implementSharingForProposals(List<Proposal__c> proposalsList,Map<Id, String> optySalesRepMap, 
                                                        Map<Id, Set<Id> > opportunityContactRoles,Map<Id, Id> optySalesRepUserIdMap,
                                                        Map<Id, Opportunity> mapOpps){
        Set<Id> headquarters = new Set<Id>();
        Set<Id> contactLocations = new Set<Id>(); 
        Map<String, Id> salesRepToAccountMap = new Map<String, Id>();
        Map<String,Contact> mapContacts = new Map<String,Contact>();
        Map<Id,Contact> mapContactsById = new Map<Id,Contact>();
        
        Map<Id, Id> salesRepToContactMap = new Map<Id, Id>();
        Set<Id> salesRepIds = new Set<Id>();
        if(optySalesRepUserIdMap != null && !optySalesRepUserIdMap.isEmpty()){
            salesRepToContactMap = getSalesRepToContactMap(optySalesRepUserIdMap.values());
            salesRepIds.addall(optySalesRepUserIdMap.values());
        }
        
        for(Opportunity optyObj : mapOpps.values()){
          modifyRECInfo(optyObj);
            if(optyObj.Install_Partner__c != null){
                headquarters.add(optyObj.Install_Partner__c);
            }
        }
        
       
        //RecordType partnerRecordType = PRMLibrary.getPartnerContactRecordType();
    Set<Id> recordTypeIds = PRMLibrary.getPartnerAndEmployeeRecordTypes();
        if((optySalesRepMap.values() != null && !optySalesRepMap.values().isEmpty()) || 
            (salesRepIds != null && !salesRepIds.isEmpty()) || 
            (salesRepToContactMap != null && !salesRepToContactMap.isEmpty())) {
            for(Contact contact : [select id,Email,Name,Account.Id,Account.Name,Account.Partner_Type__c, Location__c, Sunrun_User__c, division__c from contact 
                                    where (email in: optySalesRepMap.values() OR Sunrun_User__c in :salesRepIds OR Id in :salesRepToContactMap.values())
                                    and Email != null and Email != '' 
                                    and recordTypeId in :recordTypeIds ]){
                salesRepToAccountMap.put(contact.Email, contact.Account.Id);
                headquarters.add(contact.Account.Id);
                mapContacts.put(contact.Email,contact);
                mapContactsById.put(contact.Id,contact);
                if(contact.Location__c != null){
                    contactLocations.add(contact.Location__c);
                }
                if(contact.Sunrun_User__c != null){
                    salesRepToContactMap.put(contact.Sunrun_User__c, contact.Id);
                }
            }
        }
        System.debug('headquarters: ' + headquarters);
        Map<Id, Partner_Location__c> headquartersLocation = EDPUtil.getHeadquartersLocation(headquarters);
        Map<Id, Map<Id, Contact>> accountContactMap = new Map<Id, Map<Id, Contact>>();
        Set<Id> contactIds = new Set<Id>();
        Map<Id, Id> mapUser = new Map<Id, Id>();        
        
        if(headquartersLocation.keySet() != null && headquartersLocation.keySet().size() > 0){
            for(Contact contact : [select id,Email,Name,Account.Id,Account.Name,Account.Partner_Type__c, Location__c, Sunrun_User__c, division__c from contact 
                                        where (Account.Id in: salesRepToAccountMap.values() OR  Account.Id in:headquarters)
                                        and (Location__c in :headquartersLocation.keySet() OR Location__c in :contactLocations)]){
                
                Map<Id, Contact> tempContactMap = accountContactMap.containskey(contact.Account.Id) ?  
                                                accountContactMap.get(contact.Account.Id) : new Map<Id, Contact>();
                tempContactMap.put(contact.Id, contact);
                accountContactMap.put(contact.Account.Id, tempContactMap);
                if(contact.Sunrun_User__c != null){
                    mapUser.put(contact.Id, contact.Sunrun_User__c);
                }
                contactIds.add(contact.Id);
            }
        }
        System.debug('Account Key Set: ' + accountContactMap.keySet());
        
        if(contactIds.size() > 0){
            for(User usr:[select Id, Name,ContactId from user where ContactId in: contactIds and isactive = true]){
                mapUser.put(usr.ContactId,usr.Id);
            }
        }

        Map<Id, Opportunity> modifiedOpportunityMap= new Map<Id, Opportunity>();
        Map<Id, String> optySourceMap = new Map<Id, String>();
        Map<String,OpportunityStages__c> map_OpptyStages = OpportunityStages__c.getAll();       
        for(Proposal__c prop : proposalsList){
            Contact ct;
            Opportunity opty = mapOpps.get(prop.Opportunity__c);
            optySourceMap.put(opty.Id, prop.Proposal_Source__c);
            if(prop.Proposal_Source__c != null && prop.Proposal_Source__c ==  ProposalUtil.BLACK_BIRD && !Test.isRunningTest()
                && opty.SalesRep__c != null && salesRepToContactMap != null && salesRepToContactMap.containsKey(opty.SalesRep__c)){
                Id contactId = salesRepToContactMap.get(opty.SalesRep__c);
                System.debug('contactId: ' + contactId);
                ct = mapContactsById.get(contactId);
            }else if(prop.Sales_Rep_Email__c != null && prop.Sales_Rep_Email__c != ''){     
                ct = mapContacts.get(prop.Sales_Rep_Email__c);
            }
            
            if(ct != null){
                String partnerType = ct.Account.Partner_Type__c;   
                if(partnerType != null && partnerType != '' && partnerType.indexOf('Full Service') >= 0){
                    prop.Sales_Partner__c = ct.Account.Id;
                    prop.Install_Partner__c = ct.Account.Id;
                }else if(partnerType != null && partnerType != '' && partnerType.indexOf('Sales') >= 0){
                    prop.Sales_Partner__c = ct.Account.Id;
                }  
                updateInstallPartner(prop);
                String source = prop.Proposal_Source__c;

                if(opty.Sales_Partner__c != null && source != null && source == ProposalUtil.BLACK_BIRD){
                    prop.Sales_Partner__c = opty.Sales_Partner__c;
                }
                
                if(opty.Install_Partner__c != null && source != null && source == ProposalUtil.BLACK_BIRD){
                    prop.Install_Partner__c = opty.Install_Partner__c;
                }
        modifyRECInfo(prop);
        
                prop.Sales_Rep__c = ct.Name;
                prop.Partner_Sales_Rep__c = ct.Id;
                if(mapUser != null && !mapUser.isEmpty()){ 
                    if(prop.User_Name__c != null && prop.User_Name__c != '' && prop.User_Name__c.contains(EDPUtil.SUNRUN_EMAIL_EXTENSION)){
                        prop.Assigne__c = null;
                    }else{
                        prop.Assigne__c = (mapUser.containsKey(ct.id)) ? mapUser.get(ct.id) : prop.Assigne__c ;                         
                    }
                }
    
                if(mapOpps != null && mapOpps.size() > 0){
                    opportunity optyObj = mapOpps.get(prop.Opportunity__c);
                    if(map_OpptyStages.containsKey(optyObj.stageName)){
                    optyObj.Sales_Representative__c =  ct.id;
                    modifiedOpportunityMap.put(optyObj.Id, optyObj);
                    }
                }
                calculateProposalCostStack(prop, ct);
            }
        } 
        
        if(modifiedOpportunityMap != null && modifiedOpportunityMap.size() > 0){
            update modifiedOpportunityMap.values();
        }

        List<opportunityShare> opportunityShareList = new List<opportunityShare>();
        List<ContactShare> contactShareList = new List<ContactShare>();
        for(Opportunity opty : mapOpps.values()){
          modifyRECInfo(opty);
            String proposalSource = optySourceMap.get(opty.Id);
            Set<Id> accountIds = new Set<Id>();
            Id optyId = opty.Id;
            Contact ct;
            Id accountId;
            Boolean shareOppty=true;
            shareOppty = (opty.Channel_2__c=='Partner' && opty.Lead_Source_2__c=='Partner: Legacy') ? false : true;
            System.debug('proposalSource: ' + proposalSource);
            if((proposalSource != null && proposalSource == ProposalUtil.BLACK_BIRD) 
                && (opty.SalesRep__c != null && salesRepToContactMap != null && salesRepToContactMap.containsKey(opty.SalesRep__c))){
                Id contactId = salesRepToContactMap.get(opty.SalesRep__c);
                ct = mapContactsById.get(contactId);
            }else{      
                String tempSalesRepEmail = optySalesRepMap.get(opty.Id);
                accountId = salesRepToAccountMap.get(tempSalesRepEmail);
                ct = mapContacts.get(tempSalesRepEmail);
            }
            if(ct != null && ct.accountId != null){
                accountId = ct.accountId;
                accountIds.add(accountId);
            }
            System.debug('ct: ' + ct);
            
            if(proposalSource != null && proposalSource == ProposalUtil.BLACK_BIRD){
                if(opty.Install_Partner__c != null){
                    accountIds.add(opty.Install_Partner__c);
                }
                if(opty.Sales_Partner__c != null){
                    accountIds.add(opty.Sales_Partner__c);
                }
            }
      
      Id SunrunIncId=System.Label.Sunrun_Inc_Id;
            Set<Id> optyContactIds = opportunityContactRoles.get(opty.Id);
            
            for(Id tempAccountId : accountIds){
                String accountIdStr = tempAccountId + '';
        if(accountIdStr.contains(SunrunIncId)){
                  continue;
                }                
                Map<Id, Contact> contactMap = accountContactMap.get(tempAccountId);
                if(contactMap != null && contactMap.size() > 0){
                    for(Id contactId : contactMap.keySet()){
                        if(mapUser != null && mapUser.size() > 0){
                            Id tempUserId = mapUser.get(contactId);
                            if(tempUserId != null){
                                //OpportunityShare oppShare= new OpportunityShare();
                                 //oppShare.OpportunityAccessLevel = 'Edit';
                                //oppShare.OpportunityId = optyId;
                                 //oppShare.UserOrGroupId =  tempUserId;
                           Id userOrGroupId = (Test.isRunningTest()) ? UserInfo.getUserId() : tempUserId;
                           OpportunityShare oppShare = createOpportunitySharing(userOrGroupId, optyId);                                
                                
                                if(shareOppty){
                                  opportunityShareList.add(oppShare);
                                }
                                
                            }
                        }   
                        //Share the Opty Contacts
                        if(optyContactIds != null && optyContactIds.size() > 0){
                            if(mapUser != null && mapUser.size() > 0){
                                Id tempUserId = mapUser.get(contactId);
                                if(tempUserId != null){
                                    for(Id optyContactId : optyContactIds){
                                        //ContactShare contactShareObj = new ContactShare();
                                        //contactShareObj.ContactAccessLevel = 'Edit';
                                        //contactShareObj.ContactId = optyContactId;
                                        //contactShareObj.UserOrGroupId =  tempUserId;

                               Id userOrGroupId = (Test.isRunningTest()) ? UserInfo.getUserId() : tempUserId;
                               ContactShare contactShareObj = createContactSharing(userOrGroupId, optyContactId);
                                        contactShareList.add(contactShareObj);                          

                                    }
                                }
                            }
                        } 
                        
                        if(Test.isRunningTest())
                          break;
                                      
                    }
                }
            }
        } 
        if(opportunityShareList.size() > 0){
            Database.UpsertResult[]  result1 = database.upsert(opportunityShareList,false);
        }
        if(contactShareList.size() > 0){
            Database.UpsertResult[] result2 =  database.upsert(contactShareList,false);
        }
    }

    public static Map<Id, Proposal__c> getProposalsMap(Set<Id> proposalIds){
        String proposalSOQLStr = ProposalUtil.getProposalSQLStr();
        proposalSOQLStr += ' where Id in :proposalIds ' ;
        Map<Id, Proposal__c> proposalsMap = new Map<id,Proposal__c>((List<Proposal__c>)Database.query(proposalSOQLStr));
        return proposalsMap;
    }

    public static List<Proposal__c> getProposals(Set<Id> proposalIds){
        String proposalSOQLStr = ProposalUtil.getProposalSQLStr();
        proposalSOQLStr += ' where Id in :proposalIds ' ;
        List<Proposal__c> proposalsList = Database.query(proposalSOQLStr);
        return proposalsList;
    }
  
  public static String staticProposalSQLStr = '';
  public static String getProposalSQLStr(){
    if(staticProposalSQLStr == null || staticProposalSQLStr == ''){
      String tempStr = '';
      Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get('proposal__c').getDescribe().Fields.getMap();
      for (String fieldName : fMap.keySet()){
        if(fieldName != 'lastvieweddate' && fieldName != 'lastreferenceddate' )
            tempStr += fieldName + ', ' ;
      }
      staticProposalSQLStr = 'Select ' + tempStr ;
      staticProposalSQLStr += ' Opportunity__r.Prospect_Id__c, Generation_Asset__r.In_TE_fund__c, Generation_Asset__r.NTP_Granted__c, ';
      staticProposalSQLStr += ' Original_Proposal_ID__r.Revised_Proposal__c, Opportunity__r.Id, Opportunity__r.Name, Opportunity__r.StageName, Opportunity__r.AccountId, ';
      staticProposalSQLStr += ' Opportunity__r.Purchased_Thru__c';
      staticProposalSQLStr += ' from Proposal__c ';
    }
    return staticProposalSQLStr;
  }
    
    
  /*
    public static String getProposalSQLStr(){
        String proposalSQLStr = 'Select Id, name, Opportunity__c, Sales_Rep_Email__c, Install_Partner__c, Sales_Partner__c, Original_Proposal_ID__c, New_Home_without_Utility_Bills__c, ';
                proposalSQLStr += ' Primary_Customer__c, Current_Customer_Credit_Report__c, Homeowner_Email__c, stage__c, Credit_Status__c, Completed_Approval_Process__c, ';
                proposalSQLStr += ' Customer_Signoff_Date__c, SR_Signoff__c,Revised_SR_Signoff__c, Generation_Asset__c, Change_Order_ID__c, Proposal_ID__c, Change_Order_Information__c, ';
                proposalSQLStr += ' Credit_team_notes__c,Home_Type__c, Conditional_Approval_Amount__c, ACH_Required__c, Total_Solar_Prepay_Required__c, Partner_Financed__c, ';
                proposalSQLStr += ' Signed__c, Opportunity__r.Prospect_Id__c, Proposal_Source__c, Generation_Asset__r.In_TE_fund__c, Generation_Asset__r.NTP_Granted__c, Name_on_Credit_Verified__c, ';
                proposalSQLStr += ' Sunrun_Credit_Status__c, Conditional_Approval__c, Proposal_Type__c, Sales_Rep__c, status__c, User_Name__c, Assigne__c from Proposal__c ';
        return proposalSQLStr;
    
    }
  */
  
    public static void shareContactsByProposal(Map<Id, Id> contactProposalMap){
        
        Map<Id, Id> proposalOptyMap = new Map<Id, Id>();
        if(contactProposalMap != null && contactProposalMap.values().size() > 0){
            for(Proposal__c prposalObj : [Select Id, opportunity__c from Proposal__c where Id in :contactProposalMap.values()]){
                proposalOptyMap.put(prposalObj.Id, prposalObj.opportunity__c);
            }
        }
        
        //Select Id, OpportunityAccessLevel, UserOrGroupId, OpportunityId from OpportunityShare where OpportunityId = '006g0000002FSg3'
        Map<Id, List<OpportunityShare>> opportunityShareMap = new Map<Id, List<OpportunityShare>>();
        Set<Id> optyIds = new Set<Id>();
        if(proposalOptyMap.values() != null && proposalOptyMap.values().size() > 0){
            for(OpportunityShare optyShareObj : [Select Id, OpportunityAccessLevel, UserOrGroupId, OpportunityId 
                                                    from OpportunityShare where OpportunityId in :proposalOptyMap.values()]){
                
                List<OpportunityShare> opportunityShareList = opportunityShareMap.containsKey(optyShareObj.OpportunityId) ?  
                                                                opportunityShareMap.get(optyShareObj.OpportunityId) : new List<OpportunityShare>();
                
                opportunityShareList.add(optyShareObj);
                opportunityShareMap.put(optyShareObj.OpportunityId, opportunityShareList);
                optyIds.add(optyShareObj.OpportunityId);
            }
        }
        
        Map<Id, Set<Id>> contactToOptyIds = new Map<Id, Set<Id>>();
        for(OpportunityContactRole optyContactRole : [Select Id, contactId, opportunityId, role from OpportunityContactRole 
                                                        where contactId IN :contactProposalMap.keySet() AND 
                                                        opportunityId IN :optyIds]){
                                                        //opportunityId IN :optyIds AND role = 'Other']){
            Set<Id> tempOptyIds =   contactToOptyIds.containskey(optyContactRole.contactId) ? contactToOptyIds.get(optyContactRole.contactId) : new set<Id>();
            tempOptyIds.add(optyContactRole.opportunityId);
            contactToOptyIds.put(optyContactRole.contactId, tempOptyIds);
        }
        
        List<ContactShare> contactShareList = new List<ContactShare>();
        List<OpportunityContactRole> optyContactRoleList = new List<OpportunityContactRole>();
        for(Id contactId : contactProposalMap.keySet()){
            Id proposalId = contactProposalMap.get(contactId);
            Id optyId = proposalOptyMap.get(proposalId);
            if(opportunityShareMap.containsKey(optyId)){
                List<OpportunityShare> opportunityShareList = opportunityShareMap.get(optyId);
                for(OpportunityShare optyShareObj : opportunityShareList){
                    //ContactShare contactShareObj = new ContactShare();
                    //contactShareObj.ContactAccessLevel = optyShareObj.OpportunityAccessLevel;
                    //contactShareObj.ContactId = contactId;
                    //contactShareObj.UserOrGroupId =  optyShareObj.UserOrGroupId;
          Id userOrGroupId = (Test.isRunningTest()) ? UserInfo.getUserId() : optyShareObj.UserOrGroupId;
                     ContactShare contactShareObj = createContactSharing(userOrGroupId, contactId);                    
                    contactShareList.add(contactShareObj);                  
                }
            }
            Boolean createOptyContactRole = true;
            if(contactToOptyIds != null && contactToOptyIds.containsKey(contactId)){
                Set<Id> tempOptyIds = contactToOptyIds.get(contactId);
                if(tempOptyIds != null && tempOptyIds.contains(optyId)){
                    createOptyContactRole = false;
                }
            }
            if(createOptyContactRole == true){
                OpportunityContactRole optyContactRoleObj = new OpportunityContactRole();
                optyContactRoleObj.contactId = contactId;
                optyContactRoleObj.OpportunityId = optyId;
                optyContactRoleObj.role = 'Other';
                optyContactRoleList.add(optyContactRoleObj);
            }
        }

        if(contactShareList.size() > 0){
            database.upsert(contactShareList,false);
        }
        
        if(optyContactRoleList.size() > 0){
            database.upsert(optyContactRoleList,false);
        }
    }
    
    public static void resetCustomerCreditPendingComments(Set<Id> customerCreditIds){
        List<Customer_Credit__c> customerCreditList = new List<Customer_Credit__c>();
        for(Customer_Credit__c ccObj : [Select Id,  Pending_Reason__c, Pending_Comments__c, Pending_Notes__c 
                                            from Customer_Credit__c where Id in :customerCreditIds]){
            if(ccObj.Pending_Reason__c != null || ccObj.Pending_Comments__c != null
                || ccObj.Pending_Notes__c != null){
                ccObj.Pending_Reason__c = null;
                ccObj.Pending_Comments__c = null;
                ccObj.Pending_Notes__c = null;
                customerCreditList.add(ccObj);
            }
        }
        if(customerCreditList.size() > 0 ){
            update customerCreditList;
        }
    }

    
    public static void inactivateChildProposals(Map<Id, Set<Id>> opportunityProposalMap, Set<Id> signedProposalIds, 
                                                Set<Id> ultimateProposalIds){
        List<Proposal__c> modifiedProposals = new List<Proposal__c>();
        Set<String> inactiveProposalStages = new Set<String>();
        inactiveProposalStages.add(ProposalUtil.SUNRUN_VOID);
        inactiveProposalStages.add(EDPUtil.INACTIVE);
        inactiveProposalStages.add(EDPUtil.REPLACED_BY);
        String blackBird = ProposalUtil.BLACK_BIRD;
        if(opportunityProposalMap != null && opportunityProposalMap.size() > 0){
            for(Proposal__c proposalObj : [Select Id, Signed__c, Stage__c, Opportunity__c, Ultimate_Parent_Proposal__c, 
                                            Original_Proposal_ID__c, Proposal_Type__c from Proposal__c 
                                            where Opportunity__c in :opportunityProposalMap.keySet() 
                                            and proposal_source__c =:blackBird]){
                Set<Id> childproposals = opportunityProposalMap.get(proposalObj.Opportunity__c);
                if(childproposals == null || !childproposals.contains(proposalObj.Id)){
                    
                    if(proposalObj.Stage__c == null || !inactiveProposalStages.contains(proposalObj.Stage__c)){
                        if((proposalObj.Signed__c == true) && (ultimateProposalIds.contains(proposalObj.Id) 
                            || ultimateProposalIds.contains(proposalObj.Ultimate_Parent_Proposal__c))){
                            proposalObj.stage__c = EDPUtil.REPLACED_BY;
                        }else if(proposalObj.Original_Proposal_ID__c == null 
                            || (proposalObj.Original_Proposal_ID__c != null 
                                && proposalObj.Proposal_Type__c != null && proposalObj.Proposal_Type__c == SEED)){
                            proposalObj.stage__c = EDPUtil.INACTIVE;
                        }else{
                            proposalObj.stage__c = ProposalUtil.SUNRUN_VOID;
                        }
                        modifiedProposals.add(proposalObj);
                    }
                    
                }
            }
        }

        if(modifiedProposals.size() > 0 ){
            update modifiedProposals;
        }       
    }

    public static Map<Id, String> getSignedRootIds(Map<Id, Proposal__c> proposalMap, Boolean skipCurrentNode){
        Map<Id, String> signedProposalMap = new Map<Id, Id>();
        for(Proposal__c proposalObj : proposalMap.values()){
            String signedProposalId = getSignedRootId(proposalObj, skipCurrentNode);
            if(signedProposalId != null && signedProposalId != proposalObj.Id){
                signedProposalMap.put(proposalObj.Id, signedProposalId);
            }
        }
        return signedProposalMap;
    }
    
    public static String getSignedRootProposalName(Proposal__c proposalObj){
        String rootId = '';
        if(proposalObj != null){
            if(proposalObj.signed__c == true && isCustomerProposal(proposalObj) ){
                System.debug('proposalObj.Name: ' + proposalObj.Name);
                rootId = proposalObj.Name;
                return rootId;
            }
            
            do{
                if(proposalObj.Original_Proposal_ID__c == null){
                    break;
                }
                Proposal__c parentProposalObj = [Select Id, Change_Order_Information__c, Proposal_Source__c, name, signed__c, Original_Proposal_ID__c from Proposal__c where id =:proposalObj.Original_Proposal_ID__c];
                if(parentProposalObj.signed__c == true && isCustomerProposal(parentProposalObj) ){
                    System.debug('parentProposalObj.Name: ' + parentProposalObj.Name);
                    rootId = parentProposalObj.Name;
                    return rootId;                  
                }
                proposalObj = parentProposalObj;
            }while(true);
        }
        System.debug('rootId: ' + rootId);
        return rootId;
    }   

    public static String getSignedRootId(Proposal__c proposalObj, boolean skipCurrentNode){
        String rootId = '';
        if(proposalObj != null){
            if(proposalObj.signed__c == true && skipCurrentNode == false){
                rootId = proposalObj.Id;
                return rootId;
            }
            
            do{
                if(proposalObj.Original_Proposal_ID__c == null){
                    break;
                }
                Proposal__c parentProposalObj = [Select Id, Change_Order_Information__c, Proposal_Source__c, signed__c, Original_Proposal_ID__c from Proposal__c where id =:proposalObj.Original_Proposal_ID__c];
                if(parentProposalObj.signed__c == true){
                    rootId = parentProposalObj.Id;
                    return rootId;                  
                }
                proposalObj = parentProposalObj;
            }while(true);
        }
        return rootId;
    }

    public static void calculateUltimateProposalId(List<Proposal__c> proposalsList){
        Set<String> inactiveStages = getInactiveProposalStages();
        Set<String> prentProposalNames = new Set<String>();
        Set<Id> opportunityIds = new Set<Id>();
        Set<Id> opportunityIdsWithSignedProposals = new Set<Id>();
        for(Proposal__c proposalObj : proposalsList){
            opportunityIds.add(proposalObj.Opportunity__c);
        }
        Map<Id, Map<String, Proposal__c>> optyProposalMap = new Map<Id, Map<String, Proposal__c>>();
        Map<String, Proposal__c> ultimateParentIdMap = new Map<String, Proposal__c>();
        if(!opportunityIds.isEmpty()){
  
      String proposalSOQLStr = ProposalUtil.getProposalSQLStr();
            proposalSOQLStr += ' where opportunity__c in :opportunityIds order by name asc ' ;
      for(Proposal__c proposalObj : Database.query(proposalSOQLStr)){    
			System.debug('>>> Proposal Name ' + proposalObj.Name);
           // for(Proposal__c proposalObj : [Select Id, name, Original_Proposal_ID__c, Ultimate_Parent_Proposal__c,stage__c,Sunrun_Credit_Status__c,
            //                                Opportunity__c, signed__c, Proposal_Type__c, change_order__c, Proposal_Source__c, Conditional_Approval__c,
           //                                 Primary_Customer__c,Current_Customer_Credit_Report__c, Credit_Status__c,SR_Credit_Status__c,Name_on_Credit_Verified__c,
           //                                 Credit_team_notes__c, Conditional_Approval_Amount__c, ACH_Required__c, Total_Solar_Prepay_Required__c,
           //                                 Partner_Financed__c from Proposal__c where opportunity__c in :opportunityIds order by name asc]){
                Map<String, Proposal__c> proposalMap = optyProposalMap.containsKey(proposalObj.Opportunity__c) ? optyProposalMap.get(proposalObj.Opportunity__c) : new Map<String, Proposal__c>();
                proposalMap.put(proposalObj.name, proposalObj);
                optyProposalMap.put(proposalObj.Opportunity__c, proposalMap);
                ultimateParentIdMap.put(proposalObj.name, proposalObj);
                if(proposalObj.proposal_source__c == BLACK_BIRD && !inactiveStages.contains(proposalObj.stage__c) 
                    && (proposalObj.signed__c == true)){
                    opportunityIdsWithSignedProposals.add(proposalObj.Opportunity__c);
                }
            }           
        }
        
        for(Proposal__c proposalObj : proposalsList){
            Proposal__c parentProposal;
            if(proposalObj.proposal_source__c == BLACK_BIRD){
                if(proposalObj.Parent_Proposal_Id__c != null 
                    && ultimateParentIdMap.containsKey(proposalObj.Parent_Proposal_Id__c)){
                    parentProposal = ultimateParentIdMap.get(proposalObj.Parent_Proposal_Id__c);
                    proposalObj.Original_Proposal_ID__c = parentProposal.Id;
                    proposalObj.Ultimate_Parent_Proposal__c = (parentProposal.Original_Proposal_ID__c == null) ? parentProposal.Id  : parentProposal.Ultimate_Parent_Proposal__c;
                }
                setParentProposalInformation(proposalObj, parentProposal);
                if(proposalObj.proposal_source__c == BLACK_BIRD && 
                    proposalObj.Proposal_Type__c == SEED && 
                    opportunityIdsWithSignedProposals.contains(proposalObj.opportunity__c)){
                    proposalObj.Stage__c = EDPUtil.INACTIVE;
                }
            }
        }
        

    }


    
    public static void processNewlyCreatedBBProposals(Map<Id, Proposal__c> proposalMap,
                                                      Map<Id, String> signedProposalIds,
                                                        Boolean copyDocuSignStatus,
                                                        Boolean copyWorkingDocumentsOnly){      
        
        Set<Id> inputProposalIds = proposalMap.keySet();
        Map<Id, Map<String, List<SR_Attachment__C>>> proposalToSRAttachmentMap = new Map<Id, Map<String, List<SR_Attachment__C>>>();
        Set<String> envelopIds = new Set<String>();
        Map<String, boolean> recipientSignedStatusMap = new Map<String, boolean>();
        //Map<Id, String> signedProposalIds = getSignedRootIds(proposalMap, true);
        List<SR_Attachment__c> deletedSRAttachments = new List<SR_Attachment__c>();
        if(signedProposalIds.size() > 0){
            List<Id> proposalIdsForSRAttachments = signedProposalIds.values();
            String soqlStr;
            String blackBirdStr = ProposalUtil.BLACK_BIRD;
            soqlStr = SRAttachmentManager.getSRAttachmentSOQL();
            soqlStr += '  WHERE (Proposal__c IN :proposalIdsForSRAttachments OR Proposal__c IN :inputProposalIds) ' ;
            soqlStr += '  and Proposal__r.proposal_source__c = :blackBirdStr ' ;
            soqlStr += '  and Active__c = true ' ;
            for(SR_Attachment__c srAttachmentObj : Database.query(soqlStr)){    
                
                if(srAttachmentObj.proposal__c != null && inputProposalIds.contains(srAttachmentObj.proposal__c)){
                    if(srAttachmentObj.Parent_SR_Attachment__c != null && srAttachmentObj.Document_Source__c != EDPUtil.PROPOSAL_TOOL_SOURCE){
                        srAttachmentObj.active__c = false;
                        deletedSRAttachments.add(srAttachmentObj);
                    }
                }else{
                    if(srAttachmentObj.Document_Classification__c != null){
                        Map<String, List<SR_Attachment__C>> srAttachmentsMap = proposalToSRAttachmentMap.containsKey(srAttachmentObj.Proposal__c) ? 
                                                                proposalToSRAttachmentMap.get(srAttachmentObj.Proposal__c) : new Map<String, List<SR_Attachment__C>>();
    
                        List<SR_Attachment__C> srAttachments = srAttachmentsMap.containskey(srAttachmentObj.Document_Classification__c) ? 
                                                                    srAttachmentsMap.get(srAttachmentObj.Document_Classification__c) : new List<SR_Attachment__C>();
                        srAttachments.add(srAttachmentObj);
                        srAttachmentsMap.put(srAttachmentObj.Document_Classification__c, srAttachments);
                        proposalToSRAttachmentMap.put(srAttachmentObj.Proposal__c, srAttachmentsMap);
                    }
                }
            }
        }
        
        if(deletedSRAttachments.size() > 0 ){
            update deletedSRAttachments;
        }
        
        if(proposalToSRAttachmentMap.size() > 0 ){
            createSRAttachmentsForBBProposals(signedProposalIds, proposalMap, proposalToSRAttachmentMap, copyDocuSignStatus, copyWorkingDocumentsOnly);
        }
    }

    public static string getProposalType(String proposalType){
        String result = proposalType;
        if(proposalType != null && proposalType.contains(ProposalUtil.CUSTOMER_CHANGE_ORDER) && proposalType.contains(ProposalUtil.EPC_CHANGE_ORDER)){
            result = ProposalUtil.CUSTOMER_EPC_CHANGE_ORDER;
        }else if(proposalType != null && proposalType.contains(ProposalUtil.SALES_PARTNER_CHANGE_ORDER) && proposalType.contains(ProposalUtil.EPC_CHANGE_ORDER)){
            result = ProposalUtil.EPC_CHANGE_ORDER;
        }else if(proposalType != null && proposalType.contains(ProposalUtil.SALES_PARTNER_CHANGE_ORDER) && proposalType.contains(ProposalUtil.CUSTOMER_CHANGE_ORDER)){
            result = ProposalUtil.CUSTOMER_CHANGE_ORDER;
        }else if(proposalType != null && proposalType.contains(ProposalUtil.SALES_PARTNER_CHANGE_ORDER) && proposalType.contains(ProposalUtil.NO_SIGNATURES_REQUIRED)){
            result = ProposalUtil.NO_SIGNATURES_REQUIRED;
        }   
        return result;  
    }

    public static void createSRAttachmentsForBBProposals(Map<Id, Id> bbProposalMap, 
                                                            Map<Id, Proposal__c> proposalMap,
                                                            Map<Id, Map<String, List<SR_Attachment__C>>> proposalToSRAttachmentMap,
                                                            Boolean copyDocuSignStatus,
                                                            Boolean copyWorkingDocumentsOnly){

        List<SR_Attachment__c> newSRAttachments = new List<SR_Attachment__c>();
        Map<String, SR_Attachment__c> envelopToSRAttachmentMap = new Map<String, SR_Attachment__c>();
        for(Id proposalId : bbProposalMap.keySet()){
            Id srAttachmentProposalId = bbProposalMap.get(proposalId);
            Proposal__c proposalObj = proposalMap.get(proposalId);
            String proposalType = getProposalType(proposalObj.Change_Order_Information__c);
            Map<String, Map<String, Set<String>>> documentNamesToCopyFromParent = EDPDocumentSettings.getDocumentTypesToCopyFromParent();
            System.debug('documentNamesToCopyFromParent: ' + documentNamesToCopyFromParent);
            if(proposalType == null || proposalType == '' || !documentNamesToCopyFromParent.containsKey(proposalType)){
                continue;
            }   
            Map<String, Set<String>> documentNamesByProposalType = documentNamesToCopyFromParent.get(proposalType);
            Set<String> signedDocs = documentNamesByProposalType.get(ProposalUtil.SIGNED_DOCS);
            Set<String> unSignedDocs = documentNamesByProposalType.get(ProposalUtil.UN_SIGNED_DOCS);
            Set<String> proposalToolGeneratedDocs = documentNamesByProposalType.get(ProposalUtil.PROPOSAL_TOOL_GEN_DOCS);
            
            Map<String, List<SR_Attachment__C>> parentSRAttachmentsMap = proposalToSRAttachmentMap.get(srAttachmentProposalId);
            Map<String, List<SR_Attachment__C>> existingSRAttachmentsMap = proposalToSRAttachmentMap.get(proposalId);
            Set<String> existingDocumentTypes = new Set<String>(); 
            
            if(existingSRAttachmentsMap == null){
                existingSRAttachmentsMap = new  Map<String, List<SR_Attachment__C>>();
            }
            
            if(parentSRAttachmentsMap != null && parentSRAttachmentsMap.size() > 0){
                for(String documentType : parentSRAttachmentsMap.keySet()){
                    List<SR_Attachment__C> parentSRAttachments = parentSRAttachmentsMap.get(documentType);
                    if(parentSRAttachments != null && parentSRAttachments.size() > 0){
                        for(SR_Attachment__c srAttachment : parentSRAttachments){
                            Boolean createSRAttachment = false;
                            
                            if(srAttachment.Active__c == false)
                                continue;
                            
                            String proposalName = proposalObj.Name;                         
                            if(srAttachment.Document_Source__c == EDPUtil.PROPOSAL_TOOL_SOURCE && copyWorkingDocumentsOnly == false){
                                if(!proposalToolGeneratedDocs.contains(srAttachment.Document_Type_Name__c)){
                                    continue;
                                }
                                createSRAttachment = true;
                            }
        
                            if((srAttachment.Document_Source__c != EDPUtil.PROPOSAL_TOOL_SOURCE) 
                                &&(srAttachment.Wet_Sign_Status__c == EDPUtil.SIGNED 
                                || srAttachment.Wet_Sign_Status__c == EDPUtil.NA
                                || (srAttachment.DocuSign_Status__c != null 
                                    && srAttachment.DocuSign_Status__c  != '' 
                                    && srAttachment.DocuSign_Status__c != EDPUtil.VOIDED))){
                                if((srAttachment.Wet_Sign_Status__c != null && srAttachment.Wet_Sign_Status__c == EDPUtil.NA
                                    && !unSignedDocs.contains(srAttachment.Document_Type_Name__c)) || 
                                    (srAttachment.Wet_Sign_Status__c != EDPUtil.NA
                                    && !signedDocs.contains(srAttachment.Document_Type_Name__c)))
                                {
                                    continue;
                                }
                                
                                if(!existingSRAttachmentsMap.containsKey(srAttachment.Document_Classification__c)){
                                    createSRAttachment = true;
                                }else{
                                    List<SR_Attachment__C> tempExitingSRAttachmentsList = existingSRAttachmentsMap.get(srAttachment.Document_Classification__c);
                                    createSRAttachment = true;
                                    
                                    for(SR_Attachment__c tempExitingSRAttachment : tempExitingSRAttachmentsList){
                                        if(tempExitingSRAttachment.Document_Type_Name__c != EDPUtil.OTHER && 
                                            tempExitingSRAttachment.Document_Type_Name__c  == srAttachment.Document_Type_Name__c &&
                                            (tempExitingSRAttachment.Document_Source__c == srAttachment.Document_Source__c) || 
                                            (tempExitingSRAttachment.Document_Source__c == EDPUtil.MANUAL_UPLOAD_SOURCE && 
                                                srAttachment.Document_Source__c == EDPUtil.E_SIGN) ||
                                            (tempExitingSRAttachment.Document_Source__c == EDPUtil.E_SIGN && 
                                                srAttachment.Document_Source__c == EDPUtil.MANUAL_UPLOAD_SOURCE)){
                                            createSRAttachment = false;
                                            break;
                                        }                                       
                                    }
                                }
                            }
                            if(createSRAttachment){
                                SR_Attachment__c newSRAttachmentObj = EDPUtil.cloneSRAttachmentOnSFDC(srAttachment, proposalObj.Id);
                                newSRAttachmentObj.Parent_SR_Attachment__c = srAttachment.Id;
                                newSRAttachments.add(newSRAttachmentObj);
                                List<SR_Attachment__C> tempSRAttachments = existingSRAttachmentsMap.containskey(srAttachment.Document_Classification__c) ? 
                                                                        existingSRAttachmentsMap.get(srAttachment.Document_Classification__c) : new List<SR_Attachment__C>();
                                
                                tempSRAttachments.add(newSRAttachmentObj);
                                existingSRAttachmentsMap.put(newSRAttachmentObj.Document_Classification__c, tempSRAttachments);
                                
                                if(newSRAttachmentObj.Envelop_Id__c != null && newSRAttachmentObj.Envelop_Id__c != ''){
                                    envelopToSRAttachmentMap.put(newSRAttachmentObj.Envelop_Id__c, newSRAttachmentObj);
                                }
                            }
                        }                       
                    }
                }
            }
        }

        if(newSRAttachments.size() > 0){
            insert newSRAttachments;
        }

        if(copyDocuSignStatus){
            List<dsfs__DocuSign_Status__c> modifiedDocuSignStatusList = new List<dsfs__DocuSign_Status__c>();
            for(dsfs__DocuSign_Status__c docuSignStatusObj : [Select Id, dsfs__DocuSign_Envelope_ID__c, SR_Attachment__c from dsfs__DocuSign_Status__c 
                                                                    where dsfs__DocuSign_Envelope_ID__c in :envelopToSRAttachmentMap.keySet()]){
                
                SR_Attachment__c tempSRAttachmentObj  = envelopToSRAttachmentMap.get(docuSignStatusObj.dsfs__DocuSign_Envelope_ID__c);
                docuSignStatusObj.SR_Attachment__c = tempSRAttachmentObj.Id;
                modifiedDocuSignStatusList.add(docuSignStatusObj);  
            }
            
            if(modifiedDocuSignStatusList.size() > 0 ){
                update modifiedDocuSignStatusList;
            }           
        }

    }
    
    public static Map<Id, String> voidProposals(Map<Id, Proposal__C> proposalMap, Map<Id, String> reasonMap, boolean forceVoid){
        Map<Id, String> proposalVoidResultMap = new Map<Id, String>();
        String errorMessage = ProposalUtil.SUCCESS;
        try{
            List<Proposal__c> modifiedProposals = new List<Proposal__c>();
            if(proposalMap != null && !proposalMap.isEmpty()){
                for(Proposal__c proposalObj : proposalMap.values()){
                    if(forceVoid != true && proposalObj.stage__c == EDPUtil.INACTIVE){
                        continue;
                    }
                    if( proposalObj.Stage__c != EDPUtil.SR_OPS_APPROVED ) {
                        proposalObj.SR_Signoff__c = null; 
                        proposalObj.Customer_Signoff_Date__c = null;
                      //  proposalObj.signed__c = false;
                    }
                    
                    proposalObj.Current_Customer_Credit_Report__c = null;
                    proposalObj.ACH_Required__c = false;              
                    String voidReason = '';
                    if(reasonMap.containsKey(proposalObj.Id)){
                        voidReason = reasonMap.get(proposalObj.Id);
                    }
                    
                    if(forceVoid == true){
                        proposalObj.stage__c = ProposalUtil.SUNRUN_VOID;
                        proposalObj.Status_Reason__c = voidReason;
                    }else{
                        if(proposalObj.Original_Proposal_ID__c == null 
                            || proposalObj.Proposal_Type__c == ProposalUtil.SEED){
                            proposalObj.stage__c = EDPUtil.INACTIVE;
                        }else{
                            proposalObj.stage__c = ProposalUtil.SUNRUN_VOID;
                            proposalObj.Status_Reason__c = voidReason;
                        }
                    }
                    modifiedProposals.add(proposalObj);
                }
                if(!modifiedProposals.isEmpty()){
                    update modifiedProposals;
                }
                voidDocuSignESignatures(proposalMap.keySet());
            }
        }catch(Exception exceptionObj){
            System.debug('Unable to void the Proposal: ' + exceptionObj);
            errorMessage = exceptionObj.getMessage();
        }
        
        if(proposalMap != null && !proposalMap.isEmpty()){
            for(Id proposalId : proposalMap.keySet()){
                proposalVoidResultMap.put(proposalId, errorMessage);
            }
        }
        
        return proposalVoidResultMap;
    }
    
    public static Map<Id, String> voidProposals(Set<Id> proposalIds, Map<Id, String> reasonMap, boolean forceVoid){
        String blackBirdStr = ProposalUtil.BLACK_BIRD;
        String errorMessage = ProposalUtil.SUCCESS;
        //Map<Id, String> reasonMap = new Map<Id, String>();
        Map<Id, String> proposalVoidResultMap = new Map<Id, String>();
        try{
            Map<Id, Proposal__C> proposalMap = new Map<Id, Proposal__C>();
            if(!proposalIds.isEmpty()){
                for(Proposal__c proposalObj : [Select Id, Original_Proposal_ID__c, Proposal_Type__c, Current_Customer_Credit_Report__c,
                                                Proposal_Source__c, stage__c, signed__c, ACH_Required__c, Customer_Signoff_Date__c,
                                                SR_Signoff__c from Proposal__c where Id in :proposalIds 
                                                and Proposal_Source__c =:blackBirdStr]){
                    proposalMap.put(proposalObj.Id, proposalObj);
                }
                proposalVoidResultMap = voidProposals(proposalMap, reasonMap, forceVoid);
            }
        }catch(Exception exceptionObj){
            errorMessage = exceptionObj.getMessage();
            System.debug('Unable to void the Proposal: ' + exceptionObj);
        }
        
        if(proposalIds != null && proposalVoidResultMap.isEmpty()){
            for(Id proposalId : proposalIds){
                proposalVoidResultMap.put(proposalId, errorMessage);
            }
        }
        return proposalVoidResultMap;
    }

    @Future(callout=true)
    public static void voidDocuSignESignatures(Set<Id> proposalIds){    
        
        String blackBird = ProposalUtil.BLACK_BIRD;
        String proposalToolSource = EDPUtil.PROPOSAL_TOOL_SOURCE;
        
        try{    
        Set<Id> proposalsWithCompletedESigns = new Set<Id>();
        Map<Id, Proposal__c> proposalMap = new Map<Id, Proposal__c>();
        Map<Id, Set<String>> proposalToEnvelopMap = new Map<Id, Set<String>>();
        Map<Id, String> proposalResultMap = new Map<Id, String>(); 
        Map<String, SR_Attachment__c> envelopToSRAttachmentMap = new Map<String, SR_Attachment__c>();
        String soqlStr;
        Map<Id, SR_Attachment__c> srAttachmentMap = new Map<Id, SR_Attachment__c>();
        String blackBirdStr = ProposalUtil.BLACK_BIRD;
        soqlStr = SRAttachmentManager.getSRAttachmentSOQL();
        soqlStr += '  WHERE Proposal__c IN :proposalIds ' ;
        soqlStr += '  AND active__c = true ' ;
        soqlStr += '  AND Proposal__r.proposal_source__c =:blackBird ' ;
        soqlStr += '  AND Document_Source__c != :proposalToolSource ';
        for(SR_Attachment__c srAttachmentObj : Database.query(soqlStr)){
            //srAttachmentObj.active__c = false;
            //srAttachmentMap.put(srAttachmentObj.Id, srAttachmentObj);
            Proposal__c proposalObj = srAttachmentObj.proposal__r;
            proposalMap.put(proposalObj.Id, proposalObj);                       
            if(srAttachmentObj.Document_Classification__c != null){
                if(srAttachmentObj.Proposal__r.name != null && srAttachmentObj.Proposal__r.name != '' 
                    && srAttachmentObj.Proposal__r.name  == srAttachmentObj.Parent_Proposal_Name__c
                    && srAttachmentObj.Envelop_Id__c != null && srAttachmentObj.Envelop_Id__c != ''
                    && srAttachmentObj.DocuSign_Status__c == EDPUtil.COMPLETED){                
                    proposalsWithCompletedESigns.add(srAttachmentObj.Proposal__c);
                }else if(srAttachmentObj.Proposal__r.name != null && srAttachmentObj.Proposal__r.name != '' 
                    && srAttachmentObj.DocuSign_Status__c != null && srAttachmentObj.DocuSign_Status__c != ''
                    && srAttachmentObj.Proposal__r.name  == srAttachmentObj.Parent_Proposal_Name__c
                    && srAttachmentObj.Envelop_Id__c != null && srAttachmentObj.Envelop_Id__c != ''
                    && srAttachmentObj.DocuSign_Status__c != EDPUtil.COMPLETED){                
                    Set<String> envelopIds = proposalToEnvelopMap.containsKey(srAttachmentObj.proposal__c) ? proposalToEnvelopMap.get(srAttachmentObj.proposal__c) : new Set<String>();
                    envelopIds.add(srAttachmentObj.Envelop_Id__c);
                    proposalToEnvelopMap.put(srAttachmentObj.proposal__c, envelopIds);
                    envelopToSRAttachmentMap.put(srAttachmentObj.Envelop_Id__c, srAttachmentObj);
                }
            }
        }

        Map<Id, Proposal__c> modifiedProposals = new Map<Id, Proposal__c>();
        List<DocuSign_Log__c> voidResponseList = new List<DocuSign_Log__c>();
        //List<SR_Attachment__c> modifiedSRAttachmentList = new List<SR_Attachment__c>();
        Set<Id> modifySignedStatus = new Set<Id> ();
        for(Id proposalId : proposalIds){
            proposalResultMap.put(proposalId, 'Please contact Sunrun to void this proposal.');
            if(proposalsWithCompletedESigns.contains(proposalId)){
                proposalResultMap.put(proposalId, 'Sunrun has counter signed one OR more of the agreements. Please contact Sunrun to void this proposal.');
            }else{
                Set<String> envelopIds = proposalToEnvelopMap.get(proposalId);
                Set<String> voidedEnvelops = new Set<String>();
                if(envelopIds != null && envelopIds.size() > 0){
                    for(String envelopIdStr : envelopIds){
                        SR_Attachment__c srAttachment = envelopToSRAttachmentMap.get(envelopIdStr);

                        eSignServiceNew.VoidResponseWithDocuSignLog VoidResponseWithDocuSignLogObj = eSignServiceNew.voidDocuSignEnvelopId(srAttachment);
                        if(VoidResponseWithDocuSignLogObj.docuSignLogObj != null){
                            voidResponseList.add(VoidResponseWithDocuSignLogObj.docuSignLogObj);
                        }
                        String result = VoidResponseWithDocuSignLogObj.response;                        
                        
                        //String result = eSignServiceNew.voidEnvelopId(srAttachment);
                        proposalResultMap.put(proposalId, result);
                        if(result == SUCCESS){
                            voidedEnvelops.add(envelopIdStr);
                            if(ProposalUtil.canUpdateProposalSignedStatus(srAttachment.proposal__r, srAttachment.Document_Type_Name__c) == true){
                                modifySignedStatus.add(srAttachment.proposal__r.Id);                
                            }
                            srAttachment.Envelop_Id__c = '';
                            srAttachment.DocuSign_Status__c = 'Voided';
                            srAttachment.DocuSign_Error_Code__c  = '';
                            srAttachment.DocuSign_Error_Message__c = '';                            
                            srAttachmentMap.put(srAttachment.Id, srAttachment);
                            
                        }else{
                            break;
                        }                       
                    }                   
                }

            }
        }   
        
        if(voidResponseList.size() > 0){
            insert voidResponseList;
        }
        if(srAttachmentMap != null && !srAttachmentMap.isEmpty()){
            update srAttachmentMap.values();
        }

        }catch(Exception exceptionObj){
            System.debug('Unable to void eSignatures: ' + exceptionObj);
        }
    }
    
    public static Set<String> staticInactiveStages = new Set<String>();
    public static Set<String> getInactiveProposalStages(){
        if(!staticInactiveStages.isEmpty()){
            staticInactiveStages.add(EDPUtil.VOIDED);
            staticInactiveStages.add(EDPUtil.REPLACED_BY);
            staticInactiveStages.add(EDPUtil.INACTIVE); 
            staticInactiveStages.add(EDPUtil.SR_OPS_APPROVED);  
        }
        return staticInactiveStages;            
    }
    
    public static Map<Id, Proposal__c> getActiveProposals(Id optyId){
        Set<Id> opportunityIds = new Set<Id>();
        opportunityIds.add(optyId);
        Map<Id, Proposal__C> activeProposals = new Map<Id, Proposal__C>();
        Map<Id, Map<Id, Proposal__C>> optyProposalMap = getActiveProposalsForOpportunities(opportunityIds);
        if(optyProposalMap != null && optyProposalMap.containsKey(optyId)){
            activeProposals = optyProposalMap.get(optyId);
        }
        return activeProposals; 
    }
    
    public static boolean hasActiveProposals(Id optyId){
        Boolean result = false;
        Map<Id, Proposal__C> activeProposals = getActiveProposals(optyId);
        if(activeProposals != null && !activeProposals.isEmpty()){
            result = true;
        }
        return result;
    }

    Public static Boolean isCustomerProposal(Proposal__c proposalObj){
        Boolean result = false;
         if(proposalObj != null && proposalObj.Proposal_Source__c == ProposalUtil.BLACK_BIRD && proposalObj.Change_Order_Information__c != null
            &&  (proposalObj.Change_Order_Information__c.contains(ProposalUtil.CUSTOMER_CHANGE_ORDER) 
                || proposalObj.Change_Order_Information__c.contains(ProposalUtil.FULL_PROPOSAL)) ){
            result = true;
         }
         return result;
    }   
    
    public static boolean canUpdateProposalSignedStatus(Proposal__c proposalObj, String documentTypeName){
        Boolean result = false;
        if(proposalObj != null && documentTypeName != null){
            if(proposalObj.Proposal_Source__c != null && proposalObj.Proposal_Source__c == ProposalUtil.BLACK_BIRD){
                if(proposalObj.Change_Order_Information__c != null){
                    if( (proposalObj.Change_Order_Information__c == ProposalUtil.FULL_PROPOSAL && documentTypeName == EDPUtil.CUSTOMER_AGREEMENT)
                        || (proposalObj.Change_Order_Information__c == ProposalUtil.EPC_CHANGE_ORDER &&  documentTypeName == EDPUtil.EPC)
                        || (proposalObj.Change_Order_Information__c.contains(ProposalUtil.CUSTOMER_CHANGE_ORDER) && documentTypeName == EDPUtil.CHANGE_ORDER_COVER_SHEET)){
                        result = true;
                    }
                    
                }
            }
        }
        return result;
    }
    
    static Set<String> proposalStageListForVoid;
    public static Set<String> getProposalStageListForVoid(){
        if(proposalStageListForVoid == null || proposalStageListForVoid.size() == 0){
            proposalStageListForVoid = new Set<String>();
            proposalStageListForVoid.add(EDPUtil.REPLACED_BY);
            proposalStageListForVoid.add(EDPUtil.VOIDED);
        }
        return proposalStageListForVoid;
    }
    
    public static void getActiveChildNodes(Set<Id> proposalIds, Map<Id, Map<Id, Proposal__c> > childNodes){
        Set<String> stageList = ProposalUtil.getProposalStageListForVoid();
        String proposalSource = ProposalUtil.BLACK_BIRD;
        getActiveChildNodes(proposalIds, childNodes, stageList, proposalSource);
    }

    public static void getProposalToolChildNodes(Set<Id> proposalIds, Map<Id, Map<Id, Proposal__c> > childNodes){
        Set<String> stageList = ProposalUtil.getProposalStageListForVoid();
        getActiveChildNodes(proposalIds, childNodes, stageList, 'PT');
    }
    
    public static void getActiveChildNodes(Set<Id> proposalIds, Map<Id, Map<Id, Proposal__c> > childNodes, Set<String> stageList, String proposalSource){
        //String proposalSource = ProposalUtil.BLACK_BIRD;
        String nodeStr = ProposalUtil.NODE;
        String seedStr = ProposalUtil.SEED;
        if(stageList == null){
            stageList = new Set<String>();
        }
        if(proposalIds == null && proposalIds.isEmpty()){
            return;
        }else if(proposalIds.size() > 0 ){
            Set<Id> childProposalIds = new Set<Id>();
            String proposalSOQLStr = ProposalUtil.getProposalSQLStr();
            proposalSOQLStr += ' where Proposal_Source__c = :proposalSource ' ;
            proposalSOQLStr += ' and Original_Proposal_ID__c in :proposalIds ';
            if(stageList != null && !stageList.isEmpty()){
                proposalSOQLStr += ' and stage__c not in :stageList ' ;
            }
            if(proposalSource == ProposalUtil.BLACK_BIRD){
              proposalSOQLStr += ' and (Proposal_Type__c != :seedStr) ' ;
            }
            
            for(Proposal__c proposalObj : Database.query(proposalSOQLStr)){                             
                Map<Id, Proposal__c> proposalMap = childNodes.containsKey(proposalObj.Original_Proposal_ID__c) ? 
                                                    childNodes.get(proposalObj.Original_Proposal_ID__c) : new Map<Id, Proposal__c>();
                proposalMap.put(proposalObj.Id, proposalObj);
                childNodes.put(proposalObj.Original_Proposal_ID__c, proposalMap);
                childProposalIds.add(proposalObj.Id);
            }
            if(childProposalIds != null && !childProposalIds.isEmpty()){    
                getActiveChildNodes(childProposalIds, childNodes, stageList, proposalSource);
            }       
        }
    }      


    public static void getActiveChildNodesForCredit(Set<Id> proposalIds, Map<Id, Map<Id, Proposal__c> > childNodes){
        Set<String> stageList = ProposalUtil.getProposalStageListForVoid();
        getActiveChildNodesForCredit(proposalIds, childNodes, stageList);
    }
    
    public static void getActiveChildNodesForCredit(Set<Id> proposalIds, Map<Id, Map<Id, Proposal__c> > childNodes, Set<String> stageList){
        String proposalSource = ProposalUtil.BLACK_BIRD;
        String nodeStr = ProposalUtil.NODE;
        String seedStr = ProposalUtil.SEED;
        if(stageList == null){
            stageList = new Set<String>();
        }
        if(proposalIds == null && proposalIds.isEmpty()){
            return;
        }else if(proposalIds.size() > 0 ){
            Set<Id> childProposalIds = new Set<Id>();
            String proposalSOQLStr = ProposalUtil.getProposalSQLStr();
            proposalSOQLStr += ' where Proposal_Source__c = :proposalSource ' ;
            proposalSOQLStr += ' and Original_Proposal_ID__c in :proposalIds ';
            if(stageList != null && !stageList.isEmpty()){
                proposalSOQLStr += ' and stage__c not in :stageList ' ;
            }
            proposalSOQLStr += ' and (Proposal_Type__c != :seedStr) ' ;
            for(Proposal__c proposalObj : Database.query(proposalSOQLStr)){ 
                if(proposalObj.Proposal_Type__c != null && proposalObj.Proposal_Type__c == ProposalUtil.NODE 
                    && proposalObj.Change_Order_Information__c != null && proposalObj.Change_Order_Information__c.contains('FULL_PROPOSAL')){
                    continue;       
                }
                                            
                Map<Id, Proposal__c> proposalMap = childNodes.containsKey(proposalObj.Original_Proposal_ID__c) ? 
                                                    childNodes.get(proposalObj.Original_Proposal_ID__c) : new Map<Id, Proposal__c>();
                proposalMap.put(proposalObj.Id, proposalObj);
                childNodes.put(proposalObj.Original_Proposal_ID__c, proposalMap);
                childProposalIds.add(proposalObj.Id);
            }
            if(childProposalIds != null && !childProposalIds.isEmpty()){    
                getActiveChildNodesForCredit(childProposalIds, childNodes, stageList);
            }       
        }
    }      



    
    static Map<Id, Map<Id, Proposal__c> > contactProposalMap;
    public static Map<Id, Map<Id, Proposal__C>> getActiveProposalsForContacts(Set<Id> contactIds){
        String proposalSource = ProposalUtil.BLACK_BIRD;
        Set<String> stageList = ProposalUtil.getProposalStageListForVoid();
        Set<Id> optyIds = new Set<Id>();
        if(contactProposalMap == null){
            contactProposalMap = new Map<Id, Map<Id, Proposal__c> >();
            if(contactIds != null && contactIds.size() > 0){
                for(Proposal__C proposalObj : ([Select Id, name, Primary_Customer__c, opportunity__c, Proposal_Source__c, stage__c from Proposal__C where 
                                                                        Proposal_Source__c = :proposalSource and Primary_Customer__c in :contactIds 
                                                                        and stage__c not in :stageList ])){
                                                                            
                    Map<Id,Proposal__C> proposalsMap = contactProposalMap.containsKey(proposalObj.Primary_Customer__c) ? 
                                contactProposalMap.get(proposalObj.Primary_Customer__c) : new Map<Id, Proposal__c>();
                    proposalsMap.put(proposalObj.Id, proposalObj);
                    contactProposalMap.put(proposalObj.Primary_Customer__c, proposalsMap);
                }               
            }
        }
        return contactProposalMap;
    }
    
    static Map<Id, Map<Id, Proposal__c> > optyProposalMapForVoid;
    public static Map<Id, Map<Id, Proposal__C>> getActiveProposalsForOpportunities(Set<Id> opportunityIds){
        String proposalSource = ProposalUtil.BLACK_BIRD;
        Set<String> stageList = ProposalUtil.getProposalStageListForVoid();
        System.debug('stageList: ' + stageList);
        if(optyProposalMapForVoid == null){
            optyProposalMapForVoid = new Map<Id, Map<Id, Proposal__c> >();
            if(opportunityIds != null && opportunityIds.size() > 0){
                for(Proposal__C proposalObj : ([Select Id, name, Opportunity__c, stage__c, Proposal_Source__c from Proposal__C where 
                                                                        Proposal_Source__c = :proposalSource and Opportunity__c in :opportunityIds 
                                                                        and stage__c not in :stageList])){
                                                                            
                    Map<Id,Proposal__C> proposalsMap = optyProposalMapForVoid.containsKey(proposalObj.Opportunity__c) ? 
                                optyProposalMapForVoid.get(proposalObj.Opportunity__c) : new Map<Id, Proposal__c>();
                    proposalsMap.put(proposalObj.Id, proposalObj);
                    optyProposalMapForVoid.put(proposalObj.Opportunity__c, proposalsMap);
                }
            }
        }
        return optyProposalMapForVoid;
    }

    static Map<Id, Map<Id, Proposal__c> > accountProposalMapForVoid;
    public static Map<Id, Map<Id, Proposal__C>> getActiveProposalsForAccounts(Set<Id> accountIds){
        String proposalSource = ProposalUtil.BLACK_BIRD;
        Set<String> stageList = ProposalUtil.getProposalStageListForVoid();
        if(accountProposalMapForVoid == null){
            accountProposalMapForVoid = new Map<Id, Map<Id, Proposal__c> >();
            if(accountIds != null && accountIds.size() > 0){
                Map<Id, Set<Id>> accountOptyMap = new Map<Id, Set<Id>>();
                Set<Id> opportunityIds = new Set<Id>();
                for(Proposal__C proposalObj : ([Select Id, name, Opportunity__c, stage__c, Proposal_Source__c, Opportunity__r.accountId from Proposal__C where 
                                                    Proposal_Source__c = :proposalSource and Opportunity__r.accountId  in :accountIds and stage__c not in :stageList])){
                                                                            
                    Map<Id,Proposal__C> proposalsMap = accountProposalMapForVoid.containsKey(proposalObj.Opportunity__r.accountId) ? 
                                accountProposalMapForVoid.get(proposalObj.Opportunity__r.accountId) : new Map<Id, Proposal__c>();
                    proposalsMap.put(proposalObj.Id, proposalObj);
                    accountProposalMapForVoid.put(proposalObj.Opportunity__r.accountId, proposalsMap);
                }
            }
        }
        return accountProposalMapForVoid;
    }
    
    public static void setParentProposalInformation(Proposal__c proposalObj, Proposal__c parentProposalObj){
        System.debug('>> Inside method');
        if(proposalObj != null ){
            proposalObj.Proposal_Type__c = SEED;
            if(parentProposalObj != null){
                proposalObj.change_order__c = true;
                proposalObj.original_proposal_Id__c = parentProposalObj.Id;
                if(proposalObj.Proposal_Source__c == ProposalUtil.BLACK_BIRD){
                    if(parentProposalObj.Ultimate_Parent_Proposal__c == null){
                        if(parentProposalObj.signed__c != null && parentProposalObj.signed__c == true){
                            proposalObj.Proposal_Type__c = NODE;
                        }
                    }else{
                        proposalObj.Proposal_Type__c = NODE;
                    }
                }
        
                if(((proposalObj.name.indexOf('H') == 0 ) || (proposalObj.name.indexOf('C') == 0 ) 
                    || 
                    ((proposalObj.Proposal_Source__c == ProposalUtil.BLACK_BIRD) 
                        && proposalObj.Proposal_Type__c != null && proposalObj.Proposal_Type__c == ProposalUtil.NODE 
                        && proposalObj.Change_Order_Information__c != null 
                        && !proposalObj.Change_Order_Information__c.contains('FULL_PROPOSAL'))) 
                    && parentProposalObj.Sunrun_Credit_Status__c == EDPUtil.CREDIT_APPROVED){
                        System.debug('>> Call copy Credit Info');
                    copyCreditInformation(parentProposalObj, proposalObj);
                }
            }
        }
    }

    public static void updateChildproposalsForCreditInfo(Set<Id> parentProposalIds){
        String blackBird = ProposalUtil.BLACK_BIRD;
        if(parentProposalIds != null && parentProposalIds.size() > 0){
            Map<Id, Proposal__c> creditProposalMap = new Map<Id, Proposal__c>([Select Id, name, original_proposal_Id__c, Primary_Customer__c,Current_Customer_Credit_Report__c, Credit_Status__c,SR_Credit_Status__c,
                                                                                Credit_team_notes__c, Conditional_Approval_Amount__c, ACH_Required__c, Total_Solar_Prepay_Required__c,
                                                                                Partner_Financed__c from Proposal__c where Id in :parentProposalIds]);
            List<Proposal__C> modifiedProposals = new List<Proposal__C>();
            if(creditProposalMap != null && creditProposalMap.size() > 0){
                System.debug('creditProposalMap: ' + creditProposalMap.keySet());
                for(Proposal__c childProposalObj : [Select Id, name, original_proposal_Id__c, Primary_Customer__c,Current_Customer_Credit_Report__c, Credit_Status__c,SR_Credit_Status__c,
                                                Credit_team_notes__c, Conditional_Approval_Amount__c, ACH_Required__c, Total_Solar_Prepay_Required__c, Name_on_Credit_Verified__c,
                                                Partner_Financed__c from Proposal__c where original_proposal_Id__c in :creditProposalMap.keySet()
                                                and (name like 'C%' OR Name like 'H%' OR Proposal_Source__c =:blackBird)]){
                    
                    Proposal__c parentproposalObj = creditProposalMap.get(childProposalObj.original_proposal_Id__c);
                    System.debug('parentproposalObj.Current_Customer_Credit_Report__c: ' + parentproposalObj.Current_Customer_Credit_Report__c);
                    if(parentproposalObj.Current_Customer_Credit_Report__c != null
                        &&  (childProposalObj.Current_Customer_Credit_Report__c == null 
                                || childProposalObj.Current_Customer_Credit_Report__c == parentproposalObj.Current_Customer_Credit_Report__c )){
                        childProposalObj.Primary_Customer__c = parentproposalObj.Primary_Customer__c;
                        childProposalObj.Current_Customer_Credit_Report__c = parentproposalObj.Current_Customer_Credit_Report__c;
                        childProposalObj.Credit_Status__c = parentproposalObj.Credit_Status__c;
                        childProposalObj.Credit_team_notes__c = parentproposalObj.Credit_team_notes__c;
                        childProposalObj.Conditional_Approval_Amount__c = parentproposalObj.Conditional_Approval_Amount__c;
                        childProposalObj.ACH_Required__c = parentproposalObj.ACH_Required__c;
                        childProposalObj.Total_Solar_Prepay_Required__c = parentproposalObj.Total_Solar_Prepay_Required__c;
                        childProposalObj.Partner_Financed__c = parentproposalObj.Partner_Financed__c;               
                        modifiedProposals.add(childProposalObj);
                    }
                }
                
                if(modifiedProposals.size() > 0){
                    update modifiedProposals;
                }
            }
        }
    }

    public static void copyCreditInformation(Proposal__c sourceProposalObj, Proposal__c targetProposalObj){
        system.debug('>>> Copy Credit Information ' );
        targetProposalObj.Primary_Customer__c = sourceProposalObj.Primary_Customer__c;
        targetProposalObj.Current_Customer_Credit_Report__c = sourceProposalObj.Current_Customer_Credit_Report__c;
        targetProposalObj.Credit_Status__c = sourceProposalObj.Credit_Status__c;
        targetProposalObj.Credit_team_notes__c = sourceProposalObj.Credit_team_notes__c;
        targetProposalObj.Conditional_Approval_Amount__c = sourceProposalObj.Conditional_Approval_Amount__c;
        targetProposalObj.ACH_Required__c = sourceProposalObj.ACH_Required__c;
        targetProposalObj.Total_Solar_Prepay_Required__c = sourceProposalObj.Total_Solar_Prepay_Required__c;
        targetProposalObj.Partner_Financed__c = sourceProposalObj.Partner_Financed__c;  
        targetProposalObj.Sunrun_Credit_Status__c = sourceProposalObj.Sunrun_Credit_Status__c;
        targetProposalObj.Conditional_Approval__c = sourceProposalObj.Conditional_Approval__c;  
        targetProposalObj.Name_on_Credit_Verified__c = sourceProposalObj.Name_on_Credit_Verified__c;  
        targetProposalObj.Customer_SignOff_Date__c = sourceProposalObj.Customer_SignOff_Date__c;
        targetProposalObj.Date_Time_Ops_Received_Proposal_back__c = sourceProposalObj.Date_Time_Ops_Received_Proposal_back__c;  
        targetProposalObj.cvv__c = sourceProposalObj.Cvv__c; 
        targetProposalObj.Shopping_Pass__c = sourceProposalObj.Shopping_Pass__c; 
    }
    
    public static Proposal__c getParentProposalForCreditInfo(String proposalId){
        Proposal__c resultProposal = null;
        String parentProposalId = '';
        if(proposalId != null && proposalId != ''){
            String proposalSOQLStr = ProposalUtil.getProposalSQLStr();
            proposalSOQLStr += ' where Id =:proposalId ' ;
            for(Proposal__c proposalObj : Database.query(proposalSOQLStr)){
                String tempParentId = proposalObj.Original_Proposal_ID__c;
                if(tempParentId != null && tempParentId != '' && proposalObj.Change_Order_Information__c != null && 
                    !proposalObj.Change_Order_Information__c.contains('FULL_PROPOSAL')){
                    return getParentProposalForCreditInfo(tempParentId);
                }else{
                    return proposalObj;
                }
            }
        }
        return resultProposal;
    }

    public static String copyCreditInformation(Proposal__c sourceProposalObj){
    
        System.debug('sourceProposalObj: ' + sourceProposalObj);
        String result = SUCCESS;
        try{
            Proposal__c parentProposal;
            List<Proposal__c> modifiedProposals = new List<Proposal__c>();
            if(sourceProposalObj != null && sourceProposalObj.Id != null){
                parentProposal = getParentProposalForCreditInfo(sourceProposalObj.Id);
                Set<Id> parentProposalIds = new Set<Id>();
                parentProposalIds.add(parentProposal.Id);
                Map<Id, Map<Id, Proposal__c> > childNodes = new Map<Id, Map<Id, Proposal__c> >();
                getActiveChildNodesForCredit(parentProposalIds, childNodes, null);
                if(parentProposal != null && parentProposal.Id != sourceProposalObj.Id ){
                    copyCreditInformation(sourceProposalObj, parentProposal);
                    modifiedProposals.add(parentProposal);
                }

                for(Map<Id, Proposal__c> proposalMap : childNodes.values()){
                    for(Proposal__c childProposal : proposalMap.values()){
                        if(childProposal != null && childProposal.Id != sourceProposalObj.Id ){
                            copyCreditInformation(sourceProposalObj, childProposal);
                            modifiedProposals.add(childProposal);
                        }                   
                    }
                }
                
                if(modifiedProposals != null && !modifiedProposals.isEmpty()){
                    update modifiedProposals;
                }
            }
        }catch(Exception e){
            System.debug('System Error: ' + e.getMessage());
            return CustomErrorMessages.SFDC_SYSTEM_ERROR;
        }
        return result;
    }

    public static void createPartnerRoles(Map<Id, Id> opportunityToSalesPartner, Map<Id, Id> opportunityToInstallPartner){
        Set<Id> opportunityIds = new Set<Id>();
        Map<Id, List<Partner_Role__c>> optyInstallRoles = new Map<Id, List<Partner_Role__c>>();
        Map<Id, List<Partner_Role__c>> optySalesRoles = new Map<Id, List<Partner_Role__c>>();
        
        if(opportunityToSalesPartner != null && !opportunityToSalesPartner.isEmpty()){
            opportunityIds.addall(opportunityToSalesPartner.keySet());
        }

        if(opportunityToInstallPartner != null && !opportunityToInstallPartner.isEmpty()){
            opportunityIds.addall(opportunityToInstallPartner.keySet());
        }
        
        System.debug('opportunityToSalesPartner: ' + opportunityToSalesPartner);
        System.debug('opportunityToInstallPartner: ' + opportunityToInstallPartner);
        if(opportunityIds != null && !opportunityIds.isEmpty()){
            for(Partner_Role__c roleObj : [Select Id, Opportunity__c, Role__c,  Partner_Name__c from Partner_Role__c where Opportunity__c in :opportunityIds]){
                if(roleObj.Role__c != null && roleObj.Role__c == 'Install'){
                    List<Partner_Role__c> partners = optyInstallRoles.containsKey(roleObj.Opportunity__c) ? optyInstallRoles.get(roleObj.Opportunity__c) : new List<Partner_Role__c>();
                    partners.add(roleObj);
                    optyInstallRoles.put(roleObj.Opportunity__c, partners);
                }
                if(roleObj.Role__c != null && roleObj.Role__c == 'Sales'){
                    List<Partner_Role__c> partners = optySalesRoles.containsKey(roleObj.Opportunity__c) ? optySalesRoles.get(roleObj.Opportunity__c) : new List<Partner_Role__c>();
                    partners.add(roleObj);
                    optySalesRoles.put(roleObj.Opportunity__c, partners);                   
                }
            }
        }
        
        List<Partner_Role__c> deleteRoles = new List<Partner_Role__c>();
        
        List<Partner_Role__c> newPartnerRoles = new List<Partner_Role__c>();
        for(Id opportunityId : opportunityToSalesPartner.keySet()){
            Id salesPartnerId = opportunityToSalesPartner.get(opportunityId);
            Partner_Role__c newRoleObj = new Partner_Role__c();
            newRoleObj.Opportunity__c = opportunityId;
            newRoleObj.Role__c = 'Sales';
            newRoleObj.Partner_Name__c = salesPartnerId;
            newPartnerRoles.add(newRoleObj);
            if(optySalesRoles != null && optySalesRoles.containsKey(opportunityId)){
                deleteRoles.addall(optySalesRoles.get(opportunityId));
            }
        } 
        System.debug('newPartnerRoles:  ' + newPartnerRoles);
        
        for(Id opportunityId : opportunityToInstallPartner.keySet()){
            Id installPartnerId = opportunityToInstallPartner.get(opportunityId);
            Partner_Role__c newRoleObj = new Partner_Role__c();
            newRoleObj.Opportunity__c = opportunityId;
            newRoleObj.Role__c = 'Install';
            newRoleObj.Partner_Name__c = installPartnerId;
            newPartnerRoles.add(newRoleObj);
           
           if(optyInstallRoles != null && optyInstallRoles.containsKey(opportunityId)){
                deleteRoles.addall(optyInstallRoles.get(opportunityId));
            }
        } 
        
        if(newPartnerRoles != null && !newPartnerRoles.isEmpty()){
            insert newPartnerRoles;
        }
        if(deleteRoles != null && !deleteRoles.isEmpty()){
            delete deleteRoles;
        }
    }
    
    Public Static Void PopulateProposalPerformanceGuarantee(List<Proposal__c> ProposalList){
        Map<string,string> GuaranteedProdMap=new Map<string,string>();
        Map<string,string> YearlyRefundMap=new Map<string,string>();
        List<Proposal_Performance_Guarantee__c> ProPGuarantee=new List<Proposal_Performance_Guarantee__c>();
        for(Proposal__c proposal:ProposalList){
            if(proposal.Guaranteed_production_to_date__c!=null&&proposal.Yearly_refund_rate__c!=null){  
                 String GP=proposal.Guaranteed_production_to_date__c;
                 GP=proposal.Guaranteed_production_to_date__c.replace('[','');
                 GP=GP.replace(']','');          
                 List<String> GPList = GP.split(',');
                 String YR=proposal.Yearly_refund_rate__c;
                 YR=proposal.Yearly_refund_rate__c.replace('[','');
                 YR=YR.replace(']','');             
                 List<String> YRList = YR.split(',');                
                 for(Integer i=0;i<GPList.size();i++){
                    GuaranteedProdMap.put(i+''+proposal.id,GPList[i].trim());
                 }
                 for(Integer i=0;i<YRList.size();i++){
                    YearlyRefundMap.put(i+''+proposal.id,YRList[i].trim());
                 }
                 for(Integer i=0;i<GPList.size();i++){
                    if(GuaranteedProdMap.containsKey(i+''+proposal.id)&&YearlyRefundMap.containsKey(i+''+proposal.id)){
                        try{
                        Proposal_Performance_Guarantee__c ppd=new Proposal_Performance_Guarantee__c(Proposal__c=proposal.id,
                        Guranteed_Output__c=decimal.valueOf(GuaranteedProdMap.get(i+''+proposal.id)),Refund_Rate__c=decimal.valueOf(YearlyRefundMap.get(i+''+proposal.id)),
                        year__c=string.valueOf(i+1));
                        ProPGuarantee.add(ppd);
                        }
                        catch(exception e){
                            system.debug('Print Ecxeption:'+e.getMessage());
                        }
                    }
                 }              
            }
        }
        if(!ProPGuarantee.isempty()){
            insert ProPGuarantee;
        }
    }
    Public Static Void PopulateLegacyPartnersOppty(List<Proposal__c> ProposalList){
        Map<id,Account> OpptySalesPartnerMap=new Map<id,Account>();
        Map<id,Account> OpptyInstallPartnerMap=new Map<id,Account>();
        Map<Id, String> optySource = new Map<Id, String>();
        for(Proposal__c proposal:ProposalList){
            if(Proposal.Sales_Partner__c!=null&&Proposal.Opportunity__c!=null){
                OpptySalesPartnerMap.put(Proposal.Opportunity__c,new Account(id=Proposal.Sales_Partner__c,name=Proposal.Sales_Partner_Name__c));
            }
            if(Proposal.Install_Partner__c!=null&&Proposal.Opportunity__c!=null){
                OpptyInstallPartnerMap.put(Proposal.Opportunity__c,new Account(id=Proposal.Install_Partner__c,name=Proposal.Install_Partner_Name__c));
            }
            optySource.put(proposal.Opportunity__c, proposal.Proposal_Source__c);
        }
        if(!OpptySalesPartnerMap.isEmpty() || !OpptyInstallPartnerMap.isEmpty()){
            Map<Id, Opportunity> UpdateMap = new Map<Id, Opportunity>();
            for(Opportunity oppty:[select id,Partners__c,Partner_who_we_have_passed_to__c,  Install_Partner__c, Sales_Partner__c,   Market_Assignment_Sales__c,     Market_Assignment_Install__c,
                                (select id,role__c from Partner_roles__r) from opportunity where id in:OpptySalesPartnerMap.keyset() OR id in:OpptyInstallPartnerMap.keyset() ]){
                
                String source = optySource.get(oppty.id);
                Boolean modified = false;
                if(OpptySalesPartnerMap.containsKey(oppty.id)){
                    if(oppty.Partners__c==null||oppty.Partner_who_we_have_passed_to__c==null){
                        if(OpptySalesPartnerMap.containsKey(oppty.id)){
                            //Opportunity opp=new Opportunity(id=oppty.id);
                            if(oppty.Partners__c==null){
                                oppty.Partners__c=OpptySalesPartnerMap.get(oppty.id).name;
                            }
                            if(oppty.Partner_who_we_have_passed_to__c==null){
                                oppty.Partner_who_we_have_passed_to__c=OpptySalesPartnerMap.get(oppty.id).id;
                            }
                            modified = true;
                        }
                    }
                    if(source != BLACK_BIRD){
                        oppty.Sales_Partner__c = OpptySalesPartnerMap.get(oppty.id).id;
                        oppty.Market_Assignment_Sales__c = null;
                        modified = true;
                        //UpdateMap.put(oppty.Id, oppty);
                    }
                }
                
                if(OpptyInstallPartnerMap.containsKey(oppty.id)){
                    if(source != BLACK_BIRD){
                        oppty.Install_Partner__c = OpptyInstallPartnerMap.get(oppty.id).id;
                        oppty.Market_Assignment_Install__c = null;
                        modified = true;
                    }                   
                }
                
                if(modified == true){
                    UpdateMap.put(oppty.Id, oppty);
                }
                
                //if(oppty.Partner_roles__r.size()<=1){
                //    if(OpptySalesPartnerMap.containsKey(oppty.id)&&(oppty.Partner_roles__r.isempty()||oppty.Partner_roles__r[0].role__c!='Sales')){
                //    Partner_Role__c pr=new Partner_role__c(Opportunity__c=oppty.id,role__c='Sales',Partner_Name__c=OpptySalesPartnerMap.get(oppty.id).id);
               //     prList.add(pr);
                 //   }
               //     if(OpptyInstallPartnerMap.containsKey(oppty.id)&&(oppty.Partner_roles__r.isempty()||oppty.Partner_roles__r[0].role__c!='Install')){
               //     Partner_Role__c pr=new Partner_role__c(Opportunity__c=oppty.id,role__c='Install',Partner_Name__c=OpptyInstallPartnerMap.get(oppty.id));
               //     prList.add(pr);
              //      }
              //  }
            }
            if(!UpdateMap.isempty()){
                update UpdateMap.values();
            }       
            //if(!prList.isempty()){
            //    insert prList;
            ///}
        }
    }
    
    public static Map<String, Map<String, Customer_Credit__c>>  customerCreditMapByDealId;
    public static Map<String, Map<String, Customer_Credit__c>> getCustomerCreditsForDealIds(Set<String> dealIds){
        if(dealIds != null && !dealIds.isempty()){
            Boolean cachedReport = true;
            if(customerCreditMapByDealId == null){
                 customerCreditMapByDealId = new Map<String, Map<String, Customer_Credit__c>>();
            }
            for(String dealIdStr : dealIds){
                if(customerCreditMapByDealId == null || !customerCreditMapByDealId.containsKey(dealIdStr)){
                    cachedReport = false;
                    break;
                }
            }
            
            if(cachedReport == false){
                Integer expirationDays = Integer.valueOf(CustomerCreditUtil.getCreditExpirationDays()) * -1;
                for(Customer_Credit__c cc : [Select Id, Date_Pulled__c, Date_Submitted__c, deal_Id__c, Customer_Email__c from Customer_Credit__c
                                                 where  (type__c = null OR type__c = 'LeaseDimension') and deal_Id__c in :dealIds 
                                                 order by Date_Pulled__c desc , Date_Submitted__c desc]){
                    if(cc.Date_Pulled__c == null || (cc.Date_Pulled__c != null && system.today().addDays(expirationDays) < cc.Date_Pulled__c)) // still has active credit report
                    {
                        Map<String, Customer_Credit__c> creditMapByEmail = customerCreditMapByDealId.containsKey(cc.deal_Id__c) ? customerCreditMapByDealId.get(cc.deal_Id__c) : new Map<String, Customer_Credit__c>();
                        if(!creditMapByEmail.containsKey(cc.Customer_Email__c)){
                            creditMapByEmail.put(cc.Customer_Email__c, cc);
                        }
                        customerCreditMapByDealId.put(cc.deal_Id__c, creditMapByEmail);
                    }
                }               
            }
        }
        System.debug('customerCreditMapByDealId: ' + customerCreditMapByDealId);
        return customerCreditMapByDealId;
    }
    
    
    //@future
    public static void updateCreditInformation(Map<String, Id> dealIdToCustomerCreditMap, Set<Id> customerCreditRecords){
        Set<String> dealIds = new Set<String>();
        Map<Id, opportunity> modifiedOptyMap = new Map<Id, opportunity>();
        Map<Id, Proposal__c> modifiedProposalMap = new Map<Id, Proposal__c>();
        Map<Id, Customer_Credit__c> customerCreditMap = new Map<Id, Customer_Credit__c>([Select Id, deal_Id__c, Sunrun_Credit_Status__c, Customer_Email__c from Customer_Credit__c where Id in :dealIdToCustomerCreditMap.values()]);
        for(Opportunity optyObj : [Select Id, Name, deal_Id__c, (Select Id, name, Current_Customer_Credit_Report__c, Current_Customer_Credit_Report__r.type__c, Primary_Customer__r.Id, Primary_Customer__r.email from Proposals__R) from Opportunity where deal_Id__c in :dealIdToCustomerCreditMap.keySet()]){
            Id customerCreditId = dealIdToCustomerCreditMap.get(optyObj.deal_Id__c);
            Customer_Credit__c ccObj = customerCreditMap.get(customerCreditId);
            if(optyObj.Proposals__R != null){
                for(Proposal__C proposalObj : optyObj.Proposals__R){
                    if(!ProposalUtil.cusomerCreditProposalIds.contains(proposalObj.Id) && ccObj.Customer_Email__c != null && ccObj.Customer_Email__c != '' && 
                        proposalObj.Primary_Customer__r.Id != null && proposalObj.Primary_Customer__r.email == ccObj.Customer_Email__c){
                        
                        if(proposalObj.Current_Customer_Credit_Report__c == null || 
                            (proposalObj.Current_Customer_Credit_Report__c != null && proposalObj.Current_Customer_Credit_Report__r.type__c != 'Sunrun')){
                            proposalObj.Current_Customer_Credit_Report__c = ccObj.Id;
                            modifiedProposalMap.put(proposalObj.Id, proposalObj);
                        }
                    }
                }
            }
            //modifiedOptyMap.put(optyObj.Id, optyObj);
        }

        if(modifiedOptyMap != null && !modifiedOptyMap.isEmpty()){
            update modifiedOptyMap.values();
        }  
        
        
        if(modifiedProposalMap != null && !modifiedProposalMap.isEmpty()){
            update modifiedProposalMap.values();
        }
    }
    
    public static Set<Id> createCustomerCreditRecords(Map<Id, Proposal__c> proposalMap){
        Map<Id, Proposal__c> newProposalMap = new Map<Id, Proposal__c>([Select Id, Current_Customer_Credit_Report__c, Name_on_Credit_Verified__c, Current_Customer_Credit_Report__r.type__c, Agreement_Type__c, Install_Partner_Name__c, Opportunity__r.deal_Id__c, Opportunity__r.AccountId, Opportunity__r.Id, Mode_Name__c, Primary_Customer__r.Id, Primary_Customer__r.LastName, Primary_Customer__r.email,Primary_Customer__r.firstname,Primary_Customer__r.Phone, Primary_Customer__r.MailingCountry,Primary_Customer__r.MailingPostalCode,Primary_Customer__r.MailingState, Primary_Customer__r.Birthdate,Primary_Customer__r.MailingStreet, Primary_Customer__r.MailingCity from Proposal__c where Id in :proposalMap.keySet()]);
        Set<Id> ccIds = LeaseDimensions.createCreditRecord(newProposalMap, proposalMap);
        return ccIds;
    }
  
    public static void createCustomerCreditContactRole(Map<Id, Id> optyContactMap){
        
        try{
            String contactRoleStr = EDPUtil.OCR_ROLE_CREDIT;
            Boolean contactExistis = false;     
            OpportunityContactRole existingOptyRole;
            List<OpportunityContactRole> roleList = new List<OpportunityContactRole>();
            
            for(Contact existingContact : [Select Id, accountId, name , firstname, lastName, email,
                                                (Select Id, role, opportunityId, contactId, contact.name, contact.email 
                                                    from OpportunityContactRoles where opportunityId in :optyContactMap.keySet()) from Contact 
                                                where Id in :optyContactMap.values()]){
                Boolean bOCRExists = false; 
                Id proposalContactId;
                Id OpptyId;
                Id contactId;
                if(existingContact.OpportunityContactRoles != null && existingContact.OpportunityContactRoles.size() > 0){
                    existingOptyRole = null;
                    for(OpportunityContactRole optyContactRoleObj : existingContact.OpportunityContactRoles){
                        OpptyId = optyContactRoleObj.opportunityId;
                        contactId = optyContactRoleObj.contactId;
                        if(optyContactRoleObj.role == EDPUtil.HOME_OWNER){
                            proposalContactId = optyContactRoleObj.contactId;
                            System.debug('optyContactRoleObj: ' + optyContactRoleObj);
                        }
                        if(optyContactRoleObj.role == contactRoleStr || optyContactRoleObj.role == EDPUtil.OTHER){
                            existingOptyRole = optyContactRoleObj;
                            proposalContactId = optyContactRoleObj.contactId;
                            bOCRExists = true;
                            if(optyContactRoleObj.role == EDPUtil.OTHER){
                                optyContactRoleObj.role = contactRoleStr;
                                roleList.add(optyContactRoleObj);
                            }
                            break;
                        }
                    }           
                }
                
                if(!bOCRExists)
                {
                    OpportunityContactRole ocrNew = new OpportunityContactRole();
                    ocrNew.OpportunityId = OpptyId;
                    ocrNew.ContactId = contactId;
                    ocrNew.Role = EDPUtil.OCR_ROLE_CREDIT;
                    roleList.add(ocrNew);
                }
            }
            if(roleList != null && !roleList.isEmpty()){
                upsert roleList;
            }
            
        }catch(Exception e){
           System.Debug('Error Message: ' + e.getMessage()); 
        }       
        
    }   
    
   public static void updateProposalAndCustomerCreditForCreditAutomation(Opportunity tempOpty, Proposal__c proposalObj, 
                                                                          Customer_Credit__c ccObj, User defaultOpsUser, 
                                                                          Map<Id, Customer_Credit__c> modifiedCustomerCredits,
                                                                          Map<Id, Id> optyContactMap){
                                                                              
     if(ccObj.Date_Pulled__c != null && Date.Today() <= ccObj.Date_Pulled__c.addDays(CustomerCreditUtil.getCreditExpirationDays())) {
       String agreementType = (proposalObj.Agreement_Type__c == null) ? '' : proposalObj.Agreement_Type__c;
       if(tempOpty.SalesOrganizationName__c!= Label.PosigenID && ((ccObj.Sunrun_Credit_Status__c == CustomerCreditUtil.PASS) 
          || (ccObj.Sunrun_Credit_Status__c == CustomerCreditUtil.CUSTOMER_OWNED) 
          || (ccObj.Sunrun_Credit_Status__c == CustomerCreditUtil.PARTNER_GUARANTEE) 
          || (ccObj.Sunrun_Credit_Status__c == CustomerCreditUtil.CPASS && !agreementType.contains('Prepaid')) )){
              
              proposalObj.Sunrun_Credit_Status__c = EDPUtil.CREDIT_APPROVED;
              proposalObj.Completed_Approval_Process__c = true;
              proposalObj.Stage__c = EDPUtil.CREDIT_APPROVED;
              proposalObj.Assigne__c = defaultOpsUser.Id;    
              if(ccObj.Approved_By__c == NULL || ccObj.Approved_By__c == ''){
                  ccObj.Approved_By__c = 'Automatic approval';
              }
              if(ccObj.Date_Approved__c == NULL){
                  ccObj.Date_Approved__c = DateTime.now();
              }
              if(ccObj.SRH_Customer_Number__c == NULL || ccObj.SRH_Customer_Number__c == ''){
                  ccObj.SRH_Customer_Number__c = proposalObj.name;
              }               
              if(ccObj.Sunrun_Credit_Status__c == CustomerCreditUtil.PASS 
                 || (ccObj.Sunrun_Credit_Status__c == CustomerCreditUtil.CUSTOMER_OWNED) 
                 || (ccObj.Sunrun_Credit_Status__c == CustomerCreditUtil.PARTNER_GUARANTEE) ){
                     if(ccObj.Approved__c == null || ccObj.Approved__c == ''){
                         ccObj.Approved__c = 'Passed Credit Check';
                     }
                     proposalObj.Credit_Status__c = 'Passed credit check'; 
                 }else if(ccObj.Sunrun_Credit_Status__c == CustomerCreditUtil.CPASS){
                     if(ccObj.Approved__c == null || ccObj.Approved__c == ''){
                         ccObj.Approved__c = 'Conditional Pass & signed up for ACH';
                     }
                     proposalObj.Credit_Status__c = 'Conditional Pass & Signed Up for ACH'; 
                     proposalObj.ACH_Required__c = true;
                 }
              
              if(proposalObj.Agreement_Type__c == ProposalUtil.CUST_OWNED_FULL_UPFRONT 
                 || proposalObj.Agreement_Type__c == ProposalUtil.CUST_OWNED_BANK_FINANCE 
                ){
                    proposalObj.Credit_Status__c = 'Cash Contract'; 
                }else if(proposalObj.Partner_Financed__c == true || proposalObj.Total_Solar_Prepay_Required__c == true){
                    proposalObj.Credit_Status__c = 'Conditional Approval from Partner'; 
                } 
           
            modifiedCustomerCredits.put(ccObj.Id, ccObj);
            ProposalUtil.copyCreditInfoProposalIds.add(proposalObj.Id);
            optyContactMap.put(proposalObj.Opportunity__c, proposalObj.Primary_Customer__c);
      
         
              
            }
         }
                                                                              
   }                                                                        
                                           
  
  public static void processAsBuiltProposals(Map<Id, Proposal__C> asBuiltProposalMap, Set<Id>  asBuiltOriginalProposalIds){
    Set<Id> originalProposalId = new Set<Id>();
    Map<Id, Proposal__c> originalProposalMap = getProposalsMap(asBuiltOriginalProposalIds);
    for(Proposal__c proposalObj : asBuiltProposalMap.values()){
      if(proposalObj.Original_Proposal_ID__c != null){
        Proposal__c parentProposalObj = originalProposalMap.get(proposalObj.Original_Proposal_ID__c);
        if(parentProposalObj != null){
          copyCreditInformation(parentProposalObj, proposalObj);
          proposalObj.Customer_SignOff_Date__c = parentProposalObj.Customer_SignOff_Date__c;
          proposalObj.SR_Signoff__c = datetime.now();
          proposalObj.EDP_Phase__c = 'EDP Phase-1';
          proposalObj.Signed__c = true;
        }
      }
    }
  }
  //adding for Posigen credit approval process
  public static void PosigenCreditProcess(List<Proposal__c> proposalList){
        Set<Id> creditIds= new Set<Id>();
        set<id> opptyId= new Set<Id>();
        List<Customer_Credit__c> listCC = new List<Customer_Credit__c>();
         List<Proposal__c> listproposal = new List<Proposal__c>();
        for(Proposal__c proposalObj:proposalList){
            if(proposalObj.Stage__c== edputil.SR_OPS_REVIEWED && proposalObj.Current_Customer_Credit_Report__c!=null){
               creditIds.add(proposalObj.Current_Customer_Credit_Report__c);
                opptyId.add(proposalObj.Opportunity__c);
            }
        }
     
        List<User> userList = EDPUtil.getSRUserDetails();
            User defaultOpsUser = null;
        
        for(User userObj : userList){
            if(defaultOpsUser == null && userObj.name == EDPUtil.USER_NAME_TEST){
                defaultOpsUser = userObj;
            }
                      
            if(userObj.name == EDPUtil.USER_NAME_SR_OPS){
                defaultOpsUser = userObj;
            }
        }  
        
       Map<Id,Opportunity> mapOppty = new Map<id, Opportunity>([select id, SalesOrganizationName__c from Opportunity where id in : opptyId] );
       Map<id, Customer_Credit__c> ccMap = new Map<Id, Customer_Credit__c>([Select Id, Sunrun_Credit_Status__c, Date_Pulled__c, name, Approved_By__c, SRH_Customer_Number__c, Approved__c, Date_Approved__c from Customer_Credit__c where Id in :creditIds]); 
        if(!ccMap.isEmpty() ){
            if(!mapOppty.isEmpty()){
                for(Proposal__c proposalObj:proposalList){
                    if(mapOppty.get(proposalObj.Opportunity__c).SalesOrganizationName__c==Label.PosigenID && ccMap.containsKey(proposalObj.Current_Customer_Credit_Report__c) ) {
                        Customer_Credit__c ccObj = ccMap.get(proposalObj.Current_Customer_Credit_Report__c) ;
                        ccObj.Approved_By__c = 'Automatic approval';
                        ccObj.Date_Approved__c = DateTime.now();
                        ccObj.Approved__c = 'Passed Credit Check';
                        ccObj.SRH_Customer_Number__c = proposalObj.name;
                        
                        proposalObj.Stage__c = EDPUtil.CREDIT_APPROVED;
                        proposalObj.Assigne__c = defaultOpsUser.Id;   
                        proposalObj.ACH_Required__c = true;
                        proposalObj.SR_Finance_Action__c=EDPUtil.CREDIT_APPROVED;
                        system.debug('ccObj.Sunrun_Credit_Status__c ' +  ccObj.Sunrun_Credit_Status__c );
                        if(ccObj.Sunrun_Credit_Status__c == CustomerCreditUtil.CPASS){
                            proposalObj.Credit_Status__c = 'Conditional Pass & Signed Up for ACH'; 
                        }
                        else if(ccObj.Sunrun_Credit_Status__c == CustomerCreditUtil.PASS){
                            proposalObj.Credit_Status__c = 'Passed credit check';
                        }
                        
                        listCC.add(ccObj);
                        listproposal.add(proposalObj);
                    }
                    
                }
            }
        }
      
        SYSTEM.DEBUG('listCC>>' +  listCC);
        if(!listCC.isEmpty()){
            update listCC;
        }
       /* system.debug('listproposal>>' +  listproposal);
          if(!listproposal.isEmpty()){
           //update listproposal; 
        }*/
    }
    
    
    
  public static void calculateProposalCostStack(Proposal__c proposalObj, Contact contactObj){
    Id SunrunIncId=System.Label.Sunrun_Inc_Id;
    if(proposalObj.Proposal_Source__c != ProposalUtil.BLACK_BIRD){
      if(proposalObj.sales_partner__c != SunrunIncId){
        if(proposalObj.sales_partner__c == proposalObj.install_partner__c){
          proposalObj.cost_stack__c = 'INTEGRATED';
        }else{
          proposalObj.cost_stack__c = 'MULTI_PARTY';
        }
      }else if(proposalObj.sales_partner__c == SunrunIncId){
        if(proposalObj.sales_partner__c != proposalObj.install_partner__c){
          proposalObj.cost_stack__c = 'MULTI_PARTY_SUNRUN_SELLS';
        }else if(proposalObj.sales_partner__c == proposalObj.install_partner__c){
          if(contactObj != null && contactObj.Division__c == 'Field Sales'){
            proposalObj.cost_stack__c = 'INTEGRATED_SUNRUN_SELLS';
          }else{
            proposalObj.cost_stack__c = 'MULTI_PARTY_SUNRUN_SELLS';
          }
        }        
      }
      
    }
   }

    public static Set<String> sunrunModes;
    public static void updateInstallPartner(Proposal__C proposalObj){
        if(sunrunModes == null || sunrunModes.isEmpty()){
            sunrunModes = new Set<String>();
            sunrunModes.add('Sunrun - AZSS - NV');
            sunrunModes.add('Sunrun - AZSS - NV Master');
            sunrunModes.add('Sunrun - American Electric - HI');
            sunrunModes.add('Sunrun - American Electric - HI Master');
            sunrunModes.add('Sunrun - Harvest - NY');
            sunrunModes.add('Sunrun - Harvest - NY Master');
            sunrunModes.add('Sunrun - Premier Solar Solutions - NV');
            sunrunModes.add('Sunrun - Premier Solar Solutions - NV Master');
            sunrunModes.add('Sunrun - Premier Solar Solutions - NV Master');
            sunrunModes.add('Sunrun - Solar Universe - CSI Master');
            sunrunModes.add('Sunrun - Trinity - NJ');
            sunrunModes.add('Sunrun - Trinity - NJ Master');
            sunrunModes.add('Sunrun - Trinity - NY');
            sunrunModes.add('Sunrun - Trinity - NY Master');
            sunrunModes.add('Sunrun - Verengo - CSI');
            sunrunModes.add('Sunrun - Verengo - CSI Master');
        }
        Id SunrunIncId=System.Label.Sunrun_Inc_Id;
    if(Trigger.isInsert == true && proposalObj != null && proposalObj.Proposal_Source__c != ProposalUtil.BLACK_BIRD 
            && proposalObj.Install_Partner__c == SunrunIncId 
            && proposalObj.Mode_Name__c != null && sunrunModes.contains(proposalObj.Mode_Name__c)){
            proposalObj.Install_Partner__c = null;
        }
    }
    
    public static void modifyRECInfo(Proposal__c proposalObj){
        if(proposalObj != null){
            String recId = getRECPartnerId();
            String SunrunIncId = System.Label.Sunrun_Inc_Id;
            String salesPartnerId = (proposalObj.sales_partner__c != null) ? proposalObj.sales_partner__c + '' : '';
            String installPartnerId = (proposalObj.install_partner__c != null) ? proposalObj.install_partner__c + '' : '';
            if(salesPartnerId.contains(recId)){
                proposalObj.sales_partner__c = SunrunIncId;
            }
            if(installPartnerId.contains(recId)){
                System.debug('SunrunIncId : ' + SunrunIncId);
                proposalObj.install_partner__c = SunrunIncId;
            }
        }
    }

    public static void modifyRECInfo(Opportunity optyObj){
        String recId = getRECPartnerId();
        String SunrunIncId = System.Label.Sunrun_Inc_Id;
        String installPartnerId = (optyObj.Install_Partner__c != null) ? optyObj.Install_Partner__c + '' : '';
        if(installPartnerId.contains(recId)){
            optyObj.Install_Partner__c = SunrunIncId;
        }       
    }   

    
    public static Id getRECPartnerId(){
    return System.Label.REC_Partner_Id;
    }

    public static void updateUsageValues(Proposal__c newProposalObj, Proposal__c oldProposalObj){
    if(oldProposalObj == null || (newProposalObj.January_kWh__c != oldProposalObj.January_kWh__c))
      newProposalObj.Jan_Usage__c = newProposalObj.January_kWh__c;

    if(oldProposalObj == null || (newProposalObj.February_kWh__c != oldProposalObj.February_kWh__c))
      newProposalObj.Feb_Usage__c = newProposalObj.February_kWh__c;

    if(oldProposalObj == null || (newProposalObj.March_kWh__c != oldProposalObj.March_kWh__c))
      newProposalObj.Mar_Usage__c = newProposalObj.March_kWh__c;
    
    if(oldProposalObj == null || (newProposalObj.April_kWh__c != oldProposalObj.April_kWh__c))
      newProposalObj.Apr_Usage__c = newProposalObj.April_kWh__c;

    if(oldProposalObj == null || (newProposalObj.May_kWh__c != oldProposalObj.May_kWh__c))
      newProposalObj.May_Usage__c = newProposalObj.May_kWh__c;

    if(oldProposalObj == null || (newProposalObj.June_kWh__c != oldProposalObj.June_kWh__c))
      newProposalObj.Jun_Usage__c = newProposalObj.June_kWh__c;

    if(oldProposalObj == null || (newProposalObj.July_kWh__c != oldProposalObj.July_kWh__c))
      newProposalObj.Jul_Usage__c = newProposalObj.July_kWh__c;
    
    if(oldProposalObj == null || (newProposalObj.August_kWh__c != oldProposalObj.August_kWh__c))
      newProposalObj.Aug_Usage__c = newProposalObj.August_kWh__c;
      
    if(oldProposalObj == null || (newProposalObj.September_kWh__c != oldProposalObj.September_kWh__c))
      newProposalObj.Sep_Usage__c = newProposalObj.September_kWh__c;

    if(oldProposalObj == null || (newProposalObj.October_kWh__c != oldProposalObj.October_kWh__c))
      newProposalObj.Oct_Usage__c = newProposalObj.October_kWh__c;

    if(oldProposalObj == null || (newProposalObj.November_kWh__c != oldProposalObj.November_kWh__c))
      newProposalObj.Nov_Usage__c = newProposalObj.November_kWh__c;
    
    if(oldProposalObj == null || (newProposalObj.December_kWh__c != oldProposalObj.December_kWh__c))
      newProposalObj.Dec_Usage__c = newProposalObj.December_kWh__c;
  }

    public static void modifyOpportunity(List<Proposal__c> proposalsList){
        Map<String, String> proposalNameMap = new Map<String, String> ();
        Set<Id> parentProposalIds = new Set<Id>();
        for(Proposal__c proposalObj : proposalsList){
            String parentProposalName = EDPUtil.getParentProposalName(proposalObj.Name);
            if(parentProposalName != null && parentProposalName != ''){
                proposalNameMap.put(proposalObj.Name, parentProposalName);
            }
        }
        List<String> parentProposalNames = proposalNameMap.values();
        if(!proposalNameMap.isEmpty()){
            Map<String, Proposal__c> parentPoroposalMap = new Map<String, Proposal__c>();

            String proposalSOQLStr = ProposalUtil.getProposalSQLStr();
            proposalSOQLStr += ' where name in :parentProposalNames ' ;
            for(Proposal__c parentProposalObj : Database.query(proposalSOQLStr)){ 
                parentPoroposalMap.put(parentProposalObj.Name, parentProposalObj);
            }
        
            for(Proposal__c proposalObj: proposalsList){
                String parentProposalName = proposalNameMap.get(proposalObj.name);
                if(parentProposalName != null && parentProposalName != ''){
                    Proposal__c parentProposalObj = parentPoroposalMap.get(parentProposalName);
                    if(parentProposalObj != null ){
                        proposalObj.Customer_SignOff_Date__c = parentProposalObj.Customer_SignOff_Date__c;
                        proposalObj.Opportunity__C = parentProposalObj.Opportunity__C;
                        ProposalUtil.setParentProposalInformation(proposalObj, parentProposalObj);
                    }
                }       
            }
        }
    }
    
  public static set<Id> getoptyIdsWithCustOffer(Set<Id> optyIdsModifiedCustOffer){
      set<Id> optyIdsWithCustOffer = new set<Id>();
    for(Opportunity optyObj : [Select Id, Customer_Offer_Proposal__c, (Select Id, createdDate, Customer_Offer__c from Proposals__r where Customer_Offer__c = true) from Opportunity where Id in :optyIdsModifiedCustOffer]){
      if(optyObj.Proposals__r != null && optyObj.Proposals__r.size() > 0){
        optyIdsWithCustOffer.add(optyObj.Id);
      }    
    }
    return optyIdsWithCustOffer;      
    }

    public static Set<String> optyTaskName = new Set<String>();
    public static void processWFTasks(Map<Id, Proposal__c> newMap, Map<Id, Proposal__c> oldMap){
        Map<String, Id> optyMap = new  Map<String, Id>();
        Map<String, String> taskNameMap = new  Map<String, String>();
        Map<Id, Id> proposalOptyMap = new Map<Id, Id>();
        Map<String, String> reasonMap = new Map<String, String>();
        Map<String, String> actionMap = new Map<String, String>();
        for(Proposal__c proposalObj : newMap.values()){
            Proposal__c oldProposalObj;
            if(oldMap != null && proposalObj.Id != null){
                oldProposalObj = oldMap.get(proposalObj.Id);
            }
            
            System.debug('proposalObj.Stage__c: ' + proposalObj.Stage__c);
            if(oldProposalObj != null && oldProposalObj.stage__c != proposalObj.stage__c && proposalObj.stage__c == EDPUtil.SR_OPS_REVIEWED){
                //taskNameMap.put(proposalObj.Opportunity__c + Label.WFM_Approve_Credit, Label.WFM_Approve_Credit);
                //optyMap.put(proposalObj.Opportunity__c + Label.WFM_Approve_Credit, proposalObj.Opportunity__c);
            }else if(oldProposalObj != null && oldProposalObj.stage__c != proposalObj.stage__c && proposalObj.stage__c == EDPUtil.CREDIT_APPROVED){
                String uniqueString = proposalObj.Opportunity__c + Label.WFM_Approve_Credit;
                if(!optyTaskName.contains(uniqueString)){
                    taskNameMap.put(uniqueString, Label.WFM_Approve_Credit);
                    optyMap.put(uniqueString, proposalObj.Opportunity__c);
                    optyTaskName.add(uniqueString);
                }
            }else if(oldProposalObj != null && oldProposalObj.Stage__c != proposalObj.Stage__c && proposalObj.Stage__c == EDPUtil.SR_OPS_APPROVED){
                String uniqueString = proposalObj.Opportunity__c + Label.WFM_Review_And_Approve_Proposal;
                if(!optyTaskName.contains(uniqueString)){
                    taskNameMap.put(uniqueString, Label.WFM_Review_And_Approve_Proposal);
                    optyMap.put(uniqueString, proposalObj.Opportunity__c);
                    optyTaskName.add(uniqueString);
                }
            }else if(oldProposalObj != null && oldProposalObj.Stage__c != proposalObj.Stage__c && proposalObj.Stage__c == EDPUtil.SUBMITTED){
                String uniqueString = proposalObj.Opportunity__c + Label.WFM_Submit_Proposal;
                if(!optyTaskName.contains(uniqueString)){
                    taskNameMap.put(uniqueString, Label.WFM_Submit_Proposal);
                    optyMap.put(uniqueString, proposalObj.Opportunity__c);
                    proposalOptyMap.put(proposalObj.Id, proposalObj.Opportunity__c);
                    optyTaskName.add(uniqueString);
                }
            }else if(oldProposalObj != null && oldProposalObj.Stage__c != proposalObj.Stage__c && proposalObj.Stage__c == EDPUtil.SR_DECLINED){
                String uniqueString = proposalObj.Opportunity__c + Label.WFM_Submit_Proposal;
                if(!optyTaskName.contains(uniqueString)){
                    taskNameMap.put(uniqueString, Label.WFM_Submit_Proposal);
                    optyMap.put(uniqueString, proposalObj.Opportunity__c);
                    proposalOptyMap.put(proposalObj.Id, proposalObj.Opportunity__c);
                    optyTaskName.add(uniqueString);
                    reasonMap.put(uniqueString, 'Proposal Declined');
                    actionMap.put(uniqueString, wfUtil.RE_OPEN);
                }
            }else if(oldProposalObj != null && oldProposalObj.Stage__c != proposalObj.Stage__c && proposalObj.Stage__c == EDPUtil.WITH_DRAWN){
                String uniqueString = proposalObj.Opportunity__c + Label.WFM_Submit_Proposal;
                if(!optyTaskName.contains(uniqueString)){
                    taskNameMap.put(uniqueString, Label.WFM_Submit_Proposal);
                    optyMap.put(uniqueString, proposalObj.Opportunity__c);
                    proposalOptyMap.put(proposalObj.Id, proposalObj.Opportunity__c);
                    optyTaskName.add(uniqueString);
                    reasonMap.put(uniqueString, 'Proposal Withdrawn');
                    actionMap.put(uniqueString, wfUtil.RE_OPEN);
                }
            }
            
            System.debug('taskNameMap: ' + taskNameMap);
            System.debug('optyMap: ' + optyMap);
            System.debug('proposalOptyMap: ' + proposalOptyMap);
        }
        
        if(proposalOptyMap != null && !proposalOptyMap.isEmpty()){
            System.debug('Invoking updateProposalWFProjects');
            wfUtil.updateProposalWFProjects(proposalOptyMap);
        }
        
        if(optyMap != null && !optyMap.isEmpty()){
            System.debug('Invoking updateProposalWFTasks');
            wfUtil.updateProposalWFTasks(optyMap, taskNameMap, reasonMap, actionMap);
        }
    }
     
    @future
    public static void updateCustomerOfferInfo(Set<Id> opportunityIds, Set<Id> proposalIds){
        Map<Id, Proposal__C> modifiedProposalMap = new Map<Id, Proposal__C>();
        Map<Id, Opportunity> modifiedOptyMap = new Map<Id, Opportunity>();
        for(Opportunity optyObj : [Select Id, Customer_Offer_Proposal__c, (Select Id, createdDate, Customer_Offer__c from Proposals__r order by createdDate desc) from Opportunity where Id in :opportunityIds]){
          Id customerOfferId;
          for(Proposal__C proposalObj : optyObj.Proposals__r){
            if(proposalIds != null && !proposalIds.isEmpty()){
              if(proposalObj.Customer_Offer__c == true && !proposalIds.contains(proposalObj.Id)){
                proposalObj.Customer_Offer__c = false;
                modifiedProposalMap.put(proposalObj.Id, proposalObj);            
              }else if(proposalObj.Customer_Offer__c == true && proposalIds.contains(proposalObj.Id)){
                optyObj.Customer_Offer_Proposal__c = proposalObj.Id;
                modifiedOptyMap.put(optyObj.Id, optyObj);
              }
            }else{
              if(proposalObj.Customer_Offer__c == true && customerOfferId == null){
                customerOfferId = proposalObj.Id;
                optyObj.Customer_Offer_Proposal__c = proposalObj.Id;
                modifiedOptyMap.put(optyObj.Id, optyObj);
              }else if(proposalObj.Customer_Offer__c == true && customerOfferId != null){
                proposalObj.Customer_Offer__c = false;
                modifiedProposalMap.put(proposalObj.Id, proposalObj);
              }
            }
          }
          if(customerOfferId == null && (proposalIds == null || proposalIds.isEmpty())){
            optyObj.Customer_Offer_Proposal__c = null;
            modifiedOptyMap.put(optyObj.Id, optyObj);
          }
        }
        
        if(modifiedProposalMap != null && !modifiedProposalMap.isEmpty()){
          update modifiedProposalMap.values();
        }
    
        if(modifiedOptyMap != null && !modifiedOptyMap.isEmpty()){
          update modifiedOptyMap.values();
        }
  } 

    @future
    public static void updateLastCreatedProposal(Set<Id> opportunityIds){
    Map<Id, Proposal__C> modifiedProposalMap = new Map<Id, Proposal__C>();
        for(Opportunity optyObj : [Select Id, (Select Id, createdDate, Last_Generated_Proposal__c from Proposals__r order by createdDate desc) from Opportunity where Id in :opportunityIds]){
            Integer counter = 0;
            for(Proposal__C proposalObj : optyObj.Proposals__r){
                if(counter == 0){
                    proposalObj.Last_Generated_Proposal__c = true;
                    modifiedProposalMap.put(proposalObj.Id, proposalObj);
                }else if(proposalObj.Last_Generated_Proposal__c == true){
                    proposalObj.Last_Generated_Proposal__c = false;
                    modifiedProposalMap.put(proposalObj.Id, proposalObj);
                }
                
                counter ++;
            }
        }
        if(modifiedProposalMap != null && !modifiedProposalMap.isEmpty()){
            update modifiedProposalMap.values();
        }
    }
    
    @future
    public static void updateProposalStatus(Set<Id> proposalIds){
        List<Proposal__c> proposalList = new List<Proposal__c>();
        for(Proposal__C proposalObj : [Select Id, status__c from Proposal__C where Id in :proposalIds]){
            proposalObj.status__c = proposalObj.status__c = 'Valid';
            proposalList.add(proposalObj);
        }
        update proposalList;
    }

    //@future
    public static Set<Id> processedOptys = new Set<Id>();
    public static void createProject(Map<Id, Id> optyProposalMap, Map<Id, String> projectTypeMap){
        Map<Id, Id> modifiedOptyMap = new Map<Id, Id>();
        for(Id optyId : optyProposalMap.KeySet()){
            if(!processedOptys.contains(optyId)){
                modifiedOptyMap.put(optyId, optyProposalMap.get(optyId));
            }
        }
        if(!modifiedOptyMap.isEmpty()){
            processedOptys.addall(modifiedOptyMap.keySet());
            WorkflowManagement wfManagementObj = new WorkflowManagement();
            wfManagementObj.createProject(modifiedOptyMap, projectTypeMap);
        }
    }

    public static Map<Id, Boolean> getCostcoOpptySRApprovedProposalMap(Set<Id> OpptyIds){
        Map<Id, Boolean> opptyPropSRApprovedMap = new Map<Id, Boolean>(); 
        for (Proposal__c prop : [select id, Opportunity__c, Stage__c 
                                   from Proposal__c 
                                  where Opportunity__c in :OpptyIds
                                    and Stage__c = :EDPUtil.SR_OPS_APPROVED
                                    and Opportunity__r.Purchased_Thru__c = 'Costco']){
        
                opptyPropSRApprovedMap.put(prop.Opportunity__c, true);
        }
        return opptyPropSRApprovedMap;
 
    }

	public static Map<Id, Proposal__c> originalProposalMp ;
    public static Map<Id, Proposal__c> getOriginalProposalMap( Set<Id> propOriginalIds){
        Boolean runQuery = false;
        if(originalProposalMp != null && !originalProposalMp.isEmpty()){
            for(Id proposalId : propOriginalIds){
                if(!originalProposalMp.containsKey(proposalId)){
                    runQuery = true;
                    break;
                }
            }           
        }
        if(originalProposalMp == null || runQuery == true){
            originalProposalMp = new Map<Id, Proposal__c>();
			originalProposalMp =  new Map<Id, Proposal__c>([SELECT Id, Proposal_Source__c, Change_Order_Information__c,
                                                            Last_Customer_Signed_Proposal__c,Signed__c,Original_Proposal_ID__c,
                                                            Original_Proposal_ID__r.ACH_Fee_Eligible__c,Original_Proposal_ID__r.Last_Customer_Signed_Proposal__c, 
                                                            Original_Proposal_ID__r.signed__c FROM Proposal__c WHERE id IN :propOriginalIds]);
		}
        return originalProposalMp;
    }
    
	public static void copySRAttachmentsToProposal(Map<Id, Set<Id>> optyProposalMap){
    	System.debug('optyProposalMap: ' + optyProposalMap);
    	String soql = SRAttachmentManager.getOptyAttachmentSOQL();
    	Set<Id> optyIds = optyProposalMap.keySet();
    	Set<String> documentNames = new Set<String>();
    	documentNames.add('Utility Bill');
    	soql += ' where Opportunity__c in :optyIds and active__c = true and Document_Type_Name__c =:documentNames ';
    	List<SR_Attachment__c> newSRList = new List<SR_Attachment__c>();
    	for(SR_Attachment__c srAttachmentObj : Database.query(soql)){
    		Set<Id> proposalIds = optyProposalMap.get(srAttachmentObj.Opportunity__c);
    		for(Id proposalId : proposalIds){
    			SR_Attachment__c newSRAttachment = new SR_Attachment__c();
				
				newSRAttachment.Document_Name_On_File_Server__c = srAttachmentObj.Document_Name_On_File_Server__c;
				newSRAttachment.folder_name__c = srAttachmentObj.folder_name__c;
				newSRAttachment.Parent_Proposal_Name__c = srAttachmentObj.Document_Name_On_File_Server__c;
				newSRAttachment.Document_Source__c = srAttachmentObj.Document_Source__c;
				newSRAttachment.Wet_Sign_Status__c = srAttachmentObj.Wet_Sign_Status__c;
				newSRAttachment.Document_Classification__c = srAttachmentObj.Document_Classification__c;
				newSRAttachment.Document_Name__c = srAttachmentObj.Document_Name__c;
				newSRAttachment.active__c = srAttachmentObj.active__c;
				newSRAttachment.size__c = srAttachmentObj.size__c;
				newSRAttachment.proposal__c = proposalId;
				newSRList.add(newSRAttachment);
    		}
    	}
    	
    	if(!newSRList.isEmpty()){
    		insert newSRList;
    	}
    }
}