/**
 * Batch job which updates the IKnock with opty information (as of now, the partner opty url for leads converted from Iknock leads)
 *
 * To execute this batch one time, you can use this script.
 * System.scheduleBatch(new IKnockOptyUpdateBatch(), 'IKnock Opty Update Batch - One Time', 0);
 *
 * Even though we are primarily looking for opty, we are creating batch for Lead because we need some lead info like Address_Id__c to update
 * IKnock
 */
global class IKnockOptyUpdateBatch implements Database.Batchable<Lead>, Database.AllowsCallouts  {
	private BaseClass utils = new BaseClass();
    
    /**
     * We need to retrieve all opties, which are converted from IKnock leads (leads with IKnock Address Id not null) and status != IKnock Updated and process them.
     *
     * This batch job does one outbound call for each opty.
     */    
    global Iterable<Lead> start(Database.BatchableContext bc) {
        List<Lead> leads = [select id, IKnock_Address_Id__c, IKnock_Sync_Status__c, ConvertedOpportunity.id, ConvertedOpportunity.IKnock_Sync_Status__c from Lead where IKnock_Address_Id__c != null and ConvertedOpportunityId != null and ConvertedOpportunity.IKnock_Sync_Status__c != 'IKnock Updated' ];
        
        System.debug('Selected following Opties to update IKnock ' + leads);  
        return leads;
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> leads){
        try {
        	Sf.iknockLeadSyncService.syncOptiesToIKnock(leads);
        } catch (Exception e) {
            ExceptionLogger.logException(utils.getCurrentClassName(), 'Exception while Updating IKnock with Opty Urls for ' + leads, e);
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }
}