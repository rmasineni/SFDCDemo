@isTest

public class JurisdictionOnOpptyTest{


public static testmethod void jurisdictionTestMethod1(){

  Account testAcc = new Account();
  testAcc.Name = 'Test Jurisdiction Account';
  testAcc.Account_Type__c = 'Residential';
  testAcc.billingcity = 'Fremont';
  testAcc.County__c = 'Alameda';
  insert testAcc;
  
  
    
  Opportunity oppty = new Opportunity();
  oppty.Name = 'Test Jurisdiction Opportunity';
  oppty.accountId = testAcc.Id;
  oppty.Closedate = date.today().addDays(90);
  oppty.stagename = '1. Created';
  oppty.Incorporation_Status__c = 'Yes';
  insert oppty;
  
  oppty.Incorporation_Status__c = 'No';
  update oppty;
  
  Account testAcc1 = new Account();
  testAcc1.Name = 'Test Jurisdiction Account';
  testAcc1.Account_Type__c = 'Residential';
  testAcc1.billingcity = 'San Francisco';
  testAcc1.County__c = 'San Francisco';
  insert testAcc1;
  
  Opportunity oppty1 = new Opportunity();
  oppty1.Name = 'Test Jurisdiction Opportunity1';
  oppty1.accountId = testAcc1.Id;
  oppty1.Closedate = date.today().addDays(90);
  oppty1.stagename = '1. Created';
  oppty1.Incorporation_Status__c = 'No';
  insert oppty1;
  
  oppty1.Incorporation_Status__c = 'Yes';
  update oppty1;
   
  Jurisdictions__c ahj = new Jurisdictions__c();
  ahj.Name = 'Test AHJ';
  ahj.Jurisdiction_Name__c = 'AHJ TEST';
  ahj.city__c = testAcc.billingcity;
  ahj.county__c = testAcc.county__c;
  ahj.state__c = 'CA';
  insert ahj;
  
  
  Jurisdictions__c ahj1 = new Jurisdictions__c();
  ahj1.Name = 'Test AHJ1';
  ahj1.Jurisdiction_Name__c = 'AHJ TEST 1';
  ahj1.city__c = testAcc1.billingcity;
  ahj1.county__c = testAcc1.county__c;
  ahj1.state__c = 'CA';
  insert ahj1;

  oppty.Jurisdiction__c = ahj.id;
  update oppty;
  
  oppty1.Jurisdiction__c = ahj1.id;
  update oppty1;
  

}


}