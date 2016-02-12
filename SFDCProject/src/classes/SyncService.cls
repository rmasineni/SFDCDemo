public interface SyncService {
    List<Sync_Record__c> insertSyncRecords(String module, String action, String type, List<Sobject> sobjs, String externalIdField);
    List<Sync_Record__c> insertSyncRecords(String module, String action, List<Sobject> sobjs, String externalIdField);
    List<Sync_Record__c> insertSyncRecords(String module, String action, List<Sobject> sobjs);

    List<Sync_Record__c> createSyncRecords(String module, String action, String type, List<Sobject> sobjs, String externalIdField);
    List<Sync_Record__c> createSyncRecords(String module, String action, List<Sobject> sobjs, String externalIdField);
    List<Sync_Record__c> createSyncRecords(String module, String action, List<Sobject> sobjs);
    List<Sync_Record__c> insertSyncRecords(List<Sync_Record__c> syncRecords);
}