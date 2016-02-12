@IsTest
public class OptyApiTest {
	
    static BaseClass utils = new BaseClass();
    
    testmethod public static void testFields() {
		insertSettings();		
        
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();

        OptyApiFieldsEndpoint.httpGet();
        
        //This would remove the json formatting.
        JsonReader reader = new JsonReader(RestContext.response.responseBody.toString());
        System.assertEquals('StageName', reader.getString('opportunity.leadStage.sfdcField'));
        System.assertEquals('Opportunity_Status__c', reader.getString('opportunity.leadStatus.sfdcField'));
        System.assertEquals('Name', reader.getString('account.customerCompany.sfdcField'));
        System.assertEquals('FirstName', reader.getString('contact.customerFirstName.sfdcField'));
    }
	
    testmethod public static void testOpryCreate() {
		insertSettings();
    
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestBody = Blob.valueOf('{"name" : "Name", "leadStage": "Open", "closeDate": "2015-09-10", "customerCompany": "Foo Bar", "customerFirstName": "Foo", "customerLastName": "Bar", "customerPrimaryPhone": "123-456-7890"}');
        
        OptyApiOptysEndpoint.httpPost();
        
        JsonReader reader = BaseApiTest.assertSuccessResponse();
        System.assertNotEquals(null, reader.getString('prospectId'));
    }    
    
    testmethod public static void testOptyUpdateAndOptyRead() {
		insertSettings();

        Account acct = new Account(Name='Foo Bar', BillingCity='Dublin');
        insert acct;
        
        Opportunity Opty = new Opportunity(Name='Test', StageName='State', 
			CloseDate=Date.newInstance(2015, 06, 20), Account_Type__c='Test', AccountId=acct.id);
        insert opty;
        
        //Insert contact into opty contact role.
        Contact contact = new Contact(FirstName='Foo', LastName='Bar', Email='foo@bar.com', AccountId=acct.id);
        insert contact;
        
        OpportunityContactRole role = new OpportunityContactRole(
        	OpportunityId=opty.id,ContactId=contact.id,IsPrimary=true,Role='Home Owner'
        );
        insert role;
        
        opty = utils.queryOpty(opty.id);
        
        //We will test the opty update by updating one field to new value, setting another to null and leaving
        //rest out of request. In this case, only fields mentioned in the request should have been updated.
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        
        RestContext.request.requestURI = '/services/apexrest/v2/leads/' + opty.Prospect_Id__c + '?debug=true';
        RestContext.request.requestBody = Blob.valueOf('{"name" : "Test2", "accountType": null, "customerCompany": "Foo2", "customerFirstName": "Foo2"}');
		
        OptyApiOptyEndpoint.httpPatch();
        
        opty = utils.queryOpty(opty.id);

        //This updates the contact by primary contact association.
        JsonReader reader = new JsonReader(RestContext.response.responseBody.toString());
        System.assert(reader.getString('errorCode') == null, 'Received exception from rest api ' + RestContext.response.responseBody.toString());
        System.assertEquals(opty.Prospect_Id__c, reader.getString('prospectId'));
        System.assertEquals('Test2', reader.getString('name'));
        System.assertEquals(null, reader.getString('accountType'));
        System.assertEquals('2015-06-20', reader.getString('closeDate'));
        System.assertEquals('2015-06-20', reader.getString('closeDate'));
        System.assertEquals('Foo2', reader.getString('customerFirstName'));
        System.assertEquals('Foo2', reader.getString('customerCompany'));
		
        //Update contact by email
        RestContext.request.requestBody = Blob.valueOf('{"customerFirstName" : "Foo3", "customerEmail": "foo@bar.com"}');
        OptyApiOptyEndpoint.httpPatch();
        
        reader = BaseApiTest.assertSuccessResponse();
        System.assertEquals('Foo3', reader.getString('customerFirstName'));
        
        //Create new contact by email
        RestContext.request.requestBody = Blob.valueOf('{"customerFirstName" : "Foo4","customerLastName" : "Bar4", "customerEmail": "foo4@bar.com"}');
        OptyApiOptyEndpoint.httpPatch();
        reader = BaseApiTest.assertSuccessResponse();
        System.assertEquals('Foo4', reader.getString('customerFirstName'));
        System.assertEquals('foo4@bar.com', reader.getString('customerEmail'));

        //This should read the opty        
        OptyApiOptyEndpoint.httpGet();
        
        reader = BaseApiTest.assertSuccessResponse();
        System.assertEquals(null, reader.getString('message'));
        System.assertEquals(opty.Prospect_Id__c, reader.getString('prospectId'));
        System.assertEquals('Test2', reader.getString('name'));
        System.assertEquals(null, reader.getString('accountType'));
        System.assertEquals('2015-06-20', reader.getString('closeDate'));
    }
    
    testmethod public static void testGetOptyContactsAndUpdateOptyContact() {
        insertSettings();
        
        Account acct = new Account(Name='Foo Bar', BillingCity='Dublin');
        insert acct;
        
        Opportunity Opty = new Opportunity(Name='Test', StageName='State', 
			CloseDate=Date.newInstance(2015, 06, 20), Account_Type__c='Test', AccountId=acct.id);
        insert opty;
        opty = utils.queryOpty(opty.id);
        
        //Insert contact into opty contact role.
        Contact contact = new Contact(FirstName='Foo', LastName='Bar', Email='foo@bar.com', AccountId=acct.id);
        insert contact;
        
        OpportunityContactRole role = new OpportunityContactRole(
        	OpportunityId=opty.id,ContactId=contact.id,IsPrimary=true,Role='Home Owner'
        );
        insert role;
        
        BaseApiTest.setRequest('/v2/leads/' + opty.Prospect_Id__c);
        OptyApiOptyContactsEndpoint.httpGet();
        JsonReader reader = BaseApiTest.assertSuccessResponse();
        System.assertEquals('Foo', reader.getString('[0].customerFirstName'));
		
        //create new opty contact.
        BaseApiTest.setRequest('/v2/leads/' + opty.Prospect_Id__c, '{"customerFirstName":"Foo2","customerLastName":"Bar2","customerEmail":"foo2@yopmail.com","role":"Home Owner"}');
        OptyApiOptyContactsEndpoint.httpPost();
        reader = BaseApiTest.assertSuccessResponse();

        BaseApiTest.setRequest('/v2/leads/' + opty.Prospect_Id__c);
        OptyApiOptyContactsEndpoint.httpGet();
		reader = BaseApiTest.assertSuccessResponse();
        System.assertEquals(2, reader.getList('').size());
    }
    
    testmethod public static void testGetOptyPayments() {
		insertSettings();
        
        Account acct = new Account(Name='Foo Bar');
        insert acct;

        Opportunity Opty = new Opportunity(Name='Test', StageName='State', 
			CloseDate=Date.newInstance(2015, 06, 20), Account_Type__c='Test', AccountId=acct.id);
        insert opty;
        opty = utils.queryOpty(opty.id);
		
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestURI = '/services/apexrest/v2/leads/' + opty.Prospect_Id__c + '/payments?debug=true';
    
        //Now try to get opty payments and it should return empty array.
        OptyApiOptyPaymentsEndpoint.httpGet();
		BaseApiTest.assertSuccessResponse();
        System.assertEquals('[ ]', RestContext.response.responseBody.toString());

        //Now insert a successful payment and non-successful payment. We should return only successful
        //payments.
        Payment_Transaction__c tx = new Payment_Transaction__c(Opportunity__c=opty.id, 
			Status__c='accept', Amount__c=100, Payment_Type__c='check');
		insert tx;
        
		tx = new Payment_Transaction__c(Opportunity__c=opty.id, 
			Status__c='error', Amount__c=0, Payment_Type__c='card');
		insert tx;
        
        OptyApiOptyPaymentsEndpoint.httpGet();
        JsonReader jsonReader = BaseApiTest.assertSuccessResponse();
        System.assertEquals(1, jsonReader.getList(null).size());
        System.assertEquals(100, jsonReader.getDecimal('[0].amount'));
    }
    
    testmethod public static void testGetOptyCredits() {
		insertSettings();
        
		Account acct = new Account(Name='Foo', RecordTypeId=utils.getRecordTypeId('Account', 'Partner'), 
			BillingStreet='Market', Billingcity='Dublin',
			Office_Location__c  = 'Headquarters',
			Stage__c = 'Confirmed',
			Active__c  = true);
        insert acct;

        Opportunity opty = new Opportunity(Name='Test', StageName='Stage', CloseDate=Date.today());
        insert opty;
		opty = utils.queryOpty(opty.id);
        
        //Make sure api returns empty response if there are no contacts with opty.
		BaseApiTest.setRequest('/v2/leads/' + opty.Prospect_Id__c + '/customercredits');
        OptyApiOptyCustomerCreditsEndpoint.httpGet();
        JsonReader reader = BaseApiTest.assertSuccessResponse();
		System.assertEquals(0, reader.getList('').size());
        
        Contact contact1 = new Contact(FirstName='Foo1', LastName='Bar1', AccountId=acct.id);
        insert contact1;
        
        Contact contact2 = new Contact(FirstName='Foo2', LastName='Bar2', AccountId=acct.id);
        insert contact2;

        OpportunityContactRole role1 = new OpportunityContactRole(OpportunityId=opty.id, ContactId=contact1.id, Role='Foo');
        insert role1;

        OpportunityContactRole role2 = new OpportunityContactRole(OpportunityId=opty.id, ContactId=contact2.id, Role='Foo');
        insert role2;
		
		//With sync disabled, even if we insert credit, it should not create sync records.        
        Customer_Credit__c credit = new Customer_Credit__c(Contact__c=contact1.id);
        insert credit;

        credit = new Customer_Credit__c(Contact__c=contact2.id);
        insert credit;
        
        //Make sure api returns empty response if there are no contacts with opty.
		BaseApiTest.setRequest('/v2/leads/' + opty.Prospect_Id__c + '/customercredits');
        OptyApiOptyCustomerCreditsEndpoint.httpGet();
        reader = BaseApiTest.assertSuccessResponse();
		System.assertEquals(2, reader.getList('').size());
    }
    
    testmethod public static void testGetOptyAppointments() {
        insertSettings();
        
        Account acct = new Account(Name='Foo', BillingCity='Dublin', BillingPostalCode='94568');
        insert acct;
        Opportunity opty = new Opportunity(AccountId=acct.id, Name='Foo', StageName='Created');
        insert opty;
	        
        Appointment__c appt = new Appointment__c();
        appt.Appointment_Date_Time__c = DateTime.newInstanceGmt(2010, 11, 12, 13, 14, 15);
        appt.Appointment_End_Date_Time__c = DateTime.newInstanceGmt(2010, 11, 12, 14, 14, 15);
        appt.Appointment_Description__c = 'some notes1';
        appt.Status__c = 'Appointment Set';
        appt.Opportunity__c = opty.id;
        
        insert appt;
        
        appt = new Appointment__c();
        appt.Appointment_Date_Time__c = DateTime.newInstanceGmt(2010, 11, 13, 13, 14, 15);
        appt.Appointment_End_Date_Time__c = DateTime.newInstanceGmt(2010, 11, 13, 14, 14, 15);
        appt.Appointment_Description__c = 'some notes2';
        appt.Status__c = 'Appointment Set';
        appt.Opportunity__c = opty.id;
        
        insert appt;

        opty = new BaseClass().queryOpty(opty.id);
        BaseApiTest.setRequest('/v2/leads/' + opty.Prospect_Id__c + '/appointments?debug=true');
        OptyApiOptyAppointmentsEndpoint.httpGet();
        
        JsonReader reader = BaseApiTest.assertSuccessResponse();
        System.assertEquals(2, reader.getList('').size());
    }
    
    static String unformattedResponseJson() {
		return Json.serialize(Json.deserializeUntyped(RestContext.response.responseBody.toString()));
    }
    
    static void insertSettings() {
        RestServiceDto.insertFieldMapping('Opty Api', 'Opportunity', 'opportunityId=Id,prospectId=Prospect_Id__c,name=Name,leadStage=StageName,leadStatus=Opportunity_Status__c,closeDate=CloseDate');
        RestServiceDto.insertFieldMapping('Opty Api', 'Account', 'customerCompany=Name,customerStreet=BillingStreet,customerCity=BillingCity,customerState=BillingState,customerZipCode=BillingPostalCode');
        RestServiceDto.insertFieldMapping('Opty Api', 'Contact', 'customerFirstName=FirstName,customerLastName=LastName,customerPrimaryPhone=Phone,customerEmail=Email');
        RestServiceDto.insertFieldMapping('Payment Api', 'Payment_Transaction__c', 'paymentNumber=Name,amount=Amount__c,paymentMode=Payment_Mode__c,paymentType=Payment_Type__c,paymentDateTime=Transaction_DateTime__c');
        RestServiceDto.insertFieldMapping('Credit Api', 'Customer_Credit__c', 'customerEmail=Customer_Email__c');
        RestServiceDto.insertFieldMapping('Scheduler Api', 'Appointment__c', 'startTime=Appointment_Date_Time__c,endTime=Appointment_End_Date_Time__c,notes=Appointment_Description__c,appointmentId=Id,status=Status__c');
        Sf.settingsService.setString('LeadApiSigningPrivateKey', 'Secret123');
        
        //This is rquired as some trigger is looking for.
        insert new Opportunity_Email_Status__c(Name='Site Audit Schedule', No_Of_Days_In_Past_Limit__c=5);
        insert new Opportunity_Email_Status__c(Name='Site Audit Complete', No_Of_Days_In_Past_Limit__c=5);
        
        //These are required to insert credit record
        insert new CustomerCreditAutomationInfo__c(Name='FICO_PASS', Field_Value__c='600');
        insert new CustomerCreditAutomationInfo__c(Name='FICO_FAIL', Field_Value__c='400');
        insert new CustomerCreditAutomationInfo__c(Name='FICO_CPASS', Field_Value__c='700');

        OptyApiDto.getOptyApiContactRoleFieldMapping();
        OptyApiDto.getOptyApiPaymentFieldMapping();
        OptyApiDto.getOptyApiContactCreditFieldMapping();
        OptyApiDto.getOptyApiContactRequiredFields();
        OptyApiDto.getOptyApiContactRoleRequiredFields();
    }
}