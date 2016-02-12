trigger trg_SRGenAssetAttachment_after on SR_Gen_Asset_Attachment__c (after delete, after insert, after update) {

	Set<Id> scIds = new Set<Id>();
	if (Trigger.isDelete) {
        for(SR_Gen_Asset_Attachment__c srgenAttachmentObj :Trigger.old) {
			if(srgenAttachmentObj.Service_Contract__c != null){
				scIds.add(srgenAttachmentObj.Service_Contract__c);
			}
        }
    }else{
		for(SR_Gen_Asset_Attachment__c srgenAttachmentObj : Trigger.new){
			SR_Gen_Asset_Attachment__c oldAttachmentObj;
			if(Trigger.isUpdate){
				oldAttachmentObj = Trigger.oldMap.get(srgenAttachmentObj.Id);
			}
			if(srgenAttachmentObj.Service_Contract__c != null && 
				(Trigger.isInsert || 
				(Trigger.isUpdate && ( oldAttachmentObj.active__C != srgenAttachmentObj.active__c || srgenAttachmentObj.Service_Contract__c != oldAttachmentObj.Service_Contract__c)   ))){
				scIds.add(srgenAttachmentObj.Service_Contract__c);
			}
		
		}
	}
	
	System.debug('scIds: ' + scIds);
	
	if(!Test.isRunningTest() && scIds != null && !scIds.isEmpty()){
		ServiceContractUtil.updateNumberOfPhotosForServiceContracts(scIds);
	}
}