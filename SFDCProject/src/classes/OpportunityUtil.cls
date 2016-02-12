public class OpportunityUtil {
    
    public static Set<Id> eligibleForVoid = new Set<Id>();
    public static Map<Id, String> reasonMap = new Map<Id, String>();
    public static Set<Id> voidedOpportunityIds = new Set<Id>();
    //public static Boolean isUtilityInformationChanged(Opportunity newOpportunity, Opportunity oldOpportunity){
    //  return false;
    //}
    
    public static Map<Id, String> isUtilityInformationChanged(Opportunity newOpportunity, Opportunity oldOpportunity){
        boolean result = false;
        String reason = '';
        Map<Id, String> resultMap = new Map<Id, String>();
        if(newOpportunity != null && oldOpportunity != null && newOpportunity.Opportunity_Source_Type__c ==  ProposalUtil.BLACK_BIRD){
            if((newOpportunity.Utility_Company__c != oldOpportunity.Utility_Company__c)){
                //result = true;
                //reason = ProposalUtil.UTILITY_CHANGE;
                resultMap.put(newOpportunity.Id, ProposalUtil.UTILITY_CHANGE);
            }else if((newOpportunity.Average_Monthly_Electricity_Usage__c != oldOpportunity.Average_Monthly_Electricity_Usage__c)
                || (newOpportunity.Jan_Usage__c != oldOpportunity.Jan_Usage__c)
                || (newOpportunity.Feb_Usage__c != oldOpportunity.Feb_Usage__c)
                || (newOpportunity.Mar_Usage__c != oldOpportunity.Mar_Usage__c)
                || (newOpportunity.Apr_Usage__c != oldOpportunity.Apr_Usage__c)
                || (newOpportunity.May_Usage__c != oldOpportunity.May_Usage__c)
                || (newOpportunity.Jun_Usage__c != oldOpportunity.Jun_Usage__c)
                || (newOpportunity.Jun_Usage__c != oldOpportunity.Jun_Usage__c)
                || (newOpportunity.Aug_Usage__c != oldOpportunity.Aug_Usage__c)
                || (newOpportunity.Sep_Usage__c != oldOpportunity.Sep_Usage__c)
                || (newOpportunity.Oct_Usage__c != oldOpportunity.Oct_Usage__c)
                || (newOpportunity.Nov_Usage__c != oldOpportunity.Nov_Usage__c)
                || (newOpportunity.Dec_Usage__c != oldOpportunity.Dec_Usage__c)
                || (newOpportunity.Average_Monthly_Electric_Bill__c != oldOpportunity.Average_Monthly_Electric_Bill__c)
                || (newOpportunity.Purchased_Thru__c!=null && oldOpportunity.Purchased_Thru__c!=null && ((newOpportunity.Purchased_Thru__c!='Costco' && oldOpportunity.Purchased_Thru__c=='Costco') ||(newOpportunity.Purchased_Thru__c=='Costco' && oldOpportunity.Purchased_Thru__c!='Costco') ))     
                || (newOpportunity.Home_Type__c != oldOpportunity.Home_Type__c)
                || (newOpportunity.Rate_Schedule__c != oldOpportunity.Rate_Schedule__c)){

                //System.debug('newOpportunity: ' + newOpportunity);
                //System.debug('oldOpportunity: ' + oldOpportunity);

                System.debug('newOpportunity: ' + newOpportunity.Home_Type__c);
                System.debug('oldOpportunity: ' + oldOpportunity.Home_Type__c);
                
                resultMap.put(newOpportunity.Id, ProposalUtil.MONTHLY_USAGE_CHANGE);
            }
        }
        System.debug('resultMap: ' + resultMap);
        return resultMap;
    }
    
    public static String getVoidProposalErroMessage(){
        Boolean isPartnerUser = false;
        String errormessage = 'Modifying the Contact Information,Utility Information,Purchased Thru or Home Type will void the active proposals associated with this Opportunity. Select \'Void Proposals\' checkbox to confirm your changes.';

        User userObj = PRMContactUtil.getLoginUser();
        if(userObj != null && userObj.contactId != null){
            isPartnerUser = true;
        }
        if(isPartnerUser){
            errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000020').error_message__c;  
        }
        return errormessage;
    }
    
     public static void copyOptyUtilityInformation(Opportunity targetOpty, Opportunity sourceOpty){
        targetOpty.Utility_Company__c = sourceOpty.Utility_Company__c;
        targetOpty.Average_Monthly_Electricity_Usage__c = sourceOpty.Average_Monthly_Electricity_Usage__c;
        targetOpty.Average_Monthly_Electric_Bill__c = sourceOpty.Average_Monthly_Electric_Bill__c;
        targetOpty.Home_Type__c = sourceOpty.Home_Type__c;
        targetOpty.Jan_Usage__c = sourceOpty.Jan_Usage__c;
        targetOpty.Feb_Usage__c = sourceOpty.Feb_Usage__c;
        targetOpty.Mar_Usage__c = sourceOpty.Mar_Usage__c;
        targetOpty.Apr_Usage__c = sourceOpty.Apr_Usage__c;
        targetOpty.May_Usage__c = sourceOpty.May_Usage__c;
        targetOpty.Jun_Usage__c = sourceOpty.Jun_Usage__c;
        targetOpty.Jun_Usage__c = sourceOpty.Jun_Usage__c;
        targetOpty.Aug_Usage__c = sourceOpty.Aug_Usage__c;
        targetOpty.Sep_Usage__c = sourceOpty.Sep_Usage__c;
        targetOpty.Oct_Usage__c = sourceOpty.Oct_Usage__c;
        targetOpty.Nov_Usage__c = sourceOpty.Nov_Usage__c;
        targetOpty.Dec_Usage__c = sourceOpty.Dec_Usage__c;
    }

    public static void calculateMonUsage(List<Opportunity> oppList,Map<id,Opportunity> oldMap,boolean isinsert,boolean isupdate){
        Set<String> states = new Set<String>();
        List<Opportunity> OpportunitysList = new List<Opportunity>();
        /*
        for(Opportunity OpportunityObj: newMap.values()){
            if((OpportunityObj.Jan_Usage__c == 0.0 || OpportunityObj.Jan_Usage__c == null) && (OpportunityObj.Feb_Usage__c == 0.0 || OpportunityObj.Feb_Usage__c == null) && 
                (OpportunityObj.Mar_Usage__c == 0.0 || OpportunityObj.Mar_Usage__c == null) && (OpportunityObj.Apr_Usage__c == 0.0 || OpportunityObj.Apr_Usage__c == null) && 
                (OpportunityObj.May_Usage__c == 0.0 || OpportunityObj.May_Usage__c == null) && (OpportunityObj.Jun_Usage__c == 0.0 || OpportunityObj.Jun_Usage__c == null) && 
                (OpportunityObj.Jul_Usage__c == 0.0 || OpportunityObj.Jul_Usage__c == null) && (OpportunityObj.Aug_Usage__c == 0.0 || OpportunityObj.Aug_Usage__c == null) && 
                (OpportunityObj.Sep_Usage__c == 0.0 || OpportunityObj.Sep_Usage__c == null) && (OpportunityObj.Oct_Usage__c == 0.0 || OpportunityObj.Oct_Usage__c == null) && 
                (OpportunityObj.Nov_Usage__c == 0.0 || OpportunityObj.Nov_Usage__c == null) && (OpportunityObj.Dec_Usage__c == 0.0 || OpportunityObj.Dec_Usage__c == null) && 
                OpportunityObj.State__c != null && OpportunityObj.State__c != '' && OpportunityObj.Average_Monthly_Electric_Bill__c != 0.0){
                OpportunitysList.add(OpportunityObj);   
                states.add(OpportunityObj.State__c);            
            }
        }
        */
        for(Opportunity OpportunityObj: oppList){
        if((isinsert&&OpportunityObj.Lead_Id__c==null&&OpportunityObj.Average_Monthly_Electric_Bill__c!=null&&OpportunityObj.Average_Monthly_Electric_Bill__c!=0.0)             
            ||(isupdate&&OpportunityObj.Average_Monthly_Electric_Bill__c!=null&&OpportunityObj.Average_Monthly_Electric_Bill__c!=0.0&&oldMap.get(OpportunityObj.id).Average_Monthly_Electric_Bill__c!=OpportunityObj.Average_Monthly_Electric_Bill__c)){            
            OpportunitysList.add(OpportunityObj);   
            states.add(OpportunityObj.State__c);
            }
        }   
        System.debug('states: ' + states);
        Map<String, Average_kWh_by_State__c> averageKWHByStateMap = new Map<String, Average_kWh_by_State__c>();
        if(!states.isEmpty()){
            states.add('Other');
            for(Average_kWh_by_State__c averageKWHByStateObj : [Select id,Name,kwh__c from Average_kWh_by_State__c where Name in :states]){
                averageKWHByStateMap.put(averageKWHByStateObj.Name, averageKWHByStateObj);
            }
        }
        Decimal monthlyUsage;
        for(Opportunity OpportunityObj : OpportunitysList){
            monthlyUsage = 0.0;
            Average_kWh_by_State__c averageKWHByStateObj = (averageKWHByStateMap.containsKey(OpportunityObj.state__c)) ? averageKWHByStateMap.get(OpportunityObj.state__c) : averageKWHByStateMap.get('Other');
            monthlyUsage = OpportunityObj.Average_Monthly_Electric_Bill__c/averageKWHByStateObj.kwh__c;
            OpportunityObj.Jan_Usage__c = monthlyUsage.intvalue();
            OpportunityObj.Feb_Usage__c = monthlyUsage.intvalue();
            OpportunityObj.Mar_Usage__c = monthlyUsage.intvalue();
            OpportunityObj.Apr_Usage__c = monthlyUsage.intvalue();
            OpportunityObj.May_Usage__c = monthlyUsage.intvalue();
            OpportunityObj.Jun_Usage__c = monthlyUsage.intvalue();
            OpportunityObj.Jul_Usage__c = monthlyUsage.intvalue();
            OpportunityObj.Aug_Usage__c = monthlyUsage.intvalue();
            OpportunityObj.Sep_Usage__c = monthlyUsage.intvalue();
            OpportunityObj.Oct_Usage__c = monthlyUsage.intvalue();
            OpportunityObj.Nov_Usage__c = monthlyUsage.intvalue();
            OpportunityObj.Dec_Usage__c = monthlyUsage.intvalue();
        }
        
    }
    public static void doJitterBitRollBackFields(List<Opportunity> oppList,Map<id,Opportunity> oldMap){
        if(userinfo.getuserid()==System.Label.JitterBitUser){
             Map<String,JitterBit_Install_Branches__c> map_InstallBranchIds = JitterBit_Install_Branches__c.getAll();
             for(Opportunity opp:oppList){
                System.debug('Install_Branch_Id__c'+opp.Install_Branch_Id__c);
                System.debug('map_InstallBranchIds'+map_InstallBranchIds.keyset());
                if(opp.Install_Branch_Id__c!=null&&map_InstallBranchIds.containsKey(opp.Install_Branch_Id__c)){
                    opp.Actual_Construction_Finish__c=oldMap.get(opp.id).Actual_Construction_Finish__c;
                    opp.Actual_Construction_Start__c=oldMap.get(opp.id).Actual_Construction_Start__c;
                    opp.Elect_PV_Finish_Date__c=oldMap.get(opp.id).Elect_PV_Finish_Date__c;
                    opp.Layout_Approval_Finish__c=oldMap.get(opp.id).Layout_Approval_Finish__c;
                    opp.Layout_Approval_Start__c=oldMap.get(opp.id).Layout_Approval_Start__c;
                    opp.Permitting_Process_Finish_Date__c=oldMap.get(opp.id).Permitting_Process_Finish_Date__c;
                    opp.Permitting_Process_Start_Date__c=oldMap.get(opp.id).Permitting_Process_Start_Date__c;
                    opp.Plans_Completed_Date__c=oldMap.get(opp.id).Plans_Completed_Date__c;
                    opp.Plans_Reviewed_Date__c=oldMap.get(opp.id).Plans_Reviewed_Date__c;
                    opp.Scheduled_Construction_Start_Date__c=oldMap.get(opp.id).Scheduled_Construction_Start_Date__c;
                    opp.Site_Audit_Completed__c=oldMap.get(opp.id).Site_Audit_Completed__c;
                    opp.Submit_Final_Interconnection__c=oldMap.get(opp.id).Submit_Final_Interconnection__c;
                    opp.SunRun_NTP_Costco_PO_Issued__c=oldMap.get(opp.id).SunRun_NTP_Costco_PO_Issued__c;
                    opp.Oracle_Opportunity_Close_Date__c=oldMap.get(opp.id).Oracle_Opportunity_Close_Date__c;
                }
             }
        }
    }
    /*
    public static Set<Id> optyNumberIds = new Set<Id>();
    public static void updateOpportunityNumber(Set<Id> optyIds){
        System.debug('optyIds: ' + optyIds);
        if(optyIds != null){
            optyIds.removeall(optyNumberIds);
            if(!optyIds.isEmpty()){
                updateOpportunityNumberImpl(optyIds);
                optyNumberIds.addall(optyIds);
            }
        }
    }
    
    public static void updateOpportunityNumberImpl(Set<Id> optyIds){
        Map<Id, String> optyScNameMap = new Map<Id, String>();
        for(ServiceContract scoBJ : [Select Id, name, Opportunity__c,Marked_For_Deletion__c from ServiceContract where 
                                        (Marked_For_Deletion__c = null OR   Marked_For_Deletion__c = 'No') 
                                        AND Status__c != 'Inactive' and Opportunity__c in :optyIds]){
            optyScNameMap.put(scoBJ.Opportunity__c, scoBJ.Name);
        }
        Set<Id> tempOptyIds = new Set<Id>();
        tempOptyIds.addall(optyIds);
        tempOptyIds.removeall(optyScNameMap.keySet());
        List<String> optyNumberList = new List<String>();
        if(!tempOptyIds.isEmpty()){
            optyNumberList = RandomNumberGenerator.getUniqueServiceContractNumbers(tempOptyIds.size());
        }
        Integer counter = 0;
        List<Opportunity> modifiedOptys = new List<Opportunity>();
        for(Opportunity optyObj : [Select Id, Opportunity_number__c from Opportunity where Id in :optyIds and (Opportunity_number__c = null OR Opportunity_number__c = '')]){
            String optyNumber = '';
            if(optyScNameMap.containskey(optyObj.Id)){
                optyNumber = 'O-' + optyScNameMap.get(optyObj.Id);
            }else{
                optyNumber = 'O-' + optyNumberList[counter];
                counter++;
            }
            optyObj.opportunity_Number__c = optyNumber;
            modifiedOptys.add(optyObj);
        }
        if(!modifiedOptys.isEmpty()){
            update modifiedOptys;
        }
    }
    */
}