/*
** TODO: 
**
*/
global class HomeDepotOpportunitySyncBatch implements Database.Batchable<Opportunity>, Database.AllowsCallouts  {
	
	private BaseClass utils = new BaseClass();
    public Integer counter = 1;
    public String whereClause {get;set;}
	public HomeDepotOpportunitySyncBatch() {

    }
    
    global Iterable<Opportunity> start(Database.BatchableContext bc) {
        String channelStr = 'Retail';
        String homeDepotStr = 'Home Depot';
        String tobeSyncedStr = BaseClass.Status_ToBeSynced;
        Integer opptyLimit = Integer.valueOf(label.Home_Depot_Lead_Sync_Limit) * 10;
        Set<String> leadSourceValues = utils.getCustomLeadSources(homeDepotStr);
        DateTime syncStartDate = DateTime.parse(label.Home_Depot_Oppty_Sync_Start_DateTime);
		String soql = 'select Id ,Lead_Source_2__c, StageName, accountId, External_Id__c, Prospect_Id__c, External_Sync_Batch_ID_Outbound__c, External_Sync_Status__c, External_Sync_Details__c, ';
        soql += ' Lead_Organization_Location_2__r.AccountNumber, CreatedDate, Opportunity_Status__c, Lead_Organization_Location_2__c, Reason__c, External_Row_ID__c, ';
        soql += ' Account.Id, Account.BillingStreet, Account.BillingCity, Account.BillingCountry, Account.County__c, Account.BillingPostalCode, Account.BillingState from Opportunity ';
		soql += ' where External_Sync_System__c =:homeDepotStr  and External_Sync_Status__c =:tobeSyncedStr and External_Sync_InProgress__c = false  and Lead_Source_2__c in :leadSourceValues ';
		soql += ' and Channel_2__c =:channelStr and Lead_Source_2__c like \'%Home Depot%\' and CreatedDate >= :syncStartDate ';
        soql += ' order by LastModifiedDate Limit :opptyLimit';
        utils.info('Executing soql ' + soql);
        
        List<Opportunity> opportunities = Database.query(soql);
        System.debug('Queried ' + opportunities.size() + ' opportunities for standardization process [' + opportunities + ']');
        return opportunities;
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> opportunities){
        List<Opportunity> opptysReadyToSync = new List<Opportunity>();
        List<Opportunity> opptysNotReadyToSync = new List<Opportunity>();
        List<Id> opportunityIds = new List<Id>();

        String batchId = BC.getJobId() + '_' + counter;
        System.debug('opptys: ' + opportunities);
        
        for(Opportunity optyObj : opportunities){
            opportunityIds.add(optyObj.Id);
        }
        Map<Id, Map<Id, OpportunityContactRole>> opportunityContactMap = Sf.HomeDepotSyncService.getOpportunityRoleMap(opportunityIds);
        for(Integer ii =0; ii < opportunities.size(); ii++){
            Opportunity opty = opportunities.get(ii);
            Contact contactObj;
            Account accountObj = opty.account;
            Map<Id, OpportunityContactRole> roleMap = opportunityContactMap.get(opty.Id);
            
            if(roleMap != null && !roleMap.isEmpty()){
                for(OpportunityContactRole optyContactRoleObj : roleMap.values()){
                    System.debug('optyContactRoleObj: ' + optyContactRoleObj);

                    if(optyContactRoleObj.isPrimary == true){
                        contactObj = optyContactRoleObj.contact;
                        break;
                    }
                }
            } 
            
            if(accountObj != null && contactObj != null){   
                if (Sf.HomeDepotSyncService.isHomeDepotOpptyReadyToSync(opty, accountObj, contactObj)){
                    opptysReadyToSync.add(opty);
                }else{
                    opptysNotReadyToSync.add(opty);
                }
            }else{
                    opptysNotReadyToSync.add(opty);
            } 
        }

        if(!opptysReadyToSync.isEmpty()){
            //Sf.HomeDepotSyncService.syncOpportunities(batchId, opportunities);
            Sf.HomeDepotSyncService.syncOpportunities(batchId, opptysReadyToSync);
            counter++;
        }

        for(Opportunity oppObj:opptysNotReadyToSync){
            oppObj.External_Sync_Status__c = BaseClass.Status_SyncError;
            oppObj.External_Sync_Details__c = 'One or more fields required for sync are null.';
            oppObj.External_Sync_Details__c += 'Please make sure First Name, Last Name, Email, Phone, Address, County, Retaill Store Location are populated.';
        }
        update opptysNotReadyToSync;
    }
    
    global void finish(Database.BatchableContext BC){
		BatchUtil.processBatchErrors(bc);
    }
    
}