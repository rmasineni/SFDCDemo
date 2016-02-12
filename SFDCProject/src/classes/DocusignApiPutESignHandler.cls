public class DocusignApiPutESignHandler extends ProposalBaseHandler{

	override public String getApiName() {
        return 'eSign';
    }

	public void validateRequest(RestServiceDto.Request req) {
        List<String> requriedFields = new List<String>();
        requriedFields.add('proposalId');
        requriedFields.add('action');
		validateRequiredFields(requriedFields, req);
	}

    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
		String testMode = req.jsonReader.getString('testMode');
		resp.jsonWriter = new JsonWriter(true);
		
		validateRequest(req);
			
		String proposalName = req.jsonReader.getString('proposalId');
		String action = req.jsonReader.getString('action');
		String documentType = req.jsonReader.getString('documentType');
		String eSignOption = req.jsonReader.getString('eSignatureType');

		Map<String, Document_Classification__c> documentClassificationMap = EDPDocumentSettings.getDocumentClassificationByName();
		Proposal__c proposalObj = getProposalByName(proposalName);
		
		if(documentClassificationMap == null || !documentClassificationMap.containskey(documentType)){
        	throw createBusinessException(RestServiceDto.Error_InvalidRequest, 'Invalid document type ['+ documentType +']');
		}

		if(action != 'initiate' && action != 'void'){
			throw createBusinessException(RestServiceDto.Error_InvalidRequest, 'Invalid action ['+ action +']. Valid action values are \'initiate\', \'void\'');
		}
		if(eSignOption != 'INPERSON' && eSignOption != 'EMAIL'){
			throw createBusinessException(RestServiceDto.Error_InvalidRequest, 'Invalid eSignatureType ['+ eSignOption +']. Valid eSignatureType values are \'INPERSON\', \'EMAIL\'');
		}

		if(proposalObj == null){
			throw createBusinessException(RestServiceDto.Error_InvalidRequest, 'Invalid proposalId ['+ proposalName +']');
		}
					
		Document_Classification__c docClassificationObj = documentClassificationMap.get(documentType);
		if(action == 'initiate'){
			initiateESignature(proposalObj, docClassificationObj, eSignOption ,resp);
		}else if(action == 'void'){
			voidESignature(proposalObj, docClassificationObj, resp);
		}

    }
    
    public void voidESignature(Proposal__c proposalObj, Document_Classification__c docClassificationObj, RestServiceDto.Response resp){
		
		SR_Attachment__c srAttachmentObj = getSRAttachmentWithEnvelopId(proposalObj.Id, docClassificationObj.Id);
		if(srAttachmentObj == null || srAttachmentObj.Envelop_Id__c == null || 
			srAttachmentObj.Envelop_Id__c == '' || srAttachmentObj.DocuSign_Status__c == 'Voided'){
            throw createBusinessException(RestServiceDto.Error_ValidationError,  'No eSignatures are pending for the Proposal [' + proposalObj.name + '] ');               
		}		
		String voidResult = validateAndExecuteVoidRequest(srAttachmentObj);
		System.debug('voidResult: ' + voidResult);
		if(voidResult != null){
			resp.jsonWriter.write('Void Result', voidResult);   
		}
		   	
    }

	public String validateAndExecuteVoidRequest(SR_Attachment__c srAttachment){
		String result = 'SUCCESS';
		Set<String> proposalStagesAllowedForVoid = new Set<String>();
        Set<String> proposalStagesNotAllowedForVoid = new Set<String>();
        Set<String> proposalStagesForConditionalVoid = new Set<String>();
        
        proposalStagesNotAllowedForVoid.add(EDPUtil.REPLACED_BY);
        proposalStagesNotAllowedForVoid.add(EDPUtil.WITH_DRAWN);
        proposalStagesNotAllowedForVoid.add(EDPUtil.SR_OPS_APPROVED);
        proposalStagesNotAllowedForVoid.add(EDPUtil.SR_DECLINED);
        proposalStagesNotAllowedForVoid.add(EDPUtil.EXPIRED);
        
        proposalStagesAllowedForVoid.add(EDPUtil.CREATED);
        proposalStagesAllowedForVoid.add(EDPUtil.ON_HOLD);
        proposalStagesAllowedForVoid.add(EDPUtil.PENDING);
        proposalStagesAllowedForVoid.add(EDPUtil.READY_FOR_SUBMISSION);

        proposalStagesForConditionalVoid.add(EDPUtil.SUBMITTED);
        proposalStagesForConditionalVoid.add(EDPUtil.SR_OPS_RECEIVED);
        proposalStagesForConditionalVoid.add(EDPUtil.SR_OPS_REVIEWED);
        proposalStagesForConditionalVoid.add(EDPUtil.CREDIT_REVIEW);
        proposalStagesForConditionalVoid.add(EDPUtil.CREDIT_APPROVED);
        proposalStagesForConditionalVoid.add(EDPUtil.SR_SIGNOFF_REVIEW);
        proposalStagesForConditionalVoid.add(EDPUtil.PENDING_TASK_COMPLETED);
        
        Set<String> modes = new Set<String>();
        modes.add(EDPUtil.READ);
        modes.add(EDPUtil.EDIT);
		System.debug('srAttachment.proposal__r.stage__c: ' + srAttachment.proposal__r.stage__c);
		Contact contactObj = PRMContactUtil.getLoginUserAccountAndContact();
        if(!String.isEmpty(srAttachment.proposal__r.stage__c)  && contactObj != null && contactObj.Id != null){
            if(proposalStagesForConditionalVoid.contains(srAttachment.proposal__r.stage__c)){
                Map<String, Document_Classification__c> documentClassificationMap;
                documentClassificationMap = EDPDocumentSettings.getDocumentClassificationByCategroy(null,EDPDocumentSettings.MANDATORY_REQUIREMENTS,
                                                                                                    modes, srAttachment.proposal__r.Sales_Partner__c, 
                                                                                                    srAttachment.proposal__r.Install_Partner__c);
                Document_Classification__c documentClassificationObj = documentClassificationMap.get(srAttachment.Document_Type_Name__c);
                
                System.debug('documentClassificationObj: ' + documentClassificationObj);
                Partner_Document_Relationship__c ptrDocRelObj;
                if(documentClassificationObj != null && documentClassificationObj.Partner_Document_Relationships__r != null 
                    && documentClassificationObj.Partner_Document_Relationships__r.size() > 0){
                    ptrDocRelObj = documentClassificationObj.Partner_Document_Relationships__r[0];
                }
                System.debug('ptrDocRelObj: ' + ptrDocRelObj);
                if(ptrDocRelObj != null && ptrDocRelObj.Mandatory_Document__c == true){
                    String errorMessage = 'The proposal is under review and eSign requests can\'t be voided at this time';
					throw createBusinessException(RestServiceDto.Error_ValidationError, errorMessage);                    
                }
            }else if(proposalStagesNotAllowedForVoid.contains(srAttachment.proposal__r.stage__c) || 
                !proposalStagesAllowedForVoid.contains(srAttachment.proposal__r.stage__c)){
                String errorMessage = 'Invalid proposal stage to void the selected document';
				throw createBusinessException(RestServiceDto.Error_ValidationError, errorMessage);               
            } 
        }
		
		if(!Test.isRunningTest()){
			result = eSignServiceNew.voidEnvelopId(srAttachment);
		}else{
			result = 'SUCCESS';
		}
		
		if(result != 'SUCCESS'){
			throw createBusinessException(RestServiceDto.Unable_To_Process_Request, result);        			
		}
		
		try{
			srAttachment.Envelop_Id__c = '';
			srAttachment.DocuSign_Status__c = 'Voided';
			srAttachment.DocuSign_Error_Code__c  = '';
			srAttachment.DocuSign_Error_Message__c = '';
	    	update srAttachment;		
	
			Proposal__c proposalObj = srAttachment.proposal__r;
	        if(ProposalUtil.canUpdateProposalSignedStatus(proposalObj, srAttachment.Document_Type_Name__c) == true){
	            proposalObj.signed__c = false;
	            update  proposalObj;
	        }
		}catch(Exception expObj){
			throw createBusinessException(RestServiceDto.Unable_To_Process_Request, expObj.getMessage()); 
		}
		return result;
	}
	
	public void initiateESignature(Proposal__c proposalObj, Document_Classification__c docClassificationObj, String eSignOption, RestServiceDto.Response resp){

		Contact primaryContact;
		Contact secondaryContact;
		Contact partnerContact;
		String sunrunRecipientName = '';
		String sunrunRecipientEmail = '';
		String hostName = '';
		String hostEmail = '';

		Set<String> docuSignStatus = new Set<String>();
		docuSignStatus.add(EDPUtil.VOIDED);
		docuSignStatus.add(EDPUtil.NOT_SENT);

		String proposalId = proposalObj.Id;
		Map<String, Contact> contactMap = getOptyContacts(proposalObj.Opportunity__c);

		SR_Attachment__c srAttachment = DocuSignUtil.getSRAttachment(proposalObj.Id, docClassificationObj.Document_Name__c);
		if(srAttachment != null && srAttachment.Envelop_Id__c != null && srAttachment.Envelop_Id__c != '' && !docuSignStatus.contains(srAttachment.DocuSign_Status__c)){
			throw createBusinessException(RestServiceDto.Error_ValidationError, 'eSignature request is in progress or completed for the requested document');
		}
		
		String partnerType = EDPUtil.getPartnerType(proposalObj, proposalObj.Sales_Partner__c);
		List<Partner_Document_Relationship__c> partnerDocumentRelationships =  docClassificationObj.Partner_Document_Relationships__r;
		System.debug('partnerDocumentRelationships: ' + partnerDocumentRelationships);
		System.debug('contactMap: ' + contactMap);
		if(partnerDocumentRelationships != null && partnerDocumentRelationships.size() > 0){
			Partner_Document_Relationship__c ptrRelationshipObj = getPartnerDocumentRelationship(partnerDocumentRelationships, partnerType);
			if(ptrRelationshipObj != null && ptrRelationshipObj.SR_Ops_signature_required__c == true){
				sunrunRecipientName = Label.SunRun_DocuSign_User;
				sunrunRecipientEmail = Label.SunRun_DocuSign_Email;					
			}
				
			System.debug('ptrRelationshipObj: ' + ptrRelationshipObj);
			if(ptrRelationshipObj != null && ptrRelationshipObj.Partner_signature_required__c == true){
				Contact loginContact = PRMContactUtil.getLoginUserAccountAndContact();
				System.debug('loginContact: ' + loginContact);
				if(PRMContactUtil.isPartnerContact(loginContact)){
					partnerContact = loginContact;
					hostName = (loginContact.account.DocuSign_Host_Name__c != null) ? loginContact.account.DocuSign_Host_Name__c : '';
					hostEmail = (loginContact.account.DocuSign_Host_Email__c != null) ? loginContact.account.DocuSign_Host_Email__c : '' ;
				}
			}
			if(ptrRelationshipObj != null && ptrRelationshipObj.Customer_signature_required__c == true && contactMap != null){
				if(contactMap.containsKey(HOMEOWNER_PRIMARY)){
					primaryContact = contactMap.get(HOMEOWNER_PRIMARY);
				}else{
					List<Contact> contacts = contactMap.values();
					if(contacts != null && !contacts.isEmpty()){
						primaryContact = contacts[0];
					}
				}					
			}
		}
		
		eSignServiceNew.EnvResponse response;
		if(!Test.isRunningTest()){
			System.debug('hostName: ' + hostName);
			System.debug('hostEmail: ' + hostEmail);
			System.debug('primaryContact: ' + primaryContact);
			System.debug('partnerContact: ' + partnerContact);
			response = eSignServiceNew.sendDocumentsToDocusign(proposalId, docClassificationObj.Document_Name__c, eSignOption, 
																						hostName,hostEmail, primaryContact, secondaryContact, partnerContact, 
																						sunrunRecipientName,sunrunRecipientEmail);
		}else{
			response = new eSignServiceNew.EnvResponse();
			response.envelopeId = '73D3C540-6164-46C6-B669-AE07622FB239';
		}
		
		System.debug('response: ' + response);
		if(String.isEmpty(response.errorCode)){
			resp.jsonWriter.write('envelopeId', response.envelopeId);   
		}else{
			throw createBusinessException(RestServiceDto.Unable_To_Process_Request, response.message);
		}			
	}

}