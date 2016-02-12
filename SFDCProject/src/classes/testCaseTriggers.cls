/**
Peter Alexander Mandy
10232012 042352
 */
@isTest
private class testCaseTriggers {

    static testMethod void myUnitTest() {
        Account accountRec = new Account();
        accountRec.Name = 'Test Account Case';
        insert accountRec;
        //
        Contact contactRec = new Contact();
        contactRec.FirstName = 'TestAcct';
        contactRec.LastName = 'TestAcctCase';
        contactRec.AccountId = accountRec.Id;
        insert contactRec;
        //
        RecordType mileStoneRecType = [Select Id from RecordType Where SobjectType = 'Case' And DeveloperName = 'Milestone_Proof'];
        //
        Generation_Assets__c ga = new Generation_Assets__c();
        ga.Account_Name__c = accountRec.Id;
        ga.Customer_Contact__c = contactRec.Id;
        ga.Home_Address__c = 'Test Class';
        ga.City__c = 'Los Gatos';
        ga.Zip__c = '95032';
        ga.Asset_Status__c = 'Plans Approved, Awaiting NTP';
        ga.Facility_Design_Approved__c = date.today();
        ga.NTP_Granted__c = date.today();
        ga.M1_proof_panel_inverter_delivery__c = date.today();
        ga.M2_proof_substantial_completion__c = date.today();
        ga.PTO__c = date.today();
        ga.TE_Fund_name__c = 'ThisEisFunIX';   

        ga.SR_Signoff__c = date.today();
        ga.Facility_Design_Approved__c = date.today();
        ga.Complete_Deal_Received__c = date.today();
 		ga.Initial_Deposit_Processed__c = date.today();
 		ga.Initial_Deposit_Amount_Received__c = 10000;
		ga.Initial_Deposit_Amount__c = 10000;
		ga.Rebate_Conf_Rec_d__c  = date.today();
		ga.Final_Rebate_Amount__c = 100.00;
		ga.Meter_Serial_Num__c = 'Test1254ABC12345';
		ga.Rebate_Conf_Num__c = '234533';
		ga.Meter_Test_Date__c = date.today();
        insert ga;     
        //
        List<Case> listCase = new List<Case>();
        Case case1 = new Case();
        case1.RecordTypeId = mileStoneRecType.Id;
        case1.AccountId = accountRec.Id;
        case1.ContactId = null;
        case1.Milestone_Proof_Type__c = 'M1 Proof';
        case1.Status = 'Request Approval';
        case1.Origin = 'Install Partner'; 
        case1.Reason = 'Documentation';
        case1.Description = 'Milestone Proof Submitted';
        case1.Subject = 'Milestone Proof Submitted';
        case1.First_Response_Updated__c = true;
        case1.First_Response_Date_Time__c = Date.Today();
        case1.Generation_Asset__c = ga.Id;
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
        case2.First_Response_Updated__c = false;
        case2.First_Response_Date_Time__c = null;
        listCase.add(case2);
        //
        insert listCase;
    }
}