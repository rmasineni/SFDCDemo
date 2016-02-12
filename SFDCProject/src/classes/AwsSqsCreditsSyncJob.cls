public class AwsSqsCreditsSyncJob extends BaseSyncJob {
	
    public AwsSqsCreditsSyncJob () {
		super(AwsSyncServiceDto.SyncModule, AwsSyncServiceDto.CreditsSync);
    }

    override public void execute(SyncJobInfo syncJob) {
        Sf.awsSyncService.syncCredits(syncJob);
    }
}