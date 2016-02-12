public virtual with sharing class PaymentProcessorController extends BaseClass {
	//As all methods in BaseClass are instance method, to be able to refer from a 
	//static method here, we need an instance. This is that instance.
	public static BaseClass utils = new BaseClass();
	    
	public Map<Integer, String> customParams {get{
		if (customParams == null) {
			customParams = new Map<Integer, String>();
		}
		return customParams;
	}set;}
    public String errorDetails {get;set;}
    public Dto.PaymentResponse paymentResponse {get;set;}
    public Payment_Transaction__c savedPaymentTransaction {get;set;}
    
    public PaymentProcessorController() {
    	try {
	    	//Check if there is response posted to this page. If yes, extract all cybersource
	    	//parameters and validate the parameters.
	    	Map<String, String> params = ApexPages.currentPage().getParameters();
	    	if (utils.isNotEmpty(params.get('signature'))) {
	    		paymentResponse = Sf.paymentService.validatePaymentResponse(params);
	    	}
    	} catch (Exception e) {
    		addErrorMessage(e);
    	}
    }
	
	
	public String getCustomParamsJson() {
		return Json.serialize(customParams);
	}
	
	public String getCurrentPageUrl() {
		return URL.getCurrentRequestUrl().toExternalForm();
	}
	
    public virtual PageReference processPaymentResponse() {
    	try {
	    	if (paymentResponse != null) {
	    		savedPaymentTransaction = Sf.paymentService.savePaymentResponse(paymentResponse);
	    	}
    	} catch (Exception e) {
    		addErrorMessage(e);
    	}
    	return null;
    }
    
    public String getPaymentResponseJson() {
    	return paymentResponse == null?'{}':Json.serializePretty(paymentResponse);
    }
	
    @RemoteAction
    public static Map<String, Object> preparePaymentRequest(Dto.PaymentRequest paymentRequest) {
        try {
        	return Dto.successMapResponse(Sf.paymentService.preparePaymentRequest(paymentRequest));
        } catch (Exception e) {
        	return Dto.errorMapResponse(String.valueOf(e), utils.getStackTrace(e));
        }
    }

}