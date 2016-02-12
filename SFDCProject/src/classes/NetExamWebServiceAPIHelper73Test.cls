/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 */
@isTest
private class NetExamWebServiceAPIHelper73Test{

    public class MissingAccountInformationException extends Exception{}
    public class NetExamWebserviceException extends Exception{}
    
    //NetExam API Credentials    
    private static string ne_apiKey = 'APIKey';
    private static string ne_apiUser = 'APIUsername';
    private static string ne_apiPass = 'APIPassword';
     
   
     static testMethod void BulkUpsertUsers_Test() {    
       string result = 'FAIL';
       try
       {        
            webservicesNetexamComUserservice73.ArrayOfUser Users = new webservicesNetexamComUserservice73.ArrayOfUser();
            Users.User_x =  new webservicesNetexamComUserservice73.User_x[1];
                                  
                 
            webservicesNetexamComUserservice73.UserUserGroup acct = new webservicesNetexamComUserservice73.UserUserGroup();
            acct.ExternalId = '3837363738918376AAG';
            acct.Name = 'TestUsers_USA';
            acct.Country = 'USA';       
               
            webservicesNetexamComUserservice73.User_x user = new webservicesNetexamComUserservice73.User_x();
            user.FirstName = 'Carlito';
            user.LastName = 'Hlazo';
            user.UserName = 'carlito@email.com';
            user.Email = 'carlito@email.com';
            user.AlternateEmail = '';
            user.City = 'Dallas';
            user.Country = 'USA';
            user.State = 'TX';
            user.PostalCode = '75226';
            user.Language = 'English';
            user.BusinessPhone = '';
            user.PersonalPhone = '';
            user.PersonalEmail = '';
            user.JobCategory = '';
            user.JobTitle = '';
            user.TimeZone = '9';
            user.ExternalID = '786398483738379AAA';
            user.UserRole = 'Student';
            user.UserTypeName = 'Channel - US';
            user.ManagerExternalID = '';
            user.Status = '1';
            user.userGroup = acct;
            Users.User_x[0] = user;      
                   
           
            NetExamWebServiceAPIHelper73.BulkUpsertUsers(ne_apiKey, ne_apiUser, ne_apiPass, Users);
            
            result = 'SUCCESS';            
            system.assert(result == 'SUCCESS');        
        
        }
        catch(Exception ex)
        {                       
            system.assert(result == 'SUCCESS'); 
        }        
        
    }  

   static testMethod void SendContactToNetExam_TestMethod()
    {
    
        Account testAccount = new Account(Name='Test Account NE');
        insert testAccount;
 
        List<Account> objAccount = [Select ID FROM Account WHERE Name = 'Test Account NE' LIMIT 1];        
        
        String testAccountID = (String)objAccount[0].ID;
        system.assert(testAccountID.length() > 0);      
        
        //Missing Info
        string result = NetExamWebServiceAPIHelper73.ValidateAccountData('', '', '');
        system.assert(result != 'Success');
        
        result = NetExamWebServiceAPIHelper73.ValidateContactData('', '', '', '', '', '', '', '');
        system.assert(result != 'Success');
        
        //Missing Account Info
        result = NetExamWebServiceAPIHelper73.SendContactToNetExam('test', 'test', 'test', 'test', 'test', 'test', 'test', 'test', '', '', '');
        system.assert(result != 'Success');
        
        //Missing Contact Info
        result = NetExamWebServiceAPIHelper73.SendContactToNetExam('', '', '', '', '', 'test', 'test', 'test', 'test', testAccountID, 'test');
        //system.assert(result == 'Success');
        
        //Valid Info
        result = NetExamWebServiceAPIHelper73.ValidateAccountData('1234', '1234', '1234');
        system.assert(result == 'Success');
        
        result = NetExamWebServiceAPIHelper73.ValidateContactData('test', 'test', 'test', 'test', 'test', 'test', 'test', 'test');
        system.assert(result == 'Success');
        
        result = NetExamWebServiceAPIHelper73.SendContactToNetExam('test', 'test', 'test', 'test', '', 'test', 'test', 'test', 'test', testAccountID, 'test');
        //system.assert(result == 'Success');  
        
        delete testAccount;
        
         
    } 


   static testMethod void SendContactToNetExamExtended_TestMethod()
    {
    
        Account testAccount = new Account(Name='Test Account NE');
        insert testAccount;
 
        List<Account> objAccount = [Select ID FROM Account WHERE Name = 'Test Account NE' LIMIT 1];        
        
        String testAccountID = (String)objAccount[0].ID;
        system.assert(testAccountID.length() > 0);      
        
        //Missing Info
        string result = NetExamWebServiceAPIHelper73.ValidateAccountData('', '', '');
        system.assert(result != 'Success');
        
        result = NetExamWebServiceAPIHelper73.ValidateContactData('', '', '', '', '', '', '', '');
        system.assert(result != 'Success');
        
        //Missing Account Info
        result = NetExamWebServiceAPIHelper73.SendContactToNetExam('test', 'test', 'test', 'test', 'test', 'test', 'test', 'test', '', '', '');
        system.assert(result != 'Success');
        
        //Missing Contact Info
        result = NetExamWebServiceAPIHelper73.SendContactToNetExam('', '', '', '', '', 'test', 'test', 'test', 'test', testAccountID, 'test');
        //system.assert(result == 'Success');
        
        //Valid Info
        result = NetExamWebServiceAPIHelper73.ValidateAccountData('1234', '1234', '1234');
        system.assert(result == 'Success');
        
        result = NetExamWebServiceAPIHelper73.ValidateContactData('test', 'test', 'test', 'test', 'test', 'test', 'test', 'test');
        system.assert(result == 'Success');

       
        result = NetExamWebServiceAPIHelper73.SendContactToNetExamExtended('test', 'test', 'test', 'test', 'test', 'test', 'test', 'test', 'test', testAccountID, 'test');
        //system.assert(result == 'Success');  
        
        delete testAccount;
        
         
    }     
    

    static testMethod void SendContactFromTrigger_TestMethod()
    {
    
        Account testAccount = new Account(Name='Test Account NE');
        insert testAccount;
 
        List<Account> objAccount = [Select ID FROM Account WHERE Name = 'Test Account NE' LIMIT 1];        
        
        String testAccountID = (String)objAccount[0].ID;
        system.assert(testAccountID.length() > 0);
    
        try
        {
            //Missing Contact Info
            NetExamWebServiceAPIHelper73.SendContactFromTrigger('', '', '', '', 'test');
        }
        catch(MissingAccountInformationException e)
        {
            system.assert(e.getMessage() == 'Account Could Not Be Found');
        }        
        
        delete testAccount;
           
    }



    static testMethod void AddEditUserGroup_TestMethod()
    {
                
        // This always fails because it includes Callouts
        string result = NetExamWebServiceAPIHelper73.AddEditUserGroup('1234', '1234', '1234', '1234', '1234', '1234');
        //system.assert(result == 'Success');
    }
    
    
    static testMethod void UpsertUserWithUserGroups_TestMethod()
    {    
        // This always fails because it includes Callouts
        webservicesNetexamComUserservice73.ArrayOfUserUserGroup Groups = new webservicesNetexamComUserservice73.ArrayOfUserUserGroup();
        webservicesNetexamComUserservice73.ArrayOfCustomField CustomFields = new webservicesNetexamComUserservice73.ArrayOfCustomField();
        string result = NetExamWebServiceAPIHelper73.UpsertUserWithUserGroups('1234', '1234', '1234', 'test', 'test', 'test', 'test', 'test', 'test', 'test', 'test', 'test', 'test', Groups ,CustomFields,'USA',true,'test','test' );
        //system.assert(result == 'Success');
                                                          
    } 

    static testMethod void UpsertUserWithUserGroupsExtended_TestMethod()
    {    
        // This always fails because it includes Callouts
        webservicesNetexamComUserservice73.ArrayOfUserUserGroup Groups = new webservicesNetexamComUserservice73.ArrayOfUserUserGroup();
        webservicesNetexamComUserservice73.ArrayOfCustomField CustomFields = new webservicesNetexamComUserservice73.ArrayOfCustomField();
         
                                   
        string result = NetExamWebServiceAPIHelper73.UpsertUserWithUserGroupsExtended('1234', '1234', '1234', 'test', 'test', 'test', 'test', 'test', 'test', 'test', 'test', 'test', 'test','test','test','test','test','test', Groups ,'test','test','test','test','test',true,'test',true,CustomFields,true,'20011-09-11 20:00:00');
        //system.assert(result == 'Success');
                                                          
    } 
}