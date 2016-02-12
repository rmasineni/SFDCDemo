@isTest (SeeAllData=true)
public class Test_ProposalEditNoteClass {
	public static testMethod void TestProposalEditNoteClass(){
		
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

 		Notes__c notes = new Notes__c();
 		notes.Notes__c = 'Testing Notes';
 		notes.Proposal__c = proposal.id;
 		notes.Notes_Added_By__c = 'SunRun';
 		insert notes;
 						
		ApexPages.StandardController stdcon = new ApexPages.StandardController(notes);
		ProposalEditNoteClass editNotesObj = new ProposalEditNoteClass(stdcon);
		
		String testVar = editNotesObj.getBodyVal();
		editNotesObj.contentMode();
		editNotesObj.setBodyVal(testVar);
		editNotesObj.save();
		
		Test.stopTest();
			
	
	}
	
}