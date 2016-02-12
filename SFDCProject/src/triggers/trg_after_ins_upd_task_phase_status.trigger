trigger trg_after_ins_upd_task_phase_status on Task__c (after insert, after update) {
    
    wfUtil.processAfterTaskUpdate(Trigger.isInsert, Trigger.isUpdate, Trigger.new, Trigger.newMap,Trigger.oldMap);
    projTaskHelper.updatePhaseStatus(trigger.newMap, trigger.oldMap);
    system.debug('updateUtilityDelayUntilDate>>>');
     projTaskHelper.updateUtilityDelayUntilDate(Trigger.isInsert, Trigger.isUpdate,trigger.newMap, trigger.oldMap);
   // new AuditServiceImpl().captureAudit(Trigger.old, Trigger.new);
     if(trigger.isUpdate)
        projTaskHelper.updateSCEFields(trigger.newMap, trigger.oldMap);
}