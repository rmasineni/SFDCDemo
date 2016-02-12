/**
 * Address standardization batch job for acounts, which supports customized where clause so we can pick different accounts
 * for processing.
 * 
 * Where clause can be given during the construction and if not given, then it will try to pick from setting AddressStandardizationAcctWhereClause
 * If that setting is empty, then it will use the default where clause.
 */
global class AddressStandardizationAccountBatch implements Database.Batchable<Account>, Database.AllowsCallouts  {
    private BaseClass utils = new BaseClass();
    public String whereClause {get;set;}
    
    public AddressStandardizationAccountBatch() {
        this(null);
    }
    
    public AddressStandardizationAccountBatch(String whereClause) {
        if (utils.isEmpty(whereClause)) {
            whereClause = Sf.settingsService.getString('AddressStandardizationAcctWhereClause', null);
        }
        
        if (utils.isEmpty(whereClause)) {
            whereClause = '(Address_Standardization_Status__c = \'Standardization Required\'' 
                            + ' or Address_Standardization_Status__c = \'Standardization Error\''
                            + ' or Address_Standardization_Status__c = \'Standardized by UI\''
                            + ' or Address_Standardization_Status__c = \'Details Required\')';
        }
		
        this.whereClause = whereClause;
    }
    
    global Iterable<Account> start(Database.BatchableContext bc) {
        String soql = 'select Id from Account where ' + whereClause + ' order by LastModifiedDate';
        utils.info('Executing soql ' + soql);
        List<Account> accounts = Database.query(soql);
       	System.debug('Queried ' + accounts.size() + ' accounts for standardization process [' + accounts + ']');
       	return accounts;
    }
    
    global void execute(Database.BatchableContext BC, List<Account> accounts){
		Sf.addressService.standardizeAccountsAddress(utils.getUniqueIdList(accounts, 'Id'));
    }
    
    global void finish(Database.BatchableContext BC){
		BatchUtil.processBatchErrors(bc);
    }
}