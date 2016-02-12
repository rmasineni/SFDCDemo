trigger trg_bef_ins_populate_task_project on Task__c (before insert, before update) {
    wfUtil.checkProjectStatus(Trigger.isInsert, Trigger.isUpdate, Trigger.new, Trigger.newMap,Trigger.oldMap);
    //projTaskHelper.populateTaskProject(trigger.new);
    if(trigger.isUpdate)
    projTaskHelper.restrictTaskChangeOnBlockedProject(trigger.newMap, trigger.oldMap,trigger.new);
}