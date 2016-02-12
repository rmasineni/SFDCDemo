@IsTest
public class LeadApiTest {

    static BaseClass utils = new BaseClass();
    
    testmethod public static void testFields() {
		insertSettings();
        
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();

        LeadApiFieldsEndpoint.httpGet();
        
        //This would remove the json formatting.
        JsonReader reader = new JsonReader(RestContext.response.responseBody.toString());
        System.assertEquals('FirstName', reader.getString('customerFirstName.sfdcField'));
        System.assertEquals('LastName', reader.getString('customerLastName.sfdcField'));
        System.assertEquals('Company', reader.getString('company.sfdcField'));
    }
	
    testmethod public static void testV1Create() {
		insertSettings();
        
        //Account to test the leadOrgLocationName to id lookup.
        Account account = new Account(Name='Lead Org Location Account', RecordTypeId=utils.getRecordTypeId('Account', 'Partner'), Channel_Type__c='Retail');
        insert account;     
        
        //There is a dynamic field in request called UserId. We need to insert any standard user's id in there so we can 
        //ensure code is looking up appropritely.
        User user = utils.getAnyStandardUser();
        
        //we need to ensure email is unique as lookup is based on the email so we will
        //set to something unique
        user.email = 'someveryuniqueemail@yopmail.com';
        update user;
        
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        JsonWriter writer = new JsonWriter();
        writer.write('customerFirstName', 'Foo');
        writer.write('customerLastName', 'Bar');
        writer.write('customerEmail', 'foo.bar@yopmail.com');
        writer.write('consultationDateTime', '2014-09-03T22:08:23Z');
        writer.write('leadQualifier', user.email);
        writer.write('customerPhone', '1234567890');
        writer.write('avgMonthlyElectricityBill', 120.2);
        writer.write('decUsage', 220);
        writer.write('autoDialerOptIn', true);
        writer.write('leadOrgLocationName', 'Lead Org Location Account');
        
        RestContext.request.requestBody = Blob.valueOf(writer.toPrettyJson());
        RestContext.request.httpMethod = 'POST';
        
        LeadApiLeadsV1Endpoint.httpPost();
        
        JsonReader reader = new JsonReader(RestContext.response.responseBody.toString());
        System.assertEquals(200, RestContext.response.statusCode);
        System.assertNotEquals(null, reader.getString('prospectId'));
        System.assertNotEquals(null, reader.getString('expires'));
        System.assertNotEquals(null, reader.getString('signature'));
    }
    
    testmethod public static void testCreate() {
		insertSettings();
        
        //This is default and shouldn't not change the request
        //as we have specified first name.
        insert new Partner_API_Default_Value__c (
        	Type__c='Default',
            Input_Field__c='customerFirstName',
            Input_Value__c='Foo',
            Output_Field__c='customerFirstName',
            Output_Value__c='Foo2',
            Active__c=true,
            API__c='LeadApiCreateLead'
        );

        insert new Partner_API_Default_Value__c (
        	Type__c='Override',
            Input_Field__c='customerLastName',
            Input_Value__c='Bar',
            Output_Field__c='customerLastName',
            Output_Value__c='Bar2',
            Active__c=true,
            API__c='LeadApiCreateLead'
        );
        
        //Account to test the leadOrgLocationName to id lookup.
        Account account = new Account(Name='Lead Org Location Account', RecordTypeId=utils.getRecordTypeId('Account', 'Partner'), Channel_Type__c='Retail');
        insert account;     
        
        //There is a dynamic field in request called UserId. We need to insert any standard user's id in there so we can 
        //ensure code is looking up appropritely.
        User user = utils.getAnyStandardUser();
        
        //we need to ensure email is unique as lookup is based on the email so we will
        //set to something unique
        user.email = 'someveryuniqueemail@yopmail.com';
        update user;
        
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        JsonWriter writer = new JsonWriter();
        writer.write('customerFirstName', 'Foo');
        writer.write('customerLastName', 'Bar');
        writer.write('customerEmail', 'foo.bar@yopmail.com');
        writer.write('consultationDateTime', '2014-09-03T22:08:23Z');
        writer.write('leadQualifier', user.email);
        writer.write('customerPhone', '1234567890');
        writer.write('avgMonthlyElectricityBill', 120.2);
        writer.write('decUsage', 220);
        writer.write('autoDialerOptIn', true);
        writer.write('leadOrgLocationName', 'Lead Org Location Account');
        
        RestContext.request.requestBody = Blob.valueOf(writer.toPrettyJson());
        RestContext.request.httpMethod = 'POST';
        
        LeadApiLeadsEndpoint.httpPost();
        
        JsonReader reader = new JsonReader(RestContext.response.responseBody.toString());
        System.assertEquals(201, RestContext.response.statusCode);
        System.assertNotEquals(null, reader.getString('prospectId'));
        System.assertNotEquals(null, reader.getString('expires'));
        System.assertNotEquals(null, reader.getString('signature'));
        
        Lead lead = utils.queryLead(reader.getString('leadId'));

        System.assertEquals('Foo', lead.FirstName);
        System.assertEquals('Bar2', lead.LastName); 
        System.assertEquals('Foo Bar2', lead.Company);
        System.assertEquals('foo.bar@yopmail.com', lead.Email);
        System.assertEquals(Date.newInstance(2014, 09, 03), lead.Consultation_Date_and_Time__c);
        System.assertEquals('3 PM', lead.Consultation_Time__c);
        System.assertEquals('(123) 456-7890', lead.Phone);
        System.assertEquals(120.2, lead.Average_Monthly_Electric_Bill__c);
        System.assertEquals(220, lead.Dec_Usage__c);
        System.assertEquals(true, lead.Auto_dialer_Opt_in__c);
        System.assertEquals(account.id, lead.Lead_Organization_Location_2__c);
        System.assertEquals(user.id, lead.Lead_Qualifier__c);
    }
    

    testmethod public static void testCreateRequiredFields() {
		insertSettings();
        
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestBody = Blob.valueOf('{"customerFirstName": "Foo"}');
        
        LeadApiLeadsEndpoint.httpPost();
        
        JsonReader reader = new JsonReader(RestContext.response.responseBody.toString());
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals('REQUIRED_FIELDS_MISSING', reader.getString('errorCode'));
    }

    testmethod public static void testGetLeads() {
        insertSettings();
        
        //Create two leads, and three opties. One with lead generated by set and one without.
        //One opty with lead gen, one lead with salesrp and another without either.
        //Ensure that only total 3 records are returned.
        Lead lead1 = new Lead(FirstName='Foo', LastName='Bar', Email='foo.bar@yopmail.com', Company='Foo Bar', Channel__c='Partner', Lead_Generated_By__c=UserInfo.getUserId());
        insert lead1;
        Lead lead2 = new Lead(FirstName='Foo', LastName='Bar', Email='foo.bar@yopmail.com', Company='Foo Bar', Channel__c='Partner');
        insert lead2;
        Account acct = new Account(Name='Foo Bar', BillingCity='Dublin');
        insert acct;
        
        Opportunity opty1 = new Opportunity(Name='Test', StageName='State', 
			CloseDate=Date.newInstance(2015, 06, 20), Account_Type__c='Test', AccountId=acct.id,
            External_Id__c= 'OptyApiExternalId', Lead_Generated_By__c=UserInfo.getUserId());
        insert opty1;
        Opportunity opty2 = new Opportunity(Name='Test', StageName='State', 
			CloseDate=Date.newInstance(2015, 06, 20), Account_Type__c='Test', AccountId=acct.id,
            External_Id__c= 'OptyApiExternalId', SalesRep__c=UserInfo.getUserId());
        insert opty2;
        Opportunity opty3 = new Opportunity(Name='Test', StageName='State', 
			CloseDate=Date.newInstance(2015, 06, 20), Account_Type__c='Test', AccountId=acct.id,
            External_Id__c= 'OptyApiExternalId');
        insert opty3;
        
        BaseApiTest.setRequest('/v2/leads');
        BaseApiTest.setParam('startTime', '2015-01-01T01:01:01Z');
        BaseApiTest.setParam('endTime', '2099-01-01T01:01:01Z');
        LeadApiLeadsEndpoint.httpGet();
        JsonReader reader = BaseApiTest.assertSuccessResponse();
        System.assertEquals(3, reader.getList('').size());
    }
    
    testmethod public static void testOptyUpdateAndRead() {
		insertSettings();
        
        Lead lead = new Lead(FirstName='Foo', LastName='Bar', Email='foo.bar@yopmail.com', Company='Foo Bar', Channel__c='Partner');
        insert lead;
        lead = utils.queryLead(lead.id);
        
        //We will test the opty update by updating one field to new value, setting another to null and leaving
        //rest out of request. In this case, only fields mentioned in the request should have been updated.
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        
        RestContext.request.requestURI = '/services/apexrest/v2/leads/' + lead.Prospect_Id__c;
        RestContext.request.requestBody = Blob.valueOf('{"customerFirstName" : "Foo2", "customerEmail": null}');
		
        LeadApiLeadEndpoint.httpPatch();
        JsonReader reader = new JsonReader(RestContext.response.responseBody.toString());
        System.assert(reader.getString('errorCode') == null, 'Received exception from rest api ' + RestContext.response.responseBody.toString());
        
        lead = utils.queryLead(lead.id);

        System.assertEquals(lead.Prospect_Id__c, reader.getString('prospectId'));
        System.assertEquals('Foo2', reader.getString('customerFirstName'));
        System.assertEquals('Bar', reader.getString('customerLastName'));
        System.assertEquals(null, reader.getString('customerEmail'));
		
		//This should read the opty 
        LeadApiLeadEndpoint.httpGet();
        
        reader = new JsonReader(RestContext.response.responseBody.toString());
        System.assertEquals(lead.Prospect_Id__c, reader.getString('prospectId'));
        System.assertEquals('Foo2', reader.getString('customerFirstName'));
        System.assertEquals('Bar', reader.getString('customerLastName'));
        System.assertEquals(null, reader.getString('customerEmail'));
    }

    //When there is a opty with specified prospect id or external id, then
    //opty is given preference over lead. For this we will create a opty with
    //prospect id and external id and then will query/update based on that.
    testmethod public static void testOptyHookupInLeadApi() {
        insertSettings();
        
        Account acct = new Account(Name='Foo Bar', BillingCity='Dublin');
        insert acct;
        
        Opportunity opty = new Opportunity(Name='Test', StageName='State', 
			CloseDate=Date.newInstance(2015, 06, 20), Account_Type__c='Test', AccountId=acct.id,
            External_Id__c= 'OptyApiExternalId');
        insert opty;
		opty = utils.queryOpty(opty.id);
        
        //Update opty using external id and update opty using prospect id.
        //We will test the opty update by updating one field to new value, setting another to null and leaving
        //rest out of request. In this case, only fields mentioned in the request should have been updated.
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        
        RestContext.request.requestURI = '/services/apexrest/v2/leads/' + opty.Prospect_Id__c + '?debug=true';
        RestContext.request.requestBody = Blob.valueOf('{"leadStage" : "Open2"}');
        LeadApiLeadEndpoint.httpPatch();
	    JsonReader reader = new JsonReader(RestContext.response.responseBody.toString());
        System.assert(reader.getString('errorCode') == null, 'Received exception from rest api ' + RestContext.response.responseBody.toString());

        RestContext.request.requestURI = '/services/apexrest/v2/leads/' + opty.External_id__c;
        RestContext.request.requestBody = Blob.valueOf('{"leadStatus" : "Open3"}');
        LeadApiLeadEndpoint.httpPatch();
        reader = new JsonReader(RestContext.response.responseBody.toString());
        System.assert(reader.getString('errorCode') == null, 'Received exception from rest api ' + RestContext.response.responseBody.toString());
		
        //Read the opty and check if values are appropriately updated.
        RestContext.request.requestURI = '/services/apexrest/v2/leads/' + opty.External_id__c;
        LeadApiLeadEndpoint.httpGet();
        reader = new JsonReader(RestContext.response.responseBody.toString());
        System.assert(reader.getString('errorCode') == null, 'Received exception from rest api ' + RestContext.response.responseBody.toString());
        System.assertEquals('Open2', reader.getString('leadStage'));
        System.assertEquals('Open3', reader.getString('leadStatus'));
    }
    
    testmethod public static void testDelete() {
        Lead lead = new Lead(FirstName='Foo', LastName='Bar', Email='foo.bar@yopmail.com', Company='Foo Bar', Channel__c='Partner');
        insert lead;
        lead = utils.queryLead(lead.id);
        
        BaseApiTest.setRequest('/v2/leads/' + lead.prospect_Id__c);
        BaseApiTest.setParam('allowDelete', 'true');
        LeadApiLeadEndPoint.httpDelete();
        BaseApiTest.assertSuccessResponse();
        System.assertEquals(null, utils.queryLead(lead.id));
    }
    
    static String unformattedResponseJson() {
		return Json.serialize(Json.deserializeUntyped(RestContext.response.responseBody.toString()));
    }
    
    static void insertSettings() {
        RestServiceDto.insertFieldMapping('Lead Api', 'Lead', 'prospectId=Prospect_Id__c,customerFirstName=FirstName,customerLastName=LastName,company=Company,customerEmail=Email,avgMonthlyElectricityBill=Average_Monthly_Electric_Bill__c,autoDialerOptIn=Auto_dialer_Opt_in__c,customerPhone=Phone,leadOrgLocationId=Lead_Organization_Location_2__c,leadQualifier=Lead_Qualifier__c,decUsage=Dec_Usage__c,prospectId=Prospect_Id__c');
       	RestServiceDto.setRequiredFields('Lead Api', 'Lead', new String[]{'customerFirstName', 'customerLastName'});
       	RestServiceDto.setSummaryFields('Lead Api', new String[]{'prospectId', 'customerFirstName'});
        
        RestServiceDto.insertFieldMapping('Opty Api', 'Opportunity', 'prospectId=Prospect_Id__c,name=Name,leadStage=StageName,leadStatus=Opportunity_Status__c,closeDate=CloseDate');
        RestServiceDto.insertFieldMapping('Opty Api', 'Account', 'customerCompany=Name,customerStreet=BillingStreet,customerCity=BillingCity,customerState=BillingState,customerZipCode=BillingPostalCode');
        RestServiceDto.insertFieldMapping('Opty Api', 'Contact', 'customerFirstName=FirstName,customerLastName=LastName,customerPrimaryPhone=Phone,customerEmail=Email');
       	RestServiceDto.setSummaryFields('Opty Api', new String[]{'prospectId', 'customerFirstName'});
		
        Sf.settingsService.setString('LeadApiSigningPrivateKey', 'Secret123');
    }
}