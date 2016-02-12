@isTest(SeeAllData=true)
public class UnitTest_WorkflowManagement {
	
	public static Project__c createProject(){
		Proposal__c proposalObj  = UnitTest_ServiceContractUtil.createTestProposal();
		proposalObj.name = 'PKRN9XY4661C-A';
		Id SunrunIncId = System.Label.Sunrun_Inc_Id;
		proposalObj.sales_partner__c = SunrunIncId;
		proposalObj.install_partner__c = SunrunIncId;
		proposalObj.Proposal_Source__c = 'BB';
		
		Opportunity optyObj = [Select Id, name, Install_Branch_Id__c, Install_Partner__c FROM Opportunity where Id = :proposalObj.Opportunity__c];
		List<String> installPartners = new List<String>();
		installPartners.addall(wfUtil.getWFInstallPartners());
		List<String> installBranches = new List<String>(); 
		installBranches.addall(wfUtil.getWFInstallBranches());
		
		if(!installPartners.isEmpty() && !installBranches.isEmpty()){
			optyObj.Install_Branch_Id__c = installBranches[0];
			optyObj.Install_Partner__c = installPartners[0];
			update optyObj;
		}
		insert proposalObj;   
		
		wfUtil.createProject = true;
		proposalObj.Signed__c = true;
		update proposalObj;
		
		Project__c projectObj;
		List<Project__c> projectObjs = [Select Id, name, Proposal__c, Opportunity__c, Service_Contract__c, status__C from Project__c where Proposal__c =:proposalObj.Id];
		if(projectObjs != null && !projectObjs.isEmpty()){
			projectObj = projectObjs[0];
		}
		return 	projectObj;
	}
	
	public static void createUserGroup(Id userId, String groupName){
		User_Group__c ugObj = new User_Group__c();
		ugObj.User__c = userId;
		ugObj.Group__c = groupName;
		insert ugObj;
		
		Set<Id> userIds = new Set<Id>();
		userIds.add(userId);
		wfUtil.getUserGroups(userIds);
	}
	
	
	//#1
	public static testMethod void testCreateWorkflowProject(){
		Id userId = UserInfo.getUserId();
		Project__c projectObj = createProject();
		System.debug('projectObj.Status__c : ' + projectObj.Status__c);
		Task__C taskObj = [select Id, name, Task_Owner__c, group_name__c, SLA_In_Hours__c, Expected_Close_Date2__c, Expected_Close_Date__c from Task__c where Phase__r.project__c = :projectObj.Id and name = 'Verification Call'];
		createUserGroup(userId, taskObj.group_name__c);
		taskObj.Task_Owner__c = userId;
		update taskObj;
		
		Test.startTest(); 
			System.debug(taskObj.Id);
			System.currentPagereference().getParameters().put('Id', taskObj.Id);
			ApexPages.StandardController stdcon = new ApexPages.StandardController(taskObj);
			WorkflowTask wfTaskObj = new WorkflowTask(stdcon);
			wfTaskObj.initialize();  
			WorkflowTask wfTaskObj2 = new WorkflowTask(); 
			
			WorkflowManagement.setSLAEndTime(taskObj);
			WorkflowManagement.getSLATime(Datetime.now(), 3);
			WorkflowManagement wfManagementObj = new WorkflowManagement();
			wfManagementObj.createBusinessDateTime(Date.today(), true);
			wfManagementObj.createBusinessDateTime(Datetime.now(), true);
			
			wfTaskObj.showSC();
			wfTaskObj.viewTask();
			wfTaskObj.getBaseURL();
			
			wfTaskObj.getTaskDisplayFields();
			wfTaskObj.getViewFields();
			wfTaskObj.initializepredecessors();
			wfTaskObj.getTaskEditFields();
			
			wfTaskObj.editTask();
			wfTaskObj.toggleTaskCategory();
			wfTaskObj.toggleTaskCategory();
			wfTaskObj.saveRelatedObjects();
			wfTaskObj.getObjectLabel('Service_Contract_Event__c');
			wfTaskObj.getObjectLabel('Proposal__c');
			wfTaskObj.taskSave();
			
			wfTaskObj.reOpenTask();
			wfTaskObj.isTaskOwner(userId);
		Test.stopTest(); 
	}

	//#2	
	public static testMethod void testCreateAdhocTask(){
		Project__c projectObj = createProject();
		Task__C taskObj = [select Id, name, Task_Owner__c, SLA_In_Hours__c, Expected_Close_Date2__c, Expected_Close_Date__c from Task__c where Phase__r.project__c = :projectObj.Id and name = 'Verification Call'];
		System.debug(taskObj.Id);
		
		System.currentPagereference().getParameters().put('Id', taskObj.Id);
		wfCreateAdhocTask adHocObj = new wfCreateAdhocTask();
		adHocObj.initialize(); 
		try{
			adHocObj.saveAdhocTask();
		}catch(Exception expObj){
			
		}
		adHocObj.newTask.Category__c = 'Required';
		adHocObj.saveAdhocTask(); 

		Test.startTest();
			set<Id> parentIds = new set<Id>();
			parentIds.add(adHocObj.newTask.Id);
			WorkflowManagement.updateSuccessorTasks(parentIds);
			
			System.currentPagereference().getParameters().put('Id', adHocObj.newTask.Id);
			ApexPages.StandardController stdcon = new ApexPages.StandardController(adHocObj.newTask);
			WorkflowTask wfTaskObj = new WorkflowTask(stdcon);
			wfTaskObj.initialize();  
			wfTaskObj.taskSave();		

			System.currentPagereference().getParameters().put('Id', adHocObj.newTask.Id);		
			System.currentPagereference().getParameters().put('action', 'reopen');
			wfTask_Update wfTskUpdate1 = new wfTask_Update();
			wfTskUpdate1.initialize();
			wfTskUpdate1.taskObj.Reopen_Reason__c = 'Test Reopen';
			wfTskUpdate1.saveTask();
			WorkflowManagement.reopenTask(adHocObj.newTask.Id);
	
			System.currentPagereference().getParameters().put('Id', adHocObj.newTask.Id);		
			System.currentPagereference().getParameters().put('action', 'onhold');
			wfTask_Update wfTskUpdate2 = new wfTask_Update();
			wfTskUpdate2.initialize();
			wfTskUpdate2.saveTask();

			wfTask_Update wfTskUpdate3 = new wfTask_Update();
			wfTskUpdate3.initialize();
			wfTskUpdate3.taskObj.On_Hold_End_Date__c = Date.today();
			wfTskUpdate3.taskObj.On_Hold_Reason__c = 'Test';
			wfTskUpdate3.saveTask();			

		Test.stopTest();

		
	}
	
	//#3
	public static testMethod void testProjectDetails(){
		Id userId = UserInfo.getUserId();
		Project__c projectObj = createProject();
		
		System.currentPagereference().getParameters().put('Id', projectObj.Id);
		ApexPages.StandardController stdcon = new ApexPages.StandardController(projectObj);
		wfProjectDetails wfProjectObj = new wfProjectDetails(stdcon);
		wfProjectObj.initialize(); 
        wfProjectObj.initializeProjectDetails();
		wfProjectObj.getProjectDetails();
		wfProjectObj.refreshPage();
		wfProjectObj.newTask();
		
		wfProjectObj.saveTasks();
		wfProjectObj.cancelEditTask();
		wfProjectDetails wfProjectObj2 = new wfProjectDetails();

		Task__C taskObj = [select Id, name, Task_Owner__c, group_name__c, SLA_In_Hours__c, Expected_Close_Date2__c, Expected_Close_Date__c from Task__c where Phase__r.project__c = :projectObj.Id and name = 'Verification Call'];
		createUserGroup(userId, taskObj.group_name__c);
		taskObj.Task_Owner__c = userId;
		update taskObj;
		
		List<User> userList = EDPUtil.getSRUserDetails();
        User defaultOpsUser = null;
        User defaultFinanceUser = null;
            
        Test.startTest();       
			 for(User userObj : userList){
                if(defaultOpsUser == null && userObj.name == EDPUtil.USER_NAME_TEST){
                    defaultOpsUser = userObj;
                }
                if(defaultFinanceUser == null && userObj.name == EDPUtil.USER_NAME_TEST){
                    defaultFinanceUser = userObj;
                }
        
                if(userObj.name == EDPUtil.USER_NAME_SR_OPS){
                    defaultOpsUser = userObj;
                }           
                else if(userObj.name == EDPUtil.USER_NAME_SR_FINANCE){
                    defaultFinanceUser = userObj;
                }
            }
            System.runAs(defaultOpsUser){		 
				wfProjectObj.saveTasks();
            }
            
            
            WorkflowNotes notesObj1 = new WorkflowNotes();
            notesObj1.newTask();
            notesObj1.newNotesObj.comments__C = 'Test1';
            notesObj1.saveTask();
            
            notesObj1.showEdit = true;
            notesObj1.saveTask();
            
            System.currentPagereference().getParameters().put('1', '1');
            WorkflowNotes notesObj2 = new WorkflowNotes();
          	  
            
            System.currentPagereference().getParameters().put('Id', taskObj.Id);
            System.currentPagereference().getParameters().put('1', '2');
            WorkflowNotes notesObj3 = new WorkflowNotes();
            notesObj3.newTask();
            notesObj3.newNotesObj.comments__C = 'Test2';
            notesObj3.saveTask();

            notesObj3.showEdit = true;
            notesObj3.saveTask();
            
            System.currentPagereference().getParameters().put('Id', taskObj.Id);
            System.currentPagereference().getParameters().put('1', '1');
            WorkflowNotes notesObj4 = new WorkflowNotes();
			notesObj4.cancelNewTask();
		Test.stopTest();  
	}

	//#4	
	public static testMethod void testUpdateSuccessorTasks(){
		Project__c projectObj = createProject();
		Task__C taskObj = [select Id, name, Task_Owner__c, SLA_In_Hours__c, Expected_Close_Date2__c, Expected_Close_Date__c from Task__c where Phase__r.project__c = :projectObj.Id and name = 'Verification Call'];
		System.debug(taskObj.Id);
		
		System.currentPagereference().getParameters().put('Id', taskObj.Id);
		wfCreateAdhocTask adHocObj = new wfCreateAdhocTask();
		adHocObj.initialize(); 
		try{
			adHocObj.saveAdhocTask();
		}catch(Exception expObj){
			
		}
		adHocObj.newTask.Category__c = 'Required';
		adHocObj.saveAdhocTask(); 

		Test.startTest();
			set<Id> parentIds = new set<Id>();
			parentIds.add(adHocObj.newTask.Id);
			WorkflowManagement.updateSuccessorTasks(parentIds);
			
			System.currentPagereference().getParameters().put('Id', adHocObj.newTask.Id);
			ApexPages.StandardController stdcon = new ApexPages.StandardController(adHocObj.newTask);
			WorkflowTask wfTaskObj = new WorkflowTask(stdcon);
			wfTaskObj.initialize();  
			wfTaskObj.taskSave();		

			System.currentPagereference().getParameters().put('Id', adHocObj.newTask.Id);		
			System.currentPagereference().getParameters().put('action', 'reopen');
			wfTask_Update wfTskUpdate1 = new wfTask_Update();
			wfTskUpdate1.initialize();
			wfTskUpdate1.taskObj.Reopen_Reason__c = 'Test Reopen';
			wfTskUpdate1.saveTask();
			WorkflowManagement.reopenTask(adHocObj.newTask.Id);
	
			System.currentPagereference().getParameters().put('Id', adHocObj.newTask.Id);		
			System.currentPagereference().getParameters().put('action', 'onhold');
			wfTask_Update wfTskUpdate2 = new wfTask_Update();
			wfTskUpdate2.initialize();
			wfTskUpdate2.saveTask();

			wfTask_Update wfTskUpdate3 = new wfTask_Update();
			wfTskUpdate3.initialize();
			wfTskUpdate3.taskObj.On_Hold_End_Date__c = Date.today();
			wfTskUpdate3.taskObj.On_Hold_Reason__c = 'Test';
			wfTskUpdate3.saveTask();			

		Test.stopTest();

		
	}

	
}