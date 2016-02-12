public class wfCreateAdhocTask {
	public Id taskId{get;set;}
	public boolean editModeSec{get;set;}
	public Task__c newTask{get;set;}
	public Task__c taskObj{get;set;}
	public String parentURL{get;set;}
	public Boolean confirmMode {get;set;}
    public List<Opportunity_Team__c> optyRoleList {get;set;}
	public wfCreateAdhocTask(){
		initialize();
	}
	
	public void initialize(){
		editModeSec = true;
		taskId = System.currentPagereference().getParameters().get('Id');
		System.debug('taskId: ' + taskId);
		if(taskId != null){
			Set<String> tempObjectIds = new Set<String>();
			tempObjectIds.add(taskId);
			Map<Id, Task__c> taskMap = wfUtil.getTasks(tempObjectIds);
			if(taskMap != null && !taskMap.isEmpty()){
				taskObj = taskMap.values()[0];
			}
		}		
		newTask = new Task__c();
		newTask.phase__r = taskObj.Phase__r;
		newTask.project_name__c = taskObj.Phase__r.project__c;
		newTask.phase__c = taskObj.Phase__r.Id;
		newTask.Group_Name__c = taskObj.Group_Name__c;
		newTask.Task_Owner__c = taskObj.Task_Owner__c;
		newTask.Status__c = wfUtil.OPEN;
		newTask.Task_Description__c = '';
		newTask.Start_Date__c = Datetime.now();
		newTask.Category__c = wfUtil.REQUIRED;
		newTask.Type__c = 'Adhoc';
		String baseURL = EDPUtil.getBaseURL();
        parentURL = baseURL + '/' + taskId;
	}
    
    
    private void assignOptyTeamRoleToTaskOwner(task__c task){
        String optyId=[SELECT Opportunity__r.id  FROM Project__c where Id=:task.Phase__r.project__r.id limit 1].Opportunity__r.id;  
        system.debug('optyId:::::' + optyId);
        optyRoleList =[SELECT Id, Role__c, user__c, Opportunity__c FROM Opportunity_Team__c where Opportunity__c=:optyId];
        for(Opportunity_Team__c optyRole : optyRoleList) {
            If(optyRole.Role__c==task.Group_Name__c){
                task.Task_Owner__c= optyRole.user__c;
                 update task;
            }
        }
       
    }  
    
        public PageReference editTask() {
         // editModeSec = true;

          editModeSec =true;
          PageReference pageRef = new PageReference('/apex/wfCreateAdhocTask?id='+taskId);
          
          return pageRef;
          
    }
	
	public Pagereference saveAdhocTask(){
		
		try{
			if(newTask.Category__c == null || newTask.Category__c == ''){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Enter values for the required fields.'));
				return null;				
			}
			upsert newTask;
			editModeSec = false;
			
			if((taskObj.status__c == wfUtil.OPEN || taskObj.status__c == wfUtil.ON_HOLD) 
				&& ((newTask.status__c == wfUtil.OPEN || newTask.status__c == wfUtil.ON_HOLD) && newTask.Category__c == wfUtil.REQUIRED)){
				taskObj.status__c = 'Blocked';
				taskObj.Blocked_Start_Date__c = Datetime.now();
				taskObj.Blocked_Reason__c = 'Created Adhoc Task. ' + ' Task Name: ' + newTask.Name;
				update taskObj;
			}
			Task_Dependency__c tskDependencyObj = new Task_Dependency__c();
			tskDependencyObj.Parent_Task__c = newTask.Id;
            tskDependencyObj.Project_Name__c = taskObj.Phase__r.project__c;
			tskDependencyObj.Task__c = taskObj.Id;
			insert tskDependencyObj;
			assignOptyTeamRoleToTaskOwner(newTask);
			return null;
		}catch(Exception exceptionObj){
            String errorMessage = exceptionObj.getMessage();
            System.debug('Error Message: ' + errorMessage);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,errorMessage));			
		}
		return null;
	}
}