global class wfValidateTasks_Scheduler implements Schedulable{

    public wfValidateTasks_Scheduler(){
                
    }
    
    global void execute(SchedulableContext SCtx) {  
        wfValidateTasksBatch batchObj = new wfValidateTasksBatch();
        id batchinstanceid = database.executeBatch(batchObj,10);  
    }
}