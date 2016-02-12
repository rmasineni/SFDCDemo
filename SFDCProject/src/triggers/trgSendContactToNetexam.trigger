trigger trgSendContactToNetexam on Contact (after insert, after update) { 
    
    //NetExamUserServiceAPI connector = new NetExamUserServiceAPI();
    public class MissingAccountInformationException extends Exception{}
    public class MissingFirstNameException extends Exception{}    
    public class MissingLastNameException extends Exception{}  
    public class MissingEmailException extends Exception{}  

 Boolean skipValidations = false;
 skipValidations = SkipTriggerValidation.performTriggerValidations();
    
  if(skipValidations == false){

    for(Contact myContact : Trigger.new){

        if((myContact.contact_Type__c == null) || (myContact.contact_Type__c != PRMLibrary.PARTNER))
            continue; 

        String firstName = '';
        String lastName = '';
        String email = '';
        String accountId = '';
        
        //Saving off to string vars so that we can safely do 
        firstName = (String)myContact.FirstName;
        lastName = (String)myContact.LastName;
        email = (String)myContact.Email;    
        accountId = (String)myContact.AccountId;
                          
         //Do data validation on all fields that will be an issue if they wait for the webservice        
        if(firstName == null)
        {    
            throw new MissingFirstNameException('First Name is required');
        }
        
        if(lastname == null)
        {    
            throw new MissingLastNameException('Last Name is required');
        }
        
     //   if(email == null)
     //   {    
     //       throw new MissingEmailException('Email is required');
     //   }
     
     //   if(accountId == null)
     //   {    
     //       throw new MissingAccountInformationException ('Contact is not associated with an account');
     //   }
        
        
         If(!Test.isRunningTest()){
                //Do not call future class from batch apex
                if(system.isFuture() == false && system.isBatch() == false)
                {
                    NetExamWebServiceAPIHelper73.SendContactFromTrigger(
                            myContact.Id, 
                            firstName, 
                            lastName, 
                            email,
                            accountId
                        );
                 }
            }           
        
       
                
    }

  }
}