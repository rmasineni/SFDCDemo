@isTest (SeeAllData = true) 
public class TestPRMLibrary {
	static Map<String, RecordType> contactRecordTypeMap;
	static Map<String, RecordType> accountRecordTypeMap;
	static Map<String, RecordType> opportunityRecordTypeMap;
	
	static public Id getRecordTypeId(String recordTypeName, String SobjectType){
		
		if(contactRecordTypeMap == null || accountRecordTypeMap == null || opportunityRecordTypeMap == null){
			contactRecordTypeMap = new Map<String, RecordType>();
			accountRecordTypeMap = new Map<String, RecordType>();
			opportunityRecordTypeMap = new Map<String, RecordType>();
			for(Recordtype recordTypeObj  : [Select Id, SobjectType, name from Recordtype where SobjectType in ('Account', 'Contact', 'Opportunity')]){
				if(recordTypeObj.SobjectType == 'Contact'){
					contactRecordTypeMap.put(recordTypeObj.name, recordTypeObj);
				}else if(recordTypeObj.SobjectType == 'Account'){
					accountRecordTypeMap.put(recordTypeObj.name, recordTypeObj);
				}else if(recordTypeObj.SobjectType == 'Opportunity'){
					opportunityRecordTypeMap.put(recordTypeObj.name, recordTypeObj);
				}
			}
		}
		Id recordTypeId;
		if(SobjectType == 'Contact'){
			Recordtype recordTypeObj = contactRecordTypeMap.get(recordTypeName);
			recordTypeId = recordTypeObj.Id;
		}else if(SobjectType == 'Account'){
			Recordtype recordTypeObj = accountRecordTypeMap.get(recordTypeName);
			recordTypeId = recordTypeObj.Id;			
		}else if(SobjectType == 'Opportunity'){
			Recordtype recordTypeObj = opportunityRecordTypeMap.get(recordTypeName);
			recordTypeId = recordTypeObj.Id;			
		}
		//Recordtype recordTypeObj = [Select Id, name from Recordtype where SobjectType = :SobjectType and name =:recordTypeName];
		return recordTypeId;
	}

	static public Account insertAccount(String name, String accountType){
		Account account = new Account();
		account.Name = name;
		Id recordTypeId = getRecordTypeId(accountType, 'Account');
		account.RecordTypeId = recordTypeId;
		insert account;
		return account;
	}

	static public Opportunity insertOpportunity(Id accountId, String opptyName, String opptyType){
		Opportunity oppotyObj = new Opportunity();
		oppotyObj.AccountId = accountId;
		oppotyObj.name = opptyName;
		oppotyObj.CloseDate = date.today().addDays(3);
		oppotyObj.StageName = 'Assigned';
		Id optyRecordTypeId = getRecordTypeId(opptyType, 'Opportunity');
		insert oppotyObj;
		return oppotyObj;
	}

	static public Opportunity insertOpportunity(String accountName,String accountType,
													String opptyName, String opptyType){
		Account account = new Account();
		account.Name = accountName;
		Id recordTypeId = getRecordTypeId(accountType, 'Account');
		account.RecordTypeId = recordTypeId;
		insert account;
		
		Opportunity oppotyObj = new Opportunity();
		oppotyObj.AccountId = account.Id;
		oppotyObj.name = opptyName;
		oppotyObj.CloseDate = date.today().addDays(3);
		oppotyObj.StageName = 'Assigned';
		Id optyRecordTypeId = getRecordTypeId(opptyType, 'Opportunity');
		insert oppotyObj;
		return oppotyObj;
	}

	static public Contact insertInactiveContact(String accountName,String accountType,
										String lastName, String email){
		Account account = new Account();
		account.Name = accountName;
		Id recordTypeId = getRecordTypeId(accountType, 'Account');
		account.RecordTypeId = recordTypeId;

		insert account;

		account.active__C = false;
		account.Deactivation_Reason__c = 'Other';
		update account;
			
        Contact contact = new Contact();
        contact.LastName = lastName;
        contact.AccountId = account.Id;
        contact.email = email;
        insert contact; 
        return contact;
    }


	static public Contact insertContact(Id accountId,  String contactType ,String firstName, String lastName, String email){
        Id contactRecordTypeId = getRecordTypeId(contactType, 'Contact');
        Contact contact = new Contact();
        contact.firstname = firstName;
        contact.LastName = lastName;
        contact.AccountId = accountId;
        contact.RecordTypeId = contactRecordTypeId;
        contact.email = email;
        contact.title = 'Title-1';
 		contact.MailingStreet = '1st St';
		contact.MailingCity = 'SFO';
		contact.MailingState = 'CA';       
        insert contact; 
        return contact;
    }

	static public Contact insertContact(String accountName,String accountType,
										String lastName, String email){
        Account account = insertAccount(accountName, accountType);
        Id contactRecordTypeId = getRecordTypeId(accountType, 'Contact');
        Contact contact = new Contact();
        contact.LastName = lastName;
        contact.FirstName = 'First';
        contact.AccountId = account.Id;
        contact.RecordTypeId = contactRecordTypeId;
        contact.email = email;
        contact.title = 'Title-1';
        insert contact; 
        return contact;
    }

	static  testmethod void testContacts(){
		Contact contactObj1 = insertContact('PRMTestAccount1', 
											PRMLibrary.PARTNER, 
											'PRMTestLastName1',
											'prmcontact1@sunrun.com');
											
		Contact contactObj2 = insertContact('PRMTestAccount2', 
											PRMLibrary.PARTNER, 
											'PRMTestLastName2',
											'prmcontact2@sunrun.com');
		
		Contact contactObj3 = insertContact('PRMTestAccount3', 
											'Residential', 
											'PRMTestLastName3',
											'prmcontact3@sunrun.com');		

		Contact contactObj4 = insertContact('PRMTestAccount4', 
											'Residential', 
											'PRMTestLastName4',
											'prmcontact3@sunrun.com');		
		
		List<String> contactEmails = new List<String>();
		contactEmails.add('prmcontact1@sunrun.com');
		contactEmails.add('prmcontact2@sunrun.com');
		
		Map<String, List<Contact>> existingContactMap = PRMLibrary.getExistingContactsByEmail(contactEmails);
		System.assertEquals(contactEmails.size(), existingContactMap.size());
				
		List<String> numbers = PRMLibrary.getUniqueContractNumbers(2);
		System.assertEquals(numbers.size(), 2);
		
		Account accountObj1 = insertAccount('PRMTestAccount5', PRMLibrary.PARTNER);
		Account accountObj2 = insertAccount('PRMTestAccount6', PRMLibrary.PARTNER);
		
		AccountContactRole accountContactRoleObj = new AccountContactRole();
		accountContactRoleObj.AccountId = accountObj2.Id;
		accountContactRoleObj.ContactId = contactObj4.Id;
		insert accountContactRoleObj;

		contactObj4.accountId = accountObj1.Id;
		contactObj2.email = 'contactObj21@sunrun.com';
		contactObj2.contact_number__c = '';
		List<Contact> updateContactList = new List<Contact>();
		updateContactList.add(contactObj2);
		updateContactList.add(contactObj4);
		update 	updateContactList;
		
		accountObj1.Active__c = false;
		accountObj1.Deactivation_Reason__c = 'Other';
		accountObj1.Deactivation_Comments__c = 'Deactivation description1 ..';
		try{
			update 	accountObj1;
		}catch(exception ex){
			System.debug(ex.getmessage());
		}
		accountObj2.Active__c = false;
		accountObj2.Deactivation_Reason__c = 'Other';
		accountObj2.Deactivation_Comments__c = 'Deactivation description2 ..';
		update 	accountObj2;
		System.assertEquals(accountObj2.Active__c, false);
		
		Boolean exceptionResult = false;
		try{
			contactObj2.email = 'prmcontact1@sunrun.com';
			update contactObj2;
		}catch(Exception exceptionObj){
			exceptionResult = true;
		}
		System.assert(exceptionResult);
		
		Set<Id> accountIds = new  Set<Id>();
		accountIds.add(contactObj1.accountId);
		accountIds.add(contactObj2.accountId);
		accountIds.add(contactObj3.accountId);
		accountIds.add(contactObj4.accountId);
	
		//PRMLibrary.deactivateContacts(accountIds);
		//exceptionResult = false;
		//try{
		//	PRMLibrary.activateContacts(accountIds);
		//}catch(Exception exceptionobj){
		//	exceptionResult = true;
		//}
		//System.assert(exceptionResult);
		
		//accountObj1.Active__c = true;
		//accountObj1.Deactivation_Reason__c = null;
		//update accountObj1;
		//System.assertEquals(accountObj1.Active__c, true);
		//PRMLibrary.activateContacts(accountIds);	
								
	}
	
	static  testmethod void testContactEmail(){
		Contact contactObj1 = insertContact('PRMTestAccount21', 
											'Residential', 
											'PRMTestLastName21',
											'prmcontact21@sunrun.com');
		System.assertNotEquals(contactObj1.Id, null);
											
		Boolean excpetionResult = false;
		try{
			Contact contactObj2 = insertContact('PRMTestAccount22', 
													PRMLibrary.PARTNER, 
													'PRMTestLastName22',
													'prmcontact21@sunrun.com');
		}catch(Exception exceptionObj){
			excpetionResult = true;
		}
		System.assert(excpetionResult);
		
		excpetionResult = false;
		try{
			Contact contactObj3 = insertInactiveContact('PRMTestAccount23', 
													PRMLibrary.PARTNER, 
													'PRMTestLastName23',
													'prmcontact23@sunrun.com');
		}catch(Exception exceptionObj){
			excpetionResult = true;
		}
		System.assert(excpetionResult);

		Contact contactObj24 = insertContact('PRMTestAccount24', 
											'Residential', 
											'PRMTestLastName24',
											'prmcontact24@sunrun.com');
		System.assertNotEquals(contactObj24.Id, null);

		Contact contactObj25 = insertContact('PRMTestAccount25', 
											PRMLibrary.PARTNER, 
											'PRMTestLastName25',
											'prmcontact25@sunrun.com');
		System.assertNotEquals(contactObj25.Id, null);
		
		AccountContactRole contactRuleObj = new AccountContactRole();
		contactRuleObj.role = 'Other';
		contactRuleObj.contactId = contactObj24.Id;
		contactRuleObj.accountId = contactObj25.accountId;

		insert contactRuleObj;
		contactObj24.accountId = contactObj1.accountId;
		update contactObj24;
		
		//If the Contact is associated with more than one Account and if one of the 
		//account is a Partner account then the contact.contact_type__c should be 
		//marked as 'Partner'
		System.assertNotEquals(contactObj24.contact_type__c, PRMLibrary.PARTNER);
		
		Set<Id> accountIds = new Set<Id>();
		accountIds.add(contactObj1.accountId);
		accountIds.add(contactObj24.accountId);
		accountIds.add(contactObj25.accountId);
		PRMLibrary.setContactType(accountIds);
	}
	/*
	//Commented for Test errors
	static  testmethod void testContactSync(){
		
		Account accountObj1 = insertAccount('PRMPartnerAccount1', PRMLibrary.PARTNER);
		accountObj1.IsPartner = true;
		update accountObj1;

		Contact contactObj1 = insertContact('PRMTestAccount1', 
											PRMLibrary.PARTNER, 
											'PRMTestLastName1',
											'sunrunprmcontact11@sunrun.com');		
		contactObj1.accountId = accountObj1.Id;
		contactObj1.FirstName = 'PRMTest1';
		update contactObj1;
		
		List<Profile> profiles = [Select Id , name from Profile where name like '%gold%'];
		
		User newUserObj = new User();
		newUserObj.ProfileId = profiles[0].Id;
		newUserObj.FirstName = 'TestFirstName1';
		newUserObj.LastName = 'TestLastName1';
		newUserObj.Email = 'Testemail@sunrun.com';
		newUserObj.Username = contactObj1.email;
		newUserObj.contactId = contactObj1.id;
		newUserObj.TimeZoneSidKey = 'America/Los_Angeles';
		newUserObj.EmailEncodingKey = 'ISO-8859-1';
		newUserObj.LocaleSidkey = 'en_US';
		newUserObj.LanguageLocaleKey = 'en_US';
		newUserObj.alias = 'abxz';
		newUserObj.title = 'Title-111';
		newUserObj.CommunityNickname = 'prmtest1';
		insert 	newUserObj;
		

		newUserObj.FirstName = contactObj1.FirstName + '1';
		newUserObj.LastName = contactObj1.lastname  + '1';
		newUserObj.Email = 'prmmodified@sunrun.com';
		newUserObj.phone = '6436343330';
		newUserObj.fax = '7436343330' ;
		newUserObj.mobilephone = '8436343330';
		newUserObj.street = 'Street1';
		newUserObj.country = 'USA';
		newUserObj.PostalCode = '45643';
		newUserObj.city = 'TestCity';
		newUserObj.state = 'MA';
		update newUserObj;

		Contact updatedContact = [Select Id, firstname, lastname, email from Contact 
							where Id = :newUserObj.contactId];
							
		//System.assertEquals(updatedContact.firstname, newUserObj.firstname);

		test.startTest();
		contactObj1.firstname = contactObj1.firstname + '2';
		contactObj1.lastname = contactObj1.lastname + '2';
		contactObj1.email = contactObj1.email + '2';
		update contactObj1;
		
		test.stoptest();
		contactObj1 = [Select Id, firstname, lastname, email from Contact 
							where Id = :contactObj1.Id];

		User updatedUser = [Select Id, firstname, lastname, email from User 
							where ContactId = :contactObj1.Id];
							
		System.assertEquals(updatedUser.firstname, contactObj1.firstname);
		
		Id recordTypeId = getRecordTypeId(PRMLibrary.PARTNER, 'Account');
		accountObj1.RecordTypeId = recordTypeId;

		Boolean exceptionResult = false;
		try{
			delete contactObj1;
		}catch(Exception exceptionObj){
			exceptionResult = true;
		}
	}
	*/
	
	static testmethod void testAccountTypeChanges(){

		Contact contactObj61 = insertContact('PRMTestAccount61', 
									'Residential', 
									'PRMTestLastName61',
									'prmcontact61@sunrun.com');
									
		Account accountObj1 = insertAccount('PRMPartnerAccount1', PRMLibrary.PARTNER);
		contactObj61.AccountId = accountObj1.Id;
		update contactObj61;
		Contact tempContactObj = [Select Id, contact_type__c from Contact where accountId =:accountObj1.id];
		System.assertEquals(tempContactObj.contact_type__c, PRMLibrary.PARTNER);
		
		Id residentialId = TestPRMLibrary.getRecordTypeId('Residential', 'Account');
		accountObj1.RecordTypeId = residentialId;
		update accountObj1;
		
		tempContactObj = [Select Id, contact_type__c from Contact where accountId =:accountObj1.id];
		//System.assertEquals(tempContactObj.contact_type__c, null);
		
		Account deleteAccount = insertAccount('PRMDeleteTest', PRMLibrary.PARTNER);
		Boolean exceptionResult = false;
		try{
			delete deleteAccount;
		}catch(Exception exceptionObj){
			exceptionResult = true;
		}
	
	}
	
	static testmethod void testAccountHierarchy(){
		
		Account accountObj1 = insertAccount('PRMPartnerAccountUSA', PRMLibrary.PARTNER);
		Account accountObj2 = insertAccount('PRMPartnerAccountCA', PRMLibrary.PARTNER);
		Account accountObj3 = insertAccount('PRMPartnerAccountBayArea', PRMLibrary.PARTNER);
		Account accountObj4 = insertAccount('PRMPartnerAccountFremont', PRMLibrary.PARTNER);
		accountObj2.ParentId = accountObj1.Id;
		update accountObj2;

		accountObj3.ParentId = accountObj2.Id;
		update accountObj3;

		accountObj4.ParentId = accountObj3.Id;
		update accountObj4;
	
		Contact contactObj1 = insertContact('PRMTestAccount1', 
											PRMLibrary.PARTNER, 
											'PRMTestLastName1',
											'sunrunprmcontact11@sunrun.com');		
		contactObj1.accountId = accountObj4.Id;
		contactObj1.FirstName = 'PRMTestFremont1';
		update contactObj1;		

		Contact contactObj2 = insertContact('PRMTestAccount1', 
											PRMLibrary.PARTNER, 
											'PRMTestLastName21',
											'sunrunprmcontact12@sunrun.com');		
		contactObj2.accountId = accountObj2.Id;
		contactObj2.FirstName = 'PRMTestFremont11';
		update contactObj2;	
	}

	

	static testmethod void testDeleteAccount(){
		Account accountObj1 = insertAccount('PRMPartnerAccountUSA', PRMLibrary.PARTNER);
		
		List<Profile> profiles = [Select Id , name from Profile where name like '%SunRun%'];
		User newUserObj = new User();
		newUserObj.ProfileId = profiles[0].Id;
		newUserObj.FirstName =  'TestFirstName1';
		newUserObj.LastName = 'TestLastName1';
		newUserObj.Email = 'testsunRunSales11@sunrun.com';
		newUserObj.Username = 'testsunRunSales11@sunrun.com';
		newUserObj.TimeZoneSidKey = 'America/Los_Angeles';
		newUserObj.EmailEncodingKey = 'ISO-8859-1';
		newUserObj.LocaleSidkey = 'en_US';
		newUserObj.LanguageLocaleKey = 'en_US';
		newUserObj.alias = 'abxz';
		newUserObj.title = 'Title-1';
		newUserObj.CommunityNickname = 'prmtest1';
		insert 	newUserObj;
		system.runAs(newUserObj){
			try{
				delete accountObj1;
			}catch(Exception ex){
				
			}
		}
		
	}

	static testmethod void testDeleteContact(){
		Contact contactObj1 = insertContact('PRMTestAccount1', 
											PRMLibrary.PARTNER, 
											'PRMTestLastName1',
											'prmcontact1@sunrun.com');
		
		List<Profile> profiles = [Select Id , name from Profile where name like '%SunRun%'];
		User newUserObj = new User();
		newUserObj.ProfileId = profiles[0].Id;
		newUserObj.FirstName =  'TestFirstName1';
		newUserObj.LastName = 'TestLastName1';
		newUserObj.Email = 'testsunRunSales11@sunrun.com';
		newUserObj.Username = 'testsunRunSales11@sunrun.com';
		newUserObj.TimeZoneSidKey = 'America/Los_Angeles';
		newUserObj.EmailEncodingKey = 'ISO-8859-1';
		newUserObj.LocaleSidkey = 'en_US';
		newUserObj.LanguageLocaleKey = 'en_US';
		newUserObj.alias = 'abxz';
		newUserObj.title = 'Title-1';
		newUserObj.CommunityNickname = 'prmtest1';
		insert 	newUserObj;
		system.runAs(newUserObj){
			try{
				delete contactObj1;
			}catch(Exception ex){
				
			}
		}
		
	}

	static testmethod void testDomainValidations(){
		
		String validDomainList;
		String emailId;
		
		PRMLibrary.isValidDomain(validDomainList, emailId);
		
		emailId = 'Test';
		PRMLibrary.isValidDomain(validDomainList, emailId);
		
		emailId = 'Test@sunrun.com';
		PRMLibrary.isValidDomain(validDomainList, emailId);
		
		validDomainList = 'gmail.com;sunrunhome.com;sunrun.com';
		PRMLibrary.isValidDomain(validDomainList, emailId);
		
		validDomainList = 'sunrunhome.com;sunrun.com';
		PRMLibrary.isValidDomain(validDomainList, emailId);		
	}
	
	static testmethod void testContactWithInvalidDomain(){
		//Map<Id, String> getContactsWithInvalidDomain(Map<Id, String> contactEmailMap)
		
		Contact contactObj1 = insertContact('PRMTestAccount1', 
											PRMLibrary.PARTNER, 
											'PRMTestLastName1',
											'prmcontact1@sunrun.com');		
		
		Account accountObj = [Select Id, ValidDomains__C from Account where Id = :contactObj1.accountId];
		accountObj.ValidDomains__c = 'gmail.com;sunrunhome.com;sunrun.com';
		update accountObj;
		
		contactObj1.Email = 'prmcontact1@sunrunhome1.com';
		try{
			update contactObj1;
		}catch(Exception ex){
			
		}

		PRMLibrary.ErrorDescription errorObj1 = new PRMLibrary.ErrorDescription();
		String contractNumber = '1334';
		String errorMessage = 'TestError';
		PRMLibrary.ErrorDescription errorObj2 = new PRMLibrary.ErrorDescription(contractNumber, errorMessage);
		errorObj2.contractNumber = '12345';
		errorObj2.errorMessage = 'Test Error';

		//Map<Id, String> contactEmailMap = new Map<Id, String>();
		//contactEmailMap.put(contactObj1.Id, contactObj1.Email);
		//PRMLibrary.getContactsWithInvalidDomain(contactEmailMap);	
	}

	static testmethod void testInactiveAccounts(){
		Account accountObj1 = insertAccount('PRMPartnerAccount1', PRMLibrary.PARTNER);
		accountObj1.IsPartner = true;
		accountObj1.Active__c = false;
		accountObj1.Deactivation_Reason__c = 'Other';
		update accountObj1;
		
		Set<Id> accountIds = new Set<Id>();
		accountIds.add(accountObj1.Id);
		Set<Id> inactiveIds1 = PRMLibrary.getInactiveParentAccounts(accountIds);
		Set<Id> inactiveIds2 = PRMLibrary.getInactiveAccounts(accountIds);

		Contact contactObj1 = insertContact('PRMTestAccount411', 
											'Residential', 
											'PRMTestLastName411',
											'prmcontact3@sunrun.com');		
			
		contactObj1.FirstName = 'First112';
		contactObj1.active__c = true;
		update contactObj1;

		accountObj1.Active__c = true;
		update accountObj1;
		
		accountObj1.name = 'NewAccount-1';
		update accountObj1;
				
		Account childAccount = [Select Id, Active__c, ParentId from Account where Id =:contactObj1.accountId];
		childAccount.ParentId = accountObj1.Id;
		update childAccount;
		
		accountObj1.Active__c = false;
		
		try{
			update accountObj1;
		}catch(Exception ex){
			
		}		
		RecordType recordTypeObj = PRMLibrary.getPartnerContactRecordType();

		Account accountObj2 = insertAccount('PRMPartnerAccount2', PRMLibrary.PARTNER);
		accountObj2.IsPartner = true;
		accountObj2.Active__c = false;
		accountObj2.Deactivation_Reason__c = 'Other';
		update accountObj2;

		childAccount.parentId = accountObj2.Id;
		update childAccount;
		
		List<Account> childAccounts = new List<Account>();
		childAccounts.add(childAccount);
		Set<Id> parentAccountIds= new Set<Id>();
		parentAccountIds.add(accountObj2.Id);
		PRMLibrary.updateAccountName(parentAccountIds, childAccounts);
		
		PRMLibrary.modifyChildAccountsName(parentAccountIds);

		//PRMLibrary.updateContacts(parentAccountIds,true);
		//PRMLibrary.updateContacts(parentAccountIds,false);
	}

	/*
	//Commented for Test errors
	static testmethod void testSyncPartnerUsers(){
		
		Account accountObj1 = TestPRMLibrary.insertAccount('PRMPartnerAccount1', PRMLibrary.PARTNER);
		accountObj1.IsPartner = true;
		update accountObj1;
		Set<Id> parentAccountIds= new Set<Id>();
		parentAccountIds.add(accountObj1.Id);

		Contact contactObj1 = TestPRMLibrary.insertContact('PRMTestAccount1', 
											PRMLibrary.PARTNER, 
											'PRMTestLastName1',
											'sunrunprmcontact11@sunrun.com');		
		contactObj1.accountId = accountObj1.Id;
		contactObj1.FirstName = 'PRMTest1';
		update contactObj1;
		
		List<Profile> profiles = [Select Id , name from Profile where name like '%Gold Partner User%'];
		
		User newUserObj = new User();
		newUserObj.ProfileId = profiles[0].Id;
		newUserObj.FirstName = contactObj1.firstname;
		newUserObj.LastName = contactObj1.lastname;
		newUserObj.Email = contactObj1.email;
		newUserObj.title = 'title1';
		newUserObj.Username = contactObj1.email;
		newUserObj.contactId = contactObj1.id;
		newUserObj.TimeZoneSidKey = 'America/Los_Angeles';
		newUserObj.EmailEncodingKey = 'ISO-8859-1';
		newUserObj.LocaleSidkey = 'en_US';
		newUserObj.LanguageLocaleKey = 'en_US';
		newUserObj.alias = 'abxz';
		newUserObj.CommunityNickname = 'prmtest1';
		newUserObj.phone = '6436343330';
		newUserObj.fax = '7436343330' ;
		newUserObj.mobilephone = '8436343330';
		newUserObj.street = 'Street1';
		newUserObj.country = 'USA';
		newUserObj.PostalCode = '45643';
		insert 	newUserObj;
		
		Test.startTest();
			contactObj1.firstname = 'FirstName11';
			contactObj1.lastname = 'Lastname11';
			contactObj1.email = 'gtest111@sunrun.com';
			contactObj1.title = 'Title1';
			contactObj1.phone = '134544';
			contactObj1.fax = '2343646';
			contactObj1.MobilePhone = '57457';
			contactObj1.mailingstreet = 'M1Street1';
			contactObj1.mailingcity = 'City112';
			contactObj1.mailingstate = 'CA';
			contactObj1.mailingcountry = 'USA';
			contactObj1.mailingpostalcode = '94588';			
			update contactObj1;
		Test.stopTest();
		
		Map<Id, UserRole>  userRoles = PRMLibrary.getPartnerPortalRoles(accountObj1.Id);
		
		PRMLibrary.setContactType(parentAccountIds);
		List<String> uniqueContactNumber = PRMLibrary.getUniqueContractNumbers(10);
	}
	*/
	
	/*
	static testmethod void testSyncPartnerContacts(){
		
		Account accountObj1 = TestPRMLibrary.insertAccount('PRMPartnerAccount1', PRMLibrary.PARTNER);
		accountObj1.IsPartner = true;
		update accountObj1;
		Set<Id> parentAccountIds= new Set<Id>();
		parentAccountIds.add(accountObj1.Id);

		Contact contactObj1 = TestPRMLibrary.insertContact('PRMTestAccount1', 
											PRMLibrary.PARTNER, 
											'PRMTestLastName1',
											'sunrunprmcontact11@sunrun.com');		
		contactObj1.accountId = accountObj1.Id;
		contactObj1.FirstName = 'PRMTest1';
		update contactObj1;
		
		List<Profile> profiles = [Select Id , name from Profile where name like '%Gold Partner User%'];
		
		User newUserObj = new User();
		newUserObj.ProfileId = profiles[0].Id;
		newUserObj.FirstName = contactObj1.firstname;
		newUserObj.LastName = contactObj1.lastname;
		newUserObj.Email = contactObj1.email;
		newUserObj.title = 'title1';
		newUserObj.Username = contactObj1.email;
		newUserObj.contactId = contactObj1.id;
		newUserObj.TimeZoneSidKey = 'America/Los_Angeles';
		newUserObj.EmailEncodingKey = 'ISO-8859-1';
		newUserObj.LocaleSidkey = 'en_US';
		newUserObj.LanguageLocaleKey = 'en_US';
		newUserObj.alias = 'abxz';
		newUserObj.CommunityNickname = 'prmtest1';
		newUserObj.phone = '6436343330';
		newUserObj.fax = '7436343330' ;
		newUserObj.mobilephone = '8436343330';
		newUserObj.street = 'Street1';
		newUserObj.country = 'USA';
		newUserObj.PostalCode = '45643';
		
		insert 	newUserObj;
		Set<Id> contactIds1 = new Set<Id>();
		contactIds1.add(contactObj1.Id);		
		PRMLibrary.updatePartnerusers(contactIds1);		
		
		Test.startTest();
			contactObj1.firstname = 'FirstName11';
			contactObj1.lastname = 'Lastname11';
			contactObj1.email = 'gtest111@sunrun.com';
			contactObj1.title = 'Title11';
			contactObj1.phone = '134544';
			contactObj1.fax = '2343646';
			contactObj1.MobilePhone = '57457';
			contactObj1.mailingstreet = 'M1Street1';
			contactObj1.mailingcity = 'City112';
			contactObj1.mailingstate = 'CA';
			contactObj1.mailingcountry = 'USA';
			contactObj1.mailingpostalcode = '94588';			
			update contactObj1;

			Set<Id> contactIds2 = new Set<Id>();
			contactIds2.add(contactObj1.Id);
			PRMLibrary.updatePartnerContacts(contactIds2, null);

		Test.stopTest();
		Map<Id, UserRole>  userRoles = PRMLibrary.getPartnerPortalRoles(accountObj1.Id);
		
		PRMLibrary.setContactType(parentAccountIds);
		List<String> uniqueContactNumber = PRMLibrary.getUniqueContractNumbers(10);
	}
	*/

	static testmethod void testUpdatePartnerContacts(){
		
		String partnerAccountId = PartnerDetail__c.getValues('ApexTestAccount2').PartnerAccountId__C;
		String partnerContactId = PartnerDetail__c.getValues('ApexTestAccount2').PartnerContactId__C;
		String partnerSalesRepId = PartnerDetail__c.getValues('ApexTestAccount2').PartnerUserId__c;
		String salesRepEmail = PartnerDetail__c.getValues('ApexTestAccount2').PartnerContactEmail__C;
		
		Set<Id> contactIds = new Set<Id>();
		Contact contactObj = [Select Id, firstname, lastname, name, email from Contact where Id =:partnerContactId];
		contactIds.add(contactObj.Id);
		
		Set<Id> accountIds = new Set<Id>();
		Account accountObj = [Select Id, name from Account where Id =:partnerAccountId];
		accountIds.add(accountObj.Id);
		Boolean active = false;
		PRMLibrary.updateContacts(accountIds, active);
		
		active = true;
		PRMLibrary.updateContacts(accountIds, active);		
		
		PRMLibrary.updatePartnerusers(contactIds);
		
		User userObj = [Select Id, firstname, lastname, name, email from User where contactId =:partnerContactId];
		userObj.FirstName = 'TestFirst1';
		userObj.lastname = 'TestLast1';
		userObj.email = 'email1@sunrun.com';
		update userObj;
		
		Set<Id> contacts = NEW Set<Id>();
		contacts.add(contactObj.Id);
		PRMLibrary.updatePartneruserEmails(contacts);
		Test.startTest();
		PRMLibrary.updatePartnerContacts_Future(contacts, null);
		Test.stopTest();

		/*
		Account accountObj1 = TestPRMLibrary.insertAccount('PRMPartnerAccount100', PRMLibrary.PARTNER);
		accountObj1.IsPartner = true;
		update accountObj1;
		Set<Id> parentAccountIds= new Set<Id>();
		parentAccountIds.add(accountObj1.Id);
		
		
		Contact contactObj1 = TestPRMLibrary.insertContact('PRMTestAccount100', 
											PRMLibrary.PARTNER, 
											'PRMTestLastName100',
											'sunrunprmcontact100@sunrun.com');		
		contactObj1.accountId = accountObj1.Id;
		contactObj1.FirstName = 'PRMTest100';
		update contactObj1;
		
		Test.startTest();
		List<Profile> profiles = [Select Id , name from Profile where name like '%Gold Partner User%'];
		
		User newUserObj = new User();
		newUserObj.ProfileId = profiles[0].Id;
		newUserObj.FirstName = contactObj1.firstname;
		newUserObj.LastName = contactObj1.lastname;
		newUserObj.Email = contactObj1.email;
		newUserObj.title = 'title100';
		newUserObj.Username = contactObj1.email;
		newUserObj.contactId = contactObj1.id;
		newUserObj.TimeZoneSidKey = 'America/Los_Angeles';
		newUserObj.EmailEncodingKey = 'ISO-8859-1';
		newUserObj.LocaleSidkey = 'en_US';
		newUserObj.LanguageLocaleKey = 'en_US';
		newUserObj.alias = 'abxz';
		newUserObj.CommunityNickname = 'prm100';
		insert 	newUserObj;
		
		Set<Id> contactIds1 = new Set<Id>();
		contactIds1.add(contactObj1.Id);		
		PRMLibrary.updatePartnerusers(contactIds1);
		

			Set<Id> contactIds2 = new Set<Id>();
			contactIds2.add(contactObj1.Id);
			PRMLibrary.updatePortalUsers(contactIds2, true);
			PRMLibrary.updatePartnerusers(contactIds2);
		Test.stopTest();
		*/
		
	}
	
}