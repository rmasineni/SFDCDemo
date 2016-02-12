trigger trg_TaskDependency_after on Task_Dependency__c (after insert, after update, after delete) {

	Boolean skipValidations = false;
	skipValidations = SkipTriggerValidation.performTriggerValidations();  	
	if(wfUtil.skipTDTrigger == true || skipValidations)
		return;
	Set<Id> parentTaskIds = new Set<Id>();
	if(Trigger.isDelete){
		for(Task_Dependency__c tdObj: Trigger.old){
			if(tdObj.task__c != null){
				parentTaskIds.add(tdObj.task__c);
			}			
		}
	}else {
		for(Task_Dependency__c tdObj: Trigger.new){
			if(Trigger.isInsert && tdObj.parent_task__c != null){
				parentTaskIds.add(tdObj.parent_task__c);
			}else if(Trigger.isUpdate && tdObj.parent_task__c != null){
				Task_Dependency__c oldTdObj = Trigger.oldMap.get(tdObj.Id);
				if(tdObj.parent_task__c != oldTdObj.parent_task__c){
					parentTaskIds.add(tdObj.parent_task__c);
				}
				
				//else if(tdObj.task__c != oldTdObj.task__c){ 
				//	parentTaskIds.add(tdObj.task__c);
				//	parentTaskIds.add(oldTdObj.task__c);
				//}
			}
		}
	}
	
	if(!parentTaskIds.isEmpty()){
		WorkflowManagement.updateSuccessorTasks(parentTaskIds);
	}
}