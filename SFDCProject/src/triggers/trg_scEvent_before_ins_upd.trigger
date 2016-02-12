trigger trg_scEvent_before_ins_upd on Service_Contract_Event__c (before insert, before update) {
    Boolean skipValidations = false;
    String HomeDepot = 'Home Depot';
    String ToBeSynced = 'To Be Synced';
    skipValidations = SkipTriggerValidation.performTriggerValidations();
    if(skipValidations == false){
        ServiceContractUtil.updateSCEvents(trigger.isInsert, trigger.isUpdate, Trigger.new, Trigger.newMap, Trigger.oldmap);
        if(Trigger.isupdate){
            Sf.costcoSyncService.handleServiceContractsTrigger();
        }
     for(Service_Contract_Event__c sce : Trigger.new){
      if(Trigger.isUpdate && sce.M2_proof_substantial_completion__c != null && sce.M2_proof_substantial_completion__c != Trigger.oldMap.get(sce.Id).M2_proof_substantial_completion__c && sce.Lead_Source__c == HomeDepot){
        sce.External_Sync_System__c = HomeDepot;
        sce.External_Sync_Status__c = ToBeSynced;
        sf.HomeDepotSyncService.handleSCEventsTrigger();
      }
     }
    }
}