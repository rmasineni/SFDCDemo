public class GoogleCalendarGoogleToSfdcSyncJob extends BaseSyncJob implements CommonBatchable {
	
    public GoogleCalendarGoogleToSfdcSyncJob () {
		super(GoogleCalendarDto.SyncModule, 
              GoogleCalendarDto.GoogleToSfdcSync, GoogleCalendarDto.GoogleToSfdcSyncJob,
             Sf.settingsService.getInteger('GoogleCalendarGoogleToSfdcSyncJobLimit', 100));
        
        //This ensures that when we create batches, all sync records for a user is grouped together
        groupBatchesBySourceRecords = true;
        
        //This ensures that this job is marked for run after previous run. However, if there are
        //no job to run, then that chain will not be broken and job will not run untill
        //it is scheduled or marked for run.
        runJobAgain = true;
    }

    override public void execute(SyncJobInfo syncJob) {
        Sf.googleCalendarService.syncGoogleToSfdc(syncJob);
    }
}