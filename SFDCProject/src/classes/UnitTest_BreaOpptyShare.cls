@isTest(SeeAllData=true)
public with sharing class UnitTest_BreaOpptyShare{
    static testmethod void UnitTest_BreaOpptyShare(){
    Id id=System.Label.LGCY_Power_Acc_Id;   
        recordtype r=[Select id, name from RecordType where name='Partner' limit 1 ];
        Account testAcc= new Account(name='SunRun Test', lead_eligible__c=true, recordtypeid=r.id);
        if(id==null){
        id=testAcc.id;
        }
    Opportunity opp=new Opportunity (Install_Partner__c=testAcc.id,Sales_partner__c=id,SalesRep__c=userinfo.getuserid(),name='Test',stagename='Open',Channel_2__c='Partner',lead_source_2__c='Partner: Legacy',closedate=system.today(),accountid=testacc.id);        
   Opportunity opp1=new Opportunity (Install_Partner__c=id,Sales_partner__c=id,SalesRep__c=userinfo.getuserid(),name='Test',stagename='Open',Channel_2__c='Partner',lead_source_2__c='Partner: Legacy',closedate=system.today(),accountid=testacc.id);
     List<Opportunity> opptList=new List<Opportunity>();
        opptList.add(opp);
        opptList.add(opp1);
        insert opptList;        
    
    }
  }