public class CostcoLeadUpdateQuoteAmountJob extends BaseClass implements Queueable, Database.AllowsCallouts {
	
    public List<Id> proposalIds {get;set;}
    
    public CostcoLeadUpdateQuoteAmountJob() {
    	this(null);
    }
    
    public CostcoLeadUpdateQuoteAmountJob(List<Id> proposalIds) {
        this.proposalIds = proposalIds;
    }
    
    public void execute(QueueableContext ctx) {
        if (proposalIds == null) {
            proposalIds = getUniqueIdList([
                select id
                from Proposal__c 
                where External_Sync_System__c = 'Costco' 
				and (External_Sync_Status__c = :BaseClass.Status_ToBeSynced
					or External_Sync_Status__c = :BaseClass.Status_SyncError)
            ]);
        }
        
		Sf.costcoSyncService.updateLeadsQuoteAmount(proposalIds);
    }
}