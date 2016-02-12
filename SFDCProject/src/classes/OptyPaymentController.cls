public virtual with sharing class OptyPaymentController extends PaymentProcessorController {
    
    public Dto.OptyPaymentInfo optyPaymentInfo {get;set;}
    private static BaseClass utils = new BaseClass();

    public static Integer CUSTOM_PARAM_NUM = 4;
         
    public OptyPaymentController() {
        try {
            optyPaymentInfo = getOptyPaymentInfo();
            
            if (optyPaymentInfo.billingContact == null) {
                addErrorMessage('There is no Contact associated with opportunity with required ' 
                    + 'billing Contact Role (' + optyPaymentInfo.paymentContactRole + '). Please associate a Contact with specified role and try again.');
                return;
            }
            
            Dto.PaymentCustomParameters decodedCustomParams = new Dto.PaymentCustomParameters();
            decodedCustomParams.opportunityId = optyPaymentInfo.opty.id;
            decodedCustomParams.prospectId = optyPaymentInfo.opty.Prospect_Id__c;
            decodedCustomParams.contactId = optyPaymentInfo.billingContact.id;
            decodedCustomParams.contactNum = optyPaymentInfo.billingContact.Contact_Number__c;
            
            //We are using the secure custom parameter number 4, because it allows 2000 chars while rest of custom
            //parameters only allow 100 chars..
            customParams.put(CUSTOM_PARAM_NUM, Json.serialize(decodedCustomParams));
        } catch (Exception e) {
            addErrorMessage(e);
        }
    }
    
    public virtual override PageReference processPaymentResponse() {
        try {
            if (paymentResponse != null && isNotEmpty(paymentResponse.customParams.get(CUSTOM_PARAM_NUM))) {
                paymentResponse.decodedCustomParams = (Dto.PaymentCustomParameters) Json.deserialize(paymentResponse.customParams.get(CUSTOM_PARAM_NUM), Dto.PaymentCustomParameters.class);
            }
            
            super.processPaymentResponse();
        } catch (Exception e) {
            addErrorMessage(e);
        }
        return null;
    }
    
    public virtual Dto.OptyPaymentInfo getOptyPaymentInfo() {
        String optyId = getParameter('id');
        Dto.OptyPaymentInfo optyPaymentInfo = Sf.paymentWsService.getOptyPaymentInfo(optyId);
        if (optyPaymentInfo == null) {
            throw new BusinessException('Opportunity not found for specified id (' + optyId + ')!');
        }
        
        return optyPaymentInfo;
    }

    @RemoteAction
    public static Map<String, Object> associatePaymentContactWithOpty(Id optyId, String paymentMode, Dto.CustomContact contactInfo) {
        try {
            contactInfo = Sf.paymentService.associatePaymentContactWithOpty(optyId, paymentMode, contactInfo);
            
            System.debug('contactInfo=' + contactInfo);
            Dto.PaymentCustomParameters decodedCustomParams = new Dto.PaymentCustomParameters();
            decodedCustomParams.contactId = contactInfo.id;
            decodedCustomParams.contactNum = contactInfo.contactNumber;
            
            return Dto.successMapResponse(decodedCustomParams);
        } catch (Exception e) {
            return Dto.errorMapResponse(String.valueOf(e), utils.getStackTrace(e));
        }
    }

    public Integer getCustomParamNum() {
        return CUSTOM_PARAM_NUM;
    }
}