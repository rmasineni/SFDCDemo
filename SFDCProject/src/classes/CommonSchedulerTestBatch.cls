/**
 * Batch job used in testing the CommonScheduler
 */
public class CommonSchedulerTestBatch implements Database.Batchable<SObject> {
    public Iterable<SObject> start(Database.BatchableContext bc) {
        return [select id from user limit 1];
    }
    
    public void execute(Database.BatchableContext BC, List<User> users){
        //nothing
    }
    
    public void finish(Database.BatchableContext BC){
        //nothing
    }
    
}