@isTest(SeeAllData=true)
public with sharing class Test_BatchClassShareOppty {
    public static testmethod void Test_BatchClassShareOppty(){
        Test.StartTest();   
        List<Proposal__c> proList=[select id,opportunity__c,Sales_Partner__c,Install_Partner__c from Proposal__c where sales_partner__c!=null limit 10];
        Map<id,id> UserAccountMap=new Map<id,id>();
        if(!proList.isempty())
        UserAccountMap.put(proList[0].Sales_Partner__c,userinfo.getuserid());  
        String query='select id,opportunity__c,Sales_Partner__c,Install_Partner__c from Proposal__c where sales_partner__c!=null limit 10';     
         BatchApexHistoricalOppty  batch=new BatchApexHistoricalOppty(query); 
         batch.UserAccountMap= UserAccountMap;                 
            ID batchprocessid =database.executeBatch(batch,10);
         Test.stopTest();       
    }   
}