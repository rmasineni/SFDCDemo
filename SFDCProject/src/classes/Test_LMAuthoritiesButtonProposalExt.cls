@isTest (SeeAllData=true)
public class Test_LMAuthoritiesButtonProposalExt {
	public static User sysAdminUser;
    public static User PowerPartnerUser; 
    public static Proposal__c prop; 
    public static Opportunity opty;
    public static Account oAccount;
    public static Account sAccount;
    public static Account iAccount;
    public static Account pAccount;
    public static Account uAccount;
    public static Market__c market; 
    public static Market_Assignment__c ma;
    public static OpportunityContactRole OCR;
    public static Partner_Role__c PR;
    public static List<Account> accountList;
    public static Map<String, Test_Partner_User__c> testPartnerUserMap = new Map<String, Test_Partner_User__c>();
   
    public static testMethod void TestLMAuthoritiesButtonProposalExt(){
        UnitTest_ProposalUtil.disableExternalServices();
        setupProposalData(); 
        
        ApexPages.StandardController controller = new ApexPages.StandardController(prop);
        LMAuthoritiesButtonProposalExt controllerExtn = new LMAuthoritiesButtonProposalExt(controller);
        controllerExtn.redirectToDesign(); 
        
        system.assert(controllerExtn.showErrorAlert);
        system.assert(controllerExtn.errorMessage != null && controllerExtn.errorMessage.equalsIgnoreCase('This is not a valid proposal for modification'));
        
        prop.Proposal_Source__c = 'BB'; 
        prop.Stage__c = 'Voided';
        update prop; 

        controller = new ApexPages.StandardController(prop);
        controllerExtn = new LMAuthoritiesButtonProposalExt(controller);        
        controllerExtn.redirectToDesign(); 
        system.debug('controllerExtn.errorMessage1 :' +controllerExtn.errorMessage);
        system.assert(controllerExtn.showErrorAlert);
        system.assert(controllerExtn.errorMessage != null && controllerExtn.errorMessage.equalsIgnoreCase('This is not an active proposal to modify the design documents'));       
        
        prop.Stage__c='Created';
        update prop; 
        
        controller = new ApexPages.StandardController(prop);
        controllerExtn = new LMAuthoritiesButtonProposalExt(controller);   
        
        controllerExtn.selectedDesign ='eAudit';
        controllerExtn.redirectToDesign();
        system.debug('controllerExtn.errorMessage2 :' +controllerExtn.errorMessage);
        system.assert(controllerExtn.showErrorAlert);
        system.assert(controllerExtn.errorMessage != null && controllerExtn.errorMessage.equalsIgnoreCase('Cannot audit an unsigned proposal'));            
 
        //sysAdminUser = [select Id from User where Id ='00560000003bs1o'];
        
        //LightMile_User__c lightmuser =  LightMile_User__c.getValues('LightMile User');     
        LightMile_User__c lightmuser =  LightMile_User__c.getValues('Sunrun CRM');     
        if(lightmuser !=null){
            sysAdminUser=new User(id=lightmuser.user_id__c);
        
            System.runAs(sysAdminUser) {
                System.assert(UserInfo.getUserId() == sysAdminUser.Id);
                
                controller = new ApexPages.StandardController(prop);
                controllerExtn = new LMAuthoritiesButtonProposalExt(controller);               
                controllerExtn.selectedDesign ='Modify Proposal';
                controllerExtn.redirectToDesign();
                
    // Partner Terms and conditions page will be invoked as CRM user has not accepted T&C
                System.assert(controllerExtn.redirectUrl.containsIgnoreCase(Page.PartnerTermsConditions.getUrl()));
    
                Contact currentContact = [select Id,T_C_Accepted__c from Contact where Id =: controllerExtn.partnerContactId limit 1];
                currentContact.T_C_Accepted__c = true;
                currentContact.As_Built__c = 'Granted';
                currentContact.ePermitting__c = 'Granted'; 
                currentContact.Modify_Proposal__c = 'Granted';
                currentContact.eAudit__c = 'Granted';
                update currentContact;
                
                List<SelectOption> getDesignTypesOptions = controllerExtn.getDesignTypes(); 
                controllerExtn.selectedDesign ='Modify Proposal';
                controllerExtn.redirectToDesign();
    
                System.assert(controllerExtn.redirectUrl.containsIgnoreCase('lightmile'));            
            }    
        }
    }
/*    
    public static testMethod void TestLMAuthoritiesButtonProposalExtPRM(){
        testPartnerUserMap = Test_Partner_User__c.getAll(); 
        Test_Partner_User__c partnerUser;
        if(testPartnerUserMap != null && testPartnerUserMap.containsKey('Black Bird Sales Rep')){
            partnerUser = testPartnerUserMap.get('Black Bird Sales Rep');
            PowerPartnerUser = [Select Id from User where Id = :partnerUser.User_Id__c  limit 1];
            
            System.debug('PowerPartnerUser :' +PowerPartnerUser.Id);
            
            System.runAs(PowerPartnerUser) {
                System.assert(UserInfo.getUserId() == PowerPartnerUser.Id);
                setupProposalData();
                prop.Proposal_Source__c = 'BB'; 
                prop.Stage__c='Created';
                update prop;
// Partner Terms and conditions page will be invoked as Partner Portal user has not accepted T&C                
                ApexPages.StandardController controller = new ApexPages.StandardController(prop);
                LMAuthoritiesButtonProposalExt controllerExtn = new LMAuthoritiesButtonProposalExt(controller);           
                controllerExtn.selectedDesign ='Modify Proposal';
                controllerExtn.redirectToDesign();
   
                System.assert(controllerExtn.redirectUrl.containsIgnoreCase(Page.PartnerTermsConditions.getUrl()));
/*                        
                Contact currentContact = [select Id,T_C_Accepted__c from Contact where Id =: controllerExtn.partnerContactId limit 1];
                system.debug('currentContact.T_C_Accepted__c :' +currentContact.T_C_Accepted__c); 
                currentContact.T_C_Accepted__c = true;
                update currentContact;
                
                controllerExtn.selectedDesign ='Modify Proposal';
                controllerExtn.redirectToDesign();
   
                System.assert(controllerExtn.redirectUrl.containsIgnoreCase('lightmile'));           
*/
/*            }    
        }        
    }
*/    
    static void setupProposalData(){
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
        opty = new Opportunity(Name='PartnerOpportunityCreateExtTest',StageName = 'Created',CloseDate = Date.Today()+30,
                               Average_Monthly_Electric_Bill__c = 1000,Square_footage__c = 1500,channel_2__c = 'Billboard',
                               Lead_Source_2__c = 'Billboard: Brilliant',Opportunity_Source_Type__c = 'BB',Utility_Company__c = 'PG&E',
                               Usage_Option__c = 'Basic',territory__c = 'Z', home_type__c = 'Detached single family home',
                               Market_Assignment_Install__c = ma.Id,Market_Assignment_Sales__c = ma.Id,Sales_Partner__c = sAccount.Id, 
                               Install_Partner__c = iAccount.Id, Sales_Rep_Division__c ='TestDiv',Sales_Rep_Email__c = 'PartnerOpportunityCreatePR@gmail.com');
        insert opty;                 
        Test.stopTest(); 
        
        OCR = new OpportunityContactRole(ContactId=testContact.id,OpportunityId=opty.id,Role='Homeowner',isprimary=true);
        insert OCR;    
        
        PR = new Partner_Role__c(Role__c='Sales',Opportunity__c=opty.id,
                                 Sales_Rep_Email__c='PartnerOpportunityCreatePR@gmail.com',
                                 Sales_Rep_Division__c='TestDiv');
        insert pr;
        
        prop = new Proposal__c();
        prop.Name='LMAuthoritiesButtonProposalExtTest';
        prop.Opportunity__c = Opty.Id;
        prop.Stage__c = 'Created';  
        prop.Sales_Rep_Email__c = 'PartnerOpportunityCreatePR@gmail.com';
        prop.Date_Issued__c = Date.Today().addDays(18); 
        prop.Mode_Name__c = '1234';
        prop.System_Size_STC_DC__c  = 5.8;
        prop.Upfront_Payment__c = 20.0;
        prop.Sunrun_Credit_Status__c = 'SR Credit Approved';
        prop.EDP_Phase__c = 'EDP Phase-0';
    	insert prop;
    }            
}