@isTest(SeeAllData=True)
private class TestContractSummaryController {

    static testMethod void TestContractSummaryController() {
        Account a = New Account(Name = 'TestAccount');
           insert a;
         ServiceContract sc = New ServiceContract(Name = 'Testsc',AccountId =a.Id,Legacy_Asset_Number__c = '12222006');
           insert sc;
         Service_Contract_Event__c sce = New Service_Contract_Event__c(Service_Contract__c = sc.Id);
         insert sce; 
         Asset__c asset = New Asset__c(ServiceContract__c = sc.Id,System_Size_DC__c = 10,Type__c = 'Asset',Status__c = 'Active');
           insert asset; 
        ContractSummary scObj = new ContractSummary();
        ApexPages.currentPage().getparameters().put('contractId',sc.Id);
        ApexPages.currentPage().getparameters().put('contractEventId',sce.Id);
        ApexPages.currentPage().getparameters().put('assetId',asset.Id);
        scObj.refresh();
        scObj.initialize();
        scObj.initializeAssets();
        scObj.initializeServiceContractEvent();
     
      
      
    }
}