/**
 * This class identifies all events in the full sync timeframe, which are not originated in Google
 * and queue them for syncing.
 */
public class GoogleCalendarSfdcToGoogleFullSyncJob extends BaseClass implements Queueable {
	
    public List<Id> userIds {get;set;}
    
    public GoogleCalendarSfdcToGoogleFullSyncJob() {
        this(null);
    }
    
    public GoogleCalendarSfdcToGoogleFullSyncJob(List<Id> userIds) {
        this.userIds = userIds;
    }

    public void execute(QueueableContext ctx) {
        List<User> users = null;
        if (userIds == null || userIds.isEmpty()) {
            users = [select id,  Google_Calendar_Sfdc_Full_Sync_Time__c from user where IsActive=true and Google_Calendar_Sync_Enabled__c = true];
        } else {
            users = [select id,  Google_Calendar_Sfdc_Full_Sync_Time__c from user where IsActive=true and Google_Calendar_Sync_Enabled__c = true and Id In :userIds];
        }
        
        if (users.isEmpty()) {
            info('There are no active users who has Google Calendar Sync enabled to full sync Sfdc to Google');
            return;
        }
		
        DateTime newSfdcFullSyncTime = DateTime.now();
        
        List<Event> events = [
            select id, OwnerId, LastModifiedDate
            from Event 
            where OwnerId in :getUniqueIdList(users)
                and StartDateTime >= :getCurrentDateTime().addDays(-Sf.googleCalendarService.getFullSyncFromDays())
                and EndDateTime <= :getCurrentDateTime().addDays(Sf.googleCalendarService.getFullSyncToDays())
       	];
        
        //We will get all events for all users and then will try to full sync only the events which are
        //updated since last full sync.
        Map<Id, Sobject> usersMap = getIdMap(users);
        List<Event> syncRequiredEvents = new List<Event>();
        for (Event event : events) {
            User user = (User) usersMap.get(event.ownerId);
            if (user != null && (user.Google_Calendar_Sfdc_Full_Sync_Time__c == null || event.LastModifiedDate >= user.Google_Calendar_Sfdc_Full_Sync_Time__c)) {
                syncRequiredEvents.add(event);
            }
        }

        Sf.googleCalendarService.requestSfdcToGoogleSync(getUniqueIdList(syncRequiredEvents));
        
        //Update the new full sync time to all users.
        for (User user : users) {
            user.Google_Calendar_Sfdc_Full_Sync_Time__c = newSfdcFullSyncTime;
        }
        
        DbChangesWoSharing.save(users);
        
        Sf.appLogger.logDebug(GoogleCalendarDto.SyncModule, 'SfdcToGoogleFullSync', 
			'Identified ' + syncRequiredEvents.size() +' events which belongs to ' + users.size() +' users to full sync from Sfdc to Google');
    }
}