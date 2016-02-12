trigger trg_Asset_after_Ins_Update on Asset__c (after insert, after update) {
	Boolean skipValidations = false;
	skipValidations = SkipTriggerValidation.performTriggerValidations();
	Set<Id> modifiedAssetIds = new Set<Id>();
	if(skipValidations == false){

	    Set<Id> scIds = new Set<Id>();
	    for(Asset__c assetObj : Trigger.New){
	        Asset__c oldAssetObj;
	        if(Trigger.isUpdate){
	            oldAssetObj = Trigger.oldmap.get(assetObj.Id);
	        }
	        
	       // if(assetObj.System_Size_DC__c != null && assetObj.System_Size_DC__c > 0 && 
	       //     assetObj.Status__c == 'Active' && assetObj.Type__c == 'Asset' &&
	        //    (Trigger.isInsert || (Trigger.isUpdate && assetObj.System_Size_DC__c != oldAssetObj.System_Size_DC__c))){
	       //     scIds.add(assetObj.servicecontract__c);
	        //}
	        
	        if((assetObj.type__c != null && (assetObj.type__c == ServiceContractUtil.ASSET || assetObj.type__c == ServiceContractUtil.ASSET_TYPE_METER)
	        	&& assetObj.ServiceContract__c != null)){
	       		modifiedAssetIds.add(assetObj.Id);
	        }
	    }
	    
	    //if(!scIds.isEmpty()){
	    //    List<ServiceContract>  serviceContracts = ServiceContractUtil.getServiceContracts(scIds);
	    //    List<ServiceContract> modifiedSCList = ServiceContractUtil.calculateTransferPrice(scIds, serviceContracts);
	   //     if(modifiedSCList != null && !modifiedSCList.isEmpty()){
	    //        update modifiedSCList;
	    //    }
	    //}
	    
	    ArrayInfoUtil.arrayInfocontractarray(trigger.isinsert,trigger.isupdate,Trigger.new, Trigger.oldMap);
	    if(modifiedAssetIds != null && !modifiedAssetIds.isEmpty()){
	    	ServiceContractUtil.updateServiceContractsForAsset(modifiedAssetIds, datetime.now());
	    }
	}
	
}