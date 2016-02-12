global class Contact_ExpiredCSLBApplicationsScheduler implements Schedulable{

    public Contact_ExpiredCSLBApplicationsScheduler(){
                
    }
    
    global void execute(SchedulableContext SC) {  
        Contact_ExpiredCSLBApplicationsBatch batchObj = new Contact_ExpiredCSLBApplicationsBatch();
        id batchinstanceid = database.executeBatch(batchObj);  
    }

}