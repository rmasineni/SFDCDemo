/**
 * Address batch job needs to be run every hour. As of now it is designed to run at 15th minute of every hour.
 *
 * If a batch job is scheduled, we cannot modify any of its associated classes. So typically the job is removed after testing. To schedule 
 * the batch job, run following apex Script
 *
 * AddressStandardizationScheduler.scheduleJobs();
 */
global class AddressStandardizationScheduler implements Schedulable {
    public static String batchJobName = 'Address Standardization Batch';

    global void execute(SchedulableContext sc) {
        System.debug('Running the Address Standardization Batch job');
		
        //For each lead or account, we will make 3 outbound callls. So we will limit the number of batch size depending on that.
        if (Sf.addressService.isAddressStandardizationForLeadsEnabled()) {
        	Database.executebatch((Database.Batchable<Lead>) Type.forName('AddressStandardizationLeadBatch').newInstance(), 
                                  Sf.settingsService.getInteger('AddressStandardizationLeadsBatchSize', 1));
        }
        if (Sf.addressService.isAddressStandardizationForAccountsEnabled()) {
        	Database.executebatch((Database.Batchable<Account>) Type.forName('AddressStandardizationAccountBatch').newInstance(), 
                                 Sf.settingsService.getInteger('AddressStandardizationAcctsBatchSize', 1));
        }
    }
    
    public static void deleteScheduledJobs() {
        Map<Id, CronJobDetail> jobIdsMap = new Map<ID, CronJobDetail>([SELECT Id FROM CronJobDetail where name like :batchJobName]);
        List<CronTrigger> cronJobs = [SELECT Id FROM CronTrigger where CronJobDetailId = :jobIdsMap.keySet()];
        for (CronTrigger cronJob : cronJobs) {
            System.abortJob(cronJob.id);
        }
    }
    
    public static void scheduleJobs() {
        deleteScheduledJobs();
    
        System.schedule(batchJobName, '0 15 * * * ?', new AddressStandardizationScheduler());

        System.debug(batchJobName + ' is successfully scheduled');
    }
}