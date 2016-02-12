public with sharing class PartnerOpptyShare {
public static void PartnerOpptyShare(List<Opportunity> lst_Oppts,Map<id,Opportunity> oldMap,Boolean isinsert,Boolean isUpdate){ 
    Set<id> OppIds=new Set<id>(); 
    for(Opportunity o:lst_Oppts){        
        if(o.salesrep__c!=null&&o.createdbyid!=o.salesrep__c&&(isinsert||(isupdate&&(o.salesrep__c!=oldMap.get(o.id).salesrep__c)))){
            OppIds.add(o.id);
        }                
    }
    if(!OppIds.isempty()){
        PartnerOpptyShare.doOpptySharing(OppIds);
    }    
    }
    @future
    public static void doOpptySharing(Set<id> OppIds){
        List<OpportunityShare> OSShareList=new List<OpportunityShare>();
        for(Opportunity o:[select id,salesrep__c,salesrep__r.usertype from Opportunity where id in:OppIds]){
            if(o.salesrep__r.usertype=='PowerPartner'){
                OpportunityShare OS=new OpportunityShare();
                OS.OpportunityAccessLevel='Edit';
                OS.OpportunityId=o.id;
                OS.UserOrGroupId=o.salesrep__c;
                OSShareList.add(OS);
            }
        }
        if(!OSShareList.isempty()){
            //insert OSShareList;
            try {
         
            Database.SaveResult[] results = Database.insert(OSShareList,false);
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
    }           
}