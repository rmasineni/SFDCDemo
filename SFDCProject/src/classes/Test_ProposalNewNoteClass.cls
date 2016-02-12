@isTest (SeeAllData=true)
public class Test_ProposalNewNoteClass {
	public static testMethod void TestProposalNewNoteClass(){
		        
		//
		Test.startTest();
		    Account account = new Account();
		    account.Name = 'NewCustomer Account';
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
		    //           
		   insert contact;
		      
		     Opportunity oppty = new Opportunity();
		    oppty.AccountId = account.Id;
		    oppty.Name = 'NewCC Test';
		    oppty.StageName = 'Qualified';
		    oppty.CloseDate = Date.Today().addDays(18);
		    insert oppty;
		    //
		    Proposal__c proposal = new Proposal__c();
		    proposal.Opportunity__c = oppty.Id;
		    proposal.Sales_Rep_Email__c = 'Salesrep@repsfortesting.com';
		    proposal.Date_Issued__c = Date.Today().addDays(18);
		    proposal.Mode_Name__c = 'Mode323';
		    proposal.System_Size_STC_DC__c = 1290;
		    proposal.Upfront_Payment__c = 1290;
		    insert proposal;
		    
		ApexPages.StandardController stdcon = new ApexPages.StandardController(proposal);
		ProposalNewNoteClass newNotesObj = new ProposalNewNoteClass(stdcon);

		newNotesObj.getwhichOrg();
		newNotesObj.saveForm();

		Id userId = PartnerDetail__c.getValues('EDPTestAccount').PartnerUserId__c;
		User partnerUser = [Select id, name, email from User where Id =:userId];
	
		System.runAs(partnerUser){
		
		 Account account1 = new Account();
		    account1.Name = 'NewCustomer Account';
		    account1.BillingStreet = '1290 Happy Path';
		    account1.BillingCity = 'San Francisco';
		    account1.BillingState = 'CA';
		    account1.BillingCountry = 'USA';
		    insert account1;
		    //    
		   
		    Contact contact1 = new Contact();
		    contact1.AccountId = account1.Id;
		    contact1.LastName = 'Lease';
		    contact1.FirstName = 'Johnny';
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
		    //           
		   insert contact1;
		      
		     Opportunity oppty1 = new Opportunity();
		    oppty1.AccountId = account1.Id;
		    oppty1.Name = 'NewCC Test';
		    oppty1.StageName = 'Qualified';
		    oppty1.CloseDate = Date.Today().addDays(18);
		    insert oppty1;
		    //
		    Proposal__c proposal1 = new Proposal__c();
		    proposal1.Opportunity__c = oppty1.Id;
		    proposal1.Sales_Rep_Email__c = 'Salesrep@repsfortesting.com';
		    proposal1.Date_Issued__c = Date.Today().addDays(18);
		    proposal1.Mode_Name__c = 'Mode323';
		    proposal1.System_Size_STC_DC__c = 1290;
		    proposal1.Upfront_Payment__c = 1290;
		    insert proposal1;
		
		ApexPages.StandardController stdcon1 = new ApexPages.StandardController(proposal1);
		ProposalNewNoteClass newNotesObj1 = new ProposalNewNoteClass(stdcon1);
		newNotesObj1.getwhichOrg();
		newNotesObj1.saveForm();
		}
		
		Test.stopTest();
		
	}

}