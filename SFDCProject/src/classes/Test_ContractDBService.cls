@istest
public class Test_ContractDBService {
    static testmethod void testContractDBService(){
        HttpResponse responseObj = new HttpResponse();
        Test.startTest();
        account oAccount = new Account();
        oAccount.Name = 'SCETriggerClassTest';
        oAccount.BillingStreet = '123 Unit Test Street';
        oAccount.BillingCity ='Union City';
        oAccount.BillingState = 'CA';
        oAccount.BillingPostalCode = '94587';
        oAccount.BillingCountry='US';
        
        insert oAccount; 
        System.debug('Accounts created');
        
        
        Contact testContact = new Contact(LastName='SCETriggerClassCust',AccountId=oAccount.id, Email='SCETriggerClass.Customer1@yopmail.com'); 
        
        insert testContact; 
        testcontact.Preferred_Language__c = 'Spanish';
        update testcontact; 
        
        
        Opportunity  opty = new Opportunity(Name='SCETriggerClassTest',StageName = 'Created',CloseDate = Date.Today()+30,
                                            Average_Monthly_Electric_Bill__c = 1000,Square_footage__c = 1500,channel_2__c = 'Billboard',
                                            Lead_Source_2__c = 'Billboard: Brilliant',Opportunity_Source_Type__c = 'BB',Utility_Company__c = 'PG&E', 
                                            Usage_Option__c = 'Basic',territory__c = 'Z', home_type__c = 'Detached single family home',  
                                            Sales_Partner__c = oAccount.Id, 
                                            Install_Partner__c = oAccount.Id, Sales_Rep_Division__c ='TestDiv',Sales_Rep_Email__c = 'SCETriggerClass.SalesRep@yopmail.com',Purchased_Thru__c = 'Costco');
        insert opty;
        System.debug('Oppty created');
        opty.Preferred_Language__c = 'English';
        update opty;
        
        Proposal__c prop = new Proposal__c();
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
        string agreementnumber ='1000';
        ServiceContract sc=new ServiceContract(name='98903232',contactid=testContact.id,accountid=oAccount.id,Opportunity__c = opty.id, Proposal__c = prop.id,Agreement_Number__c= agreementnumber);  
        insert sc;
        set<string> agreementId = new set<string>();
        agreementId.add(agreementnumber);
        //Invoke WebService
        ContractDBService.processContractDB(agreementId);
        
        Test.stopTest();
    }
}