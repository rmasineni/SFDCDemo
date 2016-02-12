@RestResource(urlMapping='/googlecalendarsync/pushHandler')
global without sharing class GoogleCalendarSyncPushHandlerRestService {
    
    private static BaseClass utils = new BaseClass();

    @HttpGet
    global static String statusCheck() {
        return 'Ping back from GoogleCalendarSync/PushHandler';
    }

    @HttpPost
    global static void handlePushNotification() {
        RestRequest req = RestContext.request;

        System.debug('Coming to handle push notification ' + req);

        String pushType = req.headers.get('X-Goog-Resource-State');     
        if (pushType == 'sync') {
            //When registered for notifications, Google sends a first push called Sync notification to confirm if everything is working.
            //We will ignore this as of now and not take any actions.
        } else {
	        Sf.googleCalendarService.handlePushNotification(req.headers.get('X-Goog-Resource-ID'), req.headers.get('X-Goog-Channel-ID'));
        }
		
		//Log the notification to exception table so we can troubleshoot the notification errors better.
		logPushNotification();
    }
    
    public static void logPushNotification() {
        
        //If push notification logging is not enabled, then don't log it.
        if (!Sf.settingsService.getBoolean('GoogleCalendarSyncLogPushNotification', true)) {
            return;
        }
		
        App_Log__c appLog = null;
        try {
            RestRequest req = RestContext.request;
            
            appLog = Sf.appLogger.createDebug('GoogleCalendarSync', 'GoogleCalendarSyncPushNotification', null, String.valueOf(req), null);
            
            //This code usually runs from within the Portal Guest User context so we need to get the user corresponding to this 
            //notification and associate with the log entry.
            String channelId = req.headers.get('X-Goog-Channel-ID');
            if (channelId != null) {
                List<User> users = Sf.googleCalendarService.queryUsersByChannelIds(new String[]{channelId});
                if (!users.isEmpty()) {
                    appLog.OwnerId = users.get(0).id;
                    appLog.CreatedById = users.get(0).id;
                    appLog.LastModifiedById = users.get(0).id;
	                appLog.External_Id__c = users.get(0).Google_Calendar_Id__c;
                }
                appLog.Message__c = 'Received push notification for users ' + users;
            }
            
            insert appLog;
        } catch (Exception e) {
            System.debug('Exception while logging the google push notification '  + appLog + ' ' + utils.getStackTrace(e));
        }
    }
}