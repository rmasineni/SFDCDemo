@isTest(seealldata=true)
public with sharing class Test_OverridePartnerLeadTab {
    static testmethod void Test_OverridePartnerLeadTab(){
        //Account acc = new Account(name='Test1',billingpostalcode='00000',billingstate='CA'); 
        //insert acc;
       
        Lead lead1=new Lead(state='CA',city='San Francisco',street='123 street',postalcode='12345',lastname='Test',channel__c='Test',company='Home',average_Monthly_Electric_Bill__c=100,firstname='Test',email='tset@yopmail.com',alternate_phone__c='(111)-(111)-(1234)',phone='(123)-(123)-(1234)');        
        insert lead1;
        List<Lead> leadList = new List<Lead>();
        leadList.add(lead1);
        
        ApexPages.StandardSetController controller = new Apexpages.StandardSetController(leadList);
        
        
        ApexPages.currentPage().getParameters().put('retURL','/apex/NewCustomOpportunity');
        //ApexPages.currentPage().getParameters().put('oppId',opp.id);
        ApexPages.currentPage().getParameters().put('RecordType','012g00000008Y19');
        ApexPages.currentPage().getParameters().put('ent','entvalue1');
        
        OverridePartnerLeadTab oplt = new OverridePartnerLeadTab(controller);
        oplt.redirectLeadTab();
    }
}