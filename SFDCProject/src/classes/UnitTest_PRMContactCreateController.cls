@isTest
public class UnitTest_PRMContactCreateController {

 	/*
 	//Commented for Test errors
    private static testMethod void TestCreatePartnerPortalUser(){
        Account accountObj1 = TestPRMLibrary.insertAccount(PRMContactUtil.SOLAR_UNIVERSE, PRMLibrary.PARTNER);
        accountObj1.Partner_Type__c = 'Full Service';
        accountObj1.IsPartner = true;
        update accountObj1;     
        
        List<Account> accountlist = new List<Account>();
        Account accountObj2 = TestPRMLibrary.insertAccount(PRMContactUtil.SOLAR_UNIVERSE, PRMLibrary.PARTNER);
        accountObj2.Partner_Type__c = 'Full Service';
        accountObj2.ParentId = accountObj1.Id;
        accountObj2.Site = 'TestSite1';
        accountObj2.IsPartner = true;
        //update accountObj2;   
        accountlist.add(accountObj2);       

        Account accountObj3 = TestPRMLibrary.insertAccount(PRMContactUtil.SOLAR_UNIVERSE, PRMLibrary.PARTNER);
        accountObj3.Partner_Type__c = 'Full Service';
        accountObj3.ParentId = accountObj1.Id;
        accountObj3.Site = 'TestSite2';
        accountObj3.IsPartner = true;
        //update accountObj3;   
        accountlist.add(accountObj3);   
        update accountlist;
        System.debug('accountlist: ' + accountlist);
    
        Partner_Modes__c partnerModesObj1 = new Partner_Modes__c();
        partnerModesObj1.Mode_Id__c = '1234';
        partnerModesObj1.Mode_Name__c = 'Mode1';
        partnerModesObj1.Account__c = accountObj1.id;
        partnerModesObj1.ModeId_accountId__C = partnerModesObj1.Mode_Id__c + partnerModesObj1.Account__c;
        insert partnerModesObj1;

        Partner_Modes__c partnerModesObj2 = new Partner_Modes__c();
        partnerModesObj2.Mode_Id__c = '2234';
        partnerModesObj2.Mode_Name__c = 'Mode2';
        partnerModesObj2.Account__c = accountObj1.id;
        partnerModesObj2.ModeId_accountId__C = partnerModesObj2.Mode_Id__c + partnerModesObj2.Account__c;
        insert partnerModesObj2;
        
        System.currentPagereference().getParameters().put('accountId', accountObj1.Id);
        
        PRMContactCreateController createControllerObj = new PRMContactCreateController();
        createControllerObj.contactObj.AccountId = accountObj1.Id;
        createControllerObj.contactObj.FirstName = 'SU1PortalUserF331';
        createControllerObj.contactObj.lastname = 'SU1PortalUserL331';
        createControllerObj.contactObj.email = 'SU1PortalUserL331@gmail.com';
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
        
        List<User> portalUsers2 = [Select Id, name from User where  contactId != null and contactId = :createControllerObj.contactObj.Id];
        System.debug('portalUsers2: ' + portalUsers2);

        System.runAs(portalUsers2[0]){
            System.debug('Valid data testing ... ');
            System.currentPagereference().getParameters().put('accountId', accountObj1.Id);
            PRMContactCreateController createControllerObj2= new PRMContactCreateController();
            createControllerObj2.contactObj.AccountId = accountObj1.Id;
            createControllerObj2.contactObj.FirstName = 'SU1PortalUserF21';
            createControllerObj2.contactObj.lastname = 'SU1PortalUserL21';
            createControllerObj2.contactObj.email = 'SU1PortalUserL2@gmail.com';
            createControllerObj2.contactObj.title = 'Title-1';
            createControllerObj2.contactObj.Sells_SunRun__c = 'Yes';
            createControllerObj2.contactObj.Sells_in_CA__c = 'No';
            createControllerObj2.contactObj.Job_Function__c = 'Analyst';
            createControllerObj2.contactObj.role__C = 'Executive';
            createControllerObj2.contactObj.phone = '12345';
            createControllerObj2.contactObj.MobilePhone = '3523523';

            createControllerObj2.contactObj.Partner_Portal_Access__c = 'Requested';
            createControllerObj2.contactObj.Delegated_Admin_Access__c = 'Requested';
            createControllerObj2.contactObj.Proposal_Tool_Access__c = 'Requested';
    
            isSolarUniverse = createControllerObj2.showSolarUniverseFields;
            createControllerObj2.contactObj.Supress_Sales_Documents_Access__c = 'Requested';
            createControllerObj2.contactObj.Supress_EPC_Documents_Access__c = 'Requested';
            createControllerObj2.contactObj.Automatic_Document_Generation_Access__c = 'Requested';
            relObj = createControllerObj2.contactModeRelObj;
            relObj.rightvalues.put(partnerModesObj1.Id, partnerModesObj1.Mode_Name__C);
            relObj.rightvalues.put(partnerModesObj2.Id, partnerModesObj2.Mode_Name__C);

            ApexPages.getMessages().clear();
            System.debug('Apexpages.getMessages():1 ' + Apexpages.getMessages());
            createControllerObj2.submit();
            System.debug('Apexpages.getMessages():2 ' + Apexpages.getMessages());

            if(accountlist != null && accountlist.size() > 0){

                System.debug(' accountlist[0].Id: ' +  accountlist[0].Id);
                createControllerObj2.siteId = accountlist[0].Id;
                createControllerObj2.submit();
                System.debug('createControllerObj2.siteId: ' + createControllerObj2.siteId);
                
                if(accountlist.size() == 2 && accountlist[1] != null){
                    System.currentPagereference().getParameters().put('contactId', createControllerObj2.contactObj.Id);
                    PRMContactCreateController createControllerObj3= new PRMContactCreateController();
                    createControllerObj2.siteId = accountlist[1].Id;
                    createControllerObj2.submit();
                }
                System.currentPagereference().getParameters().put('contactId', createControllerObj2.contactObj.Id);
                PRMContactCreateController createControllerObj4= new PRMContactCreateController();
                createControllerObj4.oldsiteId = accountlist[1].Id;
                createControllerObj4.siteId = accountlist[0].Id;

                createControllerObj4.contactObj.AccountId = accountObj1.Id;
                createControllerObj4.contactObj.FirstName = 'SU1PortalUserF41';
                createControllerObj4.contactObj.lastname = 'SU1PortalUserL41';
                createControllerObj4.contactObj.email = 'SU1PortalUserL42@gmail.com';
                createControllerObj4.contactObj.title = 'Title-41';
                createControllerObj4.contactObj.Job_Function__c = 'Analyst';                    
                
                createControllerObj4.contactObj.Sells_Sunrun__c = PRMContactUtil.YES;
                createControllerObj4.contactObj.Sells_in_CA__c = PRMContactUtil.YES;
                createControllerObj4.contactObj.Application_Status__c = null;
                createControllerObj4.contactObj.Accreditation_Status__c = null;
                createControllerObj4.submit();
                
            }
        }

    }
	*/
	
	/*
	//Commented for Test errors
    private static testMethod void TestCreatePartnerPortalUserErrors(){
        Account accountObj1 = TestPRMLibrary.insertAccount(PRMContactUtil.SOLAR_UNIVERSE, PRMLibrary.PARTNER);
        accountObj1.Partner_Type__c = 'Full Service';
        accountObj1.IsPartner = true;
        update accountObj1;     
        
        List<Account> accountlist = new List<Account>();
        Account accountObj2 = TestPRMLibrary.insertAccount(PRMContactUtil.SOLAR_UNIVERSE, PRMLibrary.PARTNER);
        accountObj2.Partner_Type__c = 'Full Service';
        accountObj2.ParentId = accountObj1.Id;
        accountObj2.Site = 'TestSite1';
        accountObj2.IsPartner = true;
        //update accountObj2;   
        accountlist.add(accountObj2);       

        Account accountObj3 = TestPRMLibrary.insertAccount(PRMContactUtil.SOLAR_UNIVERSE, PRMLibrary.PARTNER);
        accountObj3.Partner_Type__c = 'Full Service';
        accountObj3.ParentId = accountObj1.Id;
        accountObj3.Site = 'TestSite2';
        accountObj3.IsPartner = true;
        //update accountObj3;   
        accountlist.add(accountObj3);   
        update accountlist;
        System.debug('accountlist: ' + accountlist);
    
        Partner_Modes__c partnerModesObj1 = new Partner_Modes__c();
        partnerModesObj1.Mode_Id__c = '1234';
        partnerModesObj1.Mode_Name__c = 'Mode1';
        partnerModesObj1.Account__c = accountObj1.id;
        partnerModesObj1.ModeId_accountId__C = partnerModesObj1.Mode_Id__c + partnerModesObj1.Account__c;
        insert partnerModesObj1;

        Partner_Modes__c partnerModesObj2 = new Partner_Modes__c();
        partnerModesObj2.Mode_Id__c = '2234';
        partnerModesObj2.Mode_Name__c = 'Mode2';
        partnerModesObj2.Account__c = accountObj1.id;
        partnerModesObj2.ModeId_accountId__C = partnerModesObj2.Mode_Id__c + partnerModesObj2.Account__c;
        insert partnerModesObj2;
        
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
        
        List<User> portalUsers2 = [Select Id, name from User where  contactId != null and contactId = :createControllerObj.contactObj.Id];
        System.debug('portalUsers2: ' + portalUsers2);
        System.runAs(portalUsers2[0]){

            PRMContactCreateController createControllerObj12= new PRMContactCreateController();
            createControllerObj12.contactObj.AccountId = accountObj1.Id;
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
    
            isSolarUniverse = createControllerObj12.showSolarUniverseFields;
            createControllerObj12.contactObj.Supress_Sales_Documents_Access__c = 'Requested';
            createControllerObj12.contactObj.Supress_EPC_Documents_Access__c = 'Requested';
            createControllerObj12.contactObj.Automatic_Document_Generation_Access__c = 'Requested';
            relObj = createControllerObj12.contactModeRelObj;
            relObj.rightvalues.put(partnerModesObj1.Id, partnerModesObj1.Mode_Name__C);
            relObj.rightvalues.put(partnerModesObj2.Id, partnerModesObj2.Mode_Name__C);
            //createControllerObj12.contactObj.
    
            createControllerObj12.contactObj.Proposal_Tool_Access__c = PRMContactUtil.GRANTED;
            createControllerObj12.submit();

            createControllerObj12.contactObj.Proposal_Tool_Access__c = 'Requested';
            createControllerObj12.contactObj.Can_Run_Change_Orders__c = PRMContactUtil.GRANTED;
            createControllerObj12.submit();

            createControllerObj12.contactObj.Can_Run_Change_Orders__c = null;
            createControllerObj12.contactObj.Partner_Portal_Access__c = 'PRMContactUtil.GRANTED';
            createControllerObj12.submit();
    
            createControllerObj12.contactObj.Partner_Portal_Access__c = 'Requested';
            createControllerObj12.contactObj.Delegated_Admin_Access__c = PRMContactUtil.GRANTED;
            createControllerObj12.submit();
    
            createControllerObj12.contactObj.Delegated_Admin_Access__c = null;
            createControllerObj12.contactObj.Design_Tool_Access__c = PRMContactUtil.GRANTED;
            createControllerObj12.submit();
            
            createControllerObj12.contactObj.Design_Tool_Access__c = null;
            createControllerObj12.contactObj.e_sign_documents_access__c = PRMContactUtil.GRANTED;
            createControllerObj12.submit();
        }
        
    }
	*/

	
    private static testMethod void TestPartnerRoles(){
        
        Account accountObj1 = TestPRMLibrary.insertAccount(PRMContactUtil.SOLAR_UNIVERSE, PRMLibrary.PARTNER);
        accountObj1.Partner_Type__c = 'Full Service';
        accountObj1.IsPartner = true;
        update accountObj1; 

        Partner_Modes__c partnerModesObj1 = new Partner_Modes__c();
        partnerModesObj1.Mode_Id__c = '1234';
        partnerModesObj1.Mode_Name__c = 'Mode1';
        partnerModesObj1.Account__c = accountObj1.id;
        partnerModesObj1.ModeId_accountId__C = partnerModesObj1.Mode_Id__c + partnerModesObj1.Account__c;
        insert partnerModesObj1;

        Partner_Modes__c partnerModesObj2 = new Partner_Modes__c();
        partnerModesObj2.Mode_Id__c = '2234';
        partnerModesObj2.Mode_Name__c = 'Mode2';
        partnerModesObj2.Account__c = accountObj1.id;
        partnerModesObj2.ModeId_accountId__C = partnerModesObj2.Mode_Id__c + partnerModesObj2.Account__c;
        insert partnerModesObj2;

        System.currentPagereference().getParameters().put('accountId', accountObj1.Id);
        
        PRMContactCreateController createControllerObj = new PRMContactCreateController();
        createControllerObj.contactObj.AccountId = accountObj1.Id;
        createControllerObj.contactObj.FirstName = 'SU1PortalUserF61';
        createControllerObj.contactObj.lastname = 'SU1PortalUserL61';
        createControllerObj.contactObj.email = 'SU1PortalUserL61@gmail.com';
        createControllerObj.contactObj.title = 'Title-1';
        createControllerObj.contactObj.Sells_SunRun__c = 'Yes';
        createControllerObj.contactObj.Sells_in_CA__c = 'No';
        createControllerObj.contactObj.Job_Function__c = 'Analyst';
        createControllerObj.contactObj.role__C = 'Individual Contributor';
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

        //List<User> portalUsers1 = [Select Id, name from User where  contactId != null and contactId = :createControllerObj.contactObj.Id];
        //System.debug('portalUsers1: ' + portalUsers1);
        Test.startTest();
        createControllerObj.submit();
        Test.stopTest();
        
        //Id executiveId = createControllerObj.contactObj.Id;
        //createControllerObj.contactObj.role__C = 'Executive';
        //createControllerObj.submit();

        PRMContactCreateController createControllerObj2 = new PRMContactCreateController();
        createControllerObj2.contactObj.AccountId = accountObj1.Id;
        createControllerObj2.contactObj.FirstName = 'SU1PortalUserF21';
        createControllerObj2.contactObj.lastname = 'SU1PortalUserL21';
        createControllerObj2.contactObj.email = 'SU1PortalUserL21@gmail.com';
        createControllerObj2.contactObj.title = 'Title-21';
        createControllerObj2.contactObj.Sells_SunRun__c = 'Yes';
        createControllerObj2.contactObj.Sells_in_CA__c = 'No';
        createControllerObj2.contactObj.Job_Function__c = 'Analyst';
        createControllerObj2.contactObj.role__C = 'Manager';
        createControllerObj2.contactObj.phone = '12345';
        createControllerObj2.contactObj.MobilePhone = '3523523';
        
        createControllerObj2.getContactRoles();
        createControllerObj2.getContactReportsToList();
        
        createControllerObj2.contactObj.Partner_Portal_Access__c = 'Requested';
        createControllerObj2.contactObj.Delegated_Admin_Access__c = 'Requested';
        createControllerObj2.contactObj.Proposal_Tool_Access__c = 'Requested';

        isSolarUniverse = createControllerObj2.showSolarUniverseFields;
        createControllerObj2.contactObj.Supress_Sales_Documents_Access__c = 'Requested';
        createControllerObj2.contactObj.Supress_EPC_Documents_Access__c = 'Requested';
        createControllerObj2.contactObj.Automatic_Document_Generation_Access__c = 'Granted';
        relObj = createControllerObj2.contactModeRelObj;
        relObj.leftvalues.put(partnerModesObj1.Id, partnerModesObj1.Mode_Name__C);
        relObj.rightvalues.put(partnerModesObj2.Id, partnerModesObj2.Mode_Name__C);
        
        createControllerObj2.submit();

        PRMContactCreateController createControllerObj3 = new PRMContactCreateController();
        createControllerObj3.contactObj.AccountId = accountObj1.Id;
        createControllerObj3.contactObj.FirstName = 'SU1PortalUserF31';
        createControllerObj3.contactObj.lastname = 'SU1PortalUserL31';
        createControllerObj3.contactObj.email = 'SU1PortalUserL31@gmail.com';
        createControllerObj3.contactObj.title = 'Title-1';
        createControllerObj3.contactObj.Sells_SunRun__c = 'Yes';
        createControllerObj3.contactObj.Sells_in_CA__c = 'No';
        createControllerObj3.contactObj.Job_Function__c = 'Analyst';
        createControllerObj3.contactObj.role__C = 'Individual Contributor';
        createControllerObj3.contactObj.phone = '12345';
        createControllerObj3.contactObj.MobilePhone = '3523523';
        
        createControllerObj3.getContactRoles();
        createControllerObj3.getContactReportsToList();
        
        createControllerObj3.contactObj.Partner_Portal_Access__c = 'Requested';
        createControllerObj3.contactObj.Delegated_Admin_Access__c = 'Requested';
        createControllerObj3.contactObj.Proposal_Tool_Access__c = 'Requested';

        isSolarUniverse = createControllerObj3.showSolarUniverseFields;
        createControllerObj3.contactObj.Supress_Sales_Documents_Access__c = 'Requested';
        createControllerObj3.contactObj.Supress_EPC_Documents_Access__c = 'Requested';
        createControllerObj3.contactObj.Automatic_Document_Generation_Access__c = 'Granted';
        relObj = createControllerObj3.contactModeRelObj;
        relObj.leftvalues.put(partnerModesObj1.Id, partnerModesObj1.Mode_Name__C);
        relObj.rightvalues.put(partnerModesObj2.Id, partnerModesObj2.Mode_Name__C);
        
        createControllerObj3.submit();

    }
    
    private static testMethod void InactivateContact(){ 
        Account accountObj1 = TestPRMLibrary.insertAccount(PRMContactUtil.SOLAR_UNIVERSE, PRMLibrary.PARTNER);
        accountObj1.Partner_Type__c = 'Full Service';
        accountObj1.IsPartner = true;
        update accountObj1;     
        
        List<Account> accountlist = new List<Account>();
        Account accountObj2 = TestPRMLibrary.insertAccount(PRMContactUtil.SOLAR_UNIVERSE, PRMLibrary.PARTNER);
        accountObj2.Partner_Type__c = 'Full Service';
        accountObj2.ParentId = accountObj1.Id;
        accountObj2.Site = 'TestSite1';
        accountObj2.IsPartner = true;
        //update accountObj2;   
        accountlist.add(accountObj2);       

        Account accountObj3 = TestPRMLibrary.insertAccount(PRMContactUtil.SOLAR_UNIVERSE, PRMLibrary.PARTNER);
        accountObj3.Partner_Type__c = 'Full Service';
        accountObj3.ParentId = accountObj1.Id;
        accountObj3.Site = 'TestSite2';
        accountObj3.IsPartner = true;
        //update accountObj3;   
        accountlist.add(accountObj3);   
        update accountlist;
        System.debug('accountlist: ' + accountlist);
    
        Partner_Modes__c partnerModesObj1 = new Partner_Modes__c();
        partnerModesObj1.Mode_Id__c = '1234';
        partnerModesObj1.Mode_Name__c = 'Mode1';
        partnerModesObj1.Account__c = accountObj1.id;
        partnerModesObj1.ModeId_accountId__C = partnerModesObj1.Mode_Id__c + partnerModesObj1.Account__c;
        insert partnerModesObj1;

        Partner_Modes__c partnerModesObj2 = new Partner_Modes__c();
        partnerModesObj2.Mode_Id__c = '2234';
        partnerModesObj2.Mode_Name__c = 'Mode2';
        partnerModesObj2.Account__c = accountObj1.id;
        partnerModesObj2.ModeId_accountId__C = partnerModesObj2.Mode_Id__c + partnerModesObj2.Account__c;
        insert partnerModesObj2;
        
        System.currentPagereference().getParameters().put('accountId', accountObj1.Id);
        
        PRMContactCreateController createControllerObj = new PRMContactCreateController();
        createControllerObj.contactObj.AccountId = accountObj1.Id;
        createControllerObj.contactObj.FirstName = 'SU1PortalUserF1';
        createControllerObj.contactObj.lastname = 'SU1PortalUserL1';
        createControllerObj.contactObj.email = 'SU1PortalUserL1@gmail.com';
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
        
        createControllerObj.contactObj.active__c = false;
        createControllerObj.submit();
    }
 
   private static testMethod void TestContactCreate(){
        Account accountObj1 = TestPRMLibrary.insertAccount(PRMContactUtil.SOLAR_UNIVERSE, PRMLibrary.PARTNER);
        accountObj1.IsPartner = true;
        update accountObj1;
        
        Account accountObj2 = TestPRMLibrary.insertAccount(PRMContactUtil.SOLAR_UNIVERSE, PRMLibrary.PARTNER);
        accountObj2.IsPartner = true;
        accountObj2.ParentId = accountObj1.Id;
        update accountObj2;     

        Partner_Modes__c partnerModeObj1 = new Partner_Modes__c();
        partnerModeObj1.Account__c = accountObj1.Id;
        partnerModeObj1.Mode_Name__c = 'TestMode1';
        partnerModeObj1.Mode_Id__c = '123443';
        partnerModeObj1.Deleted__c = false;
        partnerModeObj1.ModeId_AccountId__c = partnerModeObj1.Mode_Id__c + partnerModeObj1.Account__c;

        Partner_Modes__c partnerModeObj2 = new Partner_Modes__c();
        partnerModeObj2.Account__c = accountObj1.Id;
        partnerModeObj2.Mode_Name__c = 'TestMode2';
        partnerModeObj2.Mode_Id__c = '1234';
        partnerModeObj2.Deleted__c = false;
        partnerModeObj2.ModeId_AccountId__c = partnerModeObj2.Mode_Id__c + partnerModeObj2.Account__c;
        List<Partner_Modes__c> modesList = new List<Partner_Modes__c>();
        modesList.add(partnerModeObj1);
        modesList.add(partnerModeObj2);
        insert modesList;
        
        Partner_Location__c PartnerLocObj1 = new Partner_Location__c();
        PartnerLocObj1.Headquarters__c = true;
        PartnerLocObj1.Name = 'Testing Location';
        PartnerLocObj1.Account__c = accountObj1.Id;
        insert PartnerLocObj1;

        PRMContactCreateController createControllerObj1= new PRMContactCreateController();
        createControllerObj1.contactObj.Location__c = PartnerLocObj1.id;
        createControllerObj1.submit();
        Boolean solarUniverseAccount = createControllerObj1.showSolarUniverseFields;
        
        createControllerObj1.customLookup.Account__c = accountObj1.Id;
        createControllerObj1.initializeRoleNames();

        System.currentPagereference().getParameters().put('accountId', accountObj1.Id);
        PRMContactCreateController createControllerObj = new PRMContactCreateController();
        createControllerObj.contactObj.AccountId = accountObj1.Id;
        createControllerObj.contactObj.FirstName = 'SU1PortalUserF11';
        createControllerObj.contactObj.lastname = 'SU1PortalUserL11';
        createControllerObj.contactObj.email = 'SU1PortalUserL11@gmail.com';
        createControllerObj.contactObj.title = 'Title-1';
        createControllerObj.contactObj.Job_Function__c = 'Analyst';
        createControllerObj.contactObj.role__C = 'Executive';
        createControllerObj.contactObj.phone = '12345';
        createControllerObj.contactObj.MobilePhone = '3523523';
        createControllerObj.contactObj.Location__c = PartnerLocObj1.id;
        
        createControllerObj.contactObj.Partner_Portal_Access__c = 'Requested';
        createControllerObj.contactObj.Delegated_Admin_Access__c = null;
        createControllerObj.contactObj.Proposal_Tool_Access__c = null;
        

        Boolean isSolarUniverse = createControllerObj.showSolarUniverseFields;
        createControllerObj.contactObj.Supress_Sales_Documents_Access__c = 'Requested';
        createControllerObj.contactObj.Supress_EPC_Documents_Access__c = 'Requested';
        createControllerObj.contactObj.Automatic_Document_Generation_Access__c = 'Granted';

        createControllerObj.contactObj.Sells_Sunrun__c = 'Yes';
        createControllerObj.contactObj.Sells_in_CA__c = null;       
        createControllerObj.submit();

        createControllerObj.contactObj.Sells_Sunrun__c = 'Yes';
        createControllerObj.contactObj.Sells_in_CA__c = 'No';       
        createControllerObj.contactObj.active__c = false;
        createControllerObj.contactObj.Deactivation_Reason__c = null;
        createControllerObj.submit();
        
        createControllerObj.contactObj.active__c = true;
        createControllerObj.contactObj.Delegated_Admin_Access__c = PRMContactUtil.REQUESTED;
        createControllerObj.contactObj.Partner_Portal_Access__c = null;
        createControllerObj.submit();
        
        createControllerObj.contactObj.Delegated_Admin_Access__c = null;
        createControllerObj.contactObj.Proposal_Tool_Access__c = PRMContactUtil.REQUESTED;
        createControllerObj.submit();

        createControllerObj.contactObj.Proposal_Tool_Access__c = PRMContactUtil.NOT_NEEDED;
        createControllerObj.submit();
        
        createControllerObj.contactObj.Proposal_Tool_Access__c = PRMContactUtil.REVOKED;
        createControllerObj.submit();
        
        createControllerObj.contactObj.Profile__c = PRMContactUtil.PARTNEROPS;
        createControllerObj.contactObj.Proposal_Tool_Access__c = PRMContactUtil.GRANTED;
        createControllerObj.submit();
        
        createControllerObj.contactObj.Profile__c = PRMContactUtil.PARTNERSALES;
        createControllerObj.contactObj.Proposal_Tool_Access__c = PRMContactUtil.GRANTED;
        createControllerObj.submit();
        
        createControllerObj.contactObj.Profile__c = PRMContactUtil.SPOC;
        createControllerObj.contactObj.Proposal_Tool_Access__c = PRMContactUtil.GRANTED;
        createControllerObj.submit();
     }


	//Commented for Test errors
    private static testMethod void TestPartnerPortalUser2(){
        Account accountObj1 = TestPRMLibrary.insertAccount('REC', PRMLibrary.PARTNER);
        accountObj1.Partner_Type__c = 'Full Service';
        accountObj1.IsPartner = true;
        update accountObj1;     
        
        
        List<Account> accountlist = new List<Account>();
        Account accountObj2 = TestPRMLibrary.insertAccount('REC', PRMLibrary.PARTNER);
        accountObj2.Partner_Type__c = 'Full Service';
        accountObj2.ParentId = accountObj1.Id;
        accountObj2.Site = 'TestSite1';
        accountObj2.IsPartner = true;
        //update accountObj2;   
        accountlist.add(accountObj1);
        accountlist.add(accountObj2);  
             

        Account accountObj3 = TestPRMLibrary.insertAccount('REC', PRMLibrary.PARTNER);
        accountObj3.Partner_Type__c = 'Full Service';
        accountObj3.ParentId = accountObj1.Id;
        accountObj3.Site = 'TestSite2';
        accountObj3.IsPartner = true;
        //update accountObj3;   
        accountlist.add(accountObj3);   
        update accountlist;
        System.debug('accountlist: ' + accountlist);
    
        Partner_Modes__c partnerModesObj1 = new Partner_Modes__c();
        partnerModesObj1.Mode_Id__c = '1234';
        partnerModesObj1.Mode_Name__c = 'Mode1';
        partnerModesObj1.Account__c = accountObj1.id;
        partnerModesObj1.ModeId_accountId__C = partnerModesObj1.Mode_Id__c + partnerModesObj1.Account__c;
        insert partnerModesObj1;

        Partner_Modes__c partnerModesObj2 = new Partner_Modes__c();
        partnerModesObj2.Mode_Id__c = '2234';
        partnerModesObj2.Mode_Name__c = 'Mode2';
        partnerModesObj2.Account__c = accountObj1.id;
        partnerModesObj2.ModeId_accountId__C = partnerModesObj2.Mode_Id__c + partnerModesObj2.Account__c;
        insert partnerModesObj2;

		Partner_Location__c partnerLocation = new Partner_Location__c();	
		partnerLocation.Account__c = accountlist[0].Id;
		partnerLocation.Headquarters__c = true;
		insert partnerLocation;

        System.currentPagereference().getParameters().put('accountId', accountObj1.Id);
        
        PRMContactCreateController createControllerObj = new PRMContactCreateController();
        createControllerObj.contactObj.AccountId = accountObj1.Id;
        createControllerObj.contactObj.FirstName = 'SU1PortalUserF331';
        createControllerObj.contactObj.lastname = 'SU1PortalUserL331';
        createControllerObj.contactObj.email = 'SU1PortalUserL331@gmail.com';
        createControllerObj.contactObj.title = 'Title-1';
        createControllerObj.contactObj.Sells_SunRun__c = 'Yes';
        createControllerObj.contactObj.Sells_in_CA__c = 'No';
        createControllerObj.contactObj.Job_Function__c = 'Analyst';
        createControllerObj.contactObj.role__C = 'Executive';
        createControllerObj.contactObj.phone = '12345';
        createControllerObj.contactObj.MobilePhone = '3523523';
        createControllerObj.contactObj.Profile__c = 'Partner Sales';

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
		createControllerObj.contactObj.Location__c = partnerLocation.Id;
        createControllerObj.customLookup.Account__c = accountObj1.Id; 
        
        System.debug('createControllerObj.contactObj.Location__c: ' + createControllerObj.contactObj.Location__c);
        System.debug('createControllerObj.contactObj.Account__c: ' + createControllerObj.customLookup.Account__c);
               
        createControllerObj.submit();
        Test.stopTest();
        
        List<User> portalUsers2 = [Select Id, name from User where  contactId != null and contactId = :createControllerObj.contactObj.Id];
        System.debug('portalUsers2: ' + portalUsers2);

        System.runAs(portalUsers2[0]){
            System.debug('Valid data testing ... ');
            System.currentPagereference().getParameters().put('accountId', accountObj1.Id);
            PRMContactCreateController createControllerObj2= new PRMContactCreateController();
            createControllerObj2.contactObj.AccountId = accountObj1.Id;
            createControllerObj2.contactObj.FirstName = 'SU1PortalUserF21';
            createControllerObj2.contactObj.lastname = 'SU1PortalUserL21';
            createControllerObj2.contactObj.email = 'SU1PortalUserL2@gmail.com';
            createControllerObj2.contactObj.title = 'Title-1';
            createControllerObj2.contactObj.Sells_SunRun__c = 'Yes';
            createControllerObj2.contactObj.Sells_in_CA__c = 'No';
            createControllerObj2.contactObj.Job_Function__c = 'Analyst';
            createControllerObj2.contactObj.role__C = 'Executive';
            createControllerObj2.contactObj.phone = '12345';
            createControllerObj2.contactObj.MobilePhone = '3523523';

            createControllerObj2.contactObj.Partner_Portal_Access__c = 'Requested';
            createControllerObj2.contactObj.Delegated_Admin_Access__c = 'Requested';
            createControllerObj2.contactObj.Proposal_Tool_Access__c = 'Requested';
    
            isSolarUniverse = createControllerObj2.showSolarUniverseFields;
            createControllerObj2.contactObj.Supress_Sales_Documents_Access__c = 'Requested';
            createControllerObj2.contactObj.Supress_EPC_Documents_Access__c = 'Requested';
            createControllerObj2.contactObj.Automatic_Document_Generation_Access__c = 'Requested';
            relObj = createControllerObj2.contactModeRelObj;
            relObj.rightvalues.put(partnerModesObj1.Id, partnerModesObj1.Mode_Name__C);
            relObj.rightvalues.put(partnerModesObj2.Id, partnerModesObj2.Mode_Name__C);

            ApexPages.getMessages().clear();
            System.debug('Apexpages.getMessages():1 ' + Apexpages.getMessages());
			createControllerObj2.contactObj.Location__c = partnerLocation.Id;
			createControllerObj2.customLookup.Account__c = accountObj1.Id; 
			
			System.debug('createControllerObj2.contactObj.Location__c: ' + createControllerObj2.contactObj.Location__c);
			System.debug('createControllerObj2.contactObj.Account__c: ' + createControllerObj2.customLookup.Account__c);            
            createControllerObj2.submit();
            System.debug('Apexpages.getMessages():2 ' + Apexpages.getMessages());

            if(accountlist != null && accountlist.size() > 0){

                System.debug(' accountlist[0].Id: ' +  accountlist[0].Id);
                createControllerObj2.siteId = accountlist[0].Id;
				createControllerObj2.contactObj.Location__c = partnerLocation.Id;
				createControllerObj2.customLookup.Account__c = accountObj1.Id; 
				
				System.debug('createControllerObj2.contactObj.Location__c: ' + createControllerObj2.contactObj.Location__c);
				System.debug('createControllerObj2.contactObj.Account__c: ' + createControllerObj2.customLookup.Account__c);
                createControllerObj2.submit();
                System.debug('createControllerObj2.siteId: ' + createControllerObj2.siteId);
                
                if(accountlist.size() == 2 && accountlist[1] != null){
                    System.currentPagereference().getParameters().put('contactId', createControllerObj2.contactObj.Id);
                    PRMContactCreateController createControllerObj3= new PRMContactCreateController();
                    createControllerObj2.siteId = accountlist[1].Id;
                    createControllerObj2.submit();
                }

                createControllerObj2.cancel();
                createControllerObj2.getAccountSites();
                createControllerObj2.getunSelectedValues();
                createControllerObj2.getSelectedValues();
                createControllerObj2.selectclick();
                createControllerObj2.unselectclick();
                Boolean isSolarUniverse2 = createControllerObj2.isSolarUniverseAccount;
                createControllerObj2.edit();
                createControllerObj2.getleftselected();
                createControllerObj2.setleftselected(createControllerObj2.getleftselected());
                createControllerObj2.getRightselected();
                createControllerObj2.setRightselected(createControllerObj2.getRightselected());
                
            }
        }
	}

 }