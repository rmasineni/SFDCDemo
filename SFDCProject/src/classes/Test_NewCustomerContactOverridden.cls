@isTest (SeeAllData = true)  
public class Test_NewCustomerContactOverridden {
	
	public static testmethod void TestNewCustomerContactOverridden() {
	
	Id userId = PartnerDetail__c.getValues('EDPTestAccount').PartnerUserId__c;
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
		    account.Name = 'NewCustomer Account';
		   // account.BillingStreet = '1290 Happy Path';
		 //   account.BillingCity = 'San Francisco';
		 //   account.BillingState = 'CA';
		//    account.BillingCountry = 'USA';
		    insert account;
		    
		     Opportunity oppty = new Opportunity();
		    oppty.AccountId = account.Id;
		    oppty.Name = 'NewCC Test';
		    oppty.StageName = 'Qualified';
		    oppty.CloseDate = Date.Today().addDays(18);
		    insert oppty;
		    
		       Opportunity oppty1 = new Opportunity();
		    oppty1.AccountId = account.Id;
		    oppty1.Name = 'NewCC Test';
		    oppty1.StageName = 'Qualified';
		    oppty1.CloseDate = Date.Today().addDays(18);
		    insert oppty1;
		     
		     
		    
		     Proposal__c proposal = new Proposal__c();
		    proposal.Opportunity__c = oppty.Id;
		    proposal.Sales_Rep_Email__c = 'Salesrep@repsfortesting.com';
		    proposal.Date_Issued__c = Date.Today().addDays(18);
		    proposal.Mode_Name__c = 'Mode323';
		    proposal.System_Size_STC_DC__c = 1290;
		    proposal.Upfront_Payment__c = 1290;
		    insert proposal;
		    //    
		   
		    Contact contact = new Contact();
		    contact.AccountId = account.Id;
		    contact.LastName = 'Lease';
		    contact.FirstName = 'Johnny';
		    contact.Email = 'JLeaseNew@TestInc.com';
		    contact.Phone = '2022022020'; 
		    contact.MailingStreet = '1290 Happy Path';
		    contact.MailingState = 'CA';
		    contact.MailingCountry = 'USA';
		    contact.MailingCity = 'San Francisco';
		    contact.MailingPostalCode = '99999';   
		    contact.Accreditation_period_start_date__c = Date.Today().addDays(-180);
		    contact.Accreditation_period_end_date__c = Date.Today().addDays(180);
		    contact.Birthdate = Date.Today();  
		    contact.Proposal__c=proposal.id ; 
		    //           
		   insert contact;
		   
		   
		   Contact contact1 = new Contact();
		    contact1.AccountId = account.Id;
		    contact1.LastName = 'Lease1';
		    contact1.FirstName = 'Johnny1';
		    contact1.Email = 'JLeaseNew@TestInc.com';
		    contact1.Phone = '2022022020'; 
		    contact1.MailingStreet = '1290 Happy Path';
		    contact1.MailingState = 'CA';
		    contact1.MailingCountry = 'USA';
		    contact1.MailingCity = 'San Francisco';
		    contact1.MailingPostalCode = '99999';   
		    contact1.Accreditation_period_start_date__c = Date.Today().addDays(-180);
		    contact1.Accreditation_period_end_date__c = Date.Today().addDays(180);
		    contact1.Birthdate = Date.Today();  
		    contact1.Proposal__c=proposal.id ; 
		    //           
		   insert contact1;
		   
		   
		   
		   
		    OpportunityContactRole  ocr = new OpportunityContactRole();
		   ocr.contactId = contact1.id;
		    ocr.opportunityId = oppty1.id;
		    ocr.Role = 'Manager';
		    insert ocr;
		      
		    
		    //
		   

			system.debug('Test Started:'+contact.Id);
			ApexPages.currentPage().getParameters().put('contactid', contact.Id);
		
			ApexPages.StandardController stdCon = new ApexPages.StandardController(contact);
			NewCustomerContactOverridden NewCustomerContactOverObjC = new NewCustomerContactOverridden(stdCon);
			List<SelectOption> selectlist = NewCustomerContactOverObjC.getContactRoles();
			Pagereference pg1 = NewCustomerContactOverObjC.setProposal();
			NewCustomerContactOverObjC.getBaseURL();
			NewCustomerContactOverObjC.getEditAdditionalInfo();
			NewCustomerContactOverObjC.saveContact();
			NewCustomerContactOverObjC.confirmsave();
			NewCustomerContactOverObjC.returnToOpportunity();
			NewCustomerContactOverObjC.getActiveProposals();
			
			system.debug('Proposal Called');
			
			ApexPages.currentPage().getParameters().put('Proposalid', Proposal.Id);
			ApexPages.StandardController pstdCon = new ApexPages.StandardController(Proposal);
			NewCustomerContactOverridden NewCustomerContactOverObjP = new NewCustomerContactOverridden(pstdCon);
			NewCustomerContactOverObjP.saveContact();
            NewCustomerContactOverObjP.confirmsave();
            NewCustomerContactOverObjP.returnToOpportunity();
            NewCustomerContactOverObjP.getActiveProposals();
			system.debug('Proposal Called');
			ApexPages.currentPage().getParameters().put('proposalId', Proposal.Id);
			NewCustomerContactOverridden NewCustomerContactOverObj = new NewCustomerContactOverridden();
			NewCustomerContactOverObj.getBaseURL();
			NewCustomerContactOverObj.getEditAdditionalInfo();
			NewCustomerContactOverObj.saveContact();
			NewCustomerContactOverObj.confirmsave();
			NewCustomerContactOverObj.returnToOpportunity();
			NewCustomerContactOverObj.getActiveProposals();
			
			NewCustomerContactOverridden custcontact = new NewCustomerContactOverridden();
			
			
			
			NewCustomerContactOverridden.BaseException baseExp = new NewCustomerContactOverridden.BaseException();
		Test.stopTest();
		}
	}
	
}