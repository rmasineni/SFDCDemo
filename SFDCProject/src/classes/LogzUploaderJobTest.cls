@IsTest
public class LogzUploaderJobTest {
	
    testmethod public static void testJobsUploader() {
        
        //This will create a apex job entry, which we will query to send to logz
        Test.startTest();
        System.enqueueJob(new TestQueue());
        Test.stopTest();

        BaseClass.testParams.put('HttpCalloutMock', new FlexibleCalloutMock(200, ''));
        new LogzUploaderJob().execute(null);
    }
    
    testmethod public static void testAppLogsUploader() {
		//Create one with Error status and one with Exception status and one with Debug.
		//Check that we have picked debug/exception records for processing.		
        insert new App_Log__c(Message__c='Debug Message', Type__c='Debug');
        insert new App_Log__c(Message__c='Error Message', Type__c='Error');
        insert new App_Log__c(Message__c='Exception Message', Type__c='Exception');
        
        FlexibleCalloutMock mock = new FlexibleCalloutMock(200, '');
        Test.startTest();
        new LogzUploaderJob().execute(null);
        Test.stopTest();
        
        //Go back and check the invocations. We should have a one invocation with error and exception message.
        System.assertEquals(1, mock.calloutRequests.size());
        System.assert(mock.calloutRequests.get(0).request.getBody().indexOf('Error Message') >= 0);
        System.assert(mock.calloutRequests.get(0).request.getBody().indexOf('Exception Message') >= 0);
        
        //We should not see debug posted.
        System.assert(mock.calloutRequests.get(0).request.getBody().indexOf('Debug Message') < 0);
    }

    public class TestQueue implements Queueable {
        public void execute(QueueableContext ctx) {
            //nothing to execute
        }
    }
}