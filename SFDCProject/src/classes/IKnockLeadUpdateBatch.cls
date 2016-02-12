/**
 * Batch job which updates the IKnock with leads information.
 *
 * To execute this batch one time, you can use this script.
 * System.scheduleBatch(new IKnockLeadUpdateBatch(), 'IKnock Lead Update Batch - One Time', 0);
 */
global class IKnockLeadUpdateBatch implements Database.Batchable<Lead>, Database.AllowsCallouts  {
    private BaseClass utils = new BaseClass();
    
    /**
     * We need to retrieve all leads, which have the IKnock address id and status != IKnock Updated and process them.
     *
     * This batch job does one outbound call for each lead.
     */    
    global Iterable<Lead> start(Database.BatchableContext bc) {
        List<Lead> leads = [select id, IsConverted, IKnock_Address_Id__c, IKnock_Sync_Status__c from Lead where IKnock_Address_Id__c != null and IKnock_Sync_Status__c != 'IKnock Updated' and IsConverted = false];
        
        System.debug('Selected following leads to update IKnock ' + leads);  
        return leads;
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> leads){
        try {
        	Sf.iknockLeadSyncService.syncLeadsToIKnock(leads);
        } catch (Exception e) {
            ExceptionLogger.logException(utils.getCurrentClassName(), 'Exception while Updating IKnock with Lead Urls for ' + leads, e);
        }
    }
    
    global void finish(Database.BatchableContext BC){
         //Execute IKnock Opty update batch. 
        //System.scheduleBatch(new IKnockOptyUpdateBatch(), 'IKnock Opty Update Batch - One Time', 0);       
        Database.executebatch((Database.Batchable<Lead>) Type.forName('IKnockOptyUpdateBatch').newInstance(), 5);
    }
}