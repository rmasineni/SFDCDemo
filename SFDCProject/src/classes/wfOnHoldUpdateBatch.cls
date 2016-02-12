global class wfOnHoldUpdateBatch implements Database.Batchable<Task__c>, Database.AllowsCallouts  {
        
	global Iterable<Task__c> start(Database.BatchableContext bc) {
		String completedStr = 'Complete';
		string requiredStr = 'Required';
		string onHoldStr = 'On-Hold';
    	Date currentDate = Date.today().adddays(1);
    	System.debug('currentDate: ' + currentDate);

		String taskSOQLStr = 'select id, status__c, OnHoldEndDate__c,On_Hold_Reason__c, Blocked_start_date__c,end_date__c, ';
		taskSOQLStr += ' Blocked_Reason__c, (Select Id, parent_task__r.status__c, Name, Child_Task__c, ';
		taskSOQLStr += ' Parent_Task__c, parent_task__r.category__c, Task__c From Task_Dependencys__r '; 
		taskSOQLStr += ' where parent_task__r.status__c != :completedStr and parent_task__r.category__c =:requiredStr)  ';
		taskSOQLStr += ' from Task__c where OnHoldEndDate__c < :currentDate and status__c =:onHoldStr ';
		if(Test.isRunningTest()){
			taskSOQLStr += ' limit 2 ' ;
		}

		List<Task__c> tasks = Database.query(taskSOQLStr);
        
       // List<Task__c> tasks = [select id, status__c, OnHoldEndDate__c,On_Hold_Reason__c, Blocked_start_date__c,end_date__c,
       // 							Blocked_Reason__c, (Select Id, parent_task__r.status__c, Name, Child_Task__c, 
        //							Parent_Task__c, parent_task__r.category__c, Task__c From Task_Dependencys__r  
       // 							where parent_task__r.status__c != :completedStr and parent_task__r.category__c =:requiredStr)  
       // 						from Task__c where OnHoldEndDate__c < :currentDate and status__c =:onHoldStr];
       // 
        System.debug('Selected following tasks to update status ' + tasks);  
        return tasks;
    }
    
    global void execute(Database.BatchableContext BC, List<Task__c> tasks){
        try {
        	Map<Id, Task__c> modifiedTasks = new Map<Id, Task__c>();
         	for(Task__c taskObj : tasks){
         		if(taskObj.Task_Dependencys__r != null && !taskObj.Task_Dependencys__r.isEmpty()){
					taskObj.status__c = 'Blocked';
					taskObj.end_date__c = null;
					taskObj.Blocked_start_date__c = Datetime.now() ;
					taskObj.Blocked_Reason__c = 'Moved On-Hold to Blocked status' ;
         		}else{
         			taskObj.status__c = 'Open';
         		}
				taskObj.OnHoldEndDate__c = null;
				taskObj.On_Hold_Reason__c = '';
				modifiedTasks.put(taskObj.Id, taskObj);
        	}
        	if(!modifiedTasks.isEmpty()){
        		update modifiedTasks.values();
        	}
        	
        } catch (Exception e) {
			System.debug('Exception: ' + e);
            //ExceptionLogger.logException(utils.getCurrentClassName(), 'Exception while Updating IKnock with Lead Urls for ' + leads, e);
        }
    }
    
    global void finish(Database.BatchableContext BC){

    }
}