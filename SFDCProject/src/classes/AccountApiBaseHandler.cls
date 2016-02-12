public abstract class AccountApiBaseHandler extends RestService {
	
    public List<Account> queryAccounts(String channelType, String verticalType, String recordType, 
			Integer page, Integer pageSize, RestServiceDto.Request req, RestServiceDto.Response resp) {
		Set<String> fields = new Set<String>();
		fields.addAll(getAccountFieldMapping().values());
        
		List<String> whereClauses = new List<String>();
        if (recordType != null) {
        	whereClauses.add('RecordType.Name = :recordType');
        }                
        
		if (channelType != null) {
			whereClauses.add('Channel_Type__c = :channelType');
		}                
                
		if (verticalType != null) {
			whereClauses.add('Vertical_Type__c = :verticalType');
		}
       
		whereClauses.add('Active__c = true');
		String soql = createSoqlWithAuditFields(new List<String>(fields), 'Account', whereClauses, 'Name', page, pageSize);

		List<Account> accounts = Database.query(soql);
        
        resp.stopWatch.markSubElapsedTime();
        
        return accounts;
    }
    
    public static Map<String, String> getAccountFieldMapping() {
	   return RestServiceDto.getFieldMapping('Account Api', 'Account');
    }
}