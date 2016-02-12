trigger AccountOwnerToSalesRep on Opportunity (after update) {
  Map<id,id> AccountSalesRepMap=new Map<id,id>();
  Set<id> opptyIds=new Set<id>();
  for(Opportunity oppObj:trigger.new){
    if(oppObj.SalesRep__c!=null&&Trigger.oldMap.get(oppObj.id).SalesRep__c!=oppObj.SalesRep__c){
      AccountSalesRepMap.put(oppObj.accountid,oppObj.SalesRep__c);
      opptyIds.add(oppObj.id);
    }
  }
  if(!AccountSalesRepMap.isempty()){
    List<Account> accList=new List<Account>();
    for(Id accId:AccountSalesRepMap.keyset()){
      Account acc=new Account();
      acc.id=accId;
      acc.ownerid=AccountSalesRepMap.get(accId);
      accList.add(acc);
    }
    if(!accList.isempty()){
      update accList;
    }
  }
  if(!opptyIds.isempty()){
    OpportunitySalesRepUpdate.OpportunitySalesRepUpdate(opptyIds);
  }

}