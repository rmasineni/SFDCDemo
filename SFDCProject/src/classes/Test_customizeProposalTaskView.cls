@isTest 
public class Test_customizeProposalTaskView {
    public static testMethod void TestcustomizeProposalTaskView(){
        customizeProposalTaskView custPropTskViewObj = new customizeProposalTaskView();
        
        custPropTskViewObj.first();
        custPropTskViewObj.getHasNext();
        custPropTskViewObj.getHasPrevious();
        custPropTskViewObj.getlstTask();
        custPropTskViewObj.getPageNumber();
        custPropTskViewObj.getTotalPageCount();
        custPropTskViewObj.getView2();
        custPropTskViewObj.last();
        custPropTskViewObj.next();
        custPropTskViewObj.previous();
        custPropTskViewObj.userActions();
        custPropTskViewObj.pageNumber = 1;
        custPropTskViewObj.totalPageCount = 3;
        custPropTskViewObj.previous();
        custPropTskViewObj.getHasNext();
        custPropTskViewObj.getHasPrevious();
        
        custPropTskViewObj.pageSize = 5;
        custPropTskViewObj.getlstTask();
        custPropTskViewObj.PickList2 = 'dToday';
        custPropTskViewObj.userActions();
        custPropTskViewObj.pageNumber = 0;
        custPropTskViewObj.getlstTask();
        custPropTskViewObj.PickList2 = 'dWeek';
        custPropTskViewObj.userActions();
        custPropTskViewObj.PickList2 = 'dOver';
        custPropTskViewObj.userActions();
        custPropTskViewObj.previous();
        custPropTskViewObj.getHasPrevious();
        custPropTskViewObj.totalCount = 4;
        custPropTskViewObj.getlstTask();
        custPropTskViewObj.userActions();
        custPropTskViewObj.pageNumber = 2;
        custPropTskViewObj.getHasPrevious();
        
        
        
        
        //RecordType=012g0000000Cisu;
        
    }
    public static testMethod void TestcustomizeProposalTaskView1(){
        
        //Id userId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
        //User partnerUser = [Select id, name, email from User where Id =:userId];
        Id userId='00560000003KtpG';
        User partnerUser=new User(id=userId);
        
        Test.startTest();
            Account account = new Account();
            account.Name = 'Lease Account';
            account.BillingStreet = '1290 Happy Path';
            account.BillingCity = 'San Francisco';
            account.BillingState = 'CA';
            account.BillingCountry = 'USA';
            insert account;
            //    
           
            Contact contact = new Contact();
            contact.AccountId = account.Id;
            contact.LastName = 'Lease';
            contact.FirstName = 'Johnny';
            contact.Email = 'JLease@Test.com';
            contact.Phone = '2022022020'; 
            contact.MailingStreet = '1290 Happy Path';
            contact.MailingState = 'CA';
            contact.MailingCountry = 'USA';
            contact.MailingCity = 'San Francisco';
            contact.MailingPostalCode = '95051';   
            contact.Accreditation_period_start_date__c = Date.Today().addDays(-180);
            contact.Accreditation_period_end_date__c = Date.Today().addDays(180);
            contact.Birthdate = Date.Today();    
            //           
           insert contact;
              
            Opportunity oppty = new Opportunity();
            oppty.AccountId = account.Id;
            oppty.Name = 'EDPLookup Test';
            oppty.StageName = 'Qualified';
            oppty.CloseDate = Date.Today().addDays(18);
            insert oppty;
            //
            //Proposal__c proposal = UnitTest_ServiceContractUtil.createProposal(oppty.Id);
            Proposal__c proposal = new Proposal__c();
            proposal.Opportunity__c = Oppty.Id;
            proposal.Stage__c = 'Created';  
            proposal.Sales_Rep_Email__c = 'therepsemail@repemailfake.com';
            proposal.Date_Issued__c = Date.Today().addDays(18); 
            proposal.Mode_Name__c = '1234';
            proposal.System_Size_STC_DC__c  = 5.8;
            proposal.Upfront_Payment__c = 20.0;
            proposal.Sunrun_Credit_Status__c = 'SR Credit Approved';
            proposal.EDP_Phase__c = 'EDP Phase-0';
            insert proposal;
            
            List<Task> taskList = new List<Task>();
            
            Task Task1 = new Task();
            Task1.OwnerId = userId;
            Task1.Status = 'Open';
            Task1.Priority = 'Normal';
            Task1.WhatId = proposal.id;
            Task1.Subject = 'Missing Fields';
            Task1.ActivityDate = Date.today();
            taskList.add(Task1);
            
            Task Task2 = new Task();
            Task2.OwnerId = userId;
            Task2.Status = 'Open';
            Task2.Priority = 'Normal';
            Task2.WhatId = proposal.id;
            Task2.Subject = 'Missing Fields';
            Task2.ActivityDate = Date.today();
            taskList.add(Task2);
            
            Task Task3 = new Task();
            Task3.OwnerId = userId;
            Task3.Status = 'Open';
            Task3.Priority = 'Normal';
            Task3.WhatId = proposal.id;
            Task3.Subject = 'Missing Fields';
            Task3.ActivityDate = Date.today().addDays(7);
            taskList.add(Task3);
            
            Task Task4 = new Task();
            Task4.OwnerId = userId;
            Task4.Status = 'Open';
            Task4.Priority = 'Normal';
            Task4.WhatId = proposal.id;
            Task4.Subject = 'Missing Fields';
            Task4.ActivityDate = Date.today().addDays(-1);
            taskList.add(Task4);
            
            insert taskList;
            
            System.runAs(partnerUser){
                customizeProposalTaskView custPropTskViewObj1 = new customizeProposalTaskView();
            }
         Test.stopTest();   
    }
}