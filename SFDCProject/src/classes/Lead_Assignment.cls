/******************************************************************************
    Class Name:Lead_Assignment
    Date:
    Author:Prashanth Veloori & Karthik Ariharapakam
    Description: Class called upon lead create/update for assignment of lead based
                 on Market Assignment and Partner Promotions. 
*******************************************************************************/
    public with sharing class Lead_Assignment{
    public static Integer marketAssignmentKey;  
    public static Integer offerPromoAssignmentKey;
    public static Integer referralPromoAssignmentKey;
    public static Integer sunrunDirectKey;
    public static List<Partner_Assignment_Staging__c> partnerAssignList;
    @future
    public static void Lead_Assignment(Set<id> LdIds){    
    marketAssignmentKey=1;  
    offerPromoAssignmentKey=1;
    referralPromoAssignmentKey=1;
    sunrunDirectKey=1;
    partnerAssignList=new List<Partner_Assignment_Staging__c>();
    Map<string,List<Lead>> zipCodeMap= new Map<string,List<Lead>>();
    Set<String> stateSet=new Set<String>();
    Set<String> utilitySet=new Set<String>();
    Map<String,Partner_Assignment_Staging__c> paMap=new Map<String,Partner_Assignment_Staging__c>();
    List<Lead> LdList=new List<Lead>();
    List<Lead> noMALds=new List<Lead>();
    List<Lead> leadList=[select Utility_company__c,Referral_web_form__c,state,Referral_Input__c,Custom_Lead_Source__c,Referred_By_Contact__c,offer__r.promotion__c,Referral_Input__r.promotion__c,postalcode,Offer_Promo_Name__c,Lock_Assignment__c from lead where id in:LdIds  order by Referred_By_Contact__c nulls last];    
    for(Lead l:leadList){
        if(l.Utility_Company__c!=null){
            utilitySet.add(l.Utility_Company__c);
        }
        if(l.Referred_By_Contact__c==null &&l.Referral_web_form__c==false && l.offer__c==null && l.postalcode==null && l.state==null){
            Partner_Assignment_Staging__c pa = new Partner_Assignment_Staging__c(Lead__c=l.id,No_Data__c=true);
            partnerAssignList.add(pa);
        } 
        else if(l.Referred_By_Contact__c==null&&l.Referral_web_form__c==true){
            Partner_Assignment_Staging__c pa=new Partner_Assignment_Staging__c(Lead__c=l.id,Referral_from_Web__c=true);
            partnerAssignList.add(pa);
        } 
            
        else if(l.postalcode!=null&&l.postalcode.length()>=5){     
        List<Lead> temp=zipCodeMap.get(l.postalcode.substring(0,5));
        if(temp==null){
        zipCodeMap.put(l.postalcode.substring(0,5),new List<Lead>{l});
        }
        else{ 
        temp.add(l);
           }
        }     
        else if(l.state!=null&&l.postalcode==null){
        List<Lead> temp=zipCodeMap.get(l.state);
           if(temp==null){ 
           zipCodeMap.put(l.state,new List<Lead>{l});
             }
             else{
             temp.add(l);
              }
           }
           else{
        List<Lead> temp=zipCodeMap.get('NoStateNoZip');
        if(temp==null){ 
        zipCodeMap.put('NoStateNoZip',new List<Lead>{l});
           }
             else
             temp.add(l);    
            }   
        stateSet.add(l.state);  
         }
         if(zipCodeMap.size()>0){
         for(integer i=0;i<zipCodeMap.values().size();i++){
         LdList.addall(zipCodeMap.values().get(i));
          }
        }
    system.debug('----leadList'+LdList);
    system.debug('----zipCodeMapnew'+zipCodeMap);
    
    List<Assignment_Order__c> aoList=[select Order__c,Assignment_Criteria__c from Assignment_Order__c  order by order__c limit 4];
    if(aoList[0].Assignment_Criteria__c=='Market Assignment'){
    doMarketAssignmentQ2(LdList,zipCodeMap,stateSet,aoList,utilitySet);
    }
    else if(aoList[0].Assignment_Criteria__c=='Offer Promotion'){
    doOfferPromotion(LdList,zipCodeMap,stateSet,aoList,utilitySet);    
    }
    else if(aoList[0].Assignment_Criteria__c=='Referral Promotion'){
    doReferralPromotion(LdList,zipCodeMap,stateSet,aoList,utilitySet); 
      }
    }
    
    
    public static void Lead_Assignment_Immediate(Set<id> LdIds){    
    marketAssignmentKey=1;  
    offerPromoAssignmentKey=1;
    referralPromoAssignmentKey=1;
    sunrunDirectKey=1;
    partnerAssignList=new List<Partner_Assignment_Staging__c>();
    Map<string,List<Lead>> zipCodeMap= new Map<string,List<Lead>>();
    Set<String> stateSet=new Set<String>();
    Set<String> utilitySet=new Set<String>();
    Map<String,Partner_Assignment_Staging__c> paMap=new Map<String,Partner_Assignment_Staging__c>();
    List<Lead> LdList=new List<Lead>();
    List<Lead> noMALds=new List<Lead>();
    List<Lead> leadList=[select Utility_company__c,Referral_web_form__c,state,Custom_Lead_Source__c,Referral_Input__c,Referred_By_Contact__c,offer__r.promotion__c,Referral_Input__r.promotion__c,postalcode,Offer_Promo_Name__c,Lock_Assignment__c from lead where id in:LdIds  order by Referred_By_Contact__c nulls last];    
    for(Lead l:leadList){
         if(l.Utility_Company__c!=null){
            utilitySet.add(l.Utility_Company__c);
        }
        if(l.Referred_By_Contact__c==null &&l.Referral_web_form__c==false && l.offer__c==null && l.postalcode==null && l.state==null){
            Partner_Assignment_Staging__c pa = new Partner_Assignment_Staging__c(Lead__c=l.id,No_Data__c=true);
            partnerAssignList.add(pa);
        } 
        else if(l.Referred_By_Contact__c==null&&l.Referral_web_form__c==true){
            Partner_Assignment_Staging__c pa=new Partner_Assignment_Staging__c(Lead__c=l.id,Referral_from_Web__c=true);
            partnerAssignList.add(pa);
        } 
            
        else if(l.postalcode!=null&&l.PostalCode.length()>=5){     
        List<Lead> temp=zipCodeMap.get(l.postalcode.substring(0,5));
        if(temp==null){
        zipCodeMap.put(l.postalcode.substring(0,5),new List<Lead>{l});
        }
        else{ 
        temp.add(l);
           }
        }     
        else if(l.state!=null&&l.postalcode==null){
        List<Lead> temp=zipCodeMap.get(l.state);
           if(temp==null){ 
           zipCodeMap.put(l.state,new List<Lead>{l});
             }
             else{
             temp.add(l);
              }
           }
           else{
        List<Lead> temp=zipCodeMap.get('NoStateNoZip');
        if(temp==null){ 
        zipCodeMap.put('NoStateNoZip',new List<Lead>{l});
           }
             else
             temp.add(l);    
            }   
        stateSet.add(l.state);  
         }
         if(zipCodeMap.size()>0){
         for(integer i=0;i<zipCodeMap.values().size();i++){
         LdList.addall(zipCodeMap.values().get(i));
          }
        }
    system.debug('----leadList'+LdList);
    system.debug('----zipCodeMapnew'+zipCodeMap);
    
    List<Assignment_Order__c> aoList=[select Order__c,Assignment_Criteria__c from Assignment_Order__c  order by order__c limit 4];
    if(aoList[0].Assignment_Criteria__c=='Market Assignment'){
    doMarketAssignmentQ2(LdList,zipCodeMap,stateSet,aoList,utilitySet);
    }
    else if(aoList[0].Assignment_Criteria__c=='Offer Promotion'){
    doOfferPromotion(LdList,zipCodeMap,stateSet,aoList,utilitySet);    
    }
    else if(aoList[0].Assignment_Criteria__c=='Referral Promotion'){
    doReferralPromotion(LdList,zipCodeMap,stateSet,aoList,utilitySet); 
      }
    }
     /*
    Market Assignment method finds a match for a Lead with related Partner Promotion record based on Zip or state(Market_Assignment__c object is searched) on Lead. 
    If no match found it procedes to next assigmnet method based on the assignment order table.
    */
    /*
     public static void doMarketAssignment(List<Lead> LdList,Map<string,List<Lead>> zipCodeMap,Set<String> stateset,List<Assignment_Order__c> aoList){  
            Map<String,List<Lead>> noMALds=new Map<String,List<Lead>>();    
            Map<String,Partner_Assignment_Staging__c> paMap=new Map<String,Partner_Assignment_Staging__c>();        
            Map<string,List<Market_Assignment__c>> maMap=new Map<string,List<Market_Assignment__c>>();
        if(marketAssignmentKey==1){                 
            List<Market_Assignment__c> maList=[select market__r.state__c,zipcodes__c,role__c,Select_All_Zipcodes__c,Utility_Company__c,Territory__c,Partner__c,partner__r.Lead_Eligible__c from Market_Assignment__c where (start_date__c<=today and end_date__c>=today and role__c includes ('Sales') and partner__r.Lead_Eligible__c=true and partner__r.Active__c=true)or( start_date__c<=today and end_date__c>=today and role__c includes ('Sales') and partner__r.Lead_Eligible__c=true and partner__r.Active__c=true and market__r.state__c in:stateSet )];
            for(Market_Assignment__c ma:maList){
                for(string zip:zipCodeMap.keyset()){
                    system.debug('----mazip'+ma.zipcodes__c);
                    system.debug('----corrzip'+zip);
                    if(!String.isempty(ma.Zipcodes__c)&&!String.isempty(zip)&&ma.Zipcodes__c.contains(zip.trim())){
                        List<Market_Assignment__c> temp=maMap.get(zip);
                        if(temp==null)
                        maMap.put(zip,new List<Market_Assignment__c>{ma});
                        else{
                        temp.add(ma);
                        system.debug('---matemp'+temp);
                        }
                    }
                    if(ma.Select_All_Zipcodes__c==true&&!String.isempty(ma.market__r.state__c)&&stateset.contains(ma.market__r.state__c)){
                        List<Market_Assignment__c> temp=maMap.get(ma.market__r.state__c);                        
                        if(temp==null)
                        maMap.put(ma.market__r.state__c,new List<Market_Assignment__c>{ma});
                        else
                        temp.add(ma);
                    }
                }
            }
            system.debug('---->malist'+maList);
            system.debug('---->stateset'+stateset);
            system.debug('---->maMap'+maMap.get('45433'));
            system.debug('---->zipcodemapkeyset'+zipCodeMap.keyset());
            system.debug('---->ldMapWithZip'+zipCodeMap.size());
            system.debug('---->market lead list size'+LdList.size());
            if(zipCodeMap.size()>0){
                for(Lead l:LdList){
                    if(maMap.containsKey(l.State)||(l.PostalCode!=null&&maMap.containsKey(l.PostalCode))){
                    if(maMap.containsKey(l.State)){                        
                        for(Market_Assignment__c marList:maMap.get(l.State)){                       
                        if(marList.partner__r.Lead_Eligible__c==true&&l.lock_Assignment__c==false&&!paMap.containsKey(l.id+''+marList.partner__c)){
                            Partner_Assignment_Staging__c pa=new Partner_Assignment_Staging__c(Account__c=marlist.partner__c,Lead__c=l.id,Market_Assignment__c=true);
                            if(marList.Role__c.contains('Sales')){
                                pa.sales_market_assignment__c=marlist.id;
                            }
                            if(marList.Role__c.contains('Install')){
                                pa.Install_market_assignment__c=marlist.id;
                            }
                            paMap.put(l.id+''+marList.partner__c,pa);
                        }                       
                        
                      }
                    }
                    if(l.PostalCode!=null&&maMap.containsKey(l.PostalCode)){                        
                        for(Market_Assignment__c marList:maMap.get(l.PostalCode)){                      
                        if(marList.partner__r.lead_eligible__c==true&&l.lock_Assignment__c==false&&!paMap.containsKey(l.id+''+marList.partner__c)){
                            Partner_Assignment_Staging__c pa=new Partner_Assignment_Staging__c(Account__c=marList.partner__c,Lead__c=l.id,Market_Assignment__c=true);
                            if(marList.Role__c.contains('Sales')){
                                pa.sales_market_assignment__c=marlist.id;
                            }
                            if(marList.Role__c.contains('Install')){
                                pa.Install_market_assignment__c=marlist.id;
                            }
                            paMap.put(l.id+''+marList.partner__c,pa);
                        }                      
                    }
                    }  
                    }                  
                    else if(l.PostalCode!=null){                     
                    List<Lead> temp=noMALds.get(l.PostalCode);                                      
                    if(temp==null)  
                    noMALds.put(l.PostalCode,new List<Lead>{l});
                    else{
                    temp.add(l);
                    }
                    }
                    else{                    
                    List<Lead> temp=noMALds.get('NoStateNoZip');                                        
                    if(temp==null)  
                    noMALds.put('NoStateNoZip',new List<Lead>{l});
                    else{
                    temp.add(l);
                    }
                    }
                }
            }
        system.debug('---pamapmarket'+paMap);
        system.debug('---noMALds'+noMALds);
        system.debug('---noMALds values size'+noMALds.values().size());
        system.debug('---noMALds size'+noMALds.size());
        if(paMap.size()>0){
        partnerAssignList.addall(paMap.values());
        LdList.clear();
        system.debug('---LdList clear'+LdList);
        
        }           
        marketAssignmentKey++;      
        if(noMALds.size()>0){
        LdList=new List<Lead>();        
        for(integer i=0;i<noMALds.values().size();i++){     
        LdList.addall(noMALds.values().get(i));
        }       
        if(aoList[0].Assignment_Criteria__c=='Market Assignment'){
            if(aoList[1].Assignment_Criteria__c=='Offer Promotion')
            doOfferPromotion(LdList,noMALds,stateset,aoList);
            else if(aoList[1].Assignment_Criteria__c=='Referral Promotion')
            doReferralPromotion(LdList,noMALds,stateset,aoList);          
        }
        else if(aoList[1].Assignment_Criteria__c=='Market Assignment'){
            if(aoList[2].Assignment_Criteria__c=='Offer Promotion')
            doOfferPromotion(LdList,noMALds,stateset,aoList);
            else if(aoList[2].Assignment_Criteria__c=='Referral Promotion')
            doReferralPromotion(LdList,noMALds,stateset,aoList);          
        }       
        else if(aoList[2].Assignment_Criteria__c=='Market Assignment'){
            doDefaultSunRunDirect(LdList,noMALds,stateset,aoList);
                }   
            }
            if(!partnerAssignList.isempty()){
                    doInsertPartnerAssignmentTable();
                }    
                   
        }
        
    }
    */
     public static void doMarketAssignmentQ2(List<Lead> LdList,Map<string,List<Lead>> zipCodeMap,Set<String> stateset,List<Assignment_Order__c> aoList,Set<String> utilitySet){
        //Set<string> utilitySet=new Set<String>();
        /*for(lead l:LdList){
            if(l.utility_company__c!=null)
            utilitySet.add(l.utility_company__c);
        }*/
        List<Market_Assignment__c> maList=[select market__r.utility_company__c,market__r.Total_Current_No_Of_Leads_Install__c,market__r.Total_Current_No_Of_Leads_Sales__c,Current_No_Of_Leads_Sales__c,Current_No_Of_Leads_Install__c,Sales_Partner_age_distribution__c,Install_Partner_age_distribution__c,market__r.state__c,zipcodes__c,role__c,Select_All_Zipcodes__c,Utility_Company__c,Territory__c,Partner__c,partner__r.Lead_Eligible__c from Market_Assignment__c where (start_date__c<=today and end_date__c>=today and role__c includes ('Sales') and partner__r.Lead_Eligible__c=true and partner__r.Active__c=true and Sales_Partner_age_distribution__c>0 and market__r.utility_company__c in:utilitySet)or( start_date__c<=today and end_date__c>=today and role__c includes ('Sales') and partner__r.Lead_Eligible__c=true and partner__r.Active__c=true and market__r.state__c in:stateSet and Sales_Partner_age_distribution__c>0 and market__r.utility_company__c in:utilitySet) order by Sales_Partner_age_distribution__c asc];
        Map<string,List<Market_Assignment__c>> maMap=new Map<string,List<Market_Assignment__c>>();
        Map<String,Partner_Assignment_Staging__c> paMap=new Map<String,Partner_Assignment_Staging__c>();                
        Map<String,List<Lead>> noMALds=new Map<String,List<Lead>>();
        Map<id,decimal> salesmarketLeadCountMap=new Map<id,decimal>();
        Set<id> maIds=new Set<id>(); 
        //decimal durationInDays=10;
        decimal TotalResults=1;
        if(!maList.isempty()){
            if(maList[0].market__r.Total_Current_No_Of_Leads_Sales__c!=0)
            TotalResults=maList[0].market__r.Total_Current_No_Of_Leads_Sales__c;
        //durationInDays= maList[0].market__r.Duration_in_days__c;
        }  
        for(Market_Assignment__c ma:maList){                
                for(string zip:zipCodeMap.keyset()){
                    maIds.add(ma.id);
                    system.debug('----mazip'+ma.zipcodes__c);
                    system.debug('----corrzip'+zip);
                    if(!String.isempty(ma.Zipcodes__c)&&!String.isempty(zip)&&ma.Zipcodes__c.contains(zip.trim())){
                        salesmarketLeadCountMap.put(ma.id,ma.Current_No_Of_Leads_Sales__c);
                        List<Market_Assignment__c> temp=maMap.get(zip+' '+ma.market__r.state__c+' '+ma.market__r.utility_company__c);
                        if(temp==null)
                        maMap.put(zip+' '+ma.market__r.state__c+' '+ma.market__r.utility_company__c,new List<Market_Assignment__c>{ma});
                        else{
                        temp.add(ma);
                        system.debug('---matemp'+temp);
                        }
                    }
                    if(ma.Select_All_Zipcodes__c==true&&!String.isempty(ma.market__r.state__c)&&stateset.contains(ma.market__r.state__c)){
                        salesmarketLeadCountMap.put(ma.id,ma.Current_No_Of_Leads_Sales__c);
                        List<Market_Assignment__c> temp=maMap.get(ma.market__r.state__c+' '+ma.market__r.utility_company__c);                        
                        if(temp==null)
                        maMap.put(ma.market__r.state__c+' '+ma.market__r.utility_company__c,new List<Market_Assignment__c>{ma});
                        else
                        temp.add(ma);
                    }
                }
            }
            system.debug('---maMap'+maMap);
            if(zipCodeMap.size()>0){                
                Map<id,list<market_assignment__c>> leadMaMap=new Map<id,List<Market_assignment__c>>();              
                        
                for(Lead l:LdList){
                    if(l.state!=null){
                        if(maMap.containsKey(l.State.touppercase()+' '+l.utility_company__c)||(l.PostalCode!=null&&maMap.containsKey(l.PostalCode.substring(0,5)+' '+l.State.touppercase()+' '+l.Utility_Company__c))){                     
                        if(maMap.containsKey(l.State.touppercase()+' '+l.utility_company__c)){                                                
                            for(Market_Assignment__c marList:maMap.get(l.State.touppercase()+' '+l.Utility_Company__c)){
                            List<Market_Assignment__c> temp=leadMaMap.get(l.id);                        
                            if(temp==null)
                            leadMaMap.put(l.id,new List<Market_Assignment__c>{marList});
                            else
                            temp.add(marList);                                                                  
                          }
                        }
                        if(l.PostalCode!=null&&maMap.containsKey(l.PostalCode.substring(0,5)+' '+l.State.touppercase()+' '+l.Utility_Company__c)){                                             
                            for(Market_Assignment__c marList:maMap.get(l.PostalCode.substring(0,5)+' '+l.State.touppercase()+' '+l.Utility_Company__c)){
                            List<Market_Assignment__c> temp=leadMaMap.get(l.id);                        
                            if(temp==null)
                            leadMaMap.put(l.id,new List<Market_Assignment__c>{marList});
                            else
                            temp.add(marList);                                           
                        }
                        }  
                        } 
                        else{
                        List<Lead> temp=noMALds.get(l.state);                                      
                        if(temp==null)  
                        noMALds.put(l.state,new List<Lead>{l});
                        else{
                        temp.add(l);
                        }   
                        }                        
                    }           
                    else if(l.PostalCode!=null&&l.PostalCode.length()>=5){                     
                    List<Lead> temp=noMALds.get(l.PostalCode.substring(0,5));                                      
                    if(temp==null)  
                    noMALds.put(l.PostalCode.substring(0,5),new List<Lead>{l});
                    else{
                    temp.add(l);
                    }
                    }
                    else{                    
                    List<Lead> temp=noMALds.get('NoStateNoZip');                                        
                    if(temp==null)  
                    noMALds.put('NoStateNoZip',new List<Lead>{l});
                    else{
                    temp.add(l);
                    }
                    }
                }
                system.debug('----leadMaMap??'+leadMaMap);   
                //Map<id,market_assignment__c> updateMAMap=new Map<id,Market_Assignment__c>();                                                          
                for(lead l:LdList){                 
                    if(leadMaMap.containsKey(l.id)){                        
                        List<market_assignment__c> tempList=leadMaMap.get(l.id);
                        decimal maxPercentage=tempList[0].Sales_Partner_age_distribution__c;
                        decimal currentPercentage=0;
                        system.debug('----maxPercentage??'+maxPercentage);
                        system.debug('----tempListsize??'+tempList.size());                                                                                         
                        for(integer i=0;i<tempList.size();i++){
                            if(tempList[i].Sales_Partner_age_distribution__c>=maxPercentage){
                                maxPercentage=tempList[i].Sales_Partner_age_distribution__c;                                
                                system.debug('----currentpercent??'+salesmarketLeadCountMap.get(tempList[i].id));
                                if(salesmarketLeadCountMap.containsKey(tempList[i].id)){ 
                                system.debug('----currentpercentdivide'+salesmarketLeadCountMap.get(tempList[i].id)*100/TotalResults);                                                                                                  
                                currentPercentage=(salesmarketLeadCountMap.get(tempList[i].id)*100)/TotalResults;
                                system.debug('----currentPercentage??'+currentPercentage);  
                                system.debug('----maxPercentage??'+maxPercentage);
                                }                           
                                if(maxPercentage>currentPercentage){
                                  if ((l.Custom_Lead_Source__c!=null&&!l.Custom_Lead_Source__c.containsIgnoreCase(System.label.Mickey_Account)) ||                                                     //Mickey
                                      (l.Custom_Lead_Source__c!=null&&l.Custom_Lead_Source__c.containsIgnoreCase(System.label.Mickey_Account)&&tempList[i].Partner__c==System.label.sunrun_inc_Id)){   //Mickey  
                                    system.debug('----Market Match??'+tempList[i]);
                                    Partner_Assignment_Staging__c pa=new Partner_Assignment_Staging__c(Account__c=tempList[i].partner__c,Lead__c=l.id,Market_Assignment__c=true);
                                    pa.sales_market_assignment__c=tempList[i].id;                                   
                                    if(tempList[i].role__c.contains('Install')){
                                    /*    if((l.Custom_Lead_Source__c!=null&&l.Custom_Lead_Source__c.containsIgnoreCase('Costco')&&tempList[i].Partner__c==System.label.sunrun_inc_Id)||
                                           (l.Custom_Lead_Source__c!=null&&l.Custom_Lead_Source__c.containsIgnoreCase(System.label.Mickey_Account)&&tempList[i].Partner__c==System.label.sunrun_inc_Id)||        //Mickey
                                           (l.Custom_Lead_Source__c!=null&&!l.Custom_Lead_Source__c.containsIgnoreCase('Costco')&&!l.Custom_Lead_Source__c.containsIgnoreCase(System.label.Mickey_Account))){    //Mickey     */
                                        
                                        if((l.Custom_Lead_Source__c!=null&&l.Custom_Lead_Source__c.containsIgnoreCase(System.label.Mickey_Account)&&tempList[i].Partner__c==System.label.sunrun_inc_Id)||        //Mickey
                                           (l.Custom_Lead_Source__c!=null&&!l.Custom_Lead_Source__c.containsIgnoreCase(System.label.Mickey_Account))){    //Mickey      
                                             pa.Install_market_assignment__c=tempList[i].id;
                                        } 
                                        else{
                                            doFindInstallPartner(LdList,zipCodeMap,stateset, aoList, pa,utilityset);
                                        }                                
                                    }
                                    else{
                                    doFindInstallPartner(LdList,zipCodeMap,stateset, aoList, pa,utilityset);    
                                    }
                                    paMap.put(l.id,pa);                                 
                                  }else{
                                    maxPercentage=0;
                                    currentPercentage=0;
                                  } 
                                }
                                else{
                                    maxPercentage=0;
                                    currentPercentage=0;
                                }
                            }
                        }
                        if(paMap.isempty()){
                                                                
                                maxPercentage=tempList[0].sales_Partner_age_distribution__c;
                                market_assignment__c ma=tempList[0];
                                for(integer i=0;i<tempList.size();i++){                                 
                                    if(tempList[i].sales_Partner_age_distribution__c>=maxPercentage){
                                    maxPercentage=tempList[i].sales_Partner_age_distribution__c;    
                                    ma=tempList[i];                                                                                                 
                                    }
                                    }  
                                    if((l.Custom_Lead_Source__c!=null&&!l.Custom_Lead_Source__c.containsIgnoreCase(System.label.Mickey_Account)) ||                                            //Mickey
                                       (l.Custom_Lead_Source__c!=null&&l.Custom_Lead_Source__c.containsIgnoreCase(System.label.Mickey_Account)&&ma.Partner__c==System.label.sunrun_inc_Id)){   //Mickey  
                                    Partner_Assignment_Staging__c pa=new Partner_Assignment_Staging__c(Account__c=ma.partner__c,Lead__c=l.id,Market_Assignment__c=true);
                                    pa.sales_market_assignment__c=ma.id;
                                    if(ma.role__c.contains('Install')){
                                    /*   if((l.Custom_Lead_Source__c!=null&&l.Custom_Lead_Source__c.containsIgnoreCase('Costco')&&ma.Partner__c==System.label.sunrun_inc_Id)||
                                          (l.Custom_Lead_Source__c!=null&&l.Custom_Lead_Source__c.containsIgnoreCase(System.label.Mickey_Account)&&ma.Partner__c==System.label.sunrun_inc_Id)||                  //Mickey
                                          (l.Custom_Lead_Source__c!=null&&!l.Custom_Lead_Source__c.containsIgnoreCase('Costco')&&!l.Custom_Lead_Source__c.containsIgnoreCase(System.label.Mickey_Account))){     //Mickey  */

                                        if((l.Custom_Lead_Source__c!=null&&l.Custom_Lead_Source__c.containsIgnoreCase(System.label.Mickey_Account)&&ma.Partner__c==System.label.sunrun_inc_Id)||                  //Mickey
                                          (l.Custom_Lead_Source__c!=null&&!l.Custom_Lead_Source__c.containsIgnoreCase(System.label.Mickey_Account))){     //Mickey                        

                                        pa.Install_market_assignment__c=ma.id;                                  
                                        }
                                        else{
                                        doFindInstallPartner(LdList,zipCodeMap,stateset, aoList, pa,utilityset);
                                        }
                                    }
                                    else{
                                    doFindInstallPartner(LdList,zipCodeMap,stateset, aoList, pa,utilityset);    
                                    }
                                    paMap.put(l.id,pa);                             

                                    }else{            //Mickey
                                        boolean mickeyMarketAssignmentFound = false;
                               //         maxPercentage=tempList[0].sales_Partner_age_distribution__c;
                                         
                                        for(integer i=0;i<tempList.size();i++){                                 
                               //          if(tempList[i].sales_Partner_age_distribution__c>=maxPercentage && !mickeyMarketAssignmentFound){
                                           if(!mickeyMarketAssignmentFound){ 
                               //              maxPercentage=tempList[i].sales_Partner_age_distribution__c;    
                                                 
                                             if(l.Custom_Lead_Source__c!=null&&l.Custom_Lead_Source__c.containsIgnoreCase(System.label.Mickey_Account)&&tempList[i].Partner__c==System.label.sunrun_inc_Id){
                                                Partner_Assignment_Staging__c pa=new Partner_Assignment_Staging__c(Account__c=tempList[i].partner__c,Lead__c=l.id,Market_Assignment__c=true);
                                                mickeyMarketAssignmentFound = true;
                                                pa.sales_market_assignment__c=tempList[i].id;
                                                if(tempList[i].role__c.contains('Install')){
                                                  if(l.Custom_Lead_Source__c!=null&&l.Custom_Lead_Source__c.containsIgnoreCase(System.label.Mickey_Account)&&tempList[i].Partner__c==System.label.sunrun_inc_Id){       //Mickey                                    
                                                      pa.Install_market_assignment__c=tempList[i].id;                                  
                                                  }else{
                                                        doFindInstallPartner(LdList,zipCodeMap,stateset, aoList, pa,utilityset);
                                                  }
                                                }else{
                                                    doFindInstallPartner(LdList,zipCodeMap,stateset, aoList, pa,utilityset);    
                                                }
                                                paMap.put(l.id,pa);                             
                                             }           //if
                                            }           //if
                                         }             //for  

                                        if(!mickeyMarketAssignmentFound){
                                            System.debug('No Mickey Market Assignment');
                                            Partner_Assignment_Staging__c pa=new Partner_Assignment_Staging__c(Account__c=ma.partner__c,Lead__c=l.id,Market_Assignment__c=true);
                                            pa.sales_market_assignment__c=tempList[0].id;
                                            System.debug('Mickey Sales Partner3 :' +pa.sales_market_assignment__c);
                                            if(ma.role__c.contains('Install')){
                                              if(l.Custom_Lead_Source__c!=null&&l.Custom_Lead_Source__c.containsIgnoreCase(System.label.Mickey_Account)&&ma.Partner__c==System.label.sunrun_inc_Id){ 
                                                 pa.Install_market_assignment__c=ma.id;                                  
                                                 System.debug('Mickey Install Partner3 :' +pa.Install_market_assignment__c);
                                              }else{
                                                  doFindInstallPartner(LdList,zipCodeMap,stateset, aoList, pa,utilityset);
                                              }
                                            }else{
                                                doFindInstallPartner(LdList,zipCodeMap,stateset, aoList, pa,utilityset);    
                                            }
                                            paMap.put(l.id,pa); 
                                        }                                                                                           
                                    }                 //Mickey
                            }
                    }
                }                
            }
        if(paMap.size()>0){
        partnerAssignList.addall(paMap.values());
        LdList.clear();
        system.debug('---LdList clear'+LdList);        
        }           
        //marketAssignmentKey++;      
        if(noMALds.size()>0){
        LdList=new List<Lead>();        
        for(integer i=0;i<noMALds.values().size();i++){     
        LdList.addall(noMALds.values().get(i));
        }       
        if(aoList[0].Assignment_Criteria__c=='Market Assignment'){
            if(aoList[1].Assignment_Criteria__c=='Offer Promotion')
            doOfferPromotion(LdList,noMALds,stateset,aoList,utilitySet);
            else if(aoList[1].Assignment_Criteria__c=='Referral Promotion')
            doReferralPromotion(LdList,noMALds,stateset,aoList,utilitySet);          
        }
        else if(aoList[1].Assignment_Criteria__c=='Market Assignment'){
            if(aoList[2].Assignment_Criteria__c=='Offer Promotion')
            doOfferPromotion(LdList,noMALds,stateset,aoList,utilitySet);
            else if(aoList[2].Assignment_Criteria__c=='Referral Promotion')
            doReferralPromotion(LdList,noMALds,stateset,aoList,utilitySet);          
        }       
        else if(aoList[2].Assignment_Criteria__c=='Market Assignment'){
            doDefaultSunRunDirect(LdList,noMALds,stateset,aoList,utilitySet);
                }   
            }
            if(!partnerAssignList.isempty()){
                    doInsertPartnerAssignmentTable();
                }    
     }
     
     public static void doFindInstallPartner(List<Lead> LdList,Map<string,List<Lead>> zipCodeMap,Set<String> stateset,List<Assignment_Order__c> aoList,Partner_Assignment_Staging__c pa,set<string> utilityset){
        List<Market_Assignment__c> maList=[select market__r.utility_company__c,market__r.Total_Current_No_Of_Leads_Install__c,Current_No_Of_Leads_Install__c,market__r.Duration_in_days__c,Install_Partner_age_distribution__c,market__r.state__c,zipcodes__c,role__c,Select_All_Zipcodes__c,Utility_Company__c,Territory__c,Partner__c,partner__r.Lead_Eligible__c from Market_Assignment__c where (start_date__c<=today and end_date__c>=today and role__c includes ('Install') and partner__r.Lead_Eligible__c=true and partner__r.Active__c=true and Install_Partner_age_distribution__c>0 and market__r.utility_company__c in:utilityset)or( start_date__c<=today and end_date__c>=today and role__c includes ('Install') and partner__r.Lead_Eligible__c=true and partner__r.Active__c=true and market__r.state__c in:stateSet and Install_Partner_age_distribution__c>0 and market__r.utility_company__c in:utilityset) order by Install_Partner_age_distribution__c asc];
        Map<string,List<Market_Assignment__c>> maMap=new Map<string,List<Market_Assignment__c>>();
        Map<String,Partner_Assignment_Staging__c> paMap=new Map<String,Partner_Assignment_Staging__c>();   
        Map<id,decimal> installmarketLeadCountMap=new Map<id,decimal>();            
        Set<id> maIds=new Set<id>();
        decimal durationInDays=10;
        decimal TotalResults=1;
        if(!maList.isempty()){
            if(maList[0].market__r.Total_Current_No_Of_Leads_Install__c!=0)
            TotalResults=maList[0].market__r.Total_Current_No_Of_Leads_Install__c;  
        }  
        for(Market_Assignment__c ma:maList){
                for(string zip:zipCodeMap.keyset()){
                    maIds.add(ma.id);
                    system.debug('----installmazip'+ma.zipcodes__c);
                    system.debug('----installcorrzip'+zip);
                    if(!String.isempty(ma.Zipcodes__c)&&!String.isempty(zip)&&ma.Zipcodes__c.contains(zip.trim())){
                        installmarketLeadCountMap.put(ma.id,ma.Current_No_Of_Leads_Install__c);
                        List<Market_Assignment__c> temp=maMap.get(zip+' '+ma.market__r.state__c+' '+ma.market__r.utility_company__c);
                        if(temp==null)
                        maMap.put(zip+' '+ma.market__r.state__c+' '+ma.market__r.utility_company__c,new List<Market_Assignment__c>{ma});
                        else{
                        temp.add(ma);
                        system.debug('---installmatemp'+temp);
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
                //Map<id,Market_Assignment__c> updateMAMap=new Map<id,Market_Assignment__c>();                                                              
                for(lead l:LdList){                 
                    if(leadMaMap.containsKey(l.id)){                        
                        List<market_assignment__c> tempList=leadMaMap.get(l.id);
                        decimal maxPercentage=tempList[0].Install_Partner_age_distribution__c;
                        decimal currentPercentage=0;
                        system.debug('----install tempListsize??'+tempList.size());                                                                                         
                        for(integer i=0;i<tempList.size();i++){
                            if(tempList[i].Install_Partner_age_distribution__c>=maxPercentage){
                                maxPercentage=tempList[i].Install_Partner_age_distribution__c;
                                system.debug('----install maxPercentage??'+maxPercentage);
                                //system.debug('----install currentpercent??'+installmarketLeadCountMap.get(tempList[i].id));
                                if(installmarketLeadCountMap.containsKey(tempList[i].id)){ 
                                //system.debug('----currentpercentdivide'+installmarketLeadCountMap.get(tempList[i].id)*100/TotalResults);                                                                                                  
                                currentPercentage=(installmarketLeadCountMap.get(tempList[i].id)*100)/TotalResults;
                                system.debug('----install currentPercentage??'+currentPercentage);  
                                }                           
                                if(maxPercentage>currentPercentage){
                                    system.debug('----install Market Match??'+tempList[i]); 
                                /*    if((l.Custom_Lead_Source__c!=null&&l.Custom_Lead_Source__c.containsIgnoreCase('Costco')&&tempList[i].Partner__c==System.label.sunrun_inc_Id)||
                                       (l.Custom_Lead_Source__c!=null&&l.Custom_Lead_Source__c.containsIgnoreCase(System.label.Mickey_Account)&&tempList[i].Partner__c==System.label.sunrun_inc_Id)||        //Mickey
                                       (l.Custom_Lead_Source__c!=null&&!l.Custom_Lead_Source__c.containsIgnoreCase('Costco')&&!l.Custom_Lead_Source__c.containsIgnoreCase(System.label.Mickey_Account))){    //Mickey */
                                    
                                    if((l.Custom_Lead_Source__c!=null&&l.Custom_Lead_Source__c.containsIgnoreCase(System.label.Mickey_Account)&&tempList[i].Partner__c==System.label.sunrun_inc_Id)||        //Mickey
                                       (l.Custom_Lead_Source__c!=null&&!l.Custom_Lead_Source__c.containsIgnoreCase(System.label.Mickey_Account))){    //Mickey
 
                                    pa.Install_market_assignment__c=tempList[i].id;  
                                    }
                                    else{
                                        maxPercentage=0;
                                        currentPercentage=0;
                                    }                                                                                           
                                }
                                else{
                                    maxPercentage=0;
                                    currentPercentage=0;
                                }
                            }                           
                        }
                        if(pa.Install_market_assignment__c==null){
                                pa.Install_market_assignment__c=tempList[0].id;
                                maxPercentage=tempList[0].Install_Partner_age_distribution__c;
                                for(integer i=0;i<tempList.size();i++){                                 
                                    if(tempList[i].Install_Partner_age_distribution__c>=maxPercentage){
                                    maxPercentage=tempList[i].Install_Partner_age_distribution__c;
                                /*   if((l.Custom_Lead_Source__c!=null&&l.Custom_Lead_Source__c.containsIgnoreCase('Costco')&&tempList[i].Partner__c==System.label.sunrun_inc_Id)||
                                      (l.Custom_Lead_Source__c!=null&&l.Custom_Lead_Source__c.containsIgnoreCase(System.label.Mickey_Account)&&tempList[i].Partner__c==System.label.sunrun_inc_Id)||         //Mickey 
                                      (l.Custom_Lead_Source__c!=null&&!l.Custom_Lead_Source__c.containsIgnoreCase('Costco')&&!l.Custom_Lead_Source__c.containsIgnoreCase(System.label.Mickey_Account))){     //Mickey */
                                   
                                    if((l.Custom_Lead_Source__c!=null&&l.Custom_Lead_Source__c.containsIgnoreCase(System.label.Mickey_Account)&&tempList[i].Partner__c==System.label.sunrun_inc_Id)||         //Mickey 
                                      (l.Custom_Lead_Source__c!=null&&!l.Custom_Lead_Source__c.containsIgnoreCase(System.label.Mickey_Account))){     //Mickey

                                    pa.Install_market_assignment__c=tempList[i].id;                                 
                                    }
                                    else if(tempList.size()>1){
                                        if(i==1||i==0){
                                        pa.Install_market_assignment__c=tempList[0].id;     
                                        }
                                        else{
                                        pa.Install_market_assignment__c=tempList[i-1].id;   
                                        }
                                    }
                                    else{
                                         pa.Install_market_assignment__c=null;
                                    }
                                    }
                                }
                                
                            }
                    }
                }                
            }            
     }
             
    /*
    Offer Promotion method finds a match for a Lead with related Partner Promotion record based on promotion code(Offer_Promotion_Name__c) on Lead. 
    If no match found it procedes to next assigmnet method based on the assignment order table.
    */
    public static void doOfferPromotion(List<Lead> LdList,Map<string,List<Lead>> zipCodeMap,Set<String> stateset,List<Assignment_Order__c> aoList,Set<String> utilitySet){
        Map<String,Lead> offerLeads=new Map<String,Lead>(); 
        Map<String,List<Lead>> noOfferLds=new Map<String,List<Lead>>();         
        Map<String,Partner_Assignment_Staging__c> paMap=new Map<String,Partner_Assignment_Staging__c>();                
        Map<String,List<Partner_Promotions__c>> LeadPromos=new Map<String,List<Partner_Promotions__c>>();
        Set<id> partnerIds=new Set<id>();
        if(offerPromoAssignmentKey==1){     
            for(Lead l:LdList){
            offerLeads.put(l.offer__r.promotion__c,l);
            }
        List<Partner_Promotions__c> ppList=[select id,Partner_Account__c,Promotion__c,Partner_Account__r.Lead_Eligible__c from Partner_Promotions__c where promotion__c in:offerLeads.keyset() and promotion__r.Promotion_Type__c='Offer' and promotion__r.Promotion_Active__c='Active' and Role__c includes ('Sales') and start_date__c<=today and end_date__c>=today and  Partner_Account__r.Lead_Eligible__c=true];
            for(Partner_Promotions__c pp:ppList){
            partnerIds.add(pp.Partner_Account__c);  
            List<Partner_Promotions__c> temp=LeadPromos.get(pp.promotion__c);
            if(temp==null)  
            LeadPromos.put(pp.promotion__c,new List<Partner_Promotions__c>{pp});
            else
            temp.add(pp);
            }
            Map<String,Market_assignment__c> maMap=new Map<String,Market_assignment__c>();
            if(!partnerIds.isempty()){
            maMap=doFindSalesInstallMarketsForReferralOffer(ldList,zipCodeMap,stateset,partnerIds,utilitySet);  
            }
            for(Lead l:LdList){
            if(LeadPromos.containsKey(l.offer__r.promotion__c)){
            for(Partner_Promotions__c ppromoList:LeadPromos.get(l.offer__r.promotion__c)){
                if(ppromoList.Partner_Account__r.Lead_Eligible__c==true&&l.Lock_Assignment__c==false&&!paMap.containsKey(l.id+''+ppromoList.Partner_Account__c)){               
                Partner_Assignment_Staging__c pa=new Partner_Assignment_Staging__c(Account__c=ppromoList.Partner_Account__c,Lead__c=l.id,Offer_Assignment__c=true);
                if(maMap.containsKey(pa.account__c)){
                            pa.Sales_Market_Assignment__c=maMap.get(pa.account__c).id;
                            if(maMap.get(pa.account__c).role__c.contains('Install')){
                                pa.Install_Market_Assignment__c=maMap.get(pa.account__c).id;
                            }
                            else{
                                doFindInstallPartner(LdList,zipCodeMap,stateset, aoList, pa,utilityset);    
                            }
                }
                paMap.put(l.id+''+ppromoList.Partner_Account__c,pa);
                }
                else if(l.PostalCode!=null&&l.PostalCode.length()>=5&&!paMap.containsKey(l.id+''+ppromoList.Partner_Account__c)){
                            List<Lead> temp=noOfferLds.get(l.PostalCode.substring(0,5));
                            if(temp==null)  
                            noOfferLds.put(l.PostalCode.substring(0,5),new List<Lead>{l});
                            else
                            temp.add(l);
                    }
                else if(l.State!=null&&!paMap.containsKey(l.id+''+ppromoList.Partner_Account__c)){
                            List<Lead> temp=noOfferLds.get(l.State);
                            if(temp==null)  
                            noOfferLds.put(l.State,new List<Lead>{l});
                            else
                            temp.add(l);
                    }
                else if(!paMap.containsKey(l.id+''+ppromoList.Partner_Account__c)){
                            List<Lead> temp=noOfferLds.get('NoStateNoZip');
                            if(temp==null)  
                            noOfferLds.put('NoStateNoZip',new List<Lead>{l});
                            else
                            temp.add(l);
                    }       
            }
            }
            else if(l.PostalCode!=null&&l.Postalcode.length()>=5){
                            List<Lead> temp=noOfferLds.get(l.PostalCode.substring(0,5));
                            if(temp==null)  
                            noOfferLds.put(l.PostalCode.substring(0,5),new List<Lead>{l});
                            else
                            temp.add(l);
                }
            else if(l.State!=null){
                            List<Lead> temp=noOfferLds.get(l.State);
                            if(temp==null)  
                            noOfferLds.put(l.State,new List<Lead>{l});
                            else
                            temp.add(l);
                }
            else {
                            List<Lead> temp=noOfferLds.get('NoStateNoZip');
                            if(temp==null)  
                            noOfferLds.put('NoStateNoZip',new List<Lead>{l});
                            else
                            temp.add(l);
                }       
                
            }
            system.debug('---pamap'+paMap);
            system.debug('---noOfferLds'+noOfferLds);
            if(paMap.size()>0){
                partnerAssignList.addall(paMap.values());
                LdList.clear();
            }
               
            offerPromoAssignmentKey++;                  
                if(noOfferLds.size()>0){
                LdList=new List<Lead>();        
                for(integer i=0;i<noOfferLds.values().size();i++){              
                LdList.addall(noOfferLds.values().get(i));
                }
                if(aoList[0].Assignment_Criteria__c=='Offer Promotion'){               
                if(aoList[1].Assignment_Criteria__c=='Referral Promotion')
                doReferralPromotion(LdList,noOfferLds,stateset,aoList,utilitySet);
                else if(aoList[1].Assignment_Criteria__c=='Market Assignment')
                doMarketAssignmentQ2(LdList,noOfferLds,stateset,aoList,utilitySet);
                }
            else if(aoList[1].Assignment_Criteria__c=='Offer Promotion'){                
                 if(aoList[2].Assignment_Criteria__c=='Referral Promotion')
                doReferralPromotion(LdList,noOfferLds,stateset,aoList,utilitySet);
                else if(aoList[2].Assignment_Criteria__c=='Market Assignment')
                doMarketAssignmentQ2(LdList,noOfferLds,stateset,aoList,utilitySet);
            }            
            else if(aoList[2].Assignment_Criteria__c=='Offer Promotion'){
            doDefaultSunRunDirect(LdList,noOfferLds,stateset,aoList,utilitySet);
                    }           
                }
                if(!partnerAssignList.isempty()){
                    doInsertPartnerAssignmentTable();
                }               
            }       
        }
    /*
    Referal Promotion method finds a match for a Lead with related Partner Promotion record based on Referred by contact) on Lead. 
    If no match found it procedes to next assigmnet method based on the assignment order table.
    */
      public static void doReferralPromotion(List<Lead> LdList,Map<string,List<Lead>> zipCodeMap,Set<String> stateset,List<Assignment_Order__c> aoList,Set<String> utilitySet){
        Map<String,Lead> referralLeads=new Map<String,Lead>();  
        Map<String,List<Lead>> noReferralLeads=new Map<String,List<Lead>>();            
        Map<String,Partner_Assignment_Staging__c> paMap=new Map<String,Partner_Assignment_Staging__c>();                
        Map<String,List<Service_Contract_Event__c>> conSCEvent=new Map<String,List<Service_Contract_Event__c>>();
        Map<String,String> leadRefContact=new Map<String,String>();
        Map<id,List<Partner_Assignment_Staging__c>>  noSCEventMatch=new Map<id,List<Partner_Assignment_Staging__c>>(); 
        List<Partner_Assignment_Staging__c> noMatchList=new List<Partner_Assignment_Staging__c>(); 
        Map<string,string> leadAccountMap=new Map<String,String>();   
        Map<id,String> LeadInstallPartnersMap=new Map<id,String>();
        Set<id> salesPartnerSCMatches=new Set<id>();
        Set<id> InstallPartnerIds=new Set<id>();
        Map<String,String> salesOrgMarketMap=new Map<String,string>();
        PTO_date__c pto =  PTO_date__c.getValues('PTO Validity');
        Decimal totalDays=365;
        if(pto!=null&&pto.pto_date__c!=null)
        totalDays=pto.pto_date__c; 
        Date lastYear= system.today()-Integer.valueof(totalDays);
        system.debug('--->last year'+lastYear);
        if(referralPromoAssignmentKey==1){
        for(Lead l:LdList){
        if(l.Referred_By_Contact__c!=null&&l.referral_input__c!=null)
        leadRefContact.put(l.id,l.Referred_By_Contact__c);
        }
        if(!leadRefContact.isempty()){
            for(Service_Contract_Event__c sce:[select service_Contract__r.contactid,service_Contract__r.Sales_Organization__c,service_Contract__r.Sales_Organization_id__c,pto__c,service_Contract__r.Install_Partner__c,service_Contract__r.Install_Partner_id__c from Service_Contract_Event__c where  service_Contract__r.contactid in:leadRefContact.values() order by pto__c desc nulls last]){
            List<Service_Contract_Event__c> temp=conSCEvent.get(sce.service_Contract__r.contactid);
            if(temp==null)  
            conSCEvent.put(sce.service_Contract__r.contactid,new List<Service_Contract_Event__c>{sce});
            else{
            temp.add(sce);
            }
            salesPartnerSCMatches.add(sce.service_Contract__r.Sales_Organization_Id__c);  
            }
        }
        system.debug('--->reff lead list'+LdList);
        system.debug('--->salesPartnerSCMatches'+salesPartnerSCMatches);
        if(!salesPartnerSCMatches.isempty()){
            for(market_assignment__c ma:[select market__r.utility_company__c,market__r.Total_Current_No_Of_Leads_Install__c,market__r.Total_Current_No_Of_Leads_Sales__c,Current_No_Of_Leads_Sales__c,Current_No_Of_Leads_Install__c,Sales_Partner_age_distribution__c,Install_Partner_age_distribution__c,market__r.state__c,zipcodes__c,role__c,Select_All_Zipcodes__c,Utility_Company__c,Territory__c,Partner__c,partner__r.Lead_Eligible__c from Market_Assignment__c where (partner__c in:salesPartnerSCMatches and start_date__c<=today and end_date__c>=today and role__c includes ('Sales') and partner__r.Lead_Eligible__c=true and partner__r.Active__c=true and market__r.utility_company__c in:utilitySet)]){
                       if(ma.Zipcodes__c!=null){
                        List<String> zipcodeSet=ma.Zipcodes__c.split(',');
                        for(string zip:zipcodeSet){
                        salesOrgMarketMap.put(zip+''+ma.partner__c,ma.id);
                        }
                        }                    
                     if(ma.Select_All_Zipcodes__c==true&&!String.isempty(ma.market__r.state__c)&&stateset.contains(ma.market__r.state__c)){
                        salesOrgMarketMap.put(ma.market__r.state__c+''+ma.partner__c,ma.id);
                     }
            }
        }
        for(lead l:LdList){
            if(l.Referred_by_Contact__c!=null&&l.referral_input__c!=null&&conSCEvent.containsKey(l.Referred_By_Contact__c)&&conSCEvent.get(l.Referred_By_Contact__c)[0].pto__c>=lastYear&&!salesOrgMarketMap.isempty()&&(salesOrgMarketMap.containsKey(l.postalcode+''+conSCEvent.get(l.Referred_By_Contact__c)[0].service_Contract__r.Sales_Organization_Id__c)||salesOrgMarketMap.containsKey(l.state+''+conSCEvent.get(l.Referred_By_Contact__c)[0].service_Contract__r.Sales_Organization_Id__c))){
                if(conSCEvent.containsKey(l.Referred_By_Contact__c)&&conSCEvent.get(l.Referred_By_Contact__c)[0].pto__c>=lastYear){
                    
                        Partner_Assignment_Staging__c pa=new Partner_Assignment_Staging__c(Lead__c=l.id);
                        List<Partner_Assignment_Staging__c> temp=noSCEventMatch.get(conSCEvent.get(l.Referred_By_Contact__c)[0].service_Contract__r.Sales_Organization_Id__c);
                        if(temp==null)
                        noSCEventMatch.put(conSCEvent.get(l.Referred_By_Contact__c)[0].service_Contract__r.Sales_Organization_Id__c,new List<Partner_Assignment_Staging__c>{pa});
                        else
                        temp.add(pa);
                        leadAccountMap.put(l.id,conSCEvent.get(l.Referred_By_Contact__c)[0].service_Contract__r.Sales_Organization_Id__c);
                        LeadInstallPartnersMap.put(l.id,conSCEvent.get(l.Referred_By_Contact__c)[0].service_Contract__r.Install_Partner_Id__c);
                        InstallPartnerIds.add(conSCEvent.get(l.Referred_By_Contact__c)[0].service_Contract__r.Install_Partner_id__c);
                    
                }
                
            }
                else if(l.PostalCode!=null&&l.postalcode.length()>=5){
                            List<Lead> temp=noReferralLeads.get(l.PostalCode.substring(0,5));
                            if(temp==null)  
                            noReferralLeads.put(l.PostalCode.substring(0,5),new List<Lead>{l});
                            else
                            temp.add(l);
                }
            else if(l.State!=null){
                            system.debug('state promo2');
                            List<Lead> temp=noReferralLeads.get(l.State);
                            if(temp==null)  
                            noReferralLeads.put(l.State,new List<Lead>{l});
                            else
                            temp.add(l);
                }   
            else {
                            List<Lead> temp=noReferralLeads.get('NoStateNoZip');
                            if(temp==null)  
                            noReferralLeads.put('NoStateNoZip',new List<Lead>{l});
                            else
                            temp.add(l);
                }               
            }
            //system.debug('no gen assets match'+noSCEventMatch);
            if(!noSCEventMatch.isempty()){
                //Set<id> partnerIds=new Set<id>();   
                //Set<id> InstallPartnerIds=new Set<id>();   
                //String PARTNER_RECORDTYPEID=Label.Partner_Account_RecordType_Id;          
                //Map<string,account> salesOrgAccountMap=new Map<string,account>();
               // Map<string,account> InstallPartnerAccountMap=new Map<string,account>();
                //for(account a:[select name,id from account where name in:noSCEventMatch.keyset() and recordtypeid=:PARTNER_RECORDTYPEID order by parentid desc]){
               // salesOrgAccountMap.put(a.name,a);
               // partnerIds.add(a.id);
               // }
               // for(account a:[select name,id from account where name in:LeadInstallPartnersMap.values() and recordtypeid=:PARTNER_RECORDTYPEID order by parentid desc]){
               // InstallPartnerAccountMap.put(a.name,a);
               // InstallPartnerIds.add(a.id);
               // }  
                Map<String,Market_assignment__c> maMap=doFindSalesInstallMarketsForReferralOffer(ldList,zipCodeMap,stateset,noSCEventMatch.keyset(),utilitySet);
                Map<String,Market_assignment__c> maInstallPartnerMap;
                if(!InstallPartnerIds.isempty()){
                    maInstallPartnerMap=doFindInstallMarketsForReferral(LdList, zipCodeMap, stateset, InstallPartnerIds, utilitySet);   
                }
                List<Partner_Assignment_Staging__c> paStagingList=new List<Partner_Assignment_Staging__c>();
                for(List<Partner_Assignment_Staging__c> paList:noSCEventMatch.values()) {
                    for(Partner_Assignment_Staging__c pa:paList)
                    paStagingList.add(pa);
                } 
                system.debug('--mamap referral'+mamap);       
                for(Partner_Assignment_Staging__c pa:paStagingList){
                    Partner_Assignment_Staging__c p=new Partner_Assignment_Staging__c();
                    if(leadAccountMap.containskey(pa.lead__c)){                     
                    p.Account__c=leadAccountMap.get(pa.lead__c);
                    p.Referral_With_Contact__c=true;
                    p.Lead__c=pa.Lead__c;
                        if(maMap.containsKey(p.account__c)){
                            p.Sales_Market_Assignment__c=maMap.get(p.account__c).id;
                            //if(LeadInstallPartnersMap.containsKey(pa.lead__c)&&InstallPartnerAccountMap.containsKey(LeadInstallPartnersMap.get(pa.lead__c))&&!maInstallPartnerMap.isempty()){
                            //  p.Install_Market_Assignment__c=maInstallPartnerMap.get((InstallPartnerAccountMap.get(LeadInstallPartnersMap.get(pa.lead__c))).id).id;
                            //}
                            if(LeadInstallPartnersMap.containsKey(pa.lead__c)&&maInstallPartnerMap!=null&&maInstallPartnerMap.containsKey(LeadInstallPartnersMap.get(pa.lead__c))){
                                p.Install_Market_Assignment__c=maInstallPartnerMap.get(LeadInstallPartnersMap.get(pa.lead__c)).id;
                            }
                            else if(maMap.get(p.account__c).role__c.contains('Install')){
                                p.Install_Market_Assignment__c=maMap.get(p.account__c).id;
                            }
                            else{
                                doFindInstallPartner(LdList,zipCodeMap,stateset, aoList, p,utilityset); 
                            }
                            
                        }                       
                    }
                    else{                   
                    p.Referral_With_Contact__c=true;
                    p.lead__c=pa.lead__c;
                    }
                    noMatchList.add(p);             
                }
                
            }
            system.debug('--->pa map'+paMAp);
            system.debug('---> no match'+noMatchList);
            if(paMap.size()>0){
                partnerAssignList.addall(paMap.values());
                LdList.clear();               
            }
            if(!noMatchList.isempty()){
                partnerAssignList.addall(noMatchList);                                    
            }
            referralPromoAssignmentKey++;                   
                if(noReferralLeads.size()>0){
                LdList=new List<Lead>();        
                for(integer i=0;i<noReferralLeads.values().size();i++){             
                LdList.addall(noReferralLeads.values().get(i));
                }
            if(aoList[0].Assignment_Criteria__c=='Referral Promotion'){
            if(aoList[1].Assignment_Criteria__c=='Offer Promotion')
            doOfferPromotion(LdList,noReferralLeads,stateset,aoList,utilitySet);
            else if(aoList[1].Assignment_Criteria__c=='Market Assignment')
            doMarketAssignmentQ2(LdList,noReferralLeads,stateset,aoList,utilitySet);            
            }
            else if(aoList[1].Assignment_Criteria__c=='Referral Promotion'){
            if(aoList[2].Assignment_Criteria__c=='Offer Promotion')
            doOfferPromotion(LdList,noReferralLeads,stateset,aoList,utilitySet);
            else if(aoList[2].Assignment_Criteria__c=='Market Assignment')
            doMarketAssignmentQ2(LdList,noReferralLeads,stateset,aoList,utilitySet);           
            }            
            else if(aoList[2].Assignment_Criteria__c=='Referral Promotion'){
            doDefaultSunRunDirect(LdList,noReferralLeads,stateset,aoList,utilitySet);
               }
            }
            if(!partnerAssignList.isempty()){
                    doInsertPartnerAssignmentTable();
                }           
        }       
        
    } 
    Public static Map<String,Market_Assignment__c> doFindSalesInstallMarketsForReferralOffer(List<Lead> LdList,Map<string,List<Lead>> zipCodeMap,Set<String> stateset,Set<id> partnerIds,Set<String> utilitySet){
        /*Set<string> utilitySet=new Set<String>();
        for(lead l:LdList){
            if(l.utility_company__c!=null)
            utilitySet.add(l.utility_company__c);
        }*/
        Map<string,Market_Assignment__c> maMap=new Map<string,Market_Assignment__c>();
        List<Market_Assignment__c> maList=[select market__r.utility_company__c,market__r.Total_Current_No_Of_Leads_Install__c,market__r.Total_Current_No_Of_Leads_Sales__c,Current_No_Of_Leads_Sales__c,Current_No_Of_Leads_Install__c,Sales_Partner_age_distribution__c,Install_Partner_age_distribution__c,market__r.state__c,zipcodes__c,role__c,Select_All_Zipcodes__c,Utility_Company__c,Territory__c,Partner__c,partner__r.Lead_Eligible__c from Market_Assignment__c where (start_date__c<=today and end_date__c>=today and role__c includes ('Sales') and partner__r.Lead_Eligible__c=true and partner__r.Active__c=true and Sales_Partner_age_distribution__c>0 and market__r.utility_company__c in:utilitySet and partner__c in:partnerIds)or( start_date__c<=today and end_date__c>=today and role__c includes ('Sales') and partner__r.Lead_Eligible__c=true and partner__r.Active__c=true and market__r.state__c in:stateSet and market__r.utility_company__c in:utilitySet and partner__c in:partnerIds) order by Sales_Partner_age_distribution__c asc];
        for(Market_assignment__c ma:maList){
            for(string zip:zipCodeMap.keyset()){                   
                    if(!String.isempty(ma.Zipcodes__c)&&!String.isempty(zip)&&ma.Zipcodes__c.contains(zip.trim())){
                        maMap.put(ma.partner__c,ma);                        
                    }
                    if(ma.Select_All_Zipcodes__c==true&&!String.isempty(ma.market__r.state__c)&&stateset.contains(ma.market__r.state__c)){
                        maMap.put(ma.partner__c,ma);
                    }
                }
        }
        return maMap;
    } 
    Public static Map<String,Market_Assignment__c> doFindInstallMarketsForReferral(List<Lead> LdList,Map<string,List<Lead>> zipCodeMap,Set<String> stateset,Set<id> partnerIds,Set<String> utilitySet){     
        Map<string,Market_Assignment__c> maMap=new Map<string,Market_Assignment__c>();
        List<Market_Assignment__c> maList=[select market__r.utility_company__c,market__r.Total_Current_No_Of_Leads_Install__c,market__r.Total_Current_No_Of_Leads_Sales__c,Current_No_Of_Leads_Sales__c,Current_No_Of_Leads_Install__c,Sales_Partner_age_distribution__c,Install_Partner_age_distribution__c,market__r.state__c,zipcodes__c,role__c,Select_All_Zipcodes__c,Utility_Company__c,Territory__c,Partner__c,partner__r.Lead_Eligible__c from Market_Assignment__c where (start_date__c<=today and end_date__c>=today and role__c includes ('Install') and partner__r.Lead_Eligible__c=true and partner__r.Active__c=true and Install_Partner_age_distribution__c>0 and market__r.utility_company__c in:utilitySet and partner__c in:partnerIds)or( start_date__c<=today and end_date__c>=today and role__c includes ('Install') and partner__r.Lead_Eligible__c=true and partner__r.Active__c=true and market__r.state__c in:stateSet and market__r.utility_company__c in:utilitySet and partner__c in:partnerIds) order by Install_Partner_age_distribution__c asc];
        for(Market_assignment__c ma:maList){
            for(string zip:zipCodeMap.keyset()){                   
                    if(!String.isempty(ma.Zipcodes__c)&&!String.isempty(zip)&&ma.Zipcodes__c.contains(zip.trim())){
                        maMap.put(ma.partner__c,ma);                        
                    }
                    if(ma.Select_All_Zipcodes__c==true&&!String.isempty(ma.market__r.state__c)&&stateset.contains(ma.market__r.state__c)){
                        maMap.put(ma.partner__c,ma);
                    }
                }
        }
        return maMap;
    } 
   /*
    public static void doReferralPromotion(List<Lead> LdList,Map<string,List<Lead>> zipCodeMap,Set<String> stateset,List<Assignment_Order__c> aoList){
        Map<String,Lead> referralLeads=new Map<String,Lead>();  
        Map<String,List<Lead>> noReferralLeads=new Map<String,List<Lead>>();            
        Map<String,Partner_Assignment_Staging__c> paMap=new Map<String,Partner_Assignment_Staging__c>();                
        Map<String,List<Service_Contract_Event__c>> conSCEvent=new Map<String,List<Service_Contract_Event__c>>();
        Map<String,String> leadRefContact=new Map<String,String>();
        Map<String,List<Partner_Assignment_Staging__c>>  noSCEventMatch=new Map<String,List<Partner_Assignment_Staging__c>>(); 
        List<Partner_Assignment_Staging__c> noMatchList=new List<Partner_Assignment_Staging__c>(); 
        Map<string,string> leadAccountMap=new Map<String,String>();   
        PTO_date__c pto =  PTO_date__c.getValues('PTO Validity');
        Decimal totalDays=365;
        if(pto!=null&&pto.pto_date__c!=null)
        totalDays=pto.pto_date__c; 
        Date lastYear= system.today()-Integer.valueof(totalDays);
        system.debug('--->last year'+lastYear);
        if(referralPromoAssignmentKey==1){
        for(Lead l:LdList){
        if(l.Referred_By_Contact__c!=null&&l.referral_input__c!=null)
        leadRefContact.put(l.id,l.Referred_By_Contact__c);
        }
        if(!leadRefContact.isempty()){
            for(Service_Contract_Event__c sce:[select service_Contract__r.contactid,service_Contract__r.Sales_Organization__c,pto__c from Service_Contract_Event__c where  service_Contract__r.contactid in:leadRefContact.values() order by pto__c desc nulls last]){
            List<Service_Contract_Event__c> temp=conSCEvent.get(sce.service_Contract__r.contactid);
            if(temp==null)  
            conSCEvent.put(sce.service_Contract__r.contactid,new List<Service_Contract_Event__c>{sce});
            else
            temp.add(sce);  
            }
        }
        system.debug('--->reff lead list'+LdList);
        for(lead l:LdList){
            if(l.Referred_by_Contact__c!=null&&l.referral_input__c!=null&&conSCEvent.containsKey(l.Referred_By_Contact__c)&&conSCEvent.get(l.Referred_By_Contact__c)[0].pto__c>=lastYear){
                if(conSCEvent.containsKey(l.Referred_By_Contact__c)&&conSCEvent.get(l.Referred_By_Contact__c)[0].pto__c>=lastYear){
                    
                        Partner_Assignment_Staging__c pa=new Partner_Assignment_Staging__c(Lead__c=l.id);
                        List<Partner_Assignment_Staging__c> temp=noSCEventMatch.get(conSCEvent.get(l.Referred_By_Contact__c)[0].service_Contract__r.Sales_Organization__c);
                        if(temp==null)
                        noSCEventMatch.put(conSCEvent.get(l.Referred_By_Contact__c)[0].service_Contract__r.Sales_Organization__c,new List<Partner_Assignment_Staging__c>{pa});
                        else
                        temp.add(pa);
                        leadAccountMap.put(l.id,conSCEvent.get(l.Referred_By_Contact__c)[0].service_Contract__r.Sales_Organization__c);
                    
                }
                
            }
                else if(l.PostalCode!=null){
                            List<Lead> temp=noReferralLeads.get(l.PostalCode);
                            if(temp==null)  
                            noReferralLeads.put(l.PostalCode,new List<Lead>{l});
                            else
                            temp.add(l);
                }
            else if(l.State!=null){
                            system.debug('state promo2');
                            List<Lead> temp=noReferralLeads.get(l.State);
                            if(temp==null)  
                            noReferralLeads.put(l.State,new List<Lead>{l});
                            else
                            temp.add(l);
                }   
            else {
                            List<Lead> temp=noReferralLeads.get('NoStateNoZip');
                            if(temp==null)  
                            noReferralLeads.put('NoStateNoZip',new List<Lead>{l});
                            else
                            temp.add(l);
                }               
            }
            //system.debug('no gen assets match'+noSCEventMatch);
            if(!noSCEventMatch.isempty()){
                Map<string,account> salesOrgAccountMap=new Map<string,account>();
                for(account a:[select name,id from account where name in:noSCEventMatch.keyset()]){
                salesOrgAccountMap.put(a.name,a);
                }  
                List<Partner_Assignment_Staging__c> paStagingList=new List<Partner_Assignment_Staging__c>();
                for(List<Partner_Assignment_Staging__c> paList:noSCEventMatch.values()) {
                    for(Partner_Assignment_Staging__c pa:paList)
                    paStagingList.add(pa);
                }         
                for(Partner_Assignment_Staging__c pa:paStagingList){
                    Partner_Assignment_Staging__c p=new Partner_Assignment_Staging__c();
                    if(leadAccountMap.containskey(pa.lead__c)&&salesOrgAccountMap.containsKey(leadAccountMap.get(pa.lead__c))){                     
                    p.Account__c=salesOrgAccountMap.get((leadAccountMap.get(pa.lead__c))).id;
                    p.Referral_With_Contact__c=true;
                    p.Lead__c=pa.Lead__c;
                    }
                    else{                   
                    p.Referral_With_Contact__c=true;
                    p.lead__c=pa.lead__c;
                    }
                    noMatchList.add(p);             
                }
                
            }
            system.debug('--->pa map'+paMAp);
            system.debug('---> no match'+noMatchList);
            if(paMap.size()>0){
                partnerAssignList.addall(paMap.values());
                LdList.clear();               
            }
            if(!noMatchList.isempty()){
                partnerAssignList.addall(noMatchList);                                    
            }
            referralPromoAssignmentKey++;                   
                if(noReferralLeads.size()>0){
                LdList=new List<Lead>();        
                for(integer i=0;i<noReferralLeads.values().size();i++){             
                LdList.addall(noReferralLeads.values().get(i));
                }
            if(aoList[0].Assignment_Criteria__c=='Referral Promotion'){
            if(aoList[1].Assignment_Criteria__c=='Offer Promotion')
            doOfferPromotion(LdList,noReferralLeads,stateset,aoList);
            else if(aoList[1].Assignment_Criteria__c=='Market Assignment')
            doMarketAssignmentQ2(LdList,noReferralLeads,stateset,aoList);            
            }
            else if(aoList[1].Assignment_Criteria__c=='Referral Promotion'){
            if(aoList[2].Assignment_Criteria__c=='Offer Promotion')
            doOfferPromotion(LdList,noReferralLeads,stateset,aoList);
            else if(aoList[2].Assignment_Criteria__c=='Market Assignment')
            doMarketAssignmentQ2(LdList,noReferralLeads,stateset,aoList);           
            }            
            else if(aoList[2].Assignment_Criteria__c=='Referral Promotion'){
            doDefaultSunRunDirect(LdList,noReferralLeads,stateset,aoList);
               }
            }
            if(!partnerAssignList.isempty()){
                    doInsertPartnerAssignmentTable();
                }           
        }       
        
    } 
    */ 
    /* Default block of code which assigns Lead to Default Lead Admin. This code is called if there are no matches 
    for the Lead on the above methods.*/
    public static void doDefaultSunRunDirect(List<Lead> LdList,Map<string,List<Lead>> zipCodeMap,Set<String> stateset,List<Assignment_Order__c> aoList,Set<String> utilitySet){
    if(sunrunDirectKey==1){
    List<Partner_Assignment_Staging__c> pasList=new List<Partner_Assignment_Staging__c>();
        for(Lead l:LdList){
            Partner_Assignment_Staging__c pa=new Partner_Assignment_Staging__c(Lead__c=l.id,Referral_With_Contact_NoMatch__c=true);           
            pasList.add(pa);            
        }
        if(pasList.size()>0){
        partnerAssignList.addall(pasList);  
        sunrunDirectKey++;
        }
        
        system.debug('Default Assignemnt'+LdList);
        system.debug('Default Assignemnt Size'+LdList.size());
    }
    if(!partnerAssignList.isempty()){
                doInsertPartnerAssignmentTable();
                }        
    }
    public static void doInsertPartnerAssignmentTable(){
        if(!partnerAssignList.isempty()){
            insert partnerAssignList;
            partnerAssignList.clear();
        }
    }   
}