@istest(SeeAllData=true)
public with sharing class BatchApexEmailStatusTest {
    static testmethod void BatchApexEmailStatusTest(){    		
            Test.starttest();           
            String query='select id,service_contract__r.contactid from service_contract_event__c where createddate>n_days_ago:30 limit 10';
            BatchApexEmailStatus  batch=new BatchApexEmailStatus(query);          
            ID batchprocessid =database.executeBatch(batch,10);
            Test.stopTest();
    }
}