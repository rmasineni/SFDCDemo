public with sharing class OptyApiCreatePaymentUrlHandler extends OptyApiBaseHandler {
    override public String getApiName() {
        return 'OptyApiCreatePaymentUrl';
    }

    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        validateRequiredFields(new String[]{'paymentMode'}, req);
		String paymentMode = req.jsonReader.getString('paymentMode'); 		       

        Opportunity opty = queryOpty(req, resp);
        
        opty = Sf.paymentService.createPaymentUrl(opty.id, paymentMode);
        
		new OptyApiGetPaymentUrlHandler().addPaymentUrlToResponse(opty, req, resp);        
    }
}