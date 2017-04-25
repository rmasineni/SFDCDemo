@IsTest
public class ZipUtilityTest {
	static BaseClass utils = new BaseClass();
    
	testmethod public static void testGetUsers() {
		insertSettings();
 		List<ZipUtility__c> zipUtilityList = new List<ZipUtility__c>();
		ZipUtility__c z1 = new ZipUtility__c(Zip_Code__c='94582', Utility_Company__c='UNITIL', Install_Branch__c='South bay' , state__c='CA', Territory__c='X1', City__c='San Ramon', 	Active_Market__c= true);
		ZipUtility__c z2 = new ZipUtility__c(Zip_Code__c='94582', Utility_Company__c='PG&E', Install_Branch__c='South bay',state__c='CA', Territory__c='X1', City__c='San Ramon', 	Active_Market__c= true);
		zipUtilityList.add(z1);
		zipUtilityList.add(z2);
		insert zipUtilityList;
		
		List<Zip_Utility_Rate_Schedule__c> zipUtilityRateList = new List<Zip_Utility_Rate_Schedule__c>();
		Zip_Utility_Rate_Schedule__c zr1 = new Zip_Utility_Rate_Schedule__c(Effective_Date__c=Date.today(),	Expiration_Date__c=Date.today().adddays(2), Rate_Schedule__c='R1', ZipUtility__c=zipUtilityList[0].Id );
		Zip_Utility_Rate_Schedule__c zr2 = new Zip_Utility_Rate_Schedule__c(Effective_Date__c=Date.today(),	Expiration_Date__c=Date.today().adddays(2), Rate_Schedule__c='S1', ZipUtility__c=zipUtilityList[1].Id );
		zipUtilityRateList.add(zr1);
		zipUtilityRateList.add(zr2);
		insert zipUtilityRateList;
		
		String zipCode = '94582;85003;95322;96055;';
        BaseApiTest.setRequest('/v2/utilities');
        BaseApiTest.setParam('zipCode', zipCode);
        BaseApiTest.setParam('state', 'CA');
        
        ZipUtilityEndpoint.httpGet();
        JsonReader reader = BaseApiTest.assertSuccessResponse();
		
	}

    static void insertSettings() {
		RestServiceDto.insertFieldMapping('ZipUtility Api', 'ZipUtility__c', 'zipCode=Zip_Code__c,state=State__c,utilityCompany=Utility_Company__c, installBranch=Install_Branch__c');
		RestServiceDto.insertFieldMapping('ZipUtility Api', 'Zip_Utility_Rate_Schedule__c', 'name=Rate_Schedule__c');
    }
	
}