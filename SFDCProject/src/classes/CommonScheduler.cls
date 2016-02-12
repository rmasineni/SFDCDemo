public interface CommonScheduler {
	Common_Scheduler__c markJobEligibleToRun(String jobName);
	Common_Scheduler__c runJob(String jobName);
	Common_Scheduler__c runJobAfterMins(String jobName, Decimal mins);
}