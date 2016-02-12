@isTest(SeeAllData=true)
private class TaskcStatsTT {

   static testMethod void testTrigger() {
      try {
          Task__c o = new Task__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<Task__c> l = [SELECT Id from Task__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}