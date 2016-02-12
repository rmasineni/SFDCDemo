/**
 * Address standardization batch job for leads, which supports customized where clause so we can pick different leads
 * for processing.
 * 
 * Where clause can be given during the construction and if not given, then it will try to pick from setting AddressStandardizationLeadWhereClause
 * If that setting is empty, then it will use the default where clause.
 */
global class AddressStandardizationLeadBatch implements Database.Batchable<Lead>, Database.AllowsCallouts  {
    private BaseClass utils = new BaseClass();
    public String whereClause {get;set;}
    
    public AddressStandardizationLeadBatch() {
        this(null);
    }
    
    public AddressStandardizationLeadBatch(String whereClause) {
        if (utils.isEmpty(whereClause)) {
            whereClause = Sf.settingsService.getString('AddressStandardizationLeadWhereClause', null);
        }
        
        if (utils.isEmpty(whereClause)) {
            whereClause = '(Address_Standardization_Status__c = \'Standardization Required\'' 
                            + ' or Address_Standardization_Status__c = \'Standardization Error\''
                            + ' or Address_Standardization_Status__c = \'Standardized by UI\''
                            + ' or Address_Standardization_Status__c = \'Details Required\')';
        }
        
        this.whereClause = whereClause;
    }
    
    global Iterable<Lead> start(Database.BatchableContext bc) {
        String soql = 'select Id from Lead where ' + whereClause + ' and IsConverted = false order by LastModifiedDate';
        utils.info('Executing soql ' + soql);
        
        List<Lead> leads = Database.query(soql);
        System.debug('Queried ' + leads.size() + ' leads for standardization process [' + leads + ']');
        return leads;
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> leads){
        Sf.addressService.standardizeLeadsAddress(utils.getUniqueIdList(leads, 'Id'));
    }
    
    global void finish(Database.BatchableContext BC){
		BatchUtil.processBatchErrors(bc);
    }
}