global with sharing class LeadApiUpdateLeadHandler extends RestService implements RestRequestHandler {
    override public String getApiName() {
        return 'LeadApiUpdateLead';
    }

    /**
     * Method implements the patch protocol for lead. For patch, it will process only the fields
     * which are explicitly requested in the request.
     */ 
    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        
        String prospectId = getPathId(req.restReq);
        if (isOpportunity(prospectId)) {
            new OptyApiUpdateOptyHandler().handleRequest(req, resp);
            return;
        }
        
        LeadApiCreateLeadHandler createHandler = new LeadApiCreateLeadHandler();
		LeadApiReadLeadHandler readHandler = new LeadApiReadLeadHandler();
    
        createHandler.parseRequest(req, resp);
		
        initRequest(req, resp);
        
        Lead lead = readHandler.queryLead(getPathId(req.restReq), req, resp);
        
        applyPatch(lead, createHandler, req, resp);

        saveRecord(lead, createHandler, req, resp);
        
        createHandler.convertLeadIfApplicable(lead, req, resp);
		
		//We will need to send updated lead so we will delegate to read.		        
        readHandler.handleRequest(req, resp);
    }

    public JsonReader initRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        try {
            debug('Comming to initRequest with request ' + req);
            
            processDefaultsAndOverrides(getApiName(), req.jsonReader);
            
            debug('Request after pre-processing ' + req.jsonReader);
            
            resp.stopwatch.markSubElapsedTime();
            
            return req.jsonReader;

        } catch (Exception e) {
            throw createBusinessException(RestServiceDto.Error_InternalServerError, 'Exception while processing the request. [' + e.getMessage() + ']', e);
        }
    }
    
    public void applyPatch(Lead lead, LeadApiCreateLeadHandler createHandler, RestServiceDto.Request req, RestServiceDto.Response resp) {
    	
		applyPatch(lead, LeadApiDto.getLeadApiLeadFieldMapping(), req);
        
        //Some of the fields cannot be just mapped but they need to be exclusively processed.
        if (req.jsonReader.containsKey(LeadApiDto.RestField_consultationDateTime)) {
        	createHandler.parseConsultationTime(lead, req.jsonReader);
        }
        
        resp.stopWatch.markSubElapsedTime();
    }

    public Lead saveRecord(Lead lead, LeadApiCreateLeadHandler createHandler, RestServiceDto.Request req, RestServiceDto.Response resp) {
    	createHandler.saveLead(lead, req, resp);
        return lead;
    }
}