global class AccountBulkUpdateBatch implements Database.Batchable <sObject>, Database.Stateful, Database.AllowsCallouts{
	public String query = null;
    public String accountType;
    
    AccountBulkUpdate accBulk;

    public AccountBulkUpdatebatch(){
        accountType = 'Residential';
		
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
    	accBulk = new AccountBulkUpdate();
    	query = accBulk.getAccountBulkUpdateQuery();
    	System.debug('CSLB query: ' + query );
        return Database.getQueryLocator(query);
    }
    
     global void execute(Database.BatchableContext BC, List<sObject> scope) {
        System.debug('scope: ' + scope);
        accBulk.processAccountBulkUpdate((List<Account>) scope);
        return;
    }
    
    global void finish(Database.BatchableContext BC) {
    	BatchUtil.processBatchErrors(bc);
    }  
    
}