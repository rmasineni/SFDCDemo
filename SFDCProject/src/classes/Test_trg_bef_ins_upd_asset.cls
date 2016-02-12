@isTest(SeeAllData=true)
public with sharing class Test_trg_bef_ins_upd_asset {
   public static testMethod void Test_trg_bef_ins_upd_asset (){
    Test.starttest();
    Recordtype r=[select id,Name from recordtype where sobjecttype='Asset__c' and Name='Meter' limit 1];  
    ServiceContract sc = [Select id,agreement_number__c from ServiceContract where agreement_number__c !=null limit 1];
    Asset__c att = new Asset__c (Status__c ='Active', Type__c='Meter', Serial_Number__c='12345', ServiceContract__c=sc.id,Meter_Type__c ='SS iTRon',Recordtypeid=r.Id);
    Asset__c att1 = new Asset__c (Status__c ='Active', Type__c='Meter', Serial_Number__c='123453', ServiceContract__c=sc.id,Meter_Type__c ='SS iTRon',Recordtypeid=r.Id);
    List<Asset__c> assList = new List<Asset__c>();
    assList.add(att);
    assList.add(att1);
    insert assList;  
    Test.stoptest();
   }
}