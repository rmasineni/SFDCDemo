@istest(seeAlldata=true)
private with sharing class UnitTest_ConvertLead {
    static testmethod void ConvertLeadTest(){
      user u=new user(id=userinfo.getuserid());
       List<RecordType> rt = [ Select Id from RecordType Where sObjectType='Account' AND Name='Partner'];  
       Account Acc  = new Account(Name='REC Solar', recordtypeid=rt[0].id,Active__c=true, lead_eligible__c=true,channel_type__c='Retail', Office_Location__c='Headquarters',   Stage__c='Confirmed',CDYNE_Status__c='Success' );
       insert Acc;
        Market__c market=new Market__c(state__c='CA',Utility_company__c='Test',Number_of_Leads__c=10);
        insert market;
        Market_Assignment__c ma = new Market_Assignment__c(market__c=market.id,partner__c=acc.id,Start_date__c=system.today()-1,end_date__c=system.today()+1,role__c='Sales,Install',Zipcodes__c='00000',Install_Partner_age_distribution__c=0.10,Sales_Partner_age_distribution__c=0.10);
        insert ma;
        Lead lead=new Lead(salesrep__c=userinfo.getuserid(),sales_rep_division__c='Inside Sales',called_in__c=true,email='Test-bb@yopmail.com',CDYNE_Status__c='Success',lead_qualifier__c=u.id,sales_partner__c=acc.id,Install_partner__c=acc.id,market_Assignment_sales__c=ma.id,market_Assignment_install__c=ma.id,firstname='Test',channel__c='Test',lastname='TESTS',company='Home',street='180 diamond street', city='San francisco',state='CA',postalcode='94114');
        Test.startTest();
        insert lead;                
        Test.stopTest();
        ConvertLead.doConvert(lead.id);
    }
}