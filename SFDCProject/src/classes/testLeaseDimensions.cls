/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=true)
private class testLeaseDimensions {
	
	static testMethod void myUnitTest() {
        Test.startTest();
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
    LeaseDimensions LD = new LeaseDimensions();
    // 
    try{
       	HttpResponse res = new HttpResponse();
       	String strResp = '<root><request><apikey>e80b330f29a62d65494265e40d645700</apikey><username>dealer-api-test@leasedimensions.com</username><password>****************</password>';
       	       strResp += '<homeowner_first_name>Beakie</homeowner_first_name><homeowner_last_name>Beakers</homeowner_last_name><homeowner_email>beakers@bikkistjohn.com</homeowner_email><customer_number>003g00000024RgwAAE</customer_number>';
       	       strResp += '<salesperson_first_name>Peter</salesperson_first_name><salesperson_last_name>Mandy</salesperson_last_name><salesperson_email>bogus@bogus.com</salesperson_email><installer_id>0123456789QyY2</installer_id><api_function_call/>';
               strResp += '</request><response><response_code>0</response_code><response_description>homeowner successfully created and invite email sent</response_description><invite_email>The below e-mail was sent to Beakie at beakers@bikkistjohn.com';
               strResp += 'Dear Beakie:';
               strResp += 'Thank you for completing your first step towards powering your home with clean solar energy by SunRun, the nations leading home solar company.';
               strResp += 'As discussed with your solar consultant, well need to review your credit before proceeding.  To do that securely and privately, SunRun created a password protected web-form that is only accessible by you.  Once you log in, youll be able to securely input your information and authorize a credit check in two easy steps.';
               strResp += 'Please start by clicking on the login link below.';
               strResp += 'Thank You,';
               strResp += 'API USER';
               strResp += 'no-reply@sunrunuat.leasedimensions.com';
               strResp += 'If you cannot read this LOGIN LINK then please use the link below to go to your account.';
               strResp += 'https://sunrunuat.leasedimensions.com/newuser?key=7a9fb4abe05f59ae6f8ae31ec55e8b3e</invite_email>';
               strResp += '</response>';
               strResp += '<dealer_account>dealer account already exists.  attached to dealer account</dealer_account>';
               strResp += '</root>';
       	res.setBody(strResp);
        LD.handleWebServiceResponse(res);    
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        res = LD.invokeWebService(h, req);
        LD.ProcessReturnValue('Hi', 'Yes', null);
        LD.ProcessReturnValue('SUCCESS', 'Yes', null);
        LD.ProcessReturnValue('SUCCESS', 'Yes', c);
    }
    catch(Exception e)
    {
    	System.Debug('ERROR MSG: ' + e.getMessage());
    }
    
    try{
    	LD.CallCreateAndInvite(cust_cred_APIrec);
    }
    catch(Exception e){
    	System.Debug('ERROR MSG: ' + e.getMessage());
    }
    try{
    	LD.CallCreateAndInvite(c);
    }
    catch(Exception e){
    	System.Debug('ERROR MSG: ' + e.getMessage());
    }     
    try{
       LD.CallResend(c.Id, 'Fred','english');
    }
    catch(Exception e){
    	System.Debug('ERROR MSG: ' + e.getMessage());
    }
    try{
       LD.createAndInviteHomeowner('Bill', 'Billiamson', 'bill@billsemail.com', '123', 'sfn', 'sln', 'salesperson@sp3.net', '');
    }
    catch(Exception e){
    	System.Debug('ERROR MSG: ' + e.getMessage());
    }
  
      try{
       LD.createInpersonCreditURL('Bill', 'Billiamson', 'bill@billsemail.com', '123','9932334349'  ,'sfn', 'sln', 'ca','94538','ts','tsd' , 'salesperson@sp3.net', '','');
    }
    catch(Exception e){
    	System.Debug('ERROR MSG: ' + e.getMessage());
    }
        
        
        
    try{
       LD.CreditCheckRefresh(c);
    }
    catch(Exception e){
    	System.Debug('ERROR MSG: ' + e.getMessage());
    }
    try{
       LD.resendToHomeowner('custnum','english');
    }
    catch(Exception e){
    	System.Debug('ERROR MSG: ' + e.getMessage());
    }      
    try{
       LD.createCreditRecord(c);
    }
    catch(Exception e){
    	System.Debug('ERROR MSG: ' + e.getMessage());
    }       
    //
    // LEASE DIMENSIONS SPECIFIC TESTS
    try{
       String custnum = String.ValueOf(c.Id);
       // LEASE DIMENSIONS WebService SPECIFIC TESTS
       LeaseDimensionsWebService LDWS = new LeaseDimensionsWebService();
       LeaseDimensionsWebService.CreditInformation crdtInfo = new LeaseDimensionsWebService.CreditInformation();
       //
       
       crdtInfo.ContactNumber = custnum; 
       crdtInfo.CustomerNumber = custnum; 
       crdtInfo.City = 'San Francisco';
       crdtInfo.Country = 'USA';
       crdtInfo.CustomerEmail = 'bikki@bikkiboxer.com';
       crdtInfo.DateApproved = Date.Today();
       crdtInfo.DatePulled = Date.Today();
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
       crdtInfo.Status = 'PASS';
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

		crdtInfo.Bureau1 = 'Experian';
		crdtInfo.X1DatePulled = Date.Today(); 
		crdtInfo.X1Fico = '750';
		crdtInfo.X1Reason = 'Test Reason1';

		//Experain banky review and adverse action reasons
		crdtInfo.X1BankyOutcome = 'X1BO';      
		crdtInfo.X1MortgageOutcome = 'X1MO' ;    
		crdtInfo.X1BKFilingCode = '';
		crdtInfo.X1BKFilingDate = Date.today();
		crdtInfo.X1BKOver60months = '';
		crdtInfo.X1BKNumMonths = '';
		crdtInfo.X1AdverseActionReason1 = '';
		crdtInfo.X1AdverseActionReason2 = '';   
		crdtInfo.X1AdverseActionReason3 = '';
		crdtInfo.X1AdverseActionReason4 = '';      
		crdtInfo.X1AdverseActionReason5 = '';
	
		//TU DATA
		crdtInfo.Bureau2 = 'TransUnion';
		crdtInfo.X2DatePulled = Date.Today().addDays(-2); 
		crdtInfo.X2Fico = '740'; 
		crdtInfo.X2Reason = 'Test Reaso2';
	
		//Transunion banky review and adverse action reasons
		crdtInfo.X2BankyOutcome = '';      
		crdtInfo.X2MortgageOutcome = '';     
		crdtInfo.X2BKNumMonths = '';
		crdtInfo.X2AdverseActionReason1 = '';
		crdtInfo.X2AdverseActionReason2 = '';     
		crdtInfo.X2AdverseActionReason3 = '';
		crdtInfo.X2AdverseActionReason4 = '';      
		crdtInfo.X2AdverseActionReason5 = '';
	
		//EQUIFAX DATA
		crdtInfo.Bureau3 = 'Equifax';
		crdtInfo.X3DatePulled = Date.Today().addDays(-1); 
		crdtInfo.X3Fico = '720'; 
		crdtInfo.X3Reason = 'Test Reason3';
	
		//EQUIFAX banky review and adverse action reasons
		crdtInfo.X3BankyOutcome = '';      
		crdtInfo.X3MortgageOutcome = '';     
		crdtInfo.X3BKNumMonths = '';
		crdtInfo.X3AdverseActionReason1 = '';
		crdtInfo.X3AdverseActionReason2 = '';     
		crdtInfo.X3AdverseActionReason3 = '';
		crdtInfo.X3AdverseActionReason4 = '';      
		crdtInfo.X3AdverseActionReason5 = '';
		
        crdtInfo.ofac='';

       //
       String custnumresp = LeaseDimensionsWebService.SendCreditResponse(crdtInfo);
       //
       crdtInfo.ContactNumber = cust_cred_APIrec.Id;  
       crdtInfo.CustomerNumber = cust_cred_APIrec.Id;  
       custnumresp = LeaseDimensionsWebService.SendCreditResponse(crdtInfo); 
       Customer_Credit__c ccObj = [Select Id,Customer_Email__c, fico__c, Decisioning_Bureau__c, Date_Pulled__c, Reason__c from  Customer_Credit__c where id =:crdtInfo.ContactNumber];
       System.assertEquals(ccObj.fico__c, crdtInfo.X1Fico);
       System.assertEquals(ccObj.Decisioning_Bureau__c, crdtInfo.Bureau1);
    	System.debug('ccObj.fico__c1: ' + ccObj.fico__c);
    
    
    	crdtInfo.X2Fico = '760'; 
    	custnumresp = LeaseDimensionsWebService.SendCreditResponse(crdtInfo);
 		ccObj = [Select Id,Customer_Email__c, fico__c, Decisioning_Bureau__c, Date_Pulled__c, Reason__c from  Customer_Credit__c where id =:crdtInfo.ContactNumber];
        System.assertEquals(ccObj.fico__c, crdtInfo.X2Fico);
        System.assertEquals(ccObj.Decisioning_Bureau__c, crdtInfo.Bureau2);   	
    	System.debug('ccObj.fico__c2: ' + ccObj.fico__c);

    	crdtInfo.X3Fico = '770'; 
    	custnumresp = LeaseDimensionsWebService.SendCreditResponse(crdtInfo);
 		ccObj = [Select Id,Customer_Email__c, fico__c, Decisioning_Bureau__c, Date_Pulled__c, Reason__c from  Customer_Credit__c where id =:crdtInfo.ContactNumber];
        System.assertEquals(ccObj.fico__c, crdtInfo.X3Fico);
        System.assertEquals(ccObj.Decisioning_Bureau__c, crdtInfo.Bureau3);   	
    	System.debug('ccObj.fico__c3: ' + ccObj.fico__c);

    	crdtInfo.X1Fico = '760'; 
    	crdtInfo.X2Fico = '760'; 
    	crdtInfo.X3Fico = '770'; 
    	custnumresp = LeaseDimensionsWebService.SendCreditResponse(crdtInfo);
 		ccObj = [Select Id,Customer_Email__c, fico__c, Decisioning_Bureau__c, Date_Pulled__c, Reason__c from  Customer_Credit__c where id =:crdtInfo.ContactNumber];
        System.assertEquals(ccObj.fico__c, crdtInfo.X3Fico);
        System.assertEquals(ccObj.Decisioning_Bureau__c, crdtInfo.Bureau3);   	
    	System.debug('ccObj.fico__c4: ' + ccObj.fico__c);

    	crdtInfo.X1Fico = '760'; 
    	crdtInfo.X2Fico = '760'; 
    	crdtInfo.X3Fico = '760'; 
    	custnumresp = LeaseDimensionsWebService.SendCreditResponse(crdtInfo);
 		ccObj = [Select Id,Customer_Email__c, fico__c, Decisioning_Bureau__c, Date_Pulled__c, Reason__c from  Customer_Credit__c where id =:crdtInfo.ContactNumber];
        System.assertEquals(ccObj.fico__c, crdtInfo.X3Fico);
        System.assertEquals(ccObj.Decisioning_Bureau__c, crdtInfo.Bureau1);   	
    	System.debug('ccObj.fico__c4: ' + ccObj.fico__c);
        
        crdtInfo.X1Fico = ''; 
    	crdtInfo.X2Fico = ''; 
    	crdtInfo.X3Fico = ''; 
        custnumresp = LeaseDimensionsWebService.SendCreditResponse(crdtInfo);
 		ccObj = [Select Id,Customer_Email__c, fico__c, Decisioning_Bureau__c, Date_Pulled__c, Reason__c from  Customer_Credit__c where id =:crdtInfo.ContactNumber];
        //System.assertEquals(ccObj.fico__c, crdtInfo.X3Fico);
       // System.assertEquals(ccObj.Decisioning_Bureau__c, crdtInfo.Bureau1);   	
    	//System.debug('ccObj.fico__c4: ' + ccObj.fico__c);
    	
         crdtInfo.X1Fico = ''; 
    	crdtInfo.X2Fico = ''; 
    	crdtInfo.X3Fico = ''; 
        LeaseDimensionsWebService.sunrunCreditStr='';
        custnumresp = LeaseDimensionsWebService.SendCreditResponse(crdtInfo);
 		ccObj = [Select Id,Customer_Email__c, fico__c, Decisioning_Bureau__c, Date_Pulled__c, Reason__c from  Customer_Credit__c where id =:crdtInfo.ContactNumber];
        //System.assertEquals(ccObj.fico__c, crdtInfo.X3Fico);
       // System.assertEquals(ccObj.Decisioning_Bureau__c, crdtInfo.Bureau1);   	
    	//System.debug('ccObj.fico__c4: ' + ccObj.fico__c);
    	LD.ProcessReturnValue('SUCCESS','test',null);
    	LD.ProcessReturnValue('FAIL','test',null);
    	map<Id,Proposal__c> proposals = new map<Id,Proposal__c>([select Id, Primary_Customer__r.firstname, Primary_Customer__r.LastName ,Primary_Customer__r.email ,
                                                           Primary_Customer__r.Birthdate,Primary_Customer__r.MailingStreet, Primary_Customer__r.Phone, Opportunity__r.AccountId, 
                                                         Primary_Customer__r.MailingCity,Primary_Customer__r.MailingState,  Opportunity__r.Deal_Id__c, Install_Partner_Name__c,
                                                         Primary_Customer__r.MailingCountry, Primary_Customer__r.MailingPostalCode, 
                                                         Agreement_Type__c, Primary_Customer__r.id ,Current_Customer_Credit_Report__c
                                                                 from proposal__c where Current_Customer_Credit_Report__c=null limit 1]);
       set<Id> setId =  LeaseDimensions.createCreditRecord(proposals, proposals);
      Test.stopTest();
    }
    catch(Exception e)
    {
    	System.Debug('ERROR MSG: ' + e.getMessage());
    }
    }
}