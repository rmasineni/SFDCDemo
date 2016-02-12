public class CostcoLeadUpdateEstimateDateJob extends BaseClass implements Queueable, Database.AllowsCallouts {
	
    public List<Id> appointmentIds {get;set;}
    
    public CostcoLeadUpdateEstimateDateJob() {
    	this(null);
    }
    
    public CostcoLeadUpdateEstimateDateJob(List<Id> appointmentIds) {
        this.appointmentIds = appointmentIds;
    }
    
    public void execute(QueueableContext ctx) {
        if (appointmentIds == null) {
            appointmentIds = getUniqueIdList([
                select id
                from Appointment__c 
                where External_Sync_System__c = 'Costco' 
					and (External_Sync_Status__c = :BaseClass.Status_ToBeSynced
					or External_Sync_Status__c = :BaseClass.Status_SyncError)
            ]);
        }
        
		Sf.costcoSyncService.updateLeadsEstimateDate(appointmentIds);
    }
}