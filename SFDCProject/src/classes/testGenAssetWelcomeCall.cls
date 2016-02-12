@isTest
private class testGenAssetWelcomeCall {

    static testMethod void testWelcomeCallDays() {
        Generation_Assets__c assetRec = new Generation_Assets__c();
        assetRec.Name = 'Test Gen Asset';
        assetRec.Home_Address__c = '100 Main St';
        assetRec.City__c = 'City';
        assetRec.Zip__c = '00001';
        assetRec.SR_Signoff__c = Date.today().addDays(-20);
        assetRec.Welcome_Call__c = Date.today();
        
        insert assetRec;
        
        assetRec.SR_Signoff__c = Date.today().addDays(-10);
        update assetRec;
    }
}