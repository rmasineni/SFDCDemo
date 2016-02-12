global class AccountBulkUpdate_Scheduler implements Schedulable{

    public AccountBulkUpdate_Scheduler(){
                
    }
    
    global void execute(SchedulableContext SCtx) {  
        AccountBulkUpdateBatch batchObj = new AccountBulkUpdateBatch();
        id batchinstanceid = database.executeBatch(batchObj,10);  
    }
    
    public static void startAccountBulkUpdate_Scheduler(){
        System.schedule('Account BulkUpdate Status - 0', '0 5 * * * ? ', new AccountBulkUpdate_Scheduler());
    }
}