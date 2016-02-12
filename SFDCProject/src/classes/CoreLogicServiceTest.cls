@IsTest
public class CoreLogicServiceTest {
	private static CoreLogicServiceImpl impl = new CoreLogicServiceImpl();
	private static BaseClass utils = new BaseClass();

    testmethod public static void testDataRetrieval() {
        
        //We will test the happy path scenario of retrieving the response for core logic.
        FlexibleCalloutMock mock = new FlexibleCalloutMock(200, '');
        mock.ifUrlContainsReturn('authenticate', '{"authKey":"authKey"}');
        mock.ifUrlContainsReturn('parcels', '{"pageInfo":{"actualPageSize":1,"length":1,"maxPageSize":50,"page":1,"pageSize":4},"parcels":[{"OWN1_FRST":"OWN1 First Name", "OWN1_LAST":"OWN1 Last Name", "OWN2_FRST":"OWN2 First Name", "OWN2_LAST":"OWN2 Last Name", "LAND_USE":"163", "LEGAL1":"TRACT 6338 LOT 14"}]}');
        mock.ifUrlContainsReturn('features', '{"AdminLocation":{"cityType":"City"}}');
        
        Account account = new Account(Name='Foo Bar', BillingCity='Dublin');
        insert account;
        List<Sync_Record__c> syncRecords = Sf.syncService.insertSyncRecords(CoreLogicServiceDto.SyncModule, CoreLogicServiceDto.SyncAction, new Account[]{account});
		new CoreLogicJob().execute();
        Sync_Record__c syncRecord = (Sync_Record__c) utils.queryAllFields(syncRecords.get(0).id);
        System.assertEquals('Sync Failed', syncRecord.Status__c);
        System.assertEquals('Core Logic Not Enabled', syncRecord.Sub_Status__c);

        Opportunity opty = new Opportunity(Name='Foo', 
				AccountId=account.id, 
				StageName='Open');
        insert opty;
        
        Proposal__c prop = new Proposal__c(Opportunity__c=opty.id, Mode_Name__c='New',
                Sales_Rep_Email__c='test@yopmail.com', 
                Date_Issued__c=Date.today(), 
                System_Size_STC_DC__c=1, 
                Upfront_Payment__c=1.0);
        insert prop;
        
        insertSettings();
        syncRecords = Sf.syncService.insertSyncRecords(CoreLogicServiceDto.SyncModule, CoreLogicServiceDto.SyncAction, new Account[]{account});
		new CoreLogicJob().execute();

        //Because account didn't have lat/lng, it should have marked sync not applicable.
        syncRecord = (Sync_Record__c) utils.queryAllFields(syncRecords.get(0).id);
        System.assertEquals('Sync Failed', syncRecord.Status__c);
        System.assertEquals('Invalid Latitude or Longitude', syncRecord.Sub_Status__c);

        //Update lat/lng to zero and test.
        account.Latitude__c = 0.0;
        account.Longitude__c = 0.0;
        update account;
        syncRecords = Sf.syncService.insertSyncRecords(CoreLogicServiceDto.SyncModule, CoreLogicServiceDto.SyncAction, new Account[]{account});
		new CoreLogicJob().execute();

        //Because account didn't have lat/lng, it should have marked sync not applicable.
        syncRecord = (Sync_Record__c) utils.queryAllFields(syncRecords.get(0).id);
        System.assertEquals('Sync Failed', syncRecord.Status__c);
        System.assertEquals('Invalid Latitude or Longitude', syncRecord.Sub_Status__c);
		
		//This clears the recurrsion check log so we can insert new sync record.        
        CoreLogicServiceImpl.accountsProcessed.clear();

        //Update account with some lat/lng
        account.Latitude__c = 37.0;
        account.Longitude__c = -127.0;
        update account;
        
        Test.startTest();
        SyncJobInfo job = new CoreLogicJob().execute();
        Test.stopTest();
        System.assertNotEquals(null, job);
        System.assertEquals(1, job.syncRecords.size());
        System.assertEquals('Sync Success', job.syncRecords.get(0).Status__c);
    }
    
    testmethod public static void testDecodeIncorporationFlag() {
        System.assertEquals('Yes', impl.decodeIncorporationFlag(new JsonReader('{"AdminLocation":{"incorporationFlag":"1"}}')));
        System.assertEquals('No', impl.decodeIncorporationFlag(new JsonReader('{"AdminLocation":{"incorporationFlag":"0"}}')));
        System.assertEquals('null', impl.decodeIncorporationFlag(new JsonReader('{"AdminLocation":{"incorporationFlag":"-1"}}')));
    }
    
    public static void insertSettings() {
        Sf.settingsService.setString('CoreLogicEnabled', 'true');
        Sf.settingsService.setString('CoreLogicUserName', 'UserName');
        Sf.settingsService.setString('CoreLogicPassword', 'Password');
    }
}