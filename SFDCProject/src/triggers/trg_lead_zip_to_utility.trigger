trigger trg_lead_zip_to_utility on Lead (before insert, before update) {
/*
    Set<String> zipcodeSet=new Set<String>();
    Map<String,ZipUtility__c> ZipUtilityMap=new Map<String,ziputility__c>();
    for(lead l:trigger.new){
        if(l.postalcode!=null&&l.postalcode!=''&&l.PostalCode.length()>=5){
            zipcodeSet.add(l.postalcode.substring(0,5));
        }                              
    }
    system.debug('----->zipcodeSet'+zipcodeSet);
    if(!zipcodeset.isempty()){
        for(ZipUtility__c z:[select State__c,Utility_Company__c,Territory__c,Zip_Code__c from ZipUtility__c where Zip_Code__c in:zipCodeSet]){
        ZipUtilityMap.put(z.zip_code__c,z);
    }
        for(lead l:trigger.new){
            if(l.postalcode!=null&&l.postalcode!=''&&l.PostalCode.length()>=5){
                if(ZipUtilityMap.containsKey(l.postalcode.substring(0,5))){
                l.Utility_Company__c=ZipUtilityMap.get(l.postalcode.substring(0,5)).utility_company__c;
                l.Territory__c=ZipUtilityMap.get(l.postalcode.substring(0,5)).Territory__c;  
                l.state= ZipUtilityMap.get(l.postalcode.substring(0,5)).state__c;         
                }
            }          
           
                                             
        }
    }
    if(trigger.isbefore&&Userinfo.getUserType()=='PowerPartner'){
        Set<string> zipSet=new Set<String>();
        Set<string> stateSet=new Set<String>();
        Set<String> zipcodesset=new set<String>();
        User u=[select id,contactid from user where id=:userinfo.getUserId()];
        Contact c=[select accountid from contact where id=:u.contactid];
        Map<String,Market_Assignment__c> maMap=new Map<String,Market_Assignment__c>();  
        for(lead l:trigger.new){
        if(l.PostalCode!=null&&l.Postalcode.length()>=5){
        zipset.add(l.postalcode.substring(0,5));
        zipcodesset.add(l.postalcode.substring(0,5));
        }
        if(l.state!=null){
        stateset.add(l.state);
        zipcodesset.add(l.state);
        }        
        for(market_assignment__c ma:[select market__r.utility_company__c,market__r.state__c,zipcodes__c,role__c,Select_All_Zipcodes__c,Territory__c,Partner__c,partner__r.Lead_Eligible__c from Market_Assignment__c where (start_date__c<=today and end_date__c>=today and role__c includes ('Sales') and partner__r.Lead_Eligible__c=true and partner__r.Active__c=true and partner__c=:c.accountid)or( start_date__c<=today and end_date__c>=today and role__c includes ('Sales') and partner__r.Lead_Eligible__c=true and partner__r.Active__c=true and market__r.state__c in:stateSet and partner__c=:c.accountid)  order by Select_All_Zipcodes__c nulls last]){
        for(string zip:zipcodesset){                    
                    if(!String.isempty(ma.Zipcodes__c)&&!String.isempty(zip)&&ma.Zipcodes__c.contains(zip.trim())){
                        maMap.put(zip+' '+ma.Market__r.state__c+' '+ma.Market__r.utility_company__c+' '+ma.partner__c,ma);
                    }
                    if(ma.Select_All_Zipcodes__c==true&&!String.isempty(ma.market__r.state__c)&&stateset.contains(ma.market__r.state__c)){
                       maMap.put(ma.Market__r.state__c+' '+ma.Market__r.utility_company__c+' '+ma.partner__c,ma);
                    }
                }   
        }
        }
        for(lead l:trigger.new){            
            l.Sales_Partner__c=c.AccountId;
            if(l.PostalCode!=null&&l.PostalCode.length()>=5){
            if(maMap.containsKey(l.postalcode.substring(0,5)+' '+l.state+' '+l.utility_company__c+' '+c.accountid)){                
                l.Market_Assignment_Sales__c=maMap.get(l.postalcode.substring(0,5)+' '+l.state+' '+l.utility_company__c+' '+c.accountid).id;
                if(maMap.get(l.postalcode.substring(0,5)+' '+l.state+' '+l.utility_company__c+' '+c.accountid).role__c.contains('Install')){
                l.Install_Partner__c=maMap.get(l.postalcode.substring(0,5)+' '+l.state+' '+l.utility_company__c+' '+c.accountid).partner__c;
                l.Market_Assignment_Install__c=maMap.get(l.postalcode.substring(0,5)+' '+l.state+' '+l.utility_company__c+' '+c.accountid).id;  
                }                           
            }
            }
            if(l.state!=null&&l.Market_Assignment_Sales__c==null){
            if(maMap.containsKey(l.state+' '+l.utility_company__c+' '+c.accountid)){                
                l.Market_Assignment_Sales__c=maMap.get(l.state+' '+l.utility_company__c+' '+c.accountid).id;
                if(maMap.get(l.state+' '+l.utility_company__c+' '+c.accountid).role__c.contains('Install')){
                l.Install_Partner__c=maMap.get(l.state+' '+l.utility_company__c+' '+c.accountid).partner__c;
                l.Market_Assignment_Install__c=maMap.get(l.state+' '+l.utility_company__c+' '+c.accountid).id;  
                }                           
            }   
            }           
        }       
        }
  */      
}