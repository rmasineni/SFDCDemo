trigger sendContactToNetexam on Contact (after insert, after update) { 

    if(system.isFuture()) return;
    
    if(Test.isRunningTest() && UserInfo.getName() == 'MyTestUserAlias') return;
    
    //NetExamUserServiceAPI connector = new NetExamUserServiceAPI();
    public class MissingAccountInformationException extends Exception{}
    public class MissingFirstNameException extends Exception{}    
    public class MissingLastNameException extends Exception{}  
    public class MissingEmailException extends Exception{}   
    
 Boolean skipValidations = false;
 skipValidations = SkipTriggerValidation.performTriggerValidations();
 if(skipValidations == false){   
    
    if(controlContactTriggerRecursion.ControlNetExamTrigger)
    {
        
        controlContactTriggerRecursion.ControlNetExamTrigger = false;    
        
      
        Set<Id> contactIds = new Set<Id>();
    
        for(Contact myContact : Trigger.new){    
                
              if(myContact.Training__c == true)
              {
                  if((myContact.contact_Type__c != null) || (myContact.contact_Type__c != PRMLibrary.PARTNER))
                      contactIds.add(myContact.Id);
              }
        }
        
        if(contactIds.size() > 0)
        {
               NetExamWebServiceAPIHelper81.SendContactListToNetExam(contactIds);
        }
    }

  }
}