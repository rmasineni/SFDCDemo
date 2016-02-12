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
private class testGenerateReferralDataController {

    static testMethod void myUnitTest() {
        // Test data
        Account a1 = new Account(name='Test Acct1');
        insert a1;
        Account a2 = new Account(name='Test Acct2');
        insert a2;        
        Contact c1 = new Contact(AccountId=a1.Id,FirstName='TestFirstName', LastName='Peter', email='peter@test.test');
        insert c1;
        Contact c2 = new Contact(AccountId=a2.Id,FirstName='TestFirstName1', LastName='Peter2', email='peter2@test.test');
        insert c2;
        //
        Boolean bHasPrimary = false;
        Promotion__c prim = new Promotion__c();
        for(Promotion__c promo:[select id from Promotion__c where Primary_Promotion__c = true])
        {
           bHasPrimary = true;
           prim = promo;
        }
        if(!bHasPrimary)
        {   
          //
          prim.Name = 'Summer Prim';
          prim.Promotion_Type__c = 'Customer';    
          prim.Start_Date__c = Date.Today().addYears(-5);
          prim.End_Date__c = Date.Today().addYears(5);
          prim.Expires_after_usage__c = 999;
          prim.In_Time_Duration_Length__c = 1;
          prim.In_Time_Duration_Unit__c = 'Weeks';
          prim.Primary_Promotion__c = true;    
          prim.Referral_Payout_on1__c = 'Asset';
          prim.At_Stage1__c = 'NTP';
          prim.Referee_Payment_Option1__c = 'Check / Credit on Monthly Bill';    
          prim.Referrer_Payment_Option1__c = 'Check / Credit on Monthly Bill';
          prim.Referee_Payment_Amount1__c = 100;
          prim.Referrer_Payment_Amount1__c = 100;
          insert prim;
       }
       Referral_Input__c ri = new Referral_Input__c();
       ri.Target_Contact_Id__c = c1.Id;
       ri.Source_Contact_Id__c = c2.Id;
       ri.Promotion__c = prim.id;
       ri.Source_Account_Id__c = a1.id;
       ri.Milestone_1_Status__c = Label.ReferralReadyForPayment;
       insert ri;       
       Referral_Input__c ri2 = new Referral_Input__c();
       ri2.Target_Contact_Id__c = c2.Id;
       ri2.Source_Contact_Id__c = c1.Id;
       ri2.Promotion__c = prim.id;
       ri2.Source_Account_Id__c = a2.id;
       ri2.Milestone_1_Status__c = Label.ReferralReadyForPayment;
       insert ri2;        
        
        Generation_Assets__c ga1 = new Generation_Assets__c(Referral_Input__c=ri.Id,Account_Name__c=a1.id, Name='12345'); 
        insert ga1;
        Generation_Assets__c ga2 = new Generation_Assets__c(Referral_Input__c=ri2.Id,Account_Name__c=a2.id, Name='56785'); 
        insert ga2;        
        //
        PageReference pr = Page.GenerateReferralData;  
        Test.setCurrentPage(pr);        
    }
}