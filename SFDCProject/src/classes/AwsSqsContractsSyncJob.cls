public class AwsSqsContractsSyncJob extends BaseSyncJob {
	
    public AwsSqsContractsSyncJob () {
		super(AwsSyncServiceDto.SyncModule, AwsSyncServiceDto.ContractsSync);
    }
	
    override public void execute(SyncJobInfo syncJob) {
        Sf.awsSyncService.syncContracts(syncJob);
    }
}