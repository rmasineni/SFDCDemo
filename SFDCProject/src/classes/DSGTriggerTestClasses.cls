/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class DSGTriggerTestClasses {

    public static testMethod void referralTest()
    {
	 	Test.startTest();
	 	
        Account accountRec = new Account();
        accountRec.Name = 'Test Class';
        insert accountRec;
 
 	    Contact contactRec = new Contact();
        contactRec.FirstName = 'DSG';
        contactRec.LastName = 'Test';
        contactRec.AccountId = accountRec.Id;
        insert contactRec;
     
        Account accountRec2 = new Account();
        accountRec2.Name = 'Test Class 2';
        accountRec2.Referred_by__c = accountRec.Id; 
        insert accountRec2;

 	    Contact contactRec2 = new Contact();
        contactRec2.FirstName = 'DSG';
        contactRec2.LastName = 'Test-2';
        contactRec2.AccountId = accountRec2.Id;
        insert contactRec2;
     
 		Account[]  acctList = [Select Id, Referred_by__c From Account Where Referred_by__c != null Limit 1];

     	Generation_Assets__c genAssetRec = new Generation_Assets__c();
     	genAssetRec.Account_Name__c = acctList[0].Referred_by__c;
     	genAssetRec.Customer_Contact__c = contactRec.Id;
     	genAssetRec.Name = 'DSG Test';
     	genAssetRec.Home_Address__c = '123 Main Street';
     	genAssetRec.City__c = 'Los Gatos';
     	genAssetRec.Zip__c = '95032';
     	genAssetRec.Upfront_Payment_Amount__c = 2000.00;
     	insert genAssetRec;

     	Generation_Assets__c genAssetRec2 = new Generation_Assets__c();
     	genAssetRec2.Account_Name__c = acctList[0].Id;
     	genAssetRec2.Customer_Contact__c = contactRec2.Id;
     	genAssetRec2.Name = 'DSG Test-2';
     	genAssetRec2.Home_Address__c = '123 Main Street';
     	genAssetRec2.City__c = 'Los Gatos';
     	genAssetRec2.Zip__c = '95032';
     	insert genAssetRec2;
		genAssetRec2.Meter_Serial_Num__c = 'Test1244ABC12345';
		genAssetRec2.Meter_Test_Date__c = date.today(); 
 		genAssetRec2.PTO__c = date.today();
 		update genAssetRec2;
 		
 		
    }
    
    public static testMethod void testTask()
    {
        //Account acc = new Account(Name = 'ac1');            
        //insert acc;
       Test.startTest(); 
        case c = new Case(Status = 'Pending External',Priority = 'Medium',First_Response_Updated__c = false);        
        insert c; 
         case c1 = new Case(Status = 'Pending External',Priority = 'Medium',First_Response_Updated__c = true);        
        insert c1;
   		Task tsk = new Task();
 		//tsk.AccountId = acc.Id;
 		tsk.Activity_Channel__c = 'Call Outbound';
 		tsk.WhatId = c.Id; 
 		tsk.Status = 'Not Started';
 		tsk.Priority = 'Normal';
 		tsk.Subject = 'Call';
 		tsk.WhoId = c1.OwnerId;
 		insert tsk;
 		Task tsk2 = new Task();
 		//tsk.AccountId = acc.Id;
 		tsk2.Activity_Channel__c = 'Snail-Mail';
 		tsk2.Status = 'Not Started';
 		tsk2.Priority = 'Normal';
 		tsk2.Subject = 'Send Letter';
 		tsk2.WhoId = c1.OwnerId;
 		tsk2.WhatId = c1.Id; 
 		insert tsk2;
    	Test.stopTest();
           
  	}
  	public static testMethod void testEmail()
    {
        //Account acc = new Account(Name = 'ac1');            
        //insert acc;
       Test.startTest(); 
        case c = new Case(Status = 'Pending External',Priority = 'Medium',First_Response_Updated__c = false);        
        insert c; 
         case c1 = new Case(Status = 'Pending External',Priority = 'Medium',First_Response_Updated__c = true);        
        insert c1;
   		EmailMessage em = new EmailMessage(ToAddress ='rsingh@demandsolutionsgroup.com',FromAddress='rsingh@demandsolutionsgroup.com',ParentId = c.Id);    
   		 insert em;
 		EmailMessage em2 = new EmailMessage(ToAddress ='rsingh@demandsolutionsgroup.com',FromAddress='rsingh@demandsolutionsgroup.com',ParentId = c1.Id);    
   		 insert em2;
    	Test.stopTest();
           
  	}
}