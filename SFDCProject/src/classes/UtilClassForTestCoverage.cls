@isTest

public class UtilClassForTestCoverage

{
 
    //Method to create Account Record

    public static Account CreateAccount(String Name)

    {

       Account oAccount = new Account();

       oAccount.Name=Name;

       insert oAccount;

       return oAccount;

    }

    //Method to create Contact Record

    public static Contact createContact(String LastName,String Email, String Title,String Job_Function,String AmbassadorId,Id AccountId)

    {    

       Contact oContact = new Contact();

       oContact.LastName = LastName;   
       oContact.Email = Email; 
       oContact.Title = Title; 
       oContact.Job_Function__c= Job_Function;
       oContact.Ambassador__Ambassador_ID__c = AmbassadorID; 

       if(AccountId != null)   
       oContact.AccountId = AccountId;  
       insert oContact;  
       return oContact; 
    }
   
}