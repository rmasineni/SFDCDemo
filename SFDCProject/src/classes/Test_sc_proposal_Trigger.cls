@isTest
private class Test_sc_proposal_Trigger {

    static testMethod void Test_sc_proposal_Trigger() {
        //Creating an Opportunity record
            List<Opportunity> oppList = New List<Opportunity>();
            Opportunity Opp = new Opportunity();
            Opp.Name = 'TestOpp';
            Opp.CloseDate = date.today();
            Opp.StageName = 'Closed Won';
            oppList.add(Opp);
            insert oppList;
             System.debug('Created an Opportunity ' + Opp.Id);
        //Creating a proposal record
            List<Proposal__c> proList = new List<Proposal__c>();
            Proposal__c p = New Proposal__c();
            p.Upfront_Payment__c = 70000;
            p.System_Size_STC_DC__c = 25;
            p.Sales_Rep_Email__c = 'testrep@yopmail.com';
            p.Name = 'Testproposal';
            p.Opportunity__c = Opp.Id;
            p.Date_Issued__c = date.today();
            p.Mode_Name__c  = 'Modetest';
            p.Stage__c  = 'SR Approved';
            p.Sunrun_Credit_Status__c = 'SR Credit Approved';
            proList.add(p);
            insert proList;
              System.debug('Created an Proposal ' + p.Id);
        //Creating an Account
             List<Account> accList = New List<Account>();
             Account a = New Account();
             a.Name = 'TestAccount'; 
             accList.add(a);
             insert accList;
              System.debug('created an Account ' + a.Id);   
            
        //Creating a service contact record 
             List<ServiceContract> scList = New List<ServiceContract>();
             ServiceContract sc = New ServiceContract();
             sc.Name = 'Testsc';
             sc.AccountId = a.Id;
             sc.Name = 'Testservicecontract';
             sc.Proposal__c = p.Id;
             sc.Legacy_Asset_Number__c = '10082004';
             scList.add(sc);
             insert scList;
             System.debug('Created an ServiceContract ' + sc.Id);
             Update proList;  
           
        
            }
}