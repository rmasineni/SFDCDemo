@ isTest (seeAllData = true)
public class testWfBlockProjectClass {
    
static testMethod void UnitTestOne() {
    
    	Id userId = UserInfo.getUserId();
		Project__c proj = UnitTest_WorkflowManagement.createProject();
		System.debug('projectObj.Status__c : ' + proj.Status__c);
		Task__C taskObj = [select Id, name, Task_Owner__c, group_name__c, Phase__c,SLA_In_Hours__c, Expected_Close_Date2__c, Expected_Close_Date__c from Task__c where Phase__r.project__c = :proj.Id and name = 'Verification Call'];
		UnitTest_WorkflowManagement.createUserGroup(userId, taskObj.group_name__c);
		taskObj.Task_Owner__c = userId;
		update taskObj;
        list<task__c> taskList = new list<task__c> ();
        
        for (integer i = 0 ; i < 5 ; i++) {    
            task__c tsk = new task__c();
            tsk.name = 'Test Task';
            tsk.Group_Name__c = 'Branch manager';
            tsk.phase__c = taskObj.phase__c;
            tsk.project_Name__c = proj.id;
            tsk.Status__c = 'Open';
            taskList.add(tsk);
        }
    	try{   
            insert taskList;
        }Catch(exception e){}
		
   		
        Test.startTest(); 
        
            system.assertNotEquals(null, taskObj);
            PageReference pageRef = Page.wfBlockProject;
            pageRef.getParameters().put('id', String.valueOf(proj.Id));
            Test.setCurrentPage(pageRef);
            wfBlockProjectClass blockProjObj = new wfBlockProjectClass();
    		blockProjObj.getTasksToUpdate();
    		blockProjObj.blockProject();
    		list<task__c> TasksBlocked = new list<task__c>([select Id, name, Blocked_Project__c,Task_Owner__c, group_name__c, Phase__c,SLA_In_Hours__c, 
                                                             Expected_Close_Date2__c, Expected_Close_Date__c from Task__c where Phase__r.project__c = :proj.Id ]);
            for (task__c tsk: TasksBlocked){
                System.assertEquals(true, tsk.Blocked_Project__c);
            }
    
            wfBlockProjectClass unBlockProjObj = new wfBlockProjectClass();
           	unBlockProjObj.getTasksToUpdate();
            unBlockProjObj.unBlockProject();
     		
    		list<task__c> TasksUnblocked = new list<task__c>([select Id, name, Blocked_Project__c,Task_Owner__c, group_name__c, Phase__c,SLA_In_Hours__c, 
                                                             Expected_Close_Date2__c, Expected_Close_Date__c from Task__c where Phase__r.project__c = :proj.Id ]);
            for (task__c tsk: TasksUnblocked){
                System.assertEquals(false, tsk.Blocked_Project__c);
            } 
        Test.stopTest(); 
	}
}