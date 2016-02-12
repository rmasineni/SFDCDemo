trigger ContactTrigger on Contact (before insert, before update, after insert, after update) {

  Boolean skipValidations = False;
  skipValidations = SkipTriggerValidation.performTriggerValidations();
  if(skipValidations == false){
  
    Sf.awsSyncService.handleContactsTrigger();    
 
    if(Trigger.isUpdate && Trigger.isAfter){
        Sf.homeDepotSyncService.handleContactsTrigger();    
    }
  }  
}