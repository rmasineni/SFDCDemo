global with sharing class ContactApiUpdateContactHandler extends RestService implements RestRequestHandler {
    override public String getApiName() {
        return 'ContactApiUpdateContact';
    }

    /**
     * Method implements the patch protocol for lead. For patch, it will process only the fields
     * which are explicitly requested in the request.
     */ 
    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        ContactApiGetContactHandler getHandler = new ContactApiGetContactHandler();

        initRequest(req, resp);
        
		Contact contact = getHandler.queryContact(req, resp);
        
        applyPatch(contact, ContactApiDto.getContactApiContactFieldMapping(), req);

        validateRequiredFields(contact, ContactApiDto.getContactApiContactRequiredFields(), 
			ContactApiDto.getContactApiContactFieldMapping());
        
		saveRecord(contact, req, resp);
        
        getHandler.prepareResponse(contact, req, resp);
    }
    
    public JsonReader initRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        debug('Comming to initRequest with request ' + req);
        
        processDefaultsAndOverrides(getApiName(), req.jsonReader);
        
        debug('Request after pre-processing ' + req.jsonReader);
        
        resp.stopwatch.markSubElapsedTime();
        
        return req.jsonReader;
    }
    
    public Contact saveRecord(Contact contact, RestServiceDto.Request req, RestServiceDto.Response resp) {
		update contact;
        return contact;
    }
}