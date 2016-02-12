public class HomeDepotLeadLookupQueueable implements Queueable, Database.AllowsCallouts  {
    
	public Id apiRequestLogId {get;set;}
    
    public HomeDepotLeadLookupQueueable() {
    	this(null);
    }
    
    public HomeDepotLeadLookupQueueable(Id apiRequestLogId) {
        this.apiRequestLogId = apiRequestLogId;
    }
    
  
    public void execute(QueueableContext ctx) {
        String batchId;  
        API_Request_Log__c apiReq = [select Id, Object_Name__c, Prospect_Id__c from API_Request_Log__c where id = :apiRequestLogId];       
        
        If(apiReq.Object_Name__c.equalsIgnoreCase('lead')){
            Lead l = [Select External_Sync_Batch_ID_Outbound__c from Lead where Prospect_Id__c = :apiReq.Prospect_Id__c];  
            batchId = l.External_Sync_Batch_ID_Outbound__c;
        }else if (apiReq.Object_Name__c.equalsIgnoreCase('opportunity')){
            Opportunity o = [Select External_Sync_Batch_ID_Outbound__c from Opportunity where Prospect_Id__c = :apiReq.Prospect_Id__c];    
            batchId = o.External_Sync_Batch_ID_Outbound__c;
        }
        
        if(batchId != null){
           Sf.HomeDepotSyncService.lookupLead(apiReq.Id, batchId, apiReq.Prospect_Id__c);             
        }else{
            apiReq.Request_Status__c = 'Look-up Error'; 
            apiReq.Response_Details__c = 'External Sync Batch ID Outbound is not found';
            update apiReq;
        }
    
    }
    
}