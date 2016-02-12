/**
 * Iknock Lead Sync Service scheduler. It is scheduled to run every hour.
 *
 * If a batch job is scheduled, we cannot modify any of its associated classes. So typically the job is removed after testing. To schedule 
 * the batch job, run following apex Script
 *
 * System.schedule('IKnock Lead Sync Batch', '0 15 * * * ?', new IKnockLeadSyncScheduler());
 */
global class IKnockLeadSyncScheduler implements Schedulable {
    global static BaseClass utils = new BaseClass();

    global void execute(SchedulableContext sc) {
        
        System.debug('Running the IKnock Lead Sync Batch job');

        //We want the batch size to be 1 because we can only save 25 leads in each transactions. The batch queries
        //for 100 leads to facilitate the batching so it means we can retrieve 25 * 100 => 2500 leads per hour.
        Database.executebatch((Database.Batchable<Lead>) Type.forName('IKnockLeadSyncBatch').newInstance(), 1);
    }
    
    global static void deleteScheduledJobs() {
        //Get the ids for IKnock batch jobs
        List<CronJobDetail> jobIds = [SELECT Id FROM CronJobDetail where name like 'IKnock Lead Sync Batch%'];
        List<CronTrigger> cronJobs = [SELECT Id FROM CronTrigger where CronJobDetailId = :utils.getUniqueIdList(jobIds, 'Id')];
        for (CronTrigger cronJob : cronJobs) {
            System.abortJob(cronJob.id);
        }
    }

    global static String schedule() {
    
        deleteScheduledJobs();
    
        for (Integer i = 0; i < 60; i+=5) {
            System.schedule('IKnock Lead Sync Batch - ' + i + ' Min', '0 ' + i + ' * * * ?', new IKnockLeadSyncScheduler());
        }

        return 'All jobs successfully scheduled';
    }
}