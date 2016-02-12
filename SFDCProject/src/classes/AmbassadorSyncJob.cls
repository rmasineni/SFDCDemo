public class AmbassadorSyncJob extends BaseClass implements Queueable, Database.AllowsCallouts {
	
    public List<Id> referralIds {get;set;}
    
    public AmbassadorSyncJob() {
    	this(null);
    }
    
    public AmbassadorSyncJob(List<Id> referralIds) {
        this.referralIds = referralIds;
    }

    public void execute(QueueableContext ctx) {
        if (referralIds == null) {
            Integer limitValue = Sf.settingsService.getInteger('AmbassadorSyncJobLimit', 100);
            
            referralIds = getUniqueIdList([
                select id
                from Referral_Input__c 
                where Ambassador_Sync_Status__c = :BaseClass.Status_ToBeSynced
	                	or Ambassador_Sync_Status__c = :BaseClass.Status_SyncError
	                	or Ambassador_Sync_Status__c = 'Commission Id Empty'
                limit :limitValue
            ]);
        }
        
        Sf.ambassadorSyncService.syncReferrals(referralIds);
    }
}