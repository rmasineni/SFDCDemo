/*
  Test Methods for Hamm: EDP, ChannelMgmt.
  Coded by: Peter Alexander Mandy
  Date: 10022012:09:27:02.28
*/
@isTest(SeeAllData=true)
private class testCreditCheckAndLeaseDimensions {

    static testMethod void myUnitTest() {
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
    o.Utility_Company__c='Pacific Gas & Electric (PG&E)';	
    o.CloseDate = Date.Today().addDays(18);
    insert o;
    //
    
    List<Proposal__c> listProp = new List<Proposal__c>();
    Proposal__c prop = new Proposal__c();
    prop.Opportunity__c = o.Id;
    prop.Sales_Rep_Email__c = 'rep@repsfortesting.com';
    prop.Date_Issued__c = Date.Today().addDays(18);
    prop.Mode_Name__c = 'Mode323';
    prop.System_Size_STC_DC__c = 1290;
    prop.Upfront_Payment__c = 1290;
    listProp.add(prop);
    //
    Proposal__c prop2 = new Proposal__c();
    prop2.Opportunity__c = o.Id;
    prop2.Sales_Rep_Email__c = 'rep@repsfortesting.com';
    prop2.Date_Issued__c = Date.Today().addDays(18);
    prop2.Mode_Name__c = 'Mode323';
    prop2.System_Size_STC_DC__c = 1290;
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
    try{
       PageReference pr1 = CCCE.returnToContact();
    }catch(Exception e)
    {
    	System.Debug('Testing Error: ' + e.getMessage());
    }
    try{
    PageReference pr2 = CCCE.submitCreditCheck();
    }catch(Exception e)
    {
    	System.Debug('Testing Error: ' + e.getMessage());
    }    
    //
    try{
      PageReference pr4 = CCCE.ResendCreditCheckInvite();
    }catch(Exception e)
    {
       System.Debug('Testing Error: ' + e.getMessage());	
    } 
    
    try{
    	ApexPages.CurrentPage().getParameters().put('ProposalId', String.ValueOf(prop.Id));
    	ApexPages.StandardController scForContact2 = new ApexPages.StandardController(c2);
        ContactCreditCheckExtension CCCE2 = new ContactCreditCheckExtension(scForContact2);
        PageReference prCCCE2 = CCCE2.submitCreditCheck();
    }catch(Exception e)
    {
    	System.Debug('Testing Error: ' + e.getMessage());
    }
       
    try{
      PageReference pr5 = CCCE.CreditCheckRefresh();
    }catch(Exception e)
    {
    	System.Debug('Testing Error: ' + e.getMessage());
    }
    //
    try{
      PageReference prCreditCheckResend = new PageReference('/apex/CreditCheckResendContact?id=' + c.Id);
      prCreditCheckResend.setRedirect(true);
    }catch(Exception e)
    {
    	System.Debug('Testing Error: ' + e.getMessage());
    }
    //
    //
    PageReference prCCEdit = new PageReference('/apex/CreditCheck?id=' + cust_cred.Id + '&ProposalId=' + prop.Id);
    prCCEdit.setRedirect(true);
    //
    //ProposalId
    ApexPages.StandardController scCreditCheck = new ApexPages.StandardController(cust_cred);
    CreditCheckExtension CCExt = new CreditCheckExtension(scCreditCheck);
    CCExt.bExpired = false;
    CCExt.ProposalID = String.ValueOf(prop.Id);
    CCExt.StartingAccount = a.Id;
    CCExt.StartingContact = c.Id;
    
    try{
      PageReference prSNCC = CCExt.submitNewCreditCheck();
    }
    catch(Exception e)
    {
       System.Debug('Testing Error: ' + e.getMessage());
    }
    //
    try{
    	PageReference prRI = CCExt.resendInvitation();
    }
    catch(Exception e)
    {
       System.Debug('Testing Error: ' + e.getMessage());
    }
    //
    try{
       PageReference prRTCR = CCExt.returnToCreditRecord();
    }
    catch(Exception e)
    {
       System.Debug('Testing Error: ' + e.getMessage());
    }
    //
    try{
    	PageReference prCCR = CCExt.CreditCheckRefresh();
    }
    catch(Exception e)
    {
       System.Debug('Testing Error: ' + e.getMessage());
    }
    
    Test.startTest();
    //
    try{
    	CCExt.ProposalID = prop.Id;
        PageReference prSaveUpdateProp = CCExt.SaveAndUpdateProposal();
        CCExt.CCObj.Contact__c = null;   
        CCExt.CCObj.Approved__c = 'Passed Credit Check';
        CCExt.CCObj.Pending_Reason__c = 'Cannot cross out or write on contract';
    //
    try{
       PageReference prSaveUpdateProp2 = CCExt.SaveAndUpdateProposal();    
    }
    catch(Exception e)
    {
       System.Debug('Testing Error: ' + e.getMessage());
    }
    //
    try{
    	ApexPages.StandardController scCreditCheck2 = new ApexPages.StandardController(cust_cred_noCon);
        CreditCheckExtension CCExt2 = new CreditCheckExtension(scCreditCheck2);
    	CCExt2.ProposalID = prop.Id;    	
    	CCExt2.CCObj.Approved__c = 'Passed Credit Check';
        CCExt2.CCObj.Pending_Reason__c = 'Cannot cross out or write on contract';
        PageReference prSaveUpdateProp4 = CCExt2.SaveAndUpdateProposal();
    }
    catch(Exception e)
    {
       System.Debug('Testing Error: ' + e.getMessage());
    }    
    //
    try{
    	ApexPages.StandardController scCreditCheck3 = new ApexPages.StandardController(cust_cred2);
        CreditCheckExtension CCExt3 = new CreditCheckExtension(scCreditCheck3);
    	CCExt3.ProposalID = prop.Id;    	
    	CCExt3.CCObj.Approved__c = 'Passed Credit Check';
        CCExt3.CCObj.Pending_Reason__c = 'Cannot cross out or write on contract';
        PageReference prSaveUpdateProp5 = CCExt3.SaveAndUpdateProposal();
    }
    catch(Exception e)
    {
       System.Debug('Testing Error: ' + e.getMessage());
    }        
    //
    PageReference prCancelUpdateProp;
    prCancelUpdateProp = CCExt.CancelCCEdit();    
    prop.Current_Customer_Credit_Report__c = null;
    update prop;
    prCancelUpdateProp = CCExt.CancelCCEdit();
    }
    catch(Exception e)
    {
    	System.Debug('Testing Error: ' + e.getMessage());
    }
    //
    //    
    CreditCheckController CCC = new CreditCheckController();
    //
    ApexPages.CurrentPage().getParameters().put('OppId', String.ValueOf(o.Id));
    ApexPages.CurrentPage().getParameters().put('DefaultConId', String.ValueOf(c.Id));    
    //
    PageReference prInit = CCC.init();
    CCC.acct = a;
    CCC.opp = o;
    CCC.bAddCon = false;  
    //    
    //    
    CCC.selCC = String.ValueOf(c2.Id);
    PageReference prCreateData = CCC.createData();
    CCC.selCC = null;
    PageReference prCreateData2 = CCC.createData();
    //  
    PageReference prCancel = CCC.Cancel();
    try{
    	PageReference prCancelCC = CCC.CancelCreditCheck();
    }
        catch(Exception e)
    {
    	System.Debug('Testing Error: ' + e.getMessage());
    }
    //
    CCC.addCon.FirstName = 'TestFirst';
    CCC.addCon.LastName = 'TestLast';
    CCC.addCon.Email = 'TestFirstLast@sunruntester.com';
    try{
      PageReference prCreateCon = CCC.CreateContact();
    }    
    catch(Exception e)
    {
    	System.Debug('Testing Error: ' + e.getMessage());
    }
    //   
    try{    	    
      PageReference prCreateCon2 = CCC.CreateContact(); // Dupe Email
    }
    catch(Exception e)
    {
    	System.Debug('Testing Error: ' + e.getMessage());
    }
    CCC.addCon.LastName = null;
    try{
       PageReference prCreateCon3 = CCC.CreateContact(); // NULL Last Name
    }
    catch(Exception e)
    {
    	System.Debug('Testing Error: ' + e.getMessage());
    }
    //
    CCC.selCC = String.ValueOf(c.Id);
    //
    try{
    PageReference prAddCon = CCC.setbAddCon();
    }
    catch(Exception e)
    {
    	System.Debug('Testing Error: ' + e.getMessage());
    }
    try{
    PageReference prSelCon = CCC.setSelCon();
    }
    catch(Exception e)
    {
    	System.Debug('Testing Error: ' + e.getMessage());
    }
    try{
    PageReference prSubmitCC = CCC.SubmitCreditCheck();
    }
    catch(Exception e)
    {
    	System.Debug('Testing Error: ' + e.getMessage());
    }    
    //
    try{
    PageReference prOpptyCC = new PageReference('/apex/CreditCheckSubmittal?OppId=' + o.Id);
    prOpptyCC.setRedirect(true);
    }
    catch(Exception e)
    {
    	System.Debug('Testing Error: ' + e.getMessage());
    }
    //
    ApexPages.StandardController scSearch = new ApexPages.StandardController(prop);
    SearchCreditReports SCR = new SearchCreditReports(scSearch);
    SCR.creditReportObj.First_Name__c = 'Peter';
    SCR.creditReportObj.Last_Name__c = 'Mandy';
    SCR.creditReportObj.Customer_Email__c = 'Peter@Mandy.com';
    SCR.creditReportObj.City__c = 'Mill Valley';
    SCR.creditReportObj.State__c = 'CA';
    SCR.creditReportObj.Country__c = 'USA';
    SCR.creditReportObj.Zip__c = '99999';
    SCR.creditReportObj.contact__c = c.Id;
    //
    try{
    PageReference prCancelSearch = SCR.CancelSearch();
    }
    catch(Exception e)
    {
    	System.Debug('Testing Error: ' + e.getMessage());
    }
    SCR.applySearchFilter();
    SCR.address1 = '1290 Happy Path';
    SCR.address2 = '';
    SCR.city = 'San Francisco';
    ApexPages.Standardsetcontroller ssc = SCR.con;
    SCR.country = 'USA';
    SCR.creditReportObj = cust_cred;
    SCR.first();
    //
    List<Customer_Credit__c> listCustCredit = new List<Customer_Credit__c>();
    //
    cust_cred = SCR.getCreditReportObj();
    prop = SCR.getProposalObj();
    Boolean bNxt = SCR.hasNext;
    Boolean bPrv = SCR.hasPrevious;
    SCR.next();
    SCR.last();
    SCR.previous();
    SearchCreditReports.CreditReportWrapper CRW = new SearchCreditReports.CreditReportWrapper(cust_cred);    
    String s = SCR.newCreditReporturl;
    Integer i = SCR.pageNumber;
    String searchColName = SCR.searchColumnName;
    String searchVal = SCR.searchValue;
    String strState = SCR.state = 'CA';
    //
    //
    try{
    PageReference prPropCCSearch = new PageReference('/apex/SearchCreditReports?id=' + prop.Id);
    prPropCCSearch.setRedirect(true);
    }
    catch(Exception e)
    {
    	System.Debug('Testing Error: ' + e.getMessage());
    }
    try{
    	PageReference prNCR = SCR.NewCreditReport();
    	List<SearchCreditReports.CreditReportWrapper> listCRW = SCR.getCreditReportList();
    }
    catch(Exception e)
    {
    	System.Debug('Testing Error: ' + e.getMessage());
    }
    // 
    //
    // LEASE DIMENSIONS SPECIFIC TESTS
    try{
       String custnum = String.ValueOf(c.Id);
       // LEASE DIMENSIONS WebService SPECIFIC TESTS
       LeaseDimensionsWebService LDWS = new LeaseDimensionsWebService();
       LeaseDimensionsWebService.CreditInformation crdtInfo = new LeaseDimensionsWebService.CreditInformation();
       //
       crdtInfo.ContactNumber = custnum;     
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
       //
       crdtInfo.ContactNumber = cust_cred_APIrec.Id;     
       custnumresp = LeaseDimensionsWebService.SendCreditResponse(crdtInfo);
    }
    catch(Exception e)
    {
    	System.Debug('ERROR MSG: ' + e.getMessage());
    }
	Test.stopTest();

	
    }
    
    
//    
    
}