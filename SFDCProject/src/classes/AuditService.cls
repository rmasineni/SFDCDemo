public interface AuditService {
    List<AuditServiceDto.SobjectAudit> getSobjectAuditHistory(Id recordId);
	void captureSobjectAudit(List<SObject> oldSobjs, List<SObject> newSobjs);
}