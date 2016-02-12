public class CoreLogicJob extends BaseSyncJob {
    
    public CoreLogicJob() {
        super(CoreLogicServiceDto.SyncModule, CoreLogicServiceDto.SyncAction);
    }
        
    override public void execute(SyncJobInfo syncJob) {
        Sf.coreLogicService.processJob(syncJob);
    }
}