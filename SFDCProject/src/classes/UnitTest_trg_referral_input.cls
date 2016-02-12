@isTest(SeeAllData=true)
public with sharing class UnitTest_trg_referral_input {

    static testmethod void UnitTest_trg_referral_input(){
    recordtype r=[Select id, name from RecordType where name='Partner' limit 1 ];
    Account acc= new Account(name='SunRun', lead_eligible__c=true, recordtypeid=r.id);
    insert acc;
    
    Contact c=new contact(firstname='teste',lastname='Test',account=acc);
     Contact c1=new contact(firstname='testestgsts',lastname='Test',account=acc,Stop_Payment__c=true);
     List<contact> contList=new List<Contact>();
     contList.add(c);
     contList.add(c1);
    insert contList;
     Opportunity Opp=new Opportunity(name='Test',stagename='Open',closedate=system.today(),accountid=acc.id);
     insert opp;
    
    String random='999'+math.random();
    ServiceContract sc=new ServiceContract(opportunity__c=opp.id,name=random.substring(0,10),contactid=c.id,accountid=acc.id,te_fund_name__c='CS Fund V',Agreement_Number__c=random.substring(0,10));  
    List<ServiceContract> scList=new List<ServiceContract>();
    scList.add(sc);
    insert scList;      
    Promotion__c promotion = new Promotion__c(Name='Test2',Promotion_Type__c='Customer',Start_Date__c=system.today()-5,end_date__c=system.today()+4);
    insert promotion ;    
    Referral_Input__c referral=new Referral_Input__c(opportunity__c=opp.id,service_contract__c=sclist[0].id,promotion__c=promotion.id,Target_Contact_Id__c=c.id,Source_Contact_Id__c=c.id);
    Referral_Input__c referral2=new Referral_Input__c(opportunity__c=opp.id,promotion__c=promotion.id,Source_Contact_Id__c=c.id,Target_Contact_Id__c=c.id);
    Referral_Input__c referral3=new Referral_Input__c(Milestone_1_Status__c='Qualified for Payment',Milestone_2_Status__c='Qualified for Payment',Milestone_3_Status__c='Qualified for Payment',opportunity__c=opp.id,promotion__c=promotion.id,Target_Contact_Id__c=c1.id,Source_Contact_Id__c=c1.id);    
    List<Referral_Input__c> refferalInputList=new List<Referral_Input__c>();
    refferalInputList.add(referral);
    refferalInputList.add(referral2);    
    refferalInputList.add(referral3); 
    insert refferalInputList;
    referral.Milestone_1_Status__c='Qualified for Payment';
    referral.Milestone_2_Status__c='Qualified for Payment';
    referral.Milestone_3_Status__c='Qualified for Payment';
    update referral;
    }
    }