public with sharing class ArrayInfoUtil {
    public static void arrayInfocontractarray(boolean isinsert,boolean isupdate, List<Asset__c>assetList, Map<Id, Asset__c> oldMap){
        Set<id> slist = new Set<id>();
        Set<Id> inactiveAssetIds = new Set<Id>();
        Set<Id> activeAssetIds = new Set<Id>();
        Set<Id> proposalIds = new Set<Id>();
        if(Trigger.isUpdate && Trigger.isafter){
            for(Asset__c a: assetList){
                Asset__c oldAssetObj;
                if(Trigger.isUpdate && oldMap != null){
                    oldAssetObj = oldMap.get(a.Id);
                }
                if(oldAssetObj != null && a.Type__c == 'Asset' && a.Status__c != oldAssetObj.Status__c && a.Status__c == 'Inactive'){
                    inactiveAssetIds.add(a.Id);
                }   
            }
        }
        System.debug('inactiveAssetIds 0 : ' + inactiveAssetIds);
        if(Trigger.isinsert && Trigger.isafter){
            for(Asset__c a: assetList){
                Asset__c oldAssetObj;
                if(Trigger.isUpdate && oldMap != null){
                    oldAssetObj = oldMap.get(a.Id);
                }
                if(oldAssetObj != null && a.Type__c == 'Asset' && a.Status__c != oldAssetObj.Status__c && a.Status__c == 'Inactive'){
                    inactiveAssetIds.add(a.Id);
                }
                if(a.Type__c == 'Asset' && a.Status__c == 'Active' ){
                    slist.add(a.ServiceContract__c);
                }
            }

            Map<id,id> scToProposal = new Map<id,id>();
            if(!slist.isEmpty()) {
                for(ServiceContract scObj : [SELECT id, Proposal__c FROM ServiceContract WHERE id IN: slist]){
                    scToProposal.put(scObj.Id, scObj.Proposal__c);
                }
            }

            List<Array_Information__c> aiList = new List<Array_Information__c>();
            if(!scToProposal.isEmpty()) {
                aiList = [SELECT Id,Service_Contract__c,Proposal__c,April_Shade__c, CEC_AC_Rating__c, Array_Number__c,August_Shade__c,Azimuth__c,December_Shade__c,February_Shade__c,
                                                 AC_DC_derate_factor__c,
                                                 Ground_Mount__c,Inverter_Type__c,January_Shade__c,July_Shade__c,June_Shade__c,March_Shade__c,May_Shade__c,Mounting_Method__c,November_Shade__c,
                                                 Number_of_Inverters__c,Number_of_Panels__c,October_Shade__c,Panel_Type__c,Pitch__c,Production__c,September_Shade__c,Annual_Solar_Access__c,Positive_30__c,Positive_60__c,Negative_30__c,Negative_60__c,East__c,West__c,South__c FROM Array_Information__c WHERE Proposal__c IN: scToProposal.values()];
            }                                            
            
            List<Contract_Array__c> caList = new List<Contract_Array__c>();
            for(Asset__c a: assetList){
                id proposalId = scToProposal.get(a.ServiceContract__c);
                if(!aiList.isEmpty()){
                    for(Array_Information__c ai: aiList){
                        if(a.Type__c == 'Asset' && a.Status__c == 'Active' && ai.Proposal__c == proposalId){
                            Contract_Array__c ca = new Contract_Array__c();
                            // ca.Name = ai.Name;
                            ca.Asset__c = a.Id;
                            ca.April_Shade__c = ai.April_Shade__c;
                            ca.Array_Number__c = ai.Array_Number__c;
                            ca.August_Shade__c = ai.August_Shade__c;
                            ca.Azimuth__c = ai.Azimuth__c;
                            ca.December_Shade__c =ai.December_Shade__c;
                            ca.February_Shade__c = ai.February_Shade__c;
                            ca.Ground_Mount__c = ai.Ground_Mount__c;
                            ca.Inverter_Type__c = ai.Inverter_Type__c;
                            ca.January_Shade__c = ai.January_Shade__c;
                            ca.July_Shade__c = ai.July_Shade__c;
                            ca.June_Shade__c = ai.June_Shade__c;
                            ca.March_Shade__c = ai.March_Shade__c;
                            ca.May_Shade__c = ai.May_Shade__c;
                            ca.Mounting_Method__c = ai.Mounting_Method__c;
                            ca.November_Shade__c = ai.November_Shade__c;
                            ca.Number_of_Inverters__c = ai.Number_of_Inverters__c;
                            ca.Number_of_Panels__c = ai.Number_of_Panels__c;
                            ca.October_Shade__c = ai.October_Shade__c;
                            ca.Panel_Type__c = ai.Panel_Type__c;
                            ca.Pitch__c =  ai.Pitch__c;
                            ca.Production__c = ai.Production__c;
                            ca.September_Shade__c = ai.September_Shade__c;
                            ca.Service_Contract__c = a.ServiceContract__c;
                            ca.Service_Contract__c = a.ServiceContract__c;
                            ca.CEC_AC_Rating__c = ai.CEC_AC_Rating__c;
                            ca.AC_DC_derate_factor__c = ai.AC_DC_derate_factor__c;
//Below 8 fields are added as part of BSKY-5745 08/03/2015 - Arun
                            ca.Positive_30__c = ai.Positive_30__c;
                            ca.Positive_60__c = ai.Positive_60__c;
                            ca.Negative_30__c = ai.Negative_30__c;
                            ca.Negative_60__c = ai.Negative_60__c;
                            ca.East__c = ai.East__c;
                            ca.West__c = ai.West__c;
                            ca.South__c = ai.South__c;
                            ca.Annual_Solar_Access__c = ai.Annual_Solar_Access__c;
                            caList.add(ca);
                        }
                    }
                }
                if(!caList.isEmpty()){
                    insert caList;
                }
            }
        }
        
        System.debug('inactiveAssetIds: ' + inactiveAssetIds);
        if(inactiveAssetIds != null && !inactiveAssetIds.isEmpty()){
            //delete records from ContractArray created on Asset that is being Inactive
            set<id> setContractArrayId = New set<id>();
            list<Contract_Array__c> listCA = new list<Contract_Array__c>();
            listCA = [Select id from Contract_Array__c Where Asset__c in :inactiveAssetIds]; 
            if(listCA != null && !listCA.isEmpty()){
                delete listCA;
            }
        }
    }
  
}