public class UpdateConstructionOpptyField {
    
   public static void UpdateFields(List<Service_Contract_Event__c> Events, Map<Id,Service_Contract_Event__c> old_map )
    {
       
        List<Opportunity> opplist = new List<Opportunity>();
        List<Opportunity> UpList = new List<Opportunity>();
        //Set<Id> opptyIds = new Set<Id>();
        Map<Id,Service_Contract_Event__c> sceOppMap = new Map<Id,Service_Contract_Event__c>();
        
        for(Service_contract_event__c sce : Events){
          if(sce.Scheduled_Install_Date__c != null && sce.Scheduled_Install_Date__c != old_map.get(sce.id).Scheduled_Install_Date__c){ 
            //opptyIds.add(sce.Opportunity__c);
            sceOppMap.put(sce.Opportunity__c,sce);
          } 
        }
        if(!sceOppMap.isEmpty()){
        opplist = [select Id, Scheduled_Construction_Start_Date__c from Opportunity where Id in : sceOppMap.keySet()];
        }
        If(!opplist.isEmpty()){
            for(opportunity o : opplist){
                If(sceOppMap.containsKey(o.Id) && sceOppMap.get(o.Id).Scheduled_Install_Date__c != null && o.Scheduled_Construction_Start_Date__c != sceOppMap.get(o.Id).Scheduled_Install_Date__c){
                o.Scheduled_Construction_Start_Date__c = sceOppMap.get(o.Id).Scheduled_Install_Date__c;
                UpList.add(o);
                }
                
            }
            
        }
        if(!UpList.isEmpty()){
        update UpList;
        }
   }
    public static void VerifyConstrctionDate(List<Opportunity> Optys, Map<Id,Opportunity> old_map, boolean isInsert, boolean isUpdate)
    {
        
        Set<Id> OptyIds = new Set<Id>();
        List<Opportunity> optyList = new List<Opportunity>();
        Map<Id,Service_contract_event__c> oppSceMap = new Map<Id,Service_contract_Event__c>();
        List<Service_contract_event__c> sceList = new List<Service_contract_event__c>();
        String errorMsg = 'When Scheduled Install Date is populated, Estimated Construction Start Date has to be the same as the Scheduled Install Date';
        if(isUpdate){
         for(Opportunity opp : Optys){
           if(old_map.get(opp.Id).Scheduled_Construction_Start_Date__c != opp.Scheduled_Construction_Start_Date__c ){ 
             OptyIds.add(opp.Id);
             optyList.add(opp);
           }
         }
        }
        if(!OptyIds.isEmpty()){
            sceList = [select Id, Scheduled_Install_Date__c,Service_contract__r.Opportunity__c from Service_contract_event__c where Service_contract__r.Opportunity__c in : OptyIds];
        }
        if(!scelist.isEmpty()){
            for(Service_Contract_event__c sce : scelist){
                if(sce.Scheduled_Install_Date__c != null){ 
                  oppSceMap.put(sce.Service_contract__r.Opportunity__c, sce);
                }    
            }
        }
        for(opportunity opp : optyList){
            
            if(oppSceMap.containsKey(opp.Id)){
                if(opp.Scheduled_Construction_Start_Date__c != oppSceMap.get(opp.Id).Scheduled_Install_Date__c && oppSceMap.get(opp.Id).Scheduled_Install_Date__c != null){
                    opp.addError(errorMsg);
                }
                
            }
        }
        
        
    }
 }