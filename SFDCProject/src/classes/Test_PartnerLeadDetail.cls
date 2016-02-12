@isTest (SeeAllData=true)
public class Test_PartnerLeadDetail {

    public static User sysAdminUser;
    public static User powerPartnerUser;
    public static Contact contactSysAdmin;
    public static Lead leadSetupData;
    public static Account oAccount;
    public static Account sAccount;
    public static Account iAccount;
    public static Account pAccount;
    public static Account uAccount;
    public static Account leadForPassingAccount;
    public static Market__c market; 
    public static Market_Assignment__c ma;
    public static List<Account> accountList;

    public static testMethod void TestPartnerLeadDetail(){
        Test.startTest(); 
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('PartnerPortal');
        mock.setStatusCode(200); // Or other appropriate HTTP status code
        mock.setHeader('Content-Type', 'application/json'); // Or other appropriate MIME type like application/xml
        Test.setMock(HttpCalloutMock.class, mock);
                
        Lead lead = new lead(lastname='Test',company='Tst');        
        insert lead;
        
        Territory_Information__c ti = new Territory_Information__c(name='texas co',IsTerritory__c= true);
        insert ti;
        
        ApexPages.StandardController stdcon = new ApexPages.StandardController(lead);
        PartnerLeadDetail PartnerLeadDetailObj = new PartnerLeadDetail(stdcon);
        Pagereference pg;   
        PartnerLeadDetailObj.getLeadId();
        lead.CDYNE_Status__c = 'Failure';
        pg = PartnerLeadDetailObj.viewProject();
        
        lead.CDYNE_Status__c = 'Success';
        lead.Utility_Company__c = null;
        PartnerLeadDetailObj.leadRec = lead;
        pg = PartnerLeadDetailObj.viewProject();
        
        lead.Usage_Option__c = null;
        lead.Utility_Company__c = 'Pacific Gas & Electric (PG&E)';
        pg = PartnerLeadDetailObj.viewProject();
        
        
        lead.Utility_Company__c = 'texas co';
        pg = PartnerLeadDetailObj.viewProject();
        
        
        lead.Utility_Company__c = 'mississippi co';
        
        pg = PartnerLeadDetailObj.viewProject();        
        
        pg=PartnerLeadDetailObj.getPageRef();
        
        pg=PartnerLeadDetailObj.convertLead();
        
        pg=PartnerLeadDetailObj.editLead();
        
        List<Notes__c>  lstNotes=PartnerLeadDetailObj.getLeadNotes();
        List<Design_Option__c> lstDesignOption=PartnerLeadDetailObj.getleadDesignOption();
        
        Test.stopTest();
    }

    public static testMethod void testGoToDesignMethod1() {

        setupLeadData();
        leadSetupData.Sales_Rep_Division__c = 'TestDiv';
        update leadSetupData;
        
        // now running the test using an user with valid contact
        Test.startTest();
        setupData();
        Test.stopTest();

        System.runAs(sysAdminUser) {
            System.assert(UserInfo.getUserId() == sysAdminUser.Id);

            ApexPages.StandardController stdcon = new ApexPages.StandardController(leadSetupData);
            PartnerLeadDetail PartnerLeadDetailObj = new PartnerLeadDetail(stdcon);         

            PartnerLeadDetailObj.selectedDesign = 'Design New Proposal';
            PartnerLeadDetailObj.goToDesign();
            
            // Partner Terms and conditions page will be invoked as CRM user has not accepted T&C
            System.assert(PartnerLeadDetailObj.redirectURL.containsIgnoreCase(Page.PartnerTermsConditions.getUrl()));

            Contact currentContact = [select Id,T_C_Accepted__c from Contact where Id =: PartnerLeadDetailObj.partnerContactId limit 1];
            currentContact.T_C_Accepted__c = true;
            update currentContact;

            // Checking the rest of the flow when CRM user has accepted T&C
            stdcon = new ApexPages.StandardController(leadSetupData);
            PartnerLeadDetailObj = new PartnerLeadDetail(stdcon);           

            PartnerLeadDetailObj.selectedDesign = 'Design New Proposal';            
            PartnerLeadDetailObj.goToDesign();

            System.assert(PartnerLeadDetailObj.redirectURL.containsIgnoreCase('lightmile'));
            
            List<TermsConditions__c> testPartnerTermsConditions = PartnerLeadDetailObj.getPartnerTermsConditions();
            System.assert(!testPartnerTermsConditions.isEmpty());
            
            currentContact = [select Id,T_C_Accepted__c from Contact where Id =: PartnerLeadDetailObj.partnerContactId limit 1];
            currentContact.T_C_Accepted__c = false;
            update currentContact;
            
            PageReference partnerTandCPage = TermsConditionsUtil.redirectToTermsConditions(PartnerLeadDetailObj.partnerContactId,leadSetupData.Id,'Lead','Design New Proposal','1364269688','PARTNER','P');
            Test.setCurrentPage(partnerTandCPage);
            PartnerLeadDetailObj.declineTermsandConditions();
        
            Test.setCurrentPage(partnerTandCPage);
            PartnerLeadDetailObj.acceptTermsandConditions();
      
            currentContact = [select Id,T_C_Accepted__c from Contact where Id =: PartnerLeadDetailObj.partnerContactId limit 1];
            system.assert(currentContact.T_C_Accepted__c);
            
            delete currentContact;
            
            PartnerLeadDetailObj.selectedDesign = 'Design New Proposal';
            PartnerLeadDetailObj.goToDesign();
              
            System.debug(LoggingLevel.INFO,'redirectURL : '+PartnerLeadDetailObj.redirectURL);
            System.debug(LoggingLevel.INFO,'displayPopupMessage : '+PartnerLeadDetailObj.displayPopupMessage);

            System.assert(PartnerLeadDetailObj.displayPopupMessage != null && 
                          PartnerLeadDetailObj.displayPopupMessage.equalsIgnoreCase('The valid user contact is required'));
            System.assert(PartnerLeadDetailObj.displayPopup);
            }

    }

    public static testMethod void testGoToDesignSalesRepPage() {
        setupLeadData();
        leadSetupData.SalesRep__c = null;
        leadSetupData.Sales_Rep_Email__c = null;
        update leadSetupData;

        Test.startTest();
        setupData();
        Test.stopTest();

        System.runAs(sysAdminUser) {
            ApexPages.StandardController stdcon = new ApexPages.StandardController(leadSetupData);
            PartnerLeadDetail PartnerLeadDetailObj = new PartnerLeadDetail(stdcon);         

            PartnerLeadDetailObj.selectedDesign = 'Design New Proposal';            
            PartnerLeadDetailObj.goToDesign();
            System.assert(PartnerLeadDetailObj.displaySalesRepUrl);
            System.assert(PartnerLeadDetailObj.SalesRepURL != null && PartnerLeadDetailObj.SalesRepURL.containsIgnoreCase('SalesRepRedirect'));                     

        }
    }

    public static testMethod void testGoToDesignMethod2() {

        setupLeadDataPRM();
  
        Test.startTest();
        setupPowerPartnerData();
        List<AccountShare> ashareList=new List<AccountShare>();
        AccountShare aShare=new AccountShare();
        aShare.AccountId = leadForPassingAccount.Id;
        aShare.UserOrGroupId = powerPartnerUser.id;
        aShare.AccountAccessLevel = 'Edit';
        aShare.ContactAccessLevel = 'Edit';
        aShare.OpportunityAccessLevel = 'Edit';
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
        ashareList.add(aShare);
        ashareList.add(aShare1);
        ashareList.add(aShare2);
        insert ashareList;
        Test.stopTest();  

        System.runAs(powerPartnerUser) {
            System.assert(UserInfo.getUserId() == powerPartnerUser.Id);
            System.debug(LoggingLevel.INFO,'powerPartnerUser.Id : '+powerPartnerUser.Id);
            leadSetupData = new Lead(Company='Test_PartnerLeadDetail',LastName = 'PartnerLeadDetailTest',
                                 Street = '123 Main St',State = 'CA',City = 'Union City',PostalCode = '94587',
                                 Utility_Company__c = 'PG&E',Average_Monthly_Electric_Bill__c = 600.00,Channel__c = 'Billboard',
                                 Custom_Lead_Source__c = 'Canvassing: Lead At Door', FirstName = 'Test_PartnerLeadDetail',
                                 Email='test@PartnerLeadDetailTest.com',Usage_Option__c='Basic',Lead_Qualifier__c = UserInfo.getUserId(),
                                 Territory__c = 'Z',Market_Assignment_Install__c = ma.Id,Market_Assignment_Sales__c = ma.Id,
                                 Sales_Partner__c = sAccount.id, Install_Partner__c = iAccount.id, SalesRep__c = powerPartnerUser.Id,
                                 Sales_Rep_Email__c = 'test@PartnerLeadDetailTest.com', Sales_Rep_Division__c = 'TestDiv',
                                 Square_footage__c=12.0,Partner_for_Lead_Passing__c = leadForPassingAccount.Id,
                                 Home_Type__c = 'Detached single family home');
            insert leadSetupData;
            system.debug('leadSetupData.Id :' +leadSetupData.Id);    

            ApexPages.StandardController stdcon = new ApexPages.StandardController(leadSetupData);
            PartnerLeadDetail PartnerLeadDetailObj = new PartnerLeadDetail(stdcon); 
            
            system.assert(PartnerLeadDetailObj.getLeadId() == leadSetupData.Id);
            PartnerLeadDetailObj.selectedDesign = 'Design New Proposal';
            PartnerLeadDetailObj.goToDesign();
            
            // Partner Terms and conditions page will be invoked as PRM user has not accepted T&C
            System.assert(PartnerLeadDetailObj.displayTandCURL);
                        
            Contact currentContact = [select Id,T_C_Accepted__c from Contact where Id =: PartnerLeadDetailObj.partnerContactId limit 1];
            currentContact.T_C_Accepted__c = true;
            update currentContact;

            // Checking the rest of the flow when PRM user has accepted T&C
            stdcon = new ApexPages.StandardController(leadSetupData);
            PartnerLeadDetailObj = new PartnerLeadDetail(stdcon);           

            PartnerLeadDetailObj.selectedDesign = 'Design New Proposal';            
            PartnerLeadDetailObj.goToDesign();
            
            System.assert(PartnerLeadDetailObj.redirectURL.containsIgnoreCase('lightmile'));

        }
    }    

    static void setupLeadData() {

        Id accountRecTypeId = [select Id from RecordType where Name = 'Partner' and SobjectType = 'Account' limit 1].Id;
        Id accountRecTypeId1 = [select Id from RecordType where Name = 'Company' and SobjectType = 'Account' limit 1].Id;

        accountList = new List<Account>();

        oAccount = new Account();
        oAccount.Name = 'PartnerTermsConditionsExtTest';
        oAccount.BillingStreet = '123 Unit Test Street';
        oAccount.BillingCity ='Union City';
        oAccount.BillingState = 'CA';
        oAccount.BillingPostalCode = '94587';
        oAccount.BillingCountry='US';
        oAccount.RecordTypeId = accountRecTypeId;
        
        //insert oAccount;
        accountList.add(oAccount);

        sAccount = new Account();
        sAccount.Name = 'SalesPartnerTermsConditionsExtTest';
        sAccount.BillingStreet = '345 Unit Test Street';
        sAccount.BillingCity ='Union City';
        sAccount.BillingState = 'CA';
        sAccount.BillingPostalCode = '94587';
        sAccount.BillingCountry='US';
        sAccount.RecordTypeId = accountRecTypeId1;
        sAccount.Stage__c = 'Confirmed';    
        sAccount.Office_Location__c = 'Headquarters';
        sAccount.Active__c = true; 

        
        //insert sAccount;
        accountList.add(sAccount);      
        
        iAccount = new Account();
        iAccount.Name = 'InstallPartnerTermsConditionsExtTest';
        iAccount.BillingStreet = '678 Unit Test Street';
        iAccount.BillingCity ='Union City';
        iAccount.BillingState = 'CA';
        iAccount.BillingPostalCode = '94587';
        iAccount.BillingCountry='US';
        iAccount.RecordTypeId = accountRecTypeId1;
        
        //insert iAccount;
        accountList.add(iAccount);

        leadForPassingAccount = new Account();
        leadForPassingAccount.Name = 'leadForPassingAccountTest';
        leadForPassingAccount.BillingStreet = '123 Unit Test Street';
        leadForPassingAccount.BillingCity ='Union City';
        leadForPassingAccount.BillingState = 'CA';
        leadForPassingAccount.BillingPostalCode = '94587';
        leadForPassingAccount.BillingCountry='US';
        leadForPassingAccount.RecordTypeId = accountRecTypeId;
        leadForPassingAccount.Stage__c = 'Confirmed';   
        leadForPassingAccount.Office_Location__c = 'Headquarters';
        leadForPassingAccount.Active__c = true; 

        accountList.add(leadForPassingAccount);

        insert accountList;     
        
        market = new Market__c(Duration_in_days__c = 10,Number_of_Leads__c =10,State__c='CA',Utility_Company__c='Pacific Gas & Electric (PG&E)');
        insert market;

        ma = new Market_Assignment__c(Market__c=market.Id,Partner__c=oAccount.Id);
        insert ma;

        // create lead record

        leadSetupData = new Lead(Company='Test_PartnerLeadDetail',LastName = 'PartnerLeadDetailTest',
                             Street = '123 Main St',State = 'CA',City = 'Union City',PostalCode = '94587',
                             Utility_Company__c = 'PG&E',Average_Monthly_Electric_Bill__c = 600.00,Channel__c = 'Billboard',
                             Custom_Lead_Source__c = 'Canvassing: Lead At Door', FirstName = 'Test_PartnerLeadDetail',
                             Email='test@PartnerLeadDetailTest.com',Usage_Option__c='Basic',Lead_Qualifier__c = UserInfo.getUserId(),
                             Territory__c = 'Z',Market_Assignment_Install__c = ma.Id,Market_Assignment_Sales__c = ma.Id,
                             Sales_Partner__c = sAccount.id, Install_Partner__c = iAccount.id, SalesRep__c = UserInfo.getUserId(),
                             Sales_Rep_Email__c = 'test@PartnerLeadDetailTest.com', 
                             Sales_Rep_Division__c = 'TestDiv',    
                             Square_footage__c=12.0,Partner_for_Lead_Passing__c = leadForPassingAccount.Id);
        
        insert leadSetupData;
    }

    static void setupLeadDataPRM() {

        Id accountRecTypeId = [select Id from RecordType where Name = 'Partner' and SobjectType = 'Account' limit 1].Id;
        Id accountRecTypeId1 = [select Id from RecordType where Name = 'Company' and SobjectType = 'Account' limit 1].Id;

        accountList = new List<Account>();

        oAccount = new Account();
        oAccount.Name = 'PartnerTermsConditionsExtTest';
        oAccount.BillingStreet = '123 Unit Test Street';
        oAccount.BillingCity ='Union City';
        oAccount.BillingState = 'CA';
        oAccount.BillingPostalCode = '94587';
        oAccount.BillingCountry='US';
        oAccount.RecordTypeId = accountRecTypeId;
        oAccount.Stage__c = 'Confirmed';    
        oAccount.Office_Location__c = 'Headquarters';
        oAccount.Active__c = true; 

        
        //insert oAccount;
        accountList.add(oAccount);

        sAccount = new Account();
        sAccount.Name = 'SalesPartnerTermsConditionsExtTest';
        sAccount.BillingStreet = '345 Unit Test Street';
        sAccount.BillingCity ='Union City';
        sAccount.BillingState = 'CA';
        sAccount.BillingPostalCode = '94587';
        sAccount.BillingCountry='US';
        sAccount.RecordTypeId = accountRecTypeId1;
        sAccount.Stage__c = 'Confirmed';    
        sAccount.Office_Location__c = 'Headquarters';
        sAccount.Active__c = true; 

        
        //insert sAccount;
        accountList.add(sAccount);      
        
        iAccount = new Account();
        iAccount.Name = 'InstallPartnerTermsConditionsExtTest';
        iAccount.BillingStreet = '678 Unit Test Street';
        iAccount.BillingCity ='Union City';
        iAccount.BillingState = 'CA';
        iAccount.BillingPostalCode = '94587';
        iAccount.BillingCountry='US';
        iAccount.RecordTypeId = accountRecTypeId1;
        iAccount.Stage__c = 'Confirmed';    
        iAccount.Office_Location__c = 'Headquarters';
        iAccount.Active__c = true; 

        
        //insert iAccount;
        accountList.add(iAccount);

        leadForPassingAccount = new Account();
        leadForPassingAccount.Name = 'leadForPassingAccountTest';
        leadForPassingAccount.BillingStreet = '123 Unit Test Street';
        leadForPassingAccount.BillingCity ='Union City';
        leadForPassingAccount.BillingState = 'CA';
        leadForPassingAccount.BillingPostalCode = '94587';
        leadForPassingAccount.BillingCountry='US';
        leadForPassingAccount.RecordTypeId = accountRecTypeId;
        leadForPassingAccount.Stage__c = 'Confirmed';   
        leadForPassingAccount.Office_Location__c = 'Headquarters';
        leadForPassingAccount.Active__c = true; 

        accountList.add(leadForPassingAccount);

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
                        
        Contact powerPartnerContact = new Contact(AccountId = pAccount.id,LastName='PowerPartner',FirstName='PPFirstName',
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