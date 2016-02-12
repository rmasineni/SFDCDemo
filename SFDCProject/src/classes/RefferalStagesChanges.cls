public with sharing class RefferalStagesChanges {  
  @future
  public static void updateReferralStatus(Set<id> ids,String status, String ObjectName){
    List<Referral_input__c> list_referrals=new List<Referral_input__c>();
    String query='select id,lead__c,opportunity__c,service_contract__c from Referral_input__c where';
    query+=' '+ObjectName+' in:ids' ;
    for(Referral_input__c RefObj:database.query(query)){
      RefObj.Referral_status__c=Status;
      list_referrals.add(RefObj);
    }
    if(!list_referrals.isempty()){
      update list_referrals;
    } 
  }  
}