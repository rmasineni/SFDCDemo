public with sharing class AccountApiGetAccountsHandler extends AccountApiBaseHandler {
	
    override public String getApiName() {
        return 'AccountApiGetAccounts';
    }
    
    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        String recordType = req.getStringParam('recordType');
        String channelType = req.getStringParam('channelType');
        String verticalType = req.getStringParam('verticalType');
        Integer page = req.getIntegerParam('page');
        Integer pageSize = req.getIntegerParam('pageSize');
        
        if (page == null || page < 1) {
            page = 1;
        }
        
        if (pageSize == null || pageSize < 1) {
            pageSize = Sf.settingsService.getInteger('AccountApiGetAccountsPageSize', 250);
        }

        List<Account> accounts = queryAccounts(channelType, verticalType, recordType, page, pageSize, req, resp);
        if (accounts.isEmpty()) {
            //This will return the empty array [] back to user otherwise, it
            //will return empty object {}, which is wrong as clients expect
         	resp.jsonWriter = new JsonWriter(true);
        } else {
			addToResponse(accounts, getAccountFieldMapping(), true, req, resp);
        }
    }
}