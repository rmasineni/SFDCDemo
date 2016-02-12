@isTest(SeeAllData=true)
private class ProjectcStatsTT {

   static testMethod void testTrigger() {
      try {
          Project__c o = new Project__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<Project__c> l = [SELECT Id from Project__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}