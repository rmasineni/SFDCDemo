public with sharing class CostcoLeadUpdateInstallInfoJob extends BaseClass implements Queueable, Database.AllowsCallouts{
public List<Id> sceIds {get;set;}
    
    public CostcoLeadUpdateInstallInfoJob() {
        this(null);
    }
    
    public CostcoLeadUpdateInstallInfoJob(List<Id> sceIds) {
        this.sceIds = sceIds;
    }
    
    public void execute(QueueableContext ctx) {
        if (sceIds == null) {
            sceIds = getUniqueIdList([
                select id
                from Service_Contract_Event__c 
                where External_Sync_System__c = 'Costco' 
                and (External_Sync_Status__c = :BaseClass.Status_ToBeSynced
                    or External_Sync_Status__c = :BaseClass.Status_SyncError)
            ]);
        }
        
        Sf.costcoSyncService.updateInstallationInfo(sceIds);
    }

}