/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 */
@isTest
private class webservicesNetexamComUserservice81Test{
    
    static webservicesNetexamComUserservice81 userService = new webservicesNetexamComUserservice81();
    
    //Instantiate the NetExam web service proxy
    static webservicesNetexamComUserservice81.UserServiceSoap ws = userService.GetUserServiceSoap();
    
    //Instantiate the Account API credentials. These will be supplied by NetExam
    static String APIKey= 'ApiKey';
    static String APIUsername='APIUsername';
    static String APIPassword='APIPassword';  
  
  static testMethod void TestAPIMethods(){
      
      UpsertUserWithUserGroupsExtendedTest();
      BulkUpsertUserWithUserGroupsTest(); 
      GetBulkUpsertTransactionLog();     
  
  }
    
  private  static void UpsertUserWithUserGroupsExtendedTest(){
    
        //Create a test account    
        Account acct = new Account(name='Test Company Name', BillingCountry = 'United States');
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
        String SFDCUserID = '005367348381kdl';
        Boolean PreserveUserGroup = True;
        Boolean PreserveCustomFields = True;
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
        webservicesNetexamComUserservice81.UserUserGroup PrimaryGroup = new webservicesNetexamComUserservice81.UserUserGroup();
        PrimaryGroup.Name = acct.name;
        PrimaryGroup.ExternalID = acct.Id;
        PrimaryGroup.IsPrimaryUserGroup = 1; 
        PrimaryGroup.Country = 'USA'; 
        PrimaryGroup.AccountManagerExternalID = '';       

        // Create the array of user groups to send to NetExam. Only the PrimaryGroup is required.
        webservicesNetexamComUserservice81.ArrayOfUserUserGroup Groups = new webservicesNetexamComUserservice81.ArrayOfUserUserGroup();         
        Groups.UserUserGroup =  new webservicesNetexamComUserservice81.UserUserGroup[]{PrimaryGroup};
        
        webservicesNetexamComUserservice81.ArrayOfCustomField CustomFields = new webservicesNetexamComUserservice81.ArrayOfCustomField();
        CustomFields.CustomField=  new webservicesNetexamComUserservice81.CustomField[]{};
         
        webservicesNetexamComUserservice81.ApiResult result; 

        result = ws.UpsertUserWithUserGroupsExtended(APIKey,APIUsername,APIPassword,FirstName,LastName,UserName,UserRole,Email,BusinessPhone,PersonalEmail,Address1,Address2,City,State,TimeZone,PostalCode,Country,Language,Groups,JobCategory,JobTitle,UserType,ExternalUserID,SFDCUserId,UserActive,ManagersExternalID,PreserveUserGroup,PreserveCustomFields,customFields,EmailOptIn,StartDate);
        
        System.assert(result.Description == 'SUCCESS');
        delete ct;
        delete acct;
        
    }
  
    private static void BulkUpsertUserWithUserGroupsTest() {    
    
         //Create test account 1   
         Account acct = new Account(name='Test Company Name', BillingCountry = 'United States');
         insert acct;

         //Create test account 2
         Account acct2 = new Account(name='Test Company Name 2', BillingCountry = 'United States');
         insert acct2;


         webservicesNetexamComUserservice81.ArrayOfUserUserGroup Groups = new webservicesNetexamComUserservice81.ArrayOfUserUserGroup();         
         Groups.UserUserGroup =  new webservicesNetexamComUserservice81.UserUserGroup[2];
        
    
         //NE UserGroup 1 Instance
         webservicesNetexamComUserservice81.UserUserGroup Account1 = new webservicesNetexamComUserservice81.UserUserGroup();
         Account1.ExternalID = acct.Id;
         Account1.Name = acct.Name;
         Account1.Country = 'USA';
         Account1.IsPrimaryUserGroup = 1;

        //NE UserGroup 2 Instance
         webservicesNetexamComUserservice81.UserUserGroup Account2 = new webservicesNetexamComUserservice81.UserUserGroup();
         Account2.ExternalID = acct2.Id;
         Account2.Name = acct2.Name;
         Account2.Country = 'USA';
         Account2.IsPrimaryUserGroup = 0;
    
          
         //Create a test contact
         Contact ct = new Contact(AccountId=acct.Id,lastname='Testing',firstname='Apex',email='testuser@myapexemail.com');
         insert ct;
    
        //User 1
        webservicesNetexamComUserservice81.UserExtended user1 = new webservicesNetexamComUserservice81.UserExtended();
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
        user1.UserGroups = Groups;   
    
        //Create a test contact
        Contact ct2 = new Contact(AccountId=acct.Id,lastname='Testing2',firstname='Apex2',email='testuser2@myapexemail.com');
        insert ct2;
    
        //User 2
        webservicesNetexamComUserservice81.UserExtended user2 = new webservicesNetexamComUserservice81.UserExtended();
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
        user2.UserGroups = Groups;    
        
        // Create the array of User to send to NetExam.
        webservicesNetexamComUserservice81.ArrayOfUserExtended Users = new webservicesNetexamComUserservice81.ArrayOfUserExtended();         
        Users.UserExtended =  new webservicesNetexamComUserservice81.UserExtended[]{user1,user2};     
    
        webservicesNetexamComUserservice81.ApiResult apiResult = ws.BulkUpsertUsersWithUserGroups(APIKey,APIUsername,APIPassword,Users);
        
        System.assert(apiResult.Description == 'SUCCESS');
        
        delete ct;
        delete ct2;
        delete acct;
        delete acct2;
    
    
    } 
    
    private static void GetBulkUpsertTransactionLog()
    {
        Integer TransactionID = 111; 
        webservicesNetexamComUserservice81.ArrayOfBulkUploadTransaction arrResults = ws.GetBulkUpsertTransactionLog(APIKey,APIUsername,APIPassword,TransactionID);
        webservicesNetexamComUserservice81.BulkUploadTransaction[] arrTransactionResults = arrResults.BulkUploadTransaction;
               
        System.assert(arrTransactionResults.size() > 0);

    }
}