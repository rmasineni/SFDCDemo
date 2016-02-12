public with sharing class OptyApiReadOptyHandler extends OptyApiBaseHandler {

    override public String getApiName() {
        return 'OptyApiReadOpty';
    }
    
    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        //Here is how we will handle the read.
        //
        //1. From the lead to rest api mapping get the list of fields that needs to be read
        //		mapping will not be there for audit fields, so they will need to be add separately.
        //2. Query the lead for prospect id with those fields
        //3. Create a json with all fields
        Opportunity opty = queryOpty(req, resp);
        resp.recordId = opty.id;
        addOptyToResponse(opty, req, resp);
    }
}