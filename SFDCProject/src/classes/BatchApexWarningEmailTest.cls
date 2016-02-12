@istest(SeeAllData=true)
public with sharing class BatchApexWarningEmailTest {
    static testmethod void BatchApexWarningEmailTest(){
            Test.starttest();           
            String query='select id,email,createddate from contact limit 10';
            BatchApexWarningEmail  batch=new BatchApexWarningEmail(query);          
            ID batchprocessid =database.executeBatch(batch,10);
            Test.stopTest();
    }
}