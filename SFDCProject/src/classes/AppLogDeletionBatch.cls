/**
 * Batch job is used to clean up the old Sync Records
 *
 * To execute this batch one time, you can use this script.
 * Database.executebatch(new AppLogDeletionBatch('CreatedDate <= last_n_days:30'), 10000);
 */
public class AppLogDeletionBatch implements Database.Batchable<App_Log__c>, CommonSchedulable, Database.Stateful {
    public String whereClause {get;set;}
    public App_Log__c appLog {get;set;}
    public Integer totalRecordsDeleted {get;set;}
    
    public AppLogDeletionBatch() {
    }
    
    public AppLogDeletionBatch(String whereClause) {
        this.whereClause = whereClause;
        appLog = Sf.appLogger.createDebug('AppLogger', 'AppLogDeletionBatch', '', '');
        appLog.Details__c = '';
    }
    
    public void setParameter(String key, String value) {
        //not used
    }
    
    public void setData(String data) {
        whereClause = data;
    }
    
    public List<App_Log__c> start(Database.BatchableContext bc) {
        List<User> users = null;
        String soql = 'select Id, Module__c, Action__c, Type__c, Message__c from App_Log__c where ' + whereClause;

        logDebug('Constructed soql to fetch app logs to clean up [' + soql + ']');
        return Database.query(soql);
    }
    
    public void execute(Database.BatchableContext BC, List<App_Log__c> records){
        logDebug('Deleting ' + records.size() + ' app logs ' + String.valueOf(records));
        delete records;
    }
    
    public void finish(Database.BatchableContext BC){
        logDebug('Deleted total ' + totalRecordsDeleted + ' app logs');
        Sf.appLogger.log(appLog);
    }

    public void logDebug(String message) {
        appLog.Details__c += formatDateTime() + ' ' + message + '\n\n' ;
    }

    public String formatDateTime() {
        return DateTime.now().format('yyyy/MM/dd hh:mm:ss a z', 'America/Los_Angeles');
    }
}