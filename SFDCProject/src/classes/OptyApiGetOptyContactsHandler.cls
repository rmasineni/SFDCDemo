global with sharing class OptyApiGetOptyContactsHandler extends OptyApiBaseHandler {

    global override String getApiName() {
        return 'OptyApiGetOptyContacts';
    }
    
    global override void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        Opportunity opty = queryOpty(req, resp);
        List<OpportunityContactRole> roles = queryOptyContactRoles(opty.id);
        
		prepareResponse(roles, req, resp);
    }

    public void prepareResponse(List<OpportunityContactRole> roles, RestServiceDto.Request req, RestServiceDto.Response resp) {
        JsonWriter jsonWriter = resp.jsonWriter;
        for (Integer i = 0; i < roles.size(); i++) {
        	jsonWriter.with(i);
            
            addOptyContactRoleToResponse(roles.get(i), req, resp);
            
            jsonWriter.endWith();
        }

        resp.stopWatch.markSubElapsedTime();
    }
}