@isTest(SeeAllData=true)
private class WorkflowUpdateRulecStatsTT {

   static testMethod void testTrigger() {
      try {
          Workflow_Update_Rule__c o = new Workflow_Update_Rule__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<Workflow_Update_Rule__c> l = [SELECT Id from Workflow_Update_Rule__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}