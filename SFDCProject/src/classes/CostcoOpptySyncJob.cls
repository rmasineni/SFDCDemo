public class CostcoOpptySyncJob extends BaseClass implements Queueable, Database.AllowsCallouts{
public List<Id> opptyIds {get;set;}
    
    public CostcoOpptySyncJob() {
      this(null);
    }
    
    public CostcoOpptySyncJob(List<Id> opptyIds) {
        this.opptyIds = opptyIds;
    }
    
    public void execute(QueueableContext ctx) {
        if (opptyIds == null) {
            opptyIds = getUniqueIdList([
                select id
                from Opportunity 
                where External_Sync_System__c = 'Costco' 
                  and (External_Sync_Status__c = :BaseClass.Status_ToBeSynced
                    or External_Sync_Status__c = :BaseClass.Status_SyncError)
            ]);
        }
        
        Sf.costcoSyncService.syncOpptys(opptyIds);
    }
}