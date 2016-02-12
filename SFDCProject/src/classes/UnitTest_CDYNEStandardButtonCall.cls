@isTest(SeeAllData=true)
public with sharing class UnitTest_CDYNEStandardButtonCall  {

  static testmethod void CDYNEStandardButtonCall (){
  user u=new user(id=userinfo.getuserid());
  List<RecordType> rt = [ Select Id from RecordType Where sObjectType='Account' AND Name='Partner'];  
  Account Acc  = new Account(Name='REC Solar', recordtypeid=rt[0].id,Active__c=true, lead_eligible__c=true,channel_type__c='Retail', Office_Location__c='Headquarters',   Stage__c='Confirmed',CDYNE_Status__c='Success' );
        insert Acc;
  Market__c market=new Market__c(state__c='CA',Utility_company__c='Test',Number_of_Leads__c=10);
  insert market;
  Market_Assignment__c ma = new Market_Assignment__c(market__c=market.id,partner__c=acc.id,Start_date__c=system.today()-1,end_date__c=system.today()+1,role__c='Sales,Install',Zipcodes__c='00000',Install_Partner_age_distribution__c=0.10,Sales_Partner_age_distribution__c=0.10);
  insert ma;
  Lead l=new Lead(Apr_Usage__c=1000,may_Usage__c=1000,lastname='Test',FirstName='Test',Market_Assignment_install__c=ma.id,CDYNE_status__c='Failure',called_in__c=true,Utility_company__c='Test',company='tet',street='Test street',lead_qualifier__c=u.id,email='test@yopmail.com',city='san francisco', state='CA',postalcode='00000');
  Lead l1=new Lead(Apr_Usage__c=1000,may_Usage__c=1000,lastname='Test',FirstName='Test',Market_Assignment_Sales__c=ma.id,Market_Assignment_install__c=ma.id,CDYNE_status__c='Success',called_in__c=true,Utility_company__c='Test',company='tet',street='180 diamond street',lead_qualifier__c=u.id,email='test@yopmail.com',city='san francisco', state='CA',postalcode='94114');
  Lead l2=new Lead(Apr_Usage__c=1000,may_Usage__c=1000,lastname='Test',FirstName='Test',Market_Assignment_install__c=ma.id,CDYNE_status__c='Success',called_in__c=true,Utility_company__c='Test',company='tet',street='180 diamond street',lead_qualifier__c=u.id,email='test@yopmail.com',city='san francisco', state='CA',postalcode='94114');
  Lead l3=new Lead(Apr_Usage__c=1000,may_Usage__c=1000,lastname='Test',FirstName='Test',Market_Assignment_install__c=ma.id,CDYNE_status__c='Success',called_in__c=true,Utility_company__c='Test',company='tet',street='180 diamond street',email='test@yopmail.com',city='san francisco', state='CA',postalcode='94114');
  Lead l4=new Lead(Apr_Usage__c=1000,may_Usage__c=1000,lastname='Test',FirstName='Test',Market_Assignment_install__c=ma.id,CDYNE_status__c='Success',called_in__c=true,Utility_company__c='Test',company='tet',street='180 diamond street',city='san francisco', state='CA',postalcode='94114');
  Lead l5=new Lead(Apr_Usage__c=1000,may_Usage__c=1000,lastname='Test',Market_Assignment_install__c=ma.id,CDYNE_status__c='Success',called_in__c=true,Utility_company__c='Test',company='tet',street='180 diamond street',city='san francisco', state='CA',postalcode='94114');  
  Lead l6=new Lead(may_Usage__c=1000,lastname='Test',Market_Assignment_install__c=ma.id,CDYNE_status__c='Success',called_in__c=true,Utility_company__c='Test',company='tet',street='180 diamond street',city='san francisco', state='CA',postalcode='94114');
  Lead l7=new Lead(may_Usage__c=1000,lastname='Test',Market_Assignment_install__c=ma.id,CDYNE_status__c='Success',called_in__c=true,company='tet',street='180 diamond street',city='san francisco', state='CA',postalcode='00000');  
  Lead l8=new Lead(sunrun_south__c=true,lastname='Test',Market_Assignment_install__c=ma.id,CDYNE_status__c='Success',called_in__c=true,company='tet',street='180 diamond street',city='san francisco', state='CA',postalcode='00000');  
  Lead l9=new Lead(lastname='Test',Market_Assignment_install__c=ma.id,CDYNE_status__c='Success',called_in__c=true,company='tet',street='180 diamond street',city='san francisco'); 
  Lead l10=new Lead(Apr_Usage__c=1000,may_Usage__c=1000,lastname='Test',FirstName='Test',Market_Assignment_install__c=ma.id,CDYNE_status__c='Success',called_in__c=true,Utility_company__c='SMUD',company='tet',street='Test street',lead_qualifier__c=u.id,email='test@yopmail.com',city='san francisco',State__c='CA',usage_option__c='NA', state='CA',postalcode='00000');
  List<lead> leadList=new List<Lead>();
  leadList.add(l);
  leadList.add(l1);
  leadList.add(l2);
  leadList.add(l3);
  leadList.add(l4);
  leadList.add(l5);
  leadList.add(l6);
  leadList.add(l7);
  leadList.add(l8); 
  leadList.add(l9);
  leadList.add(l10);
  insert leadList;
  Test.starttest();
  String message=CDYNEStandardButtonCall.callCDYNE(leadList[0].id);
  message=CDYNEStandardButtonCall.callCDYNE(leadList[1].id);
  message=CDYNEStandardButtonCall.callCDYNE(leadList[2].id);
  message=CDYNEStandardButtonCall.callCDYNE(leadList[3].id);
  message=CDYNEStandardButtonCall.callCDYNE(leadList[4].id);
  message=CDYNEStandardButtonCall.callCDYNE(leadList[5].id);
  message=CDYNEStandardButtonCall.callCDYNE(leadList[6].id);  
  message=CDYNEStandardButtonCall.callCDYNE(leadList[7].id); 
  message=CDYNEStandardButtonCall.callCDYNE(leadList[8].id);
  message=CDYNEStandardButtonCall.callCDYNE(leadList[9].id);      
  message=CDYNEStandardButtonCall.callCDYNE(leadList[10].id);        
  Test.stopTest(); 
  }
    static testmethod void CDYNEStandardButtonCallOppty (){
    user u=new user(id=userinfo.getuserid());
  List<RecordType> rt = [ Select Id from RecordType Where sObjectType='Account' AND Name='Partner'];  
  Account Acc  = new Account(Name='REC Solar', recordtypeid=rt[0].id,Active__c=true, lead_eligible__c=true,channel_type__c='Retail', Office_Location__c='Headquarters',   Stage__c='Confirmed',CDYNE_Status__c='Success' );
  insert Acc;
  Market__c market=new Market__c(state__c='CA',Utility_company__c='Test',Number_of_Leads__c=10);
  insert market;
  Market_Assignment__c ma = new Market_Assignment__c(market__c=market.id,partner__c=acc.id,Start_date__c=system.today()-1,end_date__c=system.today()+1,role__c='Sales,Install',Zipcodes__c='00000',Install_Partner_age_distribution__c=0.10,Sales_Partner_age_distribution__c=0.10);
  insert ma;
    Opportunity opp=new Opportunity(Market_Assignment_Sales__c=ma.id,Market_Assignment_Install__c=ma.id,Utility_Company__c='TEst',Apr_Usage__c=1000,May_Usage__c=1000,name='Test',stagename='Open',closedate=system.today(),accountid=acc.id,sales_partner__c=acc.id,Install_Partner__c=acc.id);  
   Opportunity opp1=new Opportunity(Market_Assignment_Install__c=ma.id,Utility_Company__c='TEst',Apr_Usage__c=1000,May_Usage__c=1000,name='Test',stagename='Open',closedate=system.today(),accountid=acc.id);
   Opportunity opp2=new Opportunity(Market_Assignment_Install__c=ma.id,Utility_Company__c='SMUD',Apr_Usage__c=1000,May_Usage__c=1000,name='Test',stagename='Open',closedate=system.today(),accountid=acc.id);
   Opportunity opp3=new Opportunity(Market_Assignment_Install__c=ma.id,Utility_Company__c=null,Apr_Usage__c=1000,May_Usage__c=1000,name='Test',stagename='Open',closedate=system.today(),accountid=acc.id);
  Opportunity opp4=new Opportunity(Market_Assignment_Sales__c=ma.id,Market_Assignment_Install__c=ma.id,Utility_Company__c='TEst',Apr_Usage__c=1000,May_Usage__c=1000,name='Test',stagename='Open',closedate=system.today(),accountid=acc.id,sales_partner__c=acc.id);
  Opportunity opp5=new Opportunity(Market_Assignment_Sales__c=ma.id,Market_Assignment_Install__c=ma.id,Utility_Company__c='TEst',Apr_Usage__c=1000,May_Usage__c=1000,name='Test',stagename='Open',closedate=system.today(),sales_partner__c=acc.id);
  Opportunity opp6=new Opportunity(Market_Assignment_Sales__c=ma.id,Market_Assignment_Install__c=ma.id,Utility_Company__c='TEst',name='Test',stagename='Open',closedate=system.today(),accountid=acc.id,sales_partner__c=acc.id);
  List<Opportunity> oppList=new List<Opportunity>();
  oppList.add(opp);
  oppList.add(opp1);
  oppList.add(opp2);
  oppList.add(opp3);
  oppList.add(opp4);
  oppList.add(opp5);
  oppList.add(opp6);
  insert oppList;
  String message=CDYNEStandardButtonCall.callOpportunity(oppList[0].id);
  message=CDYNEStandardButtonCall.callOpportunity(oppList[1].id);
  message=CDYNEStandardButtonCall.callOpportunity(oppList[2].id);
  message=CDYNEStandardButtonCall.callOpportunity(oppList[3].id);
  message=CDYNEStandardButtonCall.callOpportunity(oppList[4].id);
  message=CDYNEStandardButtonCall.callOpportunity(oppList[5].id);
  message=CDYNEStandardButtonCall.callOpportunity(oppList[6].id);
    }
  }