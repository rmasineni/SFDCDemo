public with sharing class SearchSalesInstallForPartners {
    //@future
    public static void SearchSalesInstallForPartners(Set<id> LdIds){    
    Set<string> zipSet=new Set<String>();
    Set<string> stateSet=new Set<String>();
    Set<String> zipcodeset=new set<String>();
    Set<string> UtilitySet=new Set<String>();
    //User u=[select id,contactid from user where id=:userinfo.getUserId()];
    //Contact c=[select accountid from contact where id=:u.contactid];
    List<lead> leadList=[select id,Install_Partner__c,market_assignment_Install__c,utility_company__c,state,postalcode from lead where id in:LdIds];
    for(lead l:leadList){
        if(l.PostalCode!=null&&l.Postalcode.length()>=5){
        zipset.add(l.postalcode.substring(0,5));
        zipcodeset.add(l.postalcode.substring(0,5));      
            UtilitySet.add(l.utility_company__c);        
        }
        if(l.state!=null){
        stateset.add(l.state);
        zipcodeset.add(l.state);
        UtilitySet.add(l.utility_company__c);       
        }  
    }
    doFindInstallPartner(leadList,zipcodeset,stateset,UtilitySet);
    
    }   
     public static void doFindInstallPartner(List<Lead> LdList,Set<String> zipCodeMap,Set<String> stateset,Set<String> utilSet){
      //   system.debug('--utilitySet'+utilSet);
      //   system.debug('--stateset'+stateset);
         String query='select market__r.utility_company__c,market__r.Total_Current_No_Of_Leads_Install__c,Current_No_Of_Leads_Install__c,market__r.Duration_in_days__c,Install_Partner_age_distribution__c,market__r.state__c,zipcodes__c,role__c,Select_All_Zipcodes__c,Utility_Company__c,Territory__c,Partner__c,partner__r.Lead_Eligible__c from Market_Assignment__c where ';
            query+= '(start_date__c<=today and end_date__c>=today and role__c includes (\'Install\') and partner__r.Lead_Eligible__c=true and partner__r.Active__c=true and Install_Partner_age_distribution__c>0 and market__r.utility_company__c in:utilset';     
            query+=')or( start_date__c<=today and end_date__c>=today and role__c includes (\'Install\') and partner__r.Lead_Eligible__c=true and partner__r.Active__c=true and Install_Partner_age_distribution__c>0 and market__r.state__c in:stateset and market__r.utility_company__c in:utilset ) order by install_partner_age_distribution__c asc';

        //List<Market_Assignment__c> maList=[select market__r.utility_company__c,market__r.Total_Current_No_Of_Leads_Install__c,Current_No_Of_Leads_Install__c,market__r.Duration_in_days__c,Install_Partner_age_distribution__c,market__r.state__c,zipcodes__c,role__c,Select_All_Zipcodes__c,Utility_Company__c,Territory__c,Partner__c,partner__r.Lead_Eligible__c from Market_Assignment__c where (start_date__c<=today and end_date__c>=today and role__c includes ('Install') and partner__r.Lead_Eligible__c=true and partner__r.Active__c=true and Install_Partner_age_distribution__c>0 and market__r.utility_company__c in:utilSet)or( start_date__c<=today and end_date__c>=today and role__c includes ('Install') and partner__r.Lead_Eligible__c=true and partner__r.Active__c=true and market__r.state__c in:stateSet and Install_Partner_age_distribution__c>0 and market__r.utility_company__c in:utilSet) order by Install_Partner_age_distribution__c asc];
        List<Market_Assignment__c> maList=database.query(query);
        //List<Market_Assignment__c> maList=[select market__r.utility_company__c,market__r.Total_Current_No_Of_Leads_Install__c,Current_No_Of_Leads_Install__c,market__r.Duration_in_days__c,Install_Partner_age_distribution__c,market__r.state__c,zipcodes__c,role__c,Select_All_Zipcodes__c,Utility_Company__c,Territory__c,Partner__c,partner__r.Lead_Eligible__c from Market_Assignment__c where (start_date__c<=today and end_date__c>=today and role__c includes ('Install') and partner__r.Lead_Eligible__c=true and partner__r.Active__c=true and Install_Partner_age_distribution__c>0)or( start_date__c<=today and end_date__c>=today and role__c includes ('Install') and partner__r.Lead_Eligible__c=true and partner__r.Active__c=true and market__r.state__c in:stateSet and Install_Partner_age_distribution__c>0) order by Install_Partner_age_distribution__c asc];
        system.debug('malist'+malist);
        Map<string,List<Market_Assignment__c>> maMap=new Map<string,List<Market_Assignment__c>>();
        Map<String,Partner_Assignment_Staging__c> paMap=new Map<String,Partner_Assignment_Staging__c>();   
        Map<id,decimal> installmarketLeadCountMap=new Map<id,decimal>();            
        Set<id> maIds=new Set<id>();
        decimal durationInDays=10;
        decimal TotalResults=1;
        Market_Assignment__c m=new Market_Assignment__c();
        if(!maList.isempty()){
            if(maList[0].market__r.Total_Current_No_Of_Leads_Install__c!=0)
            TotalResults=maList[0].market__r.Total_Current_No_Of_Leads_Install__c;  
        }  
        for(Market_Assignment__c ma:maList){
                for(string zip:zipCodeMap){
                    maIds.add(ma.id);                   
                    if(!String.isempty(ma.Zipcodes__c)&&!String.isempty(zip)&&ma.Zipcodes__c.contains(zip.trim())){                       
                        installmarketLeadCountMap.put(ma.id,ma.Current_No_Of_Leads_Install__c);
                        List<Market_Assignment__c> temp=maMap.get(zip+' '+ma.market__r.state__c+' '+ma.market__r.utility_company__c);
                        if(temp==null)
                        maMap.put(zip+' '+ma.market__r.state__c+' '+ma.market__r.utility_company__c,new List<Market_Assignment__c>{ma});
                        else{
                        temp.add(ma);
                        }
                    }
                    if(ma.Select_All_Zipcodes__c==true&&!String.isempty(ma.market__r.state__c)&&stateset.contains(ma.market__r.state__c)){
                        installmarketLeadCountMap.put(ma.id,ma.Current_No_Of_Leads_Install__c);
                        List<Market_Assignment__c> temp=maMap.get(ma.market__r.state__c+' '+ma.market__r.utility_company__c);                        
                        if(temp==null)
                        maMap.put(ma.market__r.state__c+' '+ma.market__r.utility_company__c,new List<Market_Assignment__c>{ma});
                        else
                        temp.add(ma);
                    }
                }
            }
        if(zipCodeMap.size()>0){             
                /*   
                Map<id,list<market_assignment__c>> leadMaMap=new Map<id,List<Market_assignment__c>>();                  
                for(Lead l:LdList){
                    if(maMap.containsKey(l.State+' '+l.utility_company__c)||(l.PostalCode!=null&&maMap.containsKey(l.PostalCode.substring(0,5)+' '+l.state+' '+l.Utility_Company__c))){                     
                    if(maMap.containsKey(l.State+' '+l.utility_company__c)){                                              
                        for(Market_Assignment__c marList:maMap.get(l.State+' '+l.utility_company__c)){
                        List<Market_Assignment__c> temp=leadMaMap.get(l.id);                        
                        if(temp==null)
                        leadMaMap.put(l.id,new List<Market_Assignment__c>{marList});
                        else
                        temp.add(marList);                                                                  
                      }
                    }
                    if(l.PostalCode!=null&&maMap.containsKey(l.PostalCode.substring(0,5)+' '+l.state+' '+l.utility_company__c)){                                               
                        for(Market_Assignment__c marList:maMap.get(l.PostalCode.substring(0,5)+' '+l.state+' '+l.utility_company__c)){
                        List<Market_Assignment__c> temp=leadMaMap.get(l.id);                        
                        if(temp==null)
                        leadMaMap.put(l.id,new List<Market_Assignment__c>{marList});
                        else
                        temp.add(marList);                                             
                    }
                    }  
                    }                                      
                }
                system.debug('----install leadMaMap??'+leadMaMap); 
                */ 
                //Map<id,Market_Assignment__c> updateMAMap=new Map<id,Market_Assignment__c>();     
                system.debug('----install maMap??'+maMap);                                                         
                for(lead l:LdList){ 
                    List<market_assignment__c> tempList=new List<market_assignment__c>();
                    if(l.PostalCode!=null&&maMap.containsKey(l.PostalCode.substring(0,5)+' '+l.state+' '+l.utility_company__c)){
                        tempList=maMap.get(l.PostalCode.substring(0,5)+' '+l.state+' '+l.utility_company__c);
                    }
                    else if(maMap.containsKey(l.State+' '+l.utility_company__c)){
                        tempList=maMap.get(l.State+' '+l.utility_company__c);
                    }                
                    if(!tempList.isempty()){                        
                        //List<market_assignment__c> tempList=leadMaMap.get(l.id);
                        decimal maxPercentage=tempList[0].Install_Partner_age_distribution__c;
                        decimal currentPercentage=0;
                        for(integer i=0;i<tempList.size();i++){
                            if(tempList[i].Install_Partner_age_distribution__c>=maxPercentage){
                                maxPercentage=tempList[i].Install_Partner_age_distribution__c;
                                system.debug('----install maxPercentage??'+maxPercentage);
                                if(installmarketLeadCountMap.containsKey(tempList[i].id)){ 
                                currentPercentage=(installmarketLeadCountMap.get(tempList[i].id)*100)/TotalResults;
                                }                           
                                if(maxPercentage>currentPercentage){
                                    l.market_assignment_Install__c=tempList[i].id;  
                                    l.Install_Partner__c=tempList[i].Partner__c;  
                                    m=tempList[i];                                                                                          
                                }
                                else{
                                    maxPercentage=0;
                                    currentPercentage=0;
                                }
                            }                           
                        }
                        if(l.market_assignment_Install__c==null){
                                l.market_assignment_Install__c=tempList[0].id;
                                maxPercentage=tempList[0].Install_Partner_age_distribution__c;
                                for(integer i=0;i<tempList.size();i++){                                 
                                    if(tempList[i].Install_Partner_age_distribution__c>=maxPercentage){
                                    maxPercentage=tempList[i].Install_Partner_age_distribution__c;
                                    l.market_assignment_Install__c=tempList[i].id;  
                                    l.Install_Partner__c=tempList[i].Partner__c; 
                                    m=tempList[i];                                  
                                    }
                                }
                                
                            }
                    }
/*                    
//BSKY-4890 -  Populate Install Branch only when Install Partner is Sunrun          
                      if(l.Install_Partner__c != null && l.Install_Partner__c != System.Label.Sunrun_Inc_Id){
                         System.debug('BSKY-4890: SearchInstallForPartners' +l.Install_Partner__c);  
                         System.debug('BSKY-4890: LeadId' +l.Id);  
                         l.Install_Branch__c = '';
                      }     
*/
                if(l.Install_Partner__c!=null && l.Install_Partner__c!=System.Label.Sunrun_Inc_Id){
                  LeadTriggerClass.clearLeadFields(l);
                  nullOutFactors.nullOutFactors(l);
                  }
                }                
            } 
            if(!System.isfuture()&&!System.isBatch()&&!ldList.isempty()&&Trigger.isexecuting&&Trigger.isAfter){
            system.debug('ldList:'+ldList);
            update ldList;
            }
            /*
            else if(System.isfuture()){
            database.update(ldList,false);
            }
            */
            if(m!=null&&m.Current_No_Of_Leads_Install__c!=null){
            m.Current_No_Of_Leads_Install__c++;
            update m;   
            }        
     }
      
}