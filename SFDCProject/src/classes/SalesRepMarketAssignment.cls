public with sharing class SalesRepMarketAssignment {
    public static void doSalesRepMarketAssignment(List<Lead> lead_List,Map<id,Lead> old_map){
        Set<id> leadIds=new Set<id>();
        if(Userinfo.getUserType()!='PowerPartner'){
        for(Lead lead:lead_List){
            if(lead.salesrep__c!=null&&lead.SalesRep_Contact__c!=null&&old_map.get(lead.id).salesrep__c!=lead.salesrep__c&&lead.sales_partner__c==System.label.sunrun_inc_id){
                leadIds.add(lead.id);
            }
        }
        if(!leadIds.isempty()){
            SalesRepMarketAssignment.doMarketAssignments(leadIds);
        }
        }
    }
    @future
    public static void doMarketAssignments(Set<id> leadIds){
        List<lead> leadList=[select id,salesrep__r.accountid,state,postalcode,utility_company__c from lead where id in:leadIds];
        Set<id> accIds=new Set<id>();
        Set<String> Utility=new set<String>();
        Set<string> State=new Set<String>();
        for(lead lead:leadList){
            accIds.add(lead.salesrep__r.accountid);
            utility.add(lead.utility_company__c);
            state.add(lead.state);
        }
        Map<string,market_assignment__c> maMap=new Map<String,market_assignment__c>();
        List<Market_Assignment__c> maList=[select market__r.utility_company__c,market__r.Total_Current_No_Of_Leads_Install__c,market__r.Total_Current_No_Of_Leads_Sales__c,Current_No_Of_Leads_Sales__c,Current_No_Of_Leads_Install__c,Sales_Partner_age_distribution__c,Install_Partner_age_distribution__c,market__r.state__c,zipcodes__c,role__c,Select_All_Zipcodes__c,Utility_Company__c,Territory__c,Partner__c,partner__r.Lead_Eligible__c from Market_Assignment__c where (start_date__c<=today and end_date__c>=today and role__c includes ('Sales','Install') and market__r.utility_company__c in:utility and market__r.state__c in:state and Partner__c in:accIds) order by Sales_Partner_age_distribution__c asc];      
        for(Market_assignment__c ma:maList){
            if(ma.Select_All_Zipcodes__c){
                if(ma.role__c.contains('Sales'))
                maMap.put(ma.market__r.state__c+ma.market__r.utility_company__c+ma.partner__c+'Sales',ma);
                if(ma.role__c.contains('Install'))
                maMap.put(ma.market__r.state__c+ma.market__r.utility_company__c+ma.partner__c+'Install',ma);
            }
            else if(ma.zipcodes__c!=null&&!ma.Select_All_Zipcodes__c){
                if(ma.role__c.contains('Sales')){
                    for(string temp:ma.zipcodes__c.split(',')){
                        maMap.put(temp+ma.market__r.utility_company__c+ma.partner__c+'Sales',ma);
                    }
                }
                if(ma.role__c.contains('Install')){
                    for(string temp:ma.zipcodes__c.split(',')){
                        maMap.put(temp+ma.market__r.utility_company__c+ma.partner__c+'Install',ma);
                    }
                }
            }
        }
        if(!maMap.isempty()){
            List<Partner_Assignment_Staging__c> paList=new List<Partner_Assignment_Staging__c>();
            for(lead lead:leadList){
                if(maMap.containskey(lead.state+lead.utility_company__c+lead.salesrep__r.accountid+'Sales')){
                Partner_Assignment_Staging__c pa=new Partner_Assignment_Staging__c(Account__c=maMap.get(lead.state+lead.utility_company__c+lead.salesrep__r.accountid+'Sales').partner__c,Lead__c=lead.id,Market_Assignment__c=true);
                    pa.sales_market_assignment__c=maMap.get(lead.state+lead.utility_company__c+lead.salesrep__r.accountid+'Sales').id;
                    if(maMap.containskey(lead.state+lead.utility_company__c+lead.salesrep__r.accountid+'Install')){
                    pa.install_market_assignment__c=maMap.get(lead.state+lead.utility_company__c+lead.salesrep__r.accountid+'Sales').id;
                    }
                    palist.add(pa);
                }
                else if(maMap.containskey(lead.postalcode+lead.utility_company__c+lead.salesrep__r.accountid+'Sales')){
                    Partner_Assignment_Staging__c pa=new Partner_Assignment_Staging__c(Account__c=maMap.get(lead.postalcode+lead.utility_company__c+lead.salesrep__r.accountid+'Sales').partner__c,Lead__c=lead.id,Market_Assignment__c=true);
                    pa.sales_market_assignment__c=maMap.get(lead.postalcode+lead.utility_company__c+lead.salesrep__r.accountid+'Sales').id;
                    if(maMap.containskey(lead.postalcode+lead.utility_company__c+lead.salesrep__r.accountid+'Install')){
                    pa.install_market_assignment__c=maMap.get(lead.postalcode+lead.utility_company__c+lead.salesrep__r.accountid+'Sales').id;
                    }
                    palist.add(pa);
                }
                
            }
            if(!palist.isempty()){
                insert palist;
            }
        }
    }

}