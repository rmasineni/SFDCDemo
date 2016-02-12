public class AccountBulkUpdate {
    
    public String getAccountBulkUpdateQuery(){
        String sqlQuery = 'Select id, BillingStreet, BillingCity, BillingState, BillingPostalCode, Zip_6__c,CDYNE_Status__c,' ;
            sqlQuery += ' CDYNE_Result__c, CongressDistrictNumber__c, StateLegislativeUpper__c, StateLegislativeLower__c,';
            sqlQuery += ' FromLongitude__c, FromLatitude__c, ToLongitude__c, ToLatitude__c, AvgLongitude__c, AvgLatitude__c, ';
            sqlQuery += ' HasDaylightSavings__c, TimeZone__c, AreaCode__c, Account_type__c,Generation_Asset__c from Account ';
            sqlQuery += ' Where (Account_type__c = \'Residential Customer\' OR Account_type__c = null) and ';
            sqlQuery += ' BillingStreet != null and Generation_Asset__c != null';
            
        System.debug('sqlQuery: ' + sqlQuery);
        return sqlQuery;
    }
    
    public void processAccountBulkUpdate(List<Account> accountRecords){
        
        CDYNEService CDYNE = new CDYNEService();
        Set<String> setaccIds = new Set<String>();
        List<Account> accList = new List<Account>();
        for(Account accountObj : accountRecords){
            setaccIds.add(String.ValueOf(accountObj.Id));
        }
        
        if(setaccIds != null && setaccIds.size() > 0){
                CDYNE.processZipPlusSixForAccountsImmediate(setaccIds); 
        }
    }
}