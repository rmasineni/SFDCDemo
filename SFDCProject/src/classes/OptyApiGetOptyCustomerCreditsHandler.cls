public with sharing class OptyApiGetOptyCustomerCreditsHandler extends OptyApiBaseHandler {
    override public String getApiName() {
        return 'OptyApiGetOptyCustomerCredits';
    }

    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        Opportunity opty = queryOpty(req, resp);
        List<OpportunityContactRole> roles = queryOptyContactRoles(opty.id);
		prepareResponse(queryCustomerCredits(getUniqueIdList(roles, 'ContactId'), req, resp), req, resp);
    }
    
    public List<Customer_Credit__c> queryCustomerCredits(List<Id> contactIds, RestServiceDto.Request req, RestServiceDto.Response resp) {
        String soql = createSoqlWithAuditFields(OptyApiDto.getOptyApiContactCreditFieldMapping().values(), 'Customer_Credit__c', 'Contact__c in :contactIds');
        
       	List<Customer_Credit__c> credits = Database.query(soql);
        
        resp.stopWatch.markSubElapsedTime();
        
        return credits;
    }
    
	public void prepareResponse(List<Customer_Credit__c > credits, RestServiceDto.Request req, RestServiceDto.Response resp) {
        Map<String, String> fieldMapping = OptyApiDto.getOptyApiContactCreditFieldMapping();
        JsonWriter jsonWriter = resp.jsonWriter;
        if (credits.isEmpty()) {
            //This writes a default array
            resp.jsonWriter = new JsonWriter(true);
        } else {
            for (Integer i = 0; i < credits.size(); i++) {
                jsonWriter.newWith(i);
                addToResponse(credits.get(i), fieldMapping, true, req, resp);
            }
        }

        resp.stopWatch.markSubElapsedTime();
    }
}