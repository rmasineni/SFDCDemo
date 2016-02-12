@isTest
private class TestClassLead360 {
    static testMethod void testLead360() {

		Lead testLead = new Lead();
		testLead.LastName='Blee';
		testLead.referred_by_code__c='ABC123';
		testLead.Company='Blee Co';
		insert testLead;
		Id leadId = testLead.Id;
		ApexPages.StandardController stdCont = new ApexPages.StandardController(new Lead(Id = leadId));
    	lead360Controller lead360Cont = new lead360Controller(stdCont);
    	lead360Cont.send();
    }
}