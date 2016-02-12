@isTest(SeeAllData=true)
public with sharing class Test_EditLead {
    public static testmethod void EditLead(){
        Test.StartTest();
         Lead l=new Lead(state='CA',city='San Francisco',street='123 street',postalcode='12345',lastname='Test',channel__c='Test',company='Home',average_Monthly_Electric_Bill__c=100,firstname='Test',email='tset@yopmail.com',alternate_phone__c='(111)-(111)-(1234)',phone='(123)-(123)-(1234)');
      // Lead l= new Lead();
        insert l;
        ApexPages.StandardController controller = new Apexpages.Standardcontroller(l);
        system.currentPageReference().getParameters().put('leadId',l.id); 
       
        EditLead ldobj = new EditLead(new ApexPages.StandardController(l));
        Pagereference p= ldobj.saveLead();
        ldobj.initialize();
       ldobj.getDefaultRecordTypeId();   
       l.FirstName='Test1';
       l.LastName='Test2';
       l.Email='Test@yopmail.com';
       l.Phone='4445556666';
       ldobj.leadObj=l;
      p=ldobj.savelead();
       
     //  Pagereference pg=ldobj.leadValidations();
       l.Company='TestCompany';
       l.LastName='Test';
       l.Lead_Assignment_Control_Field__c=true;
       ldobj.leadobj=l;
     //  p=ldobj.savelead();
       
       ldobj.leadValidations();
       
       l.company='Test'+ 'Company';
       l.Lead_Assignment_Control_Field__c=true;
       ldobj.leadobj=l;       
        
       ldobj.continueLeadEdit();
       
       // p=leadobj.saveLead();
        Test.stopTest();
    }

}