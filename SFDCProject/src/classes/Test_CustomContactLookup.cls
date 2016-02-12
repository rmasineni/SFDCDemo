@isTest (SeeAllData = true)  
public with sharing class Test_CustomContactLookup {
	public static testmethod void TestCustomContactLookup() {

		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('PartnerPortal');
		mock.setStatusCode(200); // Or other appropriate HTTP status code
		mock.setHeader('Content-Type', 'application/json'); // Or other appropriate MIME type like application/xml
		Test.setMock(HttpCalloutMock.class, mock);
		 //
		Test.startTest();
		    Account account = new Account();
		    account.Name = 'Lease Account';
		    account.BillingStreet = '1290 Happy Path';
		    account.BillingCity = 'San Francisco';
		    account.BillingState = 'CA';
		    account.BillingCountry = 'USA';
		    insert account;
		    //    
		   
		    Contact contact = new Contact();
		    contact.AccountId = account.Id;
		    contact.LastName = 'Lease';
		    contact.FirstName = 'Johnny';
		    contact.Email = 'JLease@Test.com';
		    contact.Phone = '2022022020'; 
		    contact.MailingStreet = '1290 Happy Path';
		    contact.MailingState = 'CA';
		    contact.MailingCountry = 'USA';
		    contact.MailingCity = 'San Francisco';
		    contact.MailingPostalCode = '95051';   
		    contact.Accreditation_period_start_date__c = Date.Today().addDays(-180);
		    contact.Accreditation_period_end_date__c = Date.Today().addDays(180);
		    contact.Birthdate = Date.Today();    
		    //           
		   insert contact;
		      
		     Opportunity oppty = new Opportunity();
		    oppty.AccountId = account.Id;
		    oppty.Name = 'EDPLookup Test';
		    oppty.StageName = 'Qualified';
		    oppty.CloseDate = Date.Today().addDays(18);
		    insert oppty;
		    //
			Proposal__c proposal = UnitTest_ServiceContractUtil.createProposal(oppty.Id);
			insert proposal;
				
			ApexPages.currentPage().getParameters().put('proposalId', proposal.Id);
			ApexPages.currentPage().getParameters().put('lksrch', 'Johnny');
			CustomContactLookup CustomContactLookupobj = new CustomContactLookup();
		
			Integer pagenumber = CustomContactLookupobj.pageNumber;
			CustomContactLookupobj.first();
			CustomContactLookupobj.getFormTag();
			CustomContactLookupobj.getResults();
			CustomContactLookupobj.getTextBox();
			CustomContactLookupobj.first();
			boolean testVar1 = CustomContactLookupobj.hasNext;
			boolean testVar2 = CustomContactLookupobj.hasPrevious;
			CustomContactLookupobj.intializeResidentialRecordTypeId();
			CustomContactLookupobj.last();
			CustomContactLookupobj.next();
			CustomContactLookupobj.previous();
			CustomContactLookupobj.search();
		
		
		Test.stopTest();
		
		
	}
}