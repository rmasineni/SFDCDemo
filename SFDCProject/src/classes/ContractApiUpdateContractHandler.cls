public with sharing class ContractApiUpdateContractHandler extends ContractApiBaseHandler {
	
    override public String getApiName() {
        return 'ContractApiUpdateContract';
    }
    
    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        String contractId = getRecordIdFromPath('contracts', req);

        initRequest(req, resp);

        ServiceContract contract = queryServiceContract(contractId, req, resp);
        
        applyPatch(contract, getContractFieldMapping(), req);

		saveRecord(contract, req, resp);
        
        addToResponse(contract, req, resp);
    }
    
    public JsonReader initRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        debug('Comming to initRequest with request ' + req);
        
        processDefaultsAndOverrides(getApiName(), req.jsonReader);
        
        debug('Request after pre-processing ' + req.jsonReader);
        
        resp.stopwatch.markSubElapsedTime();
        
        return req.jsonReader;
    }
    
    public ServiceContract saveRecord(ServiceContract contract, RestServiceDto.Request req, RestServiceDto.Response resp) {
		update contract;
        return contract;
    }
}