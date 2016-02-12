public with sharing class FindMarketsManual {
	public static Map<String,Market_Assignment__c> doFindSalesMarket( Set<String> zipCodeSet,Set<String> stateset,Set<id> partnerIds,Set<String> utilitySet){
		 Map<string,Market_Assignment__c> maMap=new Map<string,Market_Assignment__c>();
    	List<Market_Assignment__c> maList=[select market__r.utility_company__c,market__r.Total_Current_No_Of_Leads_Install__c,market__r.Total_Current_No_Of_Leads_Sales__c,Current_No_Of_Leads_Sales__c,Current_No_Of_Leads_Install__c,Sales_Partner_age_distribution__c,Install_Partner_age_distribution__c,market__r.state__c,zipcodes__c,role__c,Select_All_Zipcodes__c,Utility_Company__c,Territory__c,Partner__c,partner__r.Lead_Eligible__c from Market_Assignment__c where (start_date__c<=today and end_date__c>=today and role__c includes ('Sales') and partner__r.Lead_Eligible__c=true and partner__r.Active__c=true and Sales_Partner_age_distribution__c>0 and market__r.utility_company__c in:utilitySet and partner__c in:partnerIds)or( start_date__c<=today and end_date__c>=today and role__c includes ('Sales') and partner__r.Lead_Eligible__c=true and partner__r.Active__c=true and market__r.state__c in:stateSet and Sales_Partner_age_distribution__c>0 and market__r.utility_company__c in:utilitySet and partner__c in:partnerIds) order by Sales_Partner_age_distribution__c asc];
    	for(Market_assignment__c ma:maList){
    		for(string zip:zipCodeSet){                   
                    if(!String.isempty(ma.Zipcodes__c)&&!String.isempty(zip)&&ma.Zipcodes__c.contains(zip.trim())){
                        maMap.put(ma.partner__c+ma.market__r.utility_company__c+ma.market__r.state__c,ma);                        
                    }
                    if(ma.Select_All_Zipcodes__c==true&&!String.isempty(ma.market__r.state__c)&&stateset.contains(ma.market__r.state__c)){
                        maMap.put(ma.partner__c+ma.market__r.utility_company__c+ma.market__r.state__c,ma);
                    }
                }
    	}
    	return maMap;
	}
	public static Map<String,Market_Assignment__c> doFindInstallMarket( Set<String> zipCodeSet,Set<String> stateset,Set<id> partnerIds,Set<String> utilitySet){
		 Map<string,Market_Assignment__c> maMap=new Map<string,Market_Assignment__c>();
    	List<Market_Assignment__c> maList=[select market__r.utility_company__c,market__r.Total_Current_No_Of_Leads_Install__c,market__r.Total_Current_No_Of_Leads_Sales__c,Current_No_Of_Leads_Sales__c,Current_No_Of_Leads_Install__c,Sales_Partner_age_distribution__c,Install_Partner_age_distribution__c,market__r.state__c,zipcodes__c,role__c,Select_All_Zipcodes__c,Utility_Company__c,Partner__c from Market_Assignment__c where (start_date__c<=today and end_date__c>=today and role__c includes ('Install') and partner__r.Lead_Eligible__c=true and partner__r.Active__c=true and Install_Partner_age_distribution__c>0 and market__r.utility_company__c in:utilitySet and partner__c in:partnerIds)or( start_date__c<=today and end_date__c>=today and role__c includes ('Install') and partner__r.Lead_Eligible__c=true and partner__r.Active__c=true and market__r.state__c in:stateSet and Install_Partner_age_distribution__c>0 and market__r.utility_company__c in:utilitySet and partner__c in:partnerIds) order by Install_Partner_age_distribution__c asc];
    	for(Market_assignment__c ma:maList){
    		for(string zip:zipCodeSet){                   
                    if(!String.isempty(ma.Zipcodes__c)&&!String.isempty(zip)&&ma.Zipcodes__c.contains(zip.trim())){
                        maMap.put(ma.partner__c+ma.market__r.utility_company__c+ma.market__r.state__c,ma);                        
                    }
                    if(ma.Select_All_Zipcodes__c==true&&!String.isempty(ma.market__r.state__c)&&stateset.contains(ma.market__r.state__c)){
                        maMap.put(ma.partner__c+ma.market__r.utility_company__c+ma.market__r.state__c,ma);
                    }
                }
    	}
    	return maMap;
	}
}