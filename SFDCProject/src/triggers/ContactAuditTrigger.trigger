trigger ContactAuditTrigger on Contact (after insert, after update, after delete) {
    
 Boolean skipValidations = false;
 skipValidations = SkipTriggerValidation.performTriggerValidations();
    
  if(skipValidations == false){
     
    Sf.auditService.captureSobjectAudit(Trigger.old, Trigger.new);
    if(Trigger.isUpdate && Trigger.isAfter){
        Sf.homeDepotSyncService.handleContactsTrigger();    
    }
  }  
}