trigger trg_contractarray_after_ins_upd on Contract_Array__c (after insert, after update) {
    Boolean skipValidations = false;
    skipValidations = SkipTriggerValidation.performTriggerValidations();
    Set<Id> modifiedRelatedObjectIds = new Set<Id>();
    System.debug('skipValidations: ' + skipValidations);
    if(skipValidations == false){
        
        for(Contract_Array__c caObj : Trigger.New){
            if(caObj.Asset__c != null ){
                modifiedRelatedObjectIds.add(caObj.Asset__c);
            }
        }
        System.debug('modifiedRelatedObjectIds: ' + modifiedRelatedObjectIds);
        if(modifiedRelatedObjectIds != null && !modifiedRelatedObjectIds.isEmpty()){
            ServiceContractUtil.updateServiceContractsForAsset(modifiedRelatedObjectIds, datetime.now());
        }
    }
}