@isTest(SeeAllData=true)
public class UnitTest_CreditCheckExtension {
	
	public static testmethod void testCreditCheckExtension(){
		    //
	    Account a = new Account();
	    a.Name = 'Lease Account';
	    a.BillingStreet = '1290 Happy Path';
	    a.BillingCity = 'San Francisco';
	    a.BillingState = 'CA';
	    a.BillingCountry = 'USA';
	    insert a;
	    //    
	    List<Contact> listCon = new List<Contact>();
	    Contact c = new Contact();
	    c.AccountId = a.Id;
	    c.LastName = 'Lease';
	    c.FirstName = 'Johnny';
	    c.Email = 'JLease@leaseyDee.com';
	    c.Phone = '2022022020'; 
	    c.MailingStreet = '1290 Happy Path';
	    c.MailingState = 'CA';
	    c.MailingCountry = 'USA';
	    c.MailingCity = 'San Francisco';
	    c.MailingPostalCode = '99999';   
	    c.Accreditation_period_start_date__c = Date.Today().addDays(-180);
	    c.Accreditation_period_end_date__c = Date.Today().addDays(180);
	    c.Birthdate = Date.Today();    
	    //           
	    listCon.add(c);
	    //
	    Contact c2 = new Contact();
	    c2.AccountId = a.Id;
	    c2.LastName = 'Lease2';
	    c2.FirstName = 'Johnny2';
	    c2.Email = 'JLease2@leaseyDee2.com';
	    c2.Phone = '2022022029'; 
	    c2.MailingStreet = '45 Fremont St';
	    c2.MailingState = 'CA';
	    c2.MailingCountry = 'USA';
	    c2.MailingCity = 'San Francisco';
	    c2.MailingPostalCode = '99999'; 
	    c2.Accreditation_period_start_date__c = Date.Today().addDays(-180);
	    c2.Accreditation_period_end_date__c = Date.Today().addDays(180); 
	    c2.Birthdate = Date.Today(); 
	    listCon.add(c2);
	    //    
	    Contact c3 = new Contact();
	    c3.AccountId = a.Id;
	    c3.LastName = 'Lease2';
	    c3.FirstName = 'Johnny2';
	    c3.Email = 'JLease2@leaseyDee2.com';
	    c3.Phone = '2022022029'; 
	    c3.MailingStreet = '45 Fremont St';
	    c3.MailingState = 'CA';
	    c3.MailingCountry = 'USA';
	    c3.MailingCity = 'San Francisco';
	    c3.MailingPostalCode = '99999'; 
	    c3.Accreditation_period_start_date__c = Date.Today().addDays(-180);
	    c3.Accreditation_period_end_date__c = Date.Today().addDays(180); 
	    c3.Birthdate = Date.Today(); 
	    listCon.add(c3);
	    //
	    insert listCon;
	    //
	    List<Customer_Credit__c> listCustCred = new List<Customer_Credit__c>();
	    Customer_Credit__c cust_cred = new Customer_Credit__c();
	    cust_cred.date_submitted__c = System.today();
	    cust_cred.Contact__c = c.Id;
	    cust_cred.Account__c = a.Id;
	    cust_cred.First_Name__c = c.FirstName;
	    cust_cred.Last_Name__c = c.LastName;
	    cust_cred.Customer_Email__c = c.Email;
	    cust_cred.Customer_Number__c = c.Id;
	    cust_cred.Street__c = c.MailingStreet;
	    cust_cred.City__c = c.MailingCity;
	    cust_cred.State__c = c.MailingState;
	    cust_cred.Zip__c = c.MailingPostalCode;
	    cust_cred.Country__c = c.MailingCountry;
	    cust_cred.Home_Phone__c = c.Phone;
	    cust_cred.Date_Pulled__c = System.today();
	    listCustCred.add(cust_cred);
	//
	    Customer_Credit__c cust_cred2 = new Customer_Credit__c();
	    cust_cred2.date_submitted__c = System.today();
	    cust_cred2.Contact__c = c2.Id;
	    cust_cred2.Account__c = a.Id;
	    cust_cred2.First_Name__c = c2.FirstName;
	    cust_cred2.Last_Name__c = c2.LastName;
	    cust_cred2.Customer_Email__c = c2.Email;
	    cust_cred2.Customer_Number__c = c2.Id;
	    cust_cred2.Street__c = c2.MailingStreet;
	    cust_cred2.City__c = c2.MailingCity;
	    cust_cred2.State__c = c2.MailingState;
	    cust_cred2.Zip__c = c2.MailingPostalCode;
	    cust_cred2.Country__c = c2.MailingCountry;
	    cust_cred2.Home_Phone__c = c2.Phone;
	    listCustCred.add(cust_cred2);
	    //
	    Customer_Credit__c cust_cred_noCon = new Customer_Credit__c();
	    cust_cred_noCon.date_submitted__c = System.today();
	    cust_cred_noCon.First_Name__c = 'Idonotexist';
	    cust_cred_noCon.Last_Name__c = 'Andneverwill';
	    cust_cred_noCon.Customer_Email__c = 'idonot@existandneverwill.net';
	    cust_cred_noCon.Customer_Number__c = 'ABC';
	    cust_cred_noCon.Street__c = '100 Happy Path';
	    cust_cred_noCon.City__c = 'Andover';
	    cust_cred_noCon.State__c = 'MD';
	    cust_cred_noCon.Zip__c = '22222';
	    cust_cred_noCon.Country__c = 'USA';
	    cust_cred_noCon.Home_Phone__c = '2222222222';
	    listCustCred.add(cust_cred_noCon);
	    //
	    Customer_Credit__c cust_cred_APIrec = new Customer_Credit__c();
	    cust_cred_APIrec.date_submitted__c = System.today();
	    cust_cred_APIrec.First_Name__c = 'Idonotexist';
	    cust_cred_APIrec.Last_Name__c = 'Andneverwill';
	    cust_cred_APIrec.Customer_Email__c = 'idonot@existandneverwill.net';
	    cust_cred_APIrec.Customer_Number__c = 'ABC';
	    cust_cred_APIrec.Street__c = '100 Happy Path';
	    cust_cred_APIrec.City__c = 'Andover';
	    cust_cred_APIrec.State__c = 'MD';
	    cust_cred_APIrec.Zip__c = '22222';
	    cust_cred_APIrec.Country__c = 'USA';
	    cust_cred_APIrec.Home_Phone__c = '2222222222';
	    listCustCred.add(cust_cred_APIrec);    
	    //
	    insert listCustCred;   
	    //
	    Opportunity o = new Opportunity();
	    o.AccountId = a.Id;
	    o.Name = 'CC Test';
	    o.StageName = 'Qualified';
	    o.CloseDate = Date.Today().addDays(18);
	    insert o;
	    //

		List<OpportunityContactRole> contactRolelist = new List<OpportunityContactRole>();
		OpportunityContactRole contactRoleObj = new OpportunityContactRole();
		contactRoleObj.ContactId = c.Id;
		contactRoleObj.OpportunityId = o.Id;
		contactRoleObj.Role = 'Homeowner';
		contactRoleObj.IsPrimary = true;
		contactRolelist.add(contactRoleObj);	  

		OpportunityContactRole contactRoleObj2 = new OpportunityContactRole();
		contactRoleObj2.ContactId = c.Id;
		contactRoleObj2.OpportunityId = o.Id;
		contactRoleObj2.Role = EDPUtil.OCR_ROLE_CREDIT;
		contactRoleObj2.IsPrimary = true;
		contactRolelist.add(contactRoleObj2);

	    insert contactRolelist;
	    
	    List<Proposal__c> listProp = new List<Proposal__c>();
	    Proposal__c prop = new Proposal__c();
	    prop.Opportunity__c = o.Id;
	    prop.Sales_Rep_Email__c = 'rep@repsfortesting.com';
	    prop.Date_Issued__c = Date.Today().addDays(18);
	    prop.Mode_Name__c = 'Mode323';
	    prop.System_Size_STC_DC__c = 10;
	    prop.Upfront_Payment__c = 1290;
	    prop.EDP_Phase__c = 'EDP Phase-1';
	    listProp.add(prop);
	    //
	    Proposal__c prop2 = new Proposal__c();
	    prop2.EDP_Phase__c = 'EDP Phase-1';
	    prop2.Opportunity__c = o.Id;
	    prop2.Sales_Rep_Email__c = 'rep@repsfortesting.com';
	    prop2.Date_Issued__c = Date.Today().addDays(18);
	    prop2.Mode_Name__c = 'Mode323';
	    prop2.System_Size_STC_DC__c = 10;
	    prop2.Upfront_Payment__c = 1290;
	    prop2.Current_Customer_Credit_Report__c = cust_cred.Id;
	    listProp.add(prop2);
	    //    
	    insert listProp;
	    //
	    PageReference prCreditCheck = new PageReference('/apex/CreditCheckContact?id=' + c.Id);
	    prCreditCheck.setRedirect(true);
	    //
	    ApexPages.CurrentPage().getParameters().put('ProposalId', String.ValueOf(prop.Id));
	    ApexPages.StandardController sc = new ApexPages.StandardController(c);
	    ContactCreditCheckExtension CCCE = new ContactCreditCheckExtension(sc);
	    
		CreditCheckExtension creditCheckExtensionObj = new CreditCheckExtension();
		creditCheckExtensionObj.CCObj = cust_cred;
		creditCheckExtensionObj.initialize();
		
		
		creditCheckExtensionObj.CancelCCEdit();
		creditCheckExtensionObj.submitNewCreditCheck();
		creditCheckExtensionObj.resendInvitation();
	    creditCheckExtensionObj.SaveAndUpdateProposal();
	    
	    CreditCheckExtension.createContact(a.Id, cust_cred);
	    cust_cred.Street__c = null;
	    cust_cred.State__c = null;
	    cust_cred.Zip__c = null;
	    cust_cred.Country__c = null;
	   	cust_cred.City__c = null;
	    cust_cred.Home_Phone__c = null;
	    CreditCheckExtension.createContact(a.Id, cust_cred);
	    
		CreditCheckExtension creditCheckExtensionObj2 = new CreditCheckExtension();
		creditCheckExtensionObj2.CCObj = cust_cred_noCon;
		cust_cred_noCon.Pending_Reason__c = 'Pending';
		update cust_cred_noCon;

		creditCheckExtensionObj2.initialize();	
		creditCheckExtensionObj2.PendingReason = '';
		creditCheckExtensionObj.CreditCheckRefresh();
		creditCheckExtensionObj2.SaveAndUpdateProposal();    
		
		prop.Current_Customer_Credit_Report__c = cust_cred_noCon.Id;
		update prop;
		creditCheckExtensionObj2.CancelCCEdit();
		
		CreditCheckExtension creditCheckExtensionObj3 = new CreditCheckExtension();
	    Customer_Credit__c cust_cred3 = new Customer_Credit__c();
	    cust_cred3.date_submitted__c = System.today();
	    cust_cred3.Contact__c = c.Id;
	    cust_cred3.Account__c = a.Id;
	    cust_cred3.First_Name__c = c.FirstName;
	    cust_cred3.Last_Name__c = c.LastName;
	    cust_cred3.Customer_Email__c = 'test123@gmail.com';
	    cust_cred3.Customer_Number__c = c.Id;
	    cust_cred3.Street__c = c.MailingStreet;
	    cust_cred3.City__c = c.MailingCity;
	    cust_cred3.State__c = c.MailingState;
	    cust_cred3.Zip__c = c.MailingPostalCode;
	    cust_cred3.Country__c = c.MailingCountry;
	    cust_cred3.Home_Phone__c = c.Phone;
	    cust_cred3.Date_Pulled__c = System.today();
		creditCheckExtensionObj3.CCObj = cust_cred3;
		creditCheckExtensionObj3.initialize();		
		creditCheckExtensionObj3.submitNewCreditCheck();
	}
	
	private static testmethod void testCusomerCredit(){
		
		//
	    // 
	    //
	    // LEASE DIMENSIONS SPECIFIC TESTS
	    try{

	       // LEASE DIMENSIONS WebService SPECIFIC TESTS
	       LeaseDimensionsWebService LDWS = new LeaseDimensionsWebService();
	       LeaseDimensionsWebService.CreditInformation crdtInfo = new LeaseDimensionsWebService.CreditInformation();
	       //
	       crdtInfo.ContactNumber = null;     
	       crdtInfo.City = 'San Francisco';
	       crdtInfo.Country = 'USA';
	       crdtInfo.CustomerEmail = 'bikki@bikkiboxer.com';
	       crdtInfo.DateApproved = Date.Today();
		   crdtInfo.DatePulled = Date.Today();
	       crdtInfo.DatePulled = null;
	       crdtInfo.Employer = 'SUNRUN';
	       crdtInfo.EstimatedHomeValue = '120000'; 
	       crdtInfo.FailedScore = '550';
	       crdtInfo.Fico = '722';
	       crdtInfo.FirstName = 'Arpad';
	       crdtInfo.Gen = 'M';
	       crdtInfo.HomeEquityAmt1 = 123;
	       crdtInfo.HomeEquityAmt2 = 123; 
	       crdtInfo.HomeEquityOpenDate1 = Date.Today();
	       crdtInfo.HomeEquityOpenDate2 = Date.Today();
	       crdtInfo.HomeEquity1 = 'X';
	       crdtInfo.HomeEquity2 = 'X';
	       crdtInfo.HomeOwnerSigned = True; 
	       crdtInfo.HomePhone = '2222222222';
	       crdtInfo.Income = '14500';
	       crdtInfo.Installer = 'Verengaux, France';
	       crdtInfo.LastName = 'Peterson';
	       crdtInfo.LTV = 23;
	       crdtInfo.MI = 'A';
	       crdtInfo.OtherPhone = '3333333333';
	       crdtInfo.Reason = 'NONE';
	       crdtInfo.SalesRepEmail = 'rep@rep.com';
	       crdtInfo.State = 'CA';
	       crdtInfo.Status = 'NONE';
	       crdtInfo.Street = '1290 Happy Path';
	       crdtInfo.X1stMortgageAmt = 123;
	       crdtInfo.X1stMortgageAmt2 = 123; 
	       crdtInfo.X1stMortgageAmt3 = 123;
	       crdtInfo.X1stMortgageAmt4 = 123;
	       crdtInfo.X1stMortgageAmt5 = 123;
	       crdtInfo.X1stMortgageName = 'X';
	       crdtInfo.X1stMortgageName2 = 'X'; 
	       crdtInfo.X1stMortgageName3 = 'X';
	       crdtInfo.X1stMortgageName4 = 'X';
	       crdtInfo.X1stMortgageName5 = 'X';
	       crdtInfo.X1stMortgageOpenDate = Date.Today();
	       crdtInfo.X1stMortgageOpenDate2 = Date.Today();
	       crdtInfo.X1stMortgageOpenDate3 = Date.Today();
	       crdtInfo.X1stMortgageOpenDate4 = Date.Today();
	       crdtInfo.X1stMortgageOpenDate5 = Date.Today();
	       crdtInfo.X2ndMortgageAmt = 123;
	       crdtInfo.X2ndMortgageName = 'X';
	       crdtInfo.X2ndMortgageDate = Date.Today();
	       crdtInfo.X2ndMortgageAmt2 = 123;
	       crdtInfo.X2ndMortgageName2 = 'X'; 
	       crdtInfo.X2ndMortgageDate2 = Date.Today();
	       crdtInfo.DOB = Date.Today();
	       crdtInfo.EmploymentStatus = 'Hired';
	       crdtInfo.Decline_Score = 12;
	       crdtInfo.HouseholdIncome = '12345';
	       crdtInfo.SizeOfHousehold = 12;
	       crdtInfo.Zip = '12222';    
	       //
	       String custnumresp = LeaseDimensionsWebService.SendCreditResponse(crdtInfo);
	    }
	    catch(Exception e)
	    {
	    	System.Debug('ERROR MSG: ' + e.getMessage());
	    }
	
		
	}
	
}