trigger trg_aft_inst_UpdateCampaignNum on Task (after insert) {
    List<Lead> ldList=new List<Lead>();
    Map<id,String> LeadCampignIds=new Map<id,String>();
    Map<id,Integer> campaignCount=new Map<id,Integer>();
    Map<String,Integer> currentCampaignCount=new Map<String,Integer>();
    for(task t:trigger.new){
        if(t.type=='Call'&&t.Five9__Five9Campaign__c!=null&&t.WhoId!=null){
            LeadCampignIds.put(t.whoId,t.Five9__Five9Campaign__c);
        }
    }
    if(!LeadCampignIds.isempty()){
        for(task t:[select id,whoid,Five9__Five9Campaign__c from task where whoid in:LeadCampignIds.keySet() order by createddate]){
            if(campaignCount.containsKey(t.whoid)){
                campaignCount.put(t.whoid,campaignCount.get(t.whoid)+1);
            }
            else{
                campaignCount.put(t.whoid,1);
            }
            if(currentCampaignCount.containsKey(t.whoid+t.Five9__Five9Campaign__c)){
                currentCampaignCount.put(t.whoid+t.Five9__Five9Campaign__c,currentCampaignCount.get(t.whoid+t.Five9__Five9Campaign__c)+1);
            }
            else{
                currentCampaignCount.put(t.whoid+t.Five9__Five9Campaign__c,1);
            }
        }
        for(Id id:LeadCampignIds.keySet()){
            Lead l=new Lead();
            l.id=id;
            if(campaignCount.containsKey(id))
            l.Total_Call_Attempts__c=campaignCount.get(id);
            if(LeadCampignIds.containsKey(id)&&currentCampaignCount.containsKey(id+LeadCampignIds.get(id)))
            l.Campaign_Call_Attempts__c=currentCampaignCount.get(id+LeadCampignIds.get(id));
            ldList.add(l);
        }
    }
    if(!ldList.isempty()){
        update ldList;
    }
}