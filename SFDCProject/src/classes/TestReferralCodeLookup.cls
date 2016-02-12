@isTest
private class TestReferralCodeLookup {


	static testMethod void test(){
		System.debug(LoggingLevel.INFO, 'entering test');
		Account acc = new Account();
		acc.Name='Foo';
		acc.Customer_referral_code__c='ABC123';
		insert acc;
		Lead testLead = new Lead();
		testLead.LastName='Blee';
		testLead.referred_by_code__c='ABC123';
		testLead.Company='Blee Co';
		insert testLead;	
	}
}