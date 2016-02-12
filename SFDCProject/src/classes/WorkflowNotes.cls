public class WorkflowNotes {
	String tempObjectId {get;set;}
	String showAll {get;set;}
	public Task__c taskObj{get;set;}
	public Project__c projectObj{get;set;}
	public List<WF_Note__c> wfNotes{get;set;}
	public boolean showEdit{get;set;}
	public boolean showNew{get;set;}
	public WF_Note__c newNotesObj{get;set;}
	static final public String taskPrefix = Schema.SObjectType.Task__c.getKeyPrefix(); 
	static final public String projectPrefix = Schema.SObjectType.Project__c.getKeyPrefix(); 
	public Boolean isProject{get;set;}
	public Boolean isTask{get;set;}
	public Id loginUserId {get;set;}
	
	public WorkflowNotes(){
		showEdit = true;
		showNew = false;
		isProject = false;
		isTask = false;
		loginUserId = UserInfo.getUserId();
		initializeNotes();
	}
	
	public void initializeNotes(){

		wfNotes = new List<WF_Note__c>();
		tempObjectId = ApexPages.currentPage().getParameters().get('Id');
		showAll = ApexPages.currentPage().getParameters().get('1');
		if(tempObjectId != null && tempObjectId != ''){
			Set<String> tempObjectIds = new Set<String>();
			tempObjectIds.add(tempObjectId);
			String whereClause = '';
			if(tempObjectId.startsWith(taskPrefix)){
				Map<Id, Task__c> taskMap = wfUtil.getTasks(tempObjectIds);
				taskObj = taskMap.values()[0];
				projectObj = taskObj.Phase__r.project__r;
				whereClause = ' where task__c  = :tempObjectId ';
				isTask = true;
			}else if(tempObjectId.startsWith(projectPrefix)){
				whereClause = ' where project__c  = :tempObjectId ';
				if(showAll != null && showAll == '1'){
					whereClause += ' OR  task__r.phase__r.project__c =:tempObjectId '; 
				}
				isProject = true;
				projectObj = [Select Id, name, description__c, Opportunity_Name__c from Project__c where Id =:tempObjectId];
			}
			whereClause += ' order by Critical__c desc, createddate desc '; 
			String notesSOQL = ' Select Id, Task_Name__c, Critical__c, OwnerId , name, comments__C, task__c, createdBy.name, lastmodifiedBy.name, createddate, lastmodifieddate from WF_Note__c ' + whereClause ;
			wfNotes =  Database.query(notesSOQL);
		}
	}
	
	public PageReference newTask() {
		showEdit = false;
		showNew = true;
		newNotesObj = new WF_Note__c();
		return ApexPages.CurrentPage();
	}

	public PageReference saveTask() {
		if(showEdit){
			System.debug('wfNotes: ' + wfNotes);
			List<WF_Note__c> modifiedNotes = new List<WF_Note__c>();
			for(WF_Note__c wfNotesObj : wfNotes){
				if(wfNotesObj.ownerId == loginUserId){
					modifiedNotes.add(wfNotesObj);
				}
			}
			if(!modifiedNotes.isEmpty()){
				update modifiedNotes;
			}
		}else if(showNew){
			if(isTask){
				newNotesObj.task__c = tempObjectId;
			}else if(isProject){
				newNotesObj.project__c = tempObjectId;
			}
			insert newNotesObj;
			wfNotes.add(newNotesObj);
		}
		showEdit = true;
		showNew = false;
		initializeNotes();
		return ApexPages.CurrentPage();
	}
	
	public PageReference cancelNewTask() {
		showEdit = true;
		showNew = false;
		return ApexPages.CurrentPage();
	}

}