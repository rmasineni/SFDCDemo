@istest
private class TestPartnerContract {
	
	static  testmethod void testNewPartnerContract(){
		Account testAccount = TestPRMLibrary.insertAccount('TestPartnerContrac1', PRMLibrary.PARTNER);
		Partner_Contract__c contractObj = new  Partner_Contract__c();
		contractObj.Account__c = testAccount.Id;
		Date dateobj = DateTime.now().date();
		contractObj.Sign_Date__c = dateobj;
		contractObj.Effective_Date__c = dateobj;
		insert contractObj;
		System.assertNotEquals(contractObj.Id, null);	
		
		// Delete custom setting data
	    Id userProfileId = UserInfo.getProfileId();
        Profile profileObj = [Select Id, name from Profile where id = :userProfileId];
        List<SunRunValidateProfiles__c> listSRVP = new List<SunRunValidateProfiles__c>();        
		for(SunRunValidateProfiles__c SRVP:[select id, name from SunRunValidateProfiles__c where Name = :profileObj.Name LIMIT 1])
		{
			listSRVP.add(SRVP);
		}
		delete listSRVP;
				
		Boolean exceptionResult = false;
		try{
			delete contractObj;
		}catch(Exception exceptionObj){
			exceptionResult = true;
		}

		Account deleteAccount = TestPRMLibrary.insertAccount('PRMDeleteTest', PRMLibrary.PARTNER);
		exceptionResult = false;
		try{
			delete deleteAccount;
		}catch(Exception exceptionObj){
			exceptionResult = true;
		}

	}
	
}