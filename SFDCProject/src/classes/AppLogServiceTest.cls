@IsTest
public class AppLogServiceTest {
	
    public static BaseClass utils = new BaseClass();
	private static AppLogServiceImpl impl = new AppLogServiceImpl();	
    
    testmethod public static void testLogging() {
		App_Log__c appLog = null;
        String idForTesting = null;
        
        appLog = Sf.appLogger.logDebug('Module', 'Action', 'Message');
        assert(appLog, 'Debug', 'Module', 'Action', 'Message', null);
        
		appLog = Sf.appLogger.logDebug('Module', 'Action', 'Message', 'Details');
        assert(appLog, 'Debug', 'Module', 'Action', 'Message', null);
        System.assertEquals('Details', appLog.Details__c);
		
        idForTesting = appLog.id;
        appLog = Sf.appLogger.logDebug('Module', 'Action', 'Message', 'Details', idForTesting);
        assert(appLog, 'Debug', 'Module', 'Action', 'Message', idForTesting);
        System.assertEquals('Details', appLog.Details__c);

        Exception e = new SystemException();
        appLog = Sf.appLogger.logError('Module', 'Action', 'Message', e);
        assert(appLog, 'Error', 'Module', 'Action', 'Message', null);
        System.assert(appLog.Details__c.indexOf('SystemException')>=0); 
        
		appLog = Sf.appLogger.logError('Module', 'Action', 'Message', 'Details', e);
        assert(appLog, 'Error', 'Module', 'Action', 'Message', null);
        System.assert(appLog.Details__c.indexOf('SystemException')>=0); 
		
        idForTesting = appLog.id;
        appLog = Sf.appLogger.logError('Module', 'Action', 'Message', 'Details', idForTesting, e);
        assert(appLog, 'Error', 'Module', 'Action', 'Message', idForTesting);
        System.assert(appLog.Details__c.indexOf('SystemException')>=0); 
    }
    
    testmethod public static void testClassMethodPopulation() {
		App_Log__c appLog = null;
        appLog = Sf.appLogger.logError(null, null, null, new SystemException('Test Exception'));
        System.assertEquals('AppLogServiceTest', appLog.Module__c);
        System.assertEquals('testClassMethodPopulation', appLog.Action__c);
        System.assertEquals('Test Exception', appLog.Message__c);
        System.assertNotEquals(null, appLog.Details__c);
    }
    
    testmethod public static void testTextLengthHandling() {
		App_Log__c appLog = null;
        String message = utils.createText('Message', 255);
        appLog = Sf.appLogger.logDebug('Module', 'Action', message);
        System.assertEquals(message, appLog.Message__c);
        
		message = utils.createText('Message', 256);
        appLog = Sf.appLogger.logDebug('Module', 'Action', message);
        System.assertEquals(message.substring(0, 255), appLog.Message__c);
        System.assert(appLog.Details__c.indexOf('Message')>=0);

        String details = utils.createText('Details', AppLogServiceImpl.DetailsMaxLength);
        appLog = Sf.appLogger.logDebug('Module', 'Action', 'Message', details);
        System.assertEquals(details, appLog.Details__c);

        details = utils.createText('Details', AppLogServiceImpl.DetailsMaxLength + 1);
        appLog = Sf.appLogger.logDebug('Module', 'Action', 'Message', details);
        System.assertEquals(details.substring(AppLogServiceImpl.DetailsMaxLength, AppLogServiceImpl.DetailsMaxLength + 1), appLog.Details2__c);

        details = utils.createText('Details', AppLogServiceImpl.DetailsMaxLength * 6);
        appLog = Sf.appLogger.logDebug('Module', 'Action', 'Message', details);
        System.assertEquals(details.substring(0, AppLogServiceImpl.DetailsMaxLength), appLog.Details__c);
        System.assertEquals(details.substring(AppLogServiceImpl.DetailsMaxLength, AppLogServiceImpl.DetailsMaxLength * 2), appLog.Details2__c);
        System.assertEquals(details.substring(AppLogServiceImpl.DetailsMaxLength * 2, AppLogServiceImpl.DetailsMaxLength * 3), appLog.Details3__c);
    }
    
    testmethod public static void testCreate() {
        App_Log__c appLog;
    	appLog = impl.createDebug('module', 'action', 'message');
		assert(appLog, 'Debug', 'module', 'action', 'message', null);
        
    	appLog = impl.createDebug('module', 'action', 'message', 'details');
		assert(appLog, 'Debug', 'module', 'action', 'message', null);
        System.assertEquals('details', appLog.Details__c);

    	appLog = impl.createDebug('module', 'action', 'message', 'details', UserInfo.getUserId());
		assert(appLog, 'Debug', 'module', 'action', 'message', UserInfo.getUserId());

    	appLog = impl.createError('module', 'action', 'message', 'details', UserInfo.getUserId(), null);
		assert(appLog, 'Error', 'module', 'action', 'message', UserInfo.getUserId());

    	appLog = impl.createError('module', 'action', 'message', null, new SystemException('Test Message'));
		assert(appLog, 'Error', 'module', 'action', 'message', null);
    	System.assertNotEquals(null, appLog.Details__c);
        
    	appLog = impl.createError('module', 'action', 'message', null, UserInfo.getUserId(), new SystemException('Test Message'));
		assert(appLog, 'Error', 'module', 'action', 'message', UserInfo.getUserId());
    	System.assertNotEquals(null, appLog.Details__c);

    	appLog = impl.createError('module', 'action', 'message', 'original details', UserInfo.getUserId(), new SystemException('Test Message'));
		assert(appLog, 'Error', 'module', 'action', 'message', UserInfo.getUserId());
    	System.assert(appLog.Details__c.indexOf('original details') >= 0);
    
    	appLog = impl.create('module', 'action', 'message', 'original details', UserInfo.getUserId(), new SystemException('Test Message'));
		assert(appLog, 'Error', 'module', 'action', 'message', UserInfo.getUserId());
    	System.assert(appLog.Details__c.indexOf('original details') >= 0);
    }
    
    testmethod public static void testProcessFields() {
        App_Log__c appLog = new App_Log__c();
        AppLogServiceImpl.DetailsMaxLength = 1000;
       	appLog.Message__c = utils.createText('Length Message', 500);
       	appLog.Details__c = utils.createText('a', AppLogServiceImpl.DetailsMaxLength) + utils.createText('b', AppLogServiceImpl.DetailsMaxLength) + utils.createText('c', AppLogServiceImpl.DetailsMaxLength)
            	+ utils.createText('d', AppLogServiceImpl.DetailsMaxLength) + utils.createText('e', AppLogServiceImpl.DetailsMaxLength) + utils.createText('f', AppLogServiceImpl.DetailsMaxLength);
        impl.processFields(appLog);
        
        System.assertEquals(255, appLog.Message__c.length());
        System.assertEquals(AppLogServiceImpl.DetailsMaxLength, appLog.Details__c.length());
        System.assertEquals(AppLogServiceImpl.DetailsMaxLength, appLog.Details2__c.length());
        System.assertEquals(AppLogServiceImpl.DetailsMaxLength, appLog.Details3__c.length());
        System.assertEquals(AppLogServiceImpl.DetailsMaxLength, appLog.Details4__c.length());
        System.assertEquals(AppLogServiceImpl.DetailsMaxLength, appLog.Details5__c.length());
        
		appLog = new App_Log__c();
        impl.processFields(appLog,new SystemException('Test Message'));
        System.assertEquals('Error', appLog.Type__c);
        System.assertEquals('Test Message', appLog.Message__c);
        System.assertNotEquals(null, appLog.Details__c);
    }

    public static void assert(App_Log__c appLog, String type, String module, String action, String message, String recordId) {
		System.assertEquals(type, appLog.Type__c);
		System.assertEquals(module, appLog.Module__c);
		System.assertEquals(action, appLog.Action__c);
		System.assertEquals(message, appLog.Message__c);
	}
}