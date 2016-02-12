@isTest(SeeAllData=true)
private class TestSendContactToNetExamTrigger
{
    static testMethod void validateSendContactToNetexamTrigger() {

    Account testAccount = new Account();
    testAccount.Name = 'TriggerAccount';
    testAccount.Type = 'Partner';
                      
    insert testAccount;     
    
    List<Account> objAccount = [Select ID FROM Account WHERE Name = 'TriggerAccount' LIMIT 1];
    String accountId = objAccount[0].ID;    
    
    RecordType rt = [select Id from RecordType where Name = 'Partner' AND SobjectType = 'Contact' LIMIT 1];        

    Contact testContact = new Contact();
    testContact.FirstName = 'NETrigger';
    testContact.LastName  = 'NESimpson';
    testContact.Email = 'triggerh@youremail.com';
    testContact.AccountId  = accountId;
    testContact.MailingStreet  = '123 Main Street';
    testContact.MailingCity = 'Beverly Hills';
    testContact.MailingState = 'CA';
    testContact.MailingPostalCode  = '90210';
    testContact.MailingCountry = 'United States';
    testContact.Job_Function__c = 'Sales Admin'; 
    testContact.Contact_Number__c = '00000001';
    testContact.active__c = True;        
    testContact.RecordTypeId = rt.Id; 
    testContact.Branch_Location__c = 'Dallas'; 
    testContact.Selling_States__c = 'Texas'; 
    testContact.Training__c = False; 
    testContact.Active_NetExam_User__c = False;
    
    test.startTest();
   
    insert testContact;    
    
    List<Contact> objContact = [Select Active_NetExam_User__c FROM Contact WHERE Email= 'triggerh@youremail.com' LIMIT 1];
    Boolean sentToNetExam = objContact[0].Active_NetExam_User__c;
    system.assertEquals(sentToNetExam,false);
     
          
    Contact testContactSend = new Contact();
    testContactSend.FirstName = 'NETrigger';
    testContactSend.LastName  = 'NESimpson';
    testContactSend.Email = 'triggerSend@youremail.com';
    testContactSend.AccountId  = accountId;
    testContactSend.MailingStreet  = '123 Main Street';
    testContactSend.MailingCity = 'Beverly Hills';
    testContactSend.MailingState = 'CA';
    testContactSend.MailingPostalCode  = '90210';
    testContactSend.MailingCountry = 'United States';
    testContactSend.Job_Function__c = 'Sales Admin'; 
    testContactSend.Contact_Number__c = '00000002';
    testContactSend.active__c = True;
    testContactSend.RecordTypeId = rt.Id; 
    testContactSend.Branch_Location__c = 'Dallas'; 
    testContactSend.Selling_States__c = 'Texas'; 
    testContactSend.Training__c = True;
    testContactSend.Active_NetExam_User__c = true;
    
    insert testContactSend; 
    
    List<Contact> objContactSent = [Select Active_NetExam_User__c FROM Contact WHERE Email= 'triggerSend@youremail.com' LIMIT 1];
    sentToNetExam = objContactSent[0].Active_NetExam_User__c;  
     
    test.stopTest();     
    system.assertEquals(sentToNetExam,true);     
     
     }

}