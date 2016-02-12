/* 
** Class: PartnerContract_Batch
** Author: Raghavendra Masineni
** 
**
*/

global class PartnerContract_Batch implements Database.Batchable <sObject>, Database.Stateful {
	
	PartnerContractsManager contractMaanger;
	public String query = null;
	public String accountFilter = null;
	public boolean testing = false;
	public PartnerContract_Batch(String accountFilter, Boolean testing){
		this.accountFilter = accountFilter;
		this.testing = testing;
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		Date todayDate = date.today();	
		Date dateObj = date.today().adddays(30);
			
		contractMaanger = new PartnerContractsManager();
		contractMaanger.testing = this.testing;
		//query = contractMaanger.getExpieredContractSOQLQuery(this.accountFilter);
		query = contractMaanger.getContractSOQLQuery(this.accountFilter);
        System.debug('XXXXXXXXXXXXXXXXXXXXXXX query: ' + query);
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        contractMaanger.processContracts((List<Partner_Contract__c>) scope);
        return;
    }
    
    global void finish(Database.BatchableContext BC) {
    	
    	AsyncApexJob apexJob = [SELECT Id, Status, NumberOfErrors, ExtendedStatus, JobItemsProcessed,
							TotalJobItems, CreatedBy.Email
							FROM AsyncApexJob WHERE Id =
							:BC.getJobId()];
		Map<String, SunRunContractExpirationEmail__c> customSettings = SunRunContractExpirationEmail__c.getall();
		if(customSettings != null && customSettings.size() > 0){
			List<String> toAddresses = new List<String>();
			toAddresses.addall(customSettings.keySet());
			contractMaanger.sendSuccessEmail(toAddresses, BC.getJobId(), apexJob);
		}			
		BatchUtil.processBatchErrors(bc);	
    }
}