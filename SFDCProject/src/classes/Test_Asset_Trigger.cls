@isTest
private class Test_Asset_Trigger {
    static testMethod void Test_Asset_Trigger() {
         Test.starttest();
        Account a = New Account(Name = 'TestAccount');
        insert a;
         
        ServiceContract sc = New ServiceContract(Name = 'Testsc',AccountId =a.Id,Legacy_Asset_Number__c = '12222006');
		insert sc;

        Map<String, Id> assetRecordTypes = ServiceContractUtil.getAssetRecordTypes();
        Id recordTypeId = assetRecordTypes.get('Asset');
        Asset__c asset = New Asset__c(ServiceContract__c = sc.Id,System_Size_DC__c = 10,Type__c = 'Asset',Status__c = 'Active', RecordTypeId = recordTypeId);
        insert asset;
       Test.stoptest();             
           
    }
}