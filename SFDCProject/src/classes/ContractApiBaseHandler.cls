public with sharing abstract class ContractApiBaseHandler extends RestService {
	
    public static Map<String, String> getContractFieldMapping() {
	   return RestServiceDto.getFieldMapping('Contract Api', 'ServiceContract');
    }

    public ServiceContract queryServiceContract(String contactNumber, RestServiceDto.Request req, RestServiceDto.Response resp) {
        String soql = createSoqlWithAuditFields(getContractFieldMapping().values(), 'ServiceContract', (List<String>) null);
       	
        List<ServiceContract> sobjs = Database.query(soql + ' where Agreement_Number__c  = :contactNumber');
        
        if (sobjs.isEmpty()) {
            sobjs = Database.query(soql + ' where Prospect_Id__c  = :contactNumber');
            
            if (sobjs.isEmpty()) {
	            throw createBusinessException(RestServiceDto.Error_NotFound, 'Service Contract with specified Contract Number or Prospect Id [' + contactNumber + '] not found');
            }
        }
        
        resp.stopWatch.markSubElapsedTime();
        
        return sobjs.get(0);
    }
    
	public void addToResponse(ServiceContract conract, RestServiceDto.Request req, RestServiceDto.Response resp) {
        
    	addToResponse(conract, getContractFieldMapping(), true, req, resp);

        resp.stopWatch.markSubElapsedTime();
    }
    
}