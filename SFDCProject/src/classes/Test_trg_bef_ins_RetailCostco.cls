@isTest(SeeAllData=true)
public with sharing class Test_trg_bef_ins_RetailCostco{
 static testMethod void Test_trg_bef_ins_RetailCostco(){
 Test.StartTest();
 Account a= [select id,name from account where office_location__c='Headquarters' and Ultimate_Parent_Account__c=null limit 1];
 Opportunity opp = new Opportunity();
 opp.Lead_Organization_Location_2__c = a.id;
 opp.Costco_Purchase_Thru_Warehouse__c = a.id;
 Test.stoptest();
 }
 }