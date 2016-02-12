trigger trg_workflow_update_rule_after on Workflow_Update_Rule__c (after insert, after delete, after update, after undelete) {
    Set<Id> parentTemplateIds = new Set<Id>();
    if(Trigger.isInsert || Trigger.isUpdate){
    	for(Workflow_Update_Rule__c wfUpdateRuleObj: Trigger.new){
			Workflow_Update_Rule__c oldWFUpdateRuleObj;
			if(Trigger.isUpdate){
				oldWFUpdateRuleObj = Trigger.oldMap.get(wfUpdateRuleObj.Id);
			}
			if(oldWFUpdateRuleObj == null && wfUpdateRuleObj.Parent_Task_Template__c != null){
				parentTemplateIds.add(wfUpdateRuleObj.Parent_Task_Template__c);
			}else if(oldWFUpdateRuleObj.Parent_Task_Template__c != wfUpdateRuleObj.Parent_Task_Template__c){
				if(wfUpdateRuleObj.Parent_Task_Template__c != null){
					parentTemplateIds.add(wfUpdateRuleObj.Parent_Task_Template__c);
				}
				if(oldWFUpdateRuleObj.Parent_Task_Template__c != null){
					parentTemplateIds.add(oldWFUpdateRuleObj.Parent_Task_Template__c);
				}
			}
                		
    	}
    }else if(Trigger.isDelete){
    	for(Workflow_Update_Rule__c wfUpdateRuleObj: Trigger.Old){
			if(wfUpdateRuleObj.Parent_Task_Template__c != null){
				parentTemplateIds.add(wfUpdateRuleObj.Parent_Task_Template__c);
			}    		
    	}
    }else if(Trigger.isUndelete){
    	for(Workflow_Update_Rule__c wfUpdateRuleObj: Trigger.new){
			if(wfUpdateRuleObj.Parent_Task_Template__c != null){
				parentTemplateIds.add(wfUpdateRuleObj.Parent_Task_Template__c);
			}    		
    	}    	
    }
    
    if(!parentTemplateIds.isEmpty()){
		wfUtil.updateTaskTemplates(parentTemplateIds);
    }
	System.debug('parentTemplateIds: ' + parentTemplateIds);
}