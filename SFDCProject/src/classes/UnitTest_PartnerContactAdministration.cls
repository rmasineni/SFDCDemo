@isTest (SeeAllData=true)
public class UnitTest_PartnerContactAdministration {

	static testmethod void testViewContact(){
		//Create Contact
		Contact contactObj1 = TestPRMLibrary.insertContact('PRMTestAccountExpired1',
															PRMLibrary.PARTNER, 
															'PRMTestExpiredLastName1',
															'prmcontactExpired1@gmail.com');

		Account accountObj1 = TestPRMLibrary.insertAccount('PRMPartnerAccount2', PRMLibrary.PARTNER);
		accountObj1.IsPartner = true;
		accountObj1.ParentId = contactObj1.AccountId;
		update accountObj1;	

		contactObj1.firstname = 'TestContact11';
		contactObj1.Sells_Sunrun__c = 'Yes';
		contactObj1.Sells_in_CA__c = 'Yes';
		contactObj1.Application_Submitted__c = date.today().addDays(2);
		contactObj1.Sells_Sunrun__c = 'Yes';
		contactObj1.e_sign_documents_access__c = 'Requested';
		contactObj1.Can_Run_Change_Orders__c = 'Requested';
		contactObj1.Proposal_Tool_Access__c = 'Requested';
		contactObj1.Design_Tool_Access__c = 'Requested';
		contactObj1.Application_Status__c = 'Submitted';
		update 	contactObj1;
		
		AccountContactRole contactRoleObj = new AccountContactRole();
		contactRoleObj.ContactId = contactObj1.Id;
		contactRoleObj.accountid = accountObj1.Id;
		contactRoleObj.Role = 'Other';
		upsert contactRoleObj;
		
		//View Contact
		PRMContactViewController viewController = new PRMContactViewController();
		System.currentPagereference().getParameters().put('contactId', contactObj1.Id);
		viewController.init();
		Boolean concierge = viewController.isPartnerConcierge;
		String tempString = viewController.contactPageType;
		viewController.cancel();
		viewController.edit();
		viewController.getContactModesList();
		viewController.syncContactModes();
		viewController.observingContacts();
		viewController.sendContactToNetExam();
		
		System.currentPagereference().getParameters().put('accountId', accountObj1.Id);

				
		PRMContactSearch contactSearchObj = new PRMContactSearch();
		contactSearchObj.customLookup.Account__c = contactRoleObj.accountid;
		contactSearchObj.applySearchFilter();
		contactSearchObj.getDeactivationReasons();
		contactSearchObj.getActions();
		contactSearchObj.getSearchBy();
		contactSearchObj.getAccountObj();
		
		contactSearchObj.exactSearch = true;
		contactSearchObj.searchColumnName = 'firstName';
		contactSearchObj.searchValue = contactObj1.firstname;
		contactSearchObj.getAllPRMContacts();

		Boolean value1 = contactSearchObj.hasNext ;
		value1 = contactSearchObj.hasPrevious;
		Integer pageVal =  contactSearchObj.pageNumber;
		contactSearchObj.first();
		contactSearchObj.last();
		contactSearchObj.previous();
		contactSearchObj.next();
		contactSearchObj.showPopup();
		contactSearchObj.closePopup();
		contactSearchObj.exportToPDF();
		contactSearchObj.exportToExcel();
		contactSearchObj.activateUser();
		contactSearchObj.userActions();
		contactSearchObj.deactivateUser();
		contactSearchObj.deactivateUserNew();
		//contactSearchObj.getContactSearchPage();
		contactSearchObj.resetPasswords();
		contactSearchObj.createUser();

		contactSearchObj.con = null;
		contactSearchObj.exactSearch = true;
		contactSearchObj.searchColumnName = 'firstName';
		contactSearchObj.searchValue = contactObj1.firstname;
		contactSearchObj.getAllPRMContacts();

		contactSearchObj.con = null;
		contactSearchObj.exactSearch = true;
		contactSearchObj.searchColumnName = 'lastName';
		contactSearchObj.searchValue = contactObj1.lastname;
		contactSearchObj.getAllPRMContacts();

		contactSearchObj.con = null;
		contactSearchObj.exactSearch = true;
		contactSearchObj.searchColumnName = 'email';
		contactSearchObj.searchValue = contactObj1.email;
		contactSearchObj.getAllPRMContacts();

		contactSearchObj.con = null;
		contactSearchObj.activeContacts = true;
		contactSearchObj.exactSearch = true;
		contactSearchObj.searchColumnName = 'email';
		contactSearchObj.searchValue = contactObj1.email;
		contactSearchObj.getAllPRMContacts();
		
		contactSearchObj.exactSearch = false;
		contactSearchObj.con = null;
		contactSearchObj.searchColumnName = 'firstName';
		contactSearchObj.searchValue = contactObj1.firstname;
		contactSearchObj.getAllPRMContacts();

		contactSearchObj.con = null;
		contactSearchObj.searchColumnName = 'lastName';
		contactSearchObj.searchValue = contactObj1.lastname;
		contactSearchObj.getAllPRMContacts();

		contactSearchObj.con = null;
		contactSearchObj.searchColumnName = 'email';
		contactSearchObj.searchValue = contactObj1.email;
		contactSearchObj.getAllPRMContacts();

		contactSearchObj.con = null;
		contactSearchObj.activeContacts = true;
		contactSearchObj.searchColumnName = 'email';
		contactSearchObj.searchValue = contactObj1.email;
		contactSearchObj.getAllPRMContacts();

	}


	//Commented for Test errors
   private static testMethod void TestCreatePartnerPortalUserErrors(){
		
		/*
		        Account accountObj1 = TestPRMLibrary.insertAccount('Solar11', PRMLibrary.PARTNER);
        accountObj1.Partner_Type__c = 'Full Service';
        accountObj1.IsPartner = true;
        update accountObj1;     
        
        List<Account> accountlist = new List<Account>();
        Account accountObj2 = TestPRMLibrary.insertAccount('Solar12', PRMLibrary.PARTNER);
        accountObj2.Partner_Type__c = 'Full Service';
        accountObj2.ParentId = accountObj1.Id;
        accountObj2.Site = 'TestSite1';
        accountObj2.IsPartner = true;  
        accountlist.add(accountObj2);       

        Account accountObj3 = TestPRMLibrary.insertAccount('Solar13', PRMLibrary.PARTNER);
        accountObj3.Partner_Type__c = 'Full Service';
        accountObj3.ParentId = accountObj1.Id;
        accountObj3.Site = 'TestSite2';
        accountObj3.IsPartner = true;
        //update accountObj3;   
        accountlist.add(accountObj3);   
        update accountlist;
        System.debug('accountlist: ' + accountlist);
    

        
        System.currentPagereference().getParameters().put('accountId', accountObj1.Id);
        
        PRMContactCreateController createControllerObj = new PRMContactCreateController();
        createControllerObj.contactObj.AccountId = accountObj1.Id;
        createControllerObj.contactObj.FirstName = 'SU1PortalUserF451';
        createControllerObj.contactObj.lastname = 'SU1PortalUserL451';
        createControllerObj.contactObj.email = 'SU1PortalUserL451@gmail.com';
        createControllerObj.contactObj.title = 'Title-1';
        createControllerObj.contactObj.Sells_SunRun__c = 'Yes';
        createControllerObj.contactObj.Sells_in_CA__c = 'No';
        createControllerObj.contactObj.Job_Function__c = 'Analyst';
        createControllerObj.contactObj.role__C = 'Executive';
        createControllerObj.contactObj.phone = '12345';
        createControllerObj.contactObj.MobilePhone = '3523523';
        
        createControllerObj.contactObj.Partner_Portal_Access__c = 'Requested';
        createControllerObj.contactObj.Delegated_Admin_Access__c = 'Requested';
        createControllerObj.contactObj.Proposal_Tool_Access__c = 'Requested';

        Boolean isSolarUniverse = createControllerObj.showSolarUniverseFields;
        createControllerObj.contactObj.Supress_Sales_Documents_Access__c = 'Requested';
        createControllerObj.contactObj.Supress_EPC_Documents_Access__c = 'Requested';
        createControllerObj.contactObj.Automatic_Document_Generation_Access__c = 'Granted';
        ContactModeRelationship relObj = createControllerObj.contactModeRelObj;
        relObj.rightvalues.put(partnerModesObj1.Id, partnerModesObj1.Mode_Name__C);
        relObj.rightvalues.put(partnerModesObj2.Id, partnerModesObj2.Mode_Name__C);
        //createControllerObj.contactObj.

        List<User> portalUsers1 = [Select Id, name from User where  contactId != null and contactId = :createControllerObj.contactObj.Id];
        System.debug('portalUsers1: ' + portalUsers1);
        Test.startTest();
        createControllerObj.submit();
        Test.stopTest();
		*/
        
		Id userId = PartnerDetail__c.getValues('EDPTestAccount').PartnerUserId__c;
		Id accountId = PartnerDetail__c.getValues('EDPTestAccount').PartnerAccountId__c;
        Partner_Modes__c partnerModesObj1 = new Partner_Modes__c();
        partnerModesObj1.Mode_Id__c = '1234';
        partnerModesObj1.Mode_Name__c = 'Mode1';
        partnerModesObj1.Account__c = accountId;
        partnerModesObj1.ModeId_accountId__C = partnerModesObj1.Mode_Id__c + partnerModesObj1.Account__c;
        insert partnerModesObj1;

        Partner_Modes__c partnerModesObj2 = new Partner_Modes__c();
        partnerModesObj2.Mode_Id__c = '2234';
        partnerModesObj2.Mode_Name__c = 'Mode2';
        partnerModesObj2.Account__c = accountId;
        partnerModesObj2.ModeId_accountId__C = partnerModesObj2.Mode_Id__c + partnerModesObj2.Account__c;
        insert partnerModesObj2;

		Partner_Location__c partnerLocation = new Partner_Location__c();	
		partnerLocation.Account__c = accountId;
		partnerLocation.Headquarters__c = true;
		insert partnerLocation;

		User partnerUser = [Select id, name, email from User where Id =:userId];		
		System.runAs(partnerUser){

            PRMContactCreateController createControllerObj12= new PRMContactCreateController();
            createControllerObj12.contactObj.AccountId = accountId;
            createControllerObj12.contactObj.FirstName = 'SU1PortalUserF151';
            createControllerObj12.contactObj.lastname = 'SU1PortalUserL151';
            createControllerObj12.contactObj.email = 'SU1PortalUserL511@gmail.com';
            createControllerObj12.contactObj.title = 'Title-1';
            createControllerObj12.contactObj.Sells_SunRun__c = 'Yes';
            createControllerObj12.contactObj.Sells_in_CA__c = 'No';
            createControllerObj12.contactObj.Job_Function__c = 'Analyst';
            createControllerObj12.contactObj.role__C = 'Executive';
            createControllerObj12.contactObj.phone = '12345';
            createControllerObj12.contactObj.MobilePhone = '3523523';
            
            createControllerObj12.contactObj.Partner_Portal_Access__c = 'Requested';
            createControllerObj12.contactObj.Delegated_Admin_Access__c = 'Requested';
            createControllerObj12.contactObj.Proposal_Tool_Access__c = 'Requested';
    
            Boolean isSolarUniverse = createControllerObj12.showSolarUniverseFields;
            createControllerObj12.contactObj.Supress_Sales_Documents_Access__c = 'Requested';
            createControllerObj12.contactObj.Supress_EPC_Documents_Access__c = 'Requested';
            createControllerObj12.contactObj.Automatic_Document_Generation_Access__c = 'Requested';
            ContactModeRelationship relObj = createControllerObj12.contactModeRelObj;
            relObj.rightvalues.put(partnerModesObj1.Id, partnerModesObj1.Mode_Name__C);
            relObj.rightvalues.put(partnerModesObj2.Id, partnerModesObj2.Mode_Name__C);

            createControllerObj12.contactObj.Proposal_Tool_Access__c = 'Requested';
            createControllerObj12.contactObj.Can_Run_Change_Orders__c = null;
            createControllerObj12.contactObj.Partner_Portal_Access__c = 'Requested';
            createControllerObj12.contactObj.Delegated_Admin_Access__c = null;
            createControllerObj12.contactObj.Design_Tool_Access__c = null;
			createControllerObj12.contactObj.Location__c = partnerLocation.Id;
			createControllerObj12.customLookup.Account__c = accountId; 
            createControllerObj12.submit();


	 		PRMContactSearch contactSearchObj1 = new PRMContactSearch();
			contactSearchObj1.customLookup.Account__c = accountId;
			contactSearchObj1.applySearchFilter();    

			List<PRMContact> prmContactList1 = contactSearchObj1.getPRMContacts();
			if(prmContactList1 != null && prmContactList1.size() > 0){
				prmContactList1[0].selected = true;
			}

			List<PRMContact> prmContactList = contactSearchObj1.getAllPRMContacts();
			if(prmContactList != null && prmContactList.size() > 0){
				prmContactList[0].selected = true;
			}
			Pagereference pageRef = contactSearchObj1.resetPasswords();
			
			PartnerPortalLanding ptrLandingObj = new PartnerPortalLanding();
        }
        
    }

}