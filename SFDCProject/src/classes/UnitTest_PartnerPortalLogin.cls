@isTest (SeeAllData = true) 
public class UnitTest_PartnerPortalLogin {
	private static testMethod void TestLogin(){
		
		PartnerPortalLogin testLoginController = new PartnerPortalLogin(true);
		
		PartnerPortalLogin loginController = new PartnerPortalLogin();
		loginController.username = 'testuser1@sunrun.com';
		loginController.password = 'passeord1';
		Pagereference p1 = loginController.login();

		//Test Error Messages
		loginController.initializeMessages();
		System.currentPagereference().getParameters().put('messagetype', 'EmailError');
		loginController.initializeMessages();
		System.currentPagereference().getParameters().put('messagetype', 'PasswordError');
		loginController.initializeMessages();
		System.currentPagereference().getParameters().put('messagetype', 'EmailSuccess');
		loginController.initializeMessages();
		System.currentPagereference().getParameters().put('messagetype', 'PasswordSuccess');
		loginController.initializeMessages();
		
	}

	//Commented for Test errors
	private static testMethod void TestLogin2(){
		/*
		Account accountObj1 = TestPRMLibrary.insertAccount('PRMPartnerAccount1', PRMLibrary.PARTNER);
		accountObj1.IsPartner = true;
		update accountObj1;

		Contact contactObj1 = TestPRMLibrary.insertContact('PRMTestAccount1', 
											PRMLibrary.PARTNER, 
											'PRMTestLastName1',
											'sunrunprmcontact11@gmail.com');		
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
		insert 	newUserObj;
		*/

		String partnerAccountId = PartnerDetail__c.getValues('ApexTestAccount').PartnerAccountId__C;
		String partnerContactId = PartnerDetail__c.getValues('ApexTestAccount').PartnerContactId__C;
		String partnerSalesRepId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
		String salesRepEmail = PartnerDetail__c.getValues('ApexTestAccount').PartnerContactEmail__C;
		User newUserObj = [Select Id, username, firstname, lastname, name, email from User where contactId =:partnerContactId];
				
		newUserObj.FirstName = newUserObj.FirstName + '1';
		newUserObj.LastName = newUserObj.LastName  + '1';
		newUserObj.Email = 'prmmodified@gmail.com';
		update newUserObj;

		PartnerPortalLogin loginController = new PartnerPortalLogin();
		loginController.username = newUserObj.Email ;
		loginController.password = 'passeord1';
		Pagereference p1 = loginController.login();
		loginController.resetPassword();
		
		loginController.username = newUserObj.Email ;
		loginController.securityAnswerInput = 'Test';
		loginController.userSercurityAnswer = 'Test';
		loginController.resetPassword();

		loginController.userSercurityAnswer = 'Test1';
		loginController.securityAnswerInput = 'Test';
		loginController.resetPassword();

		newUserObj.Security_Question__c  = 'Test';
		newUserObj.Security_Answer__c = 'Test';
		loginController.loginUserObj = newUserObj;
		loginController.login();
		
		loginController.initializeUserDetails(newUserObj.Email );
		loginController.initForgotpassword();
		loginController.forgotPasswordPage();
		loginController.needSigningHelpPage();
		loginController.returnTologinPage();
		loginController.showForgotPassword();
		loginController.showForgotUserName();
	}


	//Commented for Test errors
	private static testMethod void TestForgotUsername(){
		
		/*
		Account accountObj1 = TestPRMLibrary.insertAccount('PRMPartnerAccount2', PRMLibrary.PARTNER);
		accountObj1.IsPartner = true;
		update accountObj1;

		Contact contactObj1 = TestPRMLibrary.insertContact('PRMTestAccount2', 
											PRMLibrary.PARTNER, 
											'PRMTestLastName2',
											'sunrunprmcontact22@gmail.com');		
		contactObj1.accountId = accountObj1.Id;
		contactObj1.FirstName = 'PRMTest2';
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
		insert 	newUserObj;
		*/
		String partnerAccountId = PartnerDetail__c.getValues('ApexTestAccount').PartnerAccountId__C;
		String partnerContactId = PartnerDetail__c.getValues('ApexTestAccount').PartnerContactId__C;
		String partnerSalesRepId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
		String salesRepEmail = PartnerDetail__c.getValues('ApexTestAccount').PartnerContactEmail__C;
		User newUserObj = [Select Id, username, firstname, lastname, name, email from User where contactId =:partnerContactId];
					
		newUserObj.FirstName = newUserObj.FirstName + '1';
		newUserObj.LastName = newUserObj.LastName  + '1';
		newUserObj.Email = 'prmmodified@gmail.com';
		update newUserObj;		

		PartnerPortalLogin loginController = new PartnerPortalLogin();
		loginController.CheckPortalUser();

		loginController.email = 'prmmodified@gmail.com';
		loginController.CheckPortalUser();
				
		loginController.email = 'prmmodified@gmail.com';
		loginController.CheckPortalUser();
		
		loginController.email = '';
		loginController.username = 'test1';
		loginController.forgotPassword();
		
		loginController.email = 'prmmodified@gmail.com';
		loginController.username = newUserObj.username;
		loginController.forgotPassword();

		loginController = new PartnerPortalLogin();
		loginController.email = 'prmmodified1@gmail.com';
		loginController.forgotPassword();
	}

	private static testMethod void TestShowSecurityQuestion(){
		/*
		Account accountObj1 = TestPRMLibrary.insertAccount('PRMPartnerAccount2', PRMLibrary.PARTNER);
		accountObj1.IsPartner = true;
		update accountObj1;

		Contact contactObj1 = TestPRMLibrary.insertContact('PRMTestAccount3', 
											PRMLibrary.PARTNER, 
											'PRMTestLastName3',
											'sunrunprmcontact23@gmail.com');		
		contactObj1.accountId = accountObj1.Id;
		contactObj1.FirstName = 'PRMTest3';
		update contactObj1;
		System.debug('contactObj1: ' + contactObj1.Id);
		List<Profile> profiles = [Select Id , name from Profile where name like '%Gold Partner User%'];
		
		User newUserObj = new User();
		newUserObj.ProfileId = profiles[0].Id;
		newUserObj.FirstName = contactObj1.firstname;
		newUserObj.LastName = contactObj1.lastname;
		newUserObj.Email = 'sunrunprmcontact23@gmail.com';
		newUserObj.title = 'title1';
		newUserObj.Username = contactObj1.email;
		newUserObj.contactId = contactObj1.id;
		newUserObj.TimeZoneSidKey = 'America/Los_Angeles';
		newUserObj.EmailEncodingKey = 'ISO-8859-1';
		newUserObj.LocaleSidkey = 'en_US';
		newUserObj.LanguageLocaleKey = 'en_US';
		newUserObj.alias = 'abxz';
		newUserObj.CommunityNickname = 'prmtest1';
		//newUserObj.Security_Question__c  = 'Test';
		//newUserObj.Security_Answer__c = 'Test';	
		insert 	newUserObj;
		*/

		String partnerAccountId = PartnerDetail__c.getValues('ApexTestAccount').PartnerAccountId__C;
		String partnerContactId = PartnerDetail__c.getValues('ApexTestAccount').PartnerContactId__C;
		String partnerSalesRepId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
		String salesRepEmail = PartnerDetail__c.getValues('ApexTestAccount').PartnerContactEmail__C;
	
		PartnerPortalLogin loginController = new PartnerPortalLogin();		
		loginController.showSecurityQuestion();

		loginController.email = 'testTestShowSecurityQuestion@gmail.com';			
		loginController.showSecurityQuestion();

		loginController.email = salesRepEmail;	
		loginController.showSecurityQuestion();		
		
		loginController = new PartnerPortalLogin();
		loginController.savesecurityQuestion();

		loginController.securityQuestion = 'Test';
		loginController.securityAnswer = null;
		loginController.savesecurityQuestion();
		
		User userObj = [Select Id, firstname, lastname, name, email from User where contactId =:partnerContactId];
		
		loginController.securityQuestion = 'Test';
		loginController.securityAnswer = 'Test';
		loginController.loginUserObj = userObj;
		loginController.savesecurityQuestion();


		//Test emailUserName
		loginController = new PartnerPortalLogin();
		loginController.securityAnswerInput = null;
		loginController.emailUserName();
		
		loginController.userSercurityAnswer = 'Test1';
		loginController.securityAnswerInput = 'Test';
		loginController.emailUserName();

		loginController.userSercurityAnswer = 'Test';
		loginController.securityAnswerInput = 'Test';
		loginController.emailUserName();		

		loginController.email = 'sunrunprmcontact23@gmail.com';	
		loginController.CheckPortalUser();
		loginController.forgotPassword = true;
		loginController.showSecurityQuestion();

		loginController.forgotPassword = false;
		loginController.forgotUsername = false;
		loginController.showSecurityQuestion();
		
		loginController.userSercurityAnswer = 'Test';
		loginController.securityAnswerInput = 'Test';
		System.debug('Start ..');
		loginController.emailUserName();
		System.debug('End ..');
		
		loginController.username = null;
		loginController.userSercurityAnswer = 'test';
		loginController.securityAnswerInput = 'test';
		loginController.resetPassword();
		
		loginController.initForgotUsername();

	}	


}