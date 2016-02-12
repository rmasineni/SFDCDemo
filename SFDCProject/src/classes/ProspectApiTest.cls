@IsTest
public class ProspectApiTest {
	private static BaseClass utils = new BaseClass();
    
    testmethod public static void testGetProposal() {
        insertSettings();

        //Test required parameter (Prospect Number) test
		BaseApiTest.setRequest('/v2/prospects/1234/proposals');
        ProspectApiProspectEndpoint.httpGet();
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
        opty1 = [Select Id, Prospect_Id__c from Opportunity where Id =:opty1.Id];

        //Test required parameter (Prospect Number) test
        BaseApiTest.setRequest('/v2/prospects/' + opty1.Prospect_Id__c + '/proposals');
        ProspectApiProspectEndpoint.httpGet();
        BaseApiTest.assertErrorResponse(404, RestServiceDto.Error_NotFound);
        
		
		//With sync disabled, insert proposal and it should not create sync records.
        Proposal__c proposal = new Proposal__c(Mode_Name__c='Mode', Opportunity__c=opty1.id,
			Sales_Rep_Email__c='test@yopmail.com', Stage__c='Created', Date_Issued__c=Date.today(), System_Size_STC_DC__c=10.0, Upfront_Payment__c=00.0);
        insert proposal;
        proposal = (Proposal__c) utils.queryAllFields(proposal.id);
        
		BaseApiTest.setRequest('/v2/prospects/' + opty1.Prospect_Id__c + '/proposals');
        ProspectApiProspectEndpoint.httpGet();
		JsonReader reader = BaseApiTest.assertSuccessResponse();
		
		JsonReader tempReader = reader.newWith(0);
		System.assertNotEquals(null, tempReader);
		System.assertEquals('test@yopmail.com', tempReader.getString('salesRepEmail'));
		BaseApiTest.assertAuditFieldsExists(reader);
    }

    static void insertSettings() {
        RestServiceDto.insertFieldMapping('Prospect Api', 'Proposal__c', 'salesRepEmail=Sales_Rep_Email__c');
    }
}