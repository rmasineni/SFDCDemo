trigger trg_scpartner_rel_after_insert on Service_Contract_Partner_Rel__c (after insert) {
    Set<Id> installerIds = new Set<Id>();
    Set<Id> salesIds = new Set<Id>();
    Map<Id, Set<Id>> scInstallerMap = new Map<Id, Set<Id>>();
    Map<Id,Set<Id>> scSalesOrgMap = new Map<Id,Set<Id>>();
        for(Service_Contract_Partner_Rel__c partnerRelObj : Trigger.new){
            if(partnerRelObj.Type__c != null && partnerRelObj.Type__c == ServiceContractUtil.INSTALL
               && partnerRelObj.Account__c != null && partnerRelObj.ServiceContract__c != null){
                   installerIds.add(partnerRelObj.Account__c);
                   Set<Id> tempInstallerIds = scInstallerMap.containsKey(partnerRelObj.ServiceContract__c) ?  scInstallerMap.get(partnerRelObj.ServiceContract__c) : new Set<Id>();
                   tempInstallerIds.add(partnerRelObj.Account__c);
                   scInstallerMap.put(partnerRelObj.ServiceContract__c, tempInstallerIds);
               }
        }
    System.debug('installerIds: ' + installerIds);
    ServiceContractUtil.createServiceContractSharing(scInstallerMap, installerIds);
    for(Service_Contract_Partner_Rel__c partnerRelObj : Trigger.new){
        if(partnerRelObj.Type__c != null && partnerRelObj.Type__c == ServiceContractUtil.SALES 
           && partnerRelObj.Account__c != null && partnerRelObj.ServiceContract__c != null){
               salesIds.add(partnerRelObj.Account__c);
               Set<Id> tempSalesIds = scSalesOrgMap.containsKey(partnerRelObj.ServiceContract__c) ?  scSalesOrgMap.get(partnerRelObj.ServiceContract__c) : new Set<Id>();
               tempSalesIds.add(partnerRelObj.Account__c);
               scSalesOrgMap.put(partnerRelObj.ServiceContract__c, tempSalesIds);
           }
    }
    System.debug('salesIds: ' + salesIds);
    ServiceContractUtil.createServiceContractSharingSales(scSalesOrgMap, salesIds);
}