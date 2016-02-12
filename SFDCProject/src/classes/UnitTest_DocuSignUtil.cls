@isTest(SeeAllData=true)
public class UnitTest_DocuSignUtil {
	

	public static testmethod void testDocuSignStatus(){
		
		Account a = new Account(name='Test Acct1');
        insert a;
        
        Opportunity oppty = new Opportunity();
        oppty.AccountId = a.Id;
        oppty.Name = 'NewCC Test';
        oppty.StageName = 'Qualified';
        oppty.CloseDate = Date.Today().addDays(18);
        insert oppty;
 		Proposal__c proposal = UnitTest_ServiceContractUtil.createProposal(oppty.Id);
		insert proposal; 
		
		String proposalIdStr = '' + proposal.id;

		eSignServiceNew.isApexTesting = true;
		String envelopId1 = '535SDFF-43643-GSGA346';
		SR_Attachment__c srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Customer Agreement', envelopId1, proposalIdStr, 
																					'TestFile01.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);		
		insert srAttachmentObj1;
		
		dsfs__DocuSign_Status__c docuSignStatus1 = UnitTest_ProposalUtil.CreateDocuSignStatus(envelopId1, EDPUtil.COMPLETED);
		insert docuSignStatus1;

		SR_Attachment__c srAttachmentObj2 = UnitTest_ProposalUtil.CreateSRAttachment('EPC', envelopId1, proposalIdStr, 
																					'TestFile02.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);		
		String envelopId2 = '535SDFF-43643-GSGA336';
		srAttachmentObj2.Envelop_Id__c = envelopId2;
		srAttachmentObj2.Document_Name_On_File_Server__c = 'TestFile2';
		
		insert srAttachmentObj2;
		dsfs__DocuSign_Status__c docuSignStatus2 = UnitTest_ProposalUtil.CreateDocuSignStatus(envelopId2, EDPUtil.VOIDED);
		insert docuSignStatus2;		
	
		String recipientId = '345SDFF-43643-GSGA336';
		String recipientEmail = 'test.sunrundocusing@gmail.com';
		dsfs__DocuSign_Recipient_Status__c recipientStatus = UnitTest_ProposalUtil.CreateDocuSignRecipientStatus(''+docuSignStatus2.Id, envelopId1, recipientId, recipientEmail, EDPUtil.SENT);
		insert recipientStatus;
		
		recipientStatus.dsfs__Recipient_Status__c = EDPUtil.completed;
		update recipientStatus;	
		
		String resendStr = DocuSignUtil.createResendJSONEnvelopString(envelopId1);
		String voidString = DocuSignUtil.createVoidJSONEnvelopString();

		ApexPages.currentPage().getParameters().put('event', '');
		ApexPages.currentPage().getParameters().put('envelopId', envelopId2);
		ApexPages.currentPage().getParameters().put('recipientId', 1+'');
		
		InPersonStatus inpersonStatusObj = new InPersonStatus();
		inpersonStatusObj.initialize();
		
		ApexPages.currentPage().getParameters().put('event', 'signing_complete');
		ApexPages.currentPage().getParameters().put('envelopId', envelopId2);
		ApexPages.currentPage().getParameters().put('recipientId', 1+'');

		ApexPages.currentPage().getParameters().put('event', 'cancel');
		ApexPages.currentPage().getParameters().put('envelopId', envelopId2);
		ApexPages.currentPage().getParameters().put('recipientId', 1+'');
		
		
		PageReference pageRef1 = inpersonStatusObj.processInPersonSigningRequest();
		PageReference pageRef2 = inpersonStatusObj.continueInPersonSigningRequest();
		inpersonStatusObj.getInpersonSigningURL();
	}
	
	public static testmethod void testCostcoTags(){

        Account a = new Account(name='Test Acct1');
        insert a;
        
        Opportunity oppty = new Opportunity();
        oppty.AccountId = a.Id;
        oppty.Name = 'NewCC Test';
        oppty.StageName = 'Qualified';
        oppty.CloseDate = Date.Today().addDays(18);
        insert oppty;
 		Proposal__c proposal = UnitTest_ServiceContractUtil.createProposal(oppty.Id);
		insert proposal;
		proposal.opportunity__R = oppty;

		Contact primaryContact = new Contact();
		primaryContact.FirstName = 'PrimaryCustomer1';
		primaryContact.lastname = 'L1 ';
		primaryContact.email = 'PrimaryCustomer1@gmail.com';
		
		Contact secondaryContact = new Contact();
		secondaryContact.FirstName = 'SecondaryCustomer1';
		secondaryContact.lastname = 'L1';
		secondaryContact.email = 'SecondaryCustomer1@gmail.com';

		Contact partnerContact = new Contact();
		partnerContact.FirstName = 'PartnerContact1';
		partnerContact.lastname = 'L1';
		partnerContact.email = 'PartnerContact1@gmail.com';
				
		String sunrunRecipientName = 'TestSunrunOps';
		String sunrunRecipientEmail = 'TestSunrunOps@yopmail.com';
		String result1 = DocuSignUtil.createResendJSONEnvelopString(primaryContact, secondaryContact, partnerContact, sunrunRecipientName, sunrunRecipientEmail);		
		
		Account accountObj = new Account();
		accountObj.BillingCity = 'New York'; 
		SR_Attachment__c srAttachment = NEW SR_Attachment__c();
        String proposalIdStr = '' + proposal.id;
        List<SR_Attachment__c> srAttachmentList = new List<SR_Attachment__c>();
        SR_Attachment__c srAttachmentObj1;
        
        String envelopId1 = '';
        srAttachment = UnitTest_ProposalUtil.CreateSRAttachment('Customer Agreement', envelopId1, proposalIdStr, 
                                                                    'TestFile01.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
		insert srAttachment;
		
		srAttachment = [Select Id, name, createddate, Proposal__R.Id, Proposal__R.Opportunity__r.Sales_Partner__c , Proposal__R.Opportunity__r.Purchased_Thru__c, Document_Type_Name__c FROM SR_Attachment__c WHERE Id =:srAttachment.Id];
		srAttachment.Proposal__R = proposal;
		srAttachment.Proposal__R.Opportunity__r.Account = accountObj;
		srAttachment.Proposal__R.Opportunity__r.Sales_Partner__c = System.Label.Sunrun_Inc_Id;
		srAttachment.Proposal__R.Opportunity__r.Purchased_Thru__c = 'Costco';
		Boolean resultNY = DocuSignUtil.isNewyorkDocument(srAttachment);
		Boolean resultCostco = DocuSignUtil.isCostcoDocument(srAttachment);
		Boolean includeTabs = true;
		Integer documentId = 1;
		String eSigningType = '';
		String hostName = 'TestSunrunName';
		String hostEmail = 'TestSunrunName@gmail.com';
		
		String resultEnvelopStr = DocuSignUtil.createJSONEnvelopString(includeTabs, documentId, eSigningType, hostName, hostEmail, 
											srAttachment, primaryContact, secondaryContact,
											partnerContact, sunrunRecipientName, sunrunRecipientEmail,
											null);
		
		eSigningType = DocuSignUtil.ESIGN_IN_PERSON;
		primaryContact = new Contact();
		primaryContact.FirstName = 'PrimaryCustomer1';
		primaryContact.lastname = 'L1 ';
		primaryContact.email = 'PrimaryCustomer1@gmail.com';
		List<In_Person_Recipient__c> inpersonRecipientList = new 	List<In_Person_Recipient__c>();	
		resultEnvelopStr = DocuSignUtil.createJSONEnvelopString(includeTabs, documentId, eSigningType, hostName, hostEmail, 
											srAttachment, primaryContact, secondaryContact,
											partnerContact, sunrunRecipientName, sunrunRecipientEmail,
											inpersonRecipientList);
		
		Map<String, String> recipientEnvelopMap = new Map<String, String>();
		recipientEnvelopMap.put('Test1', 'Test1');
		String errorDescription = 'Error Message';
		DocuSignUtil.notifyProposalUpdateError(recipientEnvelopMap, errorDescription);
		DocuSignUtil.getBaseURL();
		String proposalId = proposal.Id;
		String documentType = 'Customer Agreement';
		SR_Attachment__c attachmentObj1 = DocuSignUtil.getSRAttachmentsForESignature(proposalId, documentType);
		SR_Attachment__c attachmentObj2 = DocuSignUtil.getSRAttachmentsForVoid(proposalId, documentType);
		SR_Attachment__c attachmentObj3 = DocuSignUtil.getSRAttachment(proposalId, documentType);
		
		String envelopId = 'Test1';
		dsfs__DocuSign_Status__c dsfsObj = DocuSignUtil.getDocuSignStatus(envelopId);
		DocuSignUtil.testInnerClasses();
		includeTabs = false;
		eSigningType = '';
		String resultEnvelopStr2 = DocuSignUtil.createJSONEnvelopString(includeTabs, documentId, eSigningType, hostName, hostEmail, 
											srAttachment, primaryContact, secondaryContact,
											partnerContact, sunrunRecipientName, sunrunRecipientEmail,
											null);
		
		SR_Attachment__c srAttachment4 = UnitTest_ProposalUtil.CreateSRAttachment('Conditional Approval', envelopId1, proposalIdStr, 
       	                                                             'TestFile02.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
		insert srAttachment4;
		includeTabs = false;
		String resultEnvelopStr3 = DocuSignUtil.createJSONEnvelopString(includeTabs, documentId, eSigningType, hostName, hostEmail, 
											srAttachment4, primaryContact, secondaryContact,
											partnerContact, sunrunRecipientName, sunrunRecipientEmail,
											null);
		
		In_Person_Recipient__c inpersonObj = new In_Person_Recipient__c();
		inpersonObj.Host_Email__c = 'host1@yopmail.com';
		inpersonObj.Host_Name__c = 'Sunrun Host1';
		inpersonObj.Client_User_Id__c = 'Sunrun Host1';
		envelopId = '53253253252';
		DocuSignUtil.createEmbeddedSigningJSONEnvelopString(inpersonObj, envelopId, 1);
		
		Set<String> envelopIds = new Set<String>();
		envelopIds.add('12421421412');
		Boolean documentStatus = true;
		Map<Id, dsfs__DocuSign_Recipient_Status__c> recipientStatus = DocuSignUtil.getDocuSignRecipients(envelopIds, documentStatus);
	}
	
	public static testmethod void testDocuSignTags1(){
		String documentType = '';
		String agreementType = '';
		String purchasedThrough = '';
		 String programType = '';
		DocuSignUtil.initializeRequiredTagsByDocType(documentType, agreementType, purchasedThrough, programType);
	}

	public static testmethod void testDocuSignTags2(){
		String documentType = EDPUtil.CUSTOMER_AGREEMENT ; 
		String agreementType = 'Customer Owned - Full Upfront';
		String purchasedThrough = 'Costco';
		String programType ='Program 1';
		DocuSignUtil.initializeRequiredTagsByDocType(documentType, agreementType, purchasedThrough, programType);
	}	

	public static testmethod void testDocuSignTags3(){
		String documentType = EDPUtil.CUSTOMER_AGREEMENT ; 
		String agreementType = 'Customer Owned - Full Upfront';
		String purchasedThrough = 'Costco';
		String programType ='Program 2';
		DocuSignUtil.initializeRequiredTagsByDocType(documentType, agreementType, purchasedThrough, programType);
	}

	public static testmethod void testDocuSignTags4(){
		String documentType = EDPUtil.CUSTOMER_AGREEMENT ; 
		String agreementType = 'Customer Owned - Full Upfront';
		String purchasedThrough = '';
		String programType = '';
		DocuSignUtil.initializeRequiredTagsByDocType(documentType, agreementType, purchasedThrough, programType);
	}
	
	public static testmethod void testDocuSignTags5(){
		String documentType = EDPUtil.CUSTOMER_AGREEMENT ; 
		String agreementType = 'Customer Owned - Bank Financed';
		String purchasedThrough = '';
		String programType = '';
		DocuSignUtil.initializeRequiredTagsByDocType(documentType, agreementType, purchasedThrough, programType);
	}		

	public static testmethod void testDocuSignTags6(){
		String documentType = EDPUtil.CUSTOMER_AGREEMENT ; 
		String agreementType = 'Customer Owned - Bank Financed';
		String purchasedThrough = 'Costco';
		String programType = 'Program 1';
		DocuSignUtil.initializeRequiredTagsByDocType(documentType, agreementType, purchasedThrough, programType);
	}	

	public static testmethod void testDocuSignTags7(){
		String documentType = EDPUtil.CUSTOMER_AGREEMENT ; 
		String agreementType = 'Customer Owned - Bank Financed';
		String purchasedThrough = 'Costco';
		String programType = 'Program 2';
		DocuSignUtil.initializeRequiredTagsByDocType(documentType, agreementType, purchasedThrough, programType);
	}

	public static testmethod void testDocuSignTags22(){
		String documentType = EDPUtil.CUSTOMER_CHANGEORDER_COVER_SHEET ; 
		String agreementType = 'Customer Owned - Full Upfront';
		String purchasedThrough = 'Costco';
		String programType ='Program 1';
		DocuSignUtil.initializeRequiredTagsByDocType(documentType, agreementType, purchasedThrough, programType);
	}	

	public static testmethod void testDocuSignTags32(){
		String documentType = EDPUtil.CUSTOMER_CHANGEORDER_COVER_SHEET ; 
		String agreementType = 'Customer Owned - Full Upfront';
		String purchasedThrough = 'Costco';
		String programType ='Program 2';
		DocuSignUtil.initializeRequiredTagsByDocType(documentType, agreementType, purchasedThrough, programType);
	}

	public static testmethod void testDocuSignTags42(){
		String documentType = EDPUtil.CUSTOMER_CHANGEORDER_COVER_SHEET ; 
		String agreementType = 'Customer Owned - Full Upfront';
		String purchasedThrough = '';
		String programType = '';
		DocuSignUtil.initializeRequiredTagsByDocType(documentType, agreementType, purchasedThrough, programType);
	}
	
	public static testmethod void testDocuSignTags52(){
		String documentType = EDPUtil.CUSTOMER_CHANGEORDER_COVER_SHEET ; 
		String agreementType = 'Customer Owned - Bank Financed';
		String purchasedThrough = '';
		String programType = '';
		DocuSignUtil.initializeRequiredTagsByDocType(documentType, agreementType, purchasedThrough, programType);
	}		

	public static testmethod void testDocuSignTags62(){
		String documentType = EDPUtil.CUSTOMER_CHANGEORDER_COVER_SHEET ; 
		String agreementType = 'Customer Owned - Bank Financed';
		String purchasedThrough = 'Costco';
		String programType = 'Program 1';
		DocuSignUtil.initializeRequiredTagsByDocType(documentType, agreementType, purchasedThrough, programType);
	}	

	public static testmethod void testDocuSignTags72(){
		String documentType = EDPUtil.CUSTOMER_CHANGEORDER_COVER_SHEET ; 
		String agreementType = 'Customer Owned - Bank Financed';
		String purchasedThrough = 'Costco';
		String programType = 'Program 2';
		DocuSignUtil.initializeRequiredTagsByDocType(documentType, agreementType, purchasedThrough, programType);
		
		DocuSignUtil.getRequiredTagsByDocType(documentType);
		DocuSignUtil.getRequiredTagsByDocType('EPC');
	}


	
	/*
	public static testmethod void testDocuSignUtilMethods(){
		String baseURL = DocuSignUtil.getBaseURL();
		//public static String createResendJSONEnvelopString(Contact primaryContact, Contact secondaryContact,
		//									Contact partnerContact, String sunrunRecipientName, String sunrunRecipientEmail){
		
		String partnerContactId = PartnerDetail__c.getValues('ApexTestAccount').PartnerContactId__C;
		Contact partnerContact = [Select Id, name, email from Contact where Id =:partnerContactId];
		
		Account customerAccount = TestPRMLibrary.insertAccount('1234 Fremont St CA', 'Residential');
		
		//Create Cusomer Contacts: Primary and Secondary contact
		Contact primaryCustomer = TestPRMLibrary.insertContact(customerAccount.Id, 'Residential', 'PFirstName1', 
																'PLastName1', 'PrimaryCustomer@gmail.com');
		
		Contact secondaryCustomer = TestPRMLibrary.insertContact(customerAccount.Id, 'Residential', 'SFirstName1', 
																'SLastName1', 'SecondaryCustomer@gmail.com');			
		String sunrunRecipientName = '';
		String sunrunRecipientEmail = '';
		sunrunRecipientName = Label.SunRun_DocuSign_User;
		sunrunRecipientEmail = Label.SunRun_DocuSign_Email;
		String testEnvelopStr = DocuSignUtil.createResendJSONEnvelopString(primaryCustomer, secondaryCustomer, 
																			partnerContact, sunrunRecipientName, 
																			sunrunRecipientEmail);
	
		DocuSignUtil.PhoneTab phoneTabObj = new DocuSignUtil.PhoneTab('Test1', 'Test2');
		DocuSignUtil.RadioTab RadioTabObj = new DocuSignUtil.RadioTab('\\chk\\');
		DocuSignUtil.RadioGroupTab RadioGroupTabObj = new DocuSignUtil.RadioGroupTab('Test1');

		SR_Attachment__c srAttachmentObj2 = UnitTest_ProposalUtil.CreateSRAttachment('Conditional Approval', '', null, 
																					'TestFile02.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);		
		//srAttachmentObj2.Document_Type_Name__c = 'Conditional Approval';
		insert srAttachmentObj2;
		srAttachmentObj2 = [Select Id, Document_Source__c, Document_Type_Name__c from SR_Attachment__c where Id =:srAttachmentObj2.Id] ;
		
		String srAttachmentId = srAttachmentObj2.Id;
		String soqlStr;
		soqlStr = SRAttachmentManager.getSRAttachmentSOQL();
		soqlStr += '  WHERE Id = :srAttachmentId ' ;
		srAttachmentObj2 = Database.query(soqlStr);
		List<In_Person_Recipient__c> inpersonRecipientList = new List<In_Person_Recipient__c>();
		DocuSignUtil.createJSONEnvelopString(true, 1234, '', '', '', 
											srAttachmentObj2, primaryCustomer, secondaryCustomer, partnerContact, 
											sunrunRecipientName,sunrunRecipientEmail, inpersonRecipientList);
	}
	*/
}