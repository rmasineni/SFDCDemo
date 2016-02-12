/**
Peter Alexander Mandy
10232012 101129
 */
@isTest
private class testOpptyTriggers {

    static testMethod void myUnitTest() {
        //
        Account accountRec = new Account();
        accountRec.Name = 'Test Account Oppties';
        insert accountRec;
        //
        Contact contactRec = new Contact();
        contactRec.FirstName = 'TestAcct';
        contactRec.LastName = 'TestAcctOppty';
        contactRec.AccountId = accountRec.Id;
        insert contactRec;
        //
        ID ProfileID = [ Select id from Profile where UserType = 'PowerPartner' LIMIT 1].id;
        //
        User u1 = new User( email='test-user@fakeemail.com', contactid = contactRec.id, profileid = ProfileID, 
                UserName='test-user11@fakeemail.com', alias='tusr11', CommunityNickName='tusr11', 
                TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
                LanguageLocaleKey='en_US', FirstName = 'Test', LastName = 'User',Title = 'Key User' );
        insert u1;
        //
        Opportunity Opp = new Opportunity();
        Opp.Name = 'TestOpptyTriggers';
        Opp.StageName = 'Qualified';
        Opp.CloseDate = Date.Today().addDays(18);    
        Opp.AccountId = accountRec.Id;
        Opp.Sales_Representative__c = contactRec.Id;
        Opp.Notes__c = 'test';
        insert Opp;
        Opportunity Opp1 = new Opportunity();
        Opp1.Name = 'TestOpptyTriggers';
        Opp1.StageName = 'SR Approved';
        Opp1.CloseDate = Date.Today().addDays(18);    
        Opp1.AccountId = accountRec.Id;
        Opp1.Sales_Representative__c = contactRec.Id;
        Opp1.Notes__c = 'abcxyz';
        insert Opp1;
        Opportunity Opp2 = new Opportunity();
        Opp2.Name = 'TestOpptyTriggers';
        Opp2.StageName = 'Qualified';
        Opp2.CloseDate = Date.Today().addDays(18);    
        Opp2.AccountId = accountRec.Id;
        Opp2.Sales_Representative__c = contactRec.Id;
        Opp2.Partner_Notes__c = 'pqrs';
         insert Opp2;
         Opportunity Opp3 = new Opportunity();
        Opp3.Name = 'TestOpptyTriggers';
        Opp3.StageName = 'Qualified';
        Opp3.CloseDate = Date.Today().addDays(18);    
        Opp3.AccountId = accountRec.Id;
        Opp3.Sales_Representative__c = contactRec.Id;
        Opp3.Partner_Notes__c = 'pqrs';
         insert Opp3;
         
         Proposal__c pro = New Proposal__c();
            pro.Upfront_Payment__c = 70000;
            pro.System_Size_STC_DC__c = 25;
            pro.Sales_Rep_Email__c = 'testrep@yopmail.com';
            pro.Name = 'Testproposal';
            pro.Opportunity__c = Opp.Id;
            pro.Date_Issued__c = date.today();
            pro.Mode_Name__c  = 'Modetest';
            pro.Stage__c  = 'SR Approved';
            pro.Sunrun_Credit_Status__c = 'SR Credit Approved';
            insert pro;
            Proposal__c pro1 = New Proposal__c();
            pro1.Upfront_Payment__c = 70000;
            pro1.System_Size_STC_DC__c = 25;
            pro1.Sales_Rep_Email__c = 'testrep@yopmail.com';
            pro1.Name = 'Testproposal';
            pro1.Opportunity__c = Opp3.Id;
            pro1.Date_Issued__c = date.today();
            pro1.Mode_Name__c  = 'Modetest';
            pro1.Stage__c  = 'Voided';
            pro1.Sunrun_Credit_Status__c = 'SR Credit Approved';
            insert pro1;
        Opp.StageName = 'Unqualified';
        update Opp;  
            
         Notes__c note = New Notes__c();
         note.Opportunity__c = Opp1.Id;
         note.Proposal__c = pro.Id;
         note.Notes__c = 'abcxyz';
         insert note;
         Notes__c note2 = New Notes__c();
         note2.Opportunity__c = Opp2.Id;
         note2.Proposal__c = pro.Id;
         note2.Notes__c = 'pqrs';
         insert note2; 
         Opp1.Notes__c = 'tea';
         update Opp1;
         Opp2.Partner_Notes__c= 'coffee';
         update Opp2;
        
    }
}