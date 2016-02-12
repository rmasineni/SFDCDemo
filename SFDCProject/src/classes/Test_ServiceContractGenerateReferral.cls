@isTest(SeeAllData=true)
public with sharing class Test_ServiceContractGenerateReferral {
    public static testmethod void ServiceContractGenerateReferralData(){
        Test.starttest();
        ServiceContractGenerateReferralData SCGenRef = new ServiceContractGenerateReferralData();
        Account a= [select id,name from account where office_location__c='Headquarters' and Ultimate_Parent_Account__c=null limit 1];
        Contact cont= new Contact (firstname='Test',LastName='TestCt',Accountid=a.Id,Ultimate_Parent_Account__c=a.id,ERP_Contact_of_Record__c=TRUE);
        insert cont;
        ServiceContract sc = new ServiceContract(Install_Partner__c=a.name, TE_Fund_Name__c='TestFund',Channel__c='Integrated',Agreement_Number__c='123',Utility_Company__c='TestCompany',Billing_Method__c='Test1');
        insert sc;
        Service_Contract_Event__c sce = new Service_Contract_Event__c(service_contract__c=sc.id,Upfront_Payment_Amount__c=33,Upfront_Payment_Amount_Rec_d__c=33,Initial_Deposit_Amount__c=44,Initial_Deposit_Amount_Received__c=44);
        insert sce;
        Referral_Input__c r = new Referral_Input__c(Target_Contact_Id__c=cont.id,Milestone_1_Status__c='Qualified for Payment',Milestone_2_Status__c='Qualified for Payment',Milestone_3_Status__c='Qualifies for Payment',Referrer_Status_1__c='Qualifies for Payment',Referrer_Status_2__c='Qualified for Payment',Referrer_Status_3__c='Qualifies for Payment');
        insert r;
        SCGenRef.fromDate = string.valueof(system.today()-100);
        SCGenRef.toDate = string.valueof(system.today());       
        SCGenRef.thousandBlocks=SCGenRef.getthousandBlocks();
        SCGenRef.init();  
        SCGenRef.genExcel();
        SCGenRef.refreshData2();
        SCGenRef.refreshData();
        
         SCGenRef.getReferralData(); 
              
        Test.stoptest();
    
        
    }
}