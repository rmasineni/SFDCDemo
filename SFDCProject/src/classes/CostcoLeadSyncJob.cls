public class CostcoLeadSyncJob extends BaseClass implements Queueable, Database.AllowsCallouts {
	
    public List<Id> leadIds {get;set;}
    
    public CostcoLeadSyncJob() {
    	this(null);
    }
    
    public CostcoLeadSyncJob(List<Id> leadIds) {
        this.leadIds = leadIds;
    }
    
    public void execute(QueueableContext ctx) {
        if (leadIds == null) {
            leadIds = getUniqueIdList([
                select id
                from Lead 
                where External_Sync_System__c = 'Costco' 
                	and (External_Sync_Status__c = :BaseClass.Status_ToBeSynced
	                	or External_Sync_Status__c = :BaseClass.Status_SyncError)
            ]);
        }
        
        Sf.costcoSyncService.syncLeads(leadIds);
    }
}