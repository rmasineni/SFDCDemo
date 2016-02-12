@isTest (SeeAllData = true)  
public class Test_CustomPartnerLookup {
	public static testmethod void TestCustomPartnerLookup() {

		Id userId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
	User partnerUser = [Select id, name, email from User where Id =:userId];
	
	System.runAs(partnerUser){
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
		    Proposal__c proposal = new Proposal__c();
		    proposal.Opportunity__c = oppty.Id;
		    proposal.Sales_Rep_Email__c = 'partnerrep@repsfortesting.com';
		    proposal.Date_Issued__c = Date.Today().addDays(18);
		    proposal.Mode_Name__c = 'Mode323';
		    proposal.System_Size_STC_DC__c = 1290;
		    proposal.Upfront_Payment__c = 1290;
		    proposal.sales_partner__c = PartnerDetail__c.getValues('ApexTestAccount').PartnerAccountId__c;
		    proposal.Install_Partner__c = PartnerDetail__c.getValues('ApexTestAccount').PartnerAccountId__c;
		    insert proposal;
			
			ApexPages.currentPage().getParameters().put('proposalId', proposal.Id);
			ApexPages.currentPage().getParameters().put('lksrch', 'Johnny');
			ApexPages.currentPage().getParameters().put('idValue', 'Contact');
			CustomPartnerLookup CustomPartnerLookupobj = new CustomPartnerLookup();
		
			Integer pagenumber = CustomPartnerLookupobj.pageNumber;
			CustomPartnerLookupobj.first();
			CustomPartnerLookupobj.getFormTag();
			CustomPartnerLookupobj.getResults();
			CustomPartnerLookupobj.getTextBox();
			CustomPartnerLookupobj.first();
			boolean testVar1 = CustomPartnerLookupobj.hasNext;
			boolean testVar2 = CustomPartnerLookupobj.hasPrevious;
			CustomPartnerLookupobj.last();
			CustomPartnerLookupobj.next();
			CustomPartnerLookupobj.previous();
			CustomPartnerLookupobj.search();
		
		
		Test.stopTest();
	}
		
	}
}