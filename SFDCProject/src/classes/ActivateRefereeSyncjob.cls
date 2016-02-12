public class ActivateRefereeSyncjob extends BaseClass implements Queueable, Database.AllowsCallouts {
	
    public List<Id> ERPContIds {get;set;}
    List<ID> setId = ERPContIds;
   // System.debug('This is list:'+setId);
    
    public ActivateRefereeSyncjob() {
    	this(null);
    }
    
    public ActivateRefereeSyncjob(List<Id> ERPContIds) {
        this.ERPContIds = ERPContIds;
         System.debug('This is list:'+ERPContIds);
    }
    
    public void execute(QueueableContext ctx) {
        if (ERPContIds == null) {
            Integer limitValue = Sf.settingsService.getInteger('AmbassadorSyncJobLimit', 100);
            
            ERPContIds = getUniqueIdList([
                select id
                from Contact 
				where Ambassador_Sync_Status__c = :BaseClass.Status_ToBeSynced
	                	or Ambassador_Sync_Status__c = :BaseClass.Status_SyncError
                limit :limitValue
            ]); 
            
        /*    ERPContIds = getUniqueIdList([
                select id
                from Contact  
                where ERP_Contact_of_Record__c = True
                limit :limitValue
            ]); */
        }
        System.debug('This is list2:'+ERPContIds);
      //  Sf.ambassadorSyncService.syncERPContacts(ERPContIds);
        Sf.ambassadorSyncService.ActivateRefereeContacts(ERPContIds);
    }
}