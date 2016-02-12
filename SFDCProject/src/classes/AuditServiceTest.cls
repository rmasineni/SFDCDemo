@IsTest
public class AuditServiceTest {
	
    static BaseClass utils = new BaseClass();
    
    testmethod public static void testSobjectAuditCaptureAndQuery() {
        
        Account a1 = new Account(Name='Foo Account');
        insert a1;

        Account a2 = new Account(Name='Foo Account');
        insert a2;

        Contact c1 = new Contact(FirstName='Foo',LastName='Bar', AccountId=a1.id);
        insert c1;

        insert new Settings__c(Name='SobjectAuditCaptureEnabled', Value1__c='true');
        
		Sf.auditService.captureSobjectAudit(null, null);

        //Insert capture
        Sf.auditService.captureSobjectAudit(null, new List<Sobject>{c1});
        Contact c2 = utils.queryContact(c1.id);
        c2.FirstName = 'Bob';
        c2.LastName = 'Alice';
		c2.AccountId = a2.id;
		
		Test.startTest();
        
        //Update capture
        Sf.auditService.captureSobjectAudit(new List<Sobject>{c1}, new List<Sobject>{c2});
        
        //If we send different old and new object, is should ignore the request.
        Sf.auditService.captureSobjectAudit(new List<Sobject>{c1}, new List<Sobject>{c1, c2});
		
        //Delete capture
		Sf.auditService.captureSobjectAudit(new List<Sobject>{c2}, null);
        
        //query the data and check that there must be three records
        Test.setCurrentPage(Page.SobjectAuditViewer);
		ApexPages.currentPage().getParameters().put('id', c1.id);
		
		Test.stopTest();        
        SobjectAuditViewerController controller = new SobjectAuditViewerController();
        
        System.debug('Sobject Audits are ' + controller.sobjectAudits);
        System.assertEquals(3, controller.sobjectAudits.size());
    }
    
    testmethod public static void testDisableAudit() {
        insert new Settings__c(Name='SobjectAuditCaptureEnabled', Value1__c='true');
        insert new Settings__c(Name='Audit_Contact', Value1__c='false');
        
        Contact c1 = new Contact(FirstName='Foo',LastName='Bar');
        insert c1;
        Sf.auditService.captureSobjectAudit(null, new List<Sobject>{c1});
        System.assertEquals(0, Sf.auditService.getSobjectAuditHistory(c1.id).size());
    }
}