trigger trg_after_docusign_recipient_status_ins_upd on dsfs__DocuSign_Recipient_Status__c (after insert, after update) {

	Map<String, dsfs__DocuSign_Recipient_Status__c> docuSignRecipientStatusMap1 = new Map<String, dsfs__DocuSign_Recipient_Status__c>();
	Map<String, dsfs__DocuSign_Recipient_Status__c> docuSignRecipientStatusMap2 = new Map<String, dsfs__DocuSign_Recipient_Status__c>();
	Map<String, String> recipientEnvelopMap = new Map<String, String>();
	Set<String> emailIdSet = new Set<String>();
	Set<String> envelopIdSet = new Set<String>();
	for(dsfs__DocuSign_Recipient_Status__c docuSignRecipientStatusObj : Trigger.new){
		dsfs__DocuSign_Recipient_Status__c oldStatusObj;
		if(Trigger.isUpdate){
			oldStatusObj = Trigger.oldMap.get(docuSignRecipientStatusObj.Id);
		}

		if(Trigger.isInsert 
			||  (Trigger.isUpdate && oldStatusObj != null && (oldStatusObj.dsfs__Recipient_Status__c != docuSignRecipientStatusObj.dsfs__Recipient_Status__c))){
			if(docuSignRecipientStatusObj.dsfs__Recipient_Status__c == Edputil.COMPLETED && 
				!eSignServiceNew.processedEnvelopIds.contains(docuSignRecipientStatusObj.dsfs__Envelope_Id__c)){
				eSignServiceNew.processedEnvelopIds.add(docuSignRecipientStatusObj.dsfs__Envelope_Id__c);
				envelopIdSet.add(docuSignRecipientStatusObj.dsfs__Envelope_Id__c);		
				recipientEnvelopMap.put(docuSignRecipientStatusObj.dsfs__DocuSign_Recipient_Id__c, docuSignRecipientStatusObj.dsfs__Envelope_Id__c);				
			}
		}
	}

	System.debug('envelopIdSet: ' + envelopIdSet);
	if(envelopIdSet.size() > 0 ){		
		eSignServiceNew.updateESignDocuments(envelopIdSet);
	}
	
	try{
		System.debug('recipientEnvelopMap: ' + recipientEnvelopMap);
		if(recipientEnvelopMap.size() > 0 ){
			DocuSignUtil.updateProposals(recipientEnvelopMap);
		}		
	}catch(Exception exptionObj){
		System.debug('trg_after_docusign_recipient_status_ins_upd Exception: ' + exptionObj);
		if(recipientEnvelopMap.size() > 0 ){
			DocuSignUtil.updateProposalsAsynchronously(recipientEnvelopMap);
			DocuSignUtil.notifyProposalUpdateError(recipientEnvelopMap, exptionObj.getMessage());
		}
	}

}