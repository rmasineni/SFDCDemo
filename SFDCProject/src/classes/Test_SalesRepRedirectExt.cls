@isTest(seeAllData=true)
private class Test_SalesRepRedirectExt {

    public static User partnerUser;
    public static Contact partnerContact;
    public static Lead leadSetupData;
   
    @isTest static void constructorTest() {
        setupData();
//Test Case: message='Sales Rep Message'
        Lead lead = new Lead(Company='PartnerTermsConditionsExtTest',LastName = 'PartnerTermsTest');
    	insert lead;
        List<Opportunity> lstOpp = new List<Opportunity>([select Id from opportunity limit 1]);
        PageReference partnerTandCPage = TermsConditionsUtil.redirectToTermsConditions(partnerContact.Id,lead.Id,'Lead','Design New Proposal','1364269688','PARTNER','P');

        PageReference testPage = Page.SalesRepRedirectLead;
        
        testPage.getParameters().put('Id',lead.Id);
        testPage.getParameters().put('message','Sales Rep Message');
        testPage.getParameters().put('redirectUrl',partnerTandCPage.getUrl());
        testPage.getParameters().put('partnerTandCAccepted','false'); 
        testPage.getParameters().put('partnerContactId',partnerContact.Id); 
        Test.setCurrentPage(testPage);

        ApexPages.StandardController controller = new ApexPages.StandardController(lead);
        SalesRepRedirectExt controllerExtn = new SalesRepRedirectExt(controller);

        System.assert(controllerExtn.message == 'You won\'t be able to generate proposal as Sales Rep is not identified.Click on OK to continue or Cancel to select a Sales Rep');
        
        List<TermsConditions__c> testPartnerTermsConditions = controllerExtn.getPartnerTermsConditions();
//        System.assert(!testPartnerTermsConditions.isEmpty());
        
        Test.setCurrentPage(partnerTandCPage);
        controllerExtn.declineTermsandConditions();
        
        Test.setCurrentPage(partnerTandCPage);
        controllerExtn.acceptTermsandConditions();
        
        partnerContact = [SELECT Id, T_C_Accepted__c, T_C_Accepted_Date__c FROM Contact WHERE Id =:partnerContact.Id];
        system.assert(partnerContact.T_C_Accepted__c);
        
//Test Case: message='Sales Rep Division Message'       
//        Lead lead1 = new Lead(Company='PartnerTermsConditionsExtTest1',LastName = 'PartnerTermsTest1');
//    	insert lead1;

        PageReference partnerTandCPage1 = TermsConditionsUtil.redirectToTermsConditions(partnerContact.Id,lead.Id,'Lead','Design New Proposal','1364269689','PARTNER','P');

        PageReference testPage1 = Page.SalesRepRedirectLead;
        testPage1.getParameters().put('Id',lead.Id);
        testPage1.getParameters().put('message','Sales Rep Division Message');
        testPage1.getParameters().put('redirectUrl',partnerTandCPage.getUrl());
        testPage1.getParameters().put('partnerTandCAccepted','false'); 
        testPage.getParameters().put('partnerContactId',partnerContact.Id); 
        Test.setCurrentPage(testPage1); 

        ApexPages.StandardController controller1 = new ApexPages.StandardController(lead);
        SalesRepRedirectExt controllerExtn1 = new SalesRepRedirectExt(controller1);
         
        System.assert(controllerExtn1.message == 'You won\'t be able to generate proposal as Sales Rep Division is not identified.Click on OK to continue or Cancel to select a Sales Rep Division');

//Test Case: message='County Message'       
//        Lead lead2 = new Lead(Company='PartnerTermsConditionsExtTest2',LastName = 'PartnerTermsTest2');
//    	insert lead2;

        PageReference partnerTandCPage2 = TermsConditionsUtil.redirectToTermsConditions(partnerContact.Id,lead.Id,'Lead','Design New Proposal','1364269690','PARTNER','P');

        PageReference testPage2 = Page.SalesRepRedirectLead;
        
        testPage2.getParameters().put('Id',lead.Id);
        testPage2.getParameters().put('message','County Message');
        testPage2.getParameters().put('redirectUrl',partnerTandCPage.getUrl());
        testPage2.getParameters().put('partnerTandCAccepted','false'); 
        testPage.getParameters().put('partnerContactId',partnerContact.Id); 
        Test.setCurrentPage(testPage2);

        ApexPages.StandardController controller2 = new ApexPages.StandardController(lead);
        SalesRepRedirectExt controllerExtn2 = new SalesRepRedirectExt(controller2);

        System.assert(controllerExtn2.message == 'You won\'t be able to generate proposal as County is not identified.Click on OK to continue or Cancel to select a County');
    
// Test RedirectToDesign() method
        PageReference testPage3 = Page.SalesRepRedirectLead;
       testPage.getParameters().put('Id',lstOpp[0].Id);
        //testPage3.getParameters().put('Id',lead.Id);
        testPage3.getParameters().put('message',' ');
        testPage3.getParameters().put('redirectUrl',partnerTandCPage.getUrl());
        testPage3.getParameters().put('partnerTandCAccepted','false'); 
        testPage3.getParameters().put('partnerContactId',partnerContact.Id); 
        Test.setCurrentPage(testPage3);
        
        ApexPages.StandardController controller3 = new ApexPages.StandardController(lead);
        SalesRepRedirectExt controllerExtn3 = new SalesRepRedirectExt(controller3);
 
        controllerExtn3.redirectToDesign();
        system.assert(controllerExtn3.displayTandCURL);
        
//Test redirect to Lightmile

        leadSetupData = new Lead(Company='Test_PartnerLeadDetail',LastName = 'PartnerLeadDetailTest',
                             Street = '123 Main St',State = 'CA',City = 'Union City',PostalCode = '94587',
                             FirstName = 'Test_PartnerLeadDetail',Email='test@PartnerLeadDetailTest.com');
        insert leadSetupData;
 
        String ObjectType = 'Lead';
        DesignTool.function='Design New Proposal';
        DesignToolWebservice.DesignToolWebserviceResponse responseObj = DesignTool.getDesignToolURL(leadSetupData.Id, '', ObjectType);
        system.debug('---Print url'+responseObj.url);

        PageReference testPage4 = Page.SalesRepRedirectLead;
        testPage.getParameters().put('Id',lstOpp[0].Id);
        //testPage4.getParameters().put('Id',leadSetupData.Id);
        testPage4.getParameters().put('message','Success');
        testPage4.getParameters().put('redirectUrl',responseObj.url);
        testPage4.getParameters().put('partnerTandCAccepted','true'); 
        testPage4.getParameters().put('partnerContactId',partnerContact.Id); 
        Test.setCurrentPage(testPage4);
        Test.startTest();
        ApexPages.StandardController controller4 = new ApexPages.StandardController(leadSetupData);
        SalesRepRedirectExt controllerExtn4 = new SalesRepRedirectExt(controller4);
 
        controllerExtn4.redirectToDesign();
        system.debug('SalesRepRedirectExt.redirectUrl:' +SalesRepRedirectExt.redirectUrl);
        system.assert(SalesRepRedirectExt.redirectUrl.contains('lightmile'));
        Test.StopTest();
    }
/*
    @isTest static void testReturnBack() {
        setupData();

//Test Case: Returning back to Lead page 
        Lead lead = new Lead(Company='PartnerTermsConditionsExtTest',LastName = 'PartnerTermsTest');
        insert lead;
        
        PageReference partnerTandCPage = TermsConditionsUtil.redirectToTermsConditions(partnerContact.Id,lead.Id,'Lead','Design New Proposal','1364269688','PARTNER','P');
        
        PageReference testPage = Page.SalesRepRedirectLead;
        testPage.getParameters().put('Id',lead.Id);
        testPage.getParameters().put('message','Sales Rep Message');
        testPage.getParameters().put('redirectUrl',partnerTandCPage.getUrl());
        testPage.getParameters().put('partnerTandCAccepted','false'); 
        testPage.getParameters().put('partnerContactId',partnerContact.Id);
        Test.setCurrentPage(testPage);
        
        ApexPages.StandardController controller = new ApexPages.StandardController(lead);
        SalesRepRedirectExt controllerExtn = new SalesRepRedirectExt(controller);
 
        PageReference testPr = controllerExtn.returnBack();
        Schema.DescribeSObjectResult c = lead.getSObjectType().getDescribe();
        String leadPrefix = c.getKeyPrefix();
        system.assert(testPr != null && testPr.getUrl().containsIgnoreCase(leadPrefix));       
    }    
*/   
    static void setupData() {

        Id accountRecTypeId = [select Id from RecordType where Name = 'Partner' and SobjectType = 'Account' limit 1].Id;
        Id contactRecTypeId = [select Id from RecordType where Name = 'Partner' and SobjectType = 'Contact' limit 1].Id;

        Account oAccount = new Account();
        oAccount.Name = 'PartnerTermsConditionsExtTest';
        oAccount.BillingStreet = '123 Unit Test Street';
        oAccount.BillingCity ='Union City';
        oAccount.BillingState = 'CA';
        oAccount.BillingPostalCode = '94587';
        oAccount.BillingCountry='US';
        oAccount.RecordTypeId = accountRecTypeId;
        insert oAccount;

        partnerContact = new Contact (AccountId = oAccount.id,LastName = 'portalTestUser',RecordTypeId = contactRecTypeId,
                                      FirstName='Test');
        insert partnerContact;

    }

}