@istest(seeAllData=true)
public with sharing class Test_trg_case_aftr_ins_aftr_upd{
     static testMethod void Test_trg_case_aftr_ins_aftr_upd(){
        Test.starttest();
        Schema.DescribeSObjectResult d = Schema.SObjectType.case; 
        Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
        Schema.RecordTypeInfo rtByName =  rtMapByName.get('Invoice');
        String Invoice = rtByName.getRecordTypeId();

        Generation_Assets__c gaTst=new Generation_Assets__c(name='Test12',Home_Address__c='xuy',City__c='Melbourne',Zip__c='90909',pto__c=system.today()-200,Meter_Serial_Num__c='444',Meter_Test_Date__c=system.today()-10);
        insert gaTst;
        Account a= [select id,name from account where office_location__c='Headquarters' and Ultimate_Parent_Account__c=null limit 1];
        
        Map<String, Schema.SObjectType> m  = Schema.getGlobalDescribe() ;
        Schema.SObjectType s = m.get('Account');
        Schema.DescribeSObjectResult cfrSchema = s.getDescribe() ;
        Map<String,Schema.RecordTypeInfo> RecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

        List<Account> accountList = new List<Account>();
        Account rAccount = new Account();
        rAccount.Name = 'ResidentialSCETriggerClassTest';
        rAccount.BillingStreet = '910 Unit Test Street';
        rAccount.BillingCity ='Union City';
        rAccount.BillingState = 'CA';
        rAccount.BillingPostalCode = '94587';
        rAccount.BillingCountry='US';
        rAccount.RecordTypeId = RecordTypeInfo.get('Residential').getRecordTypeId();                
        accountList.add(rAccount);    
        insert accountList; 
         
        List<Contact> conList = new List<Contact>();  
        Contact testContact = new Contact(LastName='SCETriggerClassCust',AccountId=rAccount.id, Email='Test_trg_case_aftr_ins_aftr_upd.Customer1@yopmail.com'); 
        conList.add(testContact);
        insert conList; 
 
        ServiceContract sc= new ServiceContract(Accountid=a.id,Agreement_Number__c='123',Contactid=testContact.id,TE_Fund_Name__c='Fund',install_partner__c=a.name); 
        insert sc;
        Service_Contract_Event__c sce = new Service_Contract_Event__c (Service_Contract__c=sc.id,pto__c=system.today()) ;
        insert sce;
        Case case1=new Case(recordtypeid=Invoice,Milestone_Proof_Type__c='M3 Proof',Type='Invoice',Status='Open',Origin='Chat',Generation_Asset__c=gaTst.id,Case_M3_PTO__c=system.today());
        Case case2=new Case(recordtypeid=Invoice,Milestone_Proof_Type__c='M3 Proof',Type='Invoice',Status='Open',Origin='Call',service_contract__c=sc.id,First_Response_Date_Time__c=datetime.now(),Case_M3_PTO__c=system.today());
        List<Case> caselist=new List<Case>();
        caselist.add(case1);
        caselist.add(case2);
        insert caselist;        
        caselist[0].status='Closed';
        caselist[1].status='Closed';
        update caselist;

    test.stopTest();
     }
}