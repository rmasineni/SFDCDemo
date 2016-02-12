public class wfTask_Update {
	
	public Id taskId{get;set;}
	public string action{get;set;}
	public boolean showOnHold {get;set;}
	public boolean showReopen {get;set;}
	public Boolean confirmMode {get;set;}
	public Task__c taskObj {get;set;}
	public Project__c projectObj {get;set;}
	public String parentURL{get;set;}
	public String title{get;set;}
	public 	CustomLookup__c customLookupObj{get;set;}
	Public wfTask_Update(){
		try{
			initialize();	
		}catch(Exception exceptionObj){
            String errorMessage = exceptionObj.getMessage();
            System.debug('Error Message: ' + errorMessage);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Unable to read task details'));			
		}		
	}
	public void initialize(){
		showOnHold = false;
		showReopen = false;
		taskId = System.currentPagereference().getParameters().get('Id');
		action = System.currentPagereference().getParameters().get('action');
		customLookupObj = new CustomLookup__c();
		if(action != null && action == 'onhold'){
			showOnHold = true;
			title = 'Update Task: On-hold';
		}else if(action != null && action == 'reopen'){
			showReopen = true;
			title = 'Update Task: Re-open';
		}else{
			 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Invalid user request'));	
		}
		taskObj = [Select Phase__r.Id, Id, name, reopen__c, Reopen_Reason__c, status__c, On_Hold_Reason__c, OnHoldEndDate__c, phase__r.project__r.name,  
					phase__r.project__r.Opportunity_Name__c, SLA_In_Hours__c, start_date__c, end_date__c, Expected_Close_Date__c, Expected_Close_Date2__c, Phase__r.Project__c from Task__c where Id =:taskId];
		projectObj = taskObj.phase__r.project__r;
		customLookupObj.End_Date__c = (taskObj.OnHoldEndDate__c != null ) ? taskObj.OnHoldEndDate__c : null;
	}
	
	public Pagereference saveTask(){
		Transient Savepoint sp;
		try{
			sp = Database.setSavepoint();
			if((showOnHold && (customLookupObj.End_Date__c == null || taskObj.On_Hold_Reason__c == null || taskObj.On_Hold_Reason__c == '' ))
				|| (showReopen && (taskObj.Reopen_Reason__c == null || taskObj.Reopen_Reason__c == '' ))){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Enter values for the required fields'));
				return null;
			}

			if((showOnHold && (customLookupObj.End_Date__c != null && customLookupObj.End_Date__c <= Date.today()))){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'On Hold End Date should be future date'));
				return null;
			}
			
			if(showOnHold){
				taskObj.status__c = wfUtil.ON_HOLD;
				taskObj.OnHoldEndDate__c = customLookupObj.End_Date__c;
				update taskObj;
			}else if(showReopen){
				WorkflowManagement wfObj = new WorkflowManagement();
				String result = wfObj.reopenTasksImpl(taskObj);
				if(result != null && result != ''){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, result));
					System.debug('TEST1 ....');
					return null;					
				}
			}
			confirmMode = true;
			return null;
		}catch(DMLException exceptionObj){
            String errorMessage = exceptionObj.getMessage();
			ApexPages.addMessages(exceptionObj);
        }catch(Exception exceptionObj){
            String errorMessage = exceptionObj.getMessage();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,errorMessage));
        }
        return null;
	}
}