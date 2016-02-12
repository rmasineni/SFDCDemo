/*
** TODO: 
**
*/
global class HomeDepotLeadSyncBatch implements Database.Batchable<Lead>, Database.AllowsCallouts  {
    
    private BaseClass utils = new BaseClass();
    public Integer counter = 1;
    public String whereClause {get;set;}
    public HomeDepotLeadSyncBatch() {

    }
    
    global Iterable<Lead> start(Database.BatchableContext bc) {
        String channelStr = 'Retail';
        String homeDepotStr = 'Home Depot';
        String tobeSyncedStr = BaseClass.Status_ToBeSynced;
        Integer leadLimit = Integer.valueOf(label.Home_Depot_Lead_Sync_Limit) * 10;
        DateTime syncStartDate = DateTime.parse(label.Home_Depot_Lead_Sync_Start_DateTime);
        Set<String> leadSourceValues = utils.getCustomLeadSources(homeDepotStr);
        String soql = 'select FirstName, External_Sync_Batch_ID_Inbound__c, Status, Lead_Status__c, LastName, Country, County__c, Title, Street, City, State,PostalCode, Phone, Alternate_Phone__c, Email, Notes__c, Contact_Costco_Member_ID__c, External_Id__c, Lead_Organization_Location_2__r.AccountNumber, Lead_Organization_Location_2__c, Prospect_Id__c, External_Sync_Batch_ID_Outbound__c, External_Sync_Status__c, External_Sync_Details__c,CreatedDate, External_Row_ID__c from Lead ';
        soql += ' where IsConverted = false and Custom_Lead_Source__c in :leadSourceValues  and External_Sync_System__c =:homeDepotStr  and External_Sync_Status__c =:tobeSyncedStr and External_Sync_InProgress__c = false ';
        //soql += ' and CreatedDate >= :label.HomeDepotLeadSyncStartDate ';
        //soql += ' and FirstName != null and LastName != null and Phone != null and Email != null and Street != null and City != null and Country != null and County__c != null and Postalcode != null and State != null and Prospect_Id__c != null and Lead_Organization_Location_2__r.AccountNumber !=null ';
        //soql += ' and CreatedDate >= 2015-09-01T07:00:00.000+0000 ';
        soql += ' and CreatedDate >= :syncStartDate ';
        soql += ' order by LastModifiedDate Limit :leadLimit';
        utils.info('Executing soql ' + soql);
        
        List<Lead> leads = Database.query(soql);
        System.debug('Queried ' + leads.size() + ' leads for standardization process [' + leads + ']');
        return leads;
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> leads){
        String batchId = BC.getJobId() + '_' + counter;
        System.debug('leads: ' + leads);
        List<lead> leadsReadyToSync = new List<lead>();
        List<lead> leadsNotReadyToSync = new List<lead>();
        for(lead lead: leads){
            if(Sf.HomeDepotSyncService.isHomeDepotLeadReadyToSync(lead)){
                leadsReadyToSync.add(lead);
            }else{
                leadsNotReadyToSync.add(lead);
            }
        }

        if(!leadsReadyToSync.isEmpty()){
           sf.HomeDepotSyncService.syncLeads(batchId, leadsReadyToSync);
            counter++;
        }

        for(lead lead:leadsNotReadyToSync){
            lead.External_Sync_Status__c = BaseClass.Status_SyncError;
            lead.External_Sync_Details__c = 'One or more fields required for sync are null.';
            lead.External_Sync_Details__c += 'Please make sure First Name, Last Name, Email, Phone, Address, County, Retaill Store Location are populated.';
        }
        update leadsNotReadyToSync;
    }
    
    global void finish(Database.BatchableContext BC){
		BatchUtil.processBatchErrors(bc);
    }
    
}