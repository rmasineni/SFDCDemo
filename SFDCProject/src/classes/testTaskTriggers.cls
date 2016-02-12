/**
Peter Alexander Mandy
10232012 095220 
*/
@isTest
private class testTaskTriggers {

    static testMethod void myUnitTest() {

        Account accountRec = new Account();
        accountRec.Name = 'Test Account Tasks';
        insert accountRec;
 
        Contact contactRec = new Contact();
        contactRec.FirstName = 'TestAcct';
        contactRec.LastName = 'TestAcctTasks';
        contactRec.AccountId = accountRec.Id;
        insert contactRec;
        
        RecordType mileStoneRecType = [Select Id from RecordType Where SobjectType = 'Case' And DeveloperName = 'Milestone_Proof'];
        
        List<Case> listCase = new List<Case>();
        Case case1 = new Case();
        case1.RecordTypeId = mileStoneRecType.Id;
        case1.AccountId = accountRec.Id;
        case1.ContactId = contactRec.Id;
        case1.Milestone_Proof_Type__c = 'M1 Proof';
        case1.Status = 'Request Approval';
        case1.Origin = 'Install Partner'; 
        case1.Reason = 'Documentation';
        case1.Description = 'Milestone Proof Submitted';
        case1.Subject = 'Milestone Proof Submitted';
        case1.First_Response_Updated__c = false;
        listCase.add(case1);
//
        Case case2 = new Case();
        case2.RecordTypeId = mileStoneRecType.Id;
        case2.AccountId = accountRec.Id;
        case2.ContactId = contactRec.Id;
        case2.Milestone_Proof_Type__c = 'M1 Proof';
        case2.Status = 'Request Approval';
        case2.Origin = 'Install Partner'; 
        case2.Reason = 'Documentation';
        case2.Description = 'Milestone Proof Submitted';
        case2.Subject = 'Milestone Proof Submitted';
        case2.First_Response_Updated__c = true;
        listCase.add(case2);
        //
        insert listCase;
        //
        List<Task> listTask = new List<Task>();
        Task t1 = new Task();
        t1.WhatId = case1.Id;
        t1.Activity_Channel__c = 'Email Outbound';
        listTask.add(t1);
        Task t2 = new Task();
        t2.WhatId = case2.Id;
        t2.Activity_Channel__c = 'Email Outbound';
        listTask.add(t2);
        insert listTask;
    }
}