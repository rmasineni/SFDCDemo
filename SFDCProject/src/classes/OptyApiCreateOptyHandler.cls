public class OptyApiCreateOptyHandler extends RestService implements RestRequestHandler {
    override public String getApiName() {
        return 'OptyApiCreateOpty';
    }

    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        
        parseRequest(req, resp);
        
        initRequest(req, resp);
        
        Opportunity opty = createRecord(req, resp);
        
        validateRecord(opty, req, resp);
        
        saveOpty(opty, req, resp);
        
        prepareResponse(opty, req, resp);
    }
    
    /**
     * Initializes the json reader with any defaults that need to be added before creating the lead.
     */ 
    public JsonReader initRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        debug('Comming to initRequest with request ' + req);
        
        JsonReader jsonReader = req.jsonReader;
        
        processDefaultsAndOverrides('OptyApiCreateOpty', jsonReader);
        
        debug('Req after pre-processing ' + jsonReader);
        
        resp.stopwatch.markSubElapsedTime();
        
        return jsonReader;
    }
    
    public Opportunity createRecord(RestServiceDto.Request req, RestServiceDto.Response resp) {
        
        Opportunity opty = new Opportunity();

        copyRestFieldsToSfdcFields(opty, OptyApiDto.getOptyApiOptyFieldMapping(), req);
        
        resp.stopwatch.markSubElapsedTime();
        return opty;
    }

    public void validateRecord(Opportunity opty, RestServiceDto.Request req, RestServiceDto.Response resp) {
		validateRequiredFields(opty, Sf.settingsService.getStringList('OptyApiNewLeadRequiredFields', new List<String>()), req);

        resp.stopwatch.markSubElapsedTime();
    }

    public void saveOpty(Opportunity opty, RestServiceDto.Request req, RestServiceDto.Response resp) {
        if (opty.id == null) {
            insert opty;
        } else {
            update opty;
        }
        
        resp.stopwatch.markSubElapsedTime();            
    }

    public void saveOptyAccount(Account account, RestServiceDto.Request req, RestServiceDto.Response resp) {
        if (account.id == null) {
            insert account;
        } else {
            update account;
        }
            
        resp.stopwatch.markSubElapsedTime();            
    }

	/**
	 * Prepare the lead responses to be returned to client. You can populate the required fields
	 */ 
    public void prepareResponse(Opportunity opty, RestServiceDto.Request req, RestServiceDto.Response resp) {
		
		opty = queryOpty(opty.id);
        
        debug('Preparing the response for ' + opty);
        
        resp.recordId = opty.id;
        
        signLead(opty, resp);
        
        resp.jsonWriter.write('opportunityId', opty.id);
        resp.jsonWriter.write('prospectId', opty.Prospect_Id__c);
        
        resp.stopwatch.markSubElapsedTime();
    }
}