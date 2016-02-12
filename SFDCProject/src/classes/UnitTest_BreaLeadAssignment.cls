@isTest(SeeAllData=true)
public with sharing class UnitTest_BreaLeadAssignment{
    static testmethod void UnitTest_BreaLeadAssignment(){
    Id id=System.Label.LGCY_Power_Acc_Id;
    if(id==null){
        recordtype r=[Select id, name from RecordType where name='Partner' limit 1 ];
        Account testAcc= new Account(name='SunRun Test', lead_eligible__c=true, recordtypeid=r.id);
        insert testAcc;
        id=testAcc.id;
        }
    Lead l=new Lead(Sales_Partner__c=id,state='CA',city='San Francisco',street='123 street',Channel__c='Partner',custom_lead_source__c='Partner: Legacy',postalcode='94086',lastname='Test',company='Home',average_Monthly_Electric_Bill__c=100,firstname='Test',email='tset@yopmail.com',alternate_phone__c='(111)-(111)-(1234)',phone='(123)-(123)-(1234)');        
    database.insert(l);
    }
  }