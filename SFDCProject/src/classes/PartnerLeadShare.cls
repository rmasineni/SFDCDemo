public with sharing class PartnerLeadShare {
  public static void PartnerLeadShare(List<Lead> lst_Leads,Map<id,Lead> oldMap,Boolean isinsert,Boolean isUpdate){  
  Set<id> leadIds=new Set<id>();      
  for(Lead l:lst_Leads){
    if(l.salesrep__c!=null&&l.createdbyid!=l.salesrep__c&&(isinsert||(isupdate&&(l.salesrep__c!=oldMap.get(l.id).salesrep__c)))){
      leadIds.add(l.id);
    }
    
  }
  if(!leadIds.isempty()){
    PartnerLeadShare.doLeadSharing(leadIds);
  }
  }
  @future
  public static void doLeadSharing(Set<id> leadIds){
    List<LeadShare> LSShareList=new List<LeadShare>();
    List<Lead> Ld_List=new List<Lead>();
    for(Lead l:[select id,salesrep__c,ownerid,salesrep__r.usertype from lead where id in:leadIds]){
      if(l.salesrep__r.usertype=='PowerPartner'){
          LeadShare LS=new LeadShare();
          LS.LeadAccessLevel='Edit';
          LS.LeadId=l.id;
          LS.UserOrGroupId=l.salesrep__c;
          LSShareList.add(LS);
          l.ownerid=l.salesrep__c;
          ld_List.add(l);
      }
    }
    //if(!LSShareList.isempty()){
    //  database.insert(LSShareList);
    //}
    if(!LSShareList.isempty()){
    try {
         
            Database.SaveResult[] results = Database.insert(LSShareList,false);
            if (results != null){
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()) {
                        Database.Error[] errs = result.getErrors();
                        for(Database.Error err : errs)
                            System.debug(err.getStatusCode() + ' - ' + err.getMessage());
         
                    }
                }
            }
         
            } 
          catch (Exception e) {
            System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
          } 
     }
    if(!ld_List.isempty()){
      update ld_List;
    }
  }      
}