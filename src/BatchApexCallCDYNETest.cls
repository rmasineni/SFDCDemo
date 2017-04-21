@istest(SeeAllData=true)
public with sharing class BatchApexCallCDYNETest {
static testmethod void BatchApexWarningEmailTest(){
            Test.starttest(); 
            Lead l=new Lead(lastname='Test9888',company='Home'); 
            insert l;      
            String query='select id from lead where lastname=\'Test9888\' limit 1';
            BatchApexCallCDYNE  batch=new BatchApexCallCDYNE(query);          
            ID batchprocessid =database.executeBatch(batch,10);
            Test.stopTest();
    }
}