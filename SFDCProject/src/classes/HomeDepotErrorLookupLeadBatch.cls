global class HomeDepotErrorLookupLeadBatch implements Database.Batchable<Lead>, Database.AllowsCallouts  {
    
    private BaseClass utils = new BaseClass();
    public HomeDepotErrorLookupLeadBatch() {

    }

    global List<Lead> start(Database.BatchableContext bc) {
      String channelStr = 'Retail';
      String homeDepotStr = 'Home Depot';
      String tobeSyncedStr = BaseClass.Status_ToBeSynced;
      String syncErrStatus = 'Sync Error';
      Set<String> leadSourceValues = utils.getCustomLeadSources(homeDepotStr);
      String soql = 'select FirstName, LastName, Title, Street, City, State,PostalCode, Phone, Alternate_Phone__c, Email, Notes__c, Contact_Costco_Member_ID__c, External_Id__c,External_Created_DateTime__c,'; 
      soql += 'Lead_Organization_Location_2__r.AccountNumber,  Prospect_Id__c, External_Sync_Batch_ID_Outbound__c, External_Sync_Status__c, External_Sync_Details__c, CreatedDate from Lead ';
      soql += 'where IsConverted = false  and Custom_Lead_Source__c in :leadSourceValues and External_Sync_System__c =:homeDepotStr and External_Sync_Status__c =:tobeSyncedStr ';
      soql += 'and External_Sync_InProgress__c = true and External_Created_DateTime__c != null ';
      soql += 'order by LastModifiedDate';
      
      system.debug('soql'+soql);
       List<Lead> leads = Database.query(soql);
       System.debug('leads :' +leads);
       
       return leads;
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> leads){
      
      List<API_Request_Log__c> apiRLlist = new List<API_Request_Log__c>();  
      for(Lead l : leads){
        API_Request_Log__c apiRL = new API_Request_Log__c();
        apiRL.Object_Name__c = 'Lead';
        apiRL.Prospect_Id__c = l.Prospect_Id__c;
        //apiRL.External_Created_Date__c = l.External_Created_Date__c;
        //apiRL.External_Created_DateTime__c = l.External_Created_DateTime__c;
        apiRL.Request_Type__c = 'HD Error Look-up';
        apiRL.Request_Status__c = 'Look-up Error';
        apiRL.External_Sync_System__c = 'Home Depot';
        apiRL.Name = apiRl.Request_Type__c+apiRL.Prospect_Id__c;
        apiRLlist.add(apiRL);
        system.debug('apiRLlist'+apiRLlist);
      }  
      insert apiRLlist;
    }
    
    global void finish(Database.BatchableContext BC){
		BatchUtil.processBatchErrors(bc);
    }
    
}