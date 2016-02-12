@isTest
private class Test_sc_before_insert {

    static testMethod void Test_sc_before_insert() {
    	Account a = New Account(Name = 'TestAccount');
           insert a;
        ServiceContract sc = New ServiceContract(Name = 'Sunrun Contract',AccountId =a.Id,Legacy_Asset_Number__c = '12222006');
           insert sc;   
        
    }
}