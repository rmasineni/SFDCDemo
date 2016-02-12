@isTest
public class Test_RedirectLMFromTandCExt {
    public static Contact partnerContact;
    
    @isTest static void initTest() {    

        setupData();
        Lead lead = new Lead(Company='PartnerTermsConditionsExtTest',LastName = 'PartnerTermsTest');
    	insert lead;
        
        PageReference testPage = Page.RedirectLMFromTandC;
        testPage.getParameters().put('returnId',lead.Id);
        testPage.getParameters().put('prospectId','1364269688');
        testPage.getParameters().put('selectedDesign','Design New Propsal');
        testPage.getParameters().put('returnPage','Lead'); 
        Test.setCurrentPage(testPage);
        
        ApexPages.StandardController controller = new ApexPages.StandardController(partnerContact);
        RedirectLMFromTandCExt controllerExtn = new RedirectLMFromTandCExt(controller);
        PageReference testRedirectUrl = controllerExtn.Init();
        system.debug('controllerExtn.redirectURL:' +controllerExtn.redirectURL);
        system.assert(controllerExtn.redirectURL.contains('lightmile'));
        
        Opportunity opty = new Opportunity(Name='RedirectLMFromTandCExtTest',StageName = 'Created',CloseDate = Date.Today()+30);
/*                               Average_Monthly_Electric_Bill__c = 1000,Square_footage__c = 1500,channel_2__c = 'Billboard',
                               Lead_Source_2__c = 'Billboard: Brilliant',Opportunity_Source_Type__c = 'BB',Utility_Company__c = 'PG&E',
                               Usage_Option__c = 'Basic',territory__c = 'Z', home_type__c = 'Detached single family home',
                               Market_Assignment_Install__c = ma.Id,Market_Assignment_Sales__c = ma.Id,Sales_Partner__c = sAccount.Id, 
                               Install_Partner__c = iAccount.Id, Sales_Rep_Division__c ='TestDiv',Sales_Rep_Email__c = 'test@PartnerLeadDetailTest.com');*/
        insert opty;
        
        Proposal__c prop = new Proposal__c();
        prop.Name='RedirectLMFromTandCExtTest';
        prop.Opportunity__c = Opty.Id;
        prop.Stage__c = 'Created';  
        prop.Sales_Rep_Email__c = 'therepsemail@repemailfake.com';
        prop.Date_Issued__c = Date.Today().addDays(18); 
        prop.Mode_Name__c = '1234';
        prop.System_Size_STC_DC__c  = 5.8;
        prop.Upfront_Payment__c = 20.0;
        prop.Sunrun_Credit_Status__c = 'SR Credit Approved';
        prop.EDP_Phase__c = 'EDP Phase-0';
    	insert prop;
        
        PageReference testPage1 = Page.RedirectLMFromTandC;
        testPage1.getParameters().put('returnId',prop.Id);
        testPage1.getParameters().put('prospectId','1364269688');
        testPage1.getParameters().put('selectedDesign','Modify Proposal');
        testPage1.getParameters().put('returnPage','Proposal'); 
        Test.setCurrentPage(testPage1);
        
        ApexPages.StandardController controller1 = new ApexPages.StandardController(partnerContact);
        RedirectLMFromTandCExt controllerExtn1 = new RedirectLMFromTandCExt(controller1);
        PageReference testRedirectUrl1 = controllerExtn1.Init();

        prop.Proposal_Source__c = 'BB';
        update prop; 
        testRedirectUrl1 = controllerExtn1.Init();
        system.debug('controllerExtn1.redirectURL:' +controllerExtn1.redirectURL);
        system.assert(controllerExtn1.redirectURL.contains('lightmile'));        
    }    

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