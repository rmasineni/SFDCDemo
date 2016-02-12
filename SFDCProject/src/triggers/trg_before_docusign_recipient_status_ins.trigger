trigger trg_before_docusign_recipient_status_ins on dsfs__DocuSign_Recipient_Status__c (before insert, before update) {

	Set<String> recipientNames = new Set<String>();
	Set<String> envelopIds = new Set<String>();
	for(dsfs__DocuSign_Recipient_Status__c docuSignRecipientStatusObj : Trigger.new){
		dsfs__DocuSign_Recipient_Status__c oldStatusObj;
		if(Trigger.isUpdate){
			oldStatusObj = Trigger.oldMap.get(docuSignRecipientStatusObj.Id);
		}

		if(Trigger.isInsert 
			|| (Trigger.isUpdate && docuSignRecipientStatusObj.In_Person_Email_Id__c == null || docuSignRecipientStatusObj.In_Person_Email_Id__c  == '')){

			if(docuSignRecipientStatusObj.Name != null && docuSignRecipientStatusObj.dsfs__Envelope_Id__c != null){
				recipientNames.add(docuSignRecipientStatusObj.Name);
				envelopIds.add(docuSignRecipientStatusObj.dsfs__Envelope_Id__c);
			}
		}
	}
	Map<String, In_Person_Recipient__c> recipientMap = new Map<String, In_Person_Recipient__c>();
	if(recipientNames.size() > 0){
		for(In_Person_Recipient__c inpersonObj : [Select Signer_Name__c, Signer_Email__c, Envelop_Id__c, Host_Email__c, 	
													Host_Name__c from In_Person_Recipient__c where Envelop_Id__c in :envelopIds 
													and Signer_Name__c in :recipientNames]){
			recipientMap.put(inpersonObj.Signer_Name__c, inpersonObj);		
		}

		for(dsfs__DocuSign_Recipient_Status__c docuSignRecipientStatusObj : Trigger.new){
			dsfs__DocuSign_Recipient_Status__c oldStatusObj;
			if(Trigger.isUpdate){
				oldStatusObj = Trigger.oldMap.get(docuSignRecipientStatusObj.Id);
			}
	
			if(Trigger.isInsert 
				|| (Trigger.isUpdate && docuSignRecipientStatusObj.In_Person_Email_Id__c == null || docuSignRecipientStatusObj.In_Person_Email_Id__c  == '')){

				if(docuSignRecipientStatusObj.Name != null && docuSignRecipientStatusObj.dsfs__Envelope_Id__c != null){
					if(recipientMap.containsKey(docuSignRecipientStatusObj.Name)){
						In_Person_Recipient__c tempInpersonObj = recipientMap.get(docuSignRecipientStatusObj.Name);
						docuSignRecipientStatusObj.In_Person_Email_Id__c = tempInpersonObj.Signer_Email__c;
					}
				}
			}
		}
	}

}