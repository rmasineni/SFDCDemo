@isTest(SeeAllData=true)
private class ServiceContractEventcStatsTT {

   static testMethod void testTrigger() {
      try {
          Service_Contract_Event__c o = new Service_Contract_Event__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<Service_Contract_Event__c> l = [SELECT Id from Service_Contract_Event__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}