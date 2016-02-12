public class AwsSqsPaymentsSyncJob extends BaseSyncJob {
	
    public AwsSqsPaymentsSyncJob () {
		super(AwsSyncServiceDto.SyncModule, AwsSyncServiceDto.PaymentsSync);
    }

    override public void execute(SyncJobInfo syncJob) {
        Sf.awsSyncService.syncPayments(syncJob);
    }
}