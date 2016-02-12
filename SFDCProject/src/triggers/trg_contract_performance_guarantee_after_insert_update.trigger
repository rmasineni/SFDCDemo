trigger trg_contract_performance_guarantee_after_insert_update on Contract_Performance_Guarantee__c (after insert, after update) {

	Boolean skipValidations = false;
	skipValidations = SkipTriggerValidation.performTriggerValidations();
	Set<Id> modifiedRelatedObjectIds = new Set<Id>();
	if(skipValidations == false){
		for(Contract_Performance_Guarantee__c contractPerformanceGuaranteeObj : Trigger.New){
			if(contractPerformanceGuaranteeObj.Service_Contract__c != null ){
	       		modifiedRelatedObjectIds.add(contractPerformanceGuaranteeObj.Id);
	        }
	    }
	    if(modifiedRelatedObjectIds != null && !modifiedRelatedObjectIds.isEmpty()){
	    	ServiceContractUtil.updateServiceContractsForContractPG(modifiedRelatedObjectIds, datetime.now());
	    }
	}

}