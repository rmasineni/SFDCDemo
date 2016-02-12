/***
Class to deactivate the User cred of the terminated employee
Date: 12/09/2015 IST
***/

Public class Employee_MasterDeactivatedUsers {

        //Constructor
        Public Employee_MasterDeactivatedUsers()
        {
            
        }
        
        //Method to deactivate the terminated Users
        public void DeactivatedUser() 
        {
            //Savepoint to Rollback the changes if the User updation fails
            System.Savepoint emSP = Database.setSavepoint();
            
            //List to capture the Users to be deactivated
            List<User> toBeDeactivatedUsers = new List<User>();
            
            //Business logic to fetch the <name> of the employee
            List<Employee_Master__c> Employee_MasterEmail = [SELECT EMAIL_ADDRESS__c FROM Employee_Master__c WHERE Deactivate__c ='TRUE'];

            //List to store the terminated employee email ID such that it can be used for comparing with the User ID
            List<String> emailList = new List<String>();
            String email;
            
            //Fetching the email ID of the terminated Users
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
            
            //Variable used to capture the Username
            String username;
            
            /*Method to match the terminated User Email ID and the Active Username of the Employee's. If match found, then capture the Users
            to be deactivated in a list*/
            
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
            
             //Deactivating the filtered Users 
            try
            {
                 //Update the User records to be deactivated
                 update toBeDeactivatedUsers;           
            } 
            catch (DMLException e)
            {
                  System.debug('The following exception has occurred while deactivating the Users: ' + e.getMessage());
                  //Rollback the changes in case of error
                  Database.rollback(emSP);    
            }   
    }  
 }