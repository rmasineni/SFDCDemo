/* 
** Class: ServiceContract_Batch
** Author: Raghavendra Masineni
** 
**
*/

global class ServiceContract_Batch implements Database.Batchable <sObject>, Database.Stateful {
	
	public Static Set<String> partnerIds = new Set<String>();
	public Set<String> salesPartnerIds;
	public String query = null;
	public String proposalFilter = null;
	public boolean testing = false;
	public static Map<String, Partners_For_Service_Contrac_Batch__c> partnersForSCBatchMap = new Map<String, Partners_For_Service_Contrac_Batch__c>();

    static
    {              
        partnersForSCBatchMap = Partners_For_Service_Contrac_Batch__c.getAll();
        for(Partners_For_Service_Contrac_Batch__c scBatchObj: partnersForSCBatchMap.values()){
        	if(scBatchObj.Partner_Id__c != null && scBatchObj.Partner_Id__c != ''){
        		partnerIds.add(scBatchObj.Partner_Id__c);
        	}
        }
	}

	public ServiceContract_Batch(Boolean testing){
		this.salesPartnerIds = ServiceContract_Batch.partnerIds;
		System.debug('this.salesPartnerIds: ' + this.salesPartnerIds);
		this.testing = testing;
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		String stage = 'SR Approved';
		String creditStatus = 'SR Credit Approved';
		String createSC = 'Yes';
		query = 'Select Id, name, Create_Service_Contract__c,Sunrun_Credit_Status__c,stage__c,Sales_Partner__c from Proposal__c where Create_Service_Contract__c =:createSC and Sunrun_Credit_Status__c =:creditStatus and stage__c =:stage and Sales_Partner__c in :salesPartnerIds  ' ;
		if(Test.isRunningTest()){
			query += ' limit 1 ';
		}
        System.debug('XXXXXXXXXXXXXXXXXXXXXXX query: ' + query);
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        ServiceContractUtil.createServiceContract((List<Proposal__c>) scope);
        return;
    }
    
    global void finish(Database.BatchableContext BC){
		BatchUtil.processBatchErrors(bc);
    }
}