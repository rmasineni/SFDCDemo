public interface CoreLogicService {
    void processJob(SyncJobInfo syncJob);
    void handleAccountsTrigger();
}