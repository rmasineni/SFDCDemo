@IsTest
public class AccountApiTest {
    private static BaseClass utils = new BaseClass();
    
    testmethod public static void testGetAccount() {
        insertSettings();
        
        BaseApiTest.setRequest('/services/apexrest/v2/accounts');
		
        //Trying to get accounts while there are none, should return empty list
        AccountApiAccountsEndpoint.httpGet();
        JsonReader reader = BaseApiTest.assertSuccessResponse();
		System.assertEquals('[]', reader.toJson());
		
		//Create an account and query the data.        
        Account act = new Account(Name='Foo Bar', BillingStreet='1 Market St', BillingCity='San Francisco');
        insert act;

        AccountApiAccountsEndpoint.httpGet();
        reader = BaseApiTest.assertSuccessResponse();

        System.assertEquals('Foo Bar', reader.getString('[0].name'));
        System.assertEquals('1 Market St', reader.getString('[0].street'));
		
        //Create an account with channel type, verticle type and record type
        Account acct2 = new Account(Name='Foo', Vertical_Type__c='Bob', Channel_Type__c='Alice');
        insert acct2;
        
        BaseApiTest.setRequest('/services/apexrest/v2/accounts');
        BaseApiTest.setParam('channelType', 'Alice');
        BaseApiTest.setParam('verticalType', 'Bob');
        
        //It should query one account.
        AccountApiAccountsEndpoint.httpGet();
        reader = BaseApiTest.assertSuccessResponse();
        System.assertEquals(1, reader.getList('').size());
        
        //Specifying some wrong record type, should return no accounts
        BaseApiTest.setParam('recordType', 'somewrongvalue');
        
        AccountApiAccountsEndpoint.httpGet();
        reader = BaseApiTest.assertSuccessResponse();
        System.assertEquals(0, reader.getList('').size());
    }

    static void insertSettings() {
        RestServiceDto.insertFieldMapping('Account Api', 'Account', 'name=Name,street=BillingStreet,city=BillingCity');
    }
}