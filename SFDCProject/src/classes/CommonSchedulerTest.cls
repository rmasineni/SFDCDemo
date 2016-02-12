@IsTest
public class CommonSchedulerTest {
	
	public static CommonSchedulerImpl impl = new CommonSchedulerImpl();
    public static List<Queueable> jobInstances = new List<Queueable>();
    
    testmethod public static void testScheduleDeleteJobs() {
        
        Test.startTest();
		CommonSchedulerImpl.scheduleJobs();
        
        //Now check there are 12 scheduled jobs.
		List<CronTrigger> cronJobs = [SELECT Id FROM CronTrigger where CronJobDetailId in (SELECT Id FROM CronJobDetail where name like 'Common Scheduler%')];
        System.assertEquals(60, cronJobs.size());

        CommonSchedulerImpl.deleteJobs();
		cronJobs = [SELECT Id FROM CronTrigger where CronJobDetailId in (SELECT Id FROM CronJobDetail where name like 'Common Scheduler%')];
        System.assertEquals(0, cronJobs.size());
		Test.stopTest();
    }   
    
    testmethod public static void testCreateInstance() {
        Test.startTest();
        System.assertNotEquals(null, new CommonSchedulerImpl().createInstance('CommonSchedulerImpl'));
        try {
        	System.assertNotEquals(null, new CommonSchedulerImpl().createInstance('InvalidClass'));
            System.assert(false, 'Expected an exception but not thrown');
        } catch (BusinessException e) {
            //ignore
        }
        Test.stopTest();
    }
    
    testmethod public static void testScheduling() {
        //Even without any configuration, it should run fine.
        CommonSchedulerImpl scheduler = new CommonSchedulerImpl();
        
        scheduler.execute(null);
        
        Common_Scheduler__c setting = new Common_Scheduler__c();
        setting.Name = 'CommonSchedulerTestBatch';
        setting.Enabled__c = true;
        setting.Run_Frequency__c = 'Every Min';
        insert setting;
        
        scheduler.execute(null);
		
		//Check if setting is updated appropriately.
		setting = Common_Scheduler__c.getValues('CommonSchedulerTestBatch');
        System.assertNotEquals(null, setting.Last_Run_Time__c); //run date is not null
        System.assert(setting.Message__c.indexOf('job id ') >= 0, setting.Message__c); //Message is null
        
        //Execute a non-existing class so it should have error.
        setting = new Common_Scheduler__c();
        setting.Name = 'NonExistingClass';
        setting.Enabled__c = true;
        insert setting;
        
        scheduler.execute(null);
		setting = Common_Scheduler__c.getValues('NonExistingClass');
        System.assertEquals(null, setting.Last_Run_Time__c); //Run date is null
        System.assertNotEquals(null, setting.Message__c); //Message contains error message
    }
    
    testmethod public static void testQueueable() {
        Common_Scheduler__c setting = new Common_Scheduler__c();
        setting.Name = 'QueueTest';
        setting.Class__c = 'CommonSchedulerTest.CommonSchedulerTestQueue';
        setting.Enabled__c = true;
        setting.Parameters__c = 'foo=bar,bob=alice';
        setting.Run_Frequency__c = 'Every Min';
        insert setting;
        
        Test.startTest();
	        new CommonSchedulerImpl().execute(null);
        Test.stopTest();
        
        setting = Common_Scheduler__c.getAll().get('QueueTest');
        System.assertNotEquals(null, setting.Last_Run_Time__c);
    }
    
    testmethod public static void testEligibleToRun() {
        //This tests that if eligible to run is selected, then job will be run
        //even if it is not ready for time based on the cron trigger.
        Common_Scheduler__c setting = new Common_Scheduler__c();
        setting.Name = 'Test';
        setting.Class__c = 'CommonSchedulerTest.CommonSchedulerTestQueue';
        setting.Enabled__c = true;
        setting.Cron_Trigger__c = '0 0 25 * * * *';
        insert setting;
        
        Test.startTest();

        new CommonSchedulerImpl().execute(null);
        
        setting = Common_Scheduler__c.getAll().get('Test');
        System.assertEquals(null, setting.Last_Run_Time__c);
        
        setting.Eligible_To_Run__c = true;
        update setting;
        
        new CommonSchedulerImpl().execute(null);

        Test.stopTest();
        
        setting = Common_Scheduler__c.getAll().get('Test');
        System.assertNotEquals(null, setting.Last_Run_Time__c);
    }
    
    testmethod public static void testCronTrigger() {
        
        //Seconds Minutes Hours DayOfMonth Month DayOfWeek optional_year
        CommonSchedulerImpl scheduler = new CommonSchedulerImpl();
        
        System.assertEquals(false, scheduler.isTimeMatches('0 1 1 1 1 ? 1', 
			DateTime.newInstance(2013, 12, 11, 10, 9, 8)));

        System.assertEquals(false, scheduler.isTimeMatches('0 9 1 1 1 ? 1', 
			DateTime.newInstance(2013, 12, 11, 10, 9, 8)));

        System.assertEquals(false, scheduler.isTimeMatches('0 9 10 1 1 ? 1', 
			DateTime.newInstance(2013, 12, 11, 10, 9, 8)));

        System.assertEquals(false, scheduler.isTimeMatches('0 9 10 11 1 ? 1', 
			DateTime.newInstance(2013, 12, 11, 10, 9, 8)));

        System.assertEquals(false, scheduler.isTimeMatches('0 9 10 11 1 ? 1', 
			DateTime.newInstance(2013, 12, 11, 10, 9, 8)));

        System.assertEquals(false, scheduler.isTimeMatches('0 9 10 11 12 ? 1', 
			DateTime.newInstance(2013, 12, 11, 10, 9, 8)));

        System.assertEquals(true, scheduler.isTimeMatches('0 9 10 11 12 ? 2013', 
			DateTime.newInstance(2013, 12, 11, 10, 9, 8)));
        
        System.assertEquals(true, scheduler.isTimeMatches('0 9 10 11 12 ? *', 
			DateTime.newInstance(2013, 12, 11, 10, 9, 8)));
        
        System.assertEquals(true, scheduler.isTimeMatches('0 9 10 11 * ? *', 
			DateTime.newInstance(2013, 12, 11, 10, 9, 8)));

        System.assertEquals(true, scheduler.isTimeMatches('0 9 10 * * ? *', 
			DateTime.newInstance(2013, 12, 11, 10, 9, 8)));

        System.assertEquals(true, scheduler.isTimeMatches('0 9 * * * ? *', 
			DateTime.newInstance(2013, 12, 11, 10, 9, 8)));

        System.assertEquals(true, scheduler.isTimeMatches('0 * * * * ? *', 
			DateTime.newInstance(2013, 12, 11, 10, 9, 8)));

        System.assertEquals(true, scheduler.isTimeMatches('0 8-10 * * * ? *', 
			DateTime.newInstance(2013, 12, 11, 10, 9, 8)));

        System.assertEquals(true, scheduler.isTimeMatches('0 8,9,10 * * * ? *', 
			DateTime.newInstance(2013, 12, 11, 10, 9, 8)));
		
        System.assertEquals(false, scheduler.isTimeMatches(null, DateTime.now()));
        
        try {
            scheduler.isTimeMatches('0 8,9,10 * * * ? * extra', 
			DateTime.newInstance(2013, 12, 11, 10, 9, 8));
        } catch (BusinessException e) {
            //ignore
        }
    }
    
    testmethod public static void testRunJobAfterMins() {
        Common_Scheduler__c setting = new Common_Scheduler__c();
        setting.Name = 'Test';
        setting.Class__c = 'CommonSchedulerTest.CommonSchedulerTestQueue';
        setting.Enabled__c = false; //We will disable this job so we will not run by choice
        setting.Cron_Trigger__c = '0 0 25 * * * *';
        insert setting;
		
        impl.runJob('Test');
        impl.runJob('CommonSchedulerTest.CommonSchedulerTestQueue');
        System.assertEquals(true, Common_Scheduler__c.getValues('Test').Eligible_To_Run__c);

        impl.runJobAfterMins('Test', 5);
        System.assertNotEquals(null, Common_Scheduler__c.getValues('Test').Delay_Until_Time__c);
		
        //If we schedule a job without any delay, then if there is any delay, it should be deleted.
        impl.runJob('Test');
        System.assertEquals(null, Common_Scheduler__c.getValues('Test').Delay_Until_Time__c);
        
		Common_Scheduler__c job = impl.runJob('Not Exist a very very long job name and it should truncate to 38 chars but put rest in class field');
        System.assertEquals('Not Exist a very very long job name an', job.name);
        System.assertEquals('Not Exist a very very long job name and it should truncate to 38 chars but put rest in class field', job.Class__c);
    }
    
    testmethod public static void testCronPattern() {
        System.assertEquals('0 * * * * * *', impl.getCronPattern(new Common_Scheduler__c(Run_Frequency__c='Every Min')));
        System.assertEquals('0 0,5,10,15,20,25,30,35,40,45,50,55 * * * * *', impl.getCronPattern(new Common_Scheduler__c(Run_Frequency__c='Every 5 Mins')));
        System.assertEquals('0 0,10,20,30,40,50 * * * * *', impl.getCronPattern(new Common_Scheduler__c(Run_Frequency__c='Every 10 Mins')));
        System.assertEquals('0 0,15,30,45 * * * * *', impl.getCronPattern(new Common_Scheduler__c(Run_Frequency__c='Every 15 Mins')));
        System.assertEquals('0 0,30 * * * * *', impl.getCronPattern(new Common_Scheduler__c(Run_Frequency__c='Every 30 Mins')));
        System.assertEquals('0 0 * * * * *', impl.getCronPattern(new Common_Scheduler__c(Run_Frequency__c='Every Hr')));
        System.assertEquals('0 0 0,2,4,6,8,10,12,14,16,18,20,22 * * * *', impl.getCronPattern(new Common_Scheduler__c(Run_Frequency__c='Every 2 Hrs')));
        System.assertEquals('0 0 0,4,8,12,16,20 * * * *', impl.getCronPattern(new Common_Scheduler__c(Run_Frequency__c='Every 4 Hrs')));
        System.assertEquals('0 0 0,6,12,18 * * * *', impl.getCronPattern(new Common_Scheduler__c(Run_Frequency__c='Every 6 Hrs')));
        System.assertEquals('0 0 0,12 * * * *', impl.getCronPattern(new Common_Scheduler__c(Run_Frequency__c='Every 12 Hrs')));
        System.assertEquals('0 0 0 * * * *', impl.getCronPattern(new Common_Scheduler__c(Run_Frequency__c='Every Day')));
        System.assertEquals('0 0 0 SAT * * *', impl.getCronPattern(new Common_Scheduler__c(Run_Frequency__c='Every Week')));
        System.assertEquals('* * * * * * *', impl.getCronPattern(new Common_Scheduler__c(Run_Frequency__c='Cron', Cron_Trigger__c='* * * * * * *')));
        System.assertEquals(null, impl.getCronPattern(new Common_Scheduler__c(Run_Frequency__c='On Demand')));
        
        try {
            impl.getCronPattern(new Common_Scheduler__c());
            System.assert(false, 'Should have thrown exception');
        } catch (Exception e) {
            //ignore
        }
    }
    
    testmethod public static void testJoin() {
        System.assertEquals(null, impl.join(null, ''));
        System.assertEquals(null, impl.join(new String[]{null, null}, null));
        System.assertEquals(null, impl.join(new String[]{null, null}, ''));
        System.assertEquals('abc123', impl.join(new String[]{'abc', '123'}, ''));
        System.assertEquals('abc ; 123', impl.join(new String[]{'abc', '123'}, ' ; '));
        System.assertEquals('abc', impl.join(new String[]{'abc'}, ' ; '));
    }
    
    testmethod public static void testCommonBatchable() {
        Common_Scheduler__c setting = new Common_Scheduler__c();
        setting.Name = 'Test';
        setting.Class__c = 'CommonSchedulerTest.CommonSchedulerTestQueueBatchable';
        setting.Enabled__c = true;
        setting.Batch_Job_Scope__c = 1;
        insert setting;

        List<List<Id>> batches = new List<List<Id>>();
        batches.add(new Id[]{UserInfo.getUserId()});
        BaseClass.testParams.put('CommonBatchableTestJobBatches', batches);
        
        jobInstances.clear();
        
        Test.startTest();
        impl.runJob(setting);
        Test.stopTest();
        
        System.assert(setting.Message__c.indexOf('Started 1 instances of Test') >= 0);
    }
    
    testmethod public static void testDelayUntilRun() {
        Common_Scheduler__c setting = new Common_Scheduler__c();
        setting.Name = 'Test';
        setting.Class__c = 'CommonSchedulerTest.CommonSchedulerTestQueue';
        setting.Enabled__c = true;
        setting.Batch_Job_Scope__c = 1;
        setting.Delay_Until_Time__c = DateTime.now().addMinutes(2);
        insert setting;

        impl.runJob(setting);
        System.assert( setting.Message__c.indexOf('not elapsed') >= 0, 'Expected that message has "not elapsed" text');
    }
    
    testmethod public static void testAbortJobs() {
        
        //run a job first and then try to abort it.
        Test.startTest();
        System.enqueueJob(new CommonSchedulerTestQueueBatchable());
        Test.stopTest();
        
        Common_Scheduler__c setting = new Common_Scheduler__c();
        setting.Name = 'Test';
        setting.Class__c = 'CommonSchedulerTest.CommonSchedulerTestQueue';
        setting.Enabled__c = true;
        setting.Abort_After_mins__c = 1;
        setting.Delay_Until_Time__c = DateTime.now().addMinutes(2);
        insert setting;
		
        Sf.settingsService.setString('AdminNotificationEmails', 'test@yopmail.com');
        
        List<AsyncApexJob> jobs = [SELECT 
                	Id,
					ApexClass.Name,
                	CreatedDate
                FROM AsyncApexJob 
       	];
        System.assert(!jobs.isEmpty());
        
        impl.abortJobsIfRequired(setting, jobs, DateTime.now().addMinutes(30));
    }
    
    public class CommonSchedulerTestQueue implements Queueable, CommonSchedulable {
        
        public void execute(QueueableContext ctx) {
            CommonSchedulerTest.jobInstances.add(this);
        }
        
        public void setParameter(String key, String value) {
            //ignore
        }
        public void setData(String data) {
            //ignore
        }
    }
    
    public class CommonSchedulerTestQueueBatchable implements Queueable, CommonSchedulable, CommonBatchable {
        public List<Id> batch {get;set;}
        
        public void execute(QueueableContext ctx) {
            CommonSchedulerTest.jobInstances.add(this);
        }
        
        public void setParameter(String key, String value) {
            //ignore
        }
        public void setData(String data) {
            //ignore
        }
        
        public List<List<Id>> getBatches(Integer max) {
            return (List<List<Id>> ) BaseClass.testParams.get('CommonBatchableTestJobBatches');
        }
        
        public void setBatch(List<Id> batch) {
            this.batch = batch;
        }
    }
 	
    testmethod public static void testMarkJobEligibleToRun() {
        Common_Scheduler__c job = new Common_Scheduler__c();
        job.Name = 'Test';
        job.Eligible_To_Run__c = false;
        insert job;
        
        job = impl.markJobEligibleToRun('Test');
        System.assertEquals(true, job.Eligible_To_Run__c);
    }
}