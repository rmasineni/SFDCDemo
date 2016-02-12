public class AmbassadorCommissionSyncJob extends BaseClass implements Queueable, Database.AllowsCallouts {
	
    public List<Id> referralIds {get;set;}
    
    public AmbassadorCommissionSyncJob() {
    	this(null);
    }
    
    public AmbassadorCommissionSyncJob(List<Id> referralIds) {
        this.referralIds = referralIds;
         System.debug('This is list:'+referralIds);
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
        System.debug('This is list2:'+referralIds);
        Sf.ambassadorSyncService.syncNonAmbassadorReferrals(referralIds);
    }
}