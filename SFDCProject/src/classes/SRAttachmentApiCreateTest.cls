@isTest(SeeAllData=true)
public class SRAttachmentApiCreateTest {
	private static BaseClass utils = new BaseClass();
    
    testmethod public static void testCreateSRAttachments() {
        insertSettings();
        
        //Test required parameter (proposal id) test
		BaseApiTest.setRequest('/v2/srattachments/create', '{"parentId": "123456","documents": [{"documentType": "Utility Bill","documentNameOnFileServer": "https://devmaj-sunrun.s3-us-west-2.amazonaws.com/qualificationDoc/1705931771/Utility_Bill_12_29_2015_12%3A11%3A11?AWSAccessKeyId=AKIAI3TSGQR3IGCH3C4Q&Expires=1453084076&Signature=EKy5WUMuQB8Dtaw044T2n8QA4Lg%3D","documentName": "Sample1.pdf"}]}' );
		SRAttachmentApiCreateAttachmentEndpoint.httppost();
		BaseApiTest.assertErrorResponse(404, RestServiceDto.Error_NotFound);
        
        //Insert a proposal and try to get it.
		Account acct = new Account(Name='Foo', RecordTypeId=utils.getRecordTypeId('Account', 'Partner'), 
			BillingCity='Dublin',
			Office_Location__c  = 'Headquarters',
			Stage__c = 'Confirmed',
			Active__c  = true);
        insert acct;
        
        Opportunity opty = new Opportunity(Name='Test', StageName='Stage', CloseDate=Date.today());
        insert opty;
        opty = [Select Id, Prospect_Id__c from Opportunity where Id =:opty.Id];

        //With sync disabled, insert proposal and it should not create sync records.
        Proposal__c proposal = new Proposal__c(Mode_Name__c='Mode', Opportunity__c=opty.id,
			Sales_Rep_Email__c='test@yopmail.com', stage__c='Created', Date_Issued__c=Date.today(), System_Size_STC_DC__c=10.0, Upfront_Payment__c=00.0);
        insert proposal;
        proposal = (Proposal__c) utils.queryAllFields(proposal.id);
        System.debug('proposal: ' + proposal);
		
		BaseApiTest.setRequest('/v2/srattachments/create', '{"parentId": "' + opty.Prospect_Id__c + '","documents": [{"documentType": "Utility Bill","documentNameOnFileServer": "https://devmaj-sunrun.s3-us-west-2.amazonaws.com/qualificationDoc/1705931771/Utility_Bill_12_29_2015_12%3A11%3A11?AWSAccessKeyId=AKIAI3TSGQR3IGCH3C4Q&Expires=1453084076&Signature=EKy5WUMuQB8Dtaw044T2n8QA4Lg%3D","documentName": "Sample1.pdf"}]}' );
		SRAttachmentApiCreateAttachmentEndpoint.httppost();

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