@isTest(SeeAllData=true)
public class UnitTest_WorkflowBatch{

	public static testMethod void testOnHoldTasksBatch(){
		Test.startTest();
			Id userId = UserInfo.getUserId();
			Project__c projectObj = UnitTest_WorkflowManagement.createProject();
			System.debug('projectObj.Status__c : ' + projectObj.Status__c);
			Task__C taskObj = [select Id, name, Task_Owner__c, group_name__c, SLA_In_Hours__c, Expected_Close_Date2__c, Expected_Close_Date__c from Task__c where Phase__r.project__c = :projectObj.Id and name = 'Verification Call'];
			UnitTest_WorkflowManagement.createUserGroup(userId, taskObj.group_name__c);
			taskObj.Task_Owner__c = userId;
			taskObj.status__c = 'On-Hold';
			taskObj.On_Hold_Reason__c = 'Test'; 
			taskObj.On_Hold_End_Date__c = Date.today();
			update taskObj;
			
			wfOnHoldUpdateBatch batchObj2 = new wfOnHoldUpdateBatch();
	        id batchinstanceid2 = database.executeBatch(batchObj2); 		
        Test.stopTest(); 
	}


	public static testMethod void testOnHoldTasksScheduler(){
		Test.startTest();
		
			Id userId = UserInfo.getUserId();
			Project__c projectObj = UnitTest_WorkflowManagement.createProject();
			System.debug('projectObj.Status__c : ' + projectObj.Status__c);
			Task__C taskObj = [select Id, name, Task_Owner__c, group_name__c, SLA_In_Hours__c, Expected_Close_Date2__c, Expected_Close_Date__c from Task__c where Phase__r.project__c = :projectObj.Id and name = 'Verification Call'];
			UnitTest_WorkflowManagement.createUserGroup(userId, taskObj.group_name__c);
			taskObj.Task_Owner__c = userId;
			taskObj.status__c = 'On-Hold';
			taskObj.On_Hold_Reason__c = 'Test'; 
			taskObj.On_Hold_End_Date__c = Date.today();
			update taskObj;
			
	        wfOnHoldUpdate_Scheduler schedulerObj = new wfOnHoldUpdate_Scheduler();
        Test.stopTest();


	}

}