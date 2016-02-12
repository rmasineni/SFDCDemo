public class wfTaskRedirect {
	public string taskId ;
    private Boolean systemAdmin = false;
    private Task__c taskObj;
    private string baseUrl;
    public boolean showEditPage = false;
    public wfTaskRedirect(ApexPages.StandardController controller) {
		taskObj = (Task__c) controller.getRecord();
        if (taskId == null) {
            taskId = taskObj.Id;
        }
        initialize();
    }

    private void initialize(){
    	if(taskId != null){
    		taskObj = [Select Id,Task_Owner__c, Group_Name__c, status__c from Task__c where Id =: taskId];
    	}
		showEditPage = false;
    	Set<Id> userIds = new Set<Id>();
    	Id userId = UserInfo.getUserId();
    	userIds.add(userId);
		Map<Id, Set<String>> userGroupMap = wfUtil.getUserGroups(userIds);  	
		Set<String> userGroups = userGroupMap.get(userId);
		if(taskObj.status__c == wfUtil.OPEN  
			&& ((taskObj.Task_Owner__c == userId ) || (taskObj.Task_Owner__c == null && userGroups != null && userGroups.contains(taskObj.Group_Name__c)))){
			showEditPage = true;
		}
		baseUrl = EDPUtil.getBaseURL();
    }

    private String taskViewURL {
        get {
        	return baseUrl + '/apex/wfTask_View?id=' + taskId + '&retURL=%2F' + taskId + '&&sfdc.override=1';
        }
        set;
    }  

    private String taskEditURL {
        get {
            return baseUrl + '/apex/wfTask_Edit?id=' + taskId + '&retURL=%2F' + taskId + '&sfdc.override=1';
        }
        set;
    }

	public PageReference getWfTaskEditPage() {
        PageReference ref = null;
        System.debug('showEditPage: ' + showEditPage);
        System.debug('taskEditURL: ' + taskEditURL);
		System.debug('taskViewURL: ' + taskViewURL);
        if(showEditPage == true ){
            ref = new PageReference(taskEditURL);
            ref.setRedirect(true);      
        }else{
            ref = new PageReference(taskViewURL);
            ref.setRedirect(true);          
        }
        return ref;
    }

}