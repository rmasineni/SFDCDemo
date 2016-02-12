public with sharing class ContractApiGetContractHandler extends ContractApiBaseHandler {
	
    override public String getApiName() {
        return 'ContractApiGetContract';
    }
    
    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        String contractId = getRecordIdFromPath('contracts', req);
        ServiceContract contract = queryServiceContract(contractId, req, resp);

        addToResponse(contract, req, resp);
    }
}