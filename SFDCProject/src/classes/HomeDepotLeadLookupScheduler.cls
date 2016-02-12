global class HomeDepotLeadLookupScheduler implements Schedulable{
	public HomeDepotLeadLookupScheduler(){
                
    }
    
    global void execute(SchedulableContext SCtx) {  
        HomeDepotLeadLookupBatch batchObj = new HomeDepotLeadLookupBatch();
        id batchinstanceid = database.executeBatch(batchObj,1);  
    }
}