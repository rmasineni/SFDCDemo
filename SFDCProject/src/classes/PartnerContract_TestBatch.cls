/*********************************************************************************************************************
Name : PartnerContract_TestBatch.cls
Author : Raghavendra Masineni
Date : 
Description : 
********************************************************************************************************************/

@isTest 
private class PartnerContract_TestBatch {

	static testMethod void testPartnerContractBatch(){
    	Account accountObj1 = TestPRMLibrary.insertAccount('PRMTestContract1', PRMLibrary.PARTNER);
		String accountFilter = 'account__c = \'' + accountObj1.Id + '\'';
    	PartnerContract_Batch  contractBatch = new PartnerContract_Batch(accountFilter, true);
    	Partner_Contract__c contractObj = new Partner_Contract__c();
    	contractObj.Effective_Date__c = date.today();
    	contractObj.Sign_Date__c = date.today();
    	contractObj.Terms_of_Renewal__c = 'Automatic';
    	contractObj.Auto_Renewal_Term_months__c = 10;
    	contractObj.Contract_Status__c = 'Active';
    	contractObj.Expiration_Date__c = date.today().addMonths(1);
    	contractObj.Account__c = accountObj1.id;
    	insert contractObj;
		
		Test.startTest();
		ID batchprocessid = Database.executeBatch(contractBatch); 
		System.debug('batchprocessid: ' + batchprocessid);
		Test.stopTest();
		
		List<Partner_Contract__c> updateContracts = [Select Id, Expiration_Date__c from Partner_Contract__c 
												where account__c = :accountObj1.id 
												AND contract_status__c = 'Active' ];
		
		//System.debug('updateContract.Expiration_Date__c: ' + updateContracts[0].Expiration_Date__c);
		//system.assertEquals(date.today().addMonths(11), updateContracts[0].Expiration_Date__c);

	}

	static testmethod void testPartnerContractSchedule(){// for code coverage only
    	Account accountObj1 = TestPRMLibrary.insertAccount('PRMTestContract2', PRMLibrary.PARTNER);
    	Partner_Contract__c contractObj = new Partner_Contract__c();
    	contractObj.Effective_Date__c = date.today();
    	contractObj.Sign_Date__c = date.today();
    	contractObj.Terms_of_Renewal__c = 'Automatic';
    	contractObj.Auto_Renewal_Term_months__c = 5;
    	contractObj.Contract_Status__c = 'Active';
    	contractObj.Expiration_Date__c = date.today().addMonths(1);
    	contractObj.Account__c = accountObj1.id;
    	insert contractObj;

	   	String accountFilter = 'account__c = \'' + accountObj1.Id + '\'';
		PartnerContract_Schedulable  schedule = new PartnerContract_Schedulable(accountFilter);
		schedule.execute(null);	
	}


   private static testmethod void testAutoRenewalContracts(){
    	System.debug('Start: testAutoRenewalContracts');
    	Test.startTest();
    	Account accountObj1 = TestPRMLibrary.insertAccount('PRMTestContract3', PRMLibrary.PARTNER);

    	Partner_Contract__c contractObj = new Partner_Contract__c();
    	contractObj.Effective_Date__c = date.today();
    	contractObj.Sign_Date__c = date.today();
    	contractObj.Terms_of_Renewal__c = 'Automatic';
    	contractObj.Auto_Renewal_Term_months__c = 5;
    	contractObj.Contract_Status__c = 'Active';
    	contractObj.Expiration_Date__c = date.today().addMonths(30);
    	contractObj.Account__c = accountObj1.id;
    	insert contractObj;
    	
     	PartnerContractsManager partnerContractManagerObj = new PartnerContractsManager();
    	partnerContractManagerObj.testing = true;
    	String accountFilter = 'account__c = \'' + accountObj1.Id + '\'';
    	String soqlQuery = partnerContractManagerObj.getContractSOQLQuery(accountFilter);
    	List<Partner_Contract__c> autorenewalContracts = (List<Partner_Contract__c>)Database.query(soqlQuery);
    	partnerContractManagerObj.processContracts(autorenewalContracts);
    	partnerContractManagerObj.testing = false;

		List<Partner_Contract__c> updateContracts = [Select Id, Expiration_Date__c from Partner_Contract__c 
												where account__c = :accountObj1.id 
												AND contract_status__c = 'Active'];
		
		System.debug('updateContract.Expiration_Date__c: ' + updateContracts[0].Expiration_Date__c);
		//system.assertEquals(date.today().addMonths(6), updateContracts[0].Expiration_Date__c);
		partnerContractManagerObj.addContractUpdatError('12345464', 'Error Message-1');
		partnerContractManagerObj.addContractUpdatError('12345122', 'Error Message-2');
		partnerContractManagerObj.autorenewalErrors.add('Test Renewal error1');
		partnerContractManagerObj.autorenewalErrors.add('Test Renewal error2');
		String email1 = 'rmasineni@sunrunhome.com';	
		List<String>	userList = new List<String>();
		userList.add(email1);
		partnerContractManagerObj.sendSuccessEmail(userList, 'Test Batch Job', null);
	   	EmailService.getHTMLErrorBody('BatchJob1', 'Error Message-1');
    	Test.stopTest();
   		System.debug('End: testAutoRenewalContracts');
    }


}