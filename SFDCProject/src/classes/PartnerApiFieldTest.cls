@IsTest
public class PartnerApiFieldTest {
	
    testmethod public static void testTrigger() {
        Partner_Api_Field__c field = new Partner_Api_Field__c();
        try {
	        insert field;
            System.assert(false, 'Expected a exception due to missing requried fields');
        } catch (Exception e) {
            //Exception is expected
        }
        field.Api__c = 'Test Api';
        field.Rest_Field__c = 'foo';
        field.Sobject__c = 'Contact';
        field.Sfdc_Field__c = 'non_existing_contact_field__c';
        
        try {
	        insert field;
            System.assert(false, 'Expected a exception due to invalid sfdc field');
        } catch (Exception e) {
            //Exception is expected
        }

        field.Sfdc_Field__c = 'FirstName';
        insert field;
		
        //Now insert second field with same rest field and expect it to fail.
        Partner_Api_Field__c field2 = new Partner_Api_Field__c();
        field2.Api__c = 'Test Api';
        field2.Rest_Field__c = 'foo';
        field2.Sobject__c = 'Contact';
        field2.Sfdc_Field__c = 'FirstName';
        try {
	        insert field2;
            System.assert(false, 'Expected a exception due to duplicate rest field mapping');
        } catch (Exception e) {
            //Exception is expected
        }
        
        //Now update the field to non existing value and it should fail.
        field.Sfdc_Field__c = 'non_existing_contact_field__c';
        try {
	        update field;
            System.assert(false, 'Expected a exception due to invalid sfdc field while updating');
        } catch (Exception e) {
            //Exception is expected
        }
        field.Sfdc_Field__c = 'LastName';
        update field;
    }
    
    testmethod public static void validateRelationshipField() {
        Partner_Api_Field__c field = new Partner_Api_Field__c();
        field.Api__c = 'Test Api';
        field.Rest_Field__c = 'standardRelationField';
        field.Sobject__c = 'Contact';
        field.Sfdc_Field__c = 'NonExisting.Name';
        
        try {
        	insert field;
            System.assert(false, 'Expected a exception due to invalid sfdc field while updating');
        } catch (Exception e) {
            //Expected
        }
     	
        //Now change to valid relationship field and insert.
        field.Sfdc_Field__c = 'Account.Name';
        insert field;
        
        //Same thing for custom relationship field
        field = new Partner_Api_Field__c();
        field.Api__c = 'Test Api';
        field.Rest_Field__c = 'customRelationField';
        field.Sobject__c = 'Contact';
        field.Sfdc_Field__c = 'NonExisting__r.Name';
        
        try {
        	insert field;
            System.assert(false, 'Expected a exception due to invalid sfdc field while updating');
        } catch (Exception e) {
            //Expected
        }
     	
        //Now change to valid relationship field and insert.
        field.Sfdc_Field__c = 'Location__r.Name';
        insert field;
    }
}