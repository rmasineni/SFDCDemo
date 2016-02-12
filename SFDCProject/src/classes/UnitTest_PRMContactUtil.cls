@isTest(SeeAllData=true)
public class UnitTest_PRMContactUtil {

	private static testMethod void testContactUtilsMethods1(){
		PRMContactUtil contactUtilObj = new PRMContactUtil();
		Id profileId = PRMContactUtil.getProfileId('System Administrator');
		String profileName1 = PRMContactUtil.getProfileId(profileId);
		String profileName2 = PRMContactUtil.getProfileName(profileId);

		User loginUser1 = PRMContactUtil.getLoginUser();
		User loginUser2 = PRMContactUtil.getUser(loginUser1.Id);

		Account accountObj1 = TestPRMLibrary.insertAccount(PRMContactUtil.SOLAR_UNIVERSE, PRMLibrary.PARTNER);
		accountObj1.IsPartner = true;
		accountObj1.Partner_Type__c = 'FullService;Install;';
		update accountObj1;
		
		Account accountObj2 = TestPRMLibrary.insertAccount(PRMContactUtil.SOLAR_UNIVERSE, PRMLibrary.PARTNER);
		accountObj2.IsPartner = true;
		accountObj2.ParentId = accountObj1.Id;
		update accountObj2;		
		
		Map<Id, String> sitesMap = PRMContactUtil.getPartnerSites(accountObj1.Id);
		List<UserRole> userRoleObjs = [Select Id, Name, PortalAccountId from UserRole where PortalAccountId != null limit 2];
		
		Set<Id> portalAccounts = new Set<Id>();
		for(UserRole roleObj : userRoleObjs){
			portalAccounts.add(roleObj.PortalAccountId);
		}
		
		Map<Id, Map<String, UserRole>> roleMap = PRMContactUtil.getUserRoles(portalAccounts);
		String errorMessage =  PRMContactUtil.validateAccount(accountObj1);
		Id parentAccountId = PRMContactUtil.getUltimateParentAccountId(accountObj2.Id);
	
		Contact contactObj2 = TestPRMLibrary.insertContact('PRMTestAccount1',PRMLibrary.PARTNER, 
											'PRMTestLastName21','sunrunprmcontact12@gmail.com');		
		contactObj2.accountId = accountObj2.Id;
		contactObj2.FirstName = 'PRMTestFremont11';
		update contactObj2;	
		
		set<Id> contactIds = new set<Id>();
		contactIds.add(contactObj2.Id);
		List<Contact> contactList = PRMContactUtil.getContacts('PRMTestFremont11', 'PRMTestLastName21',  'sunrunprmcontact12@gmail.com');
		contactList = PRMContactUtil.getContacts(contactIds);
		
		contactObj2.Sells_Sunrun__c = 'Yes';
		profileId = PRMContactUtil.getProfileId(accountObj1, contactObj2);
		
		contactObj2.Sells_Sunrun__c = 'No';
		profileId = PRMContactUtil.getProfileId(accountObj1, contactObj2);

		accountObj1.Partner_Type__c = 'FullService;Install;';
		contactObj2.Sells_Sunrun__c = 'No';
		profileId = PRMContactUtil.getProfileId(accountObj1, contactObj2);		

		accountObj1.Partner_Type__c = 'Sales';
		contactObj2.Sells_Sunrun__c = 'No';		
		profileId = PRMContactUtil.getProfileId(accountObj1, contactObj2);		

		accountObj1.Partner_Type__c = 'Sales';
		contactObj2.Sells_Sunrun__c = 'Yes';		
		profileId = PRMContactUtil.getProfileId(accountObj1, contactObj2);

		contactObj2.Delegated_Admin_Access__c = PRMContactUtil.GRANTED;		
		accountObj1.Partner_Type__c = 'FullService;Install;';
		profileId = PRMContactUtil.getProfileId(accountObj1, contactObj2);
		
		Account tempAccountObj;
		String accountErrorMessage = PRMContactUtil.validateAccount(tempAccountObj);
		
		tempAccountObj = new Account();
		tempAccountObj.Account_Type__c = null;
		accountErrorMessage = PRMContactUtil.validateAccount(tempAccountObj);		
		
		tempAccountObj.parentId = accountObj1.Id;
		accountErrorMessage = PRMContactUtil.validateAccount(tempAccountObj);	

		accountErrorMessage = PRMContactUtil.validateAccount(tempAccountObj);
		
		String alias = PRMContactUtil.getUniqueAlias('s34');
		String nickName = PRMContactUtil.getUniqueNickname('nickN1');
		
		Map<Id, User> existingUsers = PRMContactUtil.getExistingPortalUsers(contactIds);

		PRMContactUtil.revokeSalesToolsAccess(contactObj2);
		PRMContactUtil.revokeToolsAccess(contactObj2, true);
		
		contactObj2.Proposal_Tool_Access__c = PRMContactUtil.REQUESTED;
		contactObj2.Partner_Portal_Access__c = PRMContactUtil.REQUESTED;
		contactObj2.Design_Tool_Access__c = PRMContactUtil.REQUESTED;
		contactObj2.e_sign_documents_access__c = PRMContactUtil.REQUESTED;
		contactObj2.Can_Run_Change_Orders__c = PRMContactUtil.REQUESTED;
		contactObj2.Delegated_Admin_Access__c = PRMContactUtil.REQUESTED;
		contactObj2.Supress_EPC_Documents_Access__c = PRMContactUtil.REQUESTED;
		contactObj2.Supress_Sales_Documents_Access__c = PRMContactUtil.REQUESTED;
		contactObj2.Automatic_Document_Generation_Access__c = PRMContactUtil.REQUESTED;
		PRMContactUtil.setToolsAccessToRequested(contactObj2, true);

		PRMContactUtil.grantToolsAccess(contactObj2, true);
		Test.startTest();
			Set<Id> contactIds2 = new Set<Id>();
			contactIds2.add(contactObj2.Id);
			PRMContactUtil.managePortalUsers(contactIds2);
		Test.stopTest();		
		
	}
	
	private static testmethod void testEmail(){
		String partnerContactId = PartnerDetail__c.getValues('EDPTestAccount').PartnerContactId__C;
		Contact contactObj = [Select Id, name from Contact where Id =:partnerContactId];
		Set<Id> contactIds2 = new Set<Id>();
		contactIds2.add(contactObj.Id);
		PRMContactUtil.managePortalUsers(contactIds2);
		
		
	}

	private static testMethod void testContactObjects(){
		
		Contact contactObj1 = new Contact();
		contactObj1.Sells_Sunrun__c = 'No';
		contactObj1.Proposal_Tool_Access__c = PRMContactUtil.REQUESTED;
		contactObj1.Delegated_Admin_Access__c = PRMContactUtil.REQUESTED;	
		contactObj1.Partner_Portal_Access__c = PRMContactUtil.REQUESTED;	
		contactObj1.Can_Run_Change_Orders__c = PRMContactUtil.REQUESTED;	
		contactObj1.e_sign_documents_access__c = PRMContactUtil.REQUESTED;	
		PRMContactUtil.checkToolsAccess(contactObj1, null, null);
		
		contactObj1.Sells_Sunrun__c = 'Yes';
		contactObj1.Accreditation_Status__c = null;
		contactObj1.Proposal_Tool_Access__c = PRMContactUtil.GRANTED;
		contactObj1.Delegated_Admin_Access__c = PRMContactUtil.GRANTED;	
		contactObj1.Partner_Portal_Access__c = PRMContactUtil.GRANTED;	
		contactObj1.Can_Run_Change_Orders__c = PRMContactUtil.GRANTED;	
		contactObj1.e_sign_documents_access__c = PRMContactUtil.GRANTED;	
		contactObj1.Design_Tool_Access__c = PRMContactUtil.GRANTED;	

		PRMContactUtil.checkToolsAccess(contactObj1, null, null);

		contactObj1.Sells_Sunrun__c = 'Yes';
		contactObj1.Accreditation_Status__c = PRMContactUtil.ACCREDITATION_PENDING;
		contactObj1.Proposal_Tool_Access__c = PRMContactUtil.GRANTED;
		contactObj1.Delegated_Admin_Access__c = PRMContactUtil.GRANTED;	
		contactObj1.Partner_Portal_Access__c = PRMContactUtil.GRANTED;	
		contactObj1.Can_Run_Change_Orders__c = PRMContactUtil.GRANTED;	
		contactObj1.e_sign_documents_access__c = PRMContactUtil.GRANTED;	
		contactObj1.Design_Tool_Access__c = PRMContactUtil.GRANTED;	
		PRMContactUtil.checkToolsAccess(contactObj1, null, null);		
	
		contactObj1.Sells_Sunrun__c = 'No';
		Boolean value1 = PRMContactUtil.hasValidCSLB(contactObj1);

		contactObj1.Sells_Sunrun__c = 'Yes';
		contactObj1.Sells_in_CA__c = 'No';
		value1 = PRMContactUtil.hasValidCSLB(contactObj1);

		contactObj1.Sells_Sunrun__c = 'Yes';
		contactObj1.Sells_in_CA__c = 'Yes';
		contactObj1.Application_Status__c = PRMContactUtil.APPROVED;	
		value1 = PRMContactUtil.hasValidCSLB(contactObj1);

		contactObj1.Application_Status__c = PRMContactUtil.SUBMITTED;	
		value1 = PRMContactUtil.hasValidCSLB(contactObj1);

		Contact contactObj2 = new Contact();
		Contact contactObj3 = new Contact();
		contactObj2.active__c = true;
		contactObj2.Partner_Portal_Access__c = PRMContactUtil.GRANTED;
		Id contactId = PRMContactUtil.checkPartnerPortalAccess(contactObj2, null);
		
		contactObj2.Partner_Portal_Access__c = PRMContactUtil.GRANTED;
		contactObj3.Partner_Portal_Access__c = PRMContactUtil.REVOKED;
		contactId = PRMContactUtil.checkPartnerPortalAccess(contactObj2, contactObj3);
		
		contactObj2.Partner_Portal_Access__c = PRMContactUtil.GRANTED;
		contactObj2.role__c = 'Manager';
		contactObj3.Partner_Portal_Access__c = PRMContactUtil.GRANTED;
		contactId = PRMContactUtil.checkPartnerPortalAccess(contactObj2, contactObj3);		

		contactObj2.role__c = 'Manager';
		contactObj3.role__c = 'Manager';
		contactObj2.Delegated_Admin_Access__c = PRMContactUtil.REQUESTED;
		contactId = PRMContactUtil.checkPartnerPortalAccess(contactObj2, contactObj3);	


		contactObj2.Delegated_Admin_Access__c = PRMContactUtil.REQUESTED;
		contactObj3.Delegated_Admin_Access__c = PRMContactUtil.REQUESTED;
		contactObj2.Sells_Sunrun__c = 'No';
		contactId = PRMContactUtil.checkPartnerPortalAccess(contactObj2, contactObj3);

		contactObj2.Sells_Sunrun__c = 'No';
		contactObj3.Sells_Sunrun__c = 'No';
		contactId = PRMContactUtil.checkPartnerPortalAccess(contactObj2, contactObj3);

		contactObj2.Partner_Portal_Access__c = PRMContactUtil.REQUESTED;
		contactId = PRMContactUtil.checkPartnerPortalAccess(contactObj2, contactObj3);

		contactObj2.Partner_Portal_Access__c = PRMContactUtil.REQUESTED;
		contactObj3.Partner_Portal_Access__c = PRMContactUtil.REQUESTED;
		contactId = PRMContactUtil.checkPartnerPortalAccess(contactObj2, contactObj3);

		contactObj2.active__C = false;
		contactObj3.active__C = true;
		contactId = PRMContactUtil.checkPartnerPortalAccess(contactObj2, contactObj3);		 

		contactObj2.active__C = true;
		contactObj3.active__C = true;
		contactId = PRMContactUtil.checkPartnerPortalAccess(contactObj2, contactObj3);	
		
	}

	
	private static testMethod void testAccriditationAndCSLB(){
		
		Account accountObj1 = TestPRMLibrary.insertAccount(PRMContactUtil.SOLAR_UNIVERSE, PRMLibrary.PARTNER);
		accountObj1.IsPartner = true;
		accountObj1.Partner_Type__c = 'FullService;Install;';
		update accountObj1;
		
		Contact contactObj1 = new Contact();
		contactObj1.active__c = false;

		PRMContactUtil.performAccreditationProcess(contactObj1, null, accountObj1);
		
		contactObj1.active__c = true;
		contactObj1.Sells_Sunrun__c = PRMContactUtil.NO;
		contactObj1.Application_Status__c = PRMContactUtil.NOT_RECEIVED;
		contactObj1.Sales_Registration_Type__c = null;
		PRMContactUtil.performAccreditationProcess(contactObj1, null, accountObj1);

		contactObj1.Sells_Sunrun__c = PRMContactUtil.YES;
		contactObj1.Application_Status__c = PRMContactUtil.NOT_RECEIVED;
		contactObj1.Accreditation_Status__c = null;
		contactObj1.Sells_in_CA__c = PRMContactUtil.NO;
		contactObj1.Sales_Registration_Type__c = null;
		PRMContactUtil.performAccreditationProcess(contactObj1, null, accountObj1);		

		contactObj1.Sells_Sunrun__c = PRMContactUtil.YES;
		contactObj1.Application_Status__c = PRMContactUtil.NOT_RECEIVED;
		contactObj1.Accreditation_Status__c = null;
		contactObj1.Sells_in_CA__c = PRMContactUtil.YES;
		contactObj1.Sales_Registration_Type__c = PRMContactUtil.NOT_NEEDED;
		PRMContactUtil.performAccreditationProcess(contactObj1, null, accountObj1);	

		contactObj1.Sells_Sunrun__c = PRMContactUtil.YES;
		contactObj1.Application_Received__c = null;
		contactObj1.Sales_Registration_Type__c = PRMContactUtil.NOT_NEEDED;
		contactObj1.Application_Status__c = PRMContactUtil.RECEIVED;
		contactObj1.Accreditation_Status__c = null;
		contactObj1.Sells_in_CA__c = PRMContactUtil.YES;
		contactObj1.Sales_Registration_Type__c = PRMContactUtil.NOT_NEEDED;
		PRMContactUtil.performAccreditationProcess(contactObj1, null, accountObj1);

		contactObj1.Sells_Sunrun__c = PRMContactUtil.YES;
		contactObj1.Application_Received__c = null;
		contactObj1.Sales_Registration_Type__c = PRMContactUtil.NOT_NEEDED;
		contactObj1.Application_Status__c = NULL;
		contactObj1.Accreditation_Status__c = PRMContactUtil.NOT_ACCREDITED;
		contactObj1.Sells_in_CA__c = PRMContactUtil.YES;
		contactObj1.Sales_Registration_Type__c = PRMContactUtil.NOT_NEEDED;
		PRMContactUtil.performAccreditationProcess(contactObj1, null, accountObj1);	

		
		contactObj1 = new Contact();
		Contact contactObj2 = new Contact();
		contactObj1.active__C = true;
		contactObj2.active__C = true;
		contactObj1.Sells_Sunrun__c = PRMContactUtil.YES;
		contactObj1.Sells_in_CA__c = PRMContactUtil.YES;
		contactObj1.Application_Status__c = PRMContactUtil.NOT_RECEIVED;
		contactObj2.Sells_Sunrun__c = PRMContactUtil.NO;
		PRMContactUtil.performAccreditationProcess(contactObj1, contactObj2, accountObj1);	

		contactObj1.active__C = true;
		contactObj2.active__C = true;

		contactObj1.Sells_Sunrun__c = PRMContactUtil.YES;
		contactObj1.Sells_in_CA__c = PRMContactUtil.YES;
		contactObj1.Application_Status__c = PRMContactUtil.APPROVED;
		contactObj2.Sells_Sunrun__c = PRMContactUtil.NO;
		PRMContactUtil.performAccreditationProcess(contactObj1, contactObj2, accountObj1);

		contactObj2.Sells_Sunrun__c = PRMContactUtil.YES;
		contactObj2.Sells_in_CA__c = PRMContactUtil.NO;
		
		contactObj1.Sells_in_CA__c = PRMContactUtil.YES;
		contactObj1.Sells_Sunrun__c = PRMContactUtil.YES;
		contactObj1.Application_Status__c = PRMContactUtil.REJECTED;
		PRMContactUtil.performAccreditationProcess(contactObj1, contactObj2, accountObj1);


		contactObj2.Sells_Sunrun__c = PRMContactUtil.YES;
		contactObj2.Sells_in_CA__c = PRMContactUtil.NO;
		contactObj1.Sells_in_CA__c = PRMContactUtil.YES;
		contactObj1.Sells_Sunrun__c = PRMContactUtil.YES;
		contactObj1.Application_Status__c = PRMContactUtil.REJECTED;
		PRMContactUtil.performAccreditationProcess(contactObj1, null, accountObj1);		


		contactObj1.Sells_in_CA__c = PRMContactUtil.YES;
		contactObj1.Sells_Sunrun__c = PRMContactUtil.YES;
		contactObj1.Application_Status__c = PRMContactUtil.SUBMITTED;
		contactObj1.Application_Submitted__c = null;
		PRMContactUtil.performAccreditationProcess(contactObj1, null, accountObj1);	

		contactObj1.Sells_in_CA__c = PRMContactUtil.YES;
		contactObj1.Sells_Sunrun__c = PRMContactUtil.YES;
		contactObj1.Application_Status__c = PRMContactUtil.RECEIVED;
		contactObj1.Application_Received__c = null;
		PRMContactUtil.performAccreditationProcess(contactObj1, null, accountObj1);	

		contactObj1.Sells_in_CA__c = PRMContactUtil.YES;
		contactObj1.Sells_Sunrun__c = PRMContactUtil.YES;
		contactObj1.Application_Status__c = PRMContactUtil.NOT_RECEIVED;
		contactObj1.Application_Status__c = PRMContactUtil.NOT_RECEIVED;
		contactObj1.Sales_Registration_Type__c = PRMContactUtil.NOT_NEEDED;
		contactObj1.Application_Received__c = null;
		PRMContactUtil.performAccreditationProcess(contactObj1, null, accountObj1);
		
	}

	private static testMethod void TestLogin2(){
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
	
		//newUserObj.FirstName = contactObj1.FirstName + '1';
		//newUserObj.LastName = contactObj1.lastname  + '1';
		//newUserObj.Email = 'prmmodified@gmail.com';
		//update newUserObj;

		PRMEmailManager.communicateErrorDetails(accountObj1, contactObj1, 
 												newUserObj, 'Test Message');


		List<Contact> contactList = new List<Contact>();
		contactList.add(contactObj1);
		Set<String> exceptionsMessages = new Set<String>();
		exceptionsMessages.add('Unable to process request ... ');
		String emailId = 'test1@gmail.com' ;
		PRMEmailManager.communicateLMSInfoErrorDetails(contactList, exceptionsMessages, emailId);

		PRMEmailManager.communicateNewUserDetails(newUserObj, newUserObj, 'Test Company', 
 												true, 
 												false);
	
		PRMEmailManager.communicateNewUserDetails(newUserObj, newUserObj, 'Test Company', 
 												false, 
 												true);
		
		PRMEmailManager.communicateNewUserDetails(null, null, 'Test Company', 
 												false, 
 												true);
		//contactObj1.active__c = false;
		contactObj1.Partner_Portal_Access__c = PRMContactUtil.NOT_NEEDED;	
		update contactObj1;
		Test.startTest();
			Set<Id> contactIds = new Set<Id>();
			contactIds.add(contactObj1.Id);
			PRMContactUtil.revokePartnerPortalAccess(contactIds);
		Test.stopTest();
		
		contactObj1.Proposal_Tool_Access__c = PRMContactUtil.GRANTED;
		contactObj1.Partner_Portal_Access__c = PRMContactUtil.GRANTED;
		contactObj1.Design_Tool_Access__c = PRMContactUtil.GRANTED;
		contactObj1.e_sign_documents_access__c = PRMContactUtil.GRANTED;
		contactObj1.Can_Run_Change_Orders__c = PRMContactUtil.GRANTED;
		contactObj1.Delegated_Admin_Access__c = PRMContactUtil.GRANTED;
		contactObj1.Supress_EPC_Documents_Access__c = PRMContactUtil.GRANTED;
		contactObj1.Supress_Sales_Documents_Access__c = PRMContactUtil.GRANTED;
		contactObj1.Automatic_Document_Generation_Access__c = PRMContactUtil.GRANTED;
		PRMContactUtil.revokeToolsAccessOnlyIfGranted(contactObj1);
		
	}
	
	
	
}