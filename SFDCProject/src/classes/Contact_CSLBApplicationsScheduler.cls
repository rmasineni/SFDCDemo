global class Contact_CSLBApplicationsScheduler implements Schedulable{

    public Contact_CSLBApplicationsScheduler(){
                
    }
    
    global void execute(SchedulableContext SC) {  
        Contact_CSLBApplicationsBatch batchObj = new Contact_CSLBApplicationsBatch();
        id batchinstanceid = database.executeBatch(batchObj);  
    }

}