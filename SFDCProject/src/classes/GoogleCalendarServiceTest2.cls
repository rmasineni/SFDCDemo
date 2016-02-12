@IsTest
public class GoogleCalendarServiceTest2 {
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
   	
    //This tests when event is inserted, updated or deleted if we are appropriately
	//inserting the sync records.    
    testmethod public static void testHandleEventTrigger() {
        Event event = new Event(StartDateTime=DateTime.now(), 
				EndDateTime=DateTime.now(), 
                Google_Calendar_Event_Id__c='4p5eje11pfjsq7n9fcoudg2pvs_20150125T020000Z',
                Subject='Google Event', 
                OwnerId=UserInfo.getUserId());

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