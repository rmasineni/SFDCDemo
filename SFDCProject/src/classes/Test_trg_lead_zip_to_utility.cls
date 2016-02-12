@isTest(SeeAllData=true)
public with sharing class Test_trg_lead_zip_to_utility {

  static testmethod void method1(){
  ZipUtility__c zp=new ZipUtility__c(Territory__c='P',Zip_Code__c='00000',Utility_Company__c='Pacific Gas and Electric (PG&E)',Sales_Branch__c='Bakersfield');
  List<ZipUtility__c> zpList=new List<ZipUtility__c>();
  zpList.add(zp);
  insert zp;
  Lead l = new Lead(Postalcode='00000',LastName='Test123',company='Home');
  insert l;
   
   }
}