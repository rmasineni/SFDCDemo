@isTest(SeeAllData=true)
private with sharing class UnitTest_trg_createSharingRules  {

  static testmethod void UnitTest_trg_createSharingRules(){
   List<RecordType> rt = [ Select Id from RecordType Where sObjectType='Account' AND Name='Partner'];
        Account Ac  = new Account(Name='REC Solar', Active__c=true, RecordTypeId=rt[0].Id, channel_type__c='Retail', Office_Location__c='Headquarters',   Stage__c='Confirmed' );
        insert Ac;
  Opportunity Opp=new Opportunity(name='Test',stagename='Open',closedate=system.today(),Lead_Organization_Location_2__c=ac.id,Lead_Generated_by__c=userinfo.getuserid());
  insert opp;
  }
  }