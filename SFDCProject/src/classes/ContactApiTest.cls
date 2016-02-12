@IsTest
public class ContactApiTest {
	
    private static BaseClass utils = new BaseClass();
    
    testmethod public static void testGetContact() {
        insertSettings();
        
        Account act = new Account(Name='Foo Bar');
        insert act;
        
        Contact con = new Contact(FirstName='Foo', LastName='Bar', Email='email@email.com', Phone='111-222-3332', AccountId=act.id);
        insert con;
        
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestURI = '/services/apexrest/v2/contacts/' + con.id + '?debug=true';
        ContactApiContactEndpoint.httpGet();

        JsonReader reader = new JsonReader(RestContext.response.responseBody.toString());
        System.assert(reader.getString('errorCode') == null, 'Received exception from rest api ' + RestContext.response.responseBody.toString());
        
        System.assertEquals('Foo', reader.getString('firstName'));
        System.assertEquals('Bar', reader.getString('lastName'));
        System.assertEquals('email@email.com', reader.getString('email'));
        System.assertEquals(null, reader.getString('nonExistingField'));
		
        //Test to make sure we return record not found for invalid ids.
        RestContext.request.requestURI = '/services/apexrest/v2/contacts/non-existingid?debug=true';
        ContactApiContactEndpoint.httpGet();

		reader = new JsonReader(RestContext.response.responseBody.toString());
        System.assertEquals('RECORD_NOT_FOUND', reader.getString('errorCode'), reader.toPrettyJson());
    }
    
    testmethod public static void testUpdateContact() {
        insertSettings();
    
        Account act = new Account(Name='Foo Bar');
        insert act;
        
        Contact con = new Contact(FirstName='Foo', LastName='Bar', Email='email@email.com', Phone='111-222-3332', AccountId=act.id);
        insert con;
        
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestURI = '/services/apexrest/v2/contacts/' + con.id + '?debug=true';
        RestContext.request.requestBody = Blob.valueOf('{"firstName":"Foo2", "phone":null}');
        
        ContactApiContactEndpoint.httpPatch();

        JsonReader reader = new JsonReader(RestContext.response.responseBody.toString());
        System.assert(reader.getString('errorCode') == null, 'Received exception from rest api ' + RestContext.response.responseBody.toString());
		
		con = utils.queryContact(con.id);
		System.assertEquals('Foo2', con.FirstName);
		System.assertEquals(null, con.Phone);
        
        //Fields not updated in the request are not touched.
		System.assertEquals('Bar', con.LastName);
		System.assertEquals('email@email.com', con.Email);
        
        //Test to make sure required fields are validated
        RestContext.request.requestBody = Blob.valueOf('{"firstName":"Foo2", "lastName":null}');
        
        ContactApiContactEndpoint.httpPatch();

        reader = new JsonReader(RestContext.response.responseBody.toString());
        System.assertEquals('REQUIRED_FIELDS_MISSING', reader.getString('errorCode'));
    }
    
    static void insertSettings() {
        RestServiceDto.insertFieldMapping('Contact Api', 'Contact', 'firstName=FirstName,lastName=LastName,email=Email,phone=Phone');
       	RestServiceDto.setRequiredFields('Contact Api', 'Contact', new String[]{'firstName','lastName'});
    }
}