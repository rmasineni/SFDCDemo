public class SyncJobInfo {
    
    private static final BaseClass utils = new BaseClass();
	public static final Integer SyncErrorDelayMins = Sf.settingsService.getInteger('SyncServiceSyncErrorDelayMins', 5);
    public Map<String, App_Log__c> appLogsMap {get;set;}
    
    /**
     * List of all sync records that are fetched in this execution. This could be upto 1000 records.
     */
    public List<Sync_Record__c> syncRecords {get;set {
        this.syncRecords = value;
		this.syncRecordsMap = utils.groupBy(this.syncRecords, 'Record_Id__c');
    }}
    
    /**
     * If sync job batch is not set yet, and if code logs anything they will be stored here.
     * When app log is created, these messages will be appended.
     */
    List<String> defaultLogEntries = new List<String>();
    
    /**
     * Sync Records map by corresponding source record ids. If you notice, there could be more than
     * one sync records for same source record ids.
     */
    public Map<String, List<Sync_Record__c>> syncRecordsMap {get;set;}
    
    /**
     * We always process one or more sync records at a time. This set of records indicates
     * the records being processed in this batch. This set of records is the one, we will
     * update status of, add log entries to etc., It is very important that this batch
     * is set correctly otherwise, we will be setting status to wrong sync records.
     */
    public List<Sync_Record__c> syncRecordsBatch {get;set;}
    
    /**
     * This is the app log record for current batch. All the log statements added durig processing of current batch
     * will be added to this.
     */
    public App_Log__c appLogBatch {get;set;}

    public String module {get;set;}
    public String action {get;set;}
    
    public SyncJobInfo() {
        syncRecords = new List<Sync_Record__c>();
        syncRecordsMap = new Map<String, List<Sync_Record__c>>();
        appLogsMap = new Map<String, App_Log__c>();
    }
    
    public SyncJobInfo syncSuccess() {
        setStatus(BaseClass.Status_SyncSuccess);
        return this;
    }
    
    public SyncJobInfo setSubStatus(String subStatus) {
        log('Setting sub status to ' + subStatus);
        setValue('Sub_Status__c', subStatus);
        return this;
    }

    public SyncJobInfo syncError() {
        return syncError(null);
    }

    public SyncJobInfo syncError(String message) {
        setStatus(BaseClass.Status_SyncError, null, message);
        delayUntilMins(SyncErrorDelayMins);
        return this;
    }

    public SyncJobInfo syncNotApplicable() {
        setStatus(BaseClass.Status_SyncNotApplicable);
        return this;
    }

    public SyncJobInfo syncNotApplicable(String subStatus) {
        setStatus(BaseClass.Status_SyncNotApplicable, subStatus, null);
        return this;
    }

    public SyncJobInfo syncFailed(String subStatus) {
        setStatus('Sync Failed', subStatus, null);
        return this;
    }

    public SyncJobInfo setStatus(String status) {
        setStatus(status, null, null);
        return this;
    }
    
    public SyncJobInfo setStatus(String status, String subStatus, String message) {
        log('Setting status=' + status + ', subStatus=' + subStatus);
        setValue('Status__c', status, 'Sub_Status__c', subStatus, 'Message__c', (message==null?null:new BaseClass().trim(message, 255)));
        return this;
    }

    public SyncJobInfo delayUntilMins(Decimal mins) {
    	DateTime dt = DateTime.now().addSeconds(Integer.valueOf(mins * 60));
        return delayUntil(dt);
    }

    public SyncJobInfo delayUntil(DateTime dateTimeVal) {
        setValue('Delay_Until_Time__c', dateTimeVal);
        return this;
    }

    public SyncJobInfo handleException(Exception e) {
        setStatus(BaseClass.Status_SyncError, null, String.valueOf(e));
        delayUntilMins(SyncErrorDelayMins);
		Sf.appLogger.processFields(appLogBatch, e);
        
        return this;
    }

    public List<String> getRecordIds() {
        return new List<String>(syncRecordsMap.keySet());
    }
    
    public SyncJobInfo setExternalId(String externalId) {
        setValue('External_Id__c', externalId);
        return this;
    }

    public SyncJobInfo setBatch(String recordId) {
        List<Sync_Record__c> syncRecordsBatch = syncRecordsMap.get(recordId);
		
        if (syncRecordsBatch == null) {
            log('Sync Records Batch is null for record ' + recordId  + ' hence initializing with empty list');
            syncRecordsBatch = new List<Sync_Record__c>();
        }
        
        setBatch(syncRecordsBatch);
        return this;
    }

    public SyncJobInfo setBatch(Sync_Record__c syncRecord) {
        setBatch(new Sync_Record__c[]{syncRecord});
        return this;
    }

    public SyncJobInfo setBatch(List<Sync_Record__c> syncRecordsBatch) {
        this.syncRecordsBatch = syncRecordsBatch;

        appLogBatch = new App_Log__c();
        appLogBatch.Module__c = module;
        appLogBatch.Action__c = action;
        
        if (!defaultLogEntries.isEmpty()) {
            appLogBatch.Details__c = utils.join(defaultLogEntries, '\n\n');
            defaultLogEntries.clear();
        } else {
            //We will append to this so initializing with empty will not print 'null' at top of the log file
            appLogBatch.Details__c  = '';
        }
        
        if (!syncRecordsBatch.isEmpty()) {
            appLogBatch.Record_Id__c = syncRecordsBatch.get(0).Record_Id__c;
            appLogBatch.External_Id__c = syncRecordsBatch.get(0).External_Id__c;
            appLogBatch.Value1__c = syncRecordsBatch.get(0).Value1__c;
            appLogBatch.Value2__c = syncRecordsBatch.get(0).Value2__c;
            appLogBatch.Value3__c = syncRecordsBatch.get(0).Value3__c;
            appLogBatch.Sync_Record__c = syncRecordsBatch.get(0).id;
            
            for (Sync_Record__c syncRecord : syncRecordsBatch) {
                appLogsMap.put(syncRecord.id, appLogBatch);
                syncRecord.Attempts__c = syncRecord.Attempts__c==null?1:syncRecord.Attempts__c+1;
            }
        }
        
        log('Processing batch of '  + syncRecordsBatch.size() + ' sync records. Sync Records: ' + syncRecordsBatch);
        return this;
    }
    
    public List<Sync_Record__c> currentBatch() {
        if (syncRecordsBatch == null || syncRecordsBatch.isEmpty()) {
            throw new BusinessException('Sync Records batch is not set before retrieving it');
        }
        
        return syncRecordsBatch;
    }
    
    public void setStats(Integer inserts, Integer updates, Integer deletes) {
    	setValue('Inserts__c', inserts, 'Updates__c', updates, 'Deletes__c', deletes);  
    } 
    
    public SyncJobinfo setValue(String field, Object value) {
        for (Sync_Record__c syncRecord : currentBatch()) {
            syncRecord.put(field, value);
        }
        
        return this;
    }

    public SyncJobInfo setValue(String field1, Object value1, String field2, Object value2, String field3, Object value3) {
        for (Sync_Record__c syncRecord : currentBatch()) {
            syncRecord.put(field1, value1);
            syncRecord.put(field2, value2);
            syncRecord.put(field3, value3);            
        }
        
        return this;
    }

    public SyncJobInfo log(String message) {
		System.debug(System.LoggingLevel.INFO, message);
        
        if (appLogBatch == null) {
            defaultLogEntries.add(DateTime.now() + ': ' + message);
        } else {
	        appLogBatch.Details__c += '\n\n' + DateTime.now() + ': ' + message;
        }
        return this;
    }
    
    /**
     * Sometimes by the time we pick up the sync record for processing, source record
     * may have been deleted. In such cases, processing job would send the list of
     * sobjects it retrieved and will mark it as deleted if it not found.
     */
    public SyncJobInfo markRecordsForSourceDeletes(Map<Id, SObject> sobjMap) {
        for (Sync_Record__c syncRecord : syncRecords) {
            if (!sobjMap.containsKey(syncRecord.Record_Id__c)) {
                setBatch(syncRecord).syncNotApplicable('Record Deleted');
            }
        }
        
        return this;
    }
    
    public void setResponsePayload(String payload) {
        for (Sync_Record__c syncRecord : currentBatch()) {
            syncRecord.Response_Payload__c = payload;
        }
    }
}