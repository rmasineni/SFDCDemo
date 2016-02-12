/************************************************************************************************************
Name    : trg_srattachment_before_ins
Author  : ZCloud Team
Date    : Mar, 2013
Description: Modify the EDP document signature status
************************************************************************************************************/

trigger trg_srattachment_before_ins on SR_Attachment__c (before insert, before update) {

	try{

		Set<SR_Attachment__c> srAttachments = new Set<SR_Attachment__c> ();
		Set<Id> proposalIds = new Set<Id>();
		Set<Id> scIds = new Set<Id>();
		List<SR_Attachment__c> sungevitySRAttachments = new List<SR_Attachment__c>();
		Set<String> proposalNames = new Set<String>();
		for(SR_Attachment__c srAttachmentObj : Trigger.New){
			
			if(Trigger.isInsert){
				
				if(srAttachmentObj.Proposal__c != null){
					proposalIds.add(srAttachmentObj.Proposal__c);
				}else if(srAttachmentObj.Service_Contract__c != null){
					scIds.add(srAttachmentObj.Service_Contract__c);
				}
					
				if(srAttachmentObj.Partner_Name__c != null && srAttachmentObj.Partner_Name__c == 'Sungevity' 
					&& srAttachmentObj.Parent_Proposal_Name__c != null && srAttachmentObj.Parent_Proposal_Name__c != ''){
					sungevitySRAttachments.add(srAttachmentObj);
					proposalNames.add(srAttachmentObj.Parent_Proposal_Name__c);
				}
			}
			
			if(Trigger.isInsert 
				&& (srAttachmentObj.Document_Source__c == EDPUtil.PROPOSAL_TOOL_SOURCE 
					|| srAttachmentObj.Document_Name_On_File_Server__c == null 
					|| srAttachmentObj.Document_Name_On_File_Server__c == '')){
				srAttachmentObj.Document_Name_On_File_Server__c = srAttachmentObj.Document_Name__c;
			}
	
			if(Trigger.isInsert || 
				(Trigger.isUpdate && srAttachmentObj.Proposal_Document_Type__c != Trigger.oldMap.get(srAttachmentObj.Id).Proposal_Document_Type__c)){
				srAttachments.add(srAttachmentObj);
			}
		}
		if(proposalNames != null && !proposalNames.isEmpty()){
			EDPDocumentSettings.processSugevitySRAttchments(sungevitySRAttachments, proposalNames, proposalIds);
		}

		if(srAttachments.size() > 0 ){
			EDPDocumentSettings.updateDocumentType(srAttachments);
		}
		
		System.debug('proposalIds: ' + proposalIds);
		
		if(Trigger.isInsert ){
			EDPDocumentSettings.setSRAttachmentDefaultSignedStatus(Trigger.New, proposalIds, scIds);
		}
		
		if(proposalNames != null && !proposalNames.isEmpty()){
			EDPDocumentSettings.setDefaultValuesForSugevitySRAttchments(sungevitySRAttachments);
		}
		
		
	}catch(Exception exceptionObj){
		System.debug('Before: SR Attachment: ' + exceptionObj);
		for (SR_Attachment__c srAttachment : Trigger.new){
			srAttachment.adderror(exceptionObj.getMessage());
		}
	}
}