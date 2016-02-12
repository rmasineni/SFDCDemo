@isTest
private class Test_PartnerTermsConditionsExt {
    
    public static User partnerUser;
    public static Contact partnerContact; 
    @isTest static void constructorTest() {
        // set up the data
        setupData();

        Lead lead = new Lead(Company='PartnerTermsConditionsExtTest',LastName = 'PartnerTermsTest');
        insert lead;
        
        // Implement test code

        //System.runAs(partnerUser) {
            PageReference testPage = Page.PartnerTermsConditions;
            testPage.getParameters().put('Id',partnerContact.Id);
            testPage.getParameters().put('returnId',lead.Id);
            Test.setCurrentPage(testPage);

            ApexPages.StandardController controller = new ApexPages.StandardController(partnerContact);
            PartnerTermsConditionsExt controllerExtn = new PartnerTermsConditionsExt(controller);

            System.assert(controllerExtn.PartnerTermsConditions.size() == 0);
        //}
    }
  
    @isTest static void testLeadAcceptTermsConditionsFromPage() {
        // set up the data
        setupData();

        TermsConditions__c terms = new TermsConditions__c(TermsConditionsType__c = 'PARTNER', Active__c = True, SeqNo__c = 1.0, TermsConditionsInfo__c = 'Test');
        insert terms;

        Lead lead = new Lead(Company='PartnerTermsConditionsExtTest',LastName = 'PartnerTermsTest');
        insert lead;

        PageReference testPage = Page.PartnerTermsConditions;
        testPage.getParameters().put('Id',partnerContact.Id);
        testPage.getParameters().put('returnId',lead.Id);
        testPage.getParameters().put('returnPage','Lead');
        testPage.getParameters().put('selectedDesign','Design New Proposal');
        testPage.getParameters().put('tandCType','PARTNER');
        testPage.getParameters().put('prospectId','LTEST123');
        testPage.getParameters().put('src','P');
        Test.setCurrentPage(testPage);

        ApexPages.StandardController controller = new ApexPages.StandardController(partnerContact);
        PartnerTermsConditionsExt controllerExtn = new PartnerTermsConditionsExt(controller);

        System.assert(controllerExtn.PartnerTermsConditions.size() > 0);

        controllerExtn.declineTermsandConditions();
        System.assert(controllerExtn.displayTandCURL == false);
        
        controller = new ApexPages.StandardController(partnerContact);
        controllerExtn = new PartnerTermsConditionsExt(controller);
        controllerExtn.acceptTermsandConditions();

        partnerContact = [SELECT Id, T_C_Accepted__c, T_C_Accepted_Date__c FROM Contact WHERE Id =:partnerContact.Id];

        System.debug(LoggingLevel.INFO,'T_C_Accepted__c : '+partnerContact.T_C_Accepted__c);
        System.debug(LoggingLevel.INFO,'redirectURL : '+controllerExtn.redirectURL);
        system.assert(partnerContact.T_C_Accepted__c);
        system.assert(controllerExtn.redirectURL != null && controllerExtn.redirectURL.containsIgnoreCase('lightmile'));
    }


    @isTest static void testLeadAcceptTermsConditionsFromButton() {
        // set up the data
        setupData();

        TermsConditions__c terms = new TermsConditions__c(TermsConditionsType__c = 'PARTNER', Active__c = True, SeqNo__c = 1.0, TermsConditionsInfo__c = 'Test');
        insert terms;

        Lead lead = new Lead(Company='PartnerTermsConditionsExtTest',LastName = 'PartnerTermsTest');
        insert lead;

        PageReference testPage = Page.PartnerTermsConditions;
        testPage.getParameters().put('Id',partnerContact.Id);
        testPage.getParameters().put('returnId',lead.Id);
        testPage.getParameters().put('returnPage','Lead');
        testPage.getParameters().put('selectedDesign','Design New Proposal');
        testPage.getParameters().put('tandCType','PARTNER');
        testPage.getParameters().put('prospectId','LTEST123');
        testPage.getParameters().put('src','B');
        Test.setCurrentPage(testPage);

        ApexPages.StandardController controller = new ApexPages.StandardController(partnerContact);
        PartnerTermsConditionsExt controllerExtn = new PartnerTermsConditionsExt(controller);

        System.assert(controllerExtn.PartnerTermsConditions.size() > 0);

        controllerExtn.acceptTermsandConditions();

        partnerContact = [SELECT Id, T_C_Accepted__c, T_C_Accepted_Date__c FROM Contact WHERE Id =:partnerContact.Id];

        System.debug(LoggingLevel.INFO,'T_C_Accepted__c : '+partnerContact.T_C_Accepted__c);
        System.debug(LoggingLevel.INFO,'redirectURL : '+controllerExtn.redirectURL);
        system.assert(partnerContact.T_C_Accepted__c);
        system.assert(controllerExtn.redirectURL != null && controllerExtn.redirectURL.containsIgnoreCase('RedirectLMFromTandC'));
    }
    
    @isTest static void testLeadDeclineTermsandConditions() {
        System.debug(LoggingLevel.INFO,'Lead Decline');
        setupData();

        TermsConditions__c terms = new TermsConditions__c(TermsConditionsType__c = 'PARTNER', Active__c = True, SeqNo__c = 1.0, TermsConditionsInfo__c = 'Test');
        insert terms;

        Lead lead = new Lead(Company='PartnerTermsConditionsExtTest',LastName = 'PartnerTermsTest');
        insert lead;

        PageReference testPage = Page.PartnerTermsConditions;
        testPage.getParameters().put('Id',partnerContact.Id);
        testPage.getParameters().put('returnId',lead.Id);
        testPage.getParameters().put('returnPage','Lead');
        testPage.getParameters().put('selectedDesign','Design New Proposal');
        testPage.getParameters().put('tandCType','PARTNER');
        testPage.getParameters().put('prospectId','LTEST123');
        testPage.getParameters().put('src','P');
        Test.setCurrentPage(testPage);

        ApexPages.StandardController controller = new ApexPages.StandardController(partnerContact);
        PartnerTermsConditionsExt controllerExtn = new PartnerTermsConditionsExt(controller);

        System.assert(controllerExtn.PartnerTermsConditions.size() > 0);

        controllerExtn.declineTermsandConditions();

        partnerContact = [SELECT Id, T_C_Accepted__c, T_C_Accepted_Date__c FROM Contact WHERE Id =:partnerContact.Id];
        system.assert(!partnerContact.T_C_Accepted__c);

    }
  
    @isTest static void testOptyAcceptTermsConditionsFromPage() {
        // set up the data
        setupData();

        TermsConditions__c terms = new TermsConditions__c(TermsConditionsType__c = 'PARTNER', Active__c = True, SeqNo__c = 1.0, TermsConditionsInfo__c = 'Test');
        insert terms;

        Opportunity opty = new Opportunity(Name='PartnerTermsConditionsExtTest',StageName = 'Created',CloseDate= Date.Today()+30);
        insert opty;

        PageReference testPage = Page.PartnerTermsConditions;
        testPage.getParameters().put('Id',partnerContact.Id);
        testPage.getParameters().put('returnId',opty.Id);
        testPage.getParameters().put('returnPage','Opty');
        testPage.getParameters().put('selectedDesign','Design New Proposal');
        testPage.getParameters().put('tandCType','PARTNER');
        testPage.getParameters().put('prospectId','LTEST123');
        testPage.getParameters().put('src','P');
        Test.setCurrentPage(testPage);

        ApexPages.StandardController controller = new ApexPages.StandardController(partnerContact);
        PartnerTermsConditionsExt controllerExtn = new PartnerTermsConditionsExt(controller);

        System.assert(controllerExtn.PartnerTermsConditions.size() > 0);

        controllerExtn.acceptTermsandConditions();

        partnerContact = [SELECT Id, T_C_Accepted__c, T_C_Accepted_Date__c FROM Contact WHERE Id =:partnerContact.Id];
        
        System.debug(LoggingLevel.INFO,'T_C_Accepted__c : '+partnerContact.T_C_Accepted__c);
        System.debug(LoggingLevel.INFO,'redirectURL : '+controllerExtn.redirectURL);
        
        system.assert(partnerContact.T_C_Accepted__c);
        system.assert(controllerExtn.redirectURL != null && controllerExtn.redirectURL.containsIgnoreCase('lightmile'));
    }

  
    @isTest static void testOptyAcceptTermsConditionsFromButton() {
        // set up the data
        setupData();

        TermsConditions__c terms = new TermsConditions__c(TermsConditionsType__c = 'PARTNER', Active__c = True, SeqNo__c = 1.0, TermsConditionsInfo__c = 'Test');
        insert terms;

        Opportunity opty = new Opportunity(Name='PartnerTermsConditionsExtTest',StageName = 'Created',CloseDate= Date.Today()+30);
        insert opty;

        PageReference testPage = Page.PartnerTermsConditions;
        testPage.getParameters().put('Id',partnerContact.Id);
        testPage.getParameters().put('returnId',opty.Id);
        testPage.getParameters().put('returnPage','Opty');
        testPage.getParameters().put('selectedDesign','Design New Proposal');
        testPage.getParameters().put('tandCType','PARTNER');
        testPage.getParameters().put('prospectId','LTEST123');
        testPage.getParameters().put('src','B');
        Test.setCurrentPage(testPage);

        ApexPages.StandardController controller = new ApexPages.StandardController(partnerContact);
        PartnerTermsConditionsExt controllerExtn = new PartnerTermsConditionsExt(controller);

        System.assert(controllerExtn.PartnerTermsConditions.size() > 0);

        controllerExtn.acceptTermsandConditions();

        partnerContact = [SELECT Id, T_C_Accepted__c, T_C_Accepted_Date__c FROM Contact WHERE Id =:partnerContact.Id];
        
        System.debug(LoggingLevel.INFO,'T_C_Accepted__c : '+partnerContact.T_C_Accepted__c);
        System.debug(LoggingLevel.INFO,'redirectURL : '+controllerExtn.redirectURL);
        
        system.assert(partnerContact.T_C_Accepted__c);
        system.assert(controllerExtn.redirectURL != null && controllerExtn.redirectURL.containsIgnoreCase('RedirectLMFromTandC'));
    }
     
    @isTest static void testProposalAcceptTermsConditionsFromPage1() {
        // set up the data
        setupData();

        TermsConditions__c terms = new TermsConditions__c(TermsConditionsType__c = 'PARTNER', Active__c = True, SeqNo__c = 1.0, TermsConditionsInfo__c = 'Test');
        insert terms;

        Opportunity opty = new Opportunity(Name='PartnerTermsConditionsExtTest',StageName = 'Created',CloseDate= Date.Today()+30);
        insert opty;

        Proposal__c p = new Proposal__c(Name='PartnerTermsConditionsExtTestPropsal',Opportunity__c=opty.id,
                                        Proposal_Source__c='BB',Sales_Rep_Email__c='PartnerTermsConditionsExtTestPropsal@yopmail.com',
                                        Date_Issued__c=Date.Today(),System_Size_STC_DC__c=10,Upfront_Payment__c=500);
        insert p;
        
        PageReference testPage = Page.PartnerTermsConditions;
        testPage.getParameters().put('Id',partnerContact.Id);
        testPage.getParameters().put('returnId',p.Id);
        testPage.getParameters().put('returnPage','Proposal');
        testPage.getParameters().put('selectedDesign','Design New Proposal');
        testPage.getParameters().put('tandCType','PARTNER');
        testPage.getParameters().put('prospectId','LTEST123');
        testPage.getParameters().put('src','P');
        Test.setCurrentPage(testPage);

        ApexPages.StandardController controller = new ApexPages.StandardController(partnerContact);
        PartnerTermsConditionsExt controllerExtn = new PartnerTermsConditionsExt(controller);

        System.assert(controllerExtn.PartnerTermsConditions.size() > 0);

        controllerExtn.acceptTermsandConditions();

        partnerContact = [SELECT Id, T_C_Accepted__c, T_C_Accepted_Date__c FROM Contact WHERE Id =:partnerContact.Id];
        
        System.debug(LoggingLevel.INFO,'T_C_Accepted__c : '+partnerContact.T_C_Accepted__c);
        System.debug(LoggingLevel.INFO,'redirectURL : '+controllerExtn.redirectURL);
        
        system.assert(partnerContact.T_C_Accepted__c);
        system.assert(controllerExtn.redirectURL != null && controllerExtn.redirectURL.containsIgnoreCase('lightmile'));
    }

    @isTest static void testProposalAcceptTermsConditionsFromPage2() {
        // set up the data
        setupData();

        TermsConditions__c terms = new TermsConditions__c(TermsConditionsType__c = 'PARTNER', Active__c = True, SeqNo__c = 1.0, TermsConditionsInfo__c = 'Test');
        insert terms;

        Opportunity opty = new Opportunity(Name='PartnerTermsConditionsExtTest',StageName = 'Created',CloseDate= Date.Today()+30);
        insert opty;

        Proposal__c p = new Proposal__c(Name='PartnerTermsConditionsExtTestPropsal',Opportunity__c=opty.id,
                                        Proposal_Source__c='BB',Sales_Rep_Email__c='PartnerTermsConditionsExtTestPropsal@yopmail.com',
                                        Date_Issued__c=Date.Today(),System_Size_STC_DC__c=10,Upfront_Payment__c=500,
                                        Stage__c='Voided');
        insert p;
        
        PageReference testPage = Page.PartnerTermsConditions;
        testPage.getParameters().put('Id',partnerContact.Id);
        testPage.getParameters().put('returnId',p.Id);
        testPage.getParameters().put('returnPage','Proposal');
        testPage.getParameters().put('selectedDesign','Design New Proposal');
        testPage.getParameters().put('tandCType','PARTNER');
        testPage.getParameters().put('prospectId','LTEST123');
        testPage.getParameters().put('src','P');
        Test.setCurrentPage(testPage);

        ApexPages.StandardController controller = new ApexPages.StandardController(partnerContact);
        PartnerTermsConditionsExt controllerExtn = new PartnerTermsConditionsExt(controller);

        System.assert(controllerExtn.PartnerTermsConditions.size() > 0);

        controllerExtn.acceptTermsandConditions();

        partnerContact = [SELECT Id, T_C_Accepted__c, T_C_Accepted_Date__c FROM Contact WHERE Id =:partnerContact.Id];
        
        System.debug(LoggingLevel.INFO,'T_C_Accepted__c : '+partnerContact.T_C_Accepted__c);
        System.debug(LoggingLevel.INFO,'redirectURL : '+controllerExtn.redirectURL);
        
        system.assert(partnerContact.T_C_Accepted__c);
        system.assert(controllerExtn.redirectURL != null && controllerExtn.redirectURL.containsIgnoreCase('TandCModifyProposalError'));
    }
        
    @isTest static void testProposalAcceptTermsConditionsFromButton() {
        // set up the data
        setupData();

        TermsConditions__c terms = new TermsConditions__c(TermsConditionsType__c = 'PARTNER', Active__c = True, SeqNo__c = 1.0, TermsConditionsInfo__c = 'Test');
        insert terms;

        Opportunity opty = new Opportunity(Name='PartnerTermsConditionsExtTest',StageName = 'Created',CloseDate= Date.Today()+30);
        insert opty;

        Proposal__c p = new Proposal__c(Name='PartnerTermsConditionsExtTestPropsal',Opportunity__c=opty.id,
                                        Proposal_Source__c='BB',Sales_Rep_Email__c='PartnerTermsConditionsExtTestPropsal@yopmail.com',
                                        Date_Issued__c=Date.Today(),System_Size_STC_DC__c=10,Upfront_Payment__c=500);
        insert p;
        
        PageReference testPage = Page.PartnerTermsConditions;
        testPage.getParameters().put('Id',partnerContact.Id);
        testPage.getParameters().put('returnId',p.Id);
        testPage.getParameters().put('returnPage','Proposal');
        testPage.getParameters().put('selectedDesign','Design New Proposal');
        testPage.getParameters().put('tandCType','PARTNER');
        testPage.getParameters().put('prospectId','LTEST123');
        testPage.getParameters().put('src','B');
        Test.setCurrentPage(testPage);

        ApexPages.StandardController controller = new ApexPages.StandardController(partnerContact);
        PartnerTermsConditionsExt controllerExtn = new PartnerTermsConditionsExt(controller);

        System.assert(controllerExtn.PartnerTermsConditions.size() > 0);

        controllerExtn.acceptTermsandConditions();

        partnerContact = [SELECT Id, T_C_Accepted__c, T_C_Accepted_Date__c FROM Contact WHERE Id =:partnerContact.Id];
        
        System.debug(LoggingLevel.INFO,'T_C_Accepted__c : '+partnerContact.T_C_Accepted__c);
        System.debug(LoggingLevel.INFO,'redirectURL : '+controllerExtn.redirectURL);
        
        system.assert(partnerContact.T_C_Accepted__c);
        system.assert(controllerExtn.redirectURL != null && controllerExtn.redirectURL.containsIgnoreCase('RedirectLMFromTandC'));
    }

    static void setupData() {
        // selecting partner profile to be used for user creation
        Profile partnerProfile = [select Id,Name from Profile where Name = 'PartnerOperations' limit 1];
        System.debug(LoggingLevel.INFO,'partnerProfile : '+partnerProfile);
        // selecting record type for partner
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

        partnerUser = new User(alias = 'standt', email='standarduser@PartnerTermsConditionsExtTest.com',
                      emailencodingkey='UTF-8', lastname='PartnerTermsConditionsExtTest', LanguageLocaleKey='en_US',
                      localesidkey='en_US', profileid = partnerProfile.Id,timezonesidkey='America/Los_Angeles',
                      username='systemadmin@testorg.com',contactId=partnerContact.Id,Title='PartnerTermsConditionsExtTest',
                      FirstName='Test');
               
        insert partnerUser;
    }
}