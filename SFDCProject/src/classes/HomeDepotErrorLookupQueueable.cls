public class HomeDepotErrorLookupQueueable implements Queueable, Database.AllowsCallouts  {
    
  public Id apiRequestLogId {get;set;}
    
    public HomeDepotErrorLookupQueueable() {
      this(null);
    }
    
    public HomeDepotErrorLookupQueueable(Id apiRequestLogId) {
      system.debug('API ID'+apiRequestLogId);
        this.apiRequestLogId = apiRequestLogId;
    }
    
  
    public void execute(QueueableContext ctx) {
        String createdDateTime;
        String createdDate;  
        API_Request_Log__c apiReq = [select Id, Object_Name__c, Prospect_Id__c,External_Created_Date__c,External_Created_DateTime__c from API_Request_Log__c where id = :apiRequestLogId];       
        
        If(apiReq.Object_Name__c.equalsIgnoreCase('lead')){
            Lead l = [Select External_Created_Date__c,External_Created_DateTime__c,External_Sync_Batch_ID_Outbound__c from Lead where Prospect_Id__c = :apiReq.Prospect_Id__c];  
            createdDateTime = l.External_Created_DateTime__c;
        }else if (apiReq.Object_Name__c.equalsIgnoreCase('opportunity')){
            Opportunity o = [Select External_Created_Date__c,External_Created_DateTime__c,External_Sync_Batch_ID_Outbound__c from Opportunity where Prospect_Id__c = :apiReq.Prospect_Id__c];    
            createdDateTime = o.External_Created_DateTime__c;
        }
        Sf.HomeDepotSyncService.errorLogLookup(createdDateTime);
        /*if(createdDateTime != null){
           Sf.HomeDepotSyncService.errorLogLookup(createdDateTime);             
        }else{
            apiReq.Request_Status__c = 'Look-up Error'; 
            apiReq.Response_Details__c = 'External Created Date Time is not found';
            update apiReq;
        }*/
    
    }
    
}