@IsTest
public class GoogleCalendarServiceTest {
	private static BaseClass utils = new BaseClass();
	private static GoogleCalendarServiceImpl impl = new GoogleCalendarServiceImpl();
    private static String SummaryFullLength = 'this is really long summary to test the event sync from Google to Salesforce. When we have more than 255 chars Salesforce will fails so we will trim to that length. This is to test that trimming function to make sure it functions as it should. Not sure why would one want to type summary longer than this but it is what it is.';
    private static String Summary255Chars = 'this is really long summary to test the event sync from Google to Salesforce. When we have more than 255 chars Salesforce will fails so we will trim to that length. This is to test that trimming function to make sure it functions as it should. Not sure wh';
    private static String TestRespAccessToken = '{"access_token" : "google_access_token", "token_type" : "Bearer", "expires_in" : 3600 }';
    private static String TestRespInsert = '{"id": "event_id_for_insert", "status": "confirmed", "created": "2014-10-25T19:45:17.000Z", "updated": "2014-10-25T19:45:17.452Z", "summary": "New Sfdc Event", "creator": {"email": "187584108634-ss49re0vval2t9elqie6ac8gsjn9f6l2@developer.gserviceaccount.com"}, "start": {"dateTime": "2014-10-20T09:30:00-07:00"}, "end": {"dateTime": "2014-10-20T10:30:00-07:00"}, "sequence": 0, "extendedProperties": {"private": {"salesforceEventId": "00U11000002g7qhEAA"} } }';
    private static String TestRespUpdate = '{"id": "event_id_for_update", "status": "confirmed", "created": "2014-10-25T19:45:17.000Z", "updated": "2014-10-25T19:49:55.515Z", "summary": "New Sfdc Event Update", "creator": {"email": "187584108634-ss49re0vval2t9elqie6ac8gsjn9f6l2@developer.gserviceaccount.com"}, "start": {"dateTime": "2014-10-20T09:30:00-07:00"}, "end": {"dateTime": "2014-10-20T10:30:00-07:00"}, "sequence": 5, "extendedProperties": {"private": {"salesforceEventId": "00U11000002g7qhEAA"} } }';
	private static String TestRespGoogleToSfdcFirstPage = '{"nextPageToken": "page_token", "items": [{"id": "google_event_id_insert_long_summary", "status": "confirmed", "summary": "' + SummaryFullLength + '", "start": {"dateTime": "2015-01-24T16:00:00-08:00"}, "end": {"dateTime": "2015-01-24T17:00:00-08:00"}, "recurringEventId": "google_recurring_event_id", "sequence": 2 }, {"id": "google_event_id_insert_normal", "status": "confirmed", "summary": "Google Event1", "start": {"dateTime": "2015-01-24T16:00:00-08:00"}, "end": {"dateTime": "2015-01-24T17:00:00-08:00"}, "sequence": 1 }, {"id": "google_event_id_insert_allday", "status": "confirmed", "summary": "Google Event2", "start": {"date": "2015-01-24"}, "end": {"date": "2015-01-24"}, "sequence": 2 }, {"id": "google_event_id_insert_recurring", "status": "confirmed", "summary": "Google Event1", "start": {"dateTime": "2015-01-24T16:00:00-08:00"}, "end": {"dateTime": "2015-01-24T17:00:00-08:00"}, "recurringEventId": "google_recurring_event_id", "sequence": 1 }, {"id": "google_event_id_insert_longerthan_13_days", "status": "confirmed", "summary": "Google Event1", "start": {"dateTime": "2015-01-24T16:00:00-08:00"}, "end": {"dateTime": "2015-04-24T17:00:00-08:00"}, "sequence": 1 }, {"id": "google_event_id_update", "status": "confirmed", "summary": "Google Event3 Updated", "start": {"dateTime": "2015-01-24T16:00:00-08:00"}, "end": {"dateTime": "2015-01-24T17:00:00-08:00"}, "sequence": 3 } ] }';
	private static String TestRespGoogleToSfdcSecondPage = '{"nextSyncToken": "sync_token2", "items": [{"id": "google_event_id_delete", "status": "cancelled"}, {"id": "google_event_id_delete_nonexisting", "status": "cancelled"} ] }';
    private static String TestRespGoogleEvent = '{"id": "google_event_id", "status": "confirmed", "summary": "Google Event", "start": {"dateTime": "2015-01-24T16:00:00-08:00"}, "end": {"dateTime": "2015-01-24T17:00:00-08:00"}, "sequence": 0 }';
	private static String TestRespEventWatch = '{"id": "google_channel_id", "resourceId": "google_resource_id", "resourceUri": "https://www.googleapis.com/calendar/v3/calendars/test@sunrunhome.com/events?alt=json", "expiration": "1414852021000"}';
	private static String TestRespPrimaryCalendar = '{"id": "test1@sunrunhome.com", "summary": "test@sunrunhome.com", "timeZone": "America/Los_Angeles"}';
    
	private static String PrimaryCalendarUrl = 'https://www.googleapis.com/calendar/v3/calendars/primary';    
    private static String AclUrl = 'https://www.googleapis.com/calendar/v3/calendars/test1@sunrunhome.com/acl';
    private static String EventsUrl = 'https://www.googleapis.com/calendar/v3/calendars/test1@sunrunhome.com/events';
    private static String UpdateUrl = 'https://www.googleapis.com/calendar/v3/calendars/test1@sunrunhome.com/events/event_id_for_update';
    private static String DeleteUrl = 'https://www.googleapis.com/calendar/v3/calendars/test1@sunrunhome.com/events/event_id_for_delete';
    private static String EventUrl = 'https://www.googleapis.com/calendar/v3/calendars/test1@sunrunhome.com/events/google_event_id';
    private static String RegisterUrl = 'https://www.googleapis.com/calendar/v3/calendars/test1@sunrunhome.com/events/watch';
    private static String UnregisterUrl = 'https://www.googleapis.com/calendar/v3/channels/stop';
	private static String AccessTokenUrl = 'https://accounts.google.com/o/oauth2/token';
    
    testmethod public static void testGetSyncErrors() {
        App_log__c appLog = new App_Log__c(Module__c = 'GoogleCalendarSync', OwnerId=UserInfo.getUserId(), Type__c='Error');
        insert appLog;
        
        appLog = new App_Log__c(Module__c = 'Some Other Sync', OwnerId=UserInfo.getUserId(), Type__c='Error');
        insert appLog;
        
       	System.assertEquals(1, impl.getSyncErrors(UserInfo.getUserId()).size());
    }
    
    testmethod public static void testDisableCalendarSync() {
        Test.setCurrentPage(Page.GoogleCalendarSyncSetup);

        insertSettings();

        User user = utils.getAnyStandardUser();
        
        Test.setMock(HttpCalloutMock.class, new FlexibleCalloutMock(204, '')); //Empty response with 204
        
        user.Google_Calendar_Sync_Enabled__c = true;
        user.Google_Calendar_Sync_Required__c = true;
        user.Google_Calendar_Id__c = '123CalendarId';
        user.Google_Calendar_Push_Resource_Id__c = '123ResourceId';
        user.Google_Calendar_Push_Channel_Id__c = '123ChannelId';
        user.Google_Calendar_Sync_Token__c = 'token';
         
		DateTime lastSyncTime =  DateTime.now();
        user.Google_Calendar_Goog_Delta_Sync_Time__c = lastSyncTime;
        user.Google_Calendar_Goog_Full_Sync_Time__c = lastSyncTime;
        user.Google_Calendar_Goog_Sync_Try_Time__c = lastSyncTime;

        user.Google_Calendar_Sfdc_Delta_Sync_Time__c = lastSyncTime;
        user.Google_Calendar_Sfdc_Full_Sync_Time__c = lastSyncTime;

        user.Google_Calendar_Setup_DateTime__c = lastSyncTime;

        update user;
        
        Test.startTest();
        Sf.googleCalendarService.disableCalendarSync(user.id);
        Test.stopTest();
        
        user = utils.queryUser(user.id);
        
        System.assertEquals(false, user.Google_Calendar_Sync_Enabled__c); //Sync is disabled
		System.assertEquals(true, user.Google_Calendar_Sync_Required__c); //sync required is not touched
        System.assertEquals('123CalendarId', user.Google_Calendar_Id__c); //calendar id is not touched
        System.assertEquals(null, user.Google_Calendar_Push_Resource_Id__c); //resource id is nullified
        System.assertEquals(null, user.Google_Calendar_Push_Channel_Id__c); //channel id is nullified
		System.assertEquals('token', user.Google_Calendar_Sync_Token__c); //sync token is kept as is.
         
        //All sync times are not touched.
        System.assertEquals(lastSyncTime, user.Google_Calendar_Goog_Delta_Sync_Time__c);
        System.assertEquals(lastSyncTime, user.Google_Calendar_Goog_Full_Sync_Time__c);
        System.assertEquals(lastSyncTime, user.Google_Calendar_Goog_Sync_Try_Time__c);
        System.assertEquals(lastSyncTime, user.Google_Calendar_Sfdc_Delta_Sync_Time__c);
        System.assertEquals(lastSyncTime, user.Google_Calendar_Sfdc_Full_Sync_Time__c);
        System.assertEquals(lastSyncTime, user.Google_Calendar_Setup_DateTime__c);
    }

    testmethod public static void testEnableCalendarSync() {
        insertSettings();

        User user = utils.getAnyStandardUser();
        
        FlexibleCalloutMock mock = new FlexibleCalloutMock();
        mock.ifUrlEqualsReturn(accessTokenUrl, TestRespAccessToken);
        mock.ifUrlEqualsReturn(RegisterUrl, TestRespEventWatch);
        mock.ifUrlEqualsReturn(EventsUrl, TestRespGoogleEvent);
        mock.ifUrlEqualsReturn(EventUrl, '');
        
        user.Google_Calendar_Sync_Enabled__c = false;
        user.Google_Calendar_Sync_Required__c = false;
        user.Google_Calendar_Id__c = '123CalendarIdOld';
        user.Google_Calendar_Push_Resource_Id__c = '123ResourceIdOld';
        user.Google_Calendar_Push_Channel_Id__c = '123ChannelIdOld';
        user.Google_Calendar_Setup_DateTime__c = DateTime.now();
        update user;
		
		BaseClass.testCurrentDateTime = DateTime.now().addDays(1);
        
        Test.startTest();
        Sf.googleCalendarService.enableCalendarSync(user.id, 'test1@sunrunhome.com');
        Test.stopTest();
        
        user = utils.queryUser(user.id);
        
        System.assertEquals(true, user.Google_Calendar_Sync_Enabled__c);
        System.assertEquals(true, user.Google_Calendar_Sync_Required__c);
        System.assertEquals('test1@sunrunhome.com', user.Google_Calendar_Id__c);
        System.assertEquals('google_resource_id', user.Google_Calendar_Push_Resource_Id__c);
        System.assertEquals('google_channel_id', user.Google_Calendar_Push_Channel_Id__c);
        System.assertEquals(BaseClass.testCurrentDateTime, user.Google_Calendar_Setup_DateTime__c);
    }
    
    testmethod public static void testControllerEnableSync() {
        Test.setCurrentPage(Page.GoogleCalendarSyncSetup);
        
        User user = utils.getAnyStandardUser();
        user.email = 'test1@sunrun.com';
        update user;
            
        insertSettings();
        
        FlexibleCalloutMock mock = new FlexibleCalloutMock();
        mock.ifUrlEqualsReturn(accessTokenUrl, TestRespAccessToken);
        mock.ifUrlEqualsReturn(RegisterUrl, TestRespEventWatch);
        mock.ifUrlEqualsReturn(EventsUrl, TestRespGoogleEvent);
        mock.ifUrlEqualsReturn(EventUrl, '');
        
        Test.startTest();
        GoogleCalendarSyncSetupController controller = new GoogleCalendarSyncSetupController();
		System.assert(controller.user == null);
        
		ApexPages.currentPage().getParameters().put('id', user.id);
		controller = new GoogleCalendarSyncSetupController();
        
        //Make sure user is loaded when specified an id.
        System.assertEquals(user.id, controller.user.id);
        controller.changeUser();
        System.assert(controller.user == null);
        
        controller.continueWithSetup(); //This should generate an error.
        
		controller.account = new Account(OwnerId=user.id, BillingCity='Dublin');
        controller.continueWithSetup();
        controller.calendarId = 'test1@sunrunhome.com';
        System.assertEquals(user.id, controller.user.id);
        
        controller.enableSync();
        
		Test.stopTest();
        
        user = Sf.googleCalendarService.queryUsers(new Id[]{user.id}).get(0);

        System.assertEquals(true, user.Google_Calendar_Sync_Enabled__c);
        System.assertEquals('test1@sunrunhome.com', user.Google_Calendar_Id__c);
        System.assertEquals('google_resource_id', user.Google_Calendar_Push_Resource_Id__c);
        System.assertEquals('google_channel_id', user.Google_Calendar_Push_Channel_Id__c);
    }

    testmethod public static void testControllerDisableSync() {
        Test.setCurrentPage(Page.GoogleCalendarSyncSetup);
        
        User user = utils.getAnyStandardUser();
        user.Google_Calendar_Sync_Enabled__c =  true;
        user.Google_Calendar_Id__c = 'test1@sunrunhome.com';
        update user;
            
        insertSettings();
        
		new FlexibleCalloutMock(200, '');
        
        Test.startTest();
		ApexPages.currentPage().getParameters().put('id', user.id);
        GoogleCalendarSyncSetupController controller = new GoogleCalendarSyncSetupController();
        controller.disableSync();
		Test.stopTest();
        
        user = utils.queryUser(user.id);

        System.assertEquals(false, user.Google_Calendar_Sync_Enabled__c);
        System.assertEquals('test1@sunrunhome.com', user.Google_Calendar_Id__c);
        System.assertEquals(null, user.Google_Calendar_Push_Resource_Id__c);
        System.assertEquals(null, user.Google_Calendar_Push_Channel_Id__c);
    }

    testmethod public static void testControllerOauth() {
        Test.setCurrentPage(Page.GoogleCalendarSyncSetup);
        
        User user = utils.getAnyStandardUser();
            
        insertSettings();
        
        FlexibleCalloutMock mock = new FlexibleCalloutMock();
        mock.ifUrlEqualsReturn(accessTokenUrl, TestRespAccessToken);
        mock.ifUrlEqualsReturn(RegisterUrl, TestRespEventWatch);
        mock.ifUrlEqualsReturn(EventsUrl, TestRespGoogleEvent);
        mock.ifUrlEqualsReturn(EventUrl, '');
        mock.ifUrlEqualsReturn(PrimaryCalendarUrl, TestRespPrimaryCalendar);

        Test.startTest();
        GoogleCalendarSyncUserSetupController controller = new GoogleCalendarSyncUserSetupController(null);
		System.assert(String.valueOf(controller.requestGoogleForOAuthAccess()).indexOf('https://accounts.google.com') >= 0);
	    
        controller = new GoogleCalendarSyncUserSetupController(null);
        ApexPages.currentPage().getParameters().put('error', 'error with google oauth');
        controller.initOAuthResponse();
        System.assert(utils.getHasErrorMessagesContains('Request to access your Google Calendar failed'));
		
        controller = new GoogleCalendarSyncUserSetupController();
        controller.calendarId = null;
        
        ApexPages.currentPage().getParameters().remove('error');
        ApexPages.currentPage().getParameters().put('code', 'google oauth code');
		controller.initOAuthResponse();
        
        Test.stopTest();
        
        System.assertEquals('test1@sunrunhome.com', controller.calendarId);
        user = utils.queryUser(user.id);
    }
   	
    testmethod public static void testControllerGrantAccessToCalendar() {
        insertSettings();
        
        FlexibleCalloutMock mock = new FlexibleCalloutMock();
        mock.ifUrlEqualsReturn(accessTokenUrl, TestRespAccessToken);
		mock.ifUrlEqualsReturn(AclUrl, '');
        GoogleCalendarSyncUserSetupController controller = new GoogleCalendarSyncUserSetupController(null);

        Test.startTest();
        impl.grantAccessToCalendar('accessToken', 'test1@sunrunhome.com');
        Test.stopTest();
    }

    testmethod public static void testControllerEnableSyncExceptions() {
        insertSettings();
        
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(404);
    	BaseClass.testParams.put('ExceptionToThrow', new UnsuccessfulHttpResponseException(new HttpRequest(), resp));
        
        GoogleCalendarSyncUserSetupController controller = new GoogleCalendarSyncUserSetupController(null);
        controller.enableCalendarSync(true);
        System.assert(utils.getHasErrorMessagesContains('404 Resource Not Found'));
        
        resp.setStatusCode(403);
        controller.enableCalendarSync(true);
        System.assert(utils.getHasErrorMessagesContains('404 Resource Not Found'));
		
        resp.setStatusCode(500);
        controller.enableCalendarSync(true);
        
    	BaseClass.testParams.put('ExceptionToThrow', new SystemException());
        controller.enableCalendarSync(true);
    }   

    testmethod public static void testEnableSyncBatch() {
        User user = utils.getAnyStandardUser();
        
        insertSettings();
        
        FlexibleCalloutMock mock = new FlexibleCalloutMock();
        mock.ifUrlEqualsReturn(accessTokenUrl, TestRespAccessToken);
        mock.ifUrlEqualsReturn(RegisterUrl, TestRespEventWatch);
        mock.ifUrlEqualsReturn(EventsUrl, TestRespGoogleEvent);
        mock.ifUrlEqualsReturn(EventUrl, 204, '');
        
        user.Google_Calendar_Sync_Enabled__c = false;
        user.Google_Calendar_Sync_Required__c = false;
        user.Google_Calendar_Id__c = 'test1@sunrunhome.com';
        user.Google_Calendar_Push_Resource_Id__c = '123ResourceIdOld';
        user.Google_Calendar_Push_Channel_Id__c = '123ChannelIdOld';
        user.Google_Calendar_Setup_DateTime__c = DateTime.now();
        update user;
		
		BaseClass.testCurrentDateTime = DateTime.now().addDays(1);
        
        Test.startTest();
        new GoogleCalendarEnableDisableSyncBatch(new Id[]{user.id}).execute(null);
        Test.stopTest();
        
        user = utils.queryUser(user.id);
        
        System.assertEquals(true, user.Google_Calendar_Sync_Enabled__c);
        System.assertEquals(true, user.Google_Calendar_Sync_Required__c);
        System.assertEquals('test1@sunrunhome.com', user.Google_Calendar_Id__c);
        System.assertEquals('google_resource_id', user.Google_Calendar_Push_Resource_Id__c);
        System.assertEquals('google_channel_id', user.Google_Calendar_Push_Channel_Id__c);
        System.assertEquals(BaseClass.testCurrentDateTime, user.Google_Calendar_Setup_DateTime__c);
    }
    
    testmethod public static void testDisableSyncBatch() {
        
        //The version with no userids, should fetch all users who needs to have sync enabled or have synced already enabled
        System.assertEquals(Database.getQueryLocator([
                select id, Google_Calendar_Id__c
                from User 
                where Google_Calendar_Sync_Required__c = true or Google_Calendar_Sync_Enabled__c = true]).getQuery(), 
                            new GoogleCalendarEnableDisableSyncBatch().start(null).getQuery());
        
        //Test enable batch.
        insertSettings();
		new FlexibleCalloutMock(204, '');

        User user = utils.getAnyStandardUser();
        user.Google_Calendar_Sync_Enabled__c = true;
        user.Google_Calendar_Id__c = '123CalendarId';
        user.Google_Calendar_Push_Resource_Id__c = '123ResourceId';
        user.Google_Calendar_Push_Channel_Id__c = '123ChannelId';
        
        update user;
        
        Test.startTest();
        new GoogleCalendarEnableDisableSyncBatch(new Id[]{user.id}, true).execute(null);
        Test.stopTest();
        
        user = utils.queryUser(user.id);
        
        System.assertEquals(false, user.Google_Calendar_Sync_Enabled__c); //Sync is disabled
        System.assertEquals('123CalendarId', user.Google_Calendar_Id__c); //calendar id is not touched
        System.assertEquals(null, user.Google_Calendar_Push_Resource_Id__c); //resource id is nullified
        System.assertEquals(null, user.Google_Calendar_Push_Channel_Id__c); //channel id is nullified
    } 

   	testmethod public static void testVerificationBatch() {
        List<User> users = utils.getAnyStandardUsers(2);
        User user1 = users.get(0);
        User user2 = users.get(1);
        
        Event event1 = new Event(StartDateTime=DateTime.now(), 
				EndDateTime=DateTime.now(), 
                Subject='Google Event1', 
                Google_Calendar_Event_Id__c='google_event_id1',
                OwnerId=user1.id);
        insert event1;

        Event event2 = new Event(StartDateTime=DateTime.now(), 
				EndDateTime=DateTime.now(), 
                Subject='Google Event2', 
                Google_Calendar_Event_Id__c='google_event_id2',
                OwnerId=user2.id);
        insert event2;
        
        Sync_Record__c syncRec = new Sync_Record__c(Module__c = 'GoogleCalendarSync', OwnerId=user1.id, Status__c='Sync Error');
        insert syncRec;
        
        syncRec = new Sync_Record__c(Module__c = 'GoogleCalendarSync', OwnerId=user2.id, Status__c='Sync Error');
        insert syncRec;
        
        insertSettings();
        
        FlexibleCalloutMock mock = new FlexibleCalloutMock();
        mock.ifUrlEqualsReturn(accessTokenUrl, TestRespAccessToken);
        mock.ifUrlEqualsReturn(EventsUrl, 403, TestRespGoogleEvent);
        mock.ifUrlEqualsReturn(EventUrl, 204, '');
        
        user1.Google_Calendar_Sync_Enabled__c = true;
        user1.Google_Calendar_Id__c = 'test1@sunrunhome.com';
        user1.Google_Calendar_Push_Resource_Id__c = '123ResourceIdOld';
        user1.Google_Calendar_Push_Channel_Id__c = '123ChannelIdOld';
        update user1;
        
        user2.Google_Calendar_Sync_Enabled__c = false;
        user2.Google_Calendar_Sync_Required__c = true;
		update user2;
        
		List<User> inactiveUsers = [select id from User where IsActive=false];
        User user3;
        if (!inactiveUsers.isEmpty()) {
            user3 = inactiveUsers.get(0);
            user3.Google_Calendar_Sync_Enabled__c = true;
            user3.Google_Calendar_Sync_Required__c = true;
	        update user3;
        }
        
		BaseClass.testCurrentDateTime = DateTime.now().addDays(1);

        Test.startTest();
        Database.executebatch(new GoogleCalendarSyncSetupVerificationBatch(new Id[]{user1.id, user2.id, user3.id}), 25);
        Test.stopTest();
        
        //User3 should have google calendar disabled.
        if (user3 != null) {
            user3 = utils.queryUser(user3.id);
            System.assertEquals(false, user3.Google_Calendar_Sync_Enabled__c);
            System.assertEquals(false, user3.Google_Calendar_Sync_Required__c);
        }
        
        GoogleCalendarSyncSetupVerificationBatch.SyncFailure failure = new GoogleCalendarSyncSetupVerificationBatch.SyncFailure();
        failure.failures = 1;
        failure.compareTo(failure);
    }

   	testmethod public static void testVerificationBatchInactiveUsers() {
        List<User> users = utils.getAnyStandardUsers(1);
        User user1 = users.get(0);
        
        user1.IsActive = false;
        user1.Google_Calendar_Sync_Required__c = true;
        update user1;

        Test.startTest();
        Database.executebatch(new GoogleCalendarSyncSetupVerificationBatch(new Id[]{user1.id}), 25);
        Test.stopTest();
    }

   	testmethod public static void testVerificationBatchQueryAllUsers() {
        Test.startTest();
        Database.executebatch(new GoogleCalendarSyncSetupVerificationBatch(), 5000);
        Test.stopTest();
    }


    //This tests when event is inserted, updated or deleted if we are appropriately
	//inserting the sync records.    
    testmethod public static void testHandleEventTrigger() {
        User user = utils.getAnyStandardUser();
        user.Google_Calendar_Sync_Enabled__c = true;
        user.Google_Calendar_Id__c = 'test1@sunrunhome.com';
        update user;
        
        Event event = new Event(StartDateTime=DateTime.now(), 
				EndDateTime=DateTime.now(), 
                Google_Calendar_Event_Id__c='4p5eje11pfjsq7n9fcoudg2pvs_20150125T020000Z',
                Subject='Google Event', 
                OwnerId=user.id);

        insert event;

        //There should have been one sync record.
        System.assertEquals('To Be Synced', querySyncRecords(event.id).get(0).Status__c);

        //Now update the event without changing anything.
        deleteSyncRecords(event.id);
       	GoogleCalendarServiceImpl.eventsProcessingInProgress.clear();
        update event;

        //Because we didn't update anything, we should not have tracked this as 
        //update.
        System.assertEquals(0, querySyncRecords(event.id).size());

        //Now change the subject, update event and make sure sync record is created.
        deleteSyncRecords(event.id);
		event.Subject = 'Test2';
       	GoogleCalendarServiceImpl.eventsProcessingInProgress.clear();
		update event;        
        System.assertEquals('To Be Synced', querySyncRecords(event.id).get(0).Status__c);

        //Now delete and make sure sync record is created with external_id__c as google event id.
        deleteSyncRecords(event.id);
       	GoogleCalendarServiceImpl.eventsProcessingInProgress.clear();
		delete event;
		Sync_Record__c syncRecord = querySyncRecords(event.id).get(0);
        System.assertEquals('To Be Synced', syncRecord.Status__c);
        System.assertEquals('4p5eje11pfjsq7n9fcoudg2pvs_20150125T020000Z', syncRecord.external_id__c);
    }
    
	//This tests that when event is updated multiple times, in same transaction,
	//we create sync records only once.
    testmethod public static void testHandleTriggerRecurrencePrevention() {
        User user = utils.getAnyStandardUser();
        user.Google_Calendar_Sync_Enabled__c = true;
        user.Google_Calendar_Id__c = 'test1@sunrunhome.com';
        update user;
        
        Event event = new Event(StartDateTime=DateTime.now(),
				EndDateTime=DateTime.now(),
                Google_Calendar_Event_Id__c='4p5eje11pfjsq7n9fcoudg2pvs_20150125T020000Z',
                Subject='Google Event',
                OwnerId=user.id);

        insert event;

        //There should have been one sync record.
        System.assertEquals(1, querySyncRecords(event.id).size());

        event.Subject = 'Bar2';
        update event;
        System.assertEquals(1, querySyncRecords(event.id).size());
    }

	//This tests when we create recurring event in salesforce, we will not sync to salesforce
    testmethod public static void testHandleEventTriggerAndSfdcSyncForRecurringEvents() {
        User user = utils.getAnyStandardUser();
        user.Google_Calendar_Sync_Enabled__c = true;
        user.Google_Calendar_Id__c = 'test1@sunrunhome.com';
        update user;
        
		Event event = new Event(
		    ActivityDate = Date.today(),
		    RecurrenceEndDateOnly = Date.today(),
		    RecurrenceStartDateTime = DateTime.newInstance(2015, 10, 12, 0, 0, 0),
		    RecurrenceType = 'RecursEveryWeekday',
		    RecurrenceDayofWeekMask = 62,
		    IsRecurrence = TRUE,
		    Description = 'Class Event.', 
            DurationInMinutes = 60,
		    Subject = 'Class trigger Event', OwnerId=user.id);

        insert event;

        //There should have been one sync record.
        System.assertEquals(0, querySyncRecords(event.id).size());
        
       	//Now insert the sync record with this id and try to sync.
       	Sync_Record__c syncRecord = new Sync_Record__c(Module__c='GoogleCalendarSync', Action__c='SfdcToGoogleSync',
			Record_Id__c=event.id, Status__c='To Be Synced');
        insert syncRecord;
        
        new GoogleCalendarSfdcToGoogleSyncJob().execute();
        
        syncRecord = (Sync_Record__c) utils.queryAllFields(syncRecord.id);
        System.assertEquals('Recurring Events Not Supported', syncRecord.Sub_Status__c);
        System.assertEquals('Sync Not Applicable', syncRecord.Status__c);
    }
    
    //This tests to sync from Sfdc to Google.
    testmethod public static void testSfdcToGoogleSync() {
        insertSettings();
        
		User user = utils.queryUser(UserInfo.getUserId());
        user.Google_Calendar_Sync_Enabled__c = true;
        user.Google_Calendar_Id__c = 'test1@sunrunhome.com';
        update user;
        
        //We will have one event which we will insert, update and delete one.
        Event event1 = new Event(StartDateTime=DateTime.now(), 
				EndDateTime=DateTime.now(), 
                Subject='Test1',
                Google_Calendar_Event_Id__c=null,
                OwnerId=user.id);
        insert event1;
        
        //For Update
        Event event2 = new Event(StartDateTime=DateTime.now(), 
				EndDateTime=DateTime.now(), 
                Subject='Test2', 
                Google_Calendar_Event_Id__c='event_id_for_update',
                OwnerId=user.id);
        insert event2;
        
        //For delete
        Event event3 = new Event(StartDateTime=DateTime.now(), 
				EndDateTime=DateTime.now(), 
                Subject='Test2', 
                Google_Calendar_Event_Id__c='event_id_for_delete',
                OwnerId=user.id);
        insert event3;
        delete event3;

        Map<String, SObject> eventsMap1 = utils.getStringMap([select Id, Google_Calendar_Event_Id__c, Google_Calendar_Event_Sequence_Num__c from Event where ownerid = :user.id], 'Google_Calendar_Event_Id__c');
        System.debug('Events map just before querying ' + eventsMap1);
        
        //Each of these event inserts should have created one sycn records each.
        System.assertEquals(1, querySyncRecords(event1.id).size());
        System.assertEquals(1, querySyncRecords(event2.id).size());
        System.assertEquals(1, querySyncRecords(event3.id).size());
        
        FlexibleCalloutMock mock = new FlexibleCalloutMock(200, '');
        mock.ifUrlEqualsReturn('https://accounts.google.com/o/oauth2/token', TestRespAccessToken);
        mock.ifUrlEqualsReturn('https://www.googleapis.com/calendar/v3/calendars/test1@sunrunhome.com/events', TestRespInsert);
        mock.ifUrlEqualsReturn('https://www.googleapis.com/calendar/v3/calendars/test1@sunrunhome.com/events/event_id_for_update', TestRespUpdate);
        mock.ifUrlEqualsReturn('https://www.googleapis.com/calendar/v3/calendars/test1@sunrunhome.com/events/event_id_for_delete', '');
        
        Test.startTest();
        SyncJobInfo jobInfo = new GoogleCalendarSfdcToGoogleSyncJob().execute();
        Test.stopTest();
        
        //Confirm we had three sync records
        System.assertEquals(3, jobInfo.syncRecords.size());
		System.assertEquals('Sync Success', jobInfo.syncRecords.get(0).Status__c);
		System.assertEquals('Sync Success', jobInfo.syncRecords.get(1).Status__c);
		System.assertEquals('Sync Success', jobInfo.syncRecords.get(2).Status__c);
        
        //We will assert now that Event1 is inserted and its google event id is populated into event1.
        Map<String, SObject> eventsMap = utils.getStringMap([select Id, Google_Calendar_Event_Id__c, Google_Calendar_Event_Sequence_Num__c from Event where ownerid = :user.id], 'Google_Calendar_Event_Id__c');
        System.debug('Events map after querying ' + eventsMap);
        
        System.assertNotEquals(null, eventsMap.get('event_id_for_insert'));
        System.assertEquals(5, ((Event) eventsMap.get('event_id_for_update')).Google_Calendar_Event_Sequence_Num__c);
    }
    
    testmethod public static void testSfdcToGoogleSyncErrorToSuccess() {
		//When we sync from sfdc to google, and sometimes it fails when
		//we try to update back the events with google id. If that happens, 
		//we will mark the sync record as error. Next time, we run that sync record
		//it will findout that event is missing google id but it was retrieved earlier
		//and it will copy the alues and puts it back into event and save it.
        insertSettings();
        
		User user = utils.queryUser(UserInfo.getUserId());
        user.Google_Calendar_Sync_Enabled__c = true;
        user.Google_Calendar_Id__c = 'test1@sunrunhome.com';
        update user;
        
        //We will have one event which we will insert, update and delete one.
        Event event1 = new Event(StartDateTime=DateTime.now(), 
				EndDateTime=DateTime.now(), 
                Subject='Test1',
                Google_Calendar_Event_Id__c=null,
                OwnerId=user.id);
        insert event1;
		
		//Mark the sync record as error and set the response payload.
		Sync_Record__c syncRecord = querySyncRecords(event1.id).get(0);
		syncRecord.Status__c = 'Sync Error';
		syncRecord.Response_Payload__c = '{"sequence" : 5, "gcalEventId" : "event_id_for_insert"}';
        syncRecord.External_Id__c = 'event_id_for_insert';
		update syncRecord;
        
        //Note that we didn't have to put execute call inside Test.start or stop as 
        //we will not be making any out bound call but rather just copy the
        //event data from Sync record into event object.
        SyncJobInfo jobInfo = new GoogleCalendarSfdcToGoogleSyncJob().execute();

        System.assertEquals(1, jobInfo.syncRecords.size());
		System.assertEquals('Sync Success', jobInfo.syncRecords.get(0).Status__c);
        
        //We will assert now that Event1 is inserted and its google event id is populated into event1.
        Map<String, SObject> eventsMap = utils.getStringMap([select Id, Google_Calendar_Event_Id__c, Google_Calendar_Event_Sequence_Num__c from Event where ownerid = :user.id], 'Google_Calendar_Event_Id__c');
        System.debug('Events map after querying ' + eventsMap);
        
        System.assertNotEquals(null, eventsMap.get('event_id_for_insert'));
        System.assertEquals(5, ((Event) eventsMap.get('event_id_for_insert')).Google_Calendar_Event_Sequence_Num__c);
    }

    testmethod public static void testSfdcToGoogleInvalidSequenceErrorRecovery() {
		insertSettings();        
        
        //Tests that when we receive a invalid sequence error from Google, we will recover
        //the error. Error we will get from google is
        //"Invalid sequence value. The specified sequence number is below the current sequence number of the resource."
       	FlexibleCalloutMock mock = new FlexibleCalloutMock();
        mock.ifUrlEqualsReturn(accessTokenUrl, TestRespAccessToken);
        mock.ifUrlEqualsCountReturn(updateUrl, 1, 401, 'Invalid sequence value');
        mock.ifUrlEqualsCountReturn(updateUrl, 2, 200, TestRespUpdate);
        
		User user = utils.queryUser(UserInfo.getUserId());
        user.Google_Calendar_Sync_Enabled__c = true;
        user.Google_Calendar_Id__c = 'test1@sunrunhome.com';
        update user;

        //For Update
        Event event2 = new Event(StartDateTime=DateTime.now(), 
				EndDateTime=DateTime.now(), 
                Subject='Test2', 
                Google_Calendar_Event_Id__c='event_id_for_update',
                OwnerId=user.id);
        insert event2;
        
        Test.startTest();
        SyncJobInfo jobInfo = new GoogleCalendarSfdcToGoogleSyncJob().execute();
        Test.stopTest();
        
        System.assertEquals(1, jobInfo.syncRecords.size());
		System.assertEquals('Sync Success', jobInfo.syncRecords.get(0).Status__c);
    }
    
    testmethod public static void testSfdcToGoogleFullSync() {
        //This tests if we do full sync from SFDC To google, if all
        //appropriate events are marked to be synced.
        
        //Will have a one event before sync window, one after sync window and two in window.
      	//and with sfdc full sync time as null so it should take both events.
      	Integer fullSyncFromDays = impl.getFullSyncFromDays();
      	Integer fullSyncToDays = impl.getFullSyncToDays();
		
		//We need a user to attached the events to.
		User user = utils.getAnyStandardUser();
        user.Google_Calendar_Sync_Enabled__c = false;
        user.Google_Calendar_Id__c = 'test1@sunrunhome.com';
        user.Google_Calendar_Sfdc_Full_Sync_Time__c = null;
        update user;

        Event event1 = new Event(StartDateTime=DateTime.now(),
				EndDateTime=DateTime.now(), 
                Subject='Test1',
                Google_Calendar_Event_Id__c=null,
                OwnerId=user.id);
        insert event1;

        Event event2 = new Event(StartDateTime=DateTime.now(),
				EndDateTime=DateTime.now(), 
                Subject='Test1',
                Google_Calendar_Event_Id__c=null,
                OwnerId=user.id);
        insert event2;
        
        //If we try to full this user, it should not as use's calendar is disabled.
        new GoogleCalendarSfdcToGoogleFullSyncJob(new String[]{user.id}).execute(null);

        System.assertEquals(0, querySyncRecords().size());
        
        user.Google_Calendar_Sync_Enabled__c = true;
        update user;
        
        utils.sleep(1000);
		
		//clearup any old ones        
        delete querySyncRecords();

        //When we do full sync, it should list these two events.
        new GoogleCalendarSfdcToGoogleFullSyncJob().execute(null);
        user = utils.queryUser(user.id);
        System.assertNotEquals(null, user.Google_Calendar_Sfdc_Full_Sync_Time__c);
        System.assertEquals(2, querySyncRecords().size());
        
        delete querySyncRecords();
        
        //If we do full sync now, it should not list any events as their updated date/time is before
        //last full sync time.
        new GoogleCalendarSfdcToGoogleFullSyncJob().execute(null);
        System.assertEquals(0, querySyncRecords().size());
        
    }
    
    testmethod public static void testGooglePushNotification() {
		//Will test following scenarios.
		//
		//1. Push with a channel id which we don't find any user for. Code should send out
		//		Unregister Channel
		//
		//2. Push for user with google sync enabled
		//
		//3. Push for user with google sync disabled
        
        insertSettings();

        //User to hold the events. We will sync few events for first user, no events for second user
        List<User> users = utils.getAnyStandardUsers(2);
        User user1 = users.get(0);
        User user2 = users.get(1);
        
        //User one will be used to test the full sync and next page.
        user1.Google_Calendar_Sync_Enabled__c = true;
        user1.Google_Calendar_Id__c = 'test1@sunrunhome.com';
        user1.Google_Calendar_Push_Channel_Id__c = 'Channel1';
        update user1;

        user2.Google_Calendar_Sync_Enabled__c = false;
        user2.Google_Calendar_Push_Channel_Id__c = 'Channel2';
        update user2;
        
		RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
    	RestContext.request = req;
    	RestContext.response = res;
		
        //statusCheck method returns some string indicate the api is available. This is to cover that code.
		System.assertNotEquals(null, GoogleCalendarSyncPushHandlerRestService.statusCheck());

        //'Sync' events are sent by google first time calendar is setup. So here we are just making sure we handle it.
        req.requestURI = 'https://majdev-sunrun.cs18.force.com/partner/services/apexrest/googlecalendarsync/pushHandler';
    	req.httpMethod = 'GET';
        req.addHeader('X-Goog-Resource-State', 'sync');
        GoogleCalendarSyncPushHandlerRestService.handlePushNotification();

        //Push request for user1
        req.addHeader('X-Goog-Resource-State', 'exists');
        req.addHeader('X-Goog-Resource-ID', 'Resource1');
        req.addHeader('X-Goog-Channel-ID', 'Channel1');
        GoogleCalendarSyncPushHandlerRestService.handlePushNotification();

        //Push request for user2
        req.addHeader('X-Goog-Resource-State', 'exists');
        req.addHeader('X-Goog-Resource-ID', 'Resource2');
        req.addHeader('X-Goog-Channel-ID', 'Channel2');
        GoogleCalendarSyncPushHandlerRestService.handlePushNotification();

        //Now with non existing channel push, we should send unregister message to google.
		FlexibleCalloutMock mock = new FlexibleCalloutMock();
        mock.ifUrlEqualsReturn(accessTokenUrl, TestRespAccessToken);
        mock.ifUrlEqualsReturn(unregisterUrl, 204, '');
        
        req.addHeader('X-Goog-Resource-State', 'exists');
        req.addHeader('X-Goog-Resource-ID', 'Resource3');
        req.addHeader('X-Goog-Channel-ID', 'Channel3');
        Test.startTest();
        GoogleCalendarSyncPushHandlerRestService.handlePushNotification();
        Test.stopTest();
        
        //Now ensure that there is only one sync record for user1.
        Sync_Record__c syncRecord = querySyncRecords(user1.id).get(0);
        System.assertNotEquals(null, syncRecord);
        System.assertEquals('test1@sunrunhome.com', syncRecord.Value1__c);
        System.assertEquals(user1.id, syncRecord.OwnerId);
    }
    
    testmethod public static void testGoogleToSfdcSync() {
        insertSettings();
        
        //We will test google to sfdc delta sync. We will test following scenarios.
        //
        //1. New Event
        //2. Update existing event
        //3. Delete existing event
		//We need a user to attached the events to.
		User user = utils.queryUser(UserInfo.getUserId());
        user.Google_Calendar_Sync_Enabled__c = true;
        user.Google_Calendar_Id__c = 'test1@sunrunhome.com';
        user.Google_Calendar_Sync_Token__c = null;
        update user;
        
        //We will have one event which we will insert, update and delete one.
        Event event1 = new Event(StartDateTime=DateTime.now(), 
				EndDateTime=DateTime.now(), 
                Subject='Test1',
                Google_Calendar_Event_Id__c='google_event_id_update',
                OwnerId=user.id);
        insert event1;
        
        Event event2 = new Event(StartDateTime=DateTime.now(), 
				EndDateTime=DateTime.now(), 
                Subject='Test1',
                Google_Calendar_Event_Id__c='google_event_id_delete',
                OwnerId=user.id);
        insert event2;

        FlexibleCalloutMock mock = new FlexibleCalloutMock();
        mock.ifUrlEqualsReturn(accessTokenUrl, TestRespAccessToken);
        mock.ifUrlContainsReturn('timeMin', TestRespGoogleToSfdcFirstPage);
        mock.ifUrlContainsReturn('pageToken', TestRespGoogleToSfdcSecondPage);
        
        impl.requestGoogleToSfdcSync(new String[]{user.id}, false);
        
        //Confirm there is only one sync record.
        System.assertEquals(1, querySyncRecords(user.id).size());
        
        Test.startTest();
        new GoogleCalendarGoogleToSfdcSyncJob().execute();
        Test.stopTest();
        
        //Check the events for the user.
        Map<String, Sobject> eventsMap = getEventsMap(user.id);
        
        //We should have 5 events (4 should have inserted, 1 updated and 1 deleted.)
        System.assertEquals(5, eventsMap.keySet().size());
        System.assertEquals(255, utils.getStringValue(eventsMap.get('google_event_id_insert_long_summary'), 'Subject').length());
        System.assertEquals('google_recurring_event_id', utils.getStringValue(eventsMap.get('google_event_id_insert_recurring'), 'Google_Calendar_Recurring_Event_Id__c'));
        System.assertEquals(true, (Boolean) (eventsMap.get('google_event_id_insert_allday').get('IsAllDayEvent')));
        System.assertNotEquals(null, eventsMap.get('google_event_id_insert_normal'));
        System.assertNotEquals(null, eventsMap.get('google_event_id_update'));
        System.assertEquals(null, eventsMap.get('google_event_id_delete'));
    }
    
    testmethod public static void testGoogleToSfdcFullSync() {
        //If we try to full sync, it should now create any sync records as any user don't have sync enabled.
        new GoogleCalendarGoogleToSfdcFullSyncJob().execute(null);
        
		User user = utils.queryUser(UserInfo.getUserId());
        user.Google_Calendar_Sync_Enabled__c = true;
        user.Google_Calendar_Id__c = 'test1@sunrunhome.com';
        update user;
        
        //Now that we enabled, we should create one sync record.
        new GoogleCalendarGoogleToSfdcFullSyncJob().execute(null);
        List<Sync_Record__c> syncRecords = [select id, Sub_Type__c from Sync_Record__c where ownerId = :user.id];
        System.assertEquals('Full Sync', syncRecords.get(0).Sub_Type__c);
    }
    
    testmethod public static void testGetUserPrimaryCalendarId() {
        insertSettings();
        
        FlexibleCalloutMock mock = new FlexibleCalloutMock();
        mock.ifUrlEqualsReturn(accessTokenUrl, TestRespAccessToken);
        mock.ifUrlEqualsReturn('https://www.googleapis.com/calendar/v3/calendars/primary', '{"id": "test@sunrunhome.com", "summary": "test@sunrunhome.com", "timeZone": "America/Los_Angeles"}');
        
        Test.startTest();
        System.assertEquals('test@sunrunhome.com', impl.getUserPrimaryCalendarId('accessToken'));
        Test.stopTest();
    }
    
    testmethod public static void testGetOAuthAccessToken() {
        insertSettings();
        
        FlexibleCalloutMock mock = new FlexibleCalloutMock();
        mock.ifUrlEqualsReturn(accessTokenUrl, TestRespAccessToken);

        Test.startTest();
        System.assertEquals('google_access_token', impl.getOAuthAccessToken('access_code'));
        Test.stopTest();
    }
    
    testmethod public static void testGetOAuthAccessRequestUrl() {
        insertSettings();
        System.assertNotEquals(null, impl.getOAuthAccessRequestUrl());
    }

    testmethod public static void testGrantAccessToCalendar() {
        insertSettings();
        
        FlexibleCalloutMock mock = new FlexibleCalloutMock();
        mock.ifUrlEqualsReturn(accessTokenUrl, TestRespAccessToken);
		mock.ifUrlEqualsReturn(AclUrl, '');
        
        Test.startTest();
        impl.grantAccessToCalendar('accessToken', 'test1@sunrunhome.com');
        Test.stopTest();
    }

    testmethod public static void testGetGoogleEvent() {
        insertSettings();
        
        List<User> users = utils.getAnyStandardUsers(2);
        User user1 = users.get(0);
        User user2 = users.get(1);
        
        insert new Event(StartDateTime=DateTime.now(), 
				EndDateTime=DateTime.now(), 
                Subject='Google Event', 
                Google_Calendar_Event_Id__c='google_event_id',
                OwnerId=user1.id);
        
        insert new Event(StartDateTime=DateTime.now(), 
				EndDateTime=DateTime.now(), 
                Subject='Test', 
                Google_Calendar_Event_Id__c='google_event_id2',
                OwnerId=user2.id);

        user1.Google_Calendar_Sync_Enabled__c = true;
        user1.Google_Calendar_Id__c = 'test1@sunrunhome.com';
        update user1;
    	
        user2.Google_Calendar_Sync_Enabled__c = true;
        user2.Google_Calendar_Id__c = null; //this should result in expection
        update user2;
        
        FlexibleCalloutMock mock = new FlexibleCalloutMock();
        mock.ifUrlEqualsReturn(accessTokenUrl, TestRespAccessToken);
		mock.ifUrlEqualsReturn(EventUrl, TestRespGoogleEvent);
        
        Test.startTest();
        
        System.assertEquals('google_event_id', new JsonReader(impl.getGoogleEvent('google_event_id')).getString('id'));

        try {
            impl.getGoogleEvent('Invalid Google Event Id');
            System.assert(false, 'Expected a BusinessException due to invalid event id');
        } catch (BusinessException e) {
            //expected
        }
        
        try {
            impl.getGoogleEvent('google_event_id2');
            System.assert(false, 'Expected a BusinessException due to invalid calendar id');
        } catch (BusinessException e) {
            //expected
        }
        Test.stopTest();
    }
    
    testmethod public static void testIsSyncCalendar() {
        User user = new User();
        user.IsActive = false;
        
        Sync_Record__c syncRecord = new Sync_Record__c();
		SyncJobInfo syncJob = new SyncJobInfo();
        syncJob.syncRecords = new Sync_Record__c[]{syncRecord};        
        syncJob.setBatch(syncRecord);
            
        System.assertEquals(false, impl.isSyncCalendar(user, syncJob));
		System.assertEquals('Sync Failed', syncRecord.Status__c);
		System.assertEquals('User Not Active', syncRecord.Sub_Status__c);

        user.IsActive = true;
        
        System.assertEquals(false, impl.isSyncCalendar(user, syncJob));
		System.assertEquals('Sync Failed', syncRecord.Status__c);
		System.assertEquals('Calendar Sync Not Enabled for User', syncRecord.Sub_Status__c);

        user.Google_Calendar_Sync_Enabled__c = true;
        
        System.assertEquals(false, impl.isSyncCalendar(user, syncJob));
		System.assertEquals('Sync Failed', syncRecord.Status__c);
		System.assertEquals('Invalid Calendar Id', syncRecord.Sub_Status__c);

        user.Google_Calendar_Id__c = 'id';
        
        System.assertEquals(true, impl.isSyncCalendar(user, syncJob));
    }
    
    testmethod public static void testGetSyncToken() {
        User user = new User();
        SyncJobInfo syncJob = new SyncJobInfo();
        Sync_Record__c syncRec1 = new Sync_Record__c();
        Sync_Record__c syncRec2 = new Sync_Record__c();
        syncJob.setBatch(new Sync_Record__c[]{syncRec1, syncRec2});
    
        System.assertEquals(null, impl.getSyncToken(user, syncJob));
    
        user.Google_Calendar_Sync_Token__c = 'SyncToken';
    
        System.assertEquals('SyncToken', impl.getSyncToken(user, syncJob));
    
        //Now set one of the sync record as full sync and should get null.
        syncRec2.Sub_Type__c = 'Full Sync';
        System.assertEquals(null, impl.getSyncToken(user, syncJob));
    
        //Now remove the sub_tuype and make sure we get the sync token
        syncRec2.Sub_Type__c = null;
        System.assertEquals('SyncToken', impl.getSyncToken(user, syncJob));
    
        //Now set the flag as full sync always 
        Sf.settingsService.setString('GoogleCalendarGoogleFullSyncAlways', 'true');
        System.assertEquals(null, impl.getSyncToken(user, syncJob));
    }
    
    public static Map<String, Sobject> getEventsMap(Id userId) {
        return utils.getStringMap([
                Select id, 
                OwnerId, 
                Owner.IsActive, 
                Subject, 
                Description,
                Startdatetime, 
                Enddatetime,
                Google_Calendar_Event_Id__c,
                Google_Calendar_Recurring_Event_Id__c,
                Google_Calendar_Event_Sequence_Num__c,
                Google_Calendar_Created_In_Google__c,
                RecurrenceActivityId,
                IsAllDayEvent,
                IsChild
            from Event where ownerid = :userId
        ], 'Google_Calendar_Event_Id__c');
    }
    
    public static List<Sync_Record__c> querySyncRecords(Id recordId) {
        return [select Id, External_Id__c, Module__c, Action__c, Status__c, Sub_Status__c, Message__c, Value1__c, OwnerId from Sync_Record__c where Record_Id__c = :recordId];
    }

    public static void deleteSyncRecords(Id recordId) {
    	delete querySyncRecords(recordId);
    }

    public static void deleteSyncRecords() {
        delete [select id from Sync_Record__c];
    }
    
    public static List<Sync_Record__c> querySyncRecords() {
        return [select id from Sync_Record__C where Module__c= 'GoogleCalendarSync'];
    }
    
    public static void insertSettings() {
        
        //During testing sfdc allows only one batch to be called. Default batch size is one, so will setu to higher for testing.
 		insertSetting('GoogleCalendarDeltaSyncBatchSize', '50');
        
        insertSetting('GoogleCalendarSyncEnabled', 'true');
        insertSetting('GoogleCalendarSyncLogPushNotification', 'true');
        insertSetting('GoogleCalendarSyncBaseUrl', 'https://www.googleapis.com/calendar/v3');
        insertSetting('GoogleCalendarSyncPushHandlerUrl', 'https://force.com/partner/services/apexrest/googlecalendarsync/pushHandler');
        insertSetting('GoogleCalendarSyncServiceAccountEmail', '187584108634-ss49re0vval2t9elqie6ac8gsjn9f6l2@developer.gserviceaccount.com');
        new SettingsServiceImpl().splitAndSetString('GoogleCalendarSyncServiceAccountKey', 'MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAMFvFwSfMSwfv5oqGxC+1+dnAi0mcrz5t8G/ysJchJ5n5cVklZnrhAGSd89G1Vo+OlbRzqfFRcsUG8AFXCtLpDkkqKGGWldSgV5n7vpbtkDClvbbuYKGpfS2MORenNt0du3ShUYTTse+44rTZbICv4Vpw4yUiZazYQKMh9w5thvpAgMBAAECgYEAjw0r9bQRNnOITGfFOl4Y574rQt7DTfRTrEq9lX28ajWmHJQlev5M0qjSSA03bZTFqj1hWnuvAN+vIhQUtMQs/vhwZfFn9EIRHE8owjn+Ii33CKl6t17Rqt7j2idjLAmZ9U5i9PJoxaT/KFYdNEtiAhxRGiIQpU50qmLp5IJOXLECQQDgp9ZwrzSpNpg+mbS/KWAILhTjD6gorBjcMv4LNyI9wm4iUJ2bN9XYt/bK18l1UrTHpg//orSJd4GWEzjhv2rdAkEA3GwWtQ/xbZ1fAknhy25SJZb8SITqyoZpuLucb3VnQUTcLxOcy0gf9B7yhqW3ng5p2EvWr3n9KhuSeCRIF3jGfQJABLhiEBIOWDPWdRJDsvSKmQFm3PJ6RQiAqTfFELVC2etY5w2skhNVQe1zmQV5rSZkuAEsOuHPS0ggh+e1fUDJXQJABVL7DW6QJ1SoydZdBNvqUgweleXYAgJTJWoqsiqEzvfJ1b1EiUh5tRzWQNhZ4hB5EAds7RomOlEmLY66yw5YxQJAU4/9UTGkPA26/aMxyMfj6W1qCroBOHQoSM5ZGEWcXBiKcHTmq6rX/ZKtERCyXSNPEOBLL61B56oj0ifJwWe3Dw==');
        insertSetting('GoogleCalendarSyncOAuthClientId', 'oauthclientid');
       	insertSetting('GoogleCalendarSyncOAuthClientSecret', 'oauthclientsecret');
        insertSetting('GoogleCalendarSyncOAuthCallback', 'https://cs9.salesforce.com/apex/GoogleCalendarSyncUserSetup');
 		      
    }
    static void insertSetting(String key, String value) {
        insert new Settings__c(Name=key, Value1__c=value);
    }
}