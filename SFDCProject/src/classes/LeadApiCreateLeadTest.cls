@IsTest
public class LeadApiCreateLeadTest {
    static BaseClass utils = new BaseClass();

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
        
        LeadServiceDto.CreateLeadResponse resp = LeadCreateLeadRestService.httpPost();
        /*
        System.assertNotEquals(null, resp.prospectId);
        System.assertNotEquals(null, resp.expires);
        System.assertNotEquals(null, resp.signature);
        
        Lead lead = utils.queryLead(resp.leadId);
        
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
        
        //Test updating leads        
        writer.write('prospectId', lead.Prospect_Id__c);
        writer.write('customerLastName', 'Bar2');
        
        RestContext.request.requestBody = Blob.valueOf(writer.toPrettyJson());
        
        resp = LeadCreateLeadRestService.httpPost();        
        
        lead = utils.queryLead(resp.leadId);
        System.assertEquals('Bar2', lead.LastName);
        */
    }
    
    
    testmethod public static void testCreateRequiredFields() {
        insertSettings();
        
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestBody = Blob.valueOf('{"customerFirstName": "Foo"}');
        
        LeadApiLeadsEndpoint.httpPost();
        
        JsonReader reader = new JsonReader(RestContext.response.responseBody.toString());
        System.assertEquals('REQUIRED_FIELDS_MISSING', reader.getString('errorCode'));
        System.assertEquals(400, RestContext.response.statusCode);
    }

   public static void insertSettings() {
        RestServiceDto.insertFieldMapping('Lead Api', 'Lead', 'customerFirstName=FirstName,customerLastName=LastName,company=Company,customerEmail=Email,avgMonthlyElectricityBill=Average_Monthly_Electric_Bill__c,autoDialerOptIn=Auto_dialer_Opt_in__c,customerPhone=Phone,leadOrgLocationId=Lead_Organization_Location_2__c,leadQualifier=Lead_Qualifier__c,decUsage=Dec_Usage__c,prospectId=Prospect_Id__c');
       	RestServiceDto.setRequiredFields('Lead Api', 'Lead', new String[]{'customerFirstName', 'customerLastName'});

       	Sf.settingsService.setString('LeadApiSigningPrivateKey', 'Secret123');
    }
}