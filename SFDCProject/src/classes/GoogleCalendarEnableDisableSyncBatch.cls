/**
 * This batch job will go through all usres who have google calendar enabled or required and then
 * does re-eanble the sync. When we change the sync credentials, the Google push would fail. In such cases, we will
 * use this to re-enable the sync for all users.
 * 
 * This batch job must be executed for one user at a time.
 * 
 * new GoogleCalendarEnableDisableSyncBatch().execute(null);
 */ 
public class GoogleCalendarEnableDisableSyncBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable {
    private BaseClass utils = new BaseClass();
    private List<Id> userIds {get;set;}
	private Boolean disable {get;set;}

    public GoogleCalendarEnableDisableSyncBatch() {
        this(null, false);
    }

    public GoogleCalendarEnableDisableSyncBatch(List<Id> userIds) {
        this(userIds, false);
    }
    
    public GoogleCalendarEnableDisableSyncBatch(List<Id> userIds, Boolean disable) {
        this.userIds = userIds;
        this.disable = disable;
    }

    public void execute(SchedulableContext sc) { 
    	Database.executebatch(this, 1);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        if (userIds == null || userIds.isEmpty()) {
            return Database.getQueryLocator([
                select id, Google_Calendar_Id__c
                from User 
                where Google_Calendar_Sync_Required__c = true or Google_Calendar_Sync_Enabled__c = true
           ]);
        }
        return Database.getQueryLocator([
            select id, Google_Calendar_Id__c
            from User 
            where id in :userIds
       ]);
    }
    
    public void execute(Database.BatchableContext BC, List<User> users){
        for (User user : users) {
        	if (disable) {
        		Sf.googleCalendarService.disableCalendarSync(user.id);
        	} else {
                if (utils.isNotEmpty(user.Google_Calendar_Id__c)) {
	        		Sf.googleCalendarService.enableCalendarSync(user.id, user.Google_Calendar_Id__c, false);
                } else {
                    utils.info('User [' + user + '] doesnot have the Google_Calendar_Id__c populated, which is required to enable the sync via batch.');
                }
        	}
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }
}