@isTest
public class Test_InstallAuditExtensionController {

    public static testmethod void Test_InstallAuditExtensionController (){
    
        Profile p = [SELECT Id FROM Profile WHERE Name='Operations - Fleet Ops']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='test1231232@testorg1234.com');
                              
        //DataSetup  
        Account a = new Account(name='Test Acct1');
        insert a;
        
        Generation_Assets__c ga = new Generation_Assets__c(Account_Name__c=a.id, Name='99887' ); 
        insert ga;
        
        Install_Audit__c  ia = new Install_Audit__c();
        ia.Generation_Asset__c = ga.Id;
        insert ia;     
               
        System.RunAs(u)
        {
            //DataSetup        
            InstallAuditExtension iaTest = new InstallAuditExtension();
            iaTest.ia = ia;
            iaTest.strView = 'My Audits Last Week';
            iaTest.srchString = 'Test Search String';
            iaTest.srchType = 'SRH';
            iaTest.UserType = 'Auditor';
            iaTest.srchAudits();
            iaTest.UserType = 'Partner';
            iaTest.SortBySRH();
            iaTest.nextInstallAuditPage();
            iaTest.previousInstallAuditPage();
            System.assertEquals(iaTest.iaList.size(), 0);
            
            iaTest.strView = 'My Audits All Time';
            iaTest.srchString = 'Test Search String';
            iaTest.srchType = 'Address';
            iaTest.UserType = 'Auditor';
            iaTest.srchAudits();
            iaTest.UserType = 'Partner';
            iaTest.srchAudits();
            iaTest.SortByAddress();
            System.assertEquals(iaTest.iaList.size(), 0);        
            
            iaTest.strView = 'My Audits Last 30 Days';
            iaTest.srchString = 'Test Search String';
            iaTest.srchType = 'Name';
            iaTest.srchAudits(); 
            System.assertEquals(iaTest.iaList.size(), 0);
                    
            iaTest.strView = 'All Audits Last 30 Days';
            iaTest.srchString = 'Unassigned';
            iaTest.srchType = 'Status';
            iaTest.srchAudits();         
            iaTest.SortByStatus();
            System.assertEquals(iaTest.iaList.size(), 1);
                    
            iaTest.strView = 'All Audits Last 60 Days';
            iaTest.srchString = 'TestSearchString';
            iaTest.srchType = 'Audit Type';
            iaTest.srchAudits();
            iaTest.SortByAuditType(); 
                    
            iaTest.strView = 'All Audits Last 90 Days';
            iaTest.srchString = '99887';
            iaTest.srchType = 'SRH';
            iaTest.srchAudits();       
            //System.assertEquals(iaTest.iaList.size(), 1);
            
            iaTest.strView = 'All Audits All Time';
            iaTest.srchAudits();    
            //System.assertEquals(iaTest.iaList.size(), 1);
        }
    }
        
    public static testmethod void Test_InstallAuditExtensionControllerWithParamater (){
        Profile p = [SELECT Id FROM Profile WHERE Name='Operations - Fleet Ops']; 
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='test876655@testorg234533.com');    
        //DataSetup  
        Account a = new Account(name='Test Acct1', Partner_Type__c = 'Auditor');
        insert a;
        
        RecordType rt = [select Id, Name from RecordType Where Name = 'Partner' and SobjectType = 'Contact' limit 1];        
        Contact contactObj1 = TestPRMLibrary.insertContact('Test',
                                                            PRMLibrary.PARTNER, 
                                                            'TestLastName',
                                                            'testlastname223@gmail.comintdev');
        contactObj1.Contact_Type__c = 'Auditor';
        contactObj1.RecordType = rt;
        contactObj1.AccountId = a.Id;
        update contactObj1;        
  
        Generation_Assets__c ga = new Generation_Assets__c(Account_Name__c=a.id, Name='99887' ); 
        insert ga;
        Install_Audit__c  ia = new Install_Audit__c();
        ia.Generation_Asset__c = ga.Id;
        ia.Auditor_Account__c = a.Id;
        ia.Status__c = 'Unassigned';
        ia.Auditor_Contact__c = contactObj1.Id;
        insert ia;
        //System.RunAs(u)
        //{    

            System.AssertEquals('Unassigned', ia.Status__c);
                
            ApexPages.StandardController controller = new ApexPages.StandardController(ia);
            InstallAuditExtension iaTest2 = new InstallAuditExtension(controller);  
            iaTest2.getStatusReadOnly();
            //System.AssertEquals(2, iaTest2.getStatuses().size());
            iaTest2.showScorecard();
            iaTest2.getAuditors();
            iaTest2.uploadAuditPhotos();
            iaTest2.getAuditorAccountContacts();
            iaTest2.findContacts();
            System.AssertEquals(2, iaTest2.getStatuses().size());
            
            
            ia.Status__c = 'Assigned';
            iaTest2.saveInstallAudit();
            iaTest2.UserType = 'Auditor';
            System.AssertEquals(3, iaTest2.getStatuses().size());        
            iaTest2.getStatuses();
            iaTest2.UserType = 'Sunrun';
            System.AssertEquals(2, iaTest2.getStatuses().size());
            
    
            ia.Status__c = 'In Progress';
            iaTest2.saveInstallAudit();
            System.AssertEquals(2, iaTest2.getStatuses().size());
            
            ia.Status__c = 'Accepted';
            iaTest2.saveInstallAudit();
            System.AssertEquals(3, iaTest2.getStatuses().size());        
    
            ia.Status__c = 'Submitted';
            iaTest2.saveInstallAudit();
            iaTest2.UserType = 'Auditor';       
            iaTest2.getStatuses();
            System.AssertEquals(0, iaTest2.getStatuses().size());        
           
            iaTest2.UserType = 'Sunrun';
            iaTest2.getStatuses();        
            System.AssertEquals(3, iaTest2.getStatuses().size());        
    
            ia.Status__c = 'Denied';
            iaTest2.saveInstallAudit();
            iaTest2.getStatuses();
            
            ia.Status__c = 'SR Approved';
            iaTest2.saveInstallAudit();
            System.AssertEquals(1, iaTest2.getStatuses().size());  
            iaTest2.showScorecard();    
            iaTest2.UserType = 'Auditor';
            iaTest2.getStatusReadOnly();  
            
            ia.Status__c = 'Rejected';
            iaTest2.saveInstallAudit();
            iaTest2.UserType = 'Auditor';
            iaTest2.getStatuses();       
            
            iaTest2.UserType = 'Partner';
            iaTest2.getStatusReadOnly();
            iaTest2.UserType = 'Sunrun';
            iaTest2.getStatusReadOnly();   
        //}                
    }

    public static testmethod void Test_InstallAuditExtensionControllerUserTypes (){
        Profile p = [SELECT Id FROM Profile WHERE Name='Operations - Fleet Ops']; 
        User u = new User(Alias = 'standt3', Email='standarduser3@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing3', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='aaassseew@gghhtrdsse.com');    
        
        System.RunAs(u)
        {      
            //DataSetup  
            Account a = new Account(name='Test Acct1');
            insert a;
            Generation_Assets__c ga = new Generation_Assets__c(Account_Name__c=a.id, Name='99887' ); 
            insert ga;
            Install_Audit__c  ia = new Install_Audit__c();
            ia.Generation_Asset__c = ga.Id;
            ia.Auditor_Account__c = a.Id;
            insert ia;
                
            ApexPages.StandardController controller = new ApexPages.StandardController(ia);
            InstallAuditExtension iaTest3 = new InstallAuditExtension(controller); 
            
            iaTest3.getIsDenied();
            iaTest3.UserType = 'Auditor';
            System.AssertEquals(true, iaTest3.getIsAuditor());
            iaTest3.UserType = 'Sunrun';
            System.AssertEquals(true, iaTest3.getIsSunrun());
            iaTest3.UserType = 'Partner';
            System.AssertEquals(true, iaTest3.getIsPartner());   
        }                
    }    
       
    public static testmethod void Test_InstallAuditExtensionControllerSwitchAuditorAccounts (){
        Profile p = [SELECT Id FROM Profile WHERE Name='Operations - Fleet Ops']; 
        User u = new User(Alias = 'standt4', Email='standarduser4@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing4', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='vvvvvv@xxxxxbbv.com');    
        
        //DataSetup  
        List<Account> accounts = new List<Account>();
        Account a = new Account(name='Test Acct1');        
        Account a2 = new Account(name='Test Acct2');
        accounts.add(a);
        accounts.add(a2);
        insert accounts;        
            
        RecordType rt = [select Id, Name from RecordType Where Name = 'Partner' and SobjectType = 'Contact' limit 1];        
        Contact contactObj1 = TestPRMLibrary.insertContact('Test',
                                                           PRMLibrary.PARTNER, 
                                                           'TestLastName',
                                                           'testlastname223@gmail.comintdev');
         contactObj1.Contact_Type__c = 'Auditor';
         contactObj1.RecordType = rt;
         contactObj1.AccountId = a.Id;
         update contactObj1;
            
         Contact contactObj2 = TestPRMLibrary.insertContact('Test2',
                                                            PRMLibrary.PARTNER, 
                                                            'TestLastName2',
                                                            'testlastname2232222@gmail.comintdev');
         contactObj2.Contact_Type__c = 'Auditor';
         contactObj2.RecordType = rt;
         contactObj2.AccountId = a2.Id;
         update contactObj2;       
            
         Profile pf = [SELECT Id FROM profile WHERE name='Partner - Read/Write' limit 1]; 
         List<User> users = new List<User>();
         User mockUser = new User(title='test auditor',
                                  username=contactObj1.Email, 
                                  firstname=contactObj1.FirstName,
                                  lastname=contactObj1.LastName, 
                                  email=contactObj1.Email,
                                  contactId=contactObj1.Id,
                                  communityNickname = contactObj1.LastName,
                                  alias = string.valueof(contactObj1.FirstName.substring(0,1)), 
                                  profileid = pf.Id, emailencodingkey='UTF-8',
                                  languagelocalekey='en_US', 
                                  localesidkey='en_US', 
                                  timezonesidkey='America/Los_Angeles');                  
         users.add(mockUser);
             
         User mockUser2 = new User(title='test auditor',
                                   username=contactObj2.Email, 
                                   firstname=contactObj2.FirstName,
                                   lastname=contactObj2.LastName, 
                                   email=contactObj2.Email,
                                   contactId=contactObj2.Id,
                                   communityNickname = contactObj2.LastName,
                                   alias = string.valueof(contactObj2.FirstName.substring(0,1)), 
                                   profileid = pf.Id, emailencodingkey='UTF-8',
                                   languagelocalekey='en_US', 
                                   localesidkey='en_US', 
                                   timezonesidkey='America/Los_Angeles');      
         users.add(mockUser2);
         insert users;                    
            
         Generation_Assets__c ga = new Generation_Assets__c(Account_Name__c=a.id, Name='99887' ); 
         insert ga;
         Install_Audit__c  ia = new Install_Audit__c();
         ia.Generation_Asset__c = ga.Id;
         ia.Auditor_Account__c = a.Id;
         insert ia;
                       
         ia.Auditor_Account__c = a2.Id;
         update ia;                
    }        
       
   /* public static testmethod void Test_InstallAuditExtensionControllerAuditorUser (){
        Contact contactObj1 = TestPRMLibrary.insertContact('Test',
                                                            PRMLibrary.PARTNER, 
                                                            'TestLastName',
                                                            'test@gmail.comintdev');
        RecordType rt = [select Id, Name from RecordType Where Name = 'Partner' and SobjectType = 'Contact' limit 1];        
        contactObj1.Contact_Type__c = 'Auditor';
        contactObj1.RecordType = rt;
        update contactObj1;

        Account accountObj1 = TestPRMLibrary.insertAccount('PRMPartnerAccount2', PRMLibrary.PARTNER);
        accountObj1.IsPartner = true;
        accountObj1.ParentId = contactObj1.AccountId;
        accountObj1.Partner_Type__c = 'Auditor';
        update accountObj1; 
      
        AccountContactRole acr1 = new AccountContactRole(AccountId = accountObj1.Id);
        acr1.ContactId = contactObj1.Id;
        acr1.Role = 'Test 1';
        insert acr1;
        
        Profile pf = [SELECT Id FROM profile WHERE name='Partner - Read/Write' limit 1]; 
        User mockUser = new User(title='test auditor',
                            username=contactObj1.Email, 
                            firstname=contactObj1.FirstName,
                            lastname=contactObj1.LastName, 
                            email=contactObj1.Email,
                            contactId=contactObj1.Id,
                            communityNickname = contactObj1.LastName,
                            alias = string.valueof(contactObj1.FirstName.substring(0,1)), 
                            profileid = pf.Id, emailencodingkey='UTF-8',
                            languagelocalekey='en_US', 
                            localesidkey='en_US', 
                            timezonesidkey='America/Los_Angeles');                  
         insert mockUser;  
         
         //tried this as well to see if I could get access in the runas.
         ContactShare share = new ContactShare(); 
         share.ContactId = contactObj1.Id;
         share.UserOrGroupId = mockUser.Id;
         share.ContactAccessLevel = 'Read';
         Database.insert(share,false);
                       
         List<Contact> testContactsSize = [select Id from contact];
         System.AssertEquals(testContactsSize.size(), 1);
         
         System.runAs(mockUser){                          
             List<Contact> contact = [select id from Contact limit 1];
             System.AssertEquals(1, contact.size());
        }

    
    }*/

}