/*
** TODO: 
**
*/
global class HomeDepotOpportunityLookupBatch implements Database.Batchable<String>, Database.AllowsCallouts  {
	/*
	private BaseClass utils = new BaseClass();
    public String whereClause {get;set;}
	public HomeDepotOpportunityLookupBatch() {

    }*/

    global List<String> start(Database.BatchableContext bc) {
        /*
        String channelStr = 'Retail';
        String homeDepotStr = 'Home Depot';
        String tobeSyncedStr = BaseClass.Status_ToBeSynced;
        Set<String> leadSourceValues = utils.getCustomLeadSources(homeDepotStr);
        String soql = 'select Id , StageName, Lead_Source_2__c, accountId, External_Id__c, Prospect_Id__c, External_Sync_Batch_ID_Outbound__c, External_Sync_Status__c, External_Sync_Details__c, ';
        soql += ' Account.Id, Account.BillingStreet, Account.BillingCity, Account.BillingCountry, Account.County__c, Account.BillingPostalCode, Account.BillingState from Opportunity ';
		soql += ' where Lead_Source_2__c in :leadSourceValues and External_Sync_System__c =:homeDepotStr and External_Sync_Batch_ID_Outbound__c != null ';
		soql += ' and Channel_2__c =:channelStr  and External_Sync_Batch_ID_Outbound__c != \'\' and External_Sync_InProgress__c = true ';
        soql += ' order by LastModifiedDate ';
        utils.info('Executing soql ' + soql);
		List<String> batchIds = new List<String>();
		Set<String> setBatchIds = new Set<String>();
		for(Opportunity optyObj : Database.query(soql)){
			if(!setBatchIds.contains(optyObj.External_Sync_Batch_ID_Outbound__c)){
				setBatchIds.add(optyObj.External_Sync_Batch_ID_Outbound__c);
				batchIds.add(optyObj.External_Sync_Batch_ID_Outbound__c);
			}
		}
		
        System.debug('Queried ' + batchIds.size() + ' batch Ids for the lookup [' + batchIds + ']');
        return batchIds; */
        return null; 
    }
    
    global void execute(Database.BatchableContext BC, List<String> batchIds){
        //lookupLeads(String batchNumber, String createdDate)
        //String createdDate = '\'08/17/2015 00:00:00\'';
        /*
        String createdDateStart; 
        String createdDateEnd; 
        map<String, Map<String, HomeDepotLeadLookupDto.LeadDTO>> batchIdLeadLookupDTO = new map<String, Map<String, HomeDepotLeadLookupDto.LeadDTO>>();
          
        if(!Test.isRunningTest() &&  Sf.settingsService.getString('HomeDepotUseLookupDate') == 'true'){     
            createdDateStart = label.Home_Depot_Oppty_Sync_Start_DateTime;            
            createdDateEnd = label.Home_Depot_Oppty_Sync_End_DateTime;           
        }else{
            Datetime dateToday = DateTime.Now();
            String todayDate = dateToday.format('MM/dd/yyyy');
            createdDateStart = todayDate + ' ' + label.Home_Depot_Oppty_Sync_Start_Time;
            createdDateEnd = todayDate + ' ' + label.Home_Depot_Oppty_Sync_End_Time;
        }

        for(String batchId : batchIds){
			//Sf.HomeDepotSyncService.lookupLeads(batchId, createdDateStart, createdDateEnd);
            batchIdLeadLookupDTO.put(batchId, Sf.HomeDepotSyncService.lookupLeads(batchId, createdDateStart, createdDateEnd));
        }

        Sf.HomeDepotSyncService.updateLeads(batchIdLeadLookupDTO); 
        */
    }
    
    global void finish(Database.BatchableContext BC){
    	
    }
    
}