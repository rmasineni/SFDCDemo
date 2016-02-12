trigger trg_bef_ins_upd_project on Project__c (before insert, before update) {
  
    if(trigger.isUpdate)
   projTaskHelper.cancelTasks(trigger.newMap, trigger.oldMap);   
}