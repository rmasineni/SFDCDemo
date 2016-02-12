@isTest(SeeAllData=true)
public with sharing class UnitTest_BreaLeadShare{
    static testmethod void UnitTest_BreaLeadShare(){
    Id id=System.Label.LGCY_Power_Acc_Id;   
        recordtype r=[Select id, name from RecordType where name='Partner' limit 1 ];
        Account testAcc= new Account(name='SunRun Test', lead_eligible__c=true, recordtypeid=r.id);
        if(id==null){
        id=testAcc.id;
        }
   Lead l=new Lead(Sales_Partner__c=id,Install_Partner__c=testAcc.id,SalesRep__c=userinfo.getuserid(),state='CA',city='San Francisco',street='123 street',Channel__c='Partner',custom_lead_source__c='Partner: Legacy',postalcode='94086',lastname='Test',company='Home',average_Monthly_Electric_Bill__c=100,firstname='Test',email='tset@yopmail.com',alternate_phone__c='(111)-(111)-(1234)',phone='(123)-(123)-(1234)');       
   Lead l1=new Lead(Sales_Partner__c=id,Install_Partner__c=id,SalesRep__c=userinfo.getuserid(),state='CA',city='San Francisco',street='123 street',Channel__c='Partner',custom_lead_source__c='Partner: Legacy',postalcode='94086',lastname='Test',company='Home',average_Monthly_Electric_Bill__c=100,firstname='Test',email='tset@yopmail.com',alternate_phone__c='(111)-(111)-(1234)',phone='(123)-(123)-(1234)');
     List<Lead> leadList=new List<Lead>();
        leadList.add(l);
        leadList.add(l1);
        database.insert(leadList);  
        Set<id> lids=new set<id>();
        lids.add(l.id);         
        Map<id,lead> mapoldlead=new Map<id,lead>();
        mapoldlead.put(l.id,l);  
        SalesRepMarketAssignment.doMarketAssignments(lids);
        SalesRepMarketAssignment.doSalesRepMarketAssignment(leadList,mapoldlead);
    }
  }