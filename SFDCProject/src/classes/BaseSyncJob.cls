public abstract class BaseSyncJob extends BaseClass implements Queueable, Database.AllowsCallouts {

    public static final Integer GroupByRecordIdsQueryLimit = Sf.settingsService.getInteger('GroupByRecordIdsQueryLimit', 1000);
    public List<Id> syncRecordIds {get;set;}
    public Boolean includeErrors {get;set;}
    public Integer maxErrorAttempts {get;set;}
    public String module {get;set;}
    public String action {get;set;}
    public SyncJobInfo jobInfo {get;set;}
	
	//Indicates the maximum sync records allowed per batch.    
    public Integer maxSyncRecordsPerBatch {get;set;} 
    
    /**
     * When we want to batch, this will ensure all same record ids are not put across different
     * batches. This way, one record is alwsys processed in one job rather than across jobs.
     */
    public Boolean groupBatchesBySourceRecords {get;set;}

	/**
	 * Indicates if we should mark the job to run after successful execution of previous batch. This
	 * flag is not checked, if this job didn't process any sync records.
	 */    
    public Boolean runJobAgain {get;set;}
    
    /**
     * This is the job name as configured in the common scheduler.
     */
    public String jobName {get;set;}
    
    public BaseSyncJob(List<Id> syncRecords) {
        throw new BusinessException('The constructor which takes just sync record ids is deprecated. Please use version which takes Module, Action along with ids');
    }

    public BaseSyncJob(String module, String action) {
        this(module, action, null, null, null);
    }
    
    public BaseSyncJob(String module, String action, String jobName) {
        this(module, action, jobName, null, null);
    }

    public BaseSyncJob(String module, String action, String jobName, List<Id> syncRecordIds) {
        this(module, action, jobName, null, syncRecordIds);
    }
    
    public BaseSyncJob(String module, String action, String jobName, Integer maxSyncRecordsPerBatch) {
        this(module, action, jobName, maxSyncRecordsPerBatch, null);
    }
    
    public BaseSyncJob(String module, String action, String jobName, Integer maxSyncRecordsPerBatch, List<Id> syncRecordIds) {
        this.module = module;
        this.action = action;
        this.jobName = jobName;
        this.includeErrors = true;
		this.syncRecordIds = syncRecordIds;
        this.groupBatchesBySourceRecords = false;
        this.runJobAgain = false;
        this.maxSyncRecordsPerBatch = (Integer) firstNonNull(maxSyncRecordsPerBatch, Sf.settingsService.getInteger('SyncServiceMaxSyncRecordsPerBatch', 250));

        //1 initial try + 3 retries = 4
        this.maxErrorAttempts = Sf.settingsService.getInteger('SyncServiceMaxErrorAttempts', 4);
    }

    public SyncJobInfo execute() {
        execute((QueueableContext) null);
        return jobInfo;
    }

    public void execute(QueueableContext context) {
        jobInfo = new SyncJobInfo();
        
        try {
            
            List<Sync_Record__c> syncRecords = querySyncRecords();
            
            if (syncRecords.isEmpty()) {
                info('There are no sync records pending to be processed for module=' + module + ', action=' + action);
                return;
            }

            jobInfo.syncRecords = syncRecords;
            jobInfo.module = module;
            jobInfo.action = action;
            
            System.debug('Executing sync job ' + jobInfo);
            
            execute(jobInfo);
            
            System.debug('Completing executing the job ' + jobInfo.syncRecords);
            
        } catch (Exception e) {
            if (!jobInfo.syncRecords.isEmpty()) {
	            jobInfo.setBatch(jobInfo.syncRecords).handleException(e);
            } else {
                throw e;
            }
        }
		
		Map<Id, Sobject> syncRecordsMap = getIdMap(jobInfo.syncRecords);
        List<App_Log__c> appLogs = jobInfo.appLogsMap.values();
        if (!appLogs.isEmpty()) {
            
            //We need to normalize the app log records to make sure the detail fields
            //lengths are appropriate.
            for (App_Log__c appLog : appLogs) {
                Sf.appLogger.processFields(appLog);
            }
            
			DbChangesWoSharing.save(appLogs);
		
			//Once we create the app logs, we will need to set those ids into corresponding
			//sync records we can navigate to them.            
            for (String syncRecordId : jobInfo.appLogsMap.keyset()) {
				syncRecordsMap.get(syncRecordId).put('App_Log__c', jobInfo.appLogsMap.get(syncRecordId).id);
            }
        }

        DbChangesWoSharing.save(jobInfo.syncRecords);
        
        if (runJobAgain && jobName != null) {
            
            //This will mark the job to be eligible for run again.
            try {
	            Sf.commonScheduler.markJobEligibleToRun(jobName);
            } catch (Exception e) {
				System.debug('Exception while marking the job as eligible to run ' + jobName + ' ' + getExceptionDetails(e));                
            }
        }
    }
    
    public virtual List<Sync_Record__c> querySyncRecords() {
        
        String soql = createSoql() + ' limit ' + maxSyncRecordsPerBatch + ' for update';
        info('Executing soql to query sync records is ' + soql);
        
        DateTime currentDateTime = DateTime.now();
        List<Sync_Record__c> syncRecords = Database.query(soql);
        
        info('Found ' + syncRecords.size() + ' sync records for processing ' + syncRecords);
        
        return syncRecords;
    }
    
    public String createSoql() {
        List<String> fields = new String[]{
            'Id',
            'Record_Id__c',
            'Status__c',
            'Type__c',
            'Sub_Type__c',
            'Module__c',
            'Action__c',
            'Sobject__c',
            'External_Id__c',
            'Value1__c',
            'Value2__c',
            'Value3__c',
            'Request_Payload__c',
            'Response_Payload__c',
            'OwnerId',
            'Attempts__c'
        };
        
        List<String> whereClauses = new String[]{
            'Module__c = :module',
            'Action__c = :action',
            '(Delay_Until_Time__c = null or Delay_Until_Time__c <= :currentDateTime)'
        };
            
		if (includeErrors) {
    		whereClauses.add('(Status__c = :Status_ToBeSynced' 
                                 + ' or (Status__c = :Status_SyncError and Attempts__c < :maxErrorAttempts))');
        } else {
            whereClauses.add('Status__c = :Status_ToBeSynced');
        }
        
        if (syncRecordIds != null && !syncRecordIds.isEmpty()) {
	        whereClauses.add('Id in :syncRecordIds');
        }
        
        return createSoql(fields, 'Sync_Record__c', whereClauses);
    }
    
    /**
     * Returns the batches of sync record ids which can be used to kick off multiple instances of this
     * job.
     */
    public List<List<Id>> getBatches(Integer maxBatches) {
        String soql = createSoql() + ' order by CreatedDate';
        
        if (groupBatchesBySourceRecords) {
            //If we are grouping by source records, then we don't know how many sync records would fit
            //the max batches so we will just query fixed records.
            soql += ' limit ' + GroupByRecordIdsQueryLimit;
        } else {
            
            //If we are not grouping, we know exactly how many sync records we need.
            soql += ' limit ' + (maxSyncRecordsPerBatch * maxBatches);
        }
        
        info('Created soql to fetch the batches ' + soql);
		
		//Current time is used in soql        
        DateTime currentDateTime = DateTime.now();
        List<Sync_Record__c> syncRecords = DataBase.query(soql);
        
        List<List<Id>> syncRecordIdBatches = new List<List<Id>>();
        //If we need to group record ids, then will group first and then take max batches of them.
        //if not, will just take max batches of them and create batches.
        if (groupBatchesBySourceRecords) {
            Map<String, List<Id>> batchesBySourceRecords = new Map<String, List<Id>>();
            for (Sync_Record__c syncRecord : syncRecords) {
                List<Id> syncRecordIds = batchesBySourceRecords.get(syncRecord.Record_Id__c);
                if (syncRecordIds == null) {
                    syncRecordIds = new List<Id>();
                    batchesBySourceRecords.put(syncRecord.Record_Id__c, syncRecordIds);
                }
                
                if (syncRecordIds.size() < maxSyncRecordsPerBatch) {
	                syncRecordIds.add(syncRecord.id);
                }
            }

            for (String recordId : batchesBySourceRecords.keySet()) {
            	syncRecordIdBatches.add(batchesBySourceRecords.get(recordId));
                
                if (syncRecordIdBatches.size() >= maxBatches) {
                    break;
                }
            }
        } else {
            List<List<Sobject>> syncRecordsSplits = splitListBySize(syncRecords, maxSyncRecordsPerBatch);
            for (List<Sobject> syncRecordsSplit : syncRecordsSplits) {
                syncRecordIdBatches.add(getUniqueIdList(syncRecordsSplit));
            }
        }
        
        return syncRecordIdBatches;
    }
    
    public void setBatch(List<Id> syncRecordIds) {
        this.syncRecordIds = syncRecordIds;
    }
    
    public abstract void execute(SyncJobInfo syncJob);
}