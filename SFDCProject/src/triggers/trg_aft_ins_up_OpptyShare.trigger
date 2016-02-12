trigger trg_aft_ins_up_OpptyShare on Opportunity (after insert, after update) {
    PartnerOpptyShare.PartnerOpptyShare(trigger.new,trigger.oldmap,trigger.isinsert,trigger.isupdate);
    if(trigger.isupdate){
        Set<id> refferalStatusUpdate=new Set<id>();
        Set<id> refferalOtherStatusUpdate=new Set<id>();
        for(Opportunity oppObj:trigger.new){
            if(oppObj.referral__c!=null&&oppObj.StageName=='9. Closed Lost'&&trigger.oldMap.get(oppObj.id).stageName!=oppObj.stageName){
                refferalStatusUpdate.add(oppObj.id);    
            }
            if(oppObj.referral__c!=null&&oppObj.StageName!='9. Closed Lost'&&trigger.oldMap.get(oppObj.id).stageName=='9. Closed Lost'){
                refferalOtherStatusUpdate.add(oppObj.id);    
            }
        }
        if(!refferalStatusUpdate.isempty()){
            RefferalStagesChanges.updateReferralStatus(refferalStatusUpdate,'Not Ready for Solar Now','Opportunity__c');
        }    
        if(!refferalOtherStatusUpdate.isempty()){
            RefferalStagesChanges.updateReferralStatus(refferalOtherStatusUpdate,'Solar Consultation In-Progress','Opportunity__c');
        }
    }
}