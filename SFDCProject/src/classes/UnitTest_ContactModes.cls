@istest
public class UnitTest_ContactModes {

	public static string errorResponseBody = '<?xml version="1.0" encoding="utf-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><soapenv:Fault><faultcode>soapenv:Server.userException</faultcode><faultstring>java.lang.NumberFormatException: For input string: &quot;null&quot;</faultstring><detail><ns1:hostname xmlns:ns1="http://xml.apache.org/axis/">dev-api1</ns1:hostname></detail></soapenv:Fault></soapenv:Body></soapenv:Envelope>'; 
	public static string errorStatus = 'Internal Server Error'; 
	public static string errorStatusCode = '500'; 

	public static string successResponseBody = '<?xml version="1.0" encoding="utf-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><ns1:updateContactModesFromSalesforceResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="http://protocol010000.contract.sunrungeneration.com"><updateContactModesFromSalesforceReturn soapenc:arrayType="ns2:contactModeRelationshipRequest010000[1]" xsi:type="soapenc:Array" xmlns:ns2="srg" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"><updateContactModesFromSalesforceReturn xsi:type="ns2:contactModeRelationshipRequest010000"><contactModes soapenc:arrayType="ns2:contactMode010000[1]" xsi:type="soapenc:Array"><contactModes xsi:type="ns2:contactMode010000"><errorDescription xsi:type="soapenc:string" xsi:nil="true"/><isActive xsi:type="xsd:boolean">true</isActive><modeId xsi:type="soapenc:int">MODEID_VAL</modeId><modeName xsi:type="soapenc:string">MODENAME_VAL</modeName><statusCode xsi:type="soapenc:string">SUCCESS</statusCode></contactModes></contactModes><email xsi:type="soapenc:string">cfoldesh@recsolar.com.intdev</email><errorDescription xsi:type="soapenc:string" xsi:nil="true"/><firstName xsi:type="soapenc:string">null</firstName><lastName xsi:type="soapenc:string">Chris Foldesh</lastName><salesforceAccountId xsi:type="soapenc:string">ACCOUNTID_VAL</salesforceAccountId><salesforceContactId xsi:type="soapenc:string">CONTACTID_VAL</salesforceContactId><statusCode xsi:type="soapenc:string" xsi:nil="true"/><title xsi:type="soapenc:string">null</title></updateContactModesFromSalesforceReturn></updateContactModesFromSalesforceReturn></ns1:updateContactModesFromSalesforceResponse></soapenv:Body></soapenv:Envelope>'; 
	public static string successStatus = 'OK'; 
	public static string successStatusCode = '200'; 	

	static testmethod void testNewContactMode(){
		HttpResponse responseObj = new HttpResponse();
		
		//Insert Account
		Account accountObj1 = TestPRMLibrary.insertAccount('PRMPartnerAccountUSA', PRMLibrary.PARTNER);
		
		//Insert Contact
		Contact contactObj1 = TestPRMLibrary.insertContact('PRMTestAccount1', PRMLibrary.PARTNER, 
															'PRMTestLastName1', 'prmcontact1@gmail.com');		
		contactObj1.AccountId = accountObj1.Id;
		update contactObj1;
		System.debug('contactObj1.AccountId: ' + contactObj1.AccountId);
		
		//Insert Partner Modes
		Partner_Modes__c partnerModesObj1 = new Partner_Modes__c();
		partnerModesObj1.Mode_Id__c = '1234';
		partnerModesObj1.Mode_Name__c = 'Mode1';
		partnerModesObj1.Account__c = accountObj1.id;
		partnerModesObj1.ModeId_accountId__C = partnerModesObj1.Mode_Id__c + partnerModesObj1.Account__c;
		insert partnerModesObj1;

		Partner_Modes__c partnerModesObj2 = new Partner_Modes__c();
		partnerModesObj2.Mode_Id__c = '2234';
		partnerModesObj2.Mode_Name__c = 'Mode2';
		partnerModesObj2.Account__c = accountObj1.id;
		partnerModesObj2.ModeId_accountId__C = partnerModesObj2.Mode_Id__c + partnerModesObj2.Account__c;
		insert partnerModesObj2;
		
		//Insert Contact Modes
		List<Contact_Mode_Rel__c> contactModes = new List<Contact_Mode_Rel__c>();
		Contact_Mode_Rel__c contactModeRelObj1 = new Contact_Mode_Rel__c();
		contactModeRelObj1.Contact__c = contactObj1.Id;
		contactModeRelObj1.Isactive__c = true;
		contactModeRelObj1.Partner_Modes__c = partnerModesObj1.Id;
		insert contactModeRelObj1;

		Contact_Mode_Rel__c contactModeRelObj2 = new Contact_Mode_Rel__c();
		contactModeRelObj2.Contact__c = contactObj1.Id;
		contactModeRelObj2.Isactive__c = true;
		contactModeRelObj2.Partner_Modes__c = partnerModesObj2.Id;
		insert contactModeRelObj2;

		//Invoke WebService
		PRMContactModes contactModesObj = new PRMContactModes();
		contactModesObj.sendContactModesToProposalTool(contactObj1.Id, true);
		
		String tempResponseXML = successResponseBody.replace('MODEID_VAL', partnerModesObj1.Mode_Id__c);
		tempResponseXML = tempResponseXML.replace('ACCOUNTID_VAL', contactObj1.AccountId);
		tempResponseXML = tempResponseXML.replace('CONTACTID_VAL', contactObj1.Id);
		tempResponseXML = tempResponseXML.replace('MODENAME_VAL', partnerModesObj1.Mode_Name__c);
		
		//Process HTTP Response
		HTTPResponse httpResponseObj = new HTTPResponse(); 	
		httpResponseObj.setStatus(successStatus);
		httpResponseObj.setStatusCode(200);
		httpResponseObj.setBody(tempResponseXML);
		contactModesObj.processHTTPResponse(httpResponseObj);

		httpResponseObj.setStatus(errorStatus);
		httpResponseObj.setStatusCode(500);
		httpResponseObj.setBody(errorResponseBody);
		contactModesObj.processHTTPResponse(httpResponseObj);

		httpResponseObj.setStatus('OK');
		httpResponseObj.setStatusCode(300);
		httpResponseObj.setBody(errorResponseBody);
		contactModesObj.processHTTPResponse(httpResponseObj);
		PRMContactModesGlobal.sendContactModesToProposalTool(contactObj1.Id);
	}

}