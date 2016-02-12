/*
** TODO: 
**
*/
global class HomeDepotLeadLookupBatch implements Database.Batchable<String>, Database.AllowsCallouts  {
    /*
	private BaseClass utils = new BaseClass();
    public String whereClause {get;set;}
    public HomeDepotLeadLookupBatch() {

    }*/

    global List<String> start(Database.BatchableContext bc) {
    /*    
        String channelStr = 'Retail';
        String homeDepotStr = 'Home Depot';
        String tobeSyncedStr = BaseClass.Status_ToBeSynced;
        Set<String> leadSourceValues = utils.getCustomLeadSources(homeDepotStr);
        String soql = 'select FirstName, LastName, Title, Street, City, State,PostalCode, Phone, Alternate_Phone__c, Email, Notes__c, Contact_Costco_Member_ID__c, External_Id__c, ';
        soql += ' Lead_Organization_Location_2__r.AccountNumber,  Prospect_Id__c, External_Sync_Batch_ID_Outbound__c, External_Sync_Status__c, External_Sync_Details__c, CreatedDate from Lead ';
        soql += ' where IsConverted = false  and Custom_Lead_Source__c in :leadSourceValues and External_Sync_System__c =:homeDepotStr  and External_Sync_Batch_ID_Outbound__c != null ';
        soql += ' and External_Sync_Batch_ID_Outbound__c != \'\' and External_Sync_InProgress__c = true ';
        soql += ' order by LastModifiedDate ';
        utils.info('Executing soql ' + soql);
        List<String> batchIds = new List<String>();
        Set<String> setBatchIds = new Set<String>();
        for(Lead leadObj : Database.query(soql)){
            if(!setBatchIds.contains(leadObj.External_Sync_Batch_ID_Outbound__c)){
                setBatchIds.add(leadObj.External_Sync_Batch_ID_Outbound__c);
                batchIds.add(leadObj.External_Sync_Batch_ID_Outbound__c);
            }
        }
        
        System.debug('Queried ' + batchIds.size() + ' batch Ids for the lookup [' + batchIds + ']');
        return batchIds;
     */
        return null;    
    }
    
    global void execute(Database.BatchableContext BC, List<String> batchIds){
        //lookupLeads(String batchNumber, String createdDate)
        //String createdDate = '\'08/17/2015 00:00:00\'';
        /*
        String createdDateStart; 
        String createdDateEnd; 
        Set<String> prospectIds;
        map<String, Map<String, HomeDepotLeadLookupDto.LeadDTO>> batchIdLeadLookupDTO = new map<String, Map<String, HomeDepotLeadLookupDto.LeadDTO>>();

        if(!Test.isRunningTest() && Sf.settingsService.getString('HomeDepotUseLookupDate') == 'true'){
            createdDateStart = label.Home_Depot_Lead_Sync_Start_DateTime;            
            createdDateEnd = label.Home_Depot_Lead_Sync_End_DateTime;            
        }else{
            Datetime dateToday = DateTime.Now();
            String todayDate = dateToday.format('MM/dd/yyyy');
            createdDateStart = todayDate + ' ' + label.Home_Depot_Lead_Sync_Start_Time;
            createdDateEnd = todayDate + ' ' + label.Home_Depot_Lead_Sync_End_Time;
        }
        for(String batchId : batchIds){
            System.debug('batchId :' +batchId);
            //Sf.HomeDepotSyncService.lookupLeads(batchId, createdDate);
            batchIdLeadLookupDTO.put(batchId, Sf.HomeDepotSyncService.lookupLeads(batchId, createdDateStart, createdDateEnd));
             
        }

        Sf.HomeDepotSyncService.updateLeads(batchIdLeadLookupDTO); 
        */
    }
    
    global void finish(Database.BatchableContext BC){
        
    }    
}