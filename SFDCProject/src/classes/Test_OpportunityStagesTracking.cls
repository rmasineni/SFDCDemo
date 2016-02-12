@isTest
public with sharing class Test_OpportunityStagesTracking {
    public static testmethod void Test_OpportunityStagesTracking(){
       Test.startTest();
        Account acc = new Account (Name ='Test12',BillingPostalCode = '00000',BillingState ='CA');
        insert acc;
        Opportunity opp = new Opportunity(name='Test12', Accountid =acc.id, StageName='1.Created', CloseDate = system.today() + 365);
        insert opp;
        opp.StageName = '2. Appointment Process';
        update opp;
        opp.StageName = '3. Proposal Presented to Customer';
        update opp;
        opp.StageName = '4. Verbal Commit';
        update opp;
        opp.StageName = '5. Customer Signed Agreement';
        update opp;
        opp.StageName = '6. Submitted To Operations';
        update opp;
        opp.StageName = '7. Closed Won';
        update opp;        
        opp.StageName = '8. Future Prospect';
        update opp;
        opp.StageName = '9. Closed Lost';
        update opp;
        system.assertEquals(opp.Created_Date_New__c,opp.Stage1TimeStamp__c);
        system.assertEquals(null,opp.Stage7TimeStamp__c);
        system.assertEquals(null,opp.Stage2TimeStamp__c);
        system.assertEquals(null,opp.Stage5TimeStamp__c);
        Test.stopTest();
    }

}