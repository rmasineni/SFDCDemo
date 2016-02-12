@isTest(SeeAllData=true)
public class Test_trg_Send_SCE_Emails {
    public static User sysAdminUser;
    public static Boolean createPartnerRole;
    public static Boolean createOpty;
    public static Account oAccount;
    public static Account sAccount;
    public static Account iAccount;
    public static Account pAccount;
    public static Account rAccount;
    public static Market__c market; 
    public static Market_Assignment__c ma;
    public static OpportunityContactRole OCR;
    public static Partner_Role__c PR;
    public static List<Account> accountList;
    public static List <Contact> conList; 
    public static Opportunity opty;
    public static Opportunity opty1;
    public static Proposal__c prop;
    public static Proposal__c prop1;
    public static String random='999'+math.random();
 

    public static testMethod void testcheckScheduledInstallDate()  {
        UnitTest_ProposalUtil.disableExternalServices();
        createPartnerRole = true;
        createOpty = true; 
        setupOptyData();
    }          
           
    static void setupOptyData(){
    
        Map<String, Schema.SObjectType> m  = Schema.getGlobalDescribe() ;
        Schema.SObjectType s = m.get('Account');
        Schema.DescribeSObjectResult cfrSchema = s.getDescribe() ;
        Map<String,Schema.RecordTypeInfo> RecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
  Test.startTest();
        accountList = new List<Account>();
            
        oAccount = new Account();
        oAccount.Name = 'SCETriggerClassTest';
        oAccount.BillingStreet = '123 Unit Test Street';
        oAccount.BillingCity ='Union City';
        oAccount.BillingState = 'CA';
        oAccount.BillingPostalCode = '94587';
        oAccount.BillingCountry='US';
        //oAccount.RecordTypeId = accountRecTypMap.get('Partner');
        oAccount.RecordTypeId = RecordTypeInfo.get('Partner').getRecordTypeId();   
        
        accountList.add(oAccount);
                       
        sAccount = new Account();
        sAccount.Name = 'SalesPartnerSCETriggerClassTest';
        sAccount.BillingStreet = '345 Unit Test Street';
        sAccount.BillingCity ='Union City';
        sAccount.BillingState = 'CA';
        sAccount.BillingPostalCode = '94587';
        sAccount.BillingCountry='US';
        //sAccount.RecordTypeId = accountRecTypMap.get('Company');
        sAccount.RecordTypeId = RecordTypeInfo.get('Company').getRecordTypeId();  

        accountList.add(sAccount);        
        
        iAccount = new Account();
        iAccount.Name = 'InstallPartnerSCETriggerClassTest';
        iAccount.BillingStreet = '678 Unit Test Street';
        iAccount.BillingCity ='Union City';
        iAccount.BillingState = 'CA';
        iAccount.BillingPostalCode = '94587';
        iAccount.BillingCountry='US';
        //iAccount.RecordTypeId = accountRecTypMap.get('Company');
        iAccount.RecordTypeId = RecordTypeInfo.get('Company').getRecordTypeId();  
        
        accountList.add(iAccount);      
        
        rAccount = new Account();
        rAccount.Name = 'ResidentialSCETriggerClassTest';
        rAccount.BillingStreet = '910 Unit Test Street';
        rAccount.BillingCity ='Union City';
        rAccount.BillingState = 'CA';
        rAccount.BillingPostalCode = '94587';
        rAccount.BillingCountry='US';
        //rAccount.RecordTypeId = accountRecTypMap.get('Residential'); 
        rAccount.RecordTypeId = RecordTypeInfo.get('Residential').getRecordTypeId();         
        
        accountList.add(rAccount);    

        insert accountList; 
        System.debug('Accounts created');
         
        conList = new List<Contact>();  
        Contact testContact = new Contact(LastName='SCETriggerClassCust',AccountId=rAccount.id, Email='SCETriggerClass.Customer1@yopmail.com'); 
        conList.add(testContact);
        insert conList; 
        System.debug('Contact created');
        testcontact.Preferred_Language__c = 'Spanish';
        update testcontact; 
        market = new Market__c(Duration_in_days__c = 10,Number_of_Leads__c =10,State__c='CA',Utility_Company__c='Pacific Gas & Electric (PG&E)');
        insert market;
        System.debug('Market created');

        ma = new Market_Assignment__c(Market__c=market.Id,Partner__c=oAccount.Id);
        insert ma; 
        System.debug('Market Assignement created');

      
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt1', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1@sunrun.com');
        insert u;
        
        opty = new Opportunity(Name='SCETriggerClassTest',StageName = 'Created',CloseDate = Date.Today()+30,
                               Average_Monthly_Electric_Bill__c = 1000,Square_footage__c = 1500,channel_2__c = 'Billboard',
                               Lead_Source_2__c = 'Billboard: Brilliant',Opportunity_Source_Type__c = 'BB',Utility_Company__c = 'PG&E', 
                               Usage_Option__c = 'Basic',territory__c = 'Z', home_type__c = 'Detached single family home',  
                               Market_Assignment_Install__c = ma.Id,Market_Assignment_Sales__c = ma.Id,Sales_Partner__c = sAccount.Id, 
                               Install_Partner__c = iAccount.Id, Sales_Rep_Division__c ='TestDiv',Sales_Rep_Email__c = 'SCETriggerClass.SalesRep@yopmail.com',Purchased_Thru__c = 'Costco',SalesRep__c = u.Id);
        insert opty;
        System.debug('Oppty created');
        opty.Preferred_Language__c = 'English';
        update opty;
     
          
          opty1 = new Opportunity(Name='SCETriggerClassTest1',StageName = 'Created',CloseDate = Date.Today()+30,
                               Average_Monthly_Electric_Bill__c = 1000,Square_footage__c = 1500,channel_2__c = 'Billboard',
                               Lead_Source_2__c = 'Billboard: Brilliant',Opportunity_Source_Type__c = 'BB',Utility_Company__c = 'PG&E', 
                               Usage_Option__c = 'Basic',territory__c = 'Z', home_type__c = 'Detached single family home',  
                               Market_Assignment_Install__c = ma.Id,Market_Assignment_Sales__c = ma.Id,Sales_Partner__c = sAccount.Id, 
                               Install_Partner__c = iAccount.Id, Sales_Rep_Division__c ='TestDiv',Sales_Rep_Email__c = 'SCETriggerClass.SalesRep@yopmail.com',Purchased_Thru__c = 'Costco');
        insert opty1;
        System.debug('Oppty1 created');
        
        opty1.Preferred_Language__c = 'English';
        update opty1;
        OCR = new OpportunityContactRole(ContactId=testContact.id,OpportunityId=opty.id,Role='Homeowner',isprimary=true);
        insert OCR;    
        System.debug('OCR created');
        
        List<Partner_Role__c> prList = new List<Partner_Role__c>();
        if (createPartnerRole){
            prList.add(new Partner_Role__c(Role__c='Sales',Opportunity__c=opty.id, Partner_Name__c = System.label.sunrun_inc_Id,
                                     Sales_Rep_Email__c='SCETriggerClassSP@yopmail.com',
                                     Sales_Rep_Division__c='TestDiv'));
            prList.add(new Partner_Role__c(Role__c='Install',Opportunity__c=opty.id, Partner_Name__c = System.label.sunrun_inc_Id,
                                     Sales_Rep_Email__c='SCETriggerClassIP@yopmail.com',
                                     Sales_Rep_Division__c='TestDiv'));
            insert prList;
            System.debug('Partner Roles created');
        }
        
        prop = new Proposal__c();
        prop.Name='SCETriggerClassProposalTest';
        prop.Opportunity__c = Opty.Id;
        prop.Stage__c = 'Created';  
        prop.Sales_Rep_Email__c = 'SCETriggerClass.SalesRep@yopmail.com';
        prop.Date_Issued__c = Date.Today().addDays(18); 
        prop.Mode_Name__c = '1234';
        prop.System_Size_STC_DC__c  = 5.8;
        prop.Upfront_Payment__c = 20.0;
        prop.Sunrun_Credit_Status__c = 'SR Credit Approved';
        prop.EDP_Phase__c = 'EDP Phase-0';
        insert prop;
        System.debug('Proposal created');
        integer agreementNo =  Math.round(decimal.valueOf(Math.random() * (999107)));
        system.debug('agreementNo>>' +  agreementNo);
         ServiceContract sc=new ServiceContract(name=string.valueOf(agreementNo) ,contactid=testContact.id,accountid=rAccount.id,Opportunity__c = opty.id, Proposal__c = prop.id,Agreement_Number__c= String.valueof(agreementNo));  
        insert sc;
        System.debug('Service Contract created');
        
        System.debug('Service Contract1 created');
        sc.Agreement_Type__c = 'Customer Owned - Full Upfront';
        update sc;
        sc.Agreement_Type__c = 'Customer Owned - Bank Financed';
        update sc;
      //  sc.Agreement_Type__c ='Low Upfront Lease';
      //  update sc;
        sc.Cost_Stack__c = null;
        update sc;
      //  ServiceContract sc1=new ServiceContract(name=random.substring(0,9),contactid=testContact.id,accountid=rAccount.id,Opportunity__c = opty1.id, Proposal__c = prop.id,Agreement_Number__c=random.substring(0,10));  
     //   insert sc1;
      //  sc1.Agreement_Type__c = 'Customer Owned - Full Upfront';
     //   update sc1;
        Service_Contract_Event__c sce=new Service_Contract_Event__c(Rebate_Conf_Rec_d__c=system.today(),Final_Rebate_Amount__c=11,Initial_Deposit_Amount_Received__c=100,   Initial_Deposit_Processed__c=system.today(),Initial_Deposit_Amount__c=100,service_contract__c=sc.id,PTO__c=system.today()-1,M1_proof_panel_inverter_delivery__c=system.today(),
                                                                Complete_Deal_Received__c=system.today(),SR_Signoff__c=system.today(),Facility_Design_Approved__c=system.today(),M2_proof_substantial_completion__c=system.today(),NTP_Granted__c=system.today());     
        insert sce;
          
      //  Service_Contract_Event__c sce1=new Service_Contract_Event__c(Rebate_Conf_Rec_d__c=system.today(),Final_Rebate_Amount__c=11,Initial_Deposit_Amount_Received__c=100,   Initial_Deposit_Processed__c=system.today(),Initial_Deposit_Amount__c=100,service_contract__c=sc1.id,PTO__c=system.today()-1,M1_proof_panel_inverter_delivery__c=system.today(),
       //                                                         Complete_Deal_Received__c=system.today(),SR_Signoff__c=system.today(),Facility_Design_Approved__c=system.today(),M2_proof_substantial_completion__c=system.today(),NTP_Granted__c=system.today());     
     //   insert sce1;
     /*    List<Service_Contract_Event__c> sceList = new List<Service_Contract_Event__c>();
       //   sceList.add(sce);
        Set<Id> sceIdSet = new Set<Id>();
        sceIdSet.add(sce.Id);
        
        if(!sceIdSet.isEmpty()){
            sceList = [Select Id, Project_Manager__c, Project_Manager_Email__c, Service_Contract__r.ContactId, 
                              Service_Contract__r.Opportunity__r.Opportunity_Source_Type__c, Service_Contract__r.Utility_Company__c, 
                              Service_Contract__r.Opportunity__r.Salesrep__c, Service_Contract__r.Opportunity__r.Salesrep__r.Email,
                              Service_Contract__r.Opportunity__r.Sales_Representative__c, Service_Contract__r.Opportunity__r.Preferred_Language__c, Service_Contract__r.Opportunity__r.Sales_Representative__r.Email,
                              Opportunity__c 
                        From Service_Contract_Event__c
                        Where id in :sceIdSet];
                        
            
        }*/
        Test.stopTest(); 
        
        System.debug('SCE created');
 // Test.startTest();
        
         opty.Preferred_Language__c = 'Spanish';
        update opty;
        sce.Scheduled_Install_Date__c = date.parse('12/31/2099');
        sce.CAP_Date_Approved__c = date.parse('12/31/2099');
        
        sce.Permit_Submitted_Date__c = date.parse('12/31/2099');
       
        sce.Permit_Approval_Date__c = null;
        sce.Permit_Expected_Date__c = date.parse('12/31/2099'); 
       //  update sce;
        
      //  sce.Scheduled_Install_Date__c = date.parse('01/23/2099');
      //  sce1.Scheduled_Install_Date__c = date.parse('01/23/2099');
     
       
        
         
       
      //  sce.Scheduled_Install_Date__c = null;
        sce.CAP_Date_Approved__c = null;
        
        sce.Final_Inspection_Signoff__c = null;
        update sce;
     //   sce.Scheduled_Install_Date__c = date.parse('12/31/2099');
        sce.CAP_Date_Approved__c = date.parse('12/31/2099');
        sce.Permit_Approval_Date__c = date.parse('12/31/2099');
        
        sce.Final_Inspection_Signoff__c = date.parse('12/31/2099');
        update sce;
          opty.Preferred_Language__c = 'English';
        update opty;
         sce.Completion_of_Construction__c = null;
         
         update sce;
         sce.Completion_of_Construction__c = date.parse('12/31/2099');
         
         update sce;
          sce.Final_Inspection_Signoff__c = null;
          update sce;
          sce.Final_Inspection_Signoff__c = date.parse('12/31/2099');
          sce.Submit_Final_Interconnection__c = null;
          update sce;
          
      //    update sce;
     /*    sce.Submit_Final_Interconnection__c = date.parse('12/31/2099');
          update sce;
          sce.CAP_date_approved__c = null;
          update sce;
          sce.CAP_date_approved__c = date.parse('12/31/2099');
          update sce;*/
     //  update sce1;
 // Test.stopTest();      
        System.debug('SCE updated');
    }    

}