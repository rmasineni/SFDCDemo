@IsTest
public class AwsSyncServiceTest {

    private static BaseClass utils = new BaseClass();
	private static BaseAwsService awsService = new BaseAwsService();
    private static FlexibleCalloutMock mock = new FlexibleCalloutMock(200, '');
    
	testmethod public static void testLeadsTrigger() {
        insertSettings();
        
        Lead lead = new Lead(FirstName='Foo', LastName='Bar', Company='Foo');
        insert lead;
        
        //With sync disabled, update a monitored field and make sure sync records are not created.
        lead.Lead_Status__c = 'Updated';
        update lead;
		System.assertEquals(0, querySyncRecords(lead.id).size());	
        
        //Enable the sync and update the a field which is not monitored and it should not
        //create sync records. For excample, lastname is not monitored.
        Sf.settingsService.setBoolean('AwsSqsLeadsSyncEnabled', true);
        lead.LastName = 'Bar2';
        update lead;
		System.assertEquals(0, querySyncRecords(lead.id).size());
		
        //Now update a lead field which is monitored and it should create a sync record.
        lead.FirstName = 'Foo2';
        update lead;
		System.assertEquals(1, querySyncRecords(lead.id).size());
    }
	
	testmethod public static void testLeadsSync() {
        insertSettings();
        Lead lead = new Lead(FirstName='Foo', LastName='Bar', Company='Foo');
        insert lead;
		
        //Create a sync record.
        List<Sync_Record__c> syncRecords = Sf.syncService.insertSyncRecords('AwsSqsSync', 'LeadsSync', new Sobject[]{lead});
		
		//With sync disabled, run the job and make sure status is updated as Not Applicable/Sqs Sync Not Enabled
		new AwsSqsLeadsSyncJob().execute();
        Sync_Record__c syncRecord = querySyncRecord(syncRecords.get(0).id);
        System.assertEquals('Sync Not Applicable', syncRecord.Status__c);
        System.assertEquals('Sqs Sync Not Enabled', syncRecord.Sub_Status__c);
        
        //===================================================================
        //Now enable the sync with queue not configured. Sync should fail with 
        //as we haven't configured the sqs.
        Sf.settingsService.setString('AwsSqsLeadsSyncEnabled', 'true'); 
		syncRecord.Status__c = 'To Be Synced';
        update syncRecord;
        
		new AwsSqsLeadsSyncJob().execute();
        syncRecord = querySyncRecord(syncRecords.get(0).id);
        System.assertEquals('Sync Not Applicable', syncRecord.Status__c);
        System.assertEquals('SQS Queue Not Configured', syncRecord.Sub_Status__c);
		
        //===================================================================
        //Now configure the account with sqs queue and try to sync again. This time 
        //sync should go through.
		Account acct = new Account(Name='Foo', RecordTypeId=utils.getRecordTypeId('Account', 'Partner'), 
			Sqs_Queue_Name__c='Test',
			Office_Location__c  = 'Headquarters',
			Stage__c = 'Confirmed',
			Active__c  = true);
        insert acct;
        lead.Lead_Gen_Partner__c = acct.id;
        lead.Sales_Partner__c = acct.id;
        lead.Partner_for_Lead_Passing__c = acct.id;
        update lead;

		syncRecord.Status__c = 'To Be Synced';
        update syncRecord;

        new AwsSqsLeadsSyncJob().execute();
        syncRecord = querySyncRecord(syncRecords.get(0).id);
        System.assertEquals('Sync Success', syncRecord.Status__c);
        System.assertEquals(null, syncRecord.Sub_Status__c);
        
        //Test to ensure the sqs payload was appropriate.
        //JsonReader jsonReader = new JsonReader(mock.invocations.get(0).request.body.toString());
    }
    
	testmethod public static void testOptysTrigger() {
        insertSettings();
        
        //Insert opty and make sure we didn't create any sync records.
        Opportunity opty = new Opportunity(Name='Test', StageName='Stage', CloseDate=Date.today());
        insert opty;
		System.assertEquals(0, querySyncRecords(opty.id).size());

        //With sync disabled, update a monitored field and make sure sync records are not created.
        opty.Opportunity_Status__c = 'Updated';
        update opty;
		System.assertEquals(0, querySyncRecords(opty.id).size());
        
        //Enable the sync and update the a field which is not monitored and it should not
        //create sync records. For excample, Opportunity_Status__c is not monitored.
        Sf.settingsService.setBoolean('AwsSqsOptysSyncEnabled', true);
        opty.Opportunity_Status__c = 'UpdatedValue';
        update opty;
		System.assertEquals(0, querySyncRecords(opty.id).size());
		
        //Now update a lead field which is monitored and it should create a sync record.
        //For opty StageName is monitored
        opty.StageName = 'Created2';
        update opty;
		System.assertEquals(1, querySyncRecords(opty.id).size());
    }

	testmethod public static void testOptysSync() {
        insertSettings();
        
        Opportunity opty = new Opportunity(Name='Foo', StageName='Bar', CloseDate=Date.today());
        insert opty;

        //Create a sync record.
        List<Sync_Record__c> syncRecords = Sf.syncService.insertSyncRecords('AwsSqsSync', 'OptysSync', new Sobject[]{opty});
		
		//With sync disabled, run the job and make sure status is updated as Not Applicable/Sqs Sync Not Enabled
		new AwsSqsOptysSyncJob().execute();
        Sync_Record__c syncRecord = querySyncRecord(syncRecords.get(0).id);
        System.assertEquals('Sync Not Applicable', syncRecord.Status__c);
        System.assertEquals('Sqs Sync Not Enabled', syncRecord.Sub_Status__c);
        
        //===================================================================
        //Now enable the sync with queue not configured. Sync should fail with 
        //as we haven't configured the sqs.
        Sf.settingsService.setString('AwsSqsOptysSyncEnabled', 'true'); 
		syncRecord.Status__c = 'To Be Synced';
        update syncRecord;
        
		new AwsSqsOptysSyncJob().execute();
        syncRecord = querySyncRecord(syncRecords.get(0).id);
        System.assertEquals('Sync Not Applicable', syncRecord.Status__c);
        System.assertEquals('SQS Queue Not Configured', syncRecord.Sub_Status__c);
		
        //===================================================================
        //Now configure the account with sqs queue and try to sync again. This time 
        //sync should go through.
		Account acct = new Account(Name='Foo', RecordTypeId=utils.getRecordTypeId('Account', 'Partner'), 
			Sqs_Queue_Name__c='Test',
			Office_Location__c  = 'Headquarters',
			Stage__c = 'Confirmed',
			Active__c  = true);
        insert acct;
        opty.Lead_Gen_Partner__c = acct.id;
        opty.Sales_Partner__c = acct.id;
        opty.Partner_for_Lead_Passing__c = acct.id;
        update opty;

		syncRecord.Status__c = 'To Be Synced';
        update syncRecord;

        new AwsSqsOptysSyncJob().execute();
        syncRecord = querySyncRecord(syncRecords.get(0).id);
        System.assertEquals('Sync Success', syncRecord.Status__c);
        System.assertEquals(null, syncRecord.Sub_Status__c);
    }
	
    testmethod public static void testOptyContactUpdateSync() {
		insertSettings();
        
        Opportunity opty1 = new Opportunity(Name='Test', StageName='Stage', CloseDate=Date.today());
        insert opty1;
        
        Opportunity opty2 = new Opportunity(Name='Test', StageName='Stage', CloseDate=Date.today());
        insert opty2;

        Account acct = new Account(Name='Foo');
        insert acct;
        
        Contact contact = new Contact(FirstName='Foo', LastName='Bar', AccountId=acct.id);
        insert contact;
        
        //We need to update all opties which are associated with contact. However, if a contact is associated
        //with same opty multiple times, then we need to sync only once.
        insert new OpportunityContactRole(OpportunityId=opty1.id, ContactId=contact.id, Role='Role1');
        insert new OpportunityContactRole(OpportunityId=opty1.id, ContactId=contact.id, Role='Role2');
        insert new OpportunityContactRole(OpportunityId=opty2.id, ContactId=contact.id, Role='Role3');
        insert new OpportunityContactRole(OpportunityId=opty2.id, ContactId=contact.id, Role='Role4');

        //With sync disabled, update a monitored field but ensure no sync records are created.
        contact.FirstName = 'Foo2';
        update contact;
		System.assertEquals(0, querySyncRecords(opty1.id).size());
		System.assertEquals(0, querySyncRecords(opty2.id).size());
        
        //Enable the sync and update a monitored field but still no sync records should be created.
        Sf.settingsService.setBoolean('AwsSqsOptysSyncEnabled', true);
        contact.LastName = 'Bar2';
        update contact;
		System.assertEquals(0, querySyncRecords(opty1.id).size());
		System.assertEquals(0, querySyncRecords(opty2.id).size());
		
        //Now update the monitored field and ensure sync records are created for each opty.
        contact.FirstName = 'Foo3';
        update contact;
		System.assertEquals(1, querySyncRecords(opty1.id).size());
		System.assertEquals(1, querySyncRecords(opty2.id).size());
    }
    
    testmethod public static void testOptyAccountUpdateSync() {
		insertSettings();
        
        Account acct = new Account(Name='Foo', BillingStreet='1 Spear St', BillingCity='San Francisco', BillingState='CA');
        insert acct;

        //Two opties associated with this account one opty without.
        Opportunity opty1 = new Opportunity(Name='Test', StageName='Stage', CloseDate=Date.today(), AccountId=acct.id);
        insert opty1;
        
        Opportunity opty2 = new Opportunity(Name='Test', StageName='Stage', CloseDate=Date.today(), AccountId=acct.id);
        insert opty2;

        Opportunity opty3 = new Opportunity(Name='Test', StageName='Stage', CloseDate=Date.today());
        insert opty3;
        
        //With sync disabled, update a monitored field but ensure no sync records are created.
        acct.Name = 'Foo2';
        update acct;
		System.assertEquals(0, querySyncRecords(opty1.id).size());
		System.assertEquals(0, querySyncRecords(opty2.id).size());
		System.assertEquals(0, querySyncRecords(opty3.id).size());
        
        //Enable the sync and update a monitored field but still no sync records should be created.
        Sf.settingsService.setBoolean('AwsSqsOptysSyncEnabled', true);
        acct.Site  = 'Some Site';
        update acct;
		System.assertEquals(0, querySyncRecords(opty1.id).size());
		System.assertEquals(0, querySyncRecords(opty2.id).size());
		System.assertEquals(0, querySyncRecords(opty3.id).size());
		
        //Now update the monitored field and ensure sync records are created for each opty.
        acct.Name = 'Foo3';
        update acct;
		System.assertEquals(1, querySyncRecords(opty1.id).size());
		System.assertEquals(1, querySyncRecords(opty2.id).size());
        
        //Third opty should not be marked for sync as this account was not associated with it.
		System.assertEquals(0, querySyncRecords(opty3.id).size());
    }
	
    
    //Tests if opty corresponding to the payment tx is marked as to be synced
    //when new payment tx is inserted.
    testmethod public static void testPaymentsTrigger() {
		insertSettings();
        
		Account acct = new Account(Name='Foo', RecordTypeId=utils.getRecordTypeId('Account', 'Partner'), 
			Sqs_Queue_Name__c='Test',
			Office_Location__c  = 'Headquarters',
			Stage__c = 'Confirmed',
			Active__c  = true);
        insert acct;

        Opportunity opty = new Opportunity(Name='Test', StageName='Stage', CloseDate=Date.today());
        opty.Lead_Gen_Partner__c = acct.id;
        opty.Sales_Partner__c = acct.id;
        opty.Partner_for_Lead_Passing__c = acct.id;
        insert opty;
        
        //With sync disabled, insert payment txn and it should not create sync records.
        Payment_Transaction__c tx = new Payment_Transaction__c(Opportunity__c=opty.id, Status__c='accept');
        insert tx;
		System.assertEquals(0, querySyncRecords(tx.id).size());
		
		//Enable sync and then insert payment txn with status failure and sync should not happen.
		Sf.settingsService.setBoolean('AwsSqsPaymentsSyncEnabled', true);
        tx = new Payment_Transaction__c(Opportunity__c=opty.id, Status__c='failed');
        insert tx;
		System.assertEquals(0, querySyncRecords(tx.id).size());
	
		//Now insert a payment with status accept and see that sync record created for payment        
        tx = new Payment_Transaction__c(Opportunity__c=opty.id, Status__c='accept');
        insert tx;
		System.assertEquals(1, querySyncRecords(tx.id).size());
    }

    
	testmethod public static void testPaymentsSync() {
        insertSettings();
        
		Account acct = new Account(Name='Foo', RecordTypeId=utils.getRecordTypeId('Account', 'Partner'), 
			Office_Location__c  = 'Headquarters',
			Stage__c = 'Confirmed',
			Active__c  = true);
        insert acct;

        Opportunity opty = new Opportunity(Name='Test', StageName='Stage', CloseDate=Date.today());
        opty.Lead_Gen_Partner__c = acct.id;
        opty.Sales_Partner__c = acct.id;
        opty.Partner_for_Lead_Passing__c = acct.id;
        insert opty;
        
        //With sync disabled, insert payment txn and it should not create sync records.
        Payment_Transaction__c tx = new Payment_Transaction__c(Opportunity__c=opty.id, Status__c='accept');
        insert tx;

        //Create a sync record.
        List<Sync_Record__c> syncRecords = Sf.syncService.insertSyncRecords('AwsSqsSync', 'PaymentsSync', new Sobject[]{tx});
		
        //===================================================================
		//With sync disabled, run the job and make sure status is updated as Not Applicable/Sqs Sync Not Enabled
		new AwsSqsPaymentsSyncJob().execute();
        Sync_Record__c syncRecord = querySyncRecord(syncRecords.get(0).id);
        System.assertEquals('Sync Not Applicable', syncRecord.Status__c);
        System.assertEquals('Sqs Sync Not Enabled', syncRecord.Sub_Status__c);
        
        //===================================================================
        //Now enable the sync with queue not configured. Sync should fail with 
        //as we haven't configured the sqs.
        Sf.settingsService.setString('AwsSqsPaymentsSyncEnabled', 'true'); 
		syncRecord.Status__c = 'To Be Synced';
        update syncRecord;
        
		new AwsSqsPaymentsSyncJob().execute();
        syncRecord = querySyncRecord(syncRecords.get(0).id);
        System.assertEquals(null, syncRecord.Message__c);
        System.assertEquals('Sync Not Applicable', syncRecord.Status__c);
        System.assertEquals('SQS Queue Not Configured', syncRecord.Sub_Status__c);
		
        //===================================================================
        //Now configure the account with sqs queue and try to sync again. This time 
        //sync should go through.
		acct.Sqs_Queue_Name__c='Test';
        update acct;

        syncRecord.Status__c = 'To Be Synced';
        update syncRecord;

        new AwsSqsPaymentsSyncJob().execute();
        syncRecord = querySyncRecord(syncRecords.get(0).id);
        System.assertEquals('Sync Success', syncRecord.Status__c);
        System.assertEquals(null, syncRecord.Sub_Status__c);
    }
    
    //Tests if opty corresponding to the contact's whose credit details are changed,
    //is updated with sqs to be synced when new credit record is inserted.
    testmethod public static void testCreditsTrigger() {
        //This is rquired as some trigger is looking for.
		insertSettings();
        
		Account acct = new Account(Name='Foo', RecordTypeId=utils.getRecordTypeId('Account', 'Partner'), 
			Sqs_Queue_Name__c='Test', BillingStreet='Market', Billingcity='Dublin',
			Office_Location__c  = 'Headquarters',
			Stage__c = 'Confirmed',
			Active__c  = true);
        insert acct;

        Opportunity opty = new Opportunity(Name='Test', StageName='Stage', CloseDate=Date.today());
        opty.Lead_Gen_Partner__c = acct.id;
        opty.Sales_Partner__c = acct.id;
        opty.Partner_for_Lead_Passing__c = acct.id;
        insert opty;

        Contact contact = new Contact(FirstName='Foo', LastName='Bar', AccountId=acct.id);
        insert contact;
        
        Contact contact2 = new Contact(FirstName='Foo', LastName='Bar', AccountId=acct.id);
        insert contact2;

        OpportunityContactRole role = new OpportunityContactRole(OpportunityId=opty.id, ContactId=contact.id, Role='Foo');
        insert role;
		
		//With sync disabled, even if we insert credit, it should not create sync records.        
        Customer_Credit__c credit = new Customer_Credit__c(Contact__c=contact.id);
        insert credit;
		System.assertEquals(0, querySyncRecords(credit.id).size());
        
        //With sync enabled, it should create a sync record.
   		Sf.settingsService.setBoolean('AwsSqsCreditsSyncEnabled', true);
        credit = new Customer_Credit__c(Contact__c=contact.id);
        insert credit;
		System.assertEquals(1, querySyncRecords(credit.id).size());
        
        //If we insert credit into contcat which is not associated with opty, then it should not create sync records.
        credit = new Customer_Credit__c(Contact__c=contact2.id);
        insert credit;
		System.assertEquals(0, querySyncRecords(credit.id).size());
    }
    
	testmethod public static void testCreditsSync() {
        insertSettings();
        
		Account acct = new Account(Name='Foo', RecordTypeId=utils.getRecordTypeId('Account', 'Partner'), 
			BillingStreet='Market', Billingcity='Dublin',
			Office_Location__c  = 'Headquarters',
			Stage__c = 'Confirmed',
			Active__c  = true);
        insert acct;

        Opportunity opty = new Opportunity(Name='Test', StageName='Stage', CloseDate=Date.today());
        opty.Lead_Gen_Partner__c = acct.id;
        opty.Sales_Partner__c = acct.id;
        opty.Partner_for_Lead_Passing__c = acct.id;
        insert opty;

        Contact contact = new Contact(FirstName='Foo', LastName='Bar', AccountId=acct.id);
        insert contact;
        
        Contact contact2 = new Contact(FirstName='Foo', LastName='Bar', AccountId=acct.id);
        insert contact2;

        OpportunityContactRole role = new OpportunityContactRole(OpportunityId=opty.id, ContactId=contact.id, Role='Foo');
        insert role;
		
		//With sync disabled, even if we insert credit, it should not create sync records.        
        Customer_Credit__c credit = new Customer_Credit__c(Contact__c=contact.id);
        insert credit;

        //Create a sync record.
        List<Sync_Record__c> syncRecords = Sf.syncService.insertSyncRecords('AwsSqsSync', 'CreditsSync', new Sobject[]{credit});
		
        //===================================================================
		//With sync disabled, run the job and make sure status is updated as Not Applicable/Sqs Sync Not Enabled
		new AwsSqsCreditsSyncJob().execute();
        Sync_Record__c syncRecord = querySyncRecord(syncRecords.get(0).id);
        System.assertEquals('Sync Not Applicable', syncRecord.Status__c);
        System.assertEquals('Sqs Sync Not Enabled', syncRecord.Sub_Status__c);
        
        //===================================================================
        //Now enable the sync with queue not configured. Sync should fail with 
        //as we haven't configured the sqs.
        Sf.settingsService.setString('AwsSqsCreditsSyncEnabled', 'true'); 
		syncRecord.Status__c = 'To Be Synced';
        update syncRecord;
        
		new AwsSqsCreditsSyncJob().execute();
        syncRecord = querySyncRecord(syncRecords.get(0).id);
        System.assertEquals(null, syncRecord.Message__c);
        System.assertEquals('Sync Not Applicable', syncRecord.Status__c);
        System.assertEquals('SQS Queue Not Configured', syncRecord.Sub_Status__c);
		
        //===================================================================
        //Now configure the account with sqs queue and try to sync again. This time 
        //sync should go through.
		acct.Sqs_Queue_Name__c='Test';
        update acct;

        syncRecord.Status__c = 'To Be Synced';
        update syncRecord;

        new AwsSqsCreditsSyncJob().execute();
        syncRecord = querySyncRecord(syncRecords.get(0).id);
        System.assertEquals('Sync Success', syncRecord.Status__c);
        System.assertEquals(null, syncRecord.Sub_Status__c);
    }
    
	testmethod public static void testContractsTrigger() {
		insertSettings();
        
		Account acctWithQueue = new Account(Name='Foo', RecordTypeId=utils.getRecordTypeId('Account', 'Partner'), 
			Sqs_Queue_Name__c='Test', BillingCity='Dublin',
			Office_Location__c  = 'Headquarters',
			Stage__c = 'Confirmed',
			Active__c  = true);
        insert acctWithQueue;

		Account acctWoQueue = new Account(Name='Foo', RecordTypeId=utils.getRecordTypeId('Account', 'Partner'), 
			BillingCity='Dublin',
			Office_Location__c  = 'Headquarters',
			Stage__c = 'Confirmed',
			Active__c  = true);
        insert acctWoQueue;

        Opportunity opty1 = new Opportunity(Name='Test', StageName='Stage', CloseDate=Date.today());
        opty1.Lead_Gen_Partner__c = acctWithQueue.id;
        opty1.Sales_Partner__c = acctWithQueue.id;
        opty1.Partner_for_Lead_Passing__c = acctWithQueue.id;
        insert opty1;
        
        Opportunity opty2 = new Opportunity(Name='Test', StageName='Stage', CloseDate=Date.today());
        opty2.Lead_Gen_Partner__c = acctWoQueue.id;
        opty2.Sales_Partner__c = acctWoQueue.id;
        opty2.Partner_for_Lead_Passing__c = acctWoQueue.id;
        insert opty2;

        //With sync disabled, insert contract and it should not create sync records.
        ServiceContract contract = new ServiceContract(Opportunity__c=opty1.id);
        AwsSyncServiceImpl.syncRecordsCreatedIds.clear();
        insert contract;
		System.assertEquals(0, querySyncRecords(contract.id).size());
		
		//Enable sync and then insert contract without status failure and sync should not happen.
		Sf.settingsService.setBoolean('AwsSqsContractsSyncEnabled', true);
        contract = new ServiceContract(Opportunity__c=opty2.id);
        AwsSyncServiceImpl.syncRecordsCreatedIds.clear();
        insert contract;
		System.assertEquals(0, querySyncRecords(contract.id).size());
	
		//insert a contract and see that sync record created
		Sf.settingsService.setBoolean('AwsSqsContractsSyncEnabled', true);
        contract = new ServiceContract(Opportunity__c=opty1.id);
        AwsSyncServiceImpl.syncRecordsCreatedIds.clear();
        insert contract;
		System.assertEquals(1, querySyncRecords(contract.id).size());
		delete querySyncRecords(contract.id);

        //update a contract with non-eligible field and see that sync record not created
		contract.Opportunity__c = opty1.id;
        contract.Agreement_Type__c  = 'Some Value';
        AwsSyncServiceImpl.syncRecordsCreatedIds.clear();
        update contract;
		System.assertEquals(0, querySyncRecords(contract.id).size());

        //update a contract with eligible field and see that sync record not created
        contract.Status__c = 'Some new updated value';
        AwsSyncServiceImpl.syncRecordsCreatedIds.clear();
        update contract;
		System.assertEquals(1, querySyncRecords(contract.id).size());
    }
    
	testmethod public static void testContractsSync() {
        insertSettings();
        
		Account acct = new Account(Name='Foo', RecordTypeId=utils.getRecordTypeId('Account', 'Partner'), 
			BillingCity='Dublin',
			Office_Location__c  = 'Headquarters',
			Stage__c = 'Confirmed',
			Active__c  = true);
        insert acct;

        Opportunity opty1 = new Opportunity(Name='Test', StageName='Stage', CloseDate=Date.today());
        opty1.Lead_Gen_Partner__c = acct.id;
        opty1.Sales_Partner__c = acct.id;
        opty1.Partner_for_Lead_Passing__c = acct.id;
        insert opty1;

        ServiceContract contract = new ServiceContract(Opportunity__c=opty1.id);
        insert contract;
        
        //Create a sync record.
        List<Sync_Record__c> syncRecords = Sf.syncService.insertSyncRecords('AwsSqsSync', 'ContractsSync', new Sobject[]{contract});
		
        //===================================================================
		//With sync disabled, run the job and make sure status is updated as Not Applicable/Sqs Sync Not Enabled
		new AwsSqsContractsSyncJob().execute();
        Sync_Record__c syncRecord = querySyncRecord(syncRecords.get(0).id);
        System.assertEquals('Sync Not Applicable', syncRecord.Status__c);
        System.assertEquals('Sqs Sync Not Enabled', syncRecord.Sub_Status__c);
        
        //===================================================================
        //Now enable the sync with queue not configured. Sync should fail with 
        //as we haven't configured the sqs.
        Sf.settingsService.setString('AwsSqsContractsSyncEnabled', 'true');
		syncRecord.Status__c = 'To Be Synced';
        update syncRecord;
        
		new AwsSqsContractsSyncJob().execute();
        syncRecord = querySyncRecord(syncRecords.get(0).id);
        System.assertEquals(null, syncRecord.Message__c);
        System.assertEquals('Sync Not Applicable', syncRecord.Status__c);
        System.assertEquals('SQS Queue Not Configured', syncRecord.Sub_Status__c);
		
        //===================================================================
        //Now configure the account with sqs queue and try to sync again. This time 
        //sync should go through.
		acct.Sqs_Queue_Name__c='Test';
        update acct;

        syncRecord.Status__c = 'To Be Synced';
        update syncRecord;

        new AwsSqsContractsSyncJob().execute();
        syncRecord = querySyncRecord(syncRecords.get(0).id);
        System.assertEquals('Sync Success', syncRecord.Status__c);
        System.assertEquals(null, syncRecord.Sub_Status__c);
    }

	testmethod public static void testProposalsTrigger() {
		insertSettings();
        
		Account acctWithQueue = new Account(Name='Foo', RecordTypeId=utils.getRecordTypeId('Account', 'Partner'), 
			Sqs_Queue_Name__c='Test', BillingCity='Dublin',
			Office_Location__c  = 'Headquarters',
			Stage__c = 'Confirmed',
			Active__c  = true);
        insert acctWithQueue;

		Account acctWoQueue = new Account(Name='Foo', RecordTypeId=utils.getRecordTypeId('Account', 'Partner'), 
			BillingCity='Dublin',
			Office_Location__c  = 'Headquarters',
			Stage__c = 'Confirmed',
			Active__c  = true);
        insert acctWoQueue;

        Opportunity opty1 = new Opportunity(Name='Test', StageName='Stage', CloseDate=Date.today());
        opty1.Lead_Gen_Partner__c = acctWithQueue.id;
        opty1.Sales_Partner__c = acctWithQueue.id;
        opty1.Partner_for_Lead_Passing__c = acctWithQueue.id;
        insert opty1;
        
        Opportunity opty2 = new Opportunity(Name='Test', StageName='Stage', CloseDate=Date.today());
        opty2.Lead_Gen_Partner__c = acctWoQueue.id;
        opty2.Sales_Partner__c = acctWoQueue.id;
        opty2.Partner_for_Lead_Passing__c = acctWoQueue.id;
        insert opty2;

        //With sync disabled, insert proposal and it should not create sync records.
        Proposal__c proposal = new Proposal__c(Mode_Name__c='Mode', Opportunity__c=opty1.id,
			Sales_Rep_Email__c='test@yopmail.com', Date_Issued__c=Date.today(), System_Size_STC_DC__c=10.0, Upfront_Payment__c=00.0);
        AwsSyncServiceImpl.syncRecordsCreatedIds.clear();
        insert proposal;
		System.assertEquals(0, querySyncRecords(proposal.id).size());
		
		//Enable sync and then insert proposal without queue and sync should not happen.
		Sf.settingsService.setBoolean('AwsSqsProposalsSyncEnabled', true);
        proposal = new Proposal__c(Mode_Name__c='Mode', Opportunity__c=opty2.id,
			Sales_Rep_Email__c='test@yopmail.com', Date_Issued__c=Date.today(), System_Size_STC_DC__c=10.0, Upfront_Payment__c=00.0);
        AwsSyncServiceImpl.syncRecordsCreatedIds.clear();
        insert proposal;
		System.assertEquals(0, querySyncRecords(proposal.id).size());
	
		//insert proposal with queue and see that sync record created
        proposal = new Proposal__c(Mode_Name__c='Mode', Opportunity__c=opty1.id,
			Sales_Rep_Email__c='test@yopmail.com', Date_Issued__c=Date.today(), System_Size_STC_DC__c=10.0, Upfront_Payment__c=00.0);
        AwsSyncServiceImpl.syncRecordsCreatedIds.clear();
        insert proposal;
		System.assertEquals(1, querySyncRecords(proposal.id).size());
		delete querySyncRecords(proposal.id);

        //update proposal with non-eligible field and see that sync record not created
		proposal.Opportunity__c = opty1.id;
        proposal.Name = 'Some Value';
        AwsSyncServiceImpl.syncRecordsCreatedIds.clear();
        update proposal;
		System.assertEquals(0, querySyncRecords(proposal.id).size());

       
        //update proposal with eligible field and see that sync record not created
        proposal.Status__c = 'Some new updated value';
        AwsSyncServiceImpl.syncRecordsCreatedIds.clear();
        update proposal;
		System.assertEquals(1, querySyncRecords(proposal.id).size());
    }
    
	testmethod public static void testProposalsSync() {
        insertSettings();
        
		Account acct = new Account(Name='Foo', RecordTypeId=utils.getRecordTypeId('Account', 'Partner'), 
			BillingCity='Dublin',
			Office_Location__c  = 'Headquarters',
			Stage__c = 'Confirmed',
			Active__c  = true);
        insert acct;

        Opportunity opty1 = new Opportunity(Name='Test', StageName='Stage', CloseDate=Date.today());
        opty1.Lead_Gen_Partner__c = acct.id;
        opty1.Sales_Partner__c = acct.id;
        opty1.Partner_for_Lead_Passing__c = acct.id;
        insert opty1;

        Proposal__c proposal = new Proposal__c(Mode_Name__c='Mode', Opportunity__c=opty1.id,
			Sales_Rep_Email__c='test@yopmail.com', Date_Issued__c=Date.today(), System_Size_STC_DC__c=10.0, Upfront_Payment__c=00.0);
        insert proposal;
        
        //Create a sync record.
        List<Sync_Record__c> syncRecords = Sf.syncService.insertSyncRecords('AwsSqsSync', 'ProposalsSync', new Sobject[]{proposal});
		
        //===================================================================
		//With sync disabled, run the job and make sure status is updated as Not Applicable/Sqs Sync Not Enabled
		new AwsSqsProposalsSyncJob().execute();
        Sync_Record__c syncRecord = querySyncRecord(syncRecords.get(0).id);
        System.assertEquals('Sync Not Applicable', syncRecord.Status__c);
        System.assertEquals('Sqs Sync Not Enabled', syncRecord.Sub_Status__c);
        
        //===================================================================
        //Now enable the sync with queue not configured. Sync should fail with 
        //as we haven't configured the sqs.
        Sf.settingsService.setString('AwsSqsProposalsSyncEnabled', 'true');
		syncRecord.Status__c = 'To Be Synced';
        update syncRecord;
        
		new AwsSqsProposalsSyncJob().execute();
        syncRecord = querySyncRecord(syncRecords.get(0).id);
        System.assertEquals(null, syncRecord.Message__c);
        System.assertEquals('Sync Not Applicable', syncRecord.Status__c);
        System.assertEquals('SQS Queue Not Configured', syncRecord.Sub_Status__c);
		
        //===================================================================
        //Now configure the account with sqs queue and try to sync again. This time 
        //sync should go through.
		acct.Sqs_Queue_Name__c='Test';
        update acct;

        syncRecord.Status__c = 'To Be Synced';
        update syncRecord;

        new AwsSqsProposalsSyncJob().execute();
        syncRecord = querySyncRecord(syncRecords.get(0).id);
        System.assertEquals('Sync Success', syncRecord.Status__c);
        System.assertEquals(null, syncRecord.Sub_Status__c);
    }

    public static void insertSettings() {
        Sf.settingsService.setString('AwsAccessKey', 'accesskey'); 
        Sf.settingsService.setString('AwsSecretKey', 'secretkey'); 
        Sf.settingsService.setString('AwsSqsUrl', 'https://sqs.us-east-1.amazonaws.com/{QueueName}'); 
        Sf.settingsService.setString('AwsSqsLeadsSyncTriggerFields', 'Lead_Status__c,FirstName'); 
        Sf.settingsService.setString('AwsSqsOptysSyncTriggerFields', 'StageName,AccountId'); 
        Sf.settingsService.setString('AwsSqsAccountsSyncTriggerFields', 'Name'); 
        Sf.settingsService.setString('AwsSqsContactsSyncTriggerFields', 'FirstName'); 
        Sf.settingsService.setString('AwsSqsContractsSyncTriggerFields', 'Status__c '); 
        Sf.settingsService.setString('AwsSqsProposalsSyncTriggerFields', 'Status__c'); 
         
        //This is rquired as some opty trigger is looking for.
       	insert new Opportunity_Email_Status__c(Name='Site Audit Schedule', No_Of_Days_In_Past_Limit__c=5);
        insert new Opportunity_Email_Status__c(Name='Site Audit Complete', No_Of_Days_In_Past_Limit__c=5);

        //These are required to insert credit record
        insert new CustomerCreditAutomationInfo__c(Name='FICO_PASS', Field_Value__c='600');
        insert new CustomerCreditAutomationInfo__c(Name='FICO_FAIL', Field_Value__c='400');
        insert new CustomerCreditAutomationInfo__c(Name='FICO_CPASS', Field_Value__c='700');

        //When testing the aws sync, it always threw error cannot make
        //outbound call when uncommitted work is pending, even though
        //actual execution is guarded by Test start/stop which should
        //start a new tx. So end up bypassing the http call with mock
        //directly.
        BaseClass.testParams.put('HttpCalloutMock', mock);
   }
	
    //This is not a actual test but code used to manually test a usecase
    public void testSigningGet() {
        BaseAwsService.AwsConfig awsConfig = new BaseAwsService.AwsConfig('AKIDEXAMPLE', 'wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY');
        
        BaseAwsService.AwsRequest awsRequest = new BaseAwsService.AwsRequest();
        awsRequest.method = 'GET';
		awsRequest.url = 'https://host.foo.com/';
        awsRequest.queryParams.put('foo', 'bar');
		awsRequest.requestDateTime = DateTime.newInstanceGmt(2011, 09, 09, 23, 36, 00);
        BaseClass.testParams.put('HttpDateHeaderValue', 'Mon, 09 Sep 2011 23:36:00 GMT');
        
        awsService.signAwsRequest(awsConfig, awsRequest);
    }
    
    //This is not a actual test but code used to manually test a usecase
    public void testSigningProcess1() {
        BaseAwsService.AwsConfig awsConfig = new BaseAwsService.AwsConfig('AKIAICC3QWIQKK7W64WQ', 'uvcjbJWFIZLa0AlHTEIwQcUdHrISVtj76rh4jx/f');
        
        BaseAwsService.AwsRequest awsRequest = new BaseAwsService.AwsRequest();
		awsRequest.url = 'https://sqs.us-west-2.amazonaws.com/';
        awsRequest.queryParams.put('Action', 'GetQueueUrl');
        awsRequest.queryParams.put('QueueName', 'localdev-partner');
        awsRequest.queryParams.put('Version', '2012-11-05');
        
        //awsService.awsHttpGet(awsConfig, awsRequest);
    }

    //This is not a actual test but code used to manually test a usecase
    public void testSendMessage() {
        BaseAwsService.AwsConfig awsConfig = new BaseAwsService.AwsConfig('AKIAICC3QWIQKK7W64WQ', 'uvcjbJWFIZLa0AlHTEIwQcUdHrISVtj76rh4jx/f');
        
        BaseAwsService.AwsRequest awsRequest = new BaseAwsService.AwsRequest();
		awsRequest.url = 'https://sqs.us-west-2.amazonaws.com/563116987804/localdev-partner';
        awsRequest.bodyParams.put('Action', 'SendMessage');
        awsRequest.bodyParams.put('MessageBody', 'Test Message');
        awsRequest.bodyParams.put('Version', '2012-11-05');
        
        awsService.awsHttpPost(awsConfig, awsRequest);
    }
    
    public static Sync_Record__c querySyncRecord(Id syncRecordId) {
        return [select Id, Module__c, Action__c, Status__c, Sub_Status__c, Message__c from Sync_Record__c where Id = :syncRecordId limit 1];
    }

    public static List<Sync_Record__c> querySyncRecords(String sobjId) {
        return [select Id, Module__c, Action__c, Message__c from Sync_Record__c where Record_Id__c = :sobjId];
    }
    
    testmethod public static void testDeletingClasses() {
        new AwsOptysSqsSyncJob();
        new AwsLeadsSqsSyncJob ();
        new AwsSqsCustomerCreditsSyncJob();
    }
}