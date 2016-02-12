global class HomeDepotLeadSyncScheduler implements Schedulable{

    public HomeDepotLeadSyncScheduler(){
                
    }
    
    global void execute(SchedulableContext SCtx) {  
        HomeDepotLeadSyncBatch batchObj = new HomeDepotLeadSyncBatch();
        id batchinstanceid = database.executeBatch(batchObj,90);  
    }
}