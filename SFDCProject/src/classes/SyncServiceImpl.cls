public class SyncServiceImpl extends BaseClass implements SyncService {

    public List<Sync_Record__c> createSyncRecords(String module, String action, List<Sobject> sobjs) {
        return createSyncRecords(module, action, null, sobjs, null);
    }
    
    public List<Sync_Record__c> createSyncRecords(String module, String action, List<Sobject> sobjs, String externalIdField) {
        return createSyncRecords(module, action, null, sobjs, externalIdField);
    }
    
    public List<Sync_Record__c> createSyncRecords(String module, String action, String type, List<Sobject> sobjs, String externalIdField) {
        if (type == null && Trigger.isExecuting) {
            if (Trigger.isInsert) {
                type = 'Insert';
            } else if (Trigger.isUpdate) {
                type = 'Update';
            } else {
                type = 'Delete';
            }
        }
       
        List<Sync_Record__c> syncRecords = new List<Sync_Record__c>();
        for (Sobject sobj : sobjs) {
            Sync_Record__c syncRecord = new Sync_Record__c(
                Sobject__c=getSobjectName(sobj.id),
                Record_Id__c = sobj.id,
                Module__c = module,
                Action__c = action,
                Type__c = type,
                Status__c = Status_ToBeSynced,
                Attempts__c = 0
            );
			
			syncRecord.OwnerId = getOwnerId(sobj);            
            
            if (externalIdField != null) {
                Object value = sobj.get(externalIdField);
                if (value != null) {
	                syncRecord.External_Id__c = String.valueOf(value);
                }
            }
            
            syncRecords.add(syncRecord);
        }
        
        info('Created sync records ' + syncRecords + ' for sobjects ' + sobjs);
        return syncRecords;
    }
    
    public Id getOwnerId(Sobject sobj) {
        Id ownerId = null;
        try {
            if (getSobjectName(sobj) == 'User') {
                ownerId = sobj.id;
            } else {
                ownerId = (Id) sobj.get('OwnerId');
            }
        } catch (Exception e) {
            info('Exception while getting the Owner id for sobject ' + sobj + ' ' + e.getMessage());
        }
        
        if (ownerId == null) {
            ownerId = UserInfo.getUserId();
        }
        
        return ownerId;
    }

    public List<Sync_Record__c> insertSyncRecords(String module, String action, List<Sobject> sobjs) {
        return insertSyncRecords(module, action, null, sobjs, null);
    }
    
    public List<Sync_Record__c> insertSyncRecords(String module, String action, List<Sobject> sobjs, String externalIdField) {
        return insertSyncRecords(module, action, null, sobjs, externalIdField);
    }

    public List<Sync_Record__c> insertSyncRecords(String module, String action, String type, List<Sobject> sobjs, String externalIdField) {
        return insertSyncRecords(createSyncRecords(module, action, type, sobjs, externalIdField));
    }

    public List<Sync_Record__c> insertSyncRecords(List<Sync_Record__c> syncRecords) {
        new DbChangesWoSharing().add(syncRecords).save();
        info('Inserted sync records ' + syncRecords);
        return syncRecords;
    }
}