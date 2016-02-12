trigger trg_after_docusign_status_ins on dsfs__DocuSign_Status__c (before insert, before update) {

	Map<String, dsfs__DocuSign_Status__c> docuSignMap = new Map<String, dsfs__DocuSign_Status__c>();
	Set<String> envelopIdSet = new Set<String>();
	List<String> voidedEnvelopIds = new List<String>();
	for(dsfs__DocuSign_Status__c docuSignStatusObj : Trigger.new){
		if(docuSignStatusObj.dsfs__DocuSign_Envelope_ID__c != null 
			&& docuSignStatusObj.dsfs__DocuSign_Envelope_ID__c != ''){
			String envelopId = docuSignStatusObj.dsfs__DocuSign_Envelope_ID__c.replaceall('-', '');
			docuSignMap.put(envelopId, docuSignStatusObj);	
			envelopIdSet.add(docuSignStatusObj.dsfs__DocuSign_Envelope_ID__c);
		}
		//Voided
		//Declined
		if(docuSignStatusObj.dsfs__Envelope_Status__c == 'Voided' 
			|| docuSignStatusObj.dsfs__Envelope_Status__c == 'Declined'){
			voidedEnvelopIds.add(docuSignStatusObj.dsfs__DocuSign_Envelope_ID__c);		
		}
	}
	
	String documentSource = EDPUtil.E_SIGN;
	List<SR_Attachment__c> updatedSRAttachments = new List<SR_Attachment__c>();
	for(SR_Attachment__c srAttachmentObj: [Select Id, DocuSign_Status__c, Envelop_Id__c, Parent_Proposal_Name__c, proposal__r.stage__c 
											from SR_Attachment__c where Active__c = true AND Document_Source__c =:documentSource 
											AND Envelop_Id__c in :envelopIdSet]){
		String envelopId = srAttachmentObj.Envelop_Id__c.replaceall('-', '');
		dsfs__DocuSign_Status__c docuSignStatusObj = docuSignMap.get(envelopId);
		if(docuSignStatusObj != null){
			srAttachmentObj.DocuSign_Status__c = docuSignStatusObj.dsfs__Envelope_Status__c;
			updatedSRAttachments.add(srAttachmentObj);
		}
		if(srAttachmentObj.proposal__r.stage__c != null &&
			srAttachmentObj.proposal__r.stage__c != EDPUtil.REPLACED_BY){
			docuSignStatusObj.SR_Attachment__c = srAttachmentObj.Id;	
		}
		
	}
	
	if(updatedSRAttachments.size() > 0 ){
		update updatedSRAttachments;
	}	
	System.debug('voidedEnvelopIds: ' + voidedEnvelopIds);
	if(voidedEnvelopIds.size() > 0){
		DocuSignUtil.resetCustomerSignOffDate(voidedEnvelopIds);
	}
}