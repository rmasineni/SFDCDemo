@isTest (SeeAllData = true)  
public class Test_CustomerCreditManager {
	public static testmethod void TestCustomerCreditManager() {
		
		system.debug('PartnerDetail User id' + PartnerDetail__c.getValues('EDPTestAccount').PartnerUserId__c);
		Id userId = PartnerDetail__c.getValues('EDPTestAccount').PartnerUserId__c;
		system.debug('PartnerDetail User id' + userId);
		User partnerUser = [Select id, name, email from User where Id =:userId];
		system.debug('partnerUser'+partnerUser);
	
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
		    account.BillingStreet = '595 market street';
		    account.BillingCity = 'San Francisco';
		    account.BillingState = 'CA';
		    account.BillingCountry = 'USA';
		    account.billingpostalcode = '94105';
		    //account.Address_Standardization_Override__c = true;
		    insert account;
		    //    
		   
		    Contact contact = new Contact();
		    contact.AccountId = account.Id;
		    contact.LastName = 'Lease';
		    contact.FirstName = 'Johnny';
		    contact.Email = 'JLease@Test.com';
		    contact.Phone = '2022022020'; 
		    contact.MailingStreet = '595 market street';
		    contact.MailingState = 'CA';
		    contact.MailingCountry = 'USA';
		    contact.MailingCity = 'San Francisco';
		    contact.MailingPostalCode = '94105';   
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
			insert proposal;
			
			ApexPages.currentPage().getParameters().put('proposalId', proposal.Id);
			ApexPages.currentPage().getParameters().put('contactId', contact.Id);
			CustomerCreditManager CustomerCreditManagerobj = new CustomerCreditManager();


			
			CustomerCreditManagerobj.applySearchFilter();
			CustomerCreditManagerobj.Cancel();
			Id selectedOptyId = oppty.id;
			CustomerCreditManagerobj.createData(selectedOptyId);
			CustomerCreditManagerobj.init();
			CustomerCreditManagerobj.intializeResidentialRecordTypeId();
			CustomerCreditManagerobj.setSelCon();
			CustomerCreditManagerobj.SubmitCreditCheck();
			CustomerCreditManagerobj.SubmitResendEmail();
			CustomerCreditManagerobj.updateInputValue();
			
			contact.Email = 'JLease@yopmail.com';
			CustomerCreditManagerobj.validateContactInfo(contact, true);
			
			contact.Email = 'JLease@Test.com';
			contact.MailingState = '';
			CustomerCreditManagerobj.validateContactInfo(contact, true);
			
			contact.MailingState = 'CA';
			contact.Credit_Received__c = Date.today();
			CustomerCreditManagerobj.validateContactInfo(contact, true);
			
			contact.Credit_Received__c = null;
			contact.Credit_Submitted__c = Date.today();
			CustomerCreditManagerobj.validateContactInfo(contact, true);
			CustomerCreditManagerobj.inPersonSubmitCreditCheck();
			
			InPersonCreditResponse respobseObj1 = new InPersonCreditResponse();
			String message1 = respobseObj1.message;
			System.currentPageReference().getParameters().put('returnCode', 'Failure');

			InPersonCreditResponse respobseObj2 = new InPersonCreditResponse();
			String message2 = respobseObj2.message;
			
		}

	}
	
}