/**
 * Batch job which retrieves the leads from IKnock service and create leads.
 *
 * To execute this batch one time, you can use this script.
 * System.scheduleBatch(new IKnockLeadSyncBatch(), 'IKnock Lead Sync Batch - One Time', 0);
 */
global class IKnockLeadSyncBatch implements Database.Batchable<Lead>, Database.AllowsCallouts  {
    private BaseClass utils = new BaseClass();
    
    /**
     * Even though we don't need any of the existing data to proces the service, we will retrieve some data just to execute
     * the batch multiple times, each time it is trigged
     *
     * At this time, we can only batch process 25 leads (due to Too Many DML issue otherwise), we need to execute this batch
     * multiple times as each time it executes we get new DML limit count.
     */    
    global Iterable<Lead> start(Database.BatchableContext bc) {
        List<Lead> leads = new List<Lead>();
        Integer maxIterations = Sf.settingsService.getInteger('iKnockLeadExtractMaxIterationsPerBatch');
        for (Integer i = 0; i < maxIterations; i++) {
            leads.add(new Lead());
        }
        
        return leads;
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> leads){
        try {
        	Sf.iknockLeadSyncService.retrieveLeads();
        } catch (Exception e) {
            ExceptionLogger.logException(utils.getCurrentClassName(), 'Exception while processing leads ' + leads, e);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        BatchUtil.processBatchErrors(bc);
        //System.scheduleBatch(new IKnockLeadUpdateBatch(), 'IKnock Lead Update Batch - One Time', 0);
        Database.executebatch((Database.Batchable<Lead>) Type.forName('IKnockLeadUpdateBatch').newInstance(), 5);
    }
}