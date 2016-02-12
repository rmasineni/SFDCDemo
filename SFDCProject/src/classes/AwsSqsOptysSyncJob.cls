public class AwsSqsOptysSyncJob extends BaseSyncJob {
	
    public AwsSqsOptysSyncJob () {
		super(AwsSyncServiceDto.SyncModule, AwsSyncServiceDto.OptysSync);
    }

    override public void execute(SyncJobInfo syncJob) {
        Sf.awsSyncService.syncOptys(syncJob);
    }
}