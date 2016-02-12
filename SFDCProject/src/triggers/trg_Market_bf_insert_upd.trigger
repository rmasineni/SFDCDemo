trigger trg_Market_bf_insert_upd on market__c (after insert, after update) {
	Set<id> marketIds=new Set<id>();
	List<market_assignment__c> malist=new List<market_assignment__c>();
	for(market__c m:trigger.new){
		if(m.Number_of_Leads__c<=m.Total_Current_No_Of_Leads_Install__c||m.Number_of_Leads__c<=m.Total_Current_No_Of_Leads_sales__c){
			marketIds.add(m.id);
		}
	}
	for(Market_Assignment__c ma:[select Current_No_Of_Leads_Sales__c,Current_No_Of_Leads_Install__c from market_assignment__c where market__c in:marketIds]){
		ma.Current_No_Of_Leads_Install__c=0;
		ma.Current_no_of_Leads_Sales__C=0;
		malist.add(ma);
	}
	if(!maList.isempty())
	update malist;
}