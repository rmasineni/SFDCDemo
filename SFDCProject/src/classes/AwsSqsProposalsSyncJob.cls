public class AwsSqsProposalsSyncJob extends BaseSyncJob {
	
    public AwsSqsProposalsSyncJob () {
		super(AwsSyncServiceDto.SyncModule, AwsSyncServiceDto.ProposalsSync);
    }

    override public void execute(SyncJobInfo syncJob) {
        Sf.awsSyncService.syncProposals(syncJob);
    }
}