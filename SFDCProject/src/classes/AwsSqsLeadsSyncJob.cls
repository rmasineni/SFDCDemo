public class AwsSqsLeadsSyncJob extends BaseSyncJob {
	
    public AwsSqsLeadsSyncJob () {
		super(AwsSyncServiceDto.SyncModule, AwsSyncServiceDto.LeadsSync);
    }
	
    override public void execute(SyncJobInfo syncJob) {
        Sf.awsSyncService.syncLeads(syncJob);
    }
}