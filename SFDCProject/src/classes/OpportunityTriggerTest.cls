@IsTest
public class OpportunityTriggerTest {
    testmethod static void testDealIdOfOpty() {
        Opportunity opty = new Opportunity();
        opty.name = 'Test Opty';
        opty.StageName = 'New';       
        insert opty;
        
        Opportunity opty2 = [select Deal_Id__c from Opportunity where id = :opty.id];        
        System.assertEquals(12, opty2.Deal_Id__c.length());        
    }
    
    testmethod static void testProjectstatus() {
    
        Opportunity opty = new Opportunity();
        opty.name = 'Test Opty2';
        opty.StageName = '8. Future Prospect';       
        insert opty;
        
        Project__c p = new Project__c();
        p.Opportunity__c = opty.Id;
        p.Status__c ='Cancelled';
        
        insert p;
        
        opty.StageName = '1. Created'; 
        update opty;
        
        ServiceContract sc = new ServiceContract();
        sc.Status__c = 'Deal Cancelled';
        sc.Canceling_Party__c ='Sunrun';
        
        insert sc;
        
        Project__c p2 = new Project__c();
        p2.Service_Contract__c = sc.Id;
        p2.Status__c ='Cancelled';
        
        insert p2;
        
        sc.Status__c = 'test';
        update sc;
    }
    
}