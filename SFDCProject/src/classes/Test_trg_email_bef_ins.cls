@isTest(SeeAllData=true)
public with sharing class Test_trg_email_bef_ins {
    static testMethod void Test_trg_email_bef_ins(){
        Test.StartTest();
             
             Recordtype r=[select id,name from recordtype where sobjecttype='Case' and Name = 'Partner Concierge'  limit 1];
             Case c = new Case(RecordTypeId=r.Id,Email_Address_of_Account_Manager__c = 'Test@yopmail.com');
             insert c;                        
             
             EmailMessage emsg = new EmailMessage(Parentid=c.id );    
               
             String accountManagerEmail ='Test@yopmail.com';
             emsg.textBody = String.valueOf(accountManagerEmail);
             emsg.CcAddress= '595 market street'; 
             insert emsg;
             Test.stoptest();
  
      }
}