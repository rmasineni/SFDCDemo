@istest(seeAllData=true)
public with sharing class Test_trg_Offer_after_insert{
     static testMethod void Test_trg_Offer_after_insert(){
        Test.starttest();
       Account acc = new Account(name='Test13',billingpostalcode='9000',billingstate='CA'); 
       insert acc;        
       Lead l=new Lead(IsConverted=Boolean.valueOf('false'),Channel__c='TV',Web_Lead_From_Stage__c='Created',Company='a',  LastName='a');
       insert l;              
       Opportunity opp = new Opportunity(name='Test123',Accountid=acc.id,stagename='Created',CloseDate=system.today());
       insert opp;                   
       Offer__c ofc=new Offer__c(Lead__c=l.id);
       ofc.Opportunity__c=opp.id;
       insert ofc;
    test.stopTest();
     }
}