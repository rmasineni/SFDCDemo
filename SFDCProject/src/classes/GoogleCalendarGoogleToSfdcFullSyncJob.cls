/**
 * This class identifies all google calendar sync required users and adds them to the sync queue
 * for full syncing.
 */
public class GoogleCalendarGoogleToSfdcFullSyncJob extends BaseClass implements Queueable {
	
    public void execute(QueueableContext ctx) {
        List<User> users = [select Id from User where IsActive=true and Google_Calendar_Sync_Enabled__c = true];
        
        if (users.isEmpty()) {
            info('There are no active users who has Google Calendar Sync enabled');
            return;
        }
        
        info('Identified ' + users.size() + ' users to full sync their Google Calendars to Sfdc');
        
        Sf.googleCalendarService.requestGoogleToSfdcSync(getUniqueIdList(users), true);
    }
}