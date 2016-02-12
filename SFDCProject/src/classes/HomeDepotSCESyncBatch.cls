global class HomeDepotSCESyncBatch implements Database.Batchable<Service_Contract_Event__c>, Database.AllowsCallouts  {
  
  private BaseClass utils = new BaseClass();
    public Integer counter = 1;
    public String whereClause {get;set;}
  public HomeDepotSCESyncBatch() {

    }
    
    global Iterable<Service_Contract_Event__c> start(Database.BatchableContext bc) {
        
        String homeDepotStr = 'Home Depot';
        String tobeSyncedStr = BaseClass.Status_ToBeSynced;
        Integer leadLimit = Integer.valueOf(label.Home_Depot_Lead_Sync_Limit) * 10;
        
        Set<String> leadSourceValues = utils.getCustomLeadSources(homeDepotStr);
        String soql = 'select Id, External_Sync_Batch_ID_Inbound__c, External_Id__c, External_Sync_Batch_ID_Outbound__c, External_Sync_Status__c, External_Sync_Details__c, Service_contract__c from Service_Contract_Event__c ';
        soql += ' where External_Sync_System__c =:homeDepotStr  and External_Sync_Status__c =:tobeSyncedStr and External_Sync_InProgress__c = false and External_id__c = null ';
        //soql += ' and CreatedDate >= 2015-09-01T07:00:00.000+0000 ';
        soql += ' order by LastModifiedDate Limit :leadLimit';
        utils.info('Executing soql ' + soql);
        
        List<Service_Contract_Event__c> scEvents = Database.query(soql);
        System.debug('Queried ' + scEvents.size() + ' scEvents for standardization process [' + scEvents + ']');
        return scEvents;
    }
    
    global void execute(Database.BatchableContext BC, List<Service_Contract_Event__c> scEvents){
      String batchId = BC.getJobId() + '_' + counter;
      System.debug('scEvents: ' + scEvents);
      List<Service_Contract_Event__c> sceSyncList = new List<Service_Contract_Event__c>();
        for(Service_Contract_Event__c scEvent: ScEvents){
            sceSyncList.add(scEvent);
        }
        if(!sceSyncList.isEmpty()){
           sf.HomeDepotSyncService.syncServiceContractEvents(batchId, sceSyncList);
            counter++;
        }

    }
    
    global void finish(Database.BatchableContext BC){
		BatchUtil.processBatchErrors(bc);
    }
    
}