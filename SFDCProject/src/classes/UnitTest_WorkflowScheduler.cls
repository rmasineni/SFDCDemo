@isTest(SeeAllData=true)
public class UnitTest_WorkflowScheduler{

	public static testMethod void testValidateTasksBatch(){
		Test.startTest();
		
			Id userId = UserInfo.getUserId();
			Project__c projectObj = UnitTest_WorkflowManagement.createProject();
			System.debug('projectObj.Status__c : ' + projectObj.Status__c);
			Task__C taskObj = [select Id, name, Task_Owner__c, group_name__c, SLA_In_Hours__c, Expected_Close_Date2__c, Expected_Close_Date__c from Task__c where Phase__r.project__c = :projectObj.Id and name = 'Verification Call'];
			UnitTest_WorkflowManagement.createUserGroup(userId, taskObj.group_name__c);
			taskObj.Task_Owner__c = userId;
			update taskObj;
			
			wfValidateTasksBatch batchObj2 = new wfValidateTasksBatch();
	        //id batchinstanceid2 = database.executeBatch(batchObj2); 
        Test.stopTest(); 
	}


	public static testMethod void testValidateTasksScheduler(){
		
		Test.startTest();
		
			Id userId = UserInfo.getUserId();
			Project__c projectObj = UnitTest_WorkflowManagement.createProject();
			System.debug('projectObj.Status__c : ' + projectObj.Status__c);
			Task__C taskObj = [select Id, name, Task_Owner__c, group_name__c, SLA_In_Hours__c, Expected_Close_Date2__c, Expected_Close_Date__c from Task__c where Phase__r.project__c = :projectObj.Id and name = 'Verification Call'];
			UnitTest_WorkflowManagement.createUserGroup(userId, taskObj.group_name__c);
			taskObj.Task_Owner__c = userId;
			update taskObj;
			
			wfValidateTasks_Scheduler schedulerObj = new wfValidateTasks_Scheduler();
	        schedulerObj.execute(NULL);	 
        Test.stopTest(); 
	}


}