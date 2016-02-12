trigger trg_scEvent_after_ins_upd on Service_Contract_Event__c (after insert, after update) {
     
    UpdateConstructionOpptyField.UpdateFields(Trigger.New, Trigger.oldMap);
    Boolean skipValidations = false;
    skipValidations = SkipTriggerValidation.performTriggerValidations();
    Set<Id> modifiedRelatedObjectIds = new Set<Id>();
    System.debug('skipValidations: ' + skipValidations);
    Set<Id> meterRegSCIds = new Set<Id>();
    if(skipValidations == false){
        if(Trigger.isafter){
            ReferralOfferSCEUtil.ReferralOfferSCEUtil(Trigger.isinsert, Trigger.isupdate, Trigger.new, Trigger.oldMap, Trigger.newMap.keyset());
            //UpdateConstructionOpptyField.UpdateFields(Trigger.New, Trigger.oldMap);
        }
         
        for(Service_Contract_Event__c scEventObj : Trigger.New){
        
        
            if(scEventObj.Service_Contract__c != null ){
                modifiedRelatedObjectIds.add(scEventObj.Id);
            }
            Service_Contract_Event__c oldSCEventObj;
            if(Trigger.isUpdate){
                oldSCEventObj = Trigger.oldMap.get(scEventObj.Id);
            }
            ServiceContractUtil.trackFieldChanges(scEventObj, oldSCEventObj);
        }
    
        System.debug('modifiedRelatedObjectIds: ' + modifiedRelatedObjectIds);
        if(modifiedRelatedObjectIds != null && !modifiedRelatedObjectIds.isEmpty()){
            ServiceContractUtil.updateServiceContractsForEvents(modifiedRelatedObjectIds, datetime.now());
        }
        
        ServiceContractUtil.insertAuditTrail();
        Referral_SCE_SalesRepEmailUtil.updateSalesRepEmail(trigger.isInsert,trigger.isUpdate,trigger.new,trigger.oldMap);
        if(Trigger.isupdate){
          RefferalStatusUpdate.updateNTPReached(trigger.new,trigger.oldMap);
          ServiceContractUtil.photoreq(trigger.new, trigger.oldmap, trigger.newmap);
          Sf.costcoSyncService.handleServiceContractsTrigger();
          sf.HomeDepotSyncService.handleSCEventsTrigger();
        }
        
    }
}