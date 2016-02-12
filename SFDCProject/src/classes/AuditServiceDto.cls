public class AuditServiceDto {
    public class SobjectAudit {
        public SObject_Audit__c auditRecord {get;set;}
        public List<FieldAudit> fieldAudits {get;set;}
        
        public SobjectAudit() {
            fieldAudits = new List<FieldAudit>();
        }
    }
    
    public class FieldAudit implements Comparable {
        public String name {get;set;}
        public String label {get;set;}
        public String oldValue {get;set;}
        public String newValue {get;set;}
        public String oldId {get;set;}
        public String newId {get;set;}
        
        public FieldAudit (String name, String oldId, String oldValue, String newId, String newValue) {
        	this(name, null, oldId, oldValue, newId, newValue);
        }

        public FieldAudit (String name, String label, String oldId, String oldValue, String newId, String newValue) {
            this.name = name;
            this.oldId = oldId;
            
            if (oldvalue != null && oldvalue.length() >= 255) {
                oldvalue = oldvalue.substring(0, 252) + '...';
            }
            
            this.oldvalue = oldvalue;

            this.newId = newId;
            if (newvalue != null && newvalue.length() >= 255) {
                newvalue = newvalue.substring(0, 252) + '...';
            }
            this.newValue = newValue;
            this.label = label;
        }
        
        public Integer compareTo(Object o2) {
            return label.compareTo(((FieldAudit) o2).label);
        }
        
        public String getNewReferenceDisplayValue() {
            return String.isBlank(newValue)?newId:newValue;
        }
        public String getOldReferenceDisplayValue() {
            return String.isBlank(oldValue)?oldId:oldValue;
        }
    }
}