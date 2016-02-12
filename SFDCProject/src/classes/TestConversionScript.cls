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
private class TestConversionScript {

    static testMethod void testConvertLead() {
      Test.StartTest();
    Lead lead = new Lead();
    Quote__c c = new Quote__c();
    
    lead.email = 'a.n.th.on.ybishopric@gmail.com';
    lead.LastName='Blee';
    lead.Company='Blee Co';
    lead.street='740 Allendale Road';
    lead.state='FL';
    lead.city='Key Biscayne';
    lead.postalcode='33149';
      
    insert lead;
    
    c.lead__c= lead.id;
    c.upfront_payment__c = 10.0;
    insert c;
    Test.StopTest();
    /*
    Database.LeadConvert l = new Database.LeadConvert();
    l.setLeadId(lead.id);
    l.setConvertedStatus('Converted');
    
    Database.LeadConvertResult result = Database.convertLead(l);
    System.assert(result.isSuccess());
    
    String id = result.getAccountId();
    
    Quote__c[] results =  [Select q.Id from Quote__c q where q.Account__c= :id];
    if(!results.isempty())
    System.assert(results[0].Id == c.Id);
    */
    }
}