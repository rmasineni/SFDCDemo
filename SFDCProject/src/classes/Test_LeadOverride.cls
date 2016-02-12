@isTest(SeeAllData=true)
public with sharing class Test_LeadOverride {
 public static testmethod void Test_LeadOverride(){
    Test.StartTest();
    Lead l=new Lead(state='CA',city='San Francisco',street='123 street',postalcode='12345',lastname='Test',channel__c='Test',company='Home',average_Monthly_Electric_Bill__c=100,firstname='Test',email='tset@yopmail.com',alternate_phone__c='(111)-(111)-(1234)',phone='(123)-(123)-(1234)');        
        insert l;
     ApexPages.StandardController controller = new Apexpages.Standardcontroller(l);
        system.currentPageReference().getParameters().put('leadId',l.id); 
        LeadOverride ld = new LeadOverride(controller);      
      Pagereference pg=ld.goRedirectLeadEdit();
       ld.getUserProfile();
       ld.checkUserProfile();
       Test.StopTest();
        
 }
}