public virtual with sharing class OptyApiGetPaymentUrlHandler extends OptyApiBaseHandler {
    override public String getApiName() {
        return 'OptyApiGetPaymentUrl';
    }

    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        Opportunity opty = queryOpty(req, resp);
        if (isEmpty(opty.Payment_Request_Url__c)) {
            throw new BusinessException(RestServiceDto.Error_NotFound, 'Payment URL not yet created');
        }
        
        addPaymentUrlToResponse(opty, req, resp);
    }
    
    public void addPaymentUrlToResponse(Opportunity opty, RestServiceDto.Request req, RestServiceDto.Response resp) {
        resp.jsonWriter.write('opportunityId', opty.id);
        resp.jsonWriter.write('prospectId', opty.Prospect_Id__c);
        resp.jsonWriter.write('url', opty.Payment_Request_Url__c);
        resp.jsonWriter.write('status', opty.Payment_Request_Token_Status__c);
    }
}