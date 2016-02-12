trigger trg_after_insert_bboppty on Proposal__c (after update,after insert) {
    List<Proposal__c>bboppty = new List<Proposal__c>(); 
    Set<id> propids=new Set<id>();
    List<Array_Information__c>arrayinfolist = new List<Array_Information__c>();
    Map<Id, Opportunity> optyMap = New Map<Id, Opportunity>();
    Map<String,String> propMap=new Map<String,String>();     
    for(Proposal__c p: trigger.new){
        if((trigger.isinsert&&p.Proposal_Source__c!=null)||(trigger.isUpdate&&p.Proposal_Source__c!=null&&trigger.oldmap.get(p.id).Proposal_Source__c!=p.Proposal_Source__c)){          
            Opportunity opp=new Opportunity();
            opp.id=p.Opportunity__c;
            opp.Opportunity_Source_Type__c=p.Proposal_Source__c;
            //opp.StageName ='6. Submitted To Operations';      
            optyMap.put(opp.Id, opp);
        }
         if(trigger.isUpdate && p.Stage__c!=null&&trigger.oldmap.get(p.id).Stage__c!=p.Stage__c && p.Stage__c=='Submitted' && p.Opportunity_StageName__c!='7. Closed Won'){
            Opportunity opp=new Opportunity();
            opp.id=p.Opportunity__c;
            opp.StageName ='6. Submitted To Operations';
            optyMap.put(opp.Id, opp);
        }   
        
       else if(trigger.isUpdate &&trigger.oldmap.get(p.id).Signed__c!=p.Signed__c && p.Signed__c == true && p.Opportunity_StageName__c!='7. Closed Won'){
            Opportunity opp=new Opportunity();
            opp.id=p.Opportunity__c;
            opp.StageName ='5. Customer Signed Agreement';
            optyMap.put(opp.Id, opp);
        }
        else if(trigger.isupdate && trigger.oldmap.get(p.id).Stage__c!=p.Stage__c && p.Stage__c == 'SR Approved' && p.opportunity_StageName__c!='7.Closed Won'){
            opportunity opp = new Opportunity();
            opp.id=p.Opportunity__c;
            opp.StageName = '7. Closed Won';
            optyMap.put(opp.Id, opp);
        }
        if(trigger.isinsert&&p.Highest_Roof_Story__c!=null&&p.Opportunity__c!=null){
            if(optyMap.containsKey(p.Opportunity__c)){
                optyMap.get(p.Opportunity__c).Highest_Roof_Story__c=p.Highest_Roof_Story__c;
            }
            else{
                opportunity opp = new Opportunity();
                opp.id=p.Opportunity__c;
                opp.Highest_Roof_Story__c=p.Highest_Roof_Story__c;
                optyMap.put(opp.id,opp);
            }
        }               
                            
    }   
    if(!optyMap.isempty()){
        update optyMap.values();
    }

    for(Proposal__c p: trigger.new){
        if(trigger.isinsert) 
        {
            if(p.Proposal_Source__c =='PT') 
            {
                if(p.Array_1_Production_Yr_1__c!=null)
                {
                    Array_Information__c ar1 = new Array_Information__c();          
                    ar1.Array_Number__c = 1;
                    ar1.AC_DC_derate_factor__c = p.Array_1_AC_DC_derate_factor__c;
                    ar1.April_Shade__c = p.Array_1_April_Shade__c;
                    ar1.August_Shade__c = p.Array_1_August_Shade__c;
                    ar1.Azimuth__c = p.Array_1_Azimuth__c;
                    ar1.CEC_AC_Rating__c = p.Array_1_CEC_AC_Rating__c;
                    ar1.December_Shade__c = p.Array_1_December_Shade__c;
                    ar1.February_Shade__c = p.Array_1_February_Shade__c;
                    ar1.Ground_Mount__c = p.Array_1_Ground_Mount__c;
                    ar1.Inverter_Type__c = p.Array_1_Inverter_Type__c;
                    ar1.January_Shade__c = p.Array_1_January_Shade__c;
                    ar1.July_Shade__c = p.Array_1_July_Shade__c;
                    ar1.June_Shade__c =p.Array_1_June_Shade__c;
                    ar1.March_Shade__c = p.Array_1_March_Shade__c;
                    ar1.May_Shade__c = p.Array_1_May_Shade__c;
                    ar1.Mounting_Method__c = p.Array_1_Mounting_Method__c;
                    ar1.November_Shade__c = p.Array_1_November_Shade__c;
                    ar1.Number_of_Inverters__c = p.Array_1_No_of_Inverters__c;
                    ar1.Number_of_Panels__c = p.Array_1_No_of_Panels__c;
                    ar1.October_Shade__c = p.Array_1_October_Shade__c;
                    ar1.Panel_Type__c = p.Array_1_Panel_Type__c;
                    ar1.Pitch__c = p.Array_1_Pitch__c;
                    ar1.Production__c = p.Array_1_Production_Yr_1__c;
                    ar1.Proposal__c = p.id;
                    ar1.September_Shade__c = p.Array_1_September_Shade__c;
                    arrayinfolist.add(ar1);
                }
                if(p.Array_2_Production_Yr_1__c!=null)
                {
                    Array_Information__c ar2 = new Array_Information__c();
                    ar2.Array_Number__c = 2;
                    ar2.AC_DC_derate_factor__c = p.Array_2_AC_DC_derate_factor__c;
                    ar2.April_Shade__c = p.Array_2_April_Shade__c;
                    ar2.August_Shade__c = p.Array_2_August_Shade__c;
                    ar2.Azimuth__c = p.Array_2_Azimuth__c;
                    ar2.CEC_AC_Rating__c = p.Array_2_CEC_AC_Rating__c;
                    ar2.December_Shade__c = p.Array_2_December_Shade__c;
                    ar2.February_Shade__c = p.Array_2_February_Shade__c;
                    ar2.Ground_Mount__c = p.Array_2_Ground_Mount__c;
                    ar2.Inverter_Type__c = p.Array_2_Inverter_Type__c;
                    ar2.January_Shade__c = p.Array_2_January_Shade__c;
                    ar2.July_Shade__c = p.Array_2_July_Shade__c;
                    ar2.June_Shade__c =p.Array_2_June_Shade__c;
                    ar2.March_Shade__c = p.Array_2_March_Shade__c;
                    ar2.May_Shade__c = p.Array_2_May_Shade__c;
                    ar2.Mounting_Method__c = p.Array_2_Mounting_Method__c;
                    ar2.November_Shade__c = p.Array_2_November_Shade__c;
                    ar2.Number_of_Inverters__c = p.Array_2_No_of_Inverters__c;
                    ar2.Number_of_Panels__c = p.Array_2_No_of_Panels__c;
                    ar2.October_Shade__c = p.Array_2_October_Shade__c;
                    ar2.Panel_Type__c = p.Array_2_Panel_Type__c;
                    ar2.Pitch__c = p.Array_2_Pitch__c;
                    ar2.Production__c = p.Array_2_Production_Yr_1__c;
                    ar2.Proposal__c = p.id;
                    ar2.September_Shade__c = p.Array_2_September_Shade__c;
                    arrayinfolist.add(ar2);
                }
            
        
            if(p.Array_3_Production_Yr_1__c!=null)
                {
                    Array_Information__c ar3 = new Array_Information__c();
                    ar3.Array_Number__c = 3;
                    ar3.AC_DC_derate_factor__c = p.Array_3_AC_DC_derate_factor__c;
                    ar3.April_Shade__c = p.Array_3_April_Shade__c;
                    ar3.August_Shade__c = p.Array_3_August_Shade__c;
                    ar3.Azimuth__c = p.Array_3_Azimuth__c;
                    ar3.CEC_AC_Rating__c = p.Array_3_CEC_AC_Rating__c;
                    ar3.December_Shade__c = p.Array_3_December_Shade__c;
                    ar3.February_Shade__c = p.Array_3_February_Shade__c;
                    ar3.Ground_Mount__c = p.Array_3_Ground_Mount__c;
                    ar3.Inverter_Type__c = p.Array_3_Inverter_Type__c;
                    ar3.January_Shade__c = p.Array_3_January_Shade__c;
                    ar3.July_Shade__c = p.Array_3_July_Shade__c;
                    ar3.June_Shade__c =p.Array_3_June_Shade__c;
                    ar3.March_Shade__c = p.Array_3_March_Shade__c;
                    ar3.May_Shade__c = p.Array_3_May_Shade__c;
                    ar3.Mounting_Method__c = p.Array_3_Mounting_Method__c;
                    ar3.November_Shade__c = p.Array_3_November_Shade__c;
                    ar3.Number_of_Inverters__c = p.Array_3_No_of_Inverters__c;
                    ar3.Number_of_Panels__c = p.Array_3_No_of_Panels__c;
                    ar3.October_Shade__c = p.Array_3_October_Shade__c;
                    ar3.Panel_Type__c = p.Array_3_Panel_Type__c;
                    ar3.Pitch__c = p.Array_3_Pitch__c;
                    ar3.Production__c = p.Array_3_Production_Yr_1__c;
                    ar3.Proposal__c = p.id;
                    ar3.September_Shade__c = p.Array_3_September_Shade__c;
                    arrayinfolist.add(ar3);
                 }
            
            if(p.Array_4_Production_Yr_1__c!=null)
                {
                    
                    Array_Information__c ar4 = new Array_Information__c();  
                    ar4.Array_Number__c = 4;
                    ar4.AC_DC_derate_factor__c = p.Array_4_AC_DC_derate_factor__c;
                    ar4.April_Shade__c = p.Array_4_April_Shade__c;
                    ar4.August_Shade__c = p.Array_4_August_Shade__c;
                    ar4.Azimuth__c = p.Array_4_Azimuth__c;
                    ar4.CEC_AC_Rating__c = p.Array_4_CEC_AC_Rating__c;
                    ar4.December_Shade__c = p.Array_4_December_Shade__c;
                    ar4.February_Shade__c = p.Array_4_February_Shade__c;
                    ar4.Ground_Mount__c = p.Array_4_Ground_Mount__c;
                    ar4.Inverter_Type__c = p.Array_4_Inverter_Type__c;
                    ar4.January_Shade__c = p.Array_4_January_Shade__c;
                    ar4.July_Shade__c = p.Array_4_July_Shade__c;
                    ar4.June_Shade__c =p.Array_4_June_Shade__c;
                    ar4.March_Shade__c = p.Array_4_March_Shade__c;
                    ar4.May_Shade__c = p.Array_4_May_Shade__c;
                    ar4.Mounting_Method__c = p.Array_4_Mounting_Method__c;
                    ar4.November_Shade__c = p.Array_4_November_Shade__c;
                    ar4.Number_of_Inverters__c = p.Array_4_No_of_Inverters__c;
                    ar4.Number_of_Panels__c = p.Array_4_No_of_Panels__c;
                    ar4.October_Shade__c = p.Array_4_October_Shade__c;
                    ar4.Panel_Type__c = p.Array_4_Panel_Type__c;
                    ar4.Pitch__c = p.Array_4_Pitch__c;
                    ar4.Production__c = p.Array_4_Production_Yr_1__c;
                    ar4.Proposal__c = p.id;
                    ar4.September_Shade__c = p.Array_4_September_Shade__c;
                    arrayinfolist.add(ar4);
                }
            
            if(p.Array_5_Production_Yr_1__c!=null)              
            {               
                    Array_Information__c ar5 = new Array_Information__c();
                    ar5.Array_Number__c = 5;
                    ar5.AC_DC_derate_factor__c = p.Array_5_AC_DC_derate_factor__c;
                    ar5.April_Shade__c = p.Array_5_April_Shade__c;
                    ar5.August_Shade__c = p.Array_5_August_Shade__c;
                    ar5.Azimuth__c = p.Array_5_Azimuth__c;
                    ar5.CEC_AC_Rating__c = p.Array_5_CEC_AC_Rating__c;
                    ar5.December_Shade__c = p.Array_5_December_Shade__c;
                    ar5.February_Shade__c = p.Array_5_February_Shade__c;
                    ar5.Ground_Mount__c = p.Array_5_Ground_Mount__c;
                    ar5.Inverter_Type__c = p.Array_5_Inverter_Type__c;
                    ar5.January_Shade__c = p.Array_5_January_Shade__c;
                    ar5.July_Shade__c = p.Array_5_July_Shade__c;
                    ar5.June_Shade__c =p.Array_5_June_Shade__c;
                    ar5.March_Shade__c = p.Array_5_March_Shade__c;
                    ar5.May_Shade__c = p.Array_5_May_Shade__c;
                    ar5.Mounting_Method__c = p.Array_5_Mounting_Method__c;
                    ar5.November_Shade__c = p.Array_5_November_Shade__c;
                    ar5.Number_of_Inverters__c = p.Array_5_No_of_Inverters__c;
                    ar5.Number_of_Panels__c = p.Array_5_No_of_Panels__c;
                    ar5.October_Shade__c = p.Array_5_October_Shade__c;
                    ar5.Panel_Type__c = p.Array_5_Panel_Type__c;
                    ar5.Pitch__c = p.Array_5_Pitch__c;
                    ar5.Production__c = p.Array_5_Production_Yr_1__c;
                    ar5.Proposal__c = p.id;
                    ar5.September_Shade__c = p.Array_5_September_Shade__c;
                    arrayinfolist.add(ar5);
            }
            
            if(p.Array_6_Production_Yr_1__c!=null)
            {
                    Array_Information__c ar6 = new Array_Information__c();              
                    ar6.Array_Number__c = 6;
                    ar6.AC_DC_derate_factor__c = p.Array_6_AC_DC_derate_factor__c;
                    ar6.April_Shade__c = p.Array_6_April_Shade__c;
                    ar6.August_Shade__c = p.Array_6_August_Shade__c;
                    ar6.Azimuth__c = p.Array_6_Azimuth__c;
                    ar6.CEC_AC_Rating__c = p.Array_6_CEC_AC_Rating__c;
                    ar6.December_Shade__c = p.Array_6_December_Shade__c;
                    ar6.February_Shade__c = p.Array_6_February_Shade__c;
                    ar6.Ground_Mount__c = p.Array_6_Ground_Mount__c;
                    ar6.Inverter_Type__c = p.Array_6_Inverter_Type__c;
                    ar6.January_Shade__c = p.Array_6_January_Shade__c;
                    ar6.July_Shade__c = p.Array_6_July_Shade__c;
                    ar6.June_Shade__c =p.Array_6_June_Shade__c;
                    ar6.March_Shade__c = p.Array_6_March_Shade__c;
                    ar6.May_Shade__c = p.Array_6_May_Shade__c;
                    ar6.Mounting_Method__c = p.Array_6_Mounting_Method__c;
                    ar6.November_Shade__c = p.Array_6_November_Shade__c;
                    ar6.Number_of_Inverters__c = p.Array_6_No_of_Inverters__c;
                    ar6.Number_of_Panels__c = p.Array_6_No_of_Panels__c;
                    ar6.October_Shade__c = p.Array_6_October_Shade__c;
                    ar6.Panel_Type__c = p.Array_6_Panel_Type__c;
                    ar6.Pitch__c = p.Array_6_Pitch__c;
                    ar6.Production__c = p.Array_6_Production_Yr_1__c;
                    ar6.Proposal__c = p.id;
                    ar6.September_Shade__c = p.Array_6_September_Shade__c;
                    arrayinfolist.add(ar6);     
                
            }
        
        }
    }

    if(!arrayinfolist.isempty()){
        insert arrayinfolist;
    }
  }
}