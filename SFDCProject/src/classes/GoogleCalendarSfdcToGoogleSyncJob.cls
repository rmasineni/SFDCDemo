public class GoogleCalendarSfdcToGoogleSyncJob extends BaseSyncJob implements CommonBatchable {
	
    public GoogleCalendarSfdcToGoogleSyncJob () {
		super(GoogleCalendarDto.SyncModule, GoogleCalendarDto.SfdcToGoogleSync, 
              GoogleCalendarDto.SfdcToGoogleSyncJob,
             Sf.settingsService.getInteger('GoogleCalendarSfdcToGoogleSyncJobLimit', 100));
        
        //This ensures that this job is marked for run after previous run. However, if there are
        //no job to run, then that chain will not be broken and job will not run untill
        //it is scheduled or marked for run.
        runJobAgain = true;
    }

    override public void execute(SyncJobInfo syncJob) {
        Sf.googleCalendarService.syncSfdcToGoogle(syncJob);
    }
}