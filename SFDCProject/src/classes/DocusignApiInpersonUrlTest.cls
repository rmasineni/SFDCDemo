@isTest(SeeAllData=true)
public class DocusignApiInpersonUrlTest {
	private static BaseClass utils = new BaseClass();
    
    testmethod public static void testGetInpersonurl() {

        //Test required parameter (proposal id) test
		//BaseApiTest.setRequest('/v2/srattachments/create', '[{"contentMd5": "8b5f1ec077763d164d7d3b4362125731","documentType": "qualificationDoc","parentId": "1705931771","filename": "Utility_Bill_12_29_2015_12:11:11"}]');
		///SRAttachmentApiCreateAttachmentEndpoint.httppost();
		//BaseApiTest.assertErrorResponse(404, RestServiceDto.Error_NotFound);
        

		BaseApiTest.setRequest('/v2/eSign/inPersonUrl');
		BaseApiTest.setParam('envelopeId', '73D3C540-6164-46C6-B669-AE07622FB239');
		BaseApiTest.setParam('recipient', '1');
		BaseApiTest.setParam('proposalId', 'PK1VF9NVL6ZA-J'); 
		DocusignApiInpersonUrlEndpoint.httpget();

		JsonReader reader = BaseApiTest.assertSuccessResponse();
		System.debug('reader: ' + reader);
		
		JsonReader tempReader = reader.newWith(0);
		System.debug('tempReader: ' + tempReader);
		//System.assertNotEquals(null, tempReader);
		//System.assertEquals('test@yopmail.com', tempReader.getString('salesRepEmail'));
		//BaseApiTest.assertAuditFieldsExists(reader);
    }
}