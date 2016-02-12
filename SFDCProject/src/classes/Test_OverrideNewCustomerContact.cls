@isTest (SeeAllData=true)
public class Test_OverrideNewCustomerContact {

 	public static testMethod void TestOverrideNewCustomerContact1(){
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
		   		   		    
		   	System.runAs(partnerUser){	    
		    ApexPages.StandardController stdcon1 = new ApexPages.StandardController(contact);
	   		ApexPages.currentPage().getParameters().put('retURL', contact.Id);
		    ApexPages.currentPage().getParameters().put('RecordType', recordtypeid);
		    ApexPages.currentPage().getParameters().put('ent', '%2');
		    OverrideNewCustomerContact OverrideNewCustomerContactObj1 = new OverrideNewCustomerContact(stdcon1);
		    OverrideNewCustomerContactObj1.redirectNewCustomerContact();
		   	}
		   	
		   	
		    ApexPages.StandardController stdcon2 = new ApexPages.StandardController(contact);
	   		ApexPages.currentPage().getParameters().put('retURL', contact.Id);
		    ApexPages.currentPage().getParameters().put('RecordType', recordtypeid);
		    ApexPages.currentPage().getParameters().put('ent', '%2');
		    OverrideNewCustomerContact OverrideNewCustomerContactObj2 = new OverrideNewCustomerContact(stdcon2);
		    OverrideNewCustomerContactObj2.redirectNewCustomerContact();
		    
		Test.stopTest();
    }
    

}