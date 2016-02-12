@IsTest
public class ContractApiTest {
	static BaseClass utils = new BaseClass();
    
    testmethod public static void testGetContract() {
		init();
        
        ServiceContract contract = new ServiceContract(Billing_Notification_Preference__c='Email');
        insert contract;
        contract = (ServiceContract) utils.queryAllFields('ServiceContract', contract.id);

        BaseApiTest.setRequest('/v2/contracts/' + contract.Agreement_Number__c);
        
        ContractApiContractEndpoint.httpGet();
        
        JsonReader reader = BaseApiTest.assertSuccessResponse();
        System.assertEquals('Email', reader.getString('billingNotificationPreference'));
        System.assertEquals(contract.Agreement_Number__c, reader.getString('contractNumber'));
        System.assertEquals(contract.Id, reader.getString('contractId'));
    }
    
    testmethod public static void testGetContractByProposalId() {
        init();
        
		Account acctWithQueue = new Account(Name='Foo', RecordTypeId=utils.getRecordTypeId('Account', 'Partner'), 
			Sqs_Queue_Name__c='Test', BillingCity='Dublin',
			Office_Location__c  = 'Headquarters',
			Stage__c = 'Confirmed',
			Active__c  = true);
        insert acctWithQueue;
        
        Opportunity opty1 = new Opportunity(Name='Test', StageName='Stage', CloseDate=Date.today());
        opty1.Lead_Gen_Partner__c = acctWithQueue.id;
        opty1.Sales_Partner__c = acctWithQueue.id;
        opty1.Partner_for_Lead_Passing__c = acctWithQueue.id;
        insert opty1;

        ServiceContract contract = new ServiceContract(Billing_Notification_Preference__c='Email', Opportunity__c=opty1.id);
        insert contract;
        contract = (ServiceContract) utils.queryAllFields('ServiceContract', contract.id);
		        
        BaseApiTest.setRequest('/v2/contracts/' + contract.Prospect_Id__c);
        
        ContractApiContractEndpoint.httpGet();
        
        JsonReader reader = BaseApiTest.assertSuccessResponse();
        System.assertEquals(contract.Agreement_Number__c, reader.getString('contractNumber'));
        System.assertEquals(contract.Prospect_Id__c, reader.getString('prospectId'));
    }

    testmethod public static void testNoRecordFoundError() {
        BaseApiTest.setRequest('/v2/contracts/1234567890');
        ContractApiContractEndpoint.httpGet();
        BaseApiTest.assertErrorResponse(404);
    }
    
    testmethod public static void testUpdateContract() {
		init();
        
        ServiceContract contract = new ServiceContract(Billing_Notification_Preference__c='Email');
        insert contract;
        contract = (ServiceContract) utils.queryAllFields('ServiceContract', contract.id);

        BaseApiTest.setRequest('/v2/contracts/' + contract.Agreement_Number__c, '{"billingNotificationPreference":"Phone"}');
        
        ContractApiContractEndpoint.httpPatch();
        
        JsonReader reader = BaseApiTest.assertSuccessResponse();
        
        System.assertEquals('Phone', reader.getString('billingNotificationPreference'));
    }

    static void init() {
        RestServiceDto.insertFieldMapping('Contract Api', 'ServiceContract', 'contractId=Id,contractNumber=Agreement_Number__c,billingNotificationPreference=Billing_Notification_Preference__c,prospectId=Prospect_Id__c');
    }
}