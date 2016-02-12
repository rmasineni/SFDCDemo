@istest(seeAllData=true)
public with sharing class Test_trg_attachment_after_insert{
     static testMethod void Test_trg_attachment_after_insert(){
        Test.starttest();
        FS_Dispatch__c fsd=[Select Id from FS_Dispatch__c LIMIT 1];
        Attachment att=new Attachment(ParentId=fsd.id,name='Att1');
        String encodedContentsString='Hello World';
        att.Body = Blob.valueOf(encodedContentsString);
          insert att;
       
    test.stopTest();
     }
}