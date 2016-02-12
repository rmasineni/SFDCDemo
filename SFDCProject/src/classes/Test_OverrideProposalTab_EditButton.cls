@isTest (SeeAllData=true)
public class Test_OverrideProposalTab_EditButton {
    public static testMethod void TestOverrideProposalTab1(){
    	Id userId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
		User partnerUser = [Select id, name, email from User where Id =:userId];
		
		Test.startTest();
		
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('PartnerPortal');
		mock.setStatusCode(200); // Or other appropriate HTTP status code
		mock.setHeader('Content-Type', 'application/json'); // Or other appropriate MIME type like application/xml
		Test.setMock(HttpCalloutMock.class, mock);
		 //
		
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
		   
		   string recordtypeid = [Select r.SobjectType, r.Id From RecordType r where r.SobjectType = 'Contact' limit 1].id;
		      
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
		    
		   	System.runAs(partnerUser){	    
		    ApexPages.StandardController stdcon1 = new ApexPages.StandardController(proposal);
	   		ApexPages.currentPage().getParameters().put('retURL', proposal.Id);
		    ApexPages.currentPage().getParameters().put('RecordType', recordtypeid);
		    ApexPages.currentPage().getParameters().put('ent', '%2');
		    OverrideProposalTab OverrideProposalTabObj1 = new OverrideProposalTab(stdcon1);
		    OverrideProposalTabObj1.redirectProposalTab();
		   	}
		   	
		   	
		    ApexPages.StandardController stdcon2 = new ApexPages.StandardController(proposal);
	   		ApexPages.currentPage().getParameters().put('retURL', proposal.Id);
		    ApexPages.currentPage().getParameters().put('RecordType', recordtypeid);
		    ApexPages.currentPage().getParameters().put('ent', '%2');
		    OverrideProposalTab OverrideProposalTabObj2 = new OverrideProposalTab(stdcon2);
		    OverrideProposalTabObj2.redirectProposalTab();
		    
		Test.stopTest();
    }
    

    public static testMethod void TestOverrideProposalEditButton1(){
    	Id userId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
		User partnerUser = [Select id, name, email from User where Id =:userId];
		
		Test.startTest();
		
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('PartnerPortal');
		mock.setStatusCode(200); // Or other appropriate HTTP status code
		mock.setHeader('Content-Type', 'application/json'); // Or other appropriate MIME type like application/xml
		Test.setMock(HttpCalloutMock.class, mock);
		 //
		
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
		   
		   string recordtypeid = [Select r.SobjectType, r.Id From RecordType r where r.SobjectType = 'Contact' limit 1].id;
		      
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
		    
		   	System.runAs(partnerUser){	    
		    ApexPages.StandardController stdcon1 = new ApexPages.StandardController(proposal);
	   		ApexPages.currentPage().getParameters().put('retURL', proposal.Id);
		    ApexPages.currentPage().getParameters().put('RecordType', recordtypeid);
		    ApexPages.currentPage().getParameters().put('ent', '%2');
		    OverrideProposalEditButton OverrideProposalEditButtonObj1 = new OverrideProposalEditButton(stdcon1);
		    OverrideProposalEditButtonObj1.redirectEditPage();
		   	}
		   	
		   	
		    ApexPages.StandardController stdcon2 = new ApexPages.StandardController(proposal);
	   		ApexPages.currentPage().getParameters().put('retURL', proposal.Id);
		    ApexPages.currentPage().getParameters().put('RecordType', recordtypeid);
		    ApexPages.currentPage().getParameters().put('ent', '%2');
		    OverrideProposalEditButton OverrideProposalEditButtonObj2 = new OverrideProposalEditButton(stdcon2);
		    OverrideProposalEditButtonObj2.redirectEditPage();
		    
		Test.stopTest();
    }

}