/**
 * Batch job is used to clean up the old Sync Records
 *
 * To execute this batch one time, you can use this script.
 * Database.executebatch(new SyncServiceSyncRecordsDeletionBatch('CreatedDate <= last_n_days:30'), 10000);
 */
public class SyncServiceSyncRecordsDeletionBatch implements Database.Batchable<Sync_Record__c>, CommonSchedulable, Database.Stateful {
    public String whereClause {get;set;}
    public App_Log__c appLog {get;set;}
    public Integer totalRecordsDeleted {get;set;}
    
    public SyncServiceSyncRecordsDeletionBatch() {
    }
    
    public SyncServiceSyncRecordsDeletionBatch(String whereClause) {
        this.whereClause = whereClause;
        appLog = Sf.appLogger.createDebug('SyncService', 'SyncRecordsDeletionBatch', '', '');
        appLog.Details__c = '';
    }
	
    public void setParameter(String key, String value) {
        //not used
    }
    
    public void setData(String data) {
        whereClause = data;
    }
    
    public List<Sync_Record__c> start(Database.BatchableContext bc) {
        List<User> users = null;
        String soql = 'select Id, Module__c, Action__c, Status__c, Sub_Status__c, Message__c from Sync_Record__c where ' + whereClause;

        logDebug('Constructed soql to fetch sync records to clean up [' + soql + ']');
        return Database.query(soql);
    }
    
    public void execute(Database.BatchableContext BC, List<Sync_Record__c> syncRecords){
        logDebug('Deleting ' + syncRecords.size() + ' sync records ' + String.valueOf(syncRecords));
        delete syncRecords;
    }
    
    public void finish(Database.BatchableContext BC){
        logDebug('Deleted total ' + totalRecordsDeleted + ' sync records');
        Sf.appLogger.log(appLog);
    }

    public void logDebug(String message) {
        appLog.Details__c += formatDateTime() + ' ' + message + '\n\n' ;
    }

    public String formatDateTime() {
        return DateTime.now().format('yyyy/MM/dd hh:mm:ss a z', 'America/Los_Angeles');
    }

}