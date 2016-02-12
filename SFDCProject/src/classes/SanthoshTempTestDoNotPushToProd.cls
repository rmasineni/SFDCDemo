@IsTest
public class SanthoshTempTestDoNotPushToProd {
    private static BaseClass utils = new BaseClass();
	private static BaseAwsService awsService = new BaseAwsService();
    private static FlexibleCalloutMock mock = new FlexibleCalloutMock(200, '');

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
        AwsSyncServiceImpl.recordsProcessedInThisTxn.clear();
        insert contract;
		System.assertEquals(0, querySyncRecords(contract.id).size());
		
		//Enable sync and then insert contract associated with account which doens't have queue
		//and ensure that sync should not happen.
		Sf.settingsService.setBoolean('AwsSqsContractsSyncEnabled', true);
        contract = new ServiceContract(Opportunity__c=opty2.id);
        AwsSyncServiceImpl.recordsProcessedInThisTxn.clear();
        insert contract;
		System.assertEquals(0, querySyncRecords(contract.id).size());
	
		//insert a contract and see that sync record created
		Sf.settingsService.setBoolean('AwsSqsContractsSyncEnabled', true);
        contract = new ServiceContract(Opportunity__c=opty1.id);
        AwsSyncServiceImpl.recordsProcessedInThisTxn.clear();
        insert contract;
		System.assertEquals(1, querySyncRecords(contract.id).size());
		delete querySyncRecords(contract.id);

        //update a contract with non-eligible field and see that sync record not created
		contract.Opportunity__c = opty1.id;
        contract.Agreement_Type__c  = 'Some Value';
        AwsSyncServiceImpl.recordsProcessedInThisTxn.clear();
        update contract;
		System.assertEquals(0, querySyncRecords(contract.id).size());

        //update a contract with eligible field and see that sync record not created
        contract.Status__c = 'Some new updated value';
        AwsSyncServiceImpl.recordsProcessedInThisTxn.clear();
        update contract;
		System.assertEquals(1, querySyncRecords(contract.id).size());
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
	
    public static Sync_Record__c querySyncRecord(Id syncRecordId) {
        return [select Id, Module__c, Action__c, Status__c, Sub_Status__c, Message__c from Sync_Record__c where Id = :syncRecordId limit 1];
    }

    public static List<Sync_Record__c> querySyncRecords(String sobjId) {
        return [select Id, Module__c, Action__c, Message__c from Sync_Record__c where Record_Id__c = :sobjId];
    }
}