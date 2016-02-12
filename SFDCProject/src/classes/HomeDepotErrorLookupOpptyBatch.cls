global class HomeDepotErrorLookupOpptyBatch implements Database.Batchable<Opportunity>, Database.AllowsCallouts  {
    
    private BaseClass utils = new BaseClass();
    public HomeDepotErrorLookupOpptyBatch() {

    }

    global List<Opportunity> start(Database.BatchableContext bc) {
      String channelStr = 'Retail';
      String homeDepotStr = 'Home Depot';
      String tobeSyncedStr = BaseClass.Status_ToBeSynced;
      String syncErrStatus = 'Sync Error';
      Set<String> leadSourceValues = utils.getCustomLeadSources(homeDepotStr);
      String soql = 'select Id , StageName, Lead_Source_2__c, accountId, External_Id__c, Prospect_Id__c, External_Sync_Batch_ID_Outbound__c, External_Sync_Status__c, External_Sync_Details__c, External_Created_DateTime__c,'; 
      soql += 'Account.Id, Account.BillingStreet, Account.BillingCity, Account.BillingCountry, Account.County__c, Account.BillingPostalCode, Account.BillingState from Opportunity ';
      soql += 'where Lead_Source_2__c in:leadSourceValues and External_Sync_System__c =:homeDepotStr and External_Sync_Status__c =:tobeSyncedStr ';
      soql += 'and External_Sync_InProgress__c = true and External_Created_DateTime__c != null ';
      soql += 'order by LastModifiedDate';
      
      system.debug('soql'+soql);
       List<opportunity> optys = Database.query(soql);
       System.debug('Opportunities :' +optys);
       
       return optys;
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> optys){
      
      List<API_Request_Log__c> apiRLlist = new List<API_Request_Log__c>();  
      for(Opportunity o : optys){
        API_Request_Log__c apiRL = new API_Request_Log__c();
        apiRL.Object_Name__c = 'Opportunity';
        apiRL.Prospect_Id__c = o.Prospect_Id__c;
        //apiRL.External_Created_Date__c = o.External_Created_Date__c;
        //apiRL.External_Created_DateTime__c = o.External_Created_DateTime__c;
        apiRL.Request_Type__c = 'HD Error Look-up';
        apiRL.Request_Status__c = 'Look-up Error';
        apiRL.External_Sync_System__c = 'Home Depot';
        apiRL.Name = apiRL.Request_Type__c+apiRL.Prospect_Id__c;
        apiRLlist.add(apiRL);
      }  
      insert apiRLlist;
    }
    
    global void finish(Database.BatchableContext BC){
		BatchUtil.processBatchErrors(bc);
    }
    
}