@IsTest
public class AmbassadorSyncServiceTest {
    static BaseClass utils = new BaseClass();
    static AmbassadorSyncServiceImpl impl = new AmbassadorSyncServiceImpl();
    
    testmethod public static void testService() {
        Lead lead = new Lead(FirstName='Foo',LastName='Bar',Company='FooBar');
        insert lead;
        
        Referral_Input__c referral = new Referral_Input__c();
        referral.Lead__c = lead.id;
        insert referral;
        
        referral = queryReferral(referral.id);
        System.assertEquals('Referral_Status__c', referral.Ambassador_Sync_Field__c);
        System.assertEquals(BaseClass.Status_ToBeSynced, referral.Ambassador_Sync_Status__c);

        referral.Referrer_Status_1__c = 'New';
        referral.Ambassador_Sync_Status__c = null;
        update referral;
        
        referral = queryReferral(referral.id);
        System.assertEquals('Referrer_Status_1__c', referral.Ambassador_Sync_Field__c);
        System.assertEquals(BaseClass.Status_ToBeSynced, referral.Ambassador_Sync_Status__c);

        referral.Referrer_Status_2__c = 'New';
        referral.Ambassador_Sync_Status__c = null;
        update referral;
        
        referral = queryReferral(referral.id);
        System.assertEquals('Referrer_Status_2__c', referral.Ambassador_Sync_Field__c);
        System.assertEquals(BaseClass.Status_ToBeSynced, referral.Ambassador_Sync_Status__c);

        referral.Referrer_Status_3__c = 'New';
        referral.Ambassador_Sync_Status__c = null;
        update referral;
        
        referral = queryReferral(referral.id);
        System.assertEquals('Referrer_Status_3__c', referral.Ambassador_Sync_Field__c);
        System.assertEquals(BaseClass.Status_ToBeSynced, referral.Ambassador_Sync_Status__c);

        referral.Referral_Status__c = 'New';
        referral.Ambassador_Sync_Status__c = null;
        update referral;
        
        referral = queryReferral(referral.id);
        System.assertEquals('Referral_Status__c', referral.Ambassador_Sync_Field__c);
        System.assertEquals(BaseClass.Status_ToBeSynced, referral.Ambassador_Sync_Status__c);
    }

    testmethod public static void testReferralStatusSync() {
        
        Lead lead = new Lead(FirstName='Foo',LastName='Bar',Company='FooBar');
        insert lead;
        
        Referral_Input__c referral = new Referral_Input__c();
        referral.Lead__c = lead.id;
        insert referral;
        
        referral.Referrer_Status_1__c ='New';
        referral.Referrer_Status_2__c = 'New';
        referral.Referrer_Status_3__c = 'New';
        referral.Referral_Status__c = 'New';
        referral.Ambassador_Sync_Status__c = 'To Be Synced'  ;      
        update referral;        
        
        //Calling sync will not sync as settings is disabled.
        impl.syncReferrals(new String[]{referral.id});
        System.assertEquals('To Be Synced', queryReferral(referral.id).Ambassador_Sync_Status__c);
        
        //Enable the sync so when we call syncReferrals it goes through
        Sf.settingsService.setString('AmbassadorSyncEnabled', 'true');
        Sf.settingsService.setString('AmbassadorSyncUserName', 'test');
        Sf.settingsService.setString('AmbassadorSyncApiKey', 'test');
        
        impl.syncReferrals(new String[]{referral.id});
        System.assertEquals('Commission Id Empty', queryReferral(referral.id).Ambassador_Sync_Status__c);
     // System.assertEquals('To Be Synced', queryReferral(referral.id).Ambassador_Sync_Status__c);
            
        //Add commission id and run the sync.
        lead.Commission_Id__c = '123';
        update lead;
        
        FlexibleCalloutMock mock = new FlexibleCalloutMock(200, '');
        
        Test.startTest();
        impl.syncReferrals(new String[]{referral.id});
        Test.stopTest();
        referral = queryReferral(referral.id);
        //System.assertEquals(null, referral.Ambassador_Sync_Details__c);
        //System.assertEquals('Sync Success', referral.Ambassador_Sync_Status__c);
    }    

    testmethod public static void testPaymentStatusSync() {
        
        Lead lead = new Lead(FirstName='Foo',LastName='Bar',Company='FooBar');
        insert lead;
        
        Referral_Input__c referral = new Referral_Input__c();
        referral.Lead__c = lead.id;
        insert referral;
        
        lead.Commission_Id__c = '123';
        update lead;

        referral.Referrer_Status_1__c = 'New';
        update referral;

        //Enable the sync so when we call syncReferrals it goes through
        Sf.settingsService.setString('AmbassadorSyncEnabled', 'true');
        Sf.settingsService.setString('AmbassadorSyncUserName', 'test');
        Sf.settingsService.setString('AmbassadorSyncApiKey', 'test');
        FlexibleCalloutMock mock = new FlexibleCalloutMock(200, '');
        
        Test.startTest();
        impl.syncReferrals(new String[]{referral.id});
        Test.stopTest();

        referral = queryReferral(referral.id);
        System.assertEquals(null, referral.Ambassador_Sync_Details__c);
        System.assertEquals('Sync Success', referral.Ambassador_Sync_Status__c);
    }    
    
    testmethod public static void testSyncNonAmbassadorReferrals() {
     //  try{
        Lead lead = new Lead(FirstName='Foo',LastName='Bar',Company='FooBar',email='testleademail@gmail.com');
        insert lead;
        
        Account Acc = new Account(Name ='TestAccount');
        insert Acc;
        
        Contact Con = new Contact(AccountId=Acc.Id, FirstName='TestFname', LastName='TestLName', Ambassador__Ambassador_ID__c='43521',campaign_uid__c='23451',Email='testemail@gmail.com');
        insert Con;
        
        Referral_Input__c referral = new Referral_Input__c();
        referral.Lead__c = lead.id;
    //  referral.Referrer_Payment_1_Amount__c = 5612;
        referral.Source_Contact_Id__c = Con.id;
        referral.Referral_Status__c = 'New';
        insert referral;
        
        //lead.Commission_Id__c = '123';
        //update lead;

        referral.Referrer_Status_1__c = 'New';
        update referral;

        //Enable the sync so when we call syncReferrals it goes through
        Sf.settingsService.setString('AmbassadorSyncEnabled', 'true');
        Sf.settingsService.setString('AmbassadorSyncUserName', 'test');
        Sf.settingsService.setString('AmbassadorSyncApiKey', 'test');
        MockHttpResponseForAPI2 mock = new MockHttpResponseForAPI2();
        
        Test.startTest();
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseForAPI2());
        impl.syncNonAmbassadorReferrals(new String[]{referral.id});
        impl.getNonAmbassadorReferralSyncUrl();
                Test.stopTest();

        referral = queryReferral(referral.id);
        System.assertEquals(null, referral.Ambassador_Sync_Details__c);
       // System.assertEquals('Sync Success', referral.Ambassador_Sync_Status__c);
     //   }
     /*   Catch(Exception e) 
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
        } */ 
    }   
        
    
    testmethod public static void testSyncERPContacts() {
        
       // Lead lead = new Lead(FirstName='Foo',LastName='Bar',Company='FooBar',email='testleademail@gmail.com');
       // insert lead;
   //    try{ 
        Account Acc = new Account(Name ='TestAccount');
        insert Acc;
        
        Contact Con = new Contact(AccountId= Acc.id, FirstName='TestFname', LastName='TestLName', Ambassador__Ambassador_ID__c='43521',campaign_uid__c='23451',Email='testemail@gmail.com');
        insert Con;
        
        ServiceContract SC = new ServiceContract(name='989032322', ContactId=Con.id,Agreement_Number__c='2121213233');
        insert SC;
        /*
            Referral_Input__c referral = new Referral_Input__c();
            referral.Lead__c = lead.id;
            referral.Referrer_Payment_1_Amount__c = 5612;
            referral.Source_Contact_Id__c = Con.id;
            referral.Referral_Status__c = 'New';
            insert referral;
            
            lead.Commission_Id__c = '123';
            update lead;

            referral.Milestone_1_Status__c = 'New';
            update referral;
        */
        //Enable the sync so when we call syncReferrals it goes through
        Sf.settingsService.setString('AmbassadorSyncEnabled', 'true');
        Sf.settingsService.setString('AmbassadorSyncUserName', 'test');
        Sf.settingsService.setString('AmbassadorSyncApiKey', 'test');
       
        Test.startTest();
        // Set mock callout class
      //  Test.setMock(AmbassadorSyncServiceImpl.class, new MockHttpResponseForAPI1());
      //  impl.syncNonAmbassadorReferrals(new String[]{Con.id});
      Test.setMock(HttpCalloutMock.class, new MockHttpResponseForAPI1());
      impl.syncERPContacts(new String[]{Con.id});
        Test.stopTest();
    //    }
    /*    Catch(Exception e) 
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }  */

       // referral = queryReferral(referral.id);
       // System.assertEquals(null, referral.Ambassador_Sync_Details__c);
       // System.assertEquals('Sync Success', referral.Ambassador_Sync_Status__c);
    /*  AmbassadorERPSyncJob TempERP = new AmbassadorERPSyncJob();

      AmbassadorCommissionSyncJob TempComm = new AmbassadorCommissionSyncJob();
    */
    }  
    
   testmethod public static void testAmbassadorSyncERPSyncAndCommissionSyncJob()
   {
     test.starttest ();
     AmbassadorSyncJob TempAmbassadorSync = new AmbassadorSyncJob();
     TempAmbassadorSync.referralIds = null;
     ID jobID1 = System.enqueueJob(TempAmbassadorSync);
 
     AmbassadorERPSyncJob TempERP = new AmbassadorERPSyncJob();
     TempERP.ERPContIds = null;
     ID jobID2 = System.enqueueJob(TempERP);
     
     ActivateRefereeSyncjob TempActivate = new ActivateRefereeSyncjob();
     TempActivate.ERPContIds = null;
     ID jobID4 = System.enqueueJob(TempActivate);
     
     AmbassadorCommissionSyncJob TempComm = new AmbassadorCommissionSyncJob();
     TempComm.referralIds = null;
     ID jobID3 = System.enqueueJob(TempComm);
     Test.stopTest();   
 
   }
    public static Referral_Input__c queryReferral(Id refId) {
        return (Referral_Input__c) utils.queryAllFields('Referral_Input__c', refId);
    }
    
}