/***
Class to deactivate the User cred of the terminated employee
Date: 11/20/2015 IST
***/

global class Employee_MasterBatch implements Database.Batchable<sObject>{

    //Querying the list of terminated employees whose User cred needs to be deactivated
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT EMAIL_ADDRESS__c FROM Employee_Master__c WHERE Deactivate__c ='TRUE']);
    }


    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        //Business logic to fetch the <name> of the employee
        
        List<Employee_Master__c> Employee_MasterEmail = (List<sObject>)scope;
        List<String> emailList = new List<String>();
        String email;
        if(Employee_MasterEmail!= null && Employee_MasterEmail.size() > 0) 
        {
            for(Employee_Master__c EM:Employee_MasterEmail)
            {
                email = EM.EMAIL_ADDRESS__c;
                emailList.add(email.substringBefore('@'));
                
            }
        }
        
        //Querying the Active users 
        
        List<User> activeUsers = [Select Username From User Where IsActive = TRUE];
        List<User> toBeDeactivatedUsers = new List<User>();
        String username;
        if(activeUsers!= null && activeUsers.size() > 0)
        {
            for(User usr: activeUsers)
            {
                if(emailList!= null && emailList.size() > 0)
                {
                    for(String empEmail: emailList)
                    {
                        username = usr.Username;
                        
                        //Comparing the Username with <name>@sunrun.com or <name>@sunrunhome.com
                        
                        if((username.equalsIgnoreCase(empEmail+'@sunrun.com'))||(username.equalsIgnoreCase(empEmail+'@sunrunhome.com')))
                        {
                            usr.IsActive = false;
                            toBeDeactivatedUsers.add(usr);
                        }
                    }
                }
            }
        }
 
 
         //System.debug('emailListemailList: '+emailList);
         //System.debug('toBeDeactivatedUsers: '+toBeDeactivatedUsers);
        
        //Deactivating the filtered Users 
        
        update toBeDeactivatedUsers;
        try
        {
             update toBeDeactivatedUsers;
        } 
        catch (DMLException e)
        {
             for (User usr : toBeDeactivatedUsers) 
             {
                  usr.addError('There was a problem updating the Users');
             }
        } 
        
    }

    global void finish(Database.BatchableContext BC)
    {

    }

}