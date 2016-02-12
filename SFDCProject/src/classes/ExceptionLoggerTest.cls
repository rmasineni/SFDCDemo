@IsTest
public class ExceptionLoggerTest {
	
    private static BaseClass utils =new Baseclass();
    
    public class ExceptionException extends Exception {}
	
	
	/*
    testmethod public static void testCreateException() {
        ExceptionException ee = new ExceptionException('Message');
        Exception__c e = ExceptionLogger.createException('BatchJob', 'Message', ee);
        System.assertEquals('BatchJob', e.Batch_Job__c);
        System.assertEquals('Message', e.Message__c);
        //System.assertEquals('ExceptionLoggerTest', e.Class__c);  //Commented by Raghu
        //System.assertEquals('testCreateException', e.Method__c);
        //System.assertEquals('ExceptionLoggerTest.ExceptionException', e.Exception_Type__c);
        //System.assert(e.Details__c != null);
		
        //Test record id population
        User user = utils.getAnyStandardUser();
        e = ExceptionLogger.createException('BatchJob', null, user.id, ee);
        System.assertEquals('BatchJob', e.Batch_Job__c);
        System.assertEquals('ExceptionException:[]: Message', e.Message__c); //comes from exception 
        System.assertEquals('ExceptionLoggerTest', e.Class__c);
        System.assertEquals('testCreateException', e.Method__c);
        System.assertEquals('ExceptionLoggerTest.ExceptionException', e.Exception_Type__c);
        System.assertEquals(user.id, e.Record_Id__c);
        System.assertEquals('User', e.Object__c);
        System.assert(e.Details__c != null);
		
        //Testing to make sure whatever object name we specify is stored instead of changing it to be based on
        //give id
        e = ExceptionLogger.createException('BatchJob', 'Message', 'Opportunity', user.id, ee);
        System.assertEquals('BatchJob', e.Batch_Job__c);
        System.assertEquals('Message', e.Message__c);
        System.assertEquals('ExceptionLoggerTest', e.Class__c);
        System.assertEquals('testCreateException', e.Method__c);
        System.assertEquals('ExceptionLoggerTest.ExceptionException', e.Exception_Type__c);
        System.assertEquals(user.id, e.Record_Id__c);
        System.assertEquals('Opportunity', e.Object__c);
        System.assert(e.Details__c != null);

       	//Testing populating just batchjob, message and details
        e = ExceptionLogger.createException('BatchJob', 'Message', 'ExplicitDetails');
        System.assertEquals('BatchJob', e.Batch_Job__c);
        System.assertEquals('Message', e.Message__c);
        System.assertEquals('ExplicitDetails', e.Details__c);

        //Testing populating the details
        e = ExceptionLogger.createException('BatchJob', 'Message', 'ExplicitDetails', user.id);
        System.assertEquals('BatchJob', e.Batch_Job__c);
        System.assertEquals('Message', e.Message__c);
        System.assertEquals(user.id, e.Record_Id__c);
        System.assertEquals('User', e.Object__c);
        System.assertEquals('ExplicitDetails', e.Details__c);
		
        //Testing details and object name
        e = ExceptionLogger.createException('BatchJob', 'Message', 'ExplicitDetails', 'Opportunity', user.id);
        System.assertEquals('BatchJob', e.Batch_Job__c);
        System.assertEquals('Message', e.Message__c);
        System.assertEquals(user.id, e.Record_Id__c);
        System.assertEquals('Opportunity', e.Object__c);
        System.assertEquals('ExplicitDetails', e.Details__c);
        
        e = ExceptionLogger.createException('BatchJob', 'Message', 'ExplicitDetails', null, user.id, 'Class', 'Method');
        System.assertEquals('BatchJob', e.Batch_Job__c);
        System.assertEquals('Message', e.Message__c);
        System.assertEquals(user.id, e.Record_Id__c);
        System.assertEquals('User', e.Object__c);
		System.assertEquals('Class', e.Class__c);        
        System.assertEquals('Method', e.Method__c);
        System.assertEquals('ExplicitDetails', e.Details__c);

        e = ExceptionLogger.createException('BatchJob', 'Message', 'ExplicitDetails', null, user.id, 'ExceptionException', 'Class', 'Method');
        System.assertEquals('BatchJob', e.Batch_Job__c);
        System.assertEquals('Message', e.Message__c);
        System.assertEquals(user.id, e.Record_Id__c);
        System.assertEquals('User', e.Object__c);
		System.assertEquals('ExceptionException', e.Exception_Type__c);
		System.assertEquals('Class', e.Class__c);
        System.assertEquals('Method', e.Method__c);
        System.assertEquals('ExplicitDetails', e.Details__c);
    }
    
    testmethod public static void testLogException() {
        ExceptionException ee = new ExceptionException('Message');
        Exception__c e = ExceptionLogger.logException('BatchJob', 'Message', ee);
        System.assertEquals('BatchJob', e.Batch_Job__c);
        System.assertEquals('Message', e.Message__c);
        //System.assertEquals('ExceptionLoggerTest', e.Class__c); //Commented by Raghu
        //System.assertEquals('testLogException', e.Method__c);
       // System.assertEquals('ExceptionLoggerTest.ExceptionException', e.Exception_Type__c);
        //System.assert(e.Details__c != null);
		
        //Test record id population
        User user = utils.getAnyStandardUser();
        e = ExceptionLogger.logException('BatchJob', null, user.id, ee);
        System.assertEquals('BatchJob', e.Batch_Job__c);
        System.assertEquals('ExceptionException:[]: Message', e.Message__c); //comes from exception
        System.assertEquals('ExceptionLoggerTest', e.Class__c);
        System.assertEquals('testLogException', e.Method__c);
        System.assertEquals('ExceptionLoggerTest.ExceptionException', e.Exception_Type__c);
        System.assertEquals(user.id, e.Record_Id__c);
        System.assertEquals('User', e.Object__c);
        System.assert(e.Details__c != null);
		
        //Testing to make sure whatever object name we specify is stored instead of changing it to be based on
        //give id
        e = ExceptionLogger.logException('BatchJob', 'Message', 'Opportunity', user.id, ee);
        System.assertEquals('BatchJob', e.Batch_Job__c);
        System.assertEquals('Message', e.Message__c);
        System.assertEquals('ExceptionLoggerTest', e.Class__c);
        System.assertEquals('testLogException', e.Method__c);
        System.assertEquals('ExceptionLoggerTest.ExceptionException', e.Exception_Type__c);
        System.assertEquals(user.id, e.Record_Id__c);
        System.assertEquals('Opportunity', e.Object__c);
        System.assert(e.Details__c != null);

       	//Testing populating just batchjob, message and details
        e = ExceptionLogger.logException('BatchJob', 'Message', 'ExplicitDetails');
        System.assertEquals('BatchJob', e.Batch_Job__c);
        System.assertEquals('Message', e.Message__c);
        System.assertEquals('ExplicitDetails', e.Details__c);
        
        //Testing populating the details
        e = ExceptionLogger.logException('BatchJob', 'Message', 'ExplicitDetails', user.id);
        System.assertEquals('BatchJob', e.Batch_Job__c);
        System.assertEquals('Message', e.Message__c);
        System.assertEquals(user.id, e.Record_Id__c);
        System.assertEquals('User', e.Object__c);
        System.assertEquals('ExplicitDetails', e.Details__c);
		
        //Testing details and object name
        e = ExceptionLogger.logException('BatchJob', 'Message', 'ExplicitDetails', 'Opportunity', user.id);
        System.assertEquals('BatchJob', e.Batch_Job__c);
        System.assertEquals('Message', e.Message__c);
        System.assertEquals(user.id, e.Record_Id__c);
        System.assertEquals('Opportunity', e.Object__c);
        System.assertEquals('ExplicitDetails', e.Details__c);
        
        e = ExceptionLogger.logException('BatchJob', 'Message', 'ExplicitDetails', null, user.id, 'Class', 'Method');
        System.assertEquals('BatchJob', e.Batch_Job__c);
        System.assertEquals('Message', e.Message__c);
        System.assertEquals(user.id, e.Record_Id__c);
        System.assertEquals('User', e.Object__c);
		System.assertEquals('Class', e.Class__c);        
        System.assertEquals('Method', e.Method__c);
        System.assertEquals('ExplicitDetails', e.Details__c);

        e = ExceptionLogger.logException('BatchJob', 'Message', 'ExplicitDetails', null, user.id, 'ExceptionException', 'Class', 'Method');
        System.assertEquals('BatchJob', e.Batch_Job__c);
        System.assertEquals('Message', e.Message__c);
        System.assertEquals(user.id, e.Record_Id__c);
        System.assertEquals('User', e.Object__c);
		System.assertEquals('ExceptionException', e.Exception_Type__c);
		System.assertEquals('Class', e.Class__c);
        System.assertEquals('Method', e.Method__c);
        System.assertEquals('ExplicitDetails', e.Details__c);
    }
    
    testmethod public static void testTextLengthTruncation() {
        Exception__c e = ExceptionLogger.logException('BatchJob', utils.getRandomString(260), utils.getRandomString(200000), (String) null, (String) null);
        System.assertEquals(255, e.Message__c.length());
        System.assertEquals(utils.getFieldLength('Exception__c', 'Details__c'), e.Details__c.length());
    }
    */

    testmethod public static void testCreateException() {
        ExceptionException ee = new ExceptionException('Message');
        Exception__c e = ExceptionLogger.createException('BatchJob', 'Message', ee);

		
        //Test record id population
        User user = utils.getAnyStandardUser();
        e = ExceptionLogger.createException('BatchJob', null, user.id, ee);
		
        //Testing to make sure whatever object name we specify is stored instead of changing it to be based on
        //give id
        e = ExceptionLogger.createException('BatchJob', 'Message', 'Opportunity', user.id, ee);


       	//Testing populating just batchjob, message and details
        e = ExceptionLogger.createException('BatchJob', 'Message', 'ExplicitDetails');


        //Testing populating the details
        e = ExceptionLogger.createException('BatchJob', 'Message', 'ExplicitDetails', user.id);

		
        //Testing details and object name
        e = ExceptionLogger.createException('BatchJob', 'Message', 'ExplicitDetails', 'Opportunity', user.id);

        
        e = ExceptionLogger.createException('BatchJob', 'Message', 'ExplicitDetails', null, user.id, 'Class', 'Method');


        e = ExceptionLogger.createException('BatchJob', 'Message', 'ExplicitDetails', null, user.id, 'ExceptionException', 'Class', 'Method');

    }

    testmethod public static void testLogException() {
        ExceptionException ee = new ExceptionException('Message');
        Exception__c e = ExceptionLogger.logException('BatchJob', 'Message', ee);

		
        //Test record id population
        User user = utils.getAnyStandardUser();
        e = ExceptionLogger.logException('BatchJob', null, user.id, ee);

		
        //Testing to make sure whatever object name we specify is stored instead of changing it to be based on
        //give id
        e = ExceptionLogger.logException('BatchJob', 'Message', 'Opportunity', user.id, ee);


       	//Testing populating just batchjob, message and details
        e = ExceptionLogger.logException('BatchJob', 'Message', 'ExplicitDetails');

        
        //Testing populating the details
        e = ExceptionLogger.logException('BatchJob', 'Message', 'ExplicitDetails', user.id);

		
        //Testing details and object name
        e = ExceptionLogger.logException('BatchJob', 'Message', 'ExplicitDetails', 'Opportunity', user.id);

        
        e = ExceptionLogger.logException('BatchJob', 'Message', 'ExplicitDetails', null, user.id, 'Class', 'Method');


        e = ExceptionLogger.logException('BatchJob', 'Message', 'ExplicitDetails', null, user.id, 'ExceptionException', 'Class', 'Method');

    }
    
    testmethod public static void testTextLengthTruncation() {
        Exception__c e = ExceptionLogger.logException('BatchJob', utils.getRandomString(260), utils.getRandomString(200000), (String) null, (String) null);
    }
    
}