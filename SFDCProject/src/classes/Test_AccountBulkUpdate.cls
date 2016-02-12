@isTest	
public class Test_AccountBulkUpdate {
	
	private static testMethod void TestAccountBulkUpdateBatch(){
		//Insert contacts with different expirtation dates
		Test.startTest();
		
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('PartnerPortal');
		mock.setStatusCode(200); // Or other appropriate HTTP status code
		mock.setHeader('Content-Type', 'application/json'); // Or other appropriate MIME type like application/xml
		Test.setMock(HttpCalloutMock.class, mock);
		
		Test.stopTest(); 
		
		   /* Account account = new Account();
		    account.Name = 'Bulk Account';
		    account.BillingStreet = '3665 Benton Street Apt 145';
		    account.BillingCity = 'Santa Clara';
		    account.BillingState = 'CA';
		    account.BillingCountry = 'USA';
		    account.BillingPostalCode = '95051';
		    account.Account_Type__c = 'Residential';
		    system.debug('Before Isnert');
		    insert account;
		    system.debug('After Isnert'); */
		AccountBulkUpdateBatch batchJob = new AccountBulkUpdateBatch();
		
		id batchinstanceid = database.executeBatch(batchJob);  
		//system.debug('After Batch Execute');
		
	}
	
	static testmethod void TestAccountBulkUpdate_Scheduler(){// for code coverage only
		Test.startTest();
        AccountBulkUpdate_Scheduler  schedule = new AccountBulkUpdate_Scheduler();
        schedule.execute(null); 
        Test.stopTest(); 
    }

}