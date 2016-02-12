trigger API_Request_Log_Trigger on API_Request_Log__c (before insert, after insert, before update, after update) {

    Boolean skipValidations = false;
    skipValidations = SkipTriggerValidation.performTriggerValidations();
    
    if(skipValidations == false){ 
        
       Sf.homeDepotSyncService.handleAPIRequestLogTrigger();
       
       Sf.homeDepotSyncService.handleAPIRequestLogSCETrigger();
       
       if(Trigger.isAfter){
       sf.homeDepotSyncService.handleAPIRequestErrorLogTrigger();
       }
        
    }
}