global class wfOnHoldUpdate_Scheduler implements Schedulable{

    public wfOnHoldUpdate_Scheduler(){
                
    }
    
    global void execute(SchedulableContext SCtx) {  
        wfOnHoldUpdateBatch batchObj = new wfOnHoldUpdateBatch();
        id batchinstanceid = database.executeBatch(batchObj,1);  
    }
}