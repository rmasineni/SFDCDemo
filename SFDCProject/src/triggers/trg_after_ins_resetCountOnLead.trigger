trigger trg_after_ins_resetCountOnLead on CampaignMember (after insert) {
    List<Lead> leadlst=new List<Lead>();
    for(CampaignMember cm:trigger.new){
        if(cm.leadid!=null&&cm.CampaignId!=null){
         Lead l=new Lead();
         l.id=cm.leadid;
         l.Campaign_Call_Attempts__c=0;
         Leadlst.add(l);
        }
    }
    if(!leadlst.isempty()){
    update leadlst;
    }
}