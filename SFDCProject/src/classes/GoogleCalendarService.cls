public interface GoogleCalendarService {

    /**
     * Handles the events trigger.
     */
    void handleEventsTrigger();
    
    /**
     * Enables the calendar sync between Google Calendar and Salesforce. It does following things. Note that when enabled, only the events
     * changed after enabling the sync would be synched.
     * 
     * 1. It Sets the Google_Calendar_Sync_Enabled__C to true
     * 2. It sets the specified calendar id to user.Google_Calendar_Id__c
     * 3. Registers for push notifications for this user.
     */
    void enableCalendarSync(String userId, String calendarId);
    void enableCalendarSync(String userId, String calendarId, Boolean startFullSync);
    
    /**
     * Disables the Calendar sync for specified user between Google Calendar and Salesforce.
     */
    void disableCalendarSync(String userId);

    void verifyUserCalendarSetupAndAccess(String calendarId);
        
    /**
     * Once registered for resource update notification with Google, it would send a push notification each time
     * something in the resource changes. Notification would include the resource id and channel id. To receive that
     * notification we have setup a Guest RestService hosted via Force.com Site page (/partner)
     * 
     * That RestService would extract the requried ids from Google push payload and calls this method.
     */
    void handlePushNotification(String resourceId, String channelId);
    
    /**
     * Once we receive a push notification, we would be able to retrieve the event details for these users 
     * and sync to Salesforce.
     */
    void requestGoogleToSfdcSync(List<Id> userIds, Boolean fullSync);

    /**
     * Queues up the given set of Events to be synced to Google.
     */
    void requestSfdcToGoogleSync(List<Id> eventIds);

    void requestFullSync(List<Id> userIds);

    Integer getFullSyncFromDays();
    Integer getFullSyncToDays();
    
    /**
     * Queries the users for given userids and returns the user objects with all Google Calendar related fields.
     */
	List<User> queryUsers(List<Id> userIds);

    /**
     * Queries the users based on the google Calendar Sync channel id.
     */
	List<User> queryUsersByChannelIds(List<String> channelIds);
    
    /**
     * Returns the Google Calendar Integration Service Account Emaill.
     */
    String getServiceAccountEmail();
    
    /**
     * During the setup we need to request user to grant access to calendar to add Server Account as another owner. This method generates the url
     * which requests such access using OAuth authorization.
     */
    String getOAuthAccessRequestUrl();

    /**
     * Once user grants access to the calendar, we need to convert that code into access token. Using token,
     * we can do further operations.
     */
    String getOAuthAccessToken(String oauthAccessCode);

    /**
     * Returns the primary calendar id for specified user (via access token)
     */
    String getUserPrimaryCalendarId(String accessToken);

    /**
     * Grant calendar access to service account. This call makes a callout to Google Calendar API requesting to grant
     * access to service account for specified calendar id.
     */
    void grantAccessToCalendar(String accessToken, String calendarId);
    
    /**
     * Returns the exceptions associated with the user event synching. Returns last 500 syncs errors.
     */
    List<App_Log__c> getSyncErrors(Id userId);
    
    /**
     * Returns the Google Event details for specified google event id.
     * 
     * This google event must have been synched already to Salesforce otherwise, this method returns null.
     */
    String getGoogleEvent(String eventId);
    
    void syncGoogleToSfdc(SyncJobInfo syncJob);
    void syncSfdcToGoogle(SyncJobInfo syncJob);
}