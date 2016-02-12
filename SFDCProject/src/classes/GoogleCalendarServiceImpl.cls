public without sharing class GoogleCalendarServiceImpl extends BaseClass implements GoogleCalendarService {

    private static final String googleCalendarSyncToken = 'googleCalendarSyncToken';
    private static final Integer HTTP_MAX_RETRIES = 2;
    private static final Integer GoogleCalendarSequenceIncrement = Sf.settingsService.getInteger('GoogleCalendarSequenceIncrement', 2);
    private static final Integer GoogleCalendarListEventsMaxSize = Sf.settingsService.getInteger('GoogleCalendarListEventMaxSize', 2000);
    
    private static final String GOOGLE_API_OAUTH2_TOKEN_ENDPOINT = 'https://accounts.google.com/o/oauth2/token';
    private static final string GOOGLE_API_OAUTH2_AUTH_ENDPOINT = 'https://accounts.google.com/o/oauth2/auth?scope={Scope}&state={State}&redirect_uri={RedirectUrl}&client_id={ClientId}&approval_prompt=auto&response_type=code';    
    private static final String GOOGLE_API_OAUTH2_SCOPE = 'https://www.googleapis.com/auth/calendar';

    //We will check for this string in the creator's email of google event. If it contains this string,
    //then event was created in Google because Salesforce requested it was created originally in Google.
    private static final String NotCreatedInGoogleCheckString = Sf.settingsService.getString('GoogleCalendarNotCreatedInGoogleString', 'gserviceaccount.com');
		
	//This map is used to store the event ids of events which are already marked for sync
	//in this transaction and also events which are being updated from google. This helps
	//avoid the recursion of the events google to sfdc sync triggering new events sync back to google.    
    public static final Map<Id, String> eventsProcessingInProgress = new Map<Id, String>();
    public static final Map<String, String> eventsProcessingInProgressByGoogleEventId = new Map<String, String>();
    
    public Integer getFullSyncFromDays() {
        return Sf.settingsService.getInteger('GoogleCalendarFullSyncFromDays', 7);
    }
    
    public Integer getFullSyncToDays() {
        return Sf.settingsService.getInteger('GoogleCalendarFullSyncToDays', 180);
    }

    public class GoogleCalendarWatchRequest {
        public String id {get;set;}
        public String type {get;set;}
        public String address {get;set;}
    }
    
    public class GoogleCalendarCancelWatchRequest {
        public String id {get;set;}
        public String resourceId {get;set;}
    }

    private String serviceAccountAccessToken;

    public List<App_Log__c> getSyncErrors(Id userId) {
        return [
            select 
            	Id, Name,
            	Module__c,
            	Action__c,
            	Type__c,
            	Sobject__c,
            	Record_id__c,
            	Message__c,
            	CreatedDate
            from App_Log__c
           	where Module__c = 'GoogleCalendarSync' and OwnerId = :userId and Type__c = 'Error'
            order by lastmodifieddate desc 
            limit 100
		];
    }
    
    public void enableCalendarSync(String userId, String calendarId) {
        enableCalendarSync(userId, calendarId, true); //Start the full sync immediately
    }
    
    public void enableCalendarSync(String userId, String calendarId, Boolean startFullSync) {
        User user = queryUsers(new String[]{userId}).get(0);
        
        //Verify that user has granted appropriate access to service account.
        verifyUserCalendarSetupAndAccess(calendarId);
        
        info('Enabling Google Calendar Sync for ' + user);
        try {
            unregisterCalendarPushNotifications(user);
        } catch (Exception e) {
            //Ignore
        }
        
        GoogleCalendarWatchRequest req = new GoogleCalendarWatchRequest();
        req.id = 'User-' + userId + '-' + getDateTimeFormattedForId();
        req.address = Sf.settingsService.getString('GoogleCalendarSyncPushHandlerUrl');
        req.type = 'web_hook';
        String watchResponse = googleCalendarHttpPost('/calendars/' + calendarId + '/events/watch', Json.serialize(req));
        JsonReader jsonReader = new JsonReader(watchResponse);
        
        user.Google_Calendar_Sync_Enabled__c = true;
        user.Google_Calendar_Sync_Required__c = true;
        user.Google_Calendar_Id__c = calendarId;
        user.Google_Calendar_Push_Resource_Id__c = jsonReader.getString('resourceId');
        user.Google_Calendar_Push_Channel_Id__c = jsonReader.getString('id');
        user.Google_Calendar_Setup_DateTime__c = getCurrentDateTime();
        
        update user;
        
        //Full sync the user calendar
        if (startFullSync) {
            requestFullSync(new String[]{user.id});
        }
    }
	
    /**
     * Make sure the service account can read/write into the specified user's google calendar.
     * If we are not able to read/write then User's Calendar hasn't been given full manage access
     * to the service account.
     * 
     * The way we are going to test read/write access is that we will create a test-event in user's calendar
     * then later tries to read it and finally remove it. If any of these operations fails, then we know
     * that setup is not complete.
     */
    public void verifyUserCalendarSetupAndAccess(String calendarId) {
        Event testEvent = new Event(
            Subject='Salesforce-Google Calendar Sync Setup Test',
            startDateTime = getCurrentDateTime(),
            EndDateTime = getCurrentDateTime().addMinutes(60),
            Google_Calendar_Event_Sequence_Num__c = 1
        );
        
        String testEventJson = createGoogleEventJson(testEvent);

        info('Sending the Setup Test event ' + testEvent + ' to to google.');
        String response = googleCalendarHttpPost('/calendars/' + calendarId + '/events', testEventJson);
        JsonReader jsonReader = new JsonReader(response);
        testEvent.Google_Calendar_Event_Sequence_Num__c = jsonReader.getInteger('sequence');
        testEvent.Google_Calendar_Event_Id__c = jsonReader.getString('id');
        
        info('Event after synching to Google ' + testEvent + '. Now going to read the event from google.');
        if (isEmpty(testEvent.Google_Calendar_Event_Id__c)) {
            throw new BusinessException('Could not successfully create a test event in Google Calendar. '+ 
                'Please check if User has granted Manage access to Service Account.');
        }
        
        //Remove the teste event.
        try {
            googleCalendarHttpDelete('/calendars/' + calendarId + '/events/' + testEvent.Google_Calendar_Event_Id__c, null);
        } catch (UnsuccessfulHttpResponseException e) {
            //204 success no content
            if (e.isStatusCode(204)) {
                //ignore
            } else {
                throw e;
            }
        }
    }
    
    public void disableCalendarSync(String userId) {
        User user = queryUsers(new String[]{userId}).get(0);
        info('Disabling Google Calendar Sync for ' + user);
        
        try {
            unregisterCalendarPushNotifications(user);
        } catch (Exception e) {
            //Ignore
        }
        
        user.Google_Calendar_Sync_Enabled__c = false;
        user.Google_Calendar_Push_Channel_Id__c = null;
        user.Google_Calendar_Push_Resource_Id__c = null;
        
        update user;
    }

    private void unregisterCalendarPushNotifications(User user) {
        unregisterCalendarPushNotifications(user.Google_Calendar_Push_Resource_Id__c, user.Google_Calendar_Push_Channel_Id__c);
    }

    private void unregisterCalendarPushNotifications(String resourceId, String channelId) {
        if (isNotEmpty(resourceId) && isNotEmpty(channelId)) {
            GoogleCalendarCancelWatchRequest req = new GoogleCalendarCancelWatchRequest();
            req.id = channelId;
            req.resourceId = resourceId;
            
            try {
                googleCalendarHttpPost('/channels/stop', Json.serialize(req));
            } catch (UnsuccessfulHttpResponseException e) {
                if (e.getStatusCode() >= 200 && e.getStatusCode() < 300) {
                    //any 2xx means successfully completed without any response.
                } else {
                    throw e;
                }
            }
        }
    }

    public void handleEventsTrigger() {
        List<Sobject> eventsToBeSyncedToGoogle = new List<Sobject>();
        
        if (isAfterInsertOrUpdate()) {
            for (Integer i = 0; i < Trigger.new.size(); i++) {
                Event oldEvent = (Event) (Trigger.isUpdate?Trigger.old.get(i):null);
                Event newEvent = (Event) Trigger.new.get(i);
                
                if (newEvent.isChild) {
                    info('Child event cannot be updated in salesforce and hence are not supported for syncing ' + newEvent);
                    continue;
                }
                
                if (newEvent.RecurrenceActivityId != null) {
                    info('Recurring event created in Salesforce are not supported for syncing ' + newEvent);
                    continue;
                }
                
                if (eventsProcessingInProgress.containsKey(newEvent.id) || eventsProcessingInProgressByGoogleEventId.containsKey(newEvent.Google_Calendar_Event_Id__c)) {
					info('Event is being inserted/updated from Google to Sfdc Sync or already marked for sync in this txn so ignoring. ' + newEvent);
                } else {
                    if (Trigger.isInsert || isEventUpdated(oldEvent, newEvent)) {
                        info('Event is identified as to be synced to google ' + newEvent);
						eventsToBeSyncedToGoogle.add(newEvent);
                        eventsProcessingInProgress.put(newEvent.id, '');
                    }
                }
            }
        }
        
        //If events are deleted, we will capture them too with corresponding google calendar event id.
        //because we need this to delete google calendar.
        if (isAfterDelete()) {
            for (Sobject sobj : Trigger.old) {
                Event oldEvent = (Event) sobj;
                if (eventsProcessingInProgress.containsKey(oldEvent.id) || eventsProcessingInProgressByGoogleEventId.containsKey(oldEvent.Google_Calendar_Event_Id__c)) {
					info('Event is being deleted from Google to Sfdc Sync or already marked for sync in this txn so ignoring. ' + oldEvent);
                } else {
                    if (oldEvent.Google_Calendar_Event_Id__c != null) {
                        eventsToBeSyncedToGoogle.add(oldEvent);
                        eventsProcessingInProgress.put(oldEvent.id, '');
                    }
                }
            }
        }
        
        if (!eventsToBeSyncedToGoogle.isEmpty()) {
            requestSfdcToGoogleSync(eventsToBeSyncedToGoogle);
        }
    }

    public void requestFullSync(List<Id> userIds) {
        requestGoogleToSfdcSync(userIds, true);
        new GoogleCalendarSfdcToGoogleFullSyncJob(userIds).execute(null);
    }

    public void requestSfdcToGoogleSync(List<Id> eventIds) {
        requestSfdcToGoogleSync([select id, OwnerId, Google_Calendar_Event_Id__c from Event where id in :eventIds]);
    }
    
    public void requestSfdcToGoogleSync(List<Event> events) {
        //We need to populate the User calendar id for all of these events for record.
        Map<Id, Sobject> usersMap = getIdMap([
            select 
            	Google_Calendar_Id__c 
            from User 
            where Id in :getUniqueIdList(events, 'OwnerId') 
            	and IsActive = true 
            	and Google_Calendar_Sync_Enabled__c = true 
            	and Google_Calendar_Id__c != null
        ]);
        
       	List<Sync_Record__c> syncRecords = Sf.syncService.createSyncRecords(GoogleCalendarDto.SyncModule, GoogleCalendarDto.SfdcToGoogleSync, events, 'Google_Calendar_Event_Id__c');
        List<Sync_Record__c> toBeSyncedSyncRecords = new List<Sync_Record__c>();
        for (Sync_Record__c syncRecord : syncRecords) {
            User user = (User) usersMap.get(syncRecord.OwnerId);
            if (user != null) {
	            syncRecord.Value1__c = user.Google_Calendar_Id__c;
                toBeSyncedSyncRecords.add(syncRecord);
            }
        }
        
        if (!toBeSyncedSyncRecords.isEmpty()) {
            Sf.syncService.insertSyncRecords(syncRecords);
	        Sf.commonScheduler.markJobEligibleToRun(GoogleCalendarDto.SfdcToGoogleSyncJob);
        }
    }
    
    public void syncSfdcToGoogle(SyncJobInfo syncJob) {
        Map<Id, SObject> eventsMap = getIdMap(queryEvents(syncJob.getRecordIds()));
        
        List<Id> userIds = new List<Id>();
        userIds.addAll(getUniqueIdList(eventsMap.values(), 'OwnerId'));
        userIds.addAll(getUniqueIdList(syncJob.syncRecords, 'OwnerId'));
        Map<Id, SObject> usersMap = getIdMap(queryUsers(userIds));
        
        DbChangesWoSharing dbChangesEvents = new DbChangesWoSharing();
        DbChangesWoSharing dbChangesUsers = new DbChangesWoSharing();

        for (Sync_Record__c syncRecord : syncJob.syncRecords) {
            
            //We need at least two/three callouts for each record. So if we have reached the limit, then
            //let's stop processing. To be safe, we will stop if we have less than 5 calls outs.
            if (getCalloutsQuota() < 5) {
                info('Quota limits reached for callouts ' + getCalloutsQuota() + ' so skipping further sfdc to google sync');
                break;
            }

            try {
                syncJob.setBatch(syncRecord);
                
                Event event = (Event) eventsMap.get(syncRecord.Record_Id__c);
                User user = (User) usersMap.get(event==null?syncRecord.ownerId:event.ownerId);
                
                //If we cannot find a event for specified id, then it is delete.
                if (event == null) {
                    if (syncRecord.External_Id__c != null) {
	                    deleteGoogleEvent(user, syncRecord.External_Id__c, syncJob);
                        syncJob.setStats(0, 0, 1);
                    } else {
                        syncJob.syncNotApplicable('Record Deleted');
                    }
                    continue;
                }
                
                //If sync record status is Error and if it has Google calendar event id,
                //it means, it was successfully processed but erroed out while
                //updating the event or user so what we will do just copy the event id from sync
                //record to event and mark the sync record as processed.
                if (syncRecord.Status__c == Status_SyncError && syncRecord.External_Id__c != null) {
                   	syncJob.log('The sync record ' + syncRecord + ' was successfully synced to Google but there was an error' 
                                + ' while copying the Google event id back to Sfdc. So we will just'
                                + ' copy the event id and mark the record as success.');

                    if (syncRecord.Response_Payload__c != null) {
                        GoogleCalendarDto.Event gevent = (GoogleCalendarDto.Event) Json.deserialize(syncRecord.Response_Payload__c, GoogleCalendarDto.Event.class);
                        event.Google_Calendar_Event_Id__c = gevent.gcalEventId;
                        event.Google_Calendar_Recurring_Event_Id__c = gevent.gcalRecurringEventId;
                        event.Google_Calendar_Event_Sequence_Num__c = gevent.sequence;
                        
                        dbChangesEvents.add(event);
                        eventsProcessingInProgress.put(event.id, '');

                        syncJob.log('Updating event ' + event);
                        syncJob.syncSuccess();

                        continue;
                    }
                }

                if (!isSyncCalendar(user, syncJob)) {
                    continue;
                }
                
                if (event.IsChild) {
                    syncJob.log('Event is a child event and hence not synced to Google [' + event + ']');
                    syncJob.syncNotApplicable('Child Events Not Supported');
                    continue;
                }
                
                if (event.RecurrenceActivityId != null) {
                    syncJob.log('Event is a Recurring Event created in Saleforce and hence not synced. [' + event + ']');
                    syncJob.syncNotApplicable('Recurring Events Not Supported');
                    continue;
                }
                
                Boolean isCreate = event.Google_Calendar_Event_Id__c == null;
                Boolean eventUpdated = upsertGoogleEvent(event, user, syncJob);
                
                if (isCreate) {
					syncJob.setStats(1, 0, 0);
                } else {
                    syncJob.setStats(0, 1, 0);
                }
                
                if (eventUpdated) {
                    dbChangesEvents.add(event);
                    eventsProcessingInProgress.put(event.id, '');
                    syncJob.log('Updating event ' + event);
                }
				
                user.Google_Calendar_Sfdc_Delta_Sync_Time__c = DateTime.now();
                dbChangesUsers.add(user);
                
                syncJob.syncSuccess();
            } catch (Exception e) {
                syncJob.handleException(e);
            }
        }
        
        dbChangesEvents.save();
        dbChangesUsers.saveIgnoreExceptions();
    }

    public Boolean upsertGoogleEvent(Event event, User user, SyncJobInfo syncJob) {
        String response = null;
		
        try {
	        String googleEventJson = null;

            if (event.Google_Calendar_Event_Id__c == null) {
                googleEventJson = createGoogleEventJson(event);
                String url = '/calendars/' + user.Google_Calendar_Id__c + '/events';
            	syncJob.log('Sending Http Request POST to ' + url + ' with body ' + googleEventJson);
                response = googleCalendarHttpPost(url, googleEventJson);
            } else {
                event.Google_Calendar_Event_Sequence_Num__c = increment(event.Google_Calendar_Event_Sequence_Num__c, GoogleCalendarSequenceIncrement);
                googleEventJson = createGoogleEventJson(event);
				String url = '/calendars/' + user.Google_Calendar_Id__c + '/events/' + event.Google_Calendar_Event_Id__c;
                syncJob.log('Sending Http Request PUT to ' + url + ' with body ' + googleEventJson);
                response = googleCalendarHttpPut(url, googleEventJson);
            }
            
            syncJob.log('Received http response from Google ' + response);

            //We need to store the google event id, recurring event id, and sequence number
            //in sync job so if saving events fails, we will be able to get it from sync job later
            JsonReader jsonReader = new JsonReader(response);
            
            GoogleCalendarDto.Event gevent = new GoogleCalendarDto.Event();
            gevent.gcalEventId = jsonReader.getString('id');
            gevent.gcalRecurringEventId = jsonReader.getString('recurringEventId');
            gevent.sequence = jsonReader.getInteger('sequence');
		
            //If this is create event in google, we will store the respnsoe payload so that
            //if event update fails, we can copy these details back in next processing.
            if (event.Google_Calendar_Event_Id__c == null) {
                syncJob.setExternalId(gevent.gcalEventId);
	            syncJob.setResponsePayload(Json.serializePretty(gevent));
            }
			
            Boolean eventUpdated = false;
            if (event.Google_Calendar_Event_Sequence_Num__c != gevent.sequence) {
	            event.Google_Calendar_Event_Sequence_Num__c = gevent.sequence;
                eventUpdated = true;
            }
            
            if (event.Google_Calendar_Event_Id__c != gevent.gcalEventId) {
	            event.Google_Calendar_Event_Id__c = gevent.gcalEventId;
                eventUpdated = true;
            }
            
            if (event.Google_Calendar_Recurring_Event_Id__c  != gevent.gcalRecurringEventId) {
	            event.Google_Calendar_Recurring_Event_Id__c = gevent.gcalRecurringEventId;
                eventUpdated = true;
            }
    
            syncJob.syncSuccess();
            
            return eventUpdated;
        } catch (UnsuccessfulHttpResponseException e1) {
            if (e1.isStatusCode(404)) {
                
                //It could happen that when a event is synched with Salesforce but later deleted from Google, it would fail when we update
                //as Google won't find a entry with that Id. In such cases, we will get 404 indicating resource doesn't exist. Will
                //catch that error and try to insert the event to google.
                if (event.Google_Calendar_Event_Id__c != null) {
                    event.Google_Calendar_Event_Id__c = null;
                    info('Event ' + event + ' was there in Google earlier but has been deleted since so we are trying to insert again.');
                    upsertGoogleEvent(event, user, syncJob);
                    return true;
                } else {
                    throw e1;
                }
                
            } else if (e1.isResponseContains('Invalid sequence')) {
                //We have been getting following error at times, invalid sequence code. This happens when we update google calendar
                //with old sequence. We are actually incrementing it but under race conditions, google may see a old sequence code. If it happens,
                //we will just increment the sequence code and retry again.
                syncJob.log('Received invalid sequence error message. Going to increment the seq and resent the update. ' + e1.toString());
                event.Google_Calendar_Event_Sequence_Num__c += GoogleCalendarSequenceIncrement;
				upsertGoogleEvent(event, user, syncJob);
                return true;
                
            } else if (e1.isResponseContains('Cannot modify requested event') || (isTrue(event.Google_Calendar_Created_In_Google__c) && e1.isResponseContains('Forbidden'))) {
                //Sometimes google events are marked as identified as non-updatable. If we try to update
                //them google will return error indicating they cannot be updated. If so, we will just
                //mark the sync as success.
                syncJob.log('Received error indicating this event cannot be updated. So we will mark as Sync Not Applicable and move on. ' + e1.toString());
	            syncJob.syncNotApplicable('Non Modifiable Google Event');
                return false;

            } else {
                throw e1;
            }
        }
    }
    
    public void handlePushNotification(String resourceId, String channelId) {
        List<User> users = queryUsersByChannelIds(new String[]{channelId});
        
        if (users.isEmpty()) {
            //When we don't find a user for a channel, it is because of stale channel id so we need to inform
            //google to cancel it.
            unregisterCalendarPushNotifications(resourceId, channelId);
            
        } else {
            requestGoogleToSfdcSync(getUniqueIdList(users), false);
            for (User user : users) {
                user.Google_Calendar_Goog_Push_Time__c = DateTime.now();
            }
            
            //If something happens while saving users is not critical.
            DbChangesWoSharing.saveIgnoreExceptions(users);
        }
    }

    public void requestGoogleToSfdcSync(List<Id> userIds, boolean fullSync) {
        List<User> users = [select id, Google_Calendar_Id__c from User where Id in: userIds];
        Map<Id, Sobject> usersMap = getIdMap(users);
        List<Sync_Record__c> syncRecords = Sf.syncService.createSyncRecords(GoogleCalendarDto.SyncModule, GoogleCalendarDto.GoogleToSfdcSync, users);
        
        for (Sync_Record__c syncRecord : syncRecords) {
            syncRecord.OwnerId = syncRecord.Record_Id__c;
            syncRecord.Value1__c = getStringValue(usersMap.get(syncRecord.Record_Id__c), 'Google_Calendar_Id__c');
           	syncRecord.Sub_Type__c = fullSync?'Full Sync':null;
        }

        Sf.syncService.insertSyncRecords(syncRecords);
        Sf.commonScheduler.markJobEligibleToRun(GoogleCalendarDto.GoogleToSfdcSyncJob);
    }

    public void syncGoogleToSfdc(SyncJobInfo syncJob) {
        List<User> users = queryUsers(syncJob.getRecordIds());
        
        //We need to associate the events we insert/update in Salesforce with contacts
        //related to users. The field which links contacts to users is Contact.Sunrun_User__c field.
        //We will query all contacts matching by this field and create a map. Then we will use
        //the map to get corresponding contact id and set the WhoId field of event.
        Map<Id, SObject> userIdToContactMap = getIdMap([select Id, SunRun_User__c from Contact where SunRun_User__c in :getUniqueIdList(users)], 'SunRun_User__c');
        DbChangesWoSharing dbChangesEvents = new DbChangesWoSharing();
        DbChangesWoSharing dbChangesUsers = new DbChangesWoSharing();
        
        for (User user : users) {
            Integer inserts = 0;
            Integer updates = 0;
            Integer deletes = 0;
            
            //To sync from Google to Salesforce for each user, we need at least 3 callsouts and 3 soqls. If that 
            //quota is reached, we will not process more users.
            if (getQueriesQuota() < 3 || getCalloutsQuota() < 3) {
                info('Quota limits reached for call outs ' + getCalloutsQuota() + ' or queries ' + getQueriesQuota() + ' so skipping rest of the user processing.');
                break;
            }
            
            try {
                syncJob.setBatch(user.id);
                syncJob.log('Starting the Google to Sfdc sync for user ' + user.Google_Calendar_Id__c);
                
                if (!isSyncCalendar(user, syncJob)) {
                    continue;
                }
                
                //This flag indicates if we did sync any events for this user. If there are no events, then we will not update
                //some of the timestamp fields to accurately represent when was last time we actually sycned.
                Boolean syncedEvents = false;
                
                //Indicates the timewindow that we will sync from for this user.
                Integer syncFromDays = Integer.valueOf(firstNonNull(user.Google_Calendar_Sync_From_Days__c, getFullSyncFromDays()));
                
                //Indicates the timewindow that we will sync to for this user.
                Integer syncToDays = Integer.valueOf(firstNonNull(user.Google_Calendar_Sync_To_Days__c, getFullSyncToDays()));
                
                String syncToken = getSyncToken(user, syncJob);
                
                info('Sync Token for Google to sfdc sync is ' + syncToken);
                
                GoogleCalendarDto.ListEventsResponse listResponse = listGoogleEvents(user.Google_Calendar_Id__c, 
                                                                                             syncToken, null, null, syncFromDays, syncToDays, syncJob);
                
                //Even if we didn't request full sync, sometimes google asks to do full sync.
                Boolean fullSync = syncToken == null || listResponse.fullSync;
                
                syncJob.log('After filtering the events, identified ' + listResponse.events.size() + ' events that we need to process.');
                
                List<Event> events = queryEvents(user, listResponse);
                Map<String, SObject> seventsByExternalId = getStringMap(events, 'Google_Calendar_Event_Id__c');
                Map<String, SObject> seventsById = getStringMap(events, 'Id');
                
                //Store the next token in user.
                user.Google_Calendar_Sync_Token__c = listResponse.syncToken;
                
                for (Integer i = 0; i < listResponse.events.size(); i++) {
                    
                    GoogleCalendarDto.Event gevent = listResponse.events.get(i);
                    syncJob.log('Processing the google event ' + gevent);
                    
                    //When a normal event is converted to recurring event, the original event id is returned
                    //as recurring id and all instance of recurrance as individual events. So we will
                    //findout if we have an event with recurring event id as original event id and if so, will delete it.
                    if (gevent.gcalRecurringEventId != null) {
                        Event originalRecurringSevent = (Event) seventsByExternalId.get(gevent.gcalRecurringEventId);
                        if (originalRecurringSevent != null) {
                            eventsProcessingInProgress.put(originalRecurringSevent.id, '');
                            dbChangesEvents.addDelete(originalRecurringSevent);
                            deletes++;
                            syncJob.log('Deleting event as original recurring event changed to normal event ' + originalRecurringSevent);
                        }
                    }
                    
                    Event sevent = (Event) seventsByExternalId.get(gevent.gcalEventId);
                    if (sevent == null && gevent.salesforceEventId != null) {
                        sevent = (Event) seventsById.get(gevent.salesforceEventId);
                    }
                    
                    if (gevent.status == 'cancelled') {
                        if (sevent == null) {
                            syncJob.log('Google event is deleted but same event is not there in Salesforce so no action taken. Gevent=' + gevent);
                        } else {
                            syncJob.log('Google event is deleted and hence deleting from Salesforce. Gevent=' + gevent + ', Sevent=' + sevent);
                            eventsProcessingInProgress.put(sevent.id, '');
                            eventsProcessingInProgressByGoogleEventId.put(sevent.Google_Calendar_Event_Id__c, '');
                            dbChangesEvents.addDelete(sevent);
                            syncJob.log('Deleting event as it was deleted in Google ' + sevent);
                        }
                    } else {
                        if (sevent == null) {
                            info('Could not find a Salesforce event for Google event ' + gevent + ' so creating new Salesforce event');
                            sevent = new Event();
                            sevent.OwnerId = user.id;
                        } else {
                            info('Found a Salesforce event ' + sevent + ' for Google event ' + gevent + ' so going to update the same if changed.');
                        }
                        
                        boolean isEventUpdated = copyGoogleEventToSalesforceEvent(gevent, sevent);
                        if (isEventUpdated) {
                            sevent.Google_Calendar_Created_In_Google__c = gevent.createdInGoogle;
                            Contact contact = (Contact) userIdToContactMap.get(user.id);
                            if (contact != null) {
                                sevent.WhoId = contact.Id;
                            }
                            
                            dbChangesEvents.add(sevent);
                            if (sevent.id == null) {
                                eventsProcessingInProgressByGoogleEventId.put(sevent.Google_Calendar_Event_Id__c, '');
                                inserts++;
                                syncJob.log('Inserting event ' + sevent);
                            } else {
                                eventsProcessingInProgress.put(sevent.id, '');
                                updates++;
                                syncJob.log('Updating event ' + sevent);
                            }
                        } else {
                            syncJob.log('Google event ' + gevent + ' is same as salesforce event ' + sevent + ' and hence not updating.');
                        }
                    }
                    
                    //Trying to clear the event out of memory to save the heap
                    listResponse.events.set(i, null);
                }
                
                dbChangesUsers.add(user);
                syncJob.log('Updating user ' + user);
                syncJob.syncSuccess();
                syncJob.setStats(inserts, updates, deletes);
                
                user.Google_Calendar_Goog_Sync_Try_Time__c = DateTime.now();
                if (inserts > 0 || updates > 0 || deletes > 0) {
                    if (fullSync) {
                        user.Google_Calendar_Goog_Full_Sync_Time__c = DateTime.now();
                    } else {
                        user.Google_Calendar_Goog_Delta_Sync_Time__c = DateTime.now();
                    }
                }
            } catch (Exception e) {
                syncJob.handleException(e);
            }
        }
        
        Savepoint sp = Database.setSavepoint();
        try {
            try {
	            dbChangesUsers.save();
            } catch (Exception e) {
                //If google to sfdc full sync is enabled, then there is no point in 
                //worrying about user save as getting events synced is more important.
                //Otherwise, we will need to fail as we need latest sync token to be 
                //saved with user.
                if (!isGoogleToSfdcFullSyncAlways()) {
                    throw e;
                }
            }
            dbChangesEvents.save();
        } catch (Exception e) {
            //When we throw any exceptions, we would want to rollback all dbchanges so next time
            //the sync runs, users calendar will be synced from previous point.
            Database.rollback(sp);
            throw e;
        }
    }

    public List<Event> queryEvents(List<Id> eventIds) {
        return [select 
                id, 
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
           from Event
           where id in :eventIds];
    }

    
    public List<Event> queryEvents(Id userId, List<String> eventIds, List<String> eventExternalIds) {
        return [select 
                id, 
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
           from event 
           where (Google_Calendar_Event_Id__c in :eventExternalIds 
                  	or Id in :eventIds)
                and OwnerId = :userId
         	];
    }

    public List<User> queryUsers(List<Id> userIds) {
        return [select 
                    id,
                    Name,
                    Email,
                    IsActive,
                    Google_Calendar_Goog_Full_Sync_Time__c,
                    Google_Calendar_Goog_Delta_Sync_Time__c,
                    Google_Calendar_Goog_Sync_Try_Time__c,
                    Google_Calendar_Goog_Push_Time__c,
                    Google_Calendar_Id__c,
                    Google_Calendar_Push_Channel_Id__c,
                    Google_Calendar_Push_Resource_Id__c,
                    Google_Calendar_Setup_DateTime__c,
                    Google_Calendar_Sfdc_Delta_Sync_Time__c,
                    Google_Calendar_Sfdc_Full_Sync_Time__c,
                    Google_Calendar_Sync_Enabled__c,
                    Google_Calendar_Sync_From_Days__c,
                    Google_Calendar_Sync_Required__c,
                    Google_Calendar_Sync_To_Days__c,
                    Google_Calendar_Sync_Token__c
                from user 
                where id in :userIds
        ];
    }
    
    public List<User> queryUsersByChannelIds(List<String> channelIds) {
        
        List<User> users = [select 
                    id, Google_Calendar_Id__c
                from user 
                where Google_Calendar_Push_Channel_Id__c in :channelIds
            ];
        
        info('Coming to query users by channel ids for ' + channelIds +' and found user ' + users);
        
        return users;
    }

    /**
     * Creates Google Event resource json for given Salesforce Event object. This would embed the Salesforce Event id as 
     * extendedProperties with key salesforceEventId in GCal event resource.
     */
    public String createGoogleEventJson(Event event) {
        JsonWriter writer = new JsonWriter();
        
        writer.write('summary', event.Subject);
        writer.write('description', event.Description);

        if (event.IsAllDayEvent) {
            writer.write('start.date', event.StartDateTime.formatGmt('yyyy-MM-dd'));
        } else {
            writer.write('start.dateTime', event.StartDateTime);
        }

        if (event.IsAllDayEvent) {
            //Google's end date is exclusive. For all day events, it would be next day.
            writer.write('end.date', event.EndDateTime.addDays(1).formatGmt('yyyy-MM-dd'));
        } else {
            writer.write('end.dateTime', event.EndDateTime);
        }

        if (event.id != null) {
            writer.write('extendedProperties.private.salesforceEventId', event.id);
        }
        
        //If this event is created in Salesforce, then let's mention that it is created in Salesforce.
        if (event.Google_Calendar_Event_Id__c == null) {
            writer.write('extendedProperties.private.createdInSalesforce', true);
        }

        writer.write('sequence', event.Google_Calendar_Event_Sequence_Num__c);
        return writer.toPrettyJson();
    }
    
    public String googleCalendarHttpGet(String url) {
        return googleCalendarHttpRequest('get', url, null);
    }

    public String googleCalendarHttpPost(String url, String body) {
        return googleCalendarHttpRequest('post', url, body);
    }

    public String googleCalendarHttpPut(String url, String body) {
        return googleCalendarHttpRequest('put', url, body);
    }
    
    public String googleCalendarHttpDelete(String url, String body) {
        return googleCalendarHttpRequest('DELETE', url, body);
    }
    
    public String googleCalendarHttpRequest(String method, String url, String body) {
        if (isEmpty(serviceAccountAccessToken)) {
            info('Getting access token from Google Calendar Account...');
            serviceAccountAccessToken = getNewGoogleAccountsAccessToken();
        }
    
        return googleCalendarHttpRequest(method, url, body, serviceAccountAccessToken);
    }
    
    /**
     * Calls the main http request method with reset retry count value of 0.
     */
    public String googleCalendarHttpRequest(String method, String url, String body, String accessToken) {
        return googleCalendarHttpRequest(method, url, body, accessToken, 0);
    }
    
    /**
     * Sends a http request of requested method to specified url and with body.
     * 
     * This mehtod handles getting a new access token before making the outbound call.
     */
    public String googleCalendarHttpRequest(String method, String url, String body, String accessToken, Integer retryCount) {
        
        try {
            if (!url.startsWith('https')) {
                url = Sf.settingsService.getString('GoogleCalendarSyncBaseUrl') + url;
            }
        
            if (isEmpty(accessToken)) {
                info('Getting access token from Google Calendar Account...');
                accessToken = getNewGoogleAccountsAccessToken();
            }
            
            HttpRequest req = new HttpRequest();
            req.setMethod(method.toUpperCase());
            req.setEndpoint(url);
            req.setTimeout(getGoogleHttpTimeoutMillis());
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            
            //Google needs to specify gzip as part of the user-agent. This is little weird but it is what it is.
            //https://developers.google.com/google-apps/calendar/performance#gzip
            req.setHeader('User-Agent', 'SFDC-Callout (gzip)');
            
            if (body != null) {
                req.setBody(body);
            }
            
            HttpResponse resp = sendHttpRequest(req);
            if (resp.getStatusCode() != 200) {
                throw new UnsuccessfulHttpResponseException(req, resp);
            }
            
            String response = resp.getBody();
            
            return response;
        } catch (System.CalloutException e) {
            //If it is system callout exception, it means there was something wrong while connecting to external system.
            //We will retry configured number of times to re-run the transaction.
            if (retryCount < HTTP_MAX_RETRIES) {
                return googleCalendarHttpRequest(method, url, body, accessToken, retryCount+1);
            }
            
            throw e;

        } catch (UnsuccessfulHttpResponseException e) {
			//If we get unsuccessful http response error then someting went wrong. If we retry,
			//we will hit the same error. So we will just throw it back.            
            throw e;
        }
    }
    
    /**
     * Gets a new access token from Google Account based on the authorization information configured in the Custom Settings.
     */
    public String getNewGoogleAccountsAccessToken() {
        
        //Be careful changing anything in this method. This method does some crypto work and even if a char mismatch happens,
        //then google will reject the request.
                
        JsonWriter claim = new JsonWriter();
        Long iat = getCurrentDateTime().getTime() / 1000;
        claim.write('iss', getServiceAccountEmail());
        claim.write('scope', GOOGLE_API_OAUTH2_SCOPE);
        claim.write('aud', GOOGLE_API_OAUTH2_TOKEN_ENDPOINT);
        claim.write('iat', iat); //convert to seconds
        claim.write('exp', iat + 3000); //Valid for next 50 mins
            
        String headerJson = '{"alg":"RS256","typ":"JWT"}';
        String encodedHeader = urlSafeBase64Encode(headerJson); 
        String encodedClaim = urlSafeBase64Encode(claim.toJson());
        String signature = sign(encodedHeader, encodedClaim);
        String jwt = encodedHeader + '.' + encodedClaim + '.' + signature;

        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(GOOGLE_API_OAUTH2_TOKEN_ENDPOINT);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody('grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=' + EncodingUtil.urlEncode(jwt, 'UTF-8'));
        
        HttpResponse resp = sendHttpRequest(req);
        String accessToken = parseAccessToken(resp.getBody());
        return accessToken;
    }

    /**
     * Signs the encoded header for specified claim using the configured google account service account and returns
     * the calculated signature.
     */
    public String sign(String encodedHeader, String encodedClaim) {
        String key = Sf.settingsService.getString('GoogleCalendarSyncServiceAccountKey');
        info('The key used to sign the Google Calendar request is ' + key);
        
        Blob signature = Crypto.sign('RSA-SHA256', Blob.valueOf(encodedHeader + '.' + encodedClaim), EncodingUtil.base64Decode(key));
        return urlSafeBase64Encode(signature);
    }
    
    public String getServiceAccountEmail() {
        return Sf.settingsService.getString('GoogleCalendarSyncServiceAccountEmail');
    }
    
    public String getOAuthAccessRequestUrl() {
        Map<String, String> parms = new Map<String, String> {
            'Scope' => urlEncode(GOOGLE_API_OAUTH2_SCOPE),
            'RedirectUrl' => urlEncode(Sf.settingsService.getString('GoogleCalendarSyncOAuthCallback')),
            'ClientId' => Sf.settingsService.getString('GoogleCalendarSyncOAuthClientId')
        };
        
        String url = replaceMergeTokens(GOOGLE_API_OAUTH2_AUTH_ENDPOINT, parms);
        
        info('Returning the Google Access Request url ' + url);
        
        return url;
    }
    
    public String getOAuthAccessToken(String oauthAccessCode) {
        String body='code=' + oauthAccessCode + '&client_id=' + Sf.settingsService.getString('GoogleCalendarSyncOAuthClientId') 
            + '&client_secret=' + Sf.settingsService.getString('GoogleCalendarSyncOAuthClientSecret')  + '&redirect_uri=' + Sf.settingsService.getString('GoogleCalendarSyncOAuthCallback') 
            + '&grant_type=authorization_code';
            
        String response = httpPost(GOOGLE_API_OAUTH2_TOKEN_ENDPOINT, body, new Map<String, String> {'Content-Type' => 'application/x-www-form-urlencoded'});
        return parseAccessToken(response);
    }
    
    public String getUserPrimaryCalendarId(String userAccessToken) {
        String response = googleCalendarHttpRequest('get', '/calendars/primary', null, userAccessToken);
        String calendarId = new JsonReader(response).getString('id');
        
        info('Returning the primary calendar id ' + calendarId);
        
        return calendarId;
    }

    public String parseAccessToken(String response) {
        if (response.indexOf('access_token') >= 0) {
            String accessToken = new JsonReader(response).getString('access_token');
            info('Received access token from Google: ' + accessToken);
            return accessToken;
        }
        
        throw new SystemException('Error while getting access token from Google. [' + response + ']'); 
    }
    
    public void grantAccessToCalendar(String accessToken, String calendarId) {
        String requestBody = '{"role": "owner", "scope": {"type": "user",  "value": "' + getServiceAccountEmail() + '"}}';
        
        //If successfull (200), then nothing else to be done.
        googleCalendarHttpRequest('post', '/calendars/' + calendarId + '/acl', requestBody, accessToken);
    }
    
    public Integer getGoogleHttpTimeoutMillis() {
        return Sf.settingsService.getInteger('GoogleCalendarHttpTimeoutSecs', 10) * 1000;
    }
    
    public String getGoogleEvent(String googleEventId) {
        //Findout the Salesforce event for this google event id. For that salesorce event, get user details
        //and that user and get the info from that calendar id.
        List<Event> events = [select Id, OwnerId, Google_Calendar_Event_Id__c from Event where Google_Calendar_Event_Id__c = :googleEventId];
        if (events.isEmpty()) {
            events = [select Id, OwnerId, Google_Calendar_Event_Id__c from Event where id = :googleEventId];
        }
        
        if (events.isEmpty()) {
            throw new BusinessException('Could not find a Salesforce event corresponding to Salesforce Event Id or Google Calendar Event Id ' + googleEventId);
        }
        
        Event event = events.get(0);
        if (isEmpty(event.Google_Calendar_Event_Id__c)) {
            throw new BusinessException('Salesforce event corresponding to event id [' + googleEventId +'] is not associated with a Google Event Id');
        }

        User user = [select Id, Name, Google_Calendar_Id__c from User where id = :events.get(0).OwnerId];
        if (user.Google_Calendar_Id__c == null) {
            throw new BusinessException('User ' + user.name 
                + ' doesn\'t have the Calendar Id populated to retrieve the details for Google Event ' + event.Google_Calendar_Event_Id__c);
        }
        
        String response = googleCalendarHttpGet('/calendars/' + user.Google_Calendar_Id__c + '/events/' + event.Google_Calendar_Event_Id__c);
        
        return response;
    }
    
    /**
     * Compares the applicable fields to findout if event needs to be synced to Google. Returns true if event needs to be
     * synced to google else, false.
     */ 
    public Boolean isEventUpdated(Event eventOld, Event eventNew) {
       return isChanged(eventOld.Subject, eventNew.subject) 
           || isChanged(eventOld.StartDateTime, eventNew.StartDateTime) 
           || isChanged(eventOld.EndDateTime, eventNew.EndDateTime) 
           || isChanged(eventOld.Description, eventNew.Description) 
           || isChanged(eventOld.IsAllDayEvent, eventNew.IsAllDayEvent);
    }
    
    public List<Event> queryEvents(User user, GoogleCalendarDto.ListEventsResponse listResponse ) {
        Set<String> eventExternalids = new Set<String>();
        Set<String> eventIds = new Set<String>();
        for (GoogleCalendarDto.Event gevent : listResponse.events) {
            eventExternalIds.add(gevent.gcalEventId);
            eventExternalIds.add(gevent.gcalRecurringEventId);
            
            if (gevent.salesforceEventId != null) {
                eventIds.add(gevent.salesforceEventId);
            }
        }
        
        return queryEvents(user.id, new List<String>(eventIds), new List<String>(eventExternalIds));
    }

    public void deleteGoogleEvent(User user, String googleEventId, SyncJobInfo syncJob) {
        if (googleEventId != null) {
            try {
                String url = '/calendars/' + user.Google_Calendar_Id__c + '/events/' + googleEventId;
            	syncJob.log('Sending Http Request POST to ' + url + ' with no body');
	        	googleCalendarHttpDelete(url, null);
            } catch (UnsuccessfulHttpResponseException e) {
                if (e.isStatusCode(410) || e.isStatusCode(404) || (e.getStatusCode() >= 200 && e.getStatusCode() <= 299)) {
	            	syncJob.log('Received ' + e.getStatusCode() + ' http status, which we treat as success for delete event. ' + e.toString());
                    
                } else if (e.isResponseContains('Cannot modify requested event')) {
                    //Sometimes google events are marked as identified as non-updatable. If we try to update
                    //them google will return error indicating they cannot be updated. If so, we will just
                    //mark the sync as success.
                    syncJob.log('Received error indicating this event cannot be updated. So we will mark as Sync Not Applicable and move on. ' + e.toString());
                    syncJob.syncNotApplicable('Non Modifiable Google Event');
                    return;
                } else {
                    throw e;
                }
            }
            syncJob.syncSuccess();
        } else {
            syncJob.syncNotApplicable('Google Event Id Not Specified');
        }
    }

    public boolean isSyncCalendar(User user, SyncJobInfo syncJob) {
        
        if (!user.IsActive) {
            syncJob.log('User ' + user + ' is not active and hence not not syncing');
            syncJob.syncFailed('User Not Active');
            return false;
        }

        if (!user.Google_Calendar_Sync_Enabled__c) {
            syncJob.log('Google Calendar sync is not enabled for user ' + user + ' and hence not syncing');
            syncJob.syncFailed('Calendar Sync Not Enabled for User');
            return false;
        }
        
        if (isEmpty(user.Google_Calendar_Id__c)) {
            syncJob.log('Google Calendar sync is enabled for user ' + user + ' but Google calendar id is not populated in User.Google_Calendar_Id__c and hence not syncing');
            syncJob.syncFailed('Invalid Calendar Id');
            return false;
        }

        return true;
    }

    public GoogleCalendarDto.ListEventsResponse listGoogleEvents(String calendarId, 
			String syncToken, String pageToken, GoogleCalendarDto.ListEventsResponse resp, Integer syncFromDays, Integer syncToDays, SyncJobInfo syncJob) {
        
        if (resp == null) {
            resp = new GoogleCalendarDto.ListEventsResponse();
        }
        
        String url = '/calendars/' + calendarId + '/events?singleEvents=true&showDeleted=true&fields=nextSyncToken,nextPageToken,' 
                + 'items(id,status,recurringEventId,summary,description,locked,transparency,creator/*,start/*,end/*,sequence,extendedProperties/*)&maxResults='
                + GoogleCalendarListEventsMaxSize;
        
        if (isNotEmpty(pageToken)) {
            url += '&pageToken=' + urlEncode(pageToken);
            
        } else if (isNotEmpty(syncToken)) {
            url += '&syncToken=' + urlEncode(syncToken);
        
        } else {
            //Window of specified number of days.
            url += '&timeMin=' + formatAsUtcIsoDateTime(getCurrentDateTime().addDays(-syncFromDays));
            url += '&timeMax=' + formatAsUtcIsoDateTime(getCurrentDateTime().addDays(syncToDays));
            resp.fullSync = true;
        }
        
        try {
            syncJob.log('Retrieving Google events using url ' + url);
            
            String response = googleCalendarHttpGet(url);
            syncJob.log('Received List Events response ' + response);
            
            JsonReader jsonReader = new JsonReader(response);
            response = null; //to save memory
            
            syncJob.log('Response contains ' + jsonReader.getList('items').size() + ' events');
            
            for (Object obj : jsonReader.getList('items')) {
                try {
                    JsonReader item = new JsonReader(obj);
                    
                    GoogleCalendarDto.Event event = new GoogleCalendarDto.Event();
                    event.locked = item.getBoolean('locked');
                    event.transparency = item.getString('transparency');
                    event.gcalEventId = item.getString('id');
                    event.status = item.getString('status');
                    event.gcalRecurringEventId = item.getString('recurringEventId');
                    event.createdInGoogle = emptyIfNull(item.getString('creator.email')).indexOf(NotCreatedInGoogleCheckString) < 0;
                    event.salesforceEventId = item.getString('extendedProperties.private.salesforceEventId');
                    
                    if (!equalsIc(event.status, 'cancelled')) {
                        //Summary limit is 255 and description is 32k
                        //from https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_objects_event.htm
                        event.summary = item.getString('summary');
                        if (event.summary != null && event.summary.length() > 255){
                            event.summary = trim(event.summary, 255);
                            syncJob.log('The event summary is more than 255 chars and hence truncating it ' + item);
                        }
                        event.description = trim(item.getString('description'), 32000);
                        
                        String startDateTime = item.getString('start.dateTime');
                        String endDateTime = item.getString('end.dateTime');
                        
                        if (isEmpty(startDateTime)) {
                            //This is all day event so look for Date and set all day = true
                            startDateTime = item.getString('start.date') + 'T00:00:00.000Z';
                            endDateTime = item.getString('end.date') + 'T00:00:00.000Z';
                            event.IsAllDayEvent  = true;
                        } else {
                            event.IsAllDayEvent  = false;
                        }
                        
                        event.startTime = parseAsUtcIsoDateTime(startDateTime);
                        event.endTime = parseAsUtcIsoDateTime(endDateTime);
                        if (event.IsAllDayEvent) {
                            //Google end date is exclusive so it will send one additional days for end time. If it is non-allday event, 
                            //then it is just a second of additional time but if it is all day, it will be a day so we will appropriately
                            //reduce it.
                            event.endTime = event.endTime.addDays(-1);
                        }
                        event.sequence = item.getInteger('sequence');
                    }
                    
                    //If google event is longer than 14 days, then we are not synching that to Salesforce.
                    Integer eventDurationDays = diffInDays(event.startTime, event.endTime);
                    if (eventDurationDays > 13) {
                        syncJob.log('Google events longer than 14 days are not sycned. Hence ignoring ' + event + ' which is ' + eventDurationDays + ' days long.');
                    } else {
                        resp.addEvent(event);
                    }
                    
                } catch (Exception e) {
                    throw new SystemException('Exception while processing google event ' + obj, e);
                }
            }
            
            //Check if there is nextPageToken. If yes, then there are no events we need to retrieve.
            String nextPageToken = jsonReader.getString('nextPageToken');
            if (isNotEmpty(nextPageToken)) {
                //Recursively call the same method to continue to retrieve the events.
                info('Google returned next page token [' + nextPageToken + '] so retrieving the next page of events.');
                resp = listGoogleEvents(calendarId, null, nextPageToken, resp, syncFromDays, syncToDays, syncJob);
            } else {
                //If there is no nextPageToken, there must be nextSyncToken which we need to store in the user object
                //and use it next time we want to incrementally sync the events.
                resp.syncToken = jsonReader.getString('nextSyncToken');
            }
            
        } catch (UnsuccessfulHttpResponseException e) {
            
            //410 means sync token is invalid and we need to do full sync.
            if (e.isStatusCode(410)) {
                resp = listGoogleEvents(calendarId, null, null, null, syncFromDays, syncToDays, syncJob);
            } else {
                throw e;
            }
        }

        return resp;
    }
    
    public boolean copyGoogleEventToSalesforceEvent(GoogleCalendarDto.Event gevent, Event sevent) {
        
        boolean changed = false;
        if (isChanged(gevent.gcalEventId, sevent.Google_Calendar_Event_Id__c)) {
            changed = true;
            sevent.Google_Calendar_Event_Id__c = gevent.gcalEventId;
        }
    
        if (isChanged(gevent.summary, sevent.subject)) {
            changed = true;
            sevent.subject = gevent.summary;
        }

        if (isChanged(gevent.description, sevent.description)) {
            changed = true;
            sevent.description = gevent.description;
        }

        if (isChanged(gevent.startTime, sevent.startDateTime)) {
            changed = true;
            sevent.startDateTime = gevent.startTime;
        }

        if (isChanged(gevent.endTime, sevent.endDateTime)) {
            changed = true;
            sevent.endDateTime= gevent.endTime;
        }

        if (isChanged(gevent.isAllDayEvent, sevent.isAllDayEvent)) {
            changed = true;
            sevent.isAllDayEvent= gevent.isAllDayEvent;
        }

        if (isChanged(gevent.sequence, sevent.Google_Calendar_Event_Sequence_Num__c)) {
            changed = true;
            sevent.Google_Calendar_Event_Sequence_Num__c= gevent.sequence;
        }
        
        if (isChanged(gevent.gcalRecurringEventId, sevent.Google_Calendar_Recurring_Event_Id__c)) {
            changed = true;
            sevent.Google_Calendar_Recurring_Event_Id__c= gevent.gcalRecurringEventId;
        }

        if (isChanged(gevent.createdInGoogle, sevent.Google_Calendar_Created_In_Google__c)) {
            changed = true;
            sevent.Google_Calendar_Created_In_Google__c = gevent.createdInGoogle;
        }
        
        return changed ;
    }

    public Boolean isGoogleToSfdcFullSyncAlways() {
        return Sf.settingsService.getBoolean('GoogleCalendarGoogleFullSyncAlways', false);
    }
    
    public String getSyncToken(User user, SyncJobInfo syncJob) {
        
        //If we have full sync enabled all the time, return null.
        Boolean fullSync = isGoogleToSfdcFullSyncAlways();
        if (fullSync) {
            syncJob.log('Google Full Sync Always is enabled in settings and hence returning null token');
            return null;
        }
    
        //Else if syncjob has any record with full sync enabled
        for (Sync_Record__c syncRecord : syncJob.syncRecordsBatch) {
            if (syncRecord.Sub_Type__c == 'Full Sync') {
                fullSync = true;
            }
        }
        
        if (fullSync) {
            syncJob.log('One of the sync records for this user is marked as full sync and hence returning null token');
            return null;
        }
    
        syncJob.log('Returning sync token ' + user.Google_Calendar_Sync_Token__c);
        return user.Google_Calendar_Sync_Token__c;
    }
}