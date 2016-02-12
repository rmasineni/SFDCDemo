public without sharing class AuditServiceImpl extends BaseClass implements AuditService {
    
    /**
     * This indicates maximum number of field changes that can be stored in a audit record. If there are more than this number of changes
     * in a sobject, then multiple audit record are created. We cannot just increase this number but should actually
     * create those additional fields in Sobject_Audit__c object for OldId, oldValue, newId and newValue
     */ 
    public static Integer MaxAuditFields = 100;
   	public static Map<String, Map<String, Schema.SObjectField>> FieldsDescribeMap = new Map<String, Map<String, Schema.SObjectField>>();
   	public static Map<String, Map<String, String>> FieldsRefTypeMap = new Map<String, Map<String, String>>();
        
    public List<AuditServiceDto.SobjectAudit> getSobjectAuditHistory(Id recordId) {
        List<AuditServiceDto.SobjectAudit> sobjectAudits = new List<AuditServiceDto.SobjectAudit>();
        
        //Get the list of fields for sobject.
        Schema.DescribeSObjectResult sobjDescribe = recordId.getSobjectType().getDescribe();
        Map<String, Schema.SObjectField> fields = sobjDescribe.Fields.getMap();
        
        String soql = 'select Id, Name, Sobject_Name__c, Action__c, Record_Id__c, Record_Name__c, OwnerId, Owner.Name, CreatedDate';
        for (Integer i = 1; i <= MaxAuditFields; i++) {
            soql += ', Field' + i + '__c, Old_Id' + i + '__c, Old_Value' + i + '__c, New_Id' + i + '__c, New_Value' + i + '__c';
        }
        soql += ' from Sobject_Audit__c where Record_Id__c = :recordId order by CreatedDate desc';
        
        List<Sobject_Audit__c> audits = Database.query(soql);
        for (Sobject_Audit__c audit : audits) {
            AuditServiceDto.SobjectAudit record = new AuditServiceDto.SobjectAudit();
            record.auditRecord = audit;         
            
            for (Integer i = 1; i <= MaxAuditFields; i++) {
                String fieldName = (String) audit.get('Field' + i + '__c');
                if (fieldName == null) {
                    continue;
                }
                
                record.fieldAudits.add(new AuditServiceDto.FieldAudit(
                    fieldName, fields.get(fieldName).getDescribe().getLabel(), 
	                    (String) audit.get('Old_Id' + i + '__c'),
                    	(String) audit.get('Old_Value' + i + '__c'), 
	                    (String) audit.get('New_Id' + i + '__c'),
                    	(String) audit.get('New_Value' + i + '__c')));
            }

            record.fieldAudits.sort();
            
            sobjectAudits.add(record);
        }
        
        return sobjectAudits;
    }
    
    public void captureAudit(List<SObject> oldSobjs, List<SObject> newSobjs) {
        captureSobjectAudit(oldSobjs, newSobjs);
    }
    
    public void captureSobjectAudit(List<SObject> oldSobjs, List<SObject> newSobjs) {
        
        Stopwatch sw = new Stopwatch();
        
        //By default audit capture is disabled. It needs to be explicitly enabled.
        if (!Sf.settingsService.getBoolean('SobjectAuditCaptureEnabled', false)) {
            info('SObject audit capture is disabled in settings SobjectAuditEnabled and hence not capturing any audit.');
            return;
        }
        
        if (oldSobjs == null && newSobjs == null) {
            info('Both old and new sobjects are null and hence not capturing any audit');
            return;
        }
        
        //Get the list of fields for sobject.
        Schema.DescribeSObjectResult sobjDescribe = (oldSobjs!=null?oldSobjs:newSobjs).get(0).Id.getSobjectType().getDescribe();
        String sobjName = sobjDescribe.getName();
        
        //We will try to initialize from the static map so if this described earlier, it will be reused. If not already
        //initialized, then will describe and cache it in the map.
        //
        //We will do this optimization only while capturing the audit but not while querying as it will
        //always be one object.
        Map<String, Schema.SObjectField> fields = FieldsDescribeMap.get(sobjName);
        Map<String, String> refTypeFields = FieldsRefTypeMap.get(sobjName);
        if (fields == null || refTypeFields == null) {
            fields = sobjDescribe.Fields.getMap();
            FieldsDescribeMap.put(sobjName, fields);
            
            refTypeFields = new Map<String, String>();

            //We also need to identify if a particular field is a refernece field. and cache the result.
            for (String fieldName : fields.keySet()) {
                if (isFieldIdOrRefType(fields.get(fieldName))) {
                    refTypeFields.put(fieldName, fieldName);
                }
            }
            
            FieldsRefTypeMap.put(sobjName, refTypeFields);
        }
        
        //By default audit capture for individual object is enabled. It can be disabled if required.
        if (!Sf.settingsService.getBoolean('Audit_' + sobjName, true)) {
            info('SObject audit capture is disabled in settings SobjectAuditEnabled and hence not capturing any audit.');
            return;
        }

        DbChanges dbChanges = new DbChangesWoSharing();
        Integer recordsCount = 0;
        
        if (oldSobjs == null) {
            //Insert operation.
            for (Sobject newSobj : newSobjs) {
                dbChanges.addInsert(createAuditRecords('Insert', newSobj, sobjDescribe, calculateFieldAudits(null, newSobj, fields, refTypeFields)));
            }
            recordsCount = newSobjs.size();
            
        } else if (newSobjs == null) {
            //Delete operaiton
            for (Sobject oldSobj : oldSobjs) {
                dbChanges.addInsert(createAuditRecords('Delete', oldSobj, sobjDescribe, calculateFieldAudits(oldSobj, null, fields, refTypeFields)));
            }       
            recordsCount = oldSobjs.size();
            
        } else  {
            //Update operation
            if (oldSobjs.size() != newSobjs.size()) {
                info('Old sobjects size [' + oldSobjs.size() + '] is not equals to new sobjects size [' + newsobjs.size() + '] and hence not capturing any audit');
                return;
            }

            for (Integer i = 0; i < newSobjs.size(); i++) {
                Sobject oldSobj = oldSobjs.get(i);
                Sobject newSobj = newSobjs.get(i);
                
                dbChanges.addInsert(createAuditRecords('Update', newSobj, sobjDescribe, calculateFieldAudits(oldSobj, newSobj, fields, refTypeFields)));
            }
            
            recordsCount = newSobjs.size();
        }
        
        if (System.isBatch() || System.isFuture()) {
            populateRecordNames(new List<SObject>(dbChanges.inserts));
	        dbChanges.save();
        } else {
	        dbChanges.save();
            //Hand off populating the Record names from ids into queue job.
            System.enqueueJob(new RecordNamePopulatingJob(new List<Sobject>(dbChanges.inserts)));
        }
        
        info('Completed the audit capture for ' + recordsCount + ' ' + sobjName + ' records in ' + sw.elapsedTime() + ' ms');
    }
    
    public List<Sobject_Audit__c> createAuditRecords(String actionType, SObject sobj, Schema.DescribeSObjectResult sobjDescribe, List<AuditServiceDto.FieldAudit> fieldChanges) {
        List<SObject_Audit__c> audits = new List<SObject_Audit__c>();
        Integer index = 0;
        SObject_Audit__c audit = null;
        for (AuditServiceDto.FieldAudit fieldChange : fieldChanges) {
            if (index == 0 || index > MaxAuditFields) {
                index = 1;
                if (audit != null) {
                    audits.add(audit);
                }

                audit = new SObject_Audit__c();
                audit.Action__c = actionType;
                audit.Status__c = 'Not Processed';
                audit.Sobject_Name__c = sobjDescribe.getName();
                audit.Record_Id__c = sobj.id;
                audit.Record_Name__c = (String) sobj.get('Name');
            }
            
            audit.put('Field' + index + '__c', fieldChange.name);
            audit.put('Old_Id' + index + '__c', fieldChange.oldId);
            audit.put('Old_Value' + index + '__c', fieldChange.oldValue);
            audit.put('New_Id' + index + '__c', fieldChange.newId);
            audit.put('New_Value' + index + '__c', fieldChange.newValue);
            
            index++;
        }
        
        if (audit != null) {
            audits.add(audit);
        }
        
        return audits;
    }
    
    /**
     * For given old and new record, this method goes through all of its fields and calculates the field updates, if they are updated.
     */
    public List<AuditServiceDto.FieldAudit> calculateFieldAudits(Sobject oldSobj, Sobject newSobj, Map<String, Schema.SObjectField> fields, Map<String, String> refTypeFields) {
        List<AuditServiceDto.FieldAudit> fieldChanges = new List<AuditServiceDto.FieldAudit>();
        
        for (String fieldName : fields.keyset()) {
            
            if (isFieldIgnored(fieldName)) {
                continue;
            }

     		String oldId, newId, oldValue, newValue;
            
            if (oldSobj == null) {
                if (newSobj.get(fieldName) != null) {
                    if (refTypeFields.get(fieldName) == null) {
                        newValue = convertToString(newSobj.get(fieldName));
                    } else {
                        newId = convertToString(newSobj.get(fieldName));
                    }
                }
            } else if (newSobj == null) {
                if (oldSobj.get(fieldName) != null) {
                    if (refTypeFields.get(fieldName) == null) {
                        oldValue = convertToString(oldSobj.get(fieldName));
                    } else {
                        oldId = convertToString(oldSobj.get(fieldName));
                    }
                }
            } else {
                if (isChanged(oldSobj.get(fieldName), newSobj.get(fieldName))) {
                    if (refTypeFields.get(fieldName) == null) {
                        oldValue = convertToString(oldSobj.get(fieldName));
                        newValue = convertToString(newSobj.get(fieldName));
                    } else {
                        oldId = convertToString(oldSobj.get(fieldName));
                        newId = convertToString(newSobj.get(fieldName));
                    }
                }
            }

            if (oldId != null || oldValue != null || newId != null || newValue != null) {
                AuditServiceDto.FieldAudit fieldAudit = new AuditServiceDto.FieldAudit(fieldName, oldId, oldValue, newId, newValue);
                
                info('Created field audit ' + fieldAudit);
	            fieldChanges.add(fieldAudit);
            }
        }        
        return fieldChanges;
    }
    
    public String convertToString(Object value) {
        return value==null?null:String.valueOf(value);
    }
    
    /**
     * We ignore the changes to certain "system" fields to reduce the clutter.
     */
    public Boolean isFieldIgnored(String fieldName) {
        return fieldName == 'systemmodstamp'
            || fieldName == 'lastmodifieddate'
            || fieldName == 'createddate'
            || fieldName == 'lastmodifiedbyid'
            || fieldName == 'createdbyid'
        ;
    }
    
    public void populateRecordNames(List<Sobject> sobjectCaptures) {
        //It is expected that all audit capture records belongs to same object.
        //so we will develop according to that.
        
        //1. Go through all audit records and its fields and collect all Reference ids grouped by its types.
        //2. Query the names for each of the object at a time and build new Id to Name map. 
        //3. Loop through each of the audit records/fields one more time, filling in the name value.
        BaseClass.MultiStringMap multiMap = new BaseClass.MultiStringMap(true);
        
        for (Sobject sobj : sobjectCaptures) {
            for (Integer index = 1; index <= MaxAuditFields; index++) {
                Id fieldId = (Id) sobj.get('Old_Id' + index +'__c');
                if (fieldId != null) {
                    multiMap.put(getSobjectName(fieldId), fieldId);
                }
                
                fieldId = (Id) sobj.get('New_Id' + index +'__c');
                if (fieldId != null) {
                    multiMap.put(getSobjectName(fieldId), fieldId);
                }
            }
        }
        
        //Now we have a list of objects and their corresponding ids. Let's query the object.
        Map<Id, String> idToNameMap = new Map<Id, String>();
        
        for (String sobjName : multiMap.keyset()) {
            
            List<String> sobjIds = multimap.get(sobjName);
            
            //
            List<Sobject> sobjs = Database.query('Select Id, Name from ' + sobjName + ' where id in :sobjIds ALL ROWS');
            
            for (Sobject sobj : sobjs) {
                idToNameMap.put(sobj.id, (String) sobj.get('Name'));
            }
        }
        
        //Now we will go over the audit capture records again and fill in the record names.
        for (Sobject sobj : sobjectCaptures) {
            for (Integer index = 1; index <= MaxAuditFields; index++) {
                Id fieldId = (Id) sobj.get('Old_Id' + index +'__c');
                if (fieldId != null && idToNameMap.get(fieldId) != null) {
                    sobj.put('Old_Value' + index +'__c', idToNameMap.get(fieldId));
                }
                
                fieldId = (Id) sobj.get('New_Id' + index +'__c');
                if (fieldId != null && idToNameMap.get(fieldId) != null) {
                    sobj.put('New_Value' + index +'__c', idToNameMap.get(fieldId));
                }
            }
            
            sobj.put('Status__c', 'Processed');
        }
        
    }
    
    /**
     * This job reads the record names from given ids and populates the values.
     */
    public class RecordNamePopulatingJob implements Queueable {
        public List<Sobject> sobjectCaptures = null;
        private BaseClass utils = new BaseClass();
        
        public RecordNamePopulatingJob(List<Sobject> sobjectCaptures) {
            this.sobjectCaptures = sobjectCaptures;
        }
        
		public void execute(QueueableContext context) {
			new AuditServiceImpl().populateRecordNames(sobjectCaptures);
	        update sobjectCaptures;
        }
    }
}