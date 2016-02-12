public class HomeDepotSCELookupQueueable implements Queueable, Database.AllowsCallouts  {
    
    public Id apiRequestLogId {get;set;}
    
    public HomeDepotSCELookupQueueable() {
        this(null);
    }
    
    public HomeDepotSCELookupQueueable(Id apiRequestLogId) {
        this.apiRequestLogId = apiRequestLogId;
    }
    
  
    public void execute(QueueableContext ctx) {
        String batchId;  
        API_Request_Log__c apiReq = [select Id, Object_Name__c, Prospect_Id__c from API_Request_Log__c where id = :apiRequestLogId];       
        
        If(apiReq.Object_Name__c.equalsIgnoreCase('Service Contract Event')){
            Service_Contract_Event__c sce = [Select External_Sync_Batch_ID_Outbound__c from Service_Contract_Event__c where ProspectId__c = :apiReq.Prospect_Id__c];  
            batchId = sce.External_Sync_Batch_ID_Outbound__c;
        }
        
        if(batchId != null){
           Sf.HomeDepotSyncService.lookupSCE(apiReq.Id, batchId, apiReq.Prospect_Id__c);             
        }else{
            apiReq.Request_Status__c = 'Look-up Error'; 
            apiReq.Response_Details__c = 'External Sync Batch ID Outbound is not found';
            update apiReq;
        }
    
    }
    
}