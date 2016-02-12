trigger JurisdictionOnOpptyTrigger on Account (after insert, after update) {

 set<Id> accountIds = new Set<Id>();
 Map<Id,String> accIncorpMap = new Map<Id,String>();
 List<Opportunity> optyList = new List<Opportunity>();
 List<Opportunity> updateOptyList = new List<Opportunity>();
 
 for(Account acc : trigger.new){
  if(acc.Account_Type__c == 'Residential'){
   if((Trigger.isInsert && acc.Incorporation_Flag__c != null) || (Trigger.isUpdate && acc.Incorporation_Flag__c != Trigger.oldMap.get(acc.Id).Incorporation_Flag__c)){
     accountIds.add(acc.Id);
     accIncorpMap.put(acc.Id,acc.Incorporation_Flag__c );
   }
  }
 }
 
 if(!accountIds.isEmpty()){ 
  optyList = [select Id, AccountId, Incorporation_Status__c from Opportunity where AccountId in : accountIds]; 
 }

 if(!optyList.isEmpty()){
   for(Opportunity opp: optyList){
    if(opp.Incorporation_Status__c!= accIncorpMap.get(opp.AccountId)){
      opp.Incorporation_Status__c= accIncorpMap.get(opp.AccountId);
    }
    updateOptyList.add(opp);
   }
 }
 
 if(!updateOptyList.isEmpty()){
   update updateOptyList;
 }
}