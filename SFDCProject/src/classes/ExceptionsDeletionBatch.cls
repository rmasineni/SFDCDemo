/**
 * System.scheduleBatch(new ExceptionsDeletionBatch(), 'Exceptions Deletion Batch', 0, 10000);
 */
public class ExceptionsDeletionBatch implements Database.Batchable<SObject>, Schedulable {
	
    private Integer daysOld;
    public ExceptionsDeletionBatch() {
        this(Sf.settingsService.getInteger('ExceptionsDeletionDeleteOlderThanDays', 30));
    }
    
    public ExceptionsDeletionBatch(Integer daysOld) {
        this.daysOld = daysOld;
    }

    public void execute(SchedulableContext sc) {
    	Database.executebatch(this, 9000); //Batch size of 9000 records per iteration as max dml is 10000
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([select id from Exception__c where CreatedDate < :DateTime.now().addDays(-daysOld)]);
    }

    public void execute(Database.BatchableContext BC, List<Exception__c> exceptions){
        delete exceptions;
    }
    
    public void finish(Database.BatchableContext BC){
    }
}