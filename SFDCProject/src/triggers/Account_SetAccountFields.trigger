/****************************************************************************
Author  : Raghu Masineni (rmasineni@sunrunhome.com)
Date    : April 2012
Description: This trigger updates/verifies the following Account fields
           -- Account number filed should 10 digit text 
           -- If the Account is not active, it should have a valid reason
           -- Update the Account type based on the Record Type Id

*****************************************************************************/

trigger Account_SetAccountFields on Account (before insert, before update) {
  
    Boolean skipValidations = false;
  skipValidations = SkipTriggerValidation.performTriggerValidations();
  if(skipValidations == false){ 
    try{
      Id partnerRecordTypeId ;
      Id residentialRecordTypeId ;
      Account oldAccountObj = null;
      Set<Id> accountIdsForProposals = new Set<Id>();
      //Set<Id> accountIdforOppty = new Set<Id>();
      Map<Id, RecordType> accountRecordTypeMap = PRMLibrary.getAccountRecordTypes();
      for(RecordType recordTypeObj : accountRecordTypeMap.values()){
        if(recordTypeoBJ.name == PRMLibrary.PARTNER){
          partnerRecordTypeId = recordTypeoBJ.Id;
        }else if(recordTypeoBJ.name == AccountUtil.RESIDENTIAL){
          residentialRecordTypeId = recordTypeoBJ.Id;
        }
      }
        Integer size = 0;
        Integer counter = 0;    
        Set<Id> parentAccountIds = new Set<Id>();
        List<Account> childAccounts = new List<Account>();
        Set<Id> inactivatedAccountIds = new Set<Id>();
        Set<Id> tempParentAccountIds = new Set<Id>();
        Map<id,String> AccIdNameMap=new Map<id,String>();
        for(Account accountObj: Trigger.new){
        	//BSKY-4803
	    	if(accountObj.billingstate!=null&&accountObj.state__c==null){
	    	 accountObj.state__c=accountObj.billingstate;
	    	}
	    	//End BSKY-4803
          if(partnerRecordTypeId != null && accountObj.RecordTypeId  == partnerRecordTypeId){
            if(accountObj.Account_Number__c == null || accountObj.Account_Number__c == ''){
                  size++;
            }
    
              if(Trigger.isInsert && accountObj.ParentId != null){
                parentAccountIds.add(accountObj.ParentId);
                childAccounts.add(accountObj);
                accountObj.Ultimate_Parent_Account__c = PRMLibrary.getUltimateParentAccountId(accountObj.ParentId);
              }else if(Trigger.isupdate){
            oldAccountObj = Trigger.oldMap.get(accountObj.Id);
            if(oldAccountObj.ParentId != accountObj.ParentId) {
              parentAccountIds.add(accountObj.ParentId);
              childAccounts.add(accountObj);
              accountObj.Ultimate_Parent_Account__c = PRMLibrary.getUltimateParentAccountId(accountObj.ParentId);
            }
              }
    
          if(accountObj.Active__c != null){
                if((oldAccountObj != null && accountObj.Active__c == false 
                    && oldAccountObj.Active__c != accountObj.Active__c )) {
                 //Verify that this Account doesn't associate with any 
                 //active contacts OR active accounts
              inactivatedAccountIds.add(accountObj.Id);
            }
              }          
          
          if((accountObj.Active__c == true && oldAccountObj == null) 
            || (oldAccountObj != null && accountObj.Active__c == true 
              && oldAccountObj.Active__c != accountObj.Active__c )
            || (oldAccountObj != null && accountObj.parentId != null 
              && oldAccountObj.parentId != accountObj.parentId )){
            if(accountObj.parentId != null){
              tempParentAccountIds.add(accountObj.parentId);
            }
          }
    
        }
        if(Trigger.isUpdate){
          oldAccountObj = Trigger.oldMap.get(accountObj.Id);
          if(accountObj.RecordTypeId == residentialRecordTypeId && (AccountUtil.isAddressInformationChanged(accountObj, oldAccountObj))){
            accountIdsForProposals.add(accountObj.Id);
            System.debug('accountIdsForProposals: ' + accountIdsForProposals);
          }
        }
        /*
        if(Trigger.isInsert && accountObj.BillingState != null && accountObj.BillingState != ''){
                accountObj.Stage__c = accountObj.BillingState;
            }
          
            if(Trigger.isUpdate && accountObj.BillingState != accountObj.Stage__c){
                accountObj.Stage__c = accountObj.BillingState;
            }
            */
            if(Trigger.isUpdate&&accountObj.recordtypeid==residentialRecordTypeId){
              oldAccountObj = Trigger.oldMap.get(accountObj.Id);
              if(AccountUtil.isAddressInformationChanged(accountObj, oldAccountObj) )
               {
                 accountObj.Name = accountObj.BillingStreet + '-' + accountObj.BillingPostalCode;
                 //accountIdforOppty.add(accountObj.id);
                 AccIdNameMap.put(accountObj.id,accountObj.Name);
               }
            }
        }
      
      if(!AccIdNameMap.isEmpty()){
            OpptyUtil.updateOpptyName(AccIdNameMap);
      }
      
      if(accountIdsForProposals.size() > 0){
          Map<Id, Map<Id, Proposal__C>> accountProposalmap = ProposalUtil.getActiveProposalsForAccounts(accountIdsForProposals);
          if(accountProposalmap != null && accountProposalmap.size() > 0){
            for(Id accountId : accountProposalmap.keySet()){
              Map<Id, Proposal__c> activeProposalMap = accountProposalmap.get(accountId);
              Account tempAccountObj = Trigger.newmap.get(accountId);
              if(activeProposalMap != null && activeProposalMap.size() > 0){
              if(tempAccountObj.Void_Proposals__c == true || AccountUtil.eligibleForVoid.contains(tempAccountObj.Id)){
                AccountUtil.eligibleForVoid.add(tempAccountObj.Id);
                tempAccountObj.Void_Proposals__c = false;
              }else{
                String errormessage = '';
                errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000021').error_message__c;
                tempAccountObj.adderror(errormessage);        
              }             
              }
          }
          }
        }
        
       
         Map<Id, String> accountsWithActiveChildRecords = new Map<Id, String>();
         Set<Id> inactiveParentIds = new Set<Id>();
         if(inactivatedAccountIds.size() > 0){
        accountsWithActiveChildRecords = PRMLibrary.checkForActiveAccountsAndContacts(inactivatedAccountIds);
         }
      
      if(tempParentAccountIds.size() > 0){
        inactiveParentIds = PRMLibrary.getInactiveParentAccounts(tempParentAccountIds);
      }
      
         //Get unique Account numbers
      List<String> randomNumners = null;
      Map<Id, Account> accountMap ;
        if(size > 0){
            randomNumners = PRMLibrary.getUniqueAcountNumbers(size);
        }
        System.debug('randomNumners: ' + randomNumners);
        
        if(parentAccountIds != null && parentAccountIds.size() > 0){
         PRMLibrary.updateAccountName(parentAccountIds, childAccounts);
        }
        
        for(Account accountObj: Trigger.new){
             //Set Account Type information
            if(accountRecordTypeMap != null && 
              accountObj.RecordTypeId != null && 
              accountRecordTypeMap.containsKey(accountObj.RecordTypeId)){      
                accountObj.Account_Type__c = accountRecordTypeMap.get(accountObj.RecordTypeId).Name; 
            }
          
          if(Trigger.isUpdate){
            if(accountObj.Void_Proposals__c == true){
            accountObj.Void_Proposals__c = false;
          }
          oldAccountObj = Trigger.oldMap.get(accountObj.Id);   
            /*
            if((partnerRecordTypeId != null) && 
              (accountObj.RecordTypeId  == partnerRecordTypeId) || 
              (oldAccountObj.RecordTypeId  == partnerRecordTypeId)){
                
                if(oldAccountObj.Active__c == false && accountObj.Active__c == oldAccountObj.Active__c){
                  accountObj.adderror('First activate the account to make modifications');
                }
            }
            */
          }
          
          if(partnerRecordTypeId != null && accountObj.RecordTypeId  == partnerRecordTypeId){    
              //Set Account numbers.
              if((counter < size) && 
                  (accountObj.Account_Number__c == null || accountObj.Account_Number__c == '')){
            accountObj.Account_Number__c = randomNumners[counter];
                  counter++;
              }
    
          String tempSite = (accountObj.shippingCity != null) ? (accountObj.shippingCity) : '';
          String shippingState = (accountObj.shippingState != null) ? accountObj.shippingState : '';      
          if(tempSite != null && tempSite.length() > 0 && shippingState != null && shippingState.length() > 0){
            tempSite +=  ' - ';
          }
          tempSite += shippingState;
    
          if((accountObj.site == null) || (accountObj.site == '') ){
            accountObj.site = tempSite;
          }
              
              if(accountObj.Active__c != null){
            
                if((accountObj.Active__c == false && oldAccountObj == null) 
                  || (oldAccountObj != null && accountObj.Active__c == false 
                    && oldAccountObj.Active__c != accountObj.Active__c )) {
              if(accountObj.Deactivation_Reason__c == null  || accountObj.Deactivation_Reason__c == ''){
                accountObj.adderror('To deactivate an account, select \'Deactivation Reason\'');
              }
            }
    
             if(accountObj.Active__c == false && accountObj.Id != null 
              && accountsWithActiveChildRecords.containskey(accountObj.Id)){
              accountObj.adderror(accountsWithActiveChildRecords.get(accountObj.Id));
            }else if(accountObj.Active__c == true && accountObj.ParentId != null
              && inactiveParentIds.contains(accountObj.ParentId)){
              accountObj.adderror('Inactive Parent Account');
            }
            
              }else if(accountObj.Active__c == null){
            //accountObj.Active__c = true;
              }
          }
        }
    }catch(Exception exceptionObj){
      System.debug('Before Trigger: Account Exception: ' + exceptionObj);
      for(Account accountObj : Trigger.new){
        accountObj.adderror(exceptionObj.getMessage());
      }
    }
  }
}