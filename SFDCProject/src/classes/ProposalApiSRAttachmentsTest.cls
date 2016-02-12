@isTest(SeeAllData=true)
public class ProposalApiSRAttachmentsTest {
	private static BaseClass utils = new BaseClass();
    
    testmethod public static void testGetSRAttachments() {
        insertSettings();
        
        //Test required parameter (proposal id) test
		BaseApiTest.setRequest('/v2/proposals/PZ179A1N6C1K-D/sr_attachments');
		BaseApiTest.setParam('documentType', 'Utility Bill');
		ProposalApiProposalEndpoint.httpGet();
		BaseApiTest.assertErrorResponse(404, RestServiceDto.Error_NotFound);
        
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
		Document_Classification__c classificationObj = [Select Id, Document_Name__c from Document_Classification__c where Document_Name__c = 'Utility Bill'];
        SR_Attachment__c srAttachment = new SR_Attachment__c(proposal__c=proposal.Id, Document_Name_On_File_Server__c='Test.PDF', folder_name__c='uploadedDoc', 
        													active__c=true,size__c = '1 MB', Document_Name__c='Test.PDF', 
        													Document_Classification__c=classificationObj.Id, Wet_Sign_Status__c = EDPDocumentSettings.NA,
        													Document_Source__c = EDPDocumentSettings.MANUAL_UPLOAD, Parent_Proposal_Name__c=proposal.Name);
        insert srAttachment;		
		
		
		BaseApiTest.setRequest('/v2/proposals/' + proposal.name + '/sr_attachments');
		BaseApiTest.setParam('documentType', 'Utility Bill');
        ProposalApiProposalEndpoint.httpGet();
		JsonReader reader = BaseApiTest.assertSuccessResponse();
		System.debug('reader: ' + reader);
		JsonReader tempReader = reader.newWith(0);
		System.debug('tempReader: ' + tempReader);
		//System.assertNotEquals(null, tempReader);
		//System.assertEquals('test@yopmail.com', tempReader.getString('salesRepEmail'));
		//BaseApiTest.assertAuditFieldsExists(reader);
    }

    testmethod public static void testPatchSRAttachments() {
        insertSettings();
        
        //Test required parameter (proposal id) test
		BaseApiTest.setRequest('/v2/proposals/PZ179A1N6C1K-D/sr_attachments');
		BaseApiTest.setParam('documentType', 'Utility Bill');
		ProposalApiProposalEndpoint.httpGet();
		BaseApiTest.assertErrorResponse(404, RestServiceDto.Error_NotFound);
        
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
		Document_Classification__c classificationObj = [Select Id, Document_Name__c from Document_Classification__c where Document_Name__c = 'Utility Bill'];
        SR_Attachment__c srAttachment = new SR_Attachment__c(proposal__c=proposal.Id, Document_Name_On_File_Server__c='Test.PDF', folder_name__c='uploadedDoc', 
        													active__c=true,size__c = '1 MB', Document_Name__c='Test.PDF', 
        													Document_Classification__c=classificationObj.Id, Wet_Sign_Status__c = EDPDocumentSettings.NA,
        													Document_Source__c = EDPDocumentSettings.MANUAL_UPLOAD, Parent_Proposal_Name__c=proposal.Name);
        insert srAttachment;		
		
		BaseApiTest.setRequest('/v2/proposals/' + proposal.name + '/sr_attachments/' + srAttachment.Id, '{"active": "true"}');
		ProposalApiProposalEndpoint.httpPatch();
		JsonReader reader = BaseApiTest.assertSuccessResponse();
		System.debug('reader: ' + reader);
		JsonReader tempReader = reader.newWith(0);
		System.debug('tempReader: ' + tempReader);
		//System.assertNotEquals(null, tempReader);
		//System.assertEquals('test@yopmail.com', tempReader.getString('salesRepEmail'));
		//BaseApiTest.assertAuditFieldsExists(reader);
    }

    static void insertSettings() {
        RestServiceDto.insertFieldMapping('Proposal Api', 'Proposal__c', 'salesRepEmail=Sales_Rep_Email__c');
    }
}