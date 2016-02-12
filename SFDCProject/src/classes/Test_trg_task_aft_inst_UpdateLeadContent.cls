@isTest(seeAllData=true)
public with sharing class Test_trg_task_aft_inst_UpdateLeadContent {
      static testmethod void Test_trg_task_aft_inst_UpdateLeadContent(){     
      Lead l=new lead(lastname='TestUpdateLeadContent',company='test');
      insert l;
      Test.starttest();
      task t=new task(type='Call',whoid=l.id,Five9__Five9DNIS__c='123456789');
      insert t;
      Test.stoptest();
      }
}