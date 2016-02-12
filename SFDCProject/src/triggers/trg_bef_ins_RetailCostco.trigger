trigger trg_bef_ins_RetailCostco on Opportunity (before insert) {
	Set<id> LeadIds=new Set<id>();
	for(Opportunity opp:trigger.new){
		if(opp.Lead_Organization_Location_2__c!=null){
			opp.Costco_Purchase_Thru_Warehouse__c=opp.Lead_Organization_Location_2__c;
		}
		if(opp.Lead_Id__c!=null){
			LeadIds.add(opp.Lead_Id__c);
		}
	}
	if(!LeadIds.isempty()){
		List<OpportunityCampaignRemoval__c> lst_OpptyCampaigns = OpportunityCampaignRemoval__c.getAll().values();
		Set<String> CampaignNames=new Set<String>();	
		for(OpportunityCampaignRemoval__c OCR:lst_OpptyCampaigns){
			CampaignNames.add(OCR.Campaign__c);
		}	
		List<CampaignMember> cmList=[Select id,Campaign.name from CampaignMember where LeadId in:LeadIds and Campaign.name in:CampaignNames];
                if(!cmList.isempty()){
                    delete cmList;
                }
	}
}