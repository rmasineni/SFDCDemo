trigger trg_after_ins_upd_prjct on Project__c (after insert, after update) {
  new AuditServiceImpl().captureAudit(Trigger.old, Trigger.new);
    if(trigger.isUpdate)
       projTaskHelper.reOpenedProject(trigger.newMap, trigger.oldMap);   
}