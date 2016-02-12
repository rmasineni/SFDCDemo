trigger trg_task_before_ins_upd on Task (before update) {

	List<Case> cases = new List<Case>();    
    String[] caseIds = new String[Trigger.new.size()];
    String[] taskTypes = new String[Trigger.new.size()];
    Set <Id> parentCaseIds = new Set <Id>();
    Set <Id> lastUpdateOnCaseIds = new Set <Id>();
	List<Task> taskList = new List<Task>();
	Set<Id> proposalIds = new Set<Id>();

	Id edpRecordTypeId = EDPUtil.getTaskEDPRecordType();
	Set<Id> originalUserIds = new Set<Id>();
	Set<Id> taskIds = new Set<Id>();
    for(Integer i = 0;i<Trigger.new.size();i++)
    {      
        Task taskObj = Trigger.new[i];
        if ((System.Trigger.isUpdate ) 
        	&& edpRecordTypeId == taskObj.recordTypeId 
        	&& (taskObj.Status == EDPUtil.RESOLVED && Trigger.oldmap.get(taskObj.Id).status != EDPUtil.RESOLVED)
        	&& taskObj.Original_Task_Owner__c != null){
			if(taskObj.whatId != null &&
				String.valueOf(taskObj.whatId).startsWith(EDPUtil.ProposalPrefix)){
				originalUserIds.add(taskObj.Original_Task_Owner__c);	
				taskIds.add(taskObj.Id);
				proposalIds.add(taskObj.whatId);		
			}			
        }
                     
    }    
  	if(originalUserIds.size() > 0 ){
   		Map<Id, User> userMap = EDPUtil.getUserdetails(originalUserIds);
  		for(Id taskId : taskIds){
			Task tempTaskObj = Trigger.newMap.get(taskId);
			User tempUserObj = 	userMap.get(tempTaskObj.Original_Task_Owner__c);
			if(tempUserObj != null){
				tempTaskObj.OwnerId = tempUserObj.Id;
			}
  		}
  	}

  	if(proposalIds.size() > 0 ){
  		EDPUtil.updateProposalStageForPendingTasks(proposalIds);
  	}
}