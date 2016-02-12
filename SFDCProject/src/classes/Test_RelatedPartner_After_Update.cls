@isTest
private class Test_RelatedPartner_After_Update {

    static testMethod void Test_RelatedPartner_After_Update() {
    Account a = New Account(Name = 'TestAccount2');
        insert a;
    ServiceContract sc = New ServiceContract(Name = 'Testsc',AccountId =a.Id,Legacy_Asset_Number__c = '12222006');
        insert sc; 
    Service_Contract_Partner_Rel__c scpr = New Service_Contract_Partner_Rel__c(Account__c=a.Id, ServiceContract__c = sc.Id, Type__c = 'Install');
      	insert	scpr;  
    Service_Contract_Partner_Rel__c scpr1 = New Service_Contract_Partner_Rel__c(Account__c=a.Id, ServiceContract__c = sc.Id, Type__c = 'Sales');
      	insert	scpr1;    	
      	  
    }
}