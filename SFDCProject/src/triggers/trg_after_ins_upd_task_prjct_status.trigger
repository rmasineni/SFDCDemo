trigger trg_after_ins_upd_task_prjct_status on Phase__c (after insert, after update) {
projTaskHelper.updateProjectStatus(trigger.newMap, trigger.oldMap);
//new AuditServiceImpl().captureAudit(Trigger.old, Trigger.new);
}