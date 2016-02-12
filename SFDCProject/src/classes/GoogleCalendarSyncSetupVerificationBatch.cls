/**
 * Batch job used to verify the setup of all user who enrolled for Google Calendar Sync.
 *
 * To execute this batch one time, you can use this script.
 * Database.executebatch(new GoogleCalendarSyncSetupVerificationBatch(), 25);
 */
public class GoogleCalendarSyncSetupVerificationBatch implements Database.Batchable<User>, Database.AllowsCallouts, Database.Stateful {
    private BaseClass utils = new BaseClass();
    private List<User> syncNotEnabledUsers = new List<User>();
    private List<User> syncVerificationFailedUsers = new List<User>();
	private List<SyncFailure> syncFailures = new List<SyncFailure>();
    private List<Id> userIds {get;set;}
    
    public GoogleCalendarSyncSetupVerificationBatch() {
        this(null);
    }
    
    public GoogleCalendarSyncSetupVerificationBatch(List<Id> userIds) {
        this.userIds = userIds;
    }
    
    public Iterable<User> start(Database.BatchableContext bc) {
        List<User> users = null;
        if (userIds == null || userIds.isEmpty()) {
        	users = [
                select id, 
                	Name, 
                	IsActive,
                	Google_Calendar_Sync_Enabled__c, 
                	Google_Calendar_Sync_Required__c, 
                	Google_Calendar_Id__c 
              	from user 
                where Google_Calendar_Sync_Enabled__c = true 
                	or Google_Calendar_Sync_Required__c = true 
                Order by name
           	];
        } else {
        	users = [
                select id, 
                	Name, 
                	IsActive,
                	Google_Calendar_Sync_Enabled__c, 
                	Google_Calendar_Sync_Required__c, 
                	Google_Calendar_Id__c 
              	from user 
                where id in :userIds
                Order by name
           	];
        }
        
        return users;
    }
    
    public void execute(Database.BatchableContext BC, List<User> users){
        DbChangesWoSharing dbChanges = new DbChangesWoSharing();
        
        for (User user : users) {
            if (!user.IsActive) {
                if (user.Google_Calendar_Sync_Enabled__c || user.Google_Calendar_Sync_Required__c) {
                    user.Google_Calendar_Sync_Enabled__c = false;
                    user.Google_Calendar_Sync_Required__c = false;
                    dbChanges.add(user);
                }
            } else {
                if (user.Google_Calendar_Sync_Required__c && !user.Google_Calendar_Sync_Enabled__c) {
                    syncNotEnabledUsers.add(user);
                    
                } else if (user.Google_Calendar_Sync_Enabled__c) {
                    try {
                        Sf.googleCalendarService.verifyUserCalendarSetupAndAccess(user.Google_Calendar_Id__c);
                    } catch (Exception e) {
                        syncVerificationFailedUsers.add(user);
                    }
                }
            }
        }
        
        dbChanges.save();

        //Get the list of sync failures since yesterday for these users.
        AggregateResult[] groupedResults = [
            select 
            	Owner.Name, 
            	count(id) 
           	from Sync_Record__c
            where LastModifiedDate >= Yesterday 
            	and Module__c = 'GoogleCalendarSync'
                and Status__c = 'Sync Error'
                and Owner.Id in :utils.getUniqueIdList(users)
            group by Owner.name
        ];
        
        for (AggregateResult ar : groupedResults)  {
            SyncFailure failure = new SyncFailure();
            failure.user = (String) ar.get('name');
            failure.failures = (Integer) ar.get('expr0');
            
            syncFailures.add(failure);
        }
    }
    
    public void finish(Database.BatchableContext BC){
        String body = null;
        
        body = '<h3>Users who should have Sync enabled but not currently enabled</h3>';
        if (!syncNotEnabledUsers.isEmpty()) {
            body += '<ul>';
            for (User user : syncNotEnabledUsers) {
                body += '<li><a href="' + URL.getSalesforceBaseURL().toExternalForm() + '/apex/GoogleCalendarSyncSetup?id=' + user.id +  '">' + user.name + '</a></li>';
            }
            body += '</ul>';
        } else {
            body += '<p>No Users</p>';
        }
        
        body += '<h3>Users who have sync enabled but sync is not setup correctly</h3>';
        if (!syncVerificationFailedUsers.isEmpty()) {
            body += '<ul>';
            for (User user : syncVerificationFailedUsers) {
                body += '<li><a href="' + URL.getSalesforceBaseURL().toExternalForm() + '/apex/GoogleCalendarSyncSetup?id=' + user.id +  '">' + user.name + '</a></li>';
            }
            body += '</ul>';
        } else {
            body += '<p>No Users</p>';
        }
        
        body += '<h3>Sync Failures Since Yesterday</h3>';
        
        System.debug('Sync Failures ' + syncFailures);
        if (!syncFailures.isEmpty()) {
            syncFailures.sort();
            
            body += '<ul>';
            for (SyncFailure syncfail : syncFailures) {
                body += '<li>' + syncfail.user + ' (' + syncfail.failures + ')</li>';
            }
            body += '</ul>';
        } else {
            body += '<p>No Failures</p>';
        }
        
        if (!Test.isRunningTest()) {
	        utils.sendEmail(Sf.settingsService.getStringList('GoogleCalendarSyncSetupReportAddresses'), 'Google Calendar Sync Setup Verification Report', body, true);
        }
    }

    public class SyncFailure implements Comparable {
        public String user {get;set;}
        public Integer failures {get;set;}
        
        public Integer compareTo(Object compareTo) {
            return failures - ((SyncFailure) compareTo).failures;
        }        
    }    
}