@isTest(SeeAllData=true)
public class DocusignApiESignTest {
	private static BaseClass utils = new BaseClass();
    
    testmethod public static void testGetInpersonurl() {

		BaseApiTest.setRequest('/v2/eSign/inPersonUrl');
		BaseApiTest.setParam('recipient', '1');
		BaseApiTest.setParam('proposalId', 'PK1VF9NVL6ZA-J'); 
		DocusignApiInpersonUrlEndpoint.httpget();
		BaseApiTest.assertErrorResponse(400, RestServiceDto.Error_RequiredFieldsMissing);
		
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new DocuSignInpersonUrlMockResponse());
			BaseApiTest.setRequest('/v2/eSign/inPersonUrl');
			BaseApiTest.setParam('envelopeId', '73D3C540-6164-46C6-B669-AE07622FB239');
			BaseApiTest.setParam('recipient', '1');
			BaseApiTest.setParam('proposalId', 'PK1VF9NVL6ZA-J'); 
			DocusignApiInpersonUrlEndpoint.httpget();
	
			JsonReader reader = BaseApiTest.assertSuccessResponse();
			System.assertNotEquals(null, reader.getString('url'));
		Test.stopTest();

    }
}