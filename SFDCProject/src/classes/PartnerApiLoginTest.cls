@IsTest
public class PartnerApiLoginTest {
	private static final String SuccessfulSfdcLoginResponse = '<?xml version="1.0" encoding="UTF-8"?> <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="urn:partner.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> <soapenv:Body> <loginResponse> <result> <metadataServerUrl>https://cs18.salesforce.com/services/Soap/m/34.0/00D11000000DMaw</metadataServerUrl> <passwordExpired>false</passwordExpired> <sandbox>true</sandbox> <serverUrl>https://cs18.salesforce.com/services/Soap/u/34.0/00D11000000DMaw</serverUrl> <sessionId>session_id</sessionId> <userId>005600000045vWeAAI</userId> <userInfo> <accessibilityMode>false</accessibilityMode> <currencySymbol>$</currencySymbol> <orgAttachmentFileSizeLimit>20971520</orgAttachmentFileSizeLimit> <orgDefaultCurrencyIsoCode>USD</orgDefaultCurrencyIsoCode> <orgDisallowHtmlAttachments>false</orgDisallowHtmlAttachments> <orgHasPersonAccounts>false</orgHasPersonAccounts> <organizationId>00D11000000DMawEAG</organizationId> <organizationMultiCurrency>false</organizationMultiCurrency> <organizationName>Sunrun</organizationName> <profileId>00e60000000nGtnAAE</profileId> <roleId>00E320000027UsqEAE</roleId> <sessionSecondsValid>7200</sessionSecondsValid> <userDefaultCurrencyIsoCode xsi:nil="true"/> <userEmail>santhosh.kumar@sunrunhome.com</userEmail> <userFullName>Santhosh Kumar</userFullName> <userId>005600000045vWeAAI</userId> <userLanguage>en_US</userLanguage> <userLocale>en_US</userLocale> <userName>santhosh.kumar@sunrunhome.com.majstg</userName> <userTimeZone>America/Los_Angeles</userTimeZone> <userType>Standard</userType> <userUiSkin>Theme3</userUiSkin> </userInfo> </result> </loginResponse> </soapenv:Body> </soapenv:Envelope>';
	private static final String InvalidSfdcLoginResponse = '<?xml version="1.0" encoding="UTF-8"?> <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sf="urn:fault.partner.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> <soapenv:Body> <soapenv:Fault> <faultcode>INVALID_LOGIN</faultcode> <faultstring>INVALID_LOGIN: Invalid username, password, security token; or user locked out.</faultstring> <detail> <sf:LoginFault xsi:type="sf:LoginFault"> <sf:exceptionCode>INVALID_LOGIN</sf:exceptionCode> <sf:exceptionMessage>Invalid username, password, security token; or user locked out.</sf:exceptionMessage> </sf:LoginFault> </detail> </soapenv:Fault> </soapenv:Body> </soapenv:Envelope>';
    private static final String RestLoginRequest = '{"userName": "userid@sunrunhome.com.devmaj", "password": "Password1"}';
    private static final String RestLoginRequestProfile = '{"userName": "userid@sunrunhome.com.devmaj", "password": "Password1", "includeProfile": true}';
    
    testmethod public static void testSuccessfulLogin() {
        FlexibleCalloutMock mock = new FlexibleCalloutMock(200, SuccessfulSfdcLoginResponse);
        BaseApiTest.setRequest('', RestLoginRequest);
		
		PartnerApiLoginEndpoint.httpPost();
		
		//Validate if all values are appropriately set.
		JsonReader reader = BaseApiTest.assertSuccessResponse();
		System.assertEquals('https://cs18.salesforce.com/services/apexrest', reader.getString('restApiBaseUrl'));        
		System.assertEquals('session_id', reader.getString('sessionId'));        
		System.assertEquals('https://cs18.salesforce.com/services/Soap/u/34.0/00D11000000DMaw', reader.getString('serverUrl'));
		System.assertEquals('005600000045vWeAAI', reader.getString('userId'));
		System.assertEquals(true, reader.getBoolean('sandbox'));
		System.assertEquals(false, reader.getBoolean('passwordExpired'));
		System.assertEquals('https://cs18.salesforce.com/services/Soap/m/34.0/00D11000000DMaw', reader.getString('metadataServerUrl'));
		System.assertEquals(null, reader.getString('userInfo.userEmail'));        
    }
    
    testmethod public static void testSuccessfulLoginProfile() {
        FlexibleCalloutMock mock = new FlexibleCalloutMock(200, SuccessfulSfdcLoginResponse);
        BaseApiTest.setRequest('', RestLoginRequestProfile);
		
		PartnerApiLoginEndpoint.httpPost();
		
		//Validate if all values are appropriately set.
		JsonReader reader = BaseApiTest.assertSuccessResponse();
		System.assertEquals('santhosh.kumar@sunrunhome.com', reader.getString('userInfo.userEmail'));        
    }

    testmethod public static void testErrorScenarios() {
		
        //Set no payload and ensure it is validated.
        BaseApiTest.setRequest('', null);
		PartnerApiLoginEndpoint.httpPost();
		BaseApiTest.assertErrorResponse(401, 'REQUIRED_FIELDS_MISSING');
		
        //Send empty response
        BaseApiTest.setRequest('', '{}');
		PartnerApiLoginEndpoint.httpPost();
		BaseApiTest.assertErrorResponse(401, 'REQUIRED_FIELDS_MISSING');
		
        //Send just username
        BaseApiTest.setRequest('', '{"userName":"userid"}');
		PartnerApiLoginEndpoint.httpPost();
		BaseApiTest.assertErrorResponse(401, 'REQUIRED_FIELDS_MISSING');

        //Return invalid login resposne
        
        FlexibleCalloutMock mock = new FlexibleCalloutMock(500, InvalidSfdcLoginResponse);
        BaseApiTest.setRequest('/login', RestLoginRequest);
        BaseApiTest.setParam('debug', 'true');
		PartnerApiLoginEndpoint.httpPost();
		JsonReader reader = BaseApiTest.assertErrorResponse(403, 'INVALID_LOGIN');
        System.assertNotEquals(null, reader.getString('details'));
    }
}