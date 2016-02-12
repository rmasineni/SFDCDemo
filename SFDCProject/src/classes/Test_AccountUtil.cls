@isTest
private class Test_AccountUtil {

    static testMethod void myUnitTest() {
        Account acc = new Account(Name = 'test account1', Zip_6__c = '94536');
        insert acc;
        
        //acc.Zip_6__c = '94537';
        //update acc;
        Account acc1 = new Account(Name = 'test account1', Zip_6__c = '94538');
        insert acc1;
        
        // accUtil  =new AccountUtil();
        AccountUtil.isZip6Changed(acc,acc1);
        AccountUtil.isAddressInformationChanged(acc,acc1);
        AccountUtil.copyAcctAddressInformation(acc,acc1);
        
    }
}