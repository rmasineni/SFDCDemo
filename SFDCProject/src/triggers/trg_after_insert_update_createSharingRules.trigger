trigger trg_after_insert_update_createSharingRules on Opportunity (after insert, after update) {
    
    List<OpportunityShare> opptyShares = new List<OpportunityShare>();
    for(opportunity opp:trigger.new){
        if(opp.Lead_Generated_by__c!=null){
            if(Trigger.isinsert||(Trigger.isupdate&&trigger.oldMap.get(opp.id).Lead_Generated_by__c!=opp.Lead_Generated_by__c)){
            OpportunityShare os=new OpportunityShare(OpportunityId=opp.id,OpportunityAccessLevel='Edit',UserOrGroupid=opp.Lead_Generated_by__c );
            opptyShares.add(os);
            }
        }
    }
        if(!opptyShares.isEmpty()){
           try {
         
            Database.SaveResult[] results = Database.insert(opptyShares,false);
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