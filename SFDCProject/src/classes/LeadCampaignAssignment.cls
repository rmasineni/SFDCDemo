public with sharing class LeadCampaignAssignment {
    public static void LeadCampaigns(List<lead> lstLeads){
        List<CampaignMember> cmList=new List<CampaignMember>();
        List<Lead_Campaign__c> lst_LeadCampaign = Lead_Campaign__c.getAll().values();        
        if(!lst_LeadCampaign.isEmpty()&&lst_LeadCampaign[0].X3rd_Party__c!=null){
        for(lead l:lstLeads){
            if(l.Channel__c!=null&& l.External_Source__c!='Sunrun.com Click-to-Call' && l.Channel__c.equalsIgnoreCase('3rd Party')&&l.Custom_Lead_Source__c!='3rd Party: Media Mix'&&l.Custom_Lead_Source__c!='3rd Party: Clean Energy Experts LT'&&l.Custom_Lead_Source__c!='3rd Party: Solar Media Team'&&l.Custom_Lead_Source__c!='3rd Party: Home Improvement LT'&&l.Lead_Status__c!='Unqualified'){
                CampaignMember cm=new CampaignMember(CampaignId=lst_LeadCampaign[0].X3rd_Party__c,leadid=l.id);
                cmList.add(cm);
                system.debug('### List of CM###:'+ cmList);
            }
             if(l.External_Source__c!=null&& l.External_Source__c=='Sunrun.com Click-to-Call')
            {     
                CampaignMember cm1=new CampaignMember(CampaignId=lst_LeadCampaign[1].Five9_click_to_call__c,leadid=l.id);
                cmList.add(cm1);   
                system.debug('### List of CM###:'+ cmList);
            }
        }
        }
        if(!cmList.isempty()){
            system.debug('### List of CM###:'+ cmList);
            database.insert(cmList,false);
        }
        
    }
}