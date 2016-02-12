@IsTest
public class ExceptionsDeletionBatchTest {
	
    testmethod static void testDeletion() {
        String caseJSON = '{"CreatedDate":"2014-12-09T18:39:51.000+0000"}'; 
        Exception__c e1 = (Exception__c) JSON.deserialize(caseJSON, Exception__c.class); 
        insert e1;
        
        Exception__c e2 = new Exception__c();
        insert e2;
        
        Test.startTest();
        new ExceptionsDeletionBatch().execute(null);
        Test.stopTest();

        //Check that e1 is deleted but e2 is not
        List<Exception__c> es = [select id from Exception__c];
        System.assertEquals(1, es.size());
        System.assertEquals(e2.id, es.get(0).id);
    }
}