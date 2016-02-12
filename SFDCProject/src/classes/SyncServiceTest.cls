@IsTest
public class SyncServiceTest {
   	public static TestJob instance = null;

    testmethod static public void testSyncService() {
        Account act = new Account(Name='Foo Bar', External_Id__c='ExternalId');
        insert act;

        List<Sync_Record__c> syncRecords = Sf.syncService.createSyncRecords('Test', 'Job', new Sobject[]{act});
        syncRecords = Sf.syncService.createSyncRecords('Test', 'Job', new Sobject[]{act}, 'External_Id__c');
        syncRecords = Sf.syncService.insertSyncRecords('Test', 'Job', new Sobject[]{act});
        
       	System.assertEquals(1, syncRecords.size());
       	System.assertEquals('Account', syncRecords.get(0).Sobject__c);
       	System.assertEquals(act.id, syncRecords.get(0).Record_Id__c);
       	System.assertEquals('Test', syncRecords.get(0).Module__c);
       	System.assertEquals('Job', syncRecords.get(0).Action__c);
       	System.assertEquals(null, syncRecords.get(0).Type__c);
       	System.assertEquals('To Be Synced', syncRecords.get(0).Status__c);
       	System.assertEquals(0, syncRecords.get(0).Attempts__c);
        
        syncRecords = Sf.syncService.insertSyncRecords('Test', 'Job', new Sobject[]{act}, 'External_Id__c');
        syncRecords = Sf.syncService.insertSyncRecords('Test', 'Job', 'Insert', new Sobject[]{act}, 'External_Id__c');
       	System.assertEquals('Insert', syncRecords.get(0).Type__c);
       	System.assertEquals('ExternalId', syncRecords.get(0).External_Id__c);
    }
    
    testmethod static public void testSyncJobInfo() {
        Account act = new Account(Name='Foo Bar', External_Id__c='ExternalId');
        insert act;

        SyncJobInfo job = new SyncJobInfo();
        job.syncRecords = Sf.syncService.createSyncRecords('Test', 'Job', new Sobject[]{act});
        
        try {
            job.currentBatch();
            System.assert(false, 'Should have thrown exception');
        } catch (Exception e) {
            //ignore
        }
        
        Sync_Record__c syncRecord = job.syncRecords.get(0);
        job.setBatch(syncRecord);
        job.setBatch(job.syncRecords);
        job.setBatch(syncRecord.Record_Id__c);
		System.assertEquals(null, job.syncRecords.get(0).Delay_Until_Time__c);
		System.assertNotEquals(null, job.delayUntilMins(1).syncRecords.get(0).Delay_Until_Time__c);

        System.assertEquals(syncRecord.id, job.currentBatch().get(0).id);
        System.assertEquals(job.syncRecords.get(0).id, job.syncRecordsMap.get(act.id).get(0).id);
        
        job.syncSuccess();
		System.assertEquals('Sync Success', syncRecord.Status__c);
        
        job.syncNotApplicable();
		System.assertEquals('Sync Not Applicable', syncRecord.Status__c);
        
        job.syncNotApplicable('Some Sub Status');
		System.assertEquals('Sync Not Applicable', syncRecord.Status__c);
        
        job.syncError();
		System.assertEquals('Sync Error', syncRecord.Status__c);
        //When we sync error, record will not picked up for further processing for at least 5 mins.
        System.assertNotEquals(null, syncRecord.Delay_Until_Time__c); 
        
        job.syncError('Some Message');
		System.assertEquals('Some Message', syncRecord.Message__c);
        
        job.setSubStatus('Sub Status');
		System.assertEquals('Sub Status', syncRecord.Sub_Status__c);
        
        job.syncNotApplicable('Some Sub Status');
		System.assertEquals('Some Sub Status', syncRecord.Sub_Status__c);
        
        job.syncFailed('Some Sub Status');
		System.assertEquals('Sync Failed', syncRecord.Status__c);
		System.assertEquals('Some Sub Status', syncRecord.Sub_Status__c);
        
		System.assertEquals(act.id, job.getRecordIds().get(0));
		System.assertEquals(1, job.getRecordIds().size());
        
        job.setExternalId('Some External Id');
		System.assertEquals('Some External Id', syncRecord.External_Id__c);
        
        job.handleException(new SystemException('Test Message'));
        System.assertEquals('Sync Error', syncRecord.Status__c);
        System.assertEquals('SystemException:[]: Test Message', syncRecord.Message__c);

        job.markRecordsForSourceDeletes(new Map<Id, Sobject>());
		System.assertEquals('Sync Not Applicable', syncRecord.Status__c);
		System.assertEquals('Record Deleted', syncRecord.Sub_Status__c);
        
        //Testing setting inserts, deletes and updates
        job.setStats(1, 2, 3);
        System.assertEquals(1, syncRecord.Inserts__c);
        System.assertEquals(2, syncRecord.Updates__c);
        System.assertEquals(3, syncRecord.Deletes__c);
        
        job.setResponsePayload('response payload');
        System.assertEquals('response payload', syncRecord.Response_Payload__c);
    }
    
    testmethod public static void testBaseSyncJob() {
        //This should just return without much.
        new TestJob().execute();
		System.assertEquals(null, SyncServiceTest.instance);
        
        Account act = new Account(Name='Foo Bar', External_Id__c='ExternalId');
        insert act;

        Sf.syncService.insertSyncRecords('Test', 'Job', new Sobject[]{act});
        new TestJob().execute();
		System.assertNotEquals(null, SyncServiceTest.instance);
    }
    
    testmethod public static void testBaseSyncJobBatching() {
		
        //Without any sync records, batches should be zero
        System.assertEquals(0, new TestJob(4).getBatches(1).size());

        insert new Sync_Record__c(Module__c='Test', Action__c='Job', Status__c='To Be Synced');
        insert new Sync_Record__c(Module__c='Test', Action__c='Job', Status__c='To Be Synced');
        insert new Sync_Record__c(Module__c='Test', Action__c='Job', Status__c='To Be Synced');
        insert new Sync_Record__c(Module__c='Test', Action__c='Job', Status__c='To Be Synced');
        
        System.assertEquals(1, new TestJob(4).getBatches(100).size());
        System.assertEquals(2, new TestJob(3).getBatches(100).size());
        System.assertEquals(2, new TestJob(2).getBatches(100).size());
        System.assertEquals(4, new TestJob(1).getBatches(100).size());
        System.assertEquals(2, new TestJob(1).getBatches(2).size());
        
        TestJob job = new TestJob(1);
        List<List<Id>> batches = job.getBatches(100);
       	job.setBatch(batches.get(0));
        System.assertEquals(1, job.syncRecordIds.size());
        
        //Tests the exception throwing
        job.throwError = true;
        SyncJobInfo info = job.execute();
        System.assertEquals('Sync Error', info.syncRecords.get(0).Status__c);
    }
	    
    testmethod public static void testBaseSyncJobBatchingBySourceRecords() {
		
        //Without any sync records, batches should be zero
        System.assertEquals(0, new TestJob(4, true).getBatches(1).size());

        insert new Sync_Record__c(Module__c='Test', Action__c='Job', Status__c='To Be Synced', Record_Id__c='Record1');
        insert new Sync_Record__c(Module__c='Test', Action__c='Job', Status__c='To Be Synced', Record_Id__c='Record2');
        insert new Sync_Record__c(Module__c='Test', Action__c='Job', Status__c='To Be Synced', Record_Id__c='Record2');
        insert new Sync_Record__c(Module__c='Test', Action__c='Job', Status__c='To Be Synced', Record_Id__c='Record3');
        insert new Sync_Record__c(Module__c='Test', Action__c='Job', Status__c='To Be Synced', Record_Id__c='Record3');
        insert new Sync_Record__c(Module__c='Test', Action__c='Job', Status__c='To Be Synced', Record_Id__c='Record3');
        
        System.assertEquals(3, new TestJob(4, true).getBatches(100).size());
        System.assertEquals(3, new TestJob(3, true).getBatches(100).size());
        System.assertEquals(3, new TestJob(2, true).getBatches(100).size());
        System.assertEquals(3, new TestJob(1, true).getBatches(100).size());
        System.assertEquals(1, new TestJob(1, true).getBatches(1).size());
        
        //It should contain two batches for two users. first user with 3 sync records and 2nd user with one sync record
        System.assertEquals(1, new TestJob(4, true).getBatches(100).get(0).size());
        System.assertEquals(2, new TestJob(4, true).getBatches(100).get(1).size());
        System.assertEquals(3, new TestJob(4, true).getBatches(100).get(2).size());

        System.assertEquals(1, new TestJob(1, true).getBatches(100).get(0).size());
        System.assertEquals(1, new TestJob(1, true).getBatches(100).get(1).size());
        System.assertEquals(1, new TestJob(1, true).getBatches(100).get(2).size());
    }

    testmethod public static void testCreateSoql() {
        TestJob job = new TestJob();

        //By default we pick errors.
        System.assert(job.createSoql().indexOf('Status_SyncError') >= 0);
        
        //If we set to false, we should not pick them.
		job.includeErrors = false;
        System.assert(job.createSoql().indexOf('Status_SyncError') < 0);
        
        //If we specify sync record ids, then we should pick only those.
        job.syncRecordIds = new Id[]{'01p60000000bxLt'};
        System.assert(job.createSoql().indexOf('Id in :syncRecordIds') >= 0);
    }
    
    public class TestJob extends BaseSyncJob {
        public Boolean throwError {get;set;}
        
        public TestJob(Integer queryLimit) {
            super('Test', 'Job');
            this.maxSyncRecordsPerBatch = queryLimit;
        }
        public TestJob(Integer queryLimit, Boolean batchBySourceRecords) {
            super('Test', 'Job');
            this.maxSyncRecordsPerBatch = queryLimit;
            this.groupBatchesBySourceRecords = batchBySourceRecords;
        }        
        public TestJob() {
            super('Test', 'Job');
            maxSyncRecordsPerBatch = 2;
        }
        override public void execute(SyncJobInfo job) {
            if (throwError != null && throwError) {
                throw new SystemException();
            }
            
           	SyncServiceTest.instance = this;
            job.setBatch(job.syncRecords);
            job.syncSuccess();
        }
    }
}