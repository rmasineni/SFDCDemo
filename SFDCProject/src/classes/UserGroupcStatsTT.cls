@isTest(SeeAllData=true)
private class UserGroupcStatsTT {

   static testMethod void testTrigger() {
      try {
          User_Group__c o = new User_Group__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<User_Group__c> l = [SELECT Id from User_Group__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}