trigger trg_sc_before_update on ServiceContract (before update, before insert) {
    
    Boolean skipValidations = false;
    skipValidations = SkipTriggerValidation.performTriggerValidations();    
    List<servicecontract> scList = new List<servicecontract>();
    Map<Id,ServiceContract> ServiceContractMap = new Map<Id,ServiceContract>();
    Integer counter = 0;
    Integer dealIdCount = 0;
    for(servicecontract sc : Trigger.new){
        if((sc.Name == null || sc.Name == '') || (sc.Name != null && sc.Name == 'Sunrun Contract')){
            counter++;
        }
        if(sc.deal_Id__c == null || sc.deal_Id__c == ''){
            dealIdCount++;
        }
        sc.RelatedObjects_Last_Modified_Date__c = datetime.now();
        if((skipValidations == false) && Trigger.isUpdate && Trigger.oldmap.get(sc.Id).marked_for_deletion__c == 'Yes'){
            sc.adderror(SunrunErrorMessage.getErrorMessage('ERROR_000028').error_message__c);
        }
     }  
     
     List<String> randomNumners = new List<String>();
     if(counter > 0){
        randomNumners = RandomNumberGenerator.getUniqueServiceContractNumbers(counter);
     }

     List<String> dealIds = new List<String>();
     if(dealIdCount > 0){
        dealIds = RandomNumberGenerator.getUniqueDelId(dealIdCount);
     }

    for(servicecontract sc : Trigger.new)
    {
        if(((sc.Name == null || sc.Name == '') || (sc.Name != null && sc.Name == 'Sunrun Contract')) && counter > 0){
            sc.Name = randomNumners[counter - 1];
            -- Counter;
        }
        
        if(sc.deal_Id__c == null || sc.deal_Id__c == ''){
            sc.deal_Id__c = dealIds[dealIdCount - 1];
            -- dealIdCount;
        }

        if(sc.Legacy_Asset_Number__c != null){
            sc.Agreement_Number__c = sc.Legacy_Asset_Number__c;
        }else{      
            sc.Agreement_Number__c = sc.Name;
        } 
       
        if(Trigger.isUpdate && sc.Install_Partner_Id__c != null 
            && Trigger.oldmap.get(sc.Id).Install_Partner_Id__c !=  sc.Install_Partner_Id__c){
            String installPartnerId = sc.Install_Partner_Id__c + '';
            sc.Installed_By__c = (installPartnerId.contains(Label.Sunrun_Inc_Id)) ? Label.Sunrun_Installation_Service : sc.Install_Partner_Id__c;
        }
        
    } 
 
    
    //Comment below code for Phase-1 migration.

    if(skipValidations == false){
        ServiceContractUtil.updateServiceContract(trigger.isInsert, trigger.isUpdate, Trigger.new, Trigger.newMap, Trigger.oldmap);
    }  
    //update M0,M1,M2,M3
    
    /* BSKY-6792 user story Logic Start */
    If(Trigger.isUpdate)
    {
    // Map<Id,ServiceContract> ServiceContractMap = new Map<Id,ServiceContract>();
     for (ServiceContract sc: Trigger.New) 
     {
      if (((Trigger.oldMap.get(sc.ID).Status__c == 'Deal Cancelled' || Trigger.oldMap.get(sc.ID).Status__c =='Deal Cancelled due to credit') && (sc.Status__c !='Deal Cancelled' && sc.Status__c != 'Deal Cancelled due to credit')) ) 
      {
         ServiceContractMap.put(sc.Id, sc);
      }
     }
     if(ServiceContractMap.size()>0 && !ServiceContractMap.isEmpty())
     {
      ProjectStatusUpdateClass.ScProjectStatUpdate(ServiceContractMap);
     }
    }
    /* BSKY-6792 user story Logic End */ 
  
}