public class SobjectAuditViewerController extends BaseClass {
	
    public List<AuditServiceDto.SobjectAudit> sobjectAudits {get;set;}
    public String objectName {get;set;}
    public String recordName {get;set;}
    
    public SObjectAuditViewerController() {
        try {
            String recordId = getRequiredParameter('id');
            sobjectAudits = Sf.auditService.getSobjectAuditHistory(recordId);
            objectName = getSobjectName(recordId);
            recordName = getRecordName(recordId);
        } catch (Exception e) {
            addErrorMessage(e);
        }
    }
}