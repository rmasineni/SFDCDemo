trigger ERPContactsTrigger on Contact (before insert, after insert, before update, after update) {

Boolean skipValidations = false;
skipValidations = SkipTriggerValidation.performTriggerValidations();
  if(skipValidations == false)
  {
     Sf.ambassadorSyncService.handleERPContacts();  
     Sf.ambassadorSyncService.handleInactiveRefereeContacts();
  }   
   
}