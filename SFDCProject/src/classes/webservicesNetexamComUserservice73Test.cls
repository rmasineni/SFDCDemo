/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 */
@isTest
private class webservicesNetexamComUserservice73Test{
    
    static webservicesNetexamComUserservice73 userService = new webservicesNetexamComUserservice73();
    
    //Instantiate the NetExam web service proxy
    static webservicesNetexamComUserservice73.UserServiceSoap ws = userService.GetUserServiceSoap();
    
    //Instantiate the Account API credentials. These will be supplied by NetExam
    static String APIKey= 'ApiKey';
    static String APIUsername='APIUsername';
    static String APIPassword='APIPassword'; 

     
    static testMethod void AddEditUserTest () {    
        
        //Create a test account    
        Account acct = new Account(name='Test Company Name');
        insert acct;

        //System.debug('account id: ' +  acct.Id);
        
        //Create a test contact
        Contact ct = new Contact(AccountId=acct.Id,lastname='Testing',firstname='Apex',email='testuser@myapexemail.com');
        insert ct;   
        
        String FirstName= ct.firstname;
        String LastName= ct.lastname;
        String UserExternalID= ct.Id;
        String Email= ct.email;
        String UserGroupExternalID=acct.Id;
        String Language='English';
        String Country = 'USA';
                
        // Invoke web service method
        String result = ws.AddEditUser(APIKey,APIUsername,APIPassword,FirstName,LastName,UserExternalID,Email,UserGroupExternalID,Language,Country);
        
        System.assert(result == 'SUCCESS');
        
        delete ct;
        delete acct;     
    } 

   static testMethod void AddEditUserGroupTest() {    
    
         //Create a test account    
        Account acct = new Account(name='Test Company Name');
        insert acct;
        
        String UserGroupName= acct.Name;
        String UserGroupExternalID=acct.Id;
        String Country='USA';
        
        String result = ws.AddEditUserGroup(APIKey,APIUsername,APIPassword,UserGroupName,UserGroupExternalID,Country);
        
        System.assert(result.length() > 0);
        
        delete acct;
        
    }

  static testMethod void GetTokenTest() {
    
        //Create a test account    
        Account acct = new Account(name='Test Company Name');
        insert acct;
        
        //Create a test contact
        Contact ct = new Contact(AccountId=acct.Id,lastname='Testing',firstname='Apex',email='testuser@myapexemail.com');
        insert ct; 
        
        String ExternalUserID=ct.Id;
        String FirstName=ct.firstname;
        String LastName=ct.lastname;
        String Email=ct.email;
        String Language='English';
        String UserType='Default';
        String UserRole='Student';
        String ManagersExternalID='';
        Boolean Active = True;
        String Country = 'USA';
        Boolean PreserveUserGroup = True;
        Boolean EmailOptIn = True;
        String SFDCUserId = '';
        String TimeZone = '';
        
        
        // Add account as primary user group
        webservicesNetexamComUserservice73.UserUserGroup PrimaryGroup = new webservicesNetexamComUserservice73.UserUserGroup();
        PrimaryGroup.Name = acct.name;
        PrimaryGroup.ExternalID = acct.Id;
        PrimaryGroup.IsPrimaryUserGroup = 1;
        PrimaryGroup.Country = 'USA';         
    
        // Create the array of user groups to send to NetExam. Only the PrimaryGroup is required.
        webservicesNetexamComUserservice73.ArrayOfUserUserGroup Groups = new webservicesNetexamComUserservice73.ArrayOfUserUserGroup();         
        Groups.UserUserGroup =  new webservicesNetexamComUserservice73.UserUserGroup[]{PrimaryGroup};
        
        webservicesNetexamComUserservice73.ArrayOfCustomField CustomFields = new webservicesNetexamComUserservice73.ArrayOfCustomField();
        CustomFields.CustomField=  new webservicesNetexamComUserservice73.CustomField[]{};
         
        webservicesNetexamComUserservice73.ApiResult result;                      
        result = ws.UpsertUserWithUserGroups(APIKey,APIUsername,APIPassword,ExternalUserID,FirstName,LastName,Email,Language,UserType,UserRole,ManagersExternalID,Groups,PreserveUserGroup,CustomFields,Active,Country,EmailOptIn,SFDCUserId,TimeZone);
             
        //webservicesNetexamComUserservice73.GetTokenResponse_element token; 
        String token = ws.GetToken(APIKey,APIUsername,APIPassword,ExternalUserID);
        
        
        System.assert(token.length() > 0);
        
        delete ct;
        delete acct;  
    
    }

  static testMethod void GetLoginTokenTest() {
    
         //Create a test account    
        Account acct = new Account(name='Test Company Name');
        insert acct;
        
        //Create a test contact
        Contact ct = new Contact(AccountId=acct.Id,lastname='Testing',firstname='Apex',email='testuser@myapexemail.com');
        insert ct; 
    
        String ExternalAccountID=acct.Id;
        String ExternalUserID=ct.Id;
        String FirstName=ct.firstname;
        String LastName=ct.lastname;
        String Email=ct.email;
        String Language='English';
        String CourseID='';
        
        String token = ws.GetLoginToken(APIKey,APIUsername,APIPassword,ExternalAccountID,ExternalUserID,FirstName,LastName,Email,Language,CourseID);
        
        System.assert(token.length() > 0);
    
        delete ct;
        delete acct;  
    
    }

  static testMethod void GetAdminLoginTokenTest() {
    
             //Create a test account    
        Account acct = new Account(name='Test Company Name');
        insert acct;
        
        //Create a test contact
        Contact ct = new Contact(AccountId=acct.Id,lastname='Testing',firstname='Apex',email='testuser@myapexemail.com');
        insert ct;
    
        String ExternalAccountID=acct.Id;    
        String FirstName=ct.firstname;
        String LastName=ct.lastname;
        String Email=ct.email;
        String ExternalUserID=ct.Id;
        String ContestID='';
        String CourseID='';       
        
        String token = ws.GetAdminLoginToken(APIKey,APIUsername,APIPassword,FirstName,LastName,Email,ExternalUserID,ContestID,CourseID);
        
        System.assert(token.length() > 0);
        
        delete ct;
        delete acct; 
    }

  static testMethod void UpsertUserTest() {
    
        //Create a test account    
        Account acct = new Account(name='Test Company Name');
        insert acct;
        
        //Create a test contact
        Contact ct = new Contact(AccountId=acct.Id,lastname='Testing',firstname='Apex',email='testuser@myapexemail.com');
        insert ct;        
               
        // Add account as primary user group
        webservicesNetexamComUserservice73.UserUserGroup PrimaryGroup = new webservicesNetexamComUserservice73.UserUserGroup();
        PrimaryGroup.Name = acct.name;
        PrimaryGroup.ExternalID = acct.Id;
        PrimaryGroup.IsPrimaryUserGroup = 1;
    PrimaryGroup.AccountManagerExternalID = '';         
    
       // Create the array of user groups to send to NetExam. Only the PrimaryGroup is required.
       webservicesNetexamComUserservice73.ArrayOfString Groups = new webservicesNetexamComUserservice73.ArrayOfString();         
       Groups.string_x =  new String[]{acct.name};
       
        webservicesNetexamComUserservice73.ArrayOfCustomField CustomFields = new webservicesNetexamComUserservice73.ArrayOfCustomField();
        CustomFields.CustomField=  new webservicesNetexamComUserservice73.CustomField[]{};
    
    
        String ExternalUserID=ct.Id;
        String FirstName=ct.firstname;
        String LastName=ct.lastname;
        String Email=ct.email;
        String Language='English';
        String UserType='Default';
        String UserRole='Student';
        String ManagersExternalID='';
        Boolean PreserveUserGroup = True;
        Boolean Active = True;
        String Country='USA';
        
        webservicesNetexamComUserservice73.ApiResult result;
        
       result = ws.UpsertUser(APIKey,APIUsername,APIPassword,ExternalUserID,FirstName,LastName,Email,Language,UserType,UserRole,ManagersExternalID,Groups,PreserveUserGroup,CustomFields,Active,Country);
       
       System.assert(result.Description == 'SUCCESS');
        
       delete ct;
       delete acct;
    }

  static testMethod void DeactivateUserByExternalIDTest() {
    
        //Create a test account    
        Account acct = new Account(name='Test Company Name');
        insert acct;
      
        //Create a test contact
        Contact ct = new Contact(AccountId=acct.Id,lastname='Testing',firstname='Apex',email='testuser@myapexemail.com');
        insert ct;
         
        String UserExternalID=ct.Id;
        
        webservicesNetexamComUserservice73.ApiResult result;
        result = ws.DeactivateUserByExternalID(APIKey,APIUsername,APIPassword,UserExternalID);
        
        System.assert(result.Description == 'SUCCESS');
        
        delete ct;
        delete acct;
        
    }

  static testMethod void ActivateUserByExternalIDTest() {
  
         //Create a test account    
         Account acct = new Account(name='Test Company Name');
         insert acct;
      
         //Create a test contact
         Contact ct = new Contact(AccountId=acct.Id,lastname='Testing',firstname='Apex',email='testuser@myapexemail.com');
         insert ct;
         
        String ExternalUserID=ct.Id; 
        
        webservicesNetexamComUserservice73.ApiResult result; 
        
        result = ws.ActivateUserByExternalID(APIKey,APIUsername,APIPassword,ExternalUserID);
        
         System.assert(result.Description == 'SUCCESS');
        
        delete ct;
        delete acct;
    
    }

  
  static testMethod void UpsertUserWithUserGroupsTest(){
    
        //Create a test account    
        Account acct = new Account(name='Test Company Name');
        insert acct;
        
        //Create a test contact
        Contact ct = new Contact(AccountId=acct.Id,lastname='Testing',firstname='Apex',email='testuser@myapexemail.com');
        insert ct; 
        
        String ExternalUserID=ct.Id;
        String FirstName=ct.firstname;
        String LastName=ct.lastname;
        String Email=ct.email;
        String Language='English';
        String UserType='Default';
        String UserRole='Student';
        String ManagersExternalID='';
        Boolean Active = True;
        String Country = 'USA'; 
        Boolean EmailOptIn = True;
        String SFDCUserID = '005367348378kdl';
        Boolean PreserveUserGroup = True;
        String TimeZone = '';
        
        
        // Add account as primary user group
        webservicesNetexamComUserservice73.UserUserGroup PrimaryGroup = new webservicesNetexamComUserservice73.UserUserGroup();
        PrimaryGroup.Name = acct.name;
        PrimaryGroup.ExternalID = acct.Id;
        PrimaryGroup.IsPrimaryUserGroup = 1; 
        PrimaryGroup.Country = 'USA'; 
        PrimaryGroup.AccountManagerExternalID = '';       

        // Create the array of user groups to send to NetExam. Only the PrimaryGroup is required.
        webservicesNetexamComUserservice73.ArrayOfUserUserGroup Groups = new webservicesNetexamComUserservice73.ArrayOfUserUserGroup();         
        Groups.UserUserGroup =  new webservicesNetexamComUserservice73.UserUserGroup[]{PrimaryGroup};
        
        webservicesNetexamComUserservice73.ArrayOfCustomField CustomFields = new webservicesNetexamComUserservice73.ArrayOfCustomField();
        CustomFields.CustomField=  new webservicesNetexamComUserservice73.CustomField[]{};
         
        webservicesNetexamComUserservice73.ApiResult result; 
        result = ws.UpsertUserWithUserGroups(APIKey,APIUsername,APIPassword,ExternalUserID,FirstName,LastName,Email,Language,UserType,UserRole,ManagersExternalID,Groups,PreserveUserGroup,CustomFields,Active,Country,EmailOptIn,SFDCUserId,TimeZone);
        //result = ws.UpsertUserWithUserGroups(APIKey,APIUsername,APIPassword,ExternalUserID,FirstName,LastName,Email,Language,UserType,UserRole,ManagersExternalID,Groups,PreserveUserGroup,CustomFields,Active,Country,EmailOptIn,SFDCUserID,TimeZone);
        
        System.assert(result.Description == 'SUCCESS');
        delete ct;
        delete acct;
        
    }

  static testMethod void UpsertUserWithUserGroupsExtendedTest(){
    
        //Create a test account    
        Account acct = new Account(name='Test Company Name');
        insert acct;
        
        //Create a test contact
        Contact ct = new Contact(AccountId=acct.Id,lastname='Testing',firstname='Apex',email='testuser@myapexemail.com');
        insert ct; 
        
        String ExternalUserID=ct.Id;
        String FirstName=ct.firstname;
        String LastName=ct.lastname;
        String Email=ct.email;
        String Language='English';
        String UserType='Default';
        String UserRole='Student';
        String ManagersExternalID='';
        Boolean UserActive = True;
        String Country = 'USA'; 
        Boolean EmailOptIn = True;
        String SFDCUserID = '005367348378kdl';
        Boolean PreserveUserGroup = True;
    String TimeZone = '';
    String UserName = '';
    String BusinessPhone = '';
    String PersonalEmail='';
    String Address1 = '';
    String Address2 = '';
    String City = '';
    String State = '';
    String PostalCode = '';
    String JobCategory = '';
    String JobTitle = '';
    String StartDate = '';
    
        
        
        // Add account as primary user group
        webservicesNetexamComUserservice73.UserUserGroup PrimaryGroup = new webservicesNetexamComUserservice73.UserUserGroup();
        PrimaryGroup.Name = acct.name;
        PrimaryGroup.ExternalID = acct.Id;
        PrimaryGroup.IsPrimaryUserGroup = 1; 
        PrimaryGroup.Country = 'USA'; 
        PrimaryGroup.AccountManagerExternalID = '';       

        // Create the array of user groups to send to NetExam. Only the PrimaryGroup is required.
        webservicesNetexamComUserservice73.ArrayOfUserUserGroup Groups = new webservicesNetexamComUserservice73.ArrayOfUserUserGroup();         
        Groups.UserUserGroup =  new webservicesNetexamComUserservice73.UserUserGroup[]{PrimaryGroup};
        
        webservicesNetexamComUserservice73.ArrayOfCustomField CustomFields = new webservicesNetexamComUserservice73.ArrayOfCustomField();
        CustomFields.CustomField=  new webservicesNetexamComUserservice73.CustomField[]{};
         
        webservicesNetexamComUserservice73.ApiResult result; 

    result = ws.UpsertUserWithUserGroupsExtended(APIKey,APIUsername,APIPassword,FirstName,LastName,UserName,UserRole,Email,BusinessPhone,PersonalEmail,Address1,Address2,City,State,TimeZone,PostalCode,Country,Language,Groups,JobCategory,JobTitle,UserType,ExternalUserID,SFDCUserId,UserActive,ManagersExternalID,PreserveUserGroup,customFields,EmailOptIn,StartDate);
        
        System.assert(result.Description == 'SUCCESS');
        delete ct;
        delete acct;
        
    }

  static testMethod void BulkUpsertUsersTest() {    
    
         //Create a test account    
         Account acct = new Account(name='Test Company Name');
         insert acct;
    
         //Account for User 1
         webservicesNetexamComUserservice73.UserUserGroup Account1 = new webservicesNetexamComUserservice73.UserUserGroup();
         Account1.ExternalID = acct.Id;
         Account1.Name = acct.Name;
         Account1.Country = 'USA';
    
          
         //Create a test contact
         Contact ct = new Contact(AccountId=acct.Id,lastname='Testing',firstname='Apex',email='testuser@myapexemail.com');
         insert ct;
    
        //User 1
        webservicesNetexamComUserservice73.User_x user1 = new webservicesNetexamComUserservice73.User_x();
        user1.FirstName = ct.firstname;
        user1.LastName = ct.lastname;
        user1.UserName = ct.email;
        user1.Email = ct.email;
        user1.AlternateEmail = '';
        user1.City = 'Brooklyn';
        user1.Country = 'USA';
        user1.State = 'NY';
        user1.PostalCode = '11211';
        user1.Language = 'English';
        user1.BusinessPhone = '';
        user1.PersonalPhone = '';
        user1.PersonalEmail = '';
        user1.JobCategory = '';
        user1.JobTitle = '';
        user1.TimeZone = '9';
        user1.ExternalID =ct.Id;
        user1.UserRole = 'Student';
        user1.UserTypeName = 'Default';
        user1.ManagerExternalID = '';
        user1.Status = '1';
        user1.userGroup = Account1;   
    
        //Create a test contact
        Contact ct2 = new Contact(AccountId=acct.Id,lastname='Testing2',firstname='Apex2',email='testuser2@myapexemail.com');
        insert ct2;
    
        //User 2
        webservicesNetexamComUserservice73.User_x user2 = new webservicesNetexamComUserservice73.User_x();
        user2.FirstName = ct2.firstname;
        user2.LastName = ct2.lastname;
        user2.UserName = ct2.email;
        user2.Email = ct2.email;
        user2.AlternateEmail = '';
        user2.City = 'Paris';
        user2.Country = 'France';
        user2.State = '';
        user2.PostalCode = 'PR 00Cx2';
        user2.Language = 'French';
        user2.BusinessPhone = '';
        user2.PersonalPhone = '';
        user2.PersonalEmail = '';
        user2.JobCategory = '';
        user2.JobTitle = '';
        user2.TimeZone = '9';
        user2.ExternalID =ct2.Id;
        user2.UserRole = 'Student';
        user2.UserTypeName = 'Default';
        user2.ManagerExternalID = '';
        user2.Status = '1';
        user2.userGroup = Account1;
    
        
        // Create the array of User to send to NetExam.
        webservicesNetexamComUserservice73.ArrayOfUser Users = new webservicesNetexamComUserservice73.ArrayOfUser();         
        Users.User_x =  new webservicesNetexamComUserservice73.User_x[]{user1,user2};     
    
        webservicesNetexamComUserservice73.ApiResult apiResult = ws.BulkUpsertUsers(APIKey,APIUsername,APIPassword,Users);
        
        System.assert(apiResult.Description == 'SUCCESS');
        
        delete ct;
        delete ct2;
        delete acct;
    
    
    }    
    
}