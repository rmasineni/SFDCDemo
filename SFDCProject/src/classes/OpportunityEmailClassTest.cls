@istest(seealldata=true)

public class OpportunityEmailClassTest {

    public static testmethod void SiteAuditScheduleOpptyTest(){
        
        Account acc1 = new Account();
        acc1.Name = 'Test Acc1';
        insert acc1;
        
        Account acc2 = new Account();
        acc2.Name = 'Test Acc2';
        insert acc2;
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Test opp1';
        opp1.AccountId = acc1.Id;
        opp1.CloseDate = Date.today().AddDays(90);
        opp1.StageName = '1. Created';
        opp1.Opportunity_Status__c  ='Open';
        opp1.Site_Audit_Scheduled__c = DateTime.now();
        insert opp1;
        
        opp1.Site_Audit_Scheduled__c = DateTime.now().addDays(-2);
        update opp1;
        
        
        opportunity opp2 = new Opportunity();
        opp2.Name = 'Test opp2';
        opp2.AccountId = acc2.Id;
        opp2.CloseDate = Date.today().AddDays(90);
        opp2.StageName = '5. Customer Signed Agreement';
        opp2.Opportunity_Status__c  ='Open';
        opp2.Site_Audit_Completed__c = Date.Today();
        insert opp2;
        
        opp2.Site_Audit_Completed__c = Date.Today().addDays(-1);
        update opp2;
        
    }
    
    
}