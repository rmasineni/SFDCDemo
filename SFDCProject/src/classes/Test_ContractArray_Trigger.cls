@isTest
private class Test_ContractArray_Trigger {

    static testMethod void TestContractTrigger() {
        Account a = New Account(Name = 'TestAccount');
           insert a;
         
        ServiceContract sc = New ServiceContract(Name = 'Testsc',AccountId =a.Id,Legacy_Asset_Number__c = '12222006');
           insert sc;
              
        Map<String, Id> assetRecordTypes = ServiceContractUtil.getAssetRecordTypes();
        Id recordTypeId = assetRecordTypes.get('Asset');
        Asset__c asset = New Asset__c(ServiceContract__c = sc.Id,System_Size_DC__c = 10,Type__c = 'Asset',Status__c = 'Active' , RecordTypeId = recordTypeId);
           insert asset;
        Contract_Array__c  caobject = New Contract_Array__c(April_Shade__c = 10,Asset__c = asset.Id, August_Shade__c = 15,December_Shade__c = 8,February_Shade__c = 2,July_Shade__c = 7,June_Shade__c = 6,November_Shade__c=11,October_Shade__c = 10 );
            insert caobject;        
    }
}