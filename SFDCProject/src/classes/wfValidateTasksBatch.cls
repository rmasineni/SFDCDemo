global class wfValidateTasksBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful {
	global  Map<Id, Map<Id, Set<String>>> validationReport = new  Map<Id, Map<Id, Set<String>>>();
	global Iterable<String> start(Database.BatchableContext bc) {
		String completedStr = 'Complete';
		string requiredStr = 'Required';
		string onHoldStr = 'On-Hold';
    	Date currentDate = Date.today();
    	List<String> projectIds = new List<String>();
    	Set<String> tempProjectIds = new Set<String>();
		String taskSOQLStr = 'select Id, phase__r.project__c, Last_Modified_Date__c from Task__c where Last_Modified_Date__c =:currentDate ';
		if(Test.isRunningTest()){
			taskSOQLStr += ' limit 2 ' ;
		}
		
		//for(Task__c taskObj : [select Id, phase__r.project__c, Last_Modified_Date__c from Task__c where Last_Modified_Date__c =:currentDate]){
		for(Task__c taskObj : Database.query(taskSOQLStr)){
				tempProjectIds.add(taskObj.phase__r.project__c);
		}
		if(!tempProjectIds.isEmpty()){
			projectIds.addall(tempProjectIds);
		}
        return projectIds;
    }
    
    global void execute(Database.BatchableContext BC, List<String> projectIds){
        try {
			wfValidateTasks.validateProjects(projectIds, validationReport);
			//wfValidateTasks.emailValidationReport(validationReport);
        } catch (Exception e) {
			System.debug('Exception: ' + e);
            //ExceptionLogger.logException(utils.getCurrentClassName(), 'Exception while Updating IKnock with Lead Urls for ' + leads, e);
        }	
    }
    
    global void finish(Database.BatchableContext BC){
		wfValidateTasks.emailValidationReport(validationReport);
    }

}