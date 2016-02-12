trigger trg_after_insert_asset_case on Case (before insert,before update) { 
   //recid=[select id from recordtype where SobjectType='Case' and name='FS Ticket' limit 1].id;
   Boolean skipValidations = false;
  skipValidations = SkipTriggerValidation.performTriggerValidations();
  if(skipValidations == false){

    Map<id,String> assetSerialMap = new Map<id, String>();
    Map<Id,Id> caseToservicecontract = New Map<Id,Id>();
    Map<Id,Id> servicecontractTocontact = New Map<Id,Id>();
    List<Case> caseList = new List<Case>();
    Set<id>scids = new Set<id>();
    for(case c :trigger.new){
        if((trigger.isinsert&&c.Service_Contract__c!=null)||(trigger.isUpdate&&trigger.oldmap.get(c.id).service_contract__c!=c.service_contract__c)){
            scids.add(c.service_contract__c);
        }
        // Sridevi V 06/11 
       // if( c.ContactId == null && c.Service_Contract__c != null){
        if((trigger.isinsert && c.ContactId == null && c.Service_Contract__c != null)||(trigger.isUpdate&&trigger.oldmap.get(c.id).service_contract__c!=c.service_contract__c)){
                caseToservicecontract.put(c.Id,c.Service_Contract__c);
                caseList.add(c);
            } 
        
    }
    List<ServiceContract> scList = New List<ServiceContract>();
            if(!caseToservicecontract.isEmpty()){   
                 scList = [SELECT Id,ContactId FROM servicecontract Where id IN : caseToservicecontract.Values()];
                 
             for(ServiceContract sc: scList){
                servicecontractTocontact.put(sc.Id,sc.ContactId); 
            }
             if(!caseList.isEmpty()&& !servicecontractTocontact.isEmpty()){
         for(Case c: caseList ) {            
            id sc = caseToservicecontract.get(c.Id);          
            c.ContactId = servicecontractTocontact.get(sc);    
                 }
               }
            }
         //Sridevi v   
    if(!scids.isempty()){
        for(Asset__c a:[select servicecontract__c,serial_number__c from asset__c where ServiceContract__c in:scids and type__c='Meter' and status__c='Active']){
            assetSerialMap.put(a.servicecontract__c,a.serial_number__c);
            system.debug('---serialnumber'+assetSerialMap);
        }
        
        
        for(case c:trigger.new){
        if(assetSerialMap.containskey(c.Service_Contract__c)){
            c.Meter_Serial_Number__c=assetSerialMap.get(c.Service_Contract__c);
        }
        }
        
    }
    //SrideviV
       
  }
   

}