trigger trg_before_inset_leadOppAssign on Partner_Assignment_Staging__c (before insert) {
    List<Arizona_MA__c> lst_arizonaMA = Arizona_MA__c.getAll().values(); 
    Map<String,Arizona_MA__c> UtilityMAMap=new Map<String,Arizona_MA__c>(); 
    Set<String> stateSet=new Set<String>();
    for(Arizona_MA__c az:lst_arizonaMA){
        UtilityMAMap.put(az.Utility_Company__c+az.role__c,az);
        stateSet.add(az.state__c);
    }  
    for(Partner_Assignment_Staging__c pas:trigger.new){
        if(pas.lead_state__c!=null&&stateSet.contains(pas.lead_state__c)){
            if(pas.lead_state__c=='HI'&&pas.Lead_Source__c!=null&&pas.Lead_Source__c.contains('Home Depot')&&UtilityMAMap.keySet().contains(pas.lead_utility_company__c+'Sales')){
            pas.Sales_Market_Assignment__c=UtilityMAMap.get(pas.lead_utility_company__c+'Sales').MA_Id__c;  
            pas.Account__c =UtilityMAMap.get(pas.lead_utility_company__c+'Sales').Sales_Partner_Id__c;                     
            }            
            if(pas.lead_state__c=='HI'&&pas.Lead_Source__c!=null&&pas.Lead_Source__c.contains('Home Depot')&&UtilityMAMap.keySet().contains(pas.lead_utility_company__c+'Install')){
            pas.Install_Market_Assignment__c=UtilityMAMap.get(pas.lead_utility_company__c+'Install').MA_Id__c;
            }
        }
    }

}