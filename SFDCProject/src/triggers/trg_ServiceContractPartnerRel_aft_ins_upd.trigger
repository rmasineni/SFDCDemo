trigger trg_ServiceContractPartnerRel_aft_ins_upd on Service_Contract_Partner_Rel__c (after insert, after update, before delete) {
	
	Set<Id> scIds = new Set<Id>();
	Map<Id,Service_Contract_Partner_Rel__c> scInstallerMap = new Map<Id,Service_Contract_Partner_Rel__c>();
	Map<Id,Service_Contract_Partner_Rel__c> scSalesPartnerMap = new Map<Id,Service_Contract_Partner_Rel__c>();
	Boolean skipValidations = false;
	skipValidations = SkipTriggerValidation.performTriggerValidations();
	Set<Id> modifiedRelatedObjectIds = new Set<Id>();
    if(skipValidations == false){
        If(Trigger.IsUpdate || Trigger.IsInsert){
            for(Service_Contract_Partner_Rel__c scPartnerRel:Trigger.New){
                Service_Contract_Partner_Rel__c oldSCPartnerRelObj;
                if(Trigger.isUpdate){
                    oldSCPartnerRelObj  = Trigger.newMap.get(scPartnerRel.Id);
                }
                if((scPartnerRel.Account__c != null && scPartnerRel.ServiceContract__c != null) 
                   && (Trigger.isInsert || (oldSCPartnerRelObj != null && (scPartnerRel.Account__c  != oldSCPartnerRelObj.Account__c || scPartnerRel.ServiceContract__c  != oldSCPartnerRelObj.ServiceContract__c)))){
                       if(scPartnerRel.Type__c != null && scPartnerRel.Type__c == ServiceContractUtil.INSTALL){
                           scInstallerMap.put(scPartnerRel.ServiceContract__c, scPartnerRel);
                           scIds.add(scPartnerRel.ServiceContract__c);
                       }
                       if(scPartnerRel.Type__c != null && scPartnerRel.Type__c == ServiceContractUtil.SALES){
                           scSalesPartnerMap.put(scPartnerRel.ServiceContract__c, scPartnerRel);
                           scIds.add(scPartnerRel.ServiceContract__c);
                       }
                   }
                if(scPartnerRel.ServiceContract__c != null  && scPartnerRel.Account__c != null && scPartnerRel.Type__c == 'Install'){
                    modifiedRelatedObjectIds.add(scPartnerRel.Account__c);
                }			
            }
            
            //if(modifiedRelatedObjectIds != null && !modifiedRelatedObjectIds.isEmpty()){
            //	ServiceContractUtil.updateServiceContractsForInstallPartners(modifiedRelatedObjectIds, datetime.now());
            //}
            
            if(scIds != null && !scIds.isEmpty()){
                ServiceContractUtil.updatePartnerDetailsOnServiceContract(scIds, scInstallerMap, scSalesPartnerMap);
            }
        }
        
        //update  subcontractor tasks category is 'Required' based on related partner  type
        Set<Id> relPartnerIds = new Set<Id>();
        List<Task__c> SubcontractortaskList= new List<Task__c>();   
        List<Task__c> FinalSubcontractortaskList= new List<Task__c>();   
        
        for(Service_Contract_Partner_Rel__c scPartnerRel: (Trigger.IsDelete ? Trigger.Old :Trigger.New )){
            If(scPartnerRel.Type__c!=null)
                relPartnerIds.add(scPartnerRel.id);	
        }
        
        Map<id,Service_Contract_Partner_Rel__c> MapRelPartnerList = new Map<id,Service_Contract_Partner_Rel__c>([select id,Type__c,ServiceContract__c from Service_Contract_Partner_Rel__c 
                                                                                                                 Where id in: relPartnerIds]); 
        
        for(Id RelId : MapRelPartnerList.keySet() ){
            List<project__c> projectList = [select id from project__c where Service_Contract__c=:MapRelPartnerList.get(RelId).ServiceContract__c];
            If(!projectList.isEmpty()){
                If(MapRelPartnerList.get(RelId).Type__c=='Electrical Subcontractor'){
                    List<task__c> preparetask = new List<task__c>();
                    preparetask=[select id,category__c, project_name__c from task__c where project_name__c=:projectList[0].Id and name =:'Prepare Electrical Subk' ];
                    If(!preparetask.isEmpty())
                        SubcontractortaskList.add(preparetask[0]);
                    List<task__c> Electricaltask = new List<task__c>();
                    Electricaltask  = [select id,category__c, project_name__c from task__c where project_name__c =:projectList[0].Id and name =:'Get Electrical Subk Signed'];
                    If(!Electricaltask.isEmpty())
                        SubcontractortaskList.add(Electricaltask[0]);
                } If(MapRelPartnerList.get(RelId).Type__c=='Solar Waterproofing Subcontractor'){
                    List<task__c> prepareSolartask = new List<task__c>();
                    prepareSolartask=[select id,category__c, project_name__c from task__c where project_name__c=:projectList[0].Id and name =:'Prepare Solar Waterproofing Subk' ];
                    If(!prepareSolartask.isEmpty())
                        SubcontractortaskList.add(prepareSolartask[0]);
                    List<task__c> SolarSigned = new List<task__c>();
                    SolarSigned  =[select id,category__c, project_name__c from task__c where project_name__c =:projectList[0].Id and name =:'Get Solar Waterproofing Subk Signed' ];
                    If(!SolarSigned.isEmpty())
                        SubcontractortaskList.add(SolarSigned[0]);
                } If(MapRelPartnerList.get(RelId).Type__c=='Other Subcontractor'){
                    List<task__c> prepareOtherSub = new List<task__c>();
                    prepareOtherSub=[select id,category__c, project_name__c from task__c where project_name__c=:projectList[0].Id and name =:'Prepare Other Subk' ];
                    If(!prepareOtherSub.isEmpty())
                        SubcontractortaskList.add(prepareOtherSub[0]);
                    List<task__c> OtherSubSigned = new List<task__c>();
                    OtherSubSigned  =[select id,category__c, project_name__c from task__c where project_name__c =:projectList[0].Id and name =:'Get Other Subk Signed' ];
                    If(!OtherSubSigned.isEmpty())
                        SubcontractortaskList.add(OtherSubSigned[0]);
                }
            }
        }
        for( task__c subContractTask: SubcontractortaskList ){
            If(Trigger.IsDelete){
                subContractTask.category__c='Optional';
            }else{
                subContractTask.category__c='Required';}
            FinalSubcontractortaskList.add(subContractTask);
        }
        
        
        if(!FinalSubcontractortaskList.isEmpty())
            update FinalSubcontractortaskList;
        
    }
}