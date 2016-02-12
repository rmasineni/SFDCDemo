@istest(SeeAllData=true)
public class ZipUtilityUpdateAccountAddressChangeTest {
    testmethod public static void zipzccounts(){
        
        Account acc = new Account(name='TestZipAccountsTrigger', BillingStreet = 'Test Street', BillingCity = 'Test City', BillingState = 'TT', BillingPostalCode = '11111');
        Account acc1 = new Account(name='TestZipAccountsTrigger1', BillingStreet = 'Test Street1', BillingCity = 'Test City1', BillingState = 'TT1', BillingPostalCode = '11110');
        CheckRecursiveTrigger.resetRunOnceFlag();
        insert acc;  
        
        Opportunity opty = New Opportunity(AccountId=acc.Id,Name='Testopp1',StageName='2. Appointment Process',Opportunity_Status__c='Open',CloseDate=system.today()+90);
        insert opty;
        
        Opportunity opty1 = New Opportunity(AccountId=acc1.Id,Name='Testopp2',StageName='2. Appointment Process',Opportunity_Status__c='Open',CloseDate=system.today()+90);
        insert opty1;

        CheckRecursiveTrigger.resetRunOnceFlag();
        acc.BillingPostalCode = '94538';
        update acc; 

    }
    
  /*  private static testmethod void zipzccounts1(){
        
        Account acc1 = new Account(name='TestZipAccountsTrigger', BillingStreet = 'Test Street', BillingCity = 'Test City', BillingState = 'TT', BillingPostalCode = '11111');
        insert acc1;
        acc1.BillingPostalCode = null;
        update acc1;     
        
        
        Opportunity opty1 = New Opportunity(AccountId=acc1.Id,Name='Testopp1',StageName='2. Appointment Process',Opportunity_Status__c='Open',CloseDate=system.today()+90);
        insert opty1;
        system.assertEquals(null,opty1.Sales_Branch__c);
        
        Opportunity opty3 = New Opportunity(AccountId=acc1.Id,Name='Testopp2',StageName='2. Appointment Process',Opportunity_Status__c='Open',CloseDate=system.today()+90);
        insert opty3;
        
        
    } */
}