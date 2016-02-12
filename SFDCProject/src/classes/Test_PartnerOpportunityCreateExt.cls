@isTest(SeeAllData=true)

public with sharing class Test_PartnerOpportunityCreateExt {    
    public static User sysAdminUser;
    public static User powerPartnerUser;
    public static Contact powerPartnerContact;
    public static User sysAdmin;
    public static Opportunity opty;
    public static boolean createUser; 
    public static boolean createOpty;
    public static boolean createPartnerRole; 
    public static Account oAccount;
    public static Account sAccount;
    public static Account iAccount;
    public static Account pAccount;
    public static Account uAccount;
    public static Account leadForPassingAccount;
    public static Market__c market; 
    public static Market_Assignment__c ma;
    public static OpportunityContactRole OCR;
    public static Partner_Role__c prSales;
    public static Partner_Role__c prInstall;
    public static List<Partner_Role__c> prList;
    public static List<Account> accountList;
    
    static testmethod void Test_PartnerOpportunityCreateExt(){
        Map<String, Schema.SObjectType> m  = Schema.getGlobalDescribe() ;
        Schema.SObjectType s = m.get('Account');
        Schema.DescribeSObjectResult cfrSchema = s.getDescribe() ;
        Map<String,Schema.RecordTypeInfo> RecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id rtId = RecordTypeInfo.get('Residential').getRecordTypeId();   
        
        Account account = new Account();
        account.Name = 'Test';  
        account.RecordTypeId = rtId;
        account.billingstreet='111 Lakeridge Ln';
        account.billingcity='San Ramon';    
        account.billingstate='CA';
        account.billingpostalcode='00000';
        account.Zip_6__c='94086';
        insert account;
        
        Opportunity oppotyObj = new Opportunity();
        oppotyObj.AccountId = account.Id;
        oppotyObj.name = 'Test';
        oppotyObj.CloseDate = date.today().addDays(3);
        oppotyObj.StageName = 'Assigned';   
        oppotyObj.Territory__c='P'; 
        oppotyObj.Jan_Usage__c=201;
        oppotyObj.Feb_Usage__c=201;
        oppotyObj.Mar_Usage__c=201;
        oppotyObj.Apr_Usage__c=201;
        oppotyObj.May_Usage__c=201;
        oppotyObj.Jun_Usage__c=201;
        oppotyObj.Jul_Usage__c=201;
        oppotyObj.Aug_Usage__c=201;
        oppotyObj.Sep_Usage__c=201;
        oppotyObj.Oct_Usage__c=201;
        oppotyObj.Nov_Usage__c=201;
        oppotyObj.Dec_Usage__c=201;
        oppotyObj.Utility_Company__c='PG&E';    
        oppotyObj.Usage_Option__c='Basic';   
        insert oppotyObj;          
        ApexPages.StandardController controller = new Apexpages.Standardcontroller(oppotyObj); 
        PartnerOpportunityCreateExt POC=new PartnerOpportunityCreateExt(controller);
        Pagereference p=POC.redirect();
        p=POC.cancel();
        p=POC.redirectToDesign();
        p=POC.confirmRedirectToDesign();
        p=POC.onLoad();               
        POC.getPayTransOptions();
        POC.closePopup();
        POC.paymentTransactionRedirect();
        POC.selectedPayTransc='OneTimePayment';
        POC.paymentTransactionRedirect();
        POC.selectedPayTransc='SendRequestForAutoPaymentEmail';
        POC.paymentTransactionRedirect();
        POC.selectedPayTransc='SendRequestForPaymentEmail';
        POC.paymentTransactionRedirect();
        POC.selectedPayTransc='EnrollForAutoPayment';
        POC.paymentTransactionRedirect();
       // oppotyObj.Utility_Company__c=null;
       // oppotyObj.Territory__c=null;
       // update oppotyObj;       
        ApexPages.StandardController controller2 = new Apexpages.Standardcontroller(oppotyObj); 
        PartnerOpportunityCreateExt POC2=new PartnerOpportunityCreateExt(controller2);
        Pagereference p2=POC2.redirectToDesign();
        oppotyObj.Jan_Usage__c=0;
        oppotyObj.Feb_Usage__c=0;
        oppotyObj.Mar_Usage__c=0;
        oppotyObj.Apr_Usage__c=0;
        oppotyObj.May_Usage__c=0;
        oppotyObj.Jun_Usage__c=0;
        update oppotyObj;
        ApexPages.StandardController controller3 = new Apexpages.Standardcontroller(oppotyObj); 
        PartnerOpportunityCreateExt POC3=new PartnerOpportunityCreateExt(controller3);
        Pagereference p3=POC3.redirectToDesign();
        account.Zip_6__c=null;
        update account;
        ApexPages.StandardController controller1 = new Apexpages.Standardcontroller(oppotyObj); 
        PartnerOpportunityCreateExt POC1=new PartnerOpportunityCreateExt(controller1);
        Pagereference p1=POC1.redirectToDesign();                      
    }

    public static testMethod void testRedirectDesignToolMethod1()  {
        createUser = false; 
        createPartnerRole = false;
        createOpty = true; 
        setupOptyData();
        opty.home_type__c = null; 
        update opty; 
        
        ApexPages.StandardController stdcon = new ApexPages.StandardController(opty);
        PartnerOpportunityCreateExt PartnerOpportunityCreateExtObj = new PartnerOpportunityCreateExt(stdcon);

        PartnerOpportunityCreateExtObj.selectedDesign = 'Design New Proposal';
        System.debug(LoggingLevel.INFO,'Call redirectDesignTool():1 ');
        PartnerOpportunityCreateExtObj.redirectDesignTool();        
        System.debug(LoggingLevel.INFO,'redirectURL : '+PartnerOpportunityCreateExtObj.redirectURL);
        System.debug(LoggingLevel.INFO,'displayPopupMessage : '+PartnerOpportunityCreateExtObj.displayPopupMessage);

        System.assert(PartnerOpportunityCreateExtObj.displayPopupMessage != null && 
                      PartnerOpportunityCreateExtObj.displayPopupMessage.equalsIgnoreCase('Home type is required to create design'));
        System.assert(PartnerOpportunityCreateExtObj.displayPopup);

    }

    public static testMethod void testRedirectDesignToolMethod2() {
        createUser = true; 
        createPartnerRole = false; 
        setupOptyData();
        opty.Purchased_Thru__c = 'Standard (Non-Retail)';
        update opty;

        System.runAs(sysAdminUser) {
        System.assert(UserInfo.getUserId() == sysAdminUser.Id);

        ApexPages.StandardController stdcon = new ApexPages.StandardController(opty);
        PartnerOpportunityCreateExt PartnerOpportunityCreateExtObj = new PartnerOpportunityCreateExt(stdcon);

        System.debug(LoggingLevel.INFO,'Call redirectDesignTool():2 ');
        PartnerOpportunityCreateExtObj.selectedDesign = 'Design New Proposal';
        PartnerOpportunityCreateExtObj.redirectDesignTool();  
                        
// Since Partner Role record is not created, 
// CDYNE returns error message "Sales Rep Message" and the control is redirected to SalesRepRedirect
        System.debug(LoggingLevel.INFO,'redirectURL : '+PartnerOpportunityCreateExtObj.redirectURL);
        System.debug(LoggingLevel.INFO,'SalesRepURL : '+PartnerOpportunityCreateExtObj.SalesRepURL);    
        System.assert(PartnerOpportunityCreateExtObj.SalesRepURL.containsIgnoreCase('SalesRepRedirect'));
        }
    }

    public static testMethod void testRedirectDesignToolMethod3() {
        createUser = true; 
        createPartnerRole = true;
        setupOptyData();

        System.runAs(sysAdminUser) {
        System.assert(UserInfo.getUserId() == sysAdminUser.Id);

        ApexPages.StandardController stdcon = new ApexPages.StandardController(opty);
        PartnerOpportunityCreateExt PartnerOpportunityCreateExtObj = new PartnerOpportunityCreateExt(stdcon);

        System.debug(LoggingLevel.INFO,'Call redirectDesignTool():3 ');
        PartnerOpportunityCreateExtObj.selectedDesign = 'Design New Proposal';
        PartnerOpportunityCreateExtObj.redirectDesignTool();  
            
            
// Since Partner Role record is not created, 
// CDYNE returns error message "Sales Rep Message" and the control is redirected to SalesRepRedirect
        System.debug(LoggingLevel.INFO,'redirectURL : '+PartnerOpportunityCreateExtObj.redirectURL);
        System.debug(LoggingLevel.INFO,'SalesRepURL : '+PartnerOpportunityCreateExtObj.SalesRepURL);    
        System.assert(PartnerOpportunityCreateExtObj.redirectURL.containsIgnoreCase('partnertermsconditions'));
            
        Contact currentContact = [select Id,T_C_Accepted__c from Contact where Id =: PartnerOpportunityCreateExtObj.partnerContactId limit 1];
        currentContact.T_C_Accepted__c = true;
        update currentContact;

// Checking the rest of the flow when CRM user has accepted T&C
         stdcon = new ApexPages.StandardController(opty);
         PartnerOpportunityCreateExtObj = new PartnerOpportunityCreateExt(stdcon);  
         PartnerOpportunityCreateExtObj.selectedDesign = '--None--';   
         PartnerOpportunityCreateExtObj.redirectDesignTool();
            
         PartnerOpportunityCreateExtObj.selectedDesign = 'Design New Proposal';            
         PartnerOpportunityCreateExtObj.redirectDesignTool();

         System.assert(PartnerOpportunityCreateExtObj.redirectURL.containsIgnoreCase('lightmile'));

         List<TermsConditions__c> testPartnerTermsConditions = PartnerOpportunityCreateExtObj.getPartnerTermsConditions();
         System.assert(!testPartnerTermsConditions.isEmpty());
            
         currentContact = [select Id,T_C_Accepted__c from Contact where Id =: PartnerOpportunityCreateExtObj.partnerContactId limit 1];
         currentContact.T_C_Accepted__c = false;
         update currentContact;
            
         PageReference partnerTandCPage = TermsConditionsUtil.redirectToTermsConditions(PartnerOpportunityCreateExtObj.partnerContactId,opty.Id,'Opty','Design New Proposal','1364269688','PARTNER','P');
         Test.setCurrentPage(partnerTandCPage);
         PartnerOpportunityCreateExtObj.declineTermsandConditions();
        
         Test.setCurrentPage(partnerTandCPage);
         PartnerOpportunityCreateExtObj.acceptTermsandConditions();
      
         currentContact = [select Id,T_C_Accepted__c from Contact where Id =: PartnerOpportunityCreateExtObj.partnerContactId limit 1];
         system.assert(currentContact.T_C_Accepted__c);
      
         Contact uContact = [select id, T_C_Accepted__c from Contact where Sunrun_User__c=:userinfo.getUserId() AND 
                                  Email= :PartnerOpportunityCreateExtObj.CurrentUser.Email AND Contact_Type__c='Employee'];
         uContact.Design_New_Proposal__c='Granted';
         update uContact; 

         stdcon = new ApexPages.StandardController(opty);
         PartnerOpportunityCreateExtObj = new PartnerOpportunityCreateExt(stdcon);  
         List<SelectOption> getDesignTypesOptions = PartnerOpportunityCreateExtObj.getDesignTypes();              

//Test missing contact scenario            
         delete uContact; 
            
         stdcon = new ApexPages.StandardController(opty);
         PartnerOpportunityCreateExtObj = new PartnerOpportunityCreateExt(stdcon);  
            
         PartnerOpportunityCreateExtObj.selectedDesign = 'Design New Proposal';            
         PartnerOpportunityCreateExtObj.redirectDesignTool();

         System.assert(PartnerOpportunityCreateExtObj.displayPopupMessage != null && 
                      PartnerOpportunityCreateExtObj.displayPopupMessage.equalsIgnoreCase('The valid user contact is required'));
         System.assert(PartnerOpportunityCreateExtObj.displayPopup);

        }
    }    

    public static testMethod void testRedirectDesignToolMethodPRM() {

        setupOptyDataPRM();        
        Test.startTest();
        setupPowerPartnerData();
        List<AccountShare> ashareList=new List<AccountShare>();        
        AccountShare aShare1=new AccountShare();
        aShare1.AccountId = iAccount.Id;
        aShare1.UserOrGroupId = powerPartnerUser.id;
        aShare1.AccountAccessLevel = 'Edit';
        aShare1.ContactAccessLevel = 'Edit';
        aShare1.OpportunityAccessLevel = 'Edit';
        AccountShare aShare2=new AccountShare();
        aShare2.AccountId = sAccount.Id;
        aShare2.UserOrGroupId = powerPartnerUser.id;
        aShare2.AccountAccessLevel = 'Edit';
        aShare2.ContactAccessLevel = 'Edit';
        aShare2.OpportunityAccessLevel = 'Edit';
        ashareList.add(aShare1);
        ashareList.add(aShare2);
        insert ashareList;
        System.runAs(powerPartnerUser) {
            System.assert(UserInfo.getUserId() == powerPartnerUser.Id);
            System.debug(LoggingLevel.INFO,'powerPartnerUser.Id : '+powerPartnerUser.Id);
            opty = new Opportunity(Name='PartnerOpportunityCreateExtTest',StageName = 'Created',CloseDate = Date.Today()+30,
                               Average_Monthly_Electric_Bill__c = 1000,Square_footage__c = 1500,channel_2__c = 'Billboard',
                               Lead_Source_2__c = 'Billboard: Brilliant',Opportunity_Source_Type__c = 'BB',Utility_Company__c = 'PG&E',
                               Usage_Option__c = 'Basic',territory__c = 'Z', home_type__c = 'Detached single family home',
                               Market_Assignment_Install__c = ma.Id,Market_Assignment_Sales__c = ma.Id,Sales_Partner__c = sAccount.Id, 
                               Install_Partner__c = iAccount.Id, Sales_Rep_Division__c ='TestDiv',Sales_Rep_Email__c = 'test@PartnerLeadDetailTest.com');
            insert opty;                                        
        }
        Test.stopTest();  

        System.runAs(powerPartnerUser) {
            OCR = new OpportunityContactRole(ContactId=powerPartnerContact.id,OpportunityId=opty.id,Role='Homeowner',isprimary=true);
            insert OCR;    
          
//            PR = new Partner_Role__c(Role__c='Sales',Opportunity__c=opty.id,
//                                     Sales_Rep_Email__c='PartnerOpportunityCreatePR@yopmail.com',
//                                     Sales_Rep_Division__c='TestDiv');
//            insert pr;  
            prList = new List<Partner_Role__c>();
            prSales = new Partner_Role__c(Role__c='Sales',Opportunity__c=opty.id,Partner_Name__c=sAccount.Id,
                                     Sales_Rep_Email__c='PartnerOpportunityCreatePR@yopmail.com',
                                     Sales_Rep_Division__c='TestDiv');
            prList.add(prSales);
            prInstall = new Partner_Role__c(Role__c='Install',Opportunity__c=opty.id,Partner_Name__c=iAccount.Id,
                                     Sales_Rep_Email__c='PartnerOpportunityCreatePR@yopmail.com',
                                     Sales_Rep_Division__c='TestDiv');
            prList.add(prInstall);
            insert prList;

            ApexPages.StandardController stdcon = new ApexPages.StandardController(opty);
            PartnerOpportunityCreateExt PartnerOpportunityCreateExtObj = new PartnerOpportunityCreateExt(stdcon);
    
            System.debug(LoggingLevel.INFO,'Call redirectDesignTool():3 ');
            PartnerOpportunityCreateExtObj.selectedDesign = 'Design New Proposal';
            PartnerOpportunityCreateExtObj.redirectDesignTool();   
            System.assert(PartnerOpportunityCreateExtObj.displayTandCURL);
            
            Contact currentContact = [select Id,T_C_Accepted__c from Contact where Id =: PartnerOpportunityCreateExtObj.partnerContactId limit 1];
            currentContact.T_C_Accepted__c = true;
            update currentContact;

// Checking the rest of the flow when CRM user has accepted T&C
            stdcon = new ApexPages.StandardController(opty);
            PartnerOpportunityCreateExtObj = new PartnerOpportunityCreateExt(stdcon);  
            PartnerOpportunityCreateExtObj.selectedDesign = '--None--';   
            PartnerOpportunityCreateExtObj.redirectDesignTool();
               
            PartnerOpportunityCreateExtObj.selectedDesign = 'Design New Proposal';            
            PartnerOpportunityCreateExtObj.redirectDesignTool();
    
            System.assert(PartnerOpportunityCreateExtObj.redirectURL.containsIgnoreCase('lightmile'));
            
            PartnerOpportunityCreateExtObj.showScheduler();
            PartnerOpportunityCreateExtObj.declineTermsandConditions();
            PartnerOpportunityCreateExtObj.acceptTermsandConditions();
            PartnerOpportunityCreateExtObj.getPartnerTermsConditions();
            PartnerOpportunityCreateExtObj.partnerSungevity();
            PartnerOpportunityCreateExtObj.getApptCategories();
        } 

    }     
    
    
    static void setupOptyData(){
        Id accountRecTypeId = [select Id from RecordType where Name = 'Partner' and SobjectType = 'Account' limit 1].Id;
          
        accountList = new List<Account>();
            
        oAccount = new Account();
        oAccount.Name = 'PartnerTermsConditionsExtTest';
        oAccount.BillingStreet = '123 Unit Test Street';
        oAccount.BillingCity ='Union City';
        oAccount.BillingState = 'CA';
        oAccount.BillingPostalCode = '94587';
        oAccount.BillingCountry='US';
        oAccount.RecordTypeId = accountRecTypeId;
        
        accountList.add(oAccount);
        
        Id accountRecTypeId1 = [select Id from RecordType where Name = 'Company' and SobjectType = 'Account' limit 1].Id;   
        
        sAccount = new Account();
        sAccount.Name = 'SalesPartnerTermsConditionsExtTest';
        sAccount.BillingStreet = '345 Unit Test Street';
        sAccount.BillingCity ='Union City';
        sAccount.BillingState = 'CA';
        sAccount.BillingPostalCode = '94587';
        sAccount.BillingCountry='US';
        sAccount.RecordTypeId = accountRecTypeId1;
        
        accountList.add(sAccount);        
        
        iAccount = new Account();
        iAccount.Name = 'InstallPartnerTermsConditionsExtTest';
        iAccount.BillingStreet = '678 Unit Test Street';
        iAccount.BillingCity ='Union City';
        iAccount.BillingState = 'CA';
        iAccount.BillingPostalCode = '94587';
        iAccount.BillingCountry='US';
        iAccount.RecordTypeId = accountRecTypeId1;
        
        accountList.add(iAccount);      
        
        insert accountList; 
        
        Contact testContact = new Contact(LastName='PartnerOpportunityCreateExt',AccountId=oAccount.id); 
        insert testContact; 
        
        market = new Market__c(Duration_in_days__c = 10,Number_of_Leads__c =10,State__c='CA',Utility_Company__c='Pacific Gas & Electric (PG&E)');
        insert market;

        ma = new Market_Assignment__c(Market__c=market.Id,Partner__c=oAccount.Id);
        insert ma; 
        
        Test.startTest();
        opty = new Opportunity(Name='PartnerOpportunityCreateExtTest',StageName = 'Created',CloseDate = Date.Today()+30, Purchased_Thru__c = 'Standard (Non-Retail)',
                               Average_Monthly_Electric_Bill__c = 1000,Square_footage__c = 1500,channel_2__c = 'Billboard',
                               Lead_Source_2__c = 'Billboard: Brilliant',Opportunity_Source_Type__c = 'BB',Utility_Company__c = 'PG&E',
                               Usage_Option__c = 'Basic',territory__c = 'Z', home_type__c = 'Detached single family home',
                               Market_Assignment_Install__c = ma.Id,Market_Assignment_Sales__c = ma.Id,Sales_Partner__c = sAccount.Id, 
                               Install_Partner__c = iAccount.Id, Sales_Rep_Division__c ='TestDiv',Sales_Rep_Email__c = 'test@PartnerLeadDetailTest.com');
        insert opty;
        If (createUser){
            setupData();
        }
            
        Test.stopTest(); 
        
        OCR = new OpportunityContactRole(ContactId=testContact.id,OpportunityId=opty.id,Role='Homeowner',isprimary=true);
        insert OCR;    
        
        if (createPartnerRole){
            prList = new List<Partner_Role__c>();
            prSales = new Partner_Role__c(Role__c='Sales',Opportunity__c=opty.id,Partner_Name__c=sAccount.Id,
                                     Sales_Rep_Email__c='PartnerOpportunityCreatePR@yopmail.com',
                                     Sales_Rep_Division__c='TestDiv');
            prList.add(prSales);
            prInstall = new Partner_Role__c(Role__c='Install',Opportunity__c=opty.id,Partner_Name__c=iAccount.Id,
                                     Sales_Rep_Email__c='PartnerOpportunityCreatePR@yopmail.com',
                                     Sales_Rep_Division__c='TestDiv');
            prList.add(prInstall);
            insert prList;
        }
    }    

    static void setupOptyDataPRM(){
        Id accountRecTypeId = [select Id from RecordType where Name = 'Partner' and SobjectType = 'Account' limit 1].Id;
          
        accountList = new List<Account>();
        
        oAccount = new Account();
        oAccount.Name = 'PartnerTermsConditionsExtTest';
        oAccount.BillingStreet = '123 Unit Test Street';
        oAccount.BillingCity ='Union City';
        oAccount.BillingState = 'CA';
        oAccount.BillingPostalCode = '94587';
        oAccount.BillingCountry='US';
        oAccount.RecordTypeId = accountRecTypeId;
        
        accountList.add(oAccount);
        
        Id accountRecTypeId1 = [select Id from RecordType where Name = 'Company' and SobjectType = 'Account' limit 1].Id;   
        
        sAccount = new Account();
        sAccount.Name = 'SalesPartnerTermsConditionsExtTest';
        sAccount.BillingStreet = '345 Unit Test Street';
        sAccount.BillingCity ='Union City';
        sAccount.BillingState = 'CA';
        sAccount.BillingPostalCode = '94587';
        sAccount.BillingCountry='US';
        sAccount.RecordTypeId = accountRecTypeId1;
        
        accountList.add(sAccount);        
        
        iAccount = new Account();
        iAccount.Name = 'InstallPartnerTermsConditionsExtTest';
        iAccount.BillingStreet = '678 Unit Test Street';
        iAccount.BillingCity ='Union City';
        iAccount.BillingState = 'CA';
        iAccount.BillingPostalCode = '94587';
        iAccount.BillingCountry='US';
        iAccount.RecordTypeId = accountRecTypeId1;
        
        accountList.add(iAccount);        

        uAccount = new Account();
        uAccount.Name = 'UltimateParentPartnerTermsConditionsExtTest';
        uAccount.BillingStreet = '505 Unit Test Street';
        uAccount.BillingCity ='Union City';
        uAccount.BillingState = 'CA';
        uAccount.BillingPostalCode = '94587';
        uAccount.BillingCountry='US';
        uAccount.RecordTypeId = accountRecTypeId;
        uAccount.Stage__c = 'Confirmed';    
        uAccount.Office_Location__c = 'Headquarters';
        uAccount.Active__c = true; 
        
        accountList.add(uAccount);        
        
        insert accountList;
        
        Contact testContact = new Contact(LastName='PartnerOpportunityCreateExt',AccountId=oAccount.id); 
        insert testContact; 
        
        market = new Market__c(Duration_in_days__c = 10,Number_of_Leads__c =10,State__c='CA',Utility_Company__c='Pacific Gas & Electric (PG&E)');
        insert market;

        ma = new Market_Assignment__c(Market__c=market.Id,Partner__c=oAccount.Id);
        insert ma; 
    }        
    
    static void setupData() {

        Profile sysAdminProfile = [select Id,Name from Profile where Name = 'System Administrator' limit 1];
        

        sysAdminUser = new User(alias = 'standt', email='sysAdminUser@PartnerLeadDetailTest.com',
                      emailencodingkey='UTF-8', lastname='PartnerLeadDetailTest', LanguageLocaleKey='en_US',
                      localesidkey='en_US', profileid = sysAdminProfile.Id,timezonesidkey='America/Los_Angeles',
                      username='systemadmin@testorg.com',Title='PartnerLeadDetailTest',FirstName='Test');
        insert sysAdminUser;

    }
   
    static void setupPowerPartnerData() {

        Profile powerPartnerProfile = [select Id,Name from Profile where Name = 'PartnerSales' limit 1];
        Id accountRecTypeId = [select Id from RecordType where Name = 'Partner' and SobjectType = 'Account' limit 1].Id;

        pAccount = new Account();
        pAccount.Name = 'Unit Test Account';
        pAccount.BillingStreet = 'Street 123 Unit Test Street';
        pAccount.BillingCity='Dallas';
        pAccount.BillingState = 'TX';
        pAccount.BillingPostalCode = '75006';
        pAccount.BillingCountry='US';
        pAccount.Industry = 'Commerical';
        pAccount.Ultimate_Parent_Account__c = uAccount.Id;
        pAccount.RecordTypeId = accountRecTypeId;
        pAccount.Stage__c = 'Confirmed';    
        pAccount.Office_Location__c = 'Headquarters';
        pAccount.Active__c = true; 

        insert pAccount;
                        
        powerPartnerContact = new Contact(AccountId = pAccount.id,LastName='PowerPartner',FirstName='PPFirstName',
                                                  Ultimate_Parent_Account__c = uAccount.Id,
                                                  Email='ppcontactemail@yopmail.com');
        insert powerPartnerContact; 
        
        powerPartnerUser = new User(alias = 'standt', email='powerPartnerUser@PartnerLeadDetailTest.com',
                      emailencodingkey='UTF-8', lastname='PartnerLeadDetailTest', LanguageLocaleKey='en_US',
                      localesidkey='en_US', profileid = powerPartnerProfile.Id,timezonesidkey='America/Los_Angeles',
                      username='powerpartner@testorg.com',Title='PartnerLeadDetailTest',FirstName='Test',
                      ContactId=powerPartnerContact.Id);
        insert powerPartnerUser;
        
        User ppUser = [select Id,contact.id from user where Id = :powerPartnerUser.Id limit 1];
        system.debug('ppUser Contact.Id:' +ppUser.contact.id);

        ContactShare ConShr = new ContactShare();
        ConShr.ContactId = powerPartnerContact.Id;
        ConShr.UserOrGroupId = powerPartnerUser.Id;
        ConShr.ContactAccessLevel = 'Edit';
        insert ConShr; 
    }      
}