@isTest(SeeAllData=true)
public class UnitTest_SRAttachmentESignController {

	public static testmethod void testSendEPCDocuments(){
		//Select Partner Account and Partner Contact
		String partnerAccountId = PartnerDetail__c.getValues('ApexTestAccount').PartnerAccountId__C;
		String partnerContactId = PartnerDetail__c.getValues('ApexTestAccount').PartnerContactId__C;
		String partnerSalesRepId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
		String salesRepEmail = PartnerDetail__c.getValues('ApexTestAccount').PartnerContactEmail__C;
		
		Account customerAccount;
		Contact primaryContact;
		Contact secondaryContact;
		Opportunity opprtunityObj;
		
		//Create Proposal		
		Proposal__C proposalObj = UnitTest_ProposalUtil.createProposal('1234 Fremont St CA', 'PFirstName1', 'PLastName1', 
											'PrimaryCustomer@gmail.com', '1234 Fremont St CA','P124124123-I', 
											23532, 23, 'Mode-1', salesRepEmail, partnerAccountId, partnerAccountId,
											customerAccount, primaryContact, secondaryContact, opprtunityObj);
		insert proposalObj;
		String envelopId1 = '';
		String proposalIdStr = '' + proposalObj.id;
		List<SR_Attachment__c> srAttachmentList = new List<SR_Attachment__c>();
		SR_Attachment__c srAttachmentObj1;

		Map<String, String> newAttachments = new Map<String, String>();
		//Create SR Attachment
		srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Customer Agreement', envelopId1, proposalIdStr, 
																	'TestFile01.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
		srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
		srAttachmentList.add(srAttachmentObj1);

		envelopId1 = '';
		srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('EPC', envelopId1, proposalIdStr, 
																	'TestFile02.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
		srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
		srAttachmentList.add(srAttachmentObj1);

		envelopId1 = '5335SDFF-43643-GSGA341';
		srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Utility Bill', envelopId1, proposalIdStr, 
																	'TestFile03.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
		srAttachmentObj1.DocuSign_Status__c = EDPUtil.WET_SIGNED;
		srAttachmentList.add(srAttachmentObj1);		
		newAttachments.put(srAttachmentObj1.Document_Classification__c, 'TestFile03.pdf');

		envelopId1 = '7335SDFF-43643-GSGA342';
		srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Large System Contract Approval Request', envelopId1, proposalIdStr, 
																	'TestFile04.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
		newAttachments.put(srAttachmentObj1.Document_Classification__c, 'TestFile04.pdf');
		srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
		srAttachmentList.add(srAttachmentObj1);			
		insert srAttachmentList;

		//Initiate eSignature
		System.currentPagereference().getParameters().put('id', proposalIdStr);
		SRAttachmentESignController eSignControllerObj = new SRAttachmentESignController();	
		eSignControllerObj.documentType = 'EPC';
		eSignControllerObj.displayPartnerSelection = true;
		eSignControllerObj.partnerContactObj.Partner_Contact__c = partnerContactId;
		eSignControllerObj.displayCustomerSelection = false;
		eSignControllerObj.sendToDocuSign();
		
		String sunrunOpsEmail = Label.SunRun_DocuSign_Email;
		eSignServiceNew.RecipientResponse responseObj1 = eSignServiceNew.getDocuSignRecipient(sunrunOpsEmail);
		eSignServiceNew.insertDocuSignRequestResponse(envelopId1, 'TestRequest','TestRequestBody', 'TestResponse','TestResponseBody');

		eSignServiceNew.EnvResponse responseObj2 = eSignServiceNew.getEmbeddedSigningURL(envelopId1, 1, '');

		eSignServiceNew.VoidResponse voidResponseObj = new eSignServiceNew.VoidResponse();
		
		Set<String> envelopIds = new Set<String>();
		envelopIds.add(envelopId1);
		eSignServiceNew.updateESignDocuments(envelopIds);
		
		srAttachmentList[3].DocuSign_Status__c = EDPUtil.SENT;
		update srAttachmentList[3];

		dsfs__DocuSign_Status__c docuSignStatus1 = UnitTest_ProposalUtil.CreateDocuSignStatus(envelopId1, EDPUtil.SENT);
		insert docuSignStatus1;
				
		eSignServiceNew.resendDocumentsToDocusign(srAttachmentList[3]);
		eSignServiceNew.voidEnvelopId(srAttachmentList[3]);
		
		SRAttachmentESignController.BaseException baseExp = new SRAttachmentESignController.BaseException();
		SRAttachmentVoidESignController voideSignObj = new SRAttachmentVoidESignController();
		voideSignObj.documentType = 'EPC';
		voideSignObj.voidReason = '';
		voideSignObj.voidDocuSignRequest();

		voideSignObj.documentType = '';
		voideSignObj.voidReason = 'Test123 ...';
		voideSignObj.voidDocuSignRequest();
		
		voideSignObj.documentType = 'EPC';
		voideSignObj.voidDocuSignRequest();
		
		eSignServiceNew.notifyDocumentRefreshError(srAttachmentList[0], '100', 'Test Description');

		String relatedObjectId1 = proposalObj.id;

		FileUploaderComponent.checkexistingSRAttachments(relatedObjectId1, newAttachments);	
	}

	public static testmethod void testSendCustomerAgreement(){

		Id userId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
		User partnerUser = [Select id, name, email from User where Id =:userId];		

		System.runAs(partnerUser){
				
		//Select Partner Account and Partner Contact
		String partnerAccountId = PartnerDetail__c.getValues('ApexTestAccount').PartnerAccountId__C;
		String partnerContactId = PartnerDetail__c.getValues('ApexTestAccount').PartnerContactId__C;
		String partnerSalesRepId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
		String salesRepEmail = PartnerDetail__c.getValues('ApexTestAccount').PartnerContactEmail__C;
		
		Account customerAccount;
		Contact primaryContact;
		Contact secondaryContact;
		Opportunity opprtunityObj;
		
		//Create Proposal		
		Proposal__C proposalObj = UnitTest_ProposalUtil.createProposal('1234 Fremont St CA', 'PFirstName1', 'PLastName1', 
											'PrimaryCustomer@gmail.com', '1234 Fremont St CA','P124124123-I', 
											23532, 23, 'Mode-1', salesRepEmail, partnerAccountId, partnerAccountId,
											customerAccount, primaryContact, secondaryContact, opprtunityObj);
		insert proposalObj;
		opprtunityObj = [Select Id, name, accountId from Opportunity where id =:proposalObj.Opportunity__c];
		customerAccount = [Select Id, name,(Select Id, name, email from Contacts) from Account where Id =:opprtunityObj.accountId];
		primaryContact = customerAccount.contacts[0];
		secondaryContact = customerAccount.contacts[1];
		
		String envelopId1 = '';
		String proposalIdStr = '' + proposalObj.id;
		List<SR_Attachment__c> srAttachmentList = new List<SR_Attachment__c>();
		SR_Attachment__c srAttachmentObj1;
		
		List<OpportunityContactRole> contactRolelist = new List<OpportunityContactRole>();
		OpportunityContactRole contactRoleObj = new OpportunityContactRole();
		contactRoleObj.ContactId = primaryContact.Id;
		contactRoleObj.OpportunityId = opprtunityObj.Id;
		contactRoleObj.Role = 'Homeowner';
		contactRoleObj.IsPrimary = true;
		contactRolelist.add(contactRoleObj);
		
		contactRoleObj = new OpportunityContactRole();
		contactRoleObj.ContactId = secondaryContact.Id;
		contactRoleObj.OpportunityId = opprtunityObj.Id;
		contactRoleObj.Role = 'Other';
		contactRolelist.add(contactRoleObj);
		insert contactRolelist;
						
		//Create SR Attachment
		srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Customer Agreement', envelopId1, proposalIdStr, 
																	'TestFile01.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
		srAttachmentObj1.DocuSign_Status__c = '';
		srAttachmentList.add(srAttachmentObj1);

		envelopId1 = '';
		srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('EPC', envelopId1, proposalIdStr, 
																	'TestFile02.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
		srAttachmentObj1.DocuSign_Status__c = '';
		srAttachmentList.add(srAttachmentObj1);

		envelopId1 = '5335SDFF-43643-GSGA341';
		srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Utility Bill', envelopId1, proposalIdStr, 
																	'TestFile03.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
		srAttachmentObj1.DocuSign_Status__c = EDPUtil.WET_SIGNED;
		srAttachmentList.add(srAttachmentObj1);		

		envelopId1 = '7335SDFF-43643-GSGA342';
		srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Large System Contract Approval Request', envelopId1, proposalIdStr, 
																	'TestFile04.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
		srAttachmentObj1.Wet_Sign_Status__c = EDPUtil.SIGNED;
		srAttachmentList.add(srAttachmentObj1);			
		insert srAttachmentList;
			//Initiate eSignature
			System.currentPagereference().getParameters().put('id', proposalIdStr);
			SRAttachmentESignController eSignControllerObj = new SRAttachmentESignController();	
			eSignControllerObj.documentType = 'Customer Agreement';
			eSignControllerObj.displayPartnerSelection = true;
			eSignControllerObj.partnerContactObj.Partner_Contact__c = partnerContactId;
			eSignControllerObj.setPartnerEmail();
			eSignControllerObj.getDocumentType();
			
			eSignControllerObj.displayCustomerSelection = true;
			eSignControllerObj.primaryContactId = primaryContact.Id;
			eSignControllerObj.setPrimaryContactEmail();
			eSignControllerObj.setPartnerEmail();
			eSignControllerObj.verifyWetSignature();
			eSignControllerObj.secondaryContactId = secondaryContact.Id;
			eSignControllerObj.setSecondaryContactEmail();
			eSignControllerObj.intializeValues();
			eSignControllerObj.sendToDocuSign();
			eSignControllerObj.documentType = 'Customer Agreement - Unsigned';
			eSignControllerObj.getDisplayCustomerSigner();
			
			eSignControllerObj.wetSignature = true;
			eSignControllerObj.verifyWetSignature();
			
			try{
				eSignControllerObj.displayCustomerSelection = true;
				eSignControllerObj.primaryContactId = null;
				eSignControllerObj.setPrimaryContactEmail();				
				primaryContact.email = null;
				update primaryContact;
				eSignControllerObj.sendToDocuSign();
			}catch(Exception expObj){
				
			}

			try{
				secondaryContact.email = null;
				update secondaryContact;
				eSignControllerObj.sendToDocuSign();
			}catch(Exception expObj){
				
			}

			try{
				eSignControllerObj.displayPartnerSelection = true;
				eSignControllerObj.partnerContactObj.Partner_Contact__c = null;
				eSignControllerObj.sendToDocuSign();
			}catch(Exception expObj){
				
			}

			
			try{
				primaryContact.email = null;
				update primaryContact;
				eSignControllerObj.sendToDocuSign();
			}catch(Exception expObj){
				
			}
			
			try{
				eSignControllerObj.documentType = null;
				eSignControllerObj.sendToDocuSign();
			}catch(Exception expObj){
				
			}

			try{
				eSignControllerObj.documentType = 'Customer Agreement';
				eSignControllerObj.displayPartnerSelection = true;
				eSignControllerObj.partnerContactObj.Partner_Contact__c = null;
				eSignControllerObj.sendToDocuSign();
			}catch(Exception expObj){
				
			}

			try{
				Partner_Document_Relationship__c ptrRelationshipObj = new Partner_Document_Relationship__c();
				ptrRelationshipObj.Partner_signature_required__c = true;
				eSignControllerObj.displayCustomerSelection = true;
				eSignControllerObj.partnerContactObj.Partner_Contact__c = partnerContactId;
				eSignControllerObj.primaryContactId = null;
				eSignControllerObj.sendToDocuSign();
			}catch(Exception expObj){
				
			}

			try{
				eSignControllerObj.documentType = 'Customer Agreement';
				srAttachmentList[0].Envelop_Id__c   = '3453532-235325235123';
				srAttachmentList[0].DocuSign_Status__c = EDPUtil.SENT;
				update srAttachmentList[0];
				eSignControllerObj.sendToDocuSign();
			}catch(Exception expObj){
				
			}				
		}
	}
	
	public static testmethod void testException(){
		Exception expObj = new SRAttachmentESignController.BaseException();
		expObj.setMessage(CustomErrorMessages.MAXIMUM_REQUEST_SIZE);
		eSignServiceNew.processException(expObj);	

		expObj.setMessage('Test Message');
		eSignServiceNew.processException(expObj);

	}
	
}