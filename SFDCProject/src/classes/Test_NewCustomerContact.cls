@isTest (SeeAllData = true)  
public class Test_NewCustomerContact {
	
	public static testmethod void TestNewCustomerContact() {
	
	Id userId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
	User partnerUser = [Select id, name, email from User where Id =:userId];
	
	//System.runAs(partnerUser){
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
		    contact.Email = 'JLease@leaseyDee.com';
		    contact.Phone = '2022022020'; 
		    contact.MailingStreet = '1290 Happy Path';
		    contact.MailingState = 'CA';
		    contact.MailingCountry = 'USA';
		    contact.MailingCity = 'San Francisco';
		    contact.MailingPostalCode = '99999';   
		    contact.Accreditation_period_start_date__c = Date.Today().addDays(-180);
		    contact.Accreditation_period_end_date__c = Date.Today().addDays(180);
		    contact.Birthdate = Date.Today();    
		    //           
		   insert contact;
		      
		     Opportunity oppty = new Opportunity();
		    oppty.AccountId = account.Id;
		    oppty.Name = 'CC Test';
		    oppty.StageName = 'Qualified';
		    oppty.CloseDate = Date.Today().addDays(18);
		    insert oppty;
		    //
		    Proposal__c proposal = new Proposal__c();
		    proposal.Opportunity__c = oppty.Id;
		    proposal.Sales_Rep_Email__c = 'rep@repsfortesting.com';
		    proposal.Date_Issued__c = Date.Today().addDays(18);
		    proposal.Mode_Name__c = 'Mode323';
		    proposal.System_Size_STC_DC__c = 1290;
		    proposal.Upfront_Payment__c = 1290;
		    insert proposal;

			system.debug('Test Started:'+contact.Id);
			ApexPages.currentPage().getParameters().put('contactid', contact.Id);
		
			ApexPages.StandardController stdCon = new ApexPages.StandardController(contact);
			NewCustomerContact NewCustomerContactObjC = new NewCustomerContact(stdCon);
			
			
			NewCustomerContactObjC.getBaseURL();
			NewCustomerContactObjC.lastName = 'Ltest';
			NewCustomerContactObjC.getEditAdditionalInfo();
			NewCustomerContactObjC.contactId = contact.Id;
			NewCustomerContactObjC.saveContact();
			
			ApexPages.currentPage().getParameters().put('Proposalid', Proposal.Id);
			ApexPages.StandardController pstdCon = new ApexPages.StandardController(Proposal);
			NewCustomerContact NewCustomerContactObjP = new NewCustomerContact(pstdCon);
			
			NewCustomerContactObjP.saveContact();
			
			
			NewCustomerContact NewCustomerContactObj = new NewCustomerContact();
	
			system.debug('Assiging values');
			NewCustomerContactObj.addCon.LastName = 'Lease';
	    	NewCustomerContactObj.addCon.FirstName = 'Johnny';
	    	NewCustomerContactObj.addCon.Email = 'JLease1@Test.com';
	    	NewCustomerContactObj.addCon.Phone = '2022022020'; 
	   	 	NewCustomerContactObj.addCon.MailingStreet = '1290 Happy Path';
	   	 	NewCustomerContactObj.addCon.MailingState = 'CA';
	    	NewCustomerContactObj.addCon.MailingCountry = 'USA';
	    	NewCustomerContactObj.addCon.MailingCity = 'San Francisco';
	   		NewCustomerContactObj.addCon.MailingPostalCode = '99999'; 
	   		
	   		NewCustomerContactObj.getBaseURL();
			NewCustomerContactObj.getEditAdditionalInfo();
			NewCustomerContactObj.saveContact();
			
			NewCustomerContact.BaseException baseExp = new NewCustomerContact.BaseException();

		Test.stopTest();
		//}
	}
	
}