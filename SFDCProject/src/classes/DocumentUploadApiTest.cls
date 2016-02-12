@isTest(SeeAllData=true)
public class DocumentUploadApiTest {
	private static BaseClass utils = new BaseClass();
    
    testmethod public static void testGetDocumentUploadUrl() {

        //Test required parameter (proposal id) test
		//BaseApiTest.setRequest('/v2/srattachments/create', '[{"contentMd5": "8b5f1ec077763d164d7d3b4362125731","documentType": "qualificationDoc","parentId": "1705931771","filename": "Utility_Bill_12_29_2015_12:11:11"}]');
		///SRAttachmentApiCreateAttachmentEndpoint.httppost();
		//BaseApiTest.assertErrorResponse(404, RestServiceDto.Error_NotFound);
        
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new DocumentUploadApiMockResponse());
			
			BaseApiTest.setRequest('/v2/srattachments/documentUpload', '[{"contentMd5": "8b5f1ec077763d164d7d3b4362125731","documentType": "qualificationDoc","parentId": "1705931771","filename": "Utility_Bill_12_29_2015_12:11:11"}]' );
			DocumentUploadApiEndpoint.httppost();
	
			JsonReader reader = BaseApiTest.assertSuccessResponse();
			System.debug('reader: ' + reader);
			
			JsonReader tempReader = reader.newWith(0);
			System.debug('tempReader: ' + tempReader);
		
		Test.stopTest();
		//System.assertNotEquals(null, tempReader);
		//System.assertEquals('test@yopmail.com', tempReader.getString('salesRepEmail'));
		//BaseApiTest.assertAuditFieldsExists(reader);
    }
}