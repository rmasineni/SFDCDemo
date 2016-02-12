@isTest(SeeAllData=true)
public with sharing class UnitTest_PartnerLeadAssignment{
    static testmethod void UnitTest_PartnerLeadAssignment(){
    Lead l=new Lead(state='CA',city='San Francisco',street='123 street',Channel__c='Partner',custom_lead_source__c='Partner: Red Ventures',postalcode='94086',lastname='Test',company='Home',average_Monthly_Electric_Bill__c=100,firstname='Test',email='tset@yopmail.com',alternate_phone__c='(111)-(111)-(1234)',phone='(123)-(123)-(1234)');        
    database.insert(l);    
    }
  }