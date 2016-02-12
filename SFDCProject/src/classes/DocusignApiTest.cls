@isTest(SeeAllData=true)
public class DocusignApiTest {
	private static BaseClass utils = new BaseClass();
    
    testmethod public static void testDocuSignInpersonUrl() {

		insertSettings();
        
		//Test required parameter (proposal id) test
		BaseApiTest.setRequest('/v2/eSign/inPersonUrl');
		BaseApiTest.setParam('envelopeId', '1234567');
		BaseApiTest.setParam('recipient', '1');
		BaseApiTest.setParam('proposalId', 'PK1234567890-A');
		DocusignApiInpersonUrlEndpoint.httpGet();
        
        //Insert a proposal and try to get it.
		Account acct = new Account(Name='Foo', RecordTypeId=utils.getRecordTypeId('Account', 'Partner'), 
			BillingCity='Dublin',
			Office_Location__c  = 'Headquarters',
			Stage__c = 'Confirmed',
			Active__c  = true);
        insert acct;
        
        Opportunity opty1 = new Opportunity(Name='Test', StageName='Stage', CloseDate=Date.today());
        insert opty1;

        //With sync disabled, insert proposal and it should not create sync records.
        Proposal__c proposal = new Proposal__c(Mode_Name__c='Mode', Opportunity__c=opty1.id,
			Sales_Rep_Email__c='test@yopmail.com', stage__c='Created', Date_Issued__c=Date.today(), System_Size_STC_DC__c=10.0, Upfront_Payment__c=00.0);
        insert proposal;
        proposal = (Proposal__c) utils.queryAllFields(proposal.id);
        
        System.debug('proposal: ' + proposal);
		Document_Classification__c classificationObj = [Select Id, Document_Name__c from Document_Classification__c where Document_Name__c = 'Customer Agreement'];
        SR_Attachment__c srAttachment = new SR_Attachment__c(proposal__c=proposal.Id, Document_Name_On_File_Server__c='Test.PDF', 
															active__c=true,size__c = '1 MB', Document_Name__c='Test.PDF', 
        													Envelop_Id__c = '73D3C540-6164-46C6-B669-AE07622FB239',DocuSign_Status__C = 'Sent',
        													Document_Classification__c=classificationObj.Id, Wet_Sign_Status__c= '',
        													Document_Source__c ='eSign', Parent_Proposal_Name__c=proposal.Name);
        insert srAttachment;		
		
	 	Test.startTest();
			Test.setMock(HttpCalloutMock.class, new DocuSignInpersonUrlMockResponse());		
			BaseApiTest.setRequest('/v2/eSign/inPersonUrl');
			BaseApiTest.setParam('envelopeId', '73D3C540-6164-46C6-B669-AE07622FB239');
			BaseApiTest.setParam('recipient', '1');
			BaseApiTest.setParam('proposalId', proposal.name);
	        DocusignApiInpersonUrlEndpoint.httpGet();
			JsonReader reader = BaseApiTest.assertSuccessResponse();
			System.debug('reader: ' + reader);
			System.assertNotEquals(null, reader.getString('url'));
		Test.stopTest();

    }
	

    testmethod public static void testDocuSignInitiateInpersonSignature() {
        insertSettings();
        
		//Test required parameter (proposal id) test
		BaseApiTest.setRequest('/v2/eSign', '{"action" : "initiate","documentType" : "Customer Agreement","proposalId" : "PK1234-J","eSignatureType" : "INPERSON"}');
		DocusignApiESignEndpoint.httpPost();
		BaseApiTest.assertErrorResponse(400, RestServiceDto.Error_InvalidRequest);
        
        //Insert a proposal and try to get it.
		Account acct = new Account(Name='Foo', RecordTypeId=utils.getRecordTypeId('Account', 'Partner'), 
			BillingCity='Dublin',
			Office_Location__c  = 'Headquarters',
			Stage__c = 'Confirmed',
			Active__c  = true);
        insert acct;
        
        Opportunity opty1 = new Opportunity(Name='Test', StageName='Stage', CloseDate=Date.today());
        insert opty1;

        //With sync disabled, insert proposal and it should not create sync records.
        Proposal__c proposal = new Proposal__c(Mode_Name__c='Mode', Opportunity__c=opty1.id,
			Sales_Rep_Email__c='test@yopmail.com', stage__c='Created', Date_Issued__c=Date.today(), System_Size_STC_DC__c=10.0, Upfront_Payment__c=00.0);
        insert proposal;
        proposal = (Proposal__c) utils.queryAllFields(proposal.id);
        
        System.debug('proposal: ' + proposal);
		Document_Classification__c classificationObj = [Select Id, Document_Name__c from Document_Classification__c where Document_Name__c = 'Customer Agreement'];
        SR_Attachment__c srAttachment = new SR_Attachment__c(proposal__c=proposal.Id, Document_Name_On_File_Server__c='Test.PDF', DocuSign_Status__C = 'Sent',
															active__c=true,size__c = '1 MB', Document_Name__c='Test.PDF', Envelop_Id__c = '',
															Document_Classification__c=classificationObj.Id, Wet_Sign_Status__c= '',Proposal_Source__C= ProposalUtil.BLACK_BIRD,
        													Document_Source__c ='Proposal Tool', Parent_Proposal_Name__c=proposal.Name);
        insert srAttachment;		
		BaseApiTest.setRequest('/v2/eSign', '{"action" : "initiate","documentType" : "Customer Agreement","proposalId" : "'+ proposal.name + '","eSignatureType" : "INPERSON"}');
		DocusignApiESignEndpoint.httpPost();
		JsonReader reader = BaseApiTest.assertSuccessResponse();
		System.debug('reader: ' + reader);
		System.assertNotEquals(null, reader.getString('envelopeId'));
	}


    testmethod public static void testDocuSignVoidESignature1() {
        insertSettings();
        
		//Test required parameter (proposal id) test
		BaseApiTest.setRequest('/v2/eSign', '{"action" : "void","documentType" : "Customer Agreement","proposalId" : "PK12345-H","eSignatureType" : "EMAIL"}');
		DocusignApiESignEndpoint.httpPost();
		//BaseApiTest.assertErrorResponse(500, RestServiceDto.Unable_To_Process_Request);
        
        //Insert a proposal and try to get it.
		Account acct = new Account(Name='Foo', RecordTypeId=utils.getRecordTypeId('Account', 'Partner'), 
			BillingCity='Dublin',
			Office_Location__c  = 'Headquarters',
			Stage__c = 'Confirmed',
			Active__c  = true);
        insert acct;
        Opportunity opty1 = new Opportunity(Name='Test', StageName='Stage', CloseDate=Date.today());
        insert opty1;

        Proposal__c proposal = new Proposal__c(Mode_Name__c='Mode', Opportunity__c=opty1.id,
												Sales_Rep_Email__c='test@yopmail.com', stage__c=EDPUtil.PENDING_TASK_COMPLETED, 
												Sales_Partner__c=Label.Sunrun_Inc_Id, Install_Partner__c=Label.Sunrun_Inc_Id,
												Change_Order_Information__c=ProposalUtil.FULL_PROPOSAL,
												Proposal_Source__C= ProposalUtil.BLACK_BIRD,
												Date_Issued__c=Date.today(), System_Size_STC_DC__c=10.0, Upfront_Payment__c=00.0);
        insert proposal;
        proposal = (Proposal__c) utils.queryAllFields(proposal.id);
        
        System.debug('proposal: ' + proposal);
		Document_Classification__c classificationObj = [Select Id, Document_Name__c from Document_Classification__c where Document_Name__c = 'Customer Agreement'];
        SR_Attachment__c srAttachment = new SR_Attachment__c(proposal__c=proposal.Id, Document_Name_On_File_Server__c='Test.PDF', 
															active__c=true, size__c = '1 MB', Document_Name__c='Test.PDF', 
        													Envelop_Id__c = '73D3C540-6164-46C6-B669-AE07622FB239',DocuSign_Status__C = 'Sent',
        													Document_Classification__c=classificationObj.Id, Wet_Sign_Status__c= '',
        													Proposal_Source__C= ProposalUtil.BLACK_BIRD,
															Document_Source__c ='eSign', Parent_Proposal_Name__c=proposal.Name);
        
        insert srAttachment;		
		BaseApiTest.setRequest('/v2/eSign', '{"action" : "void","documentType" : "Customer Agreement","proposalId" : "'+ proposal.name + '","eSignatureType" : "EMAIL"}');
		DocusignApiESignEndpoint.httpPost();
		JsonReader reader = BaseApiTest.assertSuccessResponse();
    }

    testmethod public static void testDocuSignVoidESignature2() {
        insertSettings();

        //Insert a proposal and try to get it.
		Account acct = new Account(Name='Foo', RecordTypeId=utils.getRecordTypeId('Account', 'Partner'), 
			BillingCity='Dublin',
			Office_Location__c  = 'Headquarters',
			Stage__c = 'Confirmed',
			Active__c  = true);
        insert acct;
        
        Opportunity opty1 = new Opportunity(Name='Test', StageName='Stage', CloseDate=Date.today());
        insert opty1;

        //With sync disabled, insert proposal and it should not create sync records.
        Proposal__c proposal = new Proposal__c(Mode_Name__c='Mode', Opportunity__c=opty1.id,
												Sales_Rep_Email__c='test@yopmail.com', stage__c=EDPUtil.SR_DECLINED, 
												Change_Order_Information__c=ProposalUtil.FULL_PROPOSAL,
												Sales_Partner__c=Label.Sunrun_Inc_Id, Install_Partner__c=Label.Sunrun_Inc_Id,
												Proposal_Source__C= ProposalUtil.BLACK_BIRD,
												Date_Issued__c=Date.today(), System_Size_STC_DC__c=10.0, Upfront_Payment__c=00.0);
        insert proposal;
        proposal = (Proposal__c) utils.queryAllFields(proposal.id);
        
        System.debug('proposal: ' + proposal);
		Document_Classification__c classificationObj = [Select Id, Document_Name__c from Document_Classification__c where Document_Name__c = 'Customer Agreement'];
        SR_Attachment__c srAttachment = new SR_Attachment__c(proposal__c=proposal.Id, Document_Name_On_File_Server__c='Test.PDF', 
															active__c=true, size__c = '1 MB', Document_Name__c='Test.PDF', 
        													Envelop_Id__c = '73D3C540-6164-46C6-B669-AE07622FB239',DocuSign_Status__C = 'Sent',
        													Document_Classification__c=classificationObj.Id, Wet_Sign_Status__c= '',
        													Proposal_Source__C= ProposalUtil.BLACK_BIRD,
															Document_Source__c ='eSign', Parent_Proposal_Name__c=proposal.Name);
        
        insert srAttachment;		
		BaseApiTest.setRequest('/v2/eSign', '{"action" : "void","documentType" : "Customer Agreement","proposalId" : "'+ proposal.name + '","eSignatureType" : "EMAIL"}');
		DocusignApiESignEndpoint.httpPost();
    }

	testmethod public static void testDocuSignEsignInputs() {
        insertSettings();
		Account acct = new Account(Name='Foo', RecordTypeId=utils.getRecordTypeId('Account', 'Partner'), 
			BillingCity='Dublin',
			Office_Location__c  = 'Headquarters',
			Stage__c = 'Confirmed',
			Active__c  = true);
        insert acct;
        
        Opportunity opty1 = new Opportunity(Name='Test', StageName='Stage', CloseDate=Date.today());
        insert opty1;

        //With sync disabled, insert proposal and it should not create sync records.
        Proposal__c proposal = new Proposal__c(Mode_Name__c='Mode', Opportunity__c=opty1.id,
												Sales_Rep_Email__c='test@yopmail.com', stage__c=EDPUtil.SR_DECLINED, 
												Change_Order_Information__c=ProposalUtil.FULL_PROPOSAL,
												Sales_Partner__c=Label.Sunrun_Inc_Id, Install_Partner__c=Label.Sunrun_Inc_Id,
												Proposal_Source__C= ProposalUtil.BLACK_BIRD,
												Date_Issued__c=Date.today(), System_Size_STC_DC__c=10.0, Upfront_Payment__c=00.0);
        insert proposal;
        proposal = (Proposal__c) utils.queryAllFields(proposal.id);
        
		BaseApiTest.setRequest('/v2/eSign', '{"action" : "","documentType" : "Customer Agreement","proposalId" : "'+ proposal.name + ',","eSignatureType" : "EMAIL"}');
		DocusignApiESignEndpoint.httpPost();
		BaseApiTest.assertErrorResponse(400, RestServiceDto.Error_RequiredFieldsMissing);

		BaseApiTest.setRequest('/v2/eSign', '{"action" : "Initiate","documentType" : "","proposalId" : "'+ proposal.name + ',"eSignatureType" : "EMAIL"}');
		DocusignApiESignEndpoint.httpPost();
		BaseApiTest.assertErrorResponse(400, RestServiceDto.Error_InvalidRequest);
		
		BaseApiTest.setRequest('/v2/eSign', '{"action" : "Initiate","documentType" : "Customer Agreement","proposalId" : "","eSignatureType" : "EMAIL"}');
		DocusignApiESignEndpoint.httpPost();
		BaseApiTest.assertErrorResponse(400, RestServiceDto.Error_RequiredFieldsMissing);

		BaseApiTest.setRequest('/v2/eSign', '{"action" : "Initiate","documentType" : "Customer Agreement","proposalId" : "'+ proposal.name + ',","eSignatureType" : ""}');
		DocusignApiESignEndpoint.httpPost();
		BaseApiTest.assertErrorResponse(400, RestServiceDto.Error_InvalidRequest);

        System.debug('proposal: ' + proposal);
		Document_Classification__c classificationObj = [Select Id, Document_Name__c from Document_Classification__c where Document_Name__c = 'Customer Agreement'];
        SR_Attachment__c srAttachment = new SR_Attachment__c(proposal__c=proposal.Id, Document_Name_On_File_Server__c='Test.PDF', 
															active__c=true, size__c = '1 MB', Document_Name__c='Test.PDF', 
        													Envelop_Id__c = '73D3C540-6164-46C6-B669-AE07622FB239',DocuSign_Status__C = 'Sent',
        													Document_Classification__c=classificationObj.Id, Wet_Sign_Status__c= '',
        													Proposal_Source__C= ProposalUtil.BLACK_BIRD,
															Document_Source__c ='eSign', Parent_Proposal_Name__c=proposal.Name);
        
        insert srAttachment;
		BaseApiTest.setRequest('/v2/eSign', '{"action" : "Initiate","documentType" : "Customer Agreement","proposalId" : "'+ proposal.name + ',","eSignatureType" : "Inperson"}');
		DocusignApiESignEndpoint.httpPost();
		BaseApiTest.assertErrorResponse(400, RestServiceDto.Error_InvalidRequest);
	}
	
    static void insertSettings() {
        RestServiceDto.insertFieldMapping('Proposal Api', 'Proposal__c', 'salesRepEmail=Sales_Rep_Email__c');
    }
}