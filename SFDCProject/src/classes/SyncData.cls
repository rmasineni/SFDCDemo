public class SyncData {
    public String type {get;set;}
    public Map<Id, Sync_Data__c> syncDataMap = new Map<Id, Sync_Data__c>();
    public Id defaultRecordId {get;set;}
    public Map<Id, JsonReader> jsonReaders = new Map<Id, JsonReader>();
    
    public String getString(String key) {
        return getJsonReader().getString(key);
    }
    
    public SyncData setSyncData(List<Sync_Data__c> syncDataRecords) {
        syncDataMap = new Map<Id, Sync_Data__c>();
        for (Sync_Data__c syncData : syncDataRecords) {
            syncDataMap.put((Id) syncData.Record_Id__c, syncData);
        }
        return this;
    }
    
    public List<Sync_Data__c> getSyncData() {
        return syncDataMap.values();
    }

    public SyncData setString(String key, String value) {
        getJsonReader().setString(key, value);
        return this;
    }

    public JsonReader getJsonReader() {
        JsonReader jr = jsonReaders.get(defaultRecordId);
        if (jr == null) {
            jr = new JsonReader('');
            jsonReaders.put(defaultRecordId, jr);
        }
        
        return jr;
    }
    
    public SyncData setRecord(Id recordId) {
        this.defaultRecordId = recordId;
        return this;
    }
}