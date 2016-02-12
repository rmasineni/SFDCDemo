public with sharing class OptyApiGetOptyPaymentsHandler extends OptyApiBaseHandler {
    override public String getApiName() {
        return 'OptyApiGetOptyPayments';
    }

    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        Opportunity opty = queryOpty(req, resp);
        List<Payment_Transaction__c> txs= queryOptyPayments(opty.id, resp);
        
		prepareResponse(txs, req, resp);
    }
    
    public List<Payment_Transaction__c> queryOptyPayments(Id optyId, RestServiceDto.Response resp) {
        String soql = createSoqlWithAuditFields(OptyApiDto.getOptyApiPaymentFieldMapping().values(), 'Payment_Transaction__c', 'Opportunity__c = :optyId and Status__c = \'accept\'');
        soql += ' order by lastmodifieddate desc';
        
       	List<Payment_Transaction__c> paymentTxs = Database.query(soql);
        
        resp.stopWatch.markSubElapsedTime();
        
        return paymentTxs;
    }
    
	public void prepareResponse(List<Payment_Transaction__c> payments, RestServiceDto.Request req, RestServiceDto.Response resp) {
        JsonWriter jsonWriter = resp.jsonWriter;
        if (payments.isEmpty()) {
            //This writes a default array
            resp.jsonWriter = new JsonWriter(true);
        } else {
            for (Integer i = 0; i < payments.size(); i++) {
                jsonWriter.newWith(i);
                addToResponse(payments.get(i), req, resp);
            }
        }

        resp.stopWatch.markSubElapsedTime();
    }
    
    public void addToResponse(Payment_Transaction__c payment, RestServiceDto.Request req, RestServiceDto.Response resp) {
 		Map<String, String> fieldMapping = OptyApiDto.getOptyApiPaymentFieldMapping();
        
        for (String restField : fieldMapping.keySet()) {
	    	resp.jsonWriter.writeIfNotNull(restField, payment.get(fieldMapping.get(restField)));
        }
    }
}