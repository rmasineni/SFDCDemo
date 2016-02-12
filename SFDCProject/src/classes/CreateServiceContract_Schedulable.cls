global class CreateServiceContract_Schedulable implements Schedulable {
	
    public CreateServiceContract_Schedulable(){
    	
    }
	
	global void execute(SchedulableContext SC) {
        System.debug('scheduleTM: execute');   
        ServiceContract_Batch scBatch = new ServiceContract_Batch(false);
        id batchinstanceid = database.executeBatch(scBatch, 1);   
    }

}