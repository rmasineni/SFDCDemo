public virtual without sharing class CustomerOptyPaymentController extends OptyPaymentController {
  
    public Dto.Address billingAddress {get{
        billingAddress = new Dto.Address();
        billingAddress.street = optyPaymentInfo.billingContact.MailingStreet;
        billingAddress.city = optyPaymentInfo.billingContact.MailingCity;
        billingAddress.state = optyPaymentInfo.billingContact.MailingState;
        billingAddress.postalCode = optyPaymentInfo.billingContact.MailingPostalCode;
        return billingAddress;
    }set;}

    public Dto.CustomContact billingContact {get{
        billingContact = new Dto.CustomContact();
        billingContact.FirstName = optyPaymentInfo.billingContact.FirstName;
        billingContact.LastName = optyPaymentInfo.billingContact.LastName;
        billingContact.Email = optyPaymentInfo.billingContact.Email;
        billingContact.Phone = optyPaymentInfo.billingContact.Phone;
        return billingContact;
    }set;}
    
    public static BaseClass utils = new BaseClass();
    public Boolean validToken {get;set;}
    //adding error text for both english & spanish for display
    public static final string optyPaymentInfoNullError='We couldn\'t find details corresponding to this link. If you have received multiple emails, ' + 
               + 'please remember to click on the link from latest email. If you need assistance, please contact Sunrun Customer Care at 855.478.6786.' ;
    public static final string optyPaymentInfoNullError_Spanish='No pudimos encontrar detalles correspondientes a este enlace. Si usted ha recibido varios correos electrónicos,'+
        +'por favor recuerde acceder al enlace desde el mensaje más reciente. Si necesita asistencia, comuníquese con nuestro equipo de Atención al Cliente llamando al 855.478.6786.' ;   
    public static final string optyPaymentInfoConsume='Successful payment has already been made using this payment link and it cannot be used again. ' +  
               + 'If you need assistance, please contact Sunrun Customer Care at 855.478.6786.' ;
      public static final string optyPaymentInfoConsume_Spanish='Este enlace ha sido utilizado anteriormente para finalizar un pago y no se podrá utilizar de nuevo.' + 
     +'Si necesita asistencia, comuníquese con nuestro equipo de Atención al Cliente llamando al 855.478.6786.';
    public static final string optyPaymentInfoToken1='Invalid payment token, or token expired or token has been used';
    public static final string optyPaymentInfoToken2='.If you need assistance, please contact Sunrun Customer Care at 855.478.6786.' ;
    public static final string optyPaymentInfoToken1_Spanish='La ficha de pago es inválida, ha expirado o ha sido utilizada anteriormente'; 
    public static final string optyPaymentInfoToken2_Spanish='Si necesita asistencia, comuníquese con nuestro equipo de Atención al Cliente llamando al 855.478.6786.';
    
    public Static string LangParam = 'en';
    //Adding language get/set method to determine the VF page status
      public String languageCode {get{
        if(languageCode==null || languageCode==''|| languageCode=='en')
        {
            languageCode='en-us';
        }
       return languageCode;
    } set ;}
                                
    
    
    public CustomerOptyPaymentController() {
        try {
            if (optyPaymentInfo != null &&  optyPaymentInfo.opty != null && equalsIc(optyPaymentInfo.opty.Payment_Request_Token_Status__c, 'Valid')) {
                validToken = true;
            } else {
                validToken = false;
            }
                 
        } catch (Exception e) {
            addErrorMessage(e);
        }
    }
    
    public override Dto.OptyPaymentInfo getOptyPaymentInfo() {
        languageCode = getRequiredParameter('language');
        LangParam = languageCode;
        Dto.OptyPaymentInfo info = getOptyPaymentInfoForToken(getRequiredParameter('token'));
        debug('Returning the opty infor for token ' + info);
        return info;
    }

    public override PageReference processPaymentResponse() {
        try {
            if (validToken) {
                super.processPaymentResponse();
                
                debug('paymentResponse=' + paymentResponse);
                //If payment response was successful, we need to invalidate the token.
                if (paymentResponse != null && equalsIc(paymentResponse.header.status, 'success')) {
                    Sf.paymentService.markOptyPaymentTokenConsumed(getParameter('token'));
                }
            }
        } catch (Exception e) {
            addErrorMessage(e);
        }
        return null;
    }
    
    public static Dto.OptyPaymentInfo getOptyPaymentInfoForToken(String token) {
        Dto.OptyPaymentInfo optyPaymentInfo = null;
              
        if (utils.isNotEmpty(token)) {
            optyPaymentInfo = Sf.paymentService.getOptyPaymentInfoForToken(token);
        }
       
        if (optyPaymentInfo == null) {
            if(LangParam=='es') {
               throw new BusinessException(optyPaymentInfoNullError_Spanish);
             }
            else{
                 throw new BusinessException(optyPaymentInfoNullError);
            }
                
        }

        if (utils.equalsIc(optyPaymentInfo.opty.Payment_Request_Token_Status__c, 'Consumed')) {
            if(LangParam=='es') {
               throw new BusinessException(optyPaymentInfoConsume_Spanish);
             }
            else{
                 throw new BusinessException(optyPaymentInfoConsume);
            }
                     
        }
        
        if (!utils.equalsIc(optyPaymentInfo.opty.Payment_Request_Token_Status__c, 'Valid')) {
        
             if(LangParam=='es') {
               throw new BusinessException(optyPaymentInfoToken1_Spanish +'('+token+')' + optyPaymentInfo.opty.Payment_Request_Token_Status__c + optyPaymentInfoToken2_Spanish );
             }
            else{
                throw new BusinessException(optyPaymentInfoToken1 +'('+token+')' + optyPaymentInfo.opty.Payment_Request_Token_Status__c + optyPaymentInfoToken2);
            }
             
        }
        
        utils.debug('optyPaymentInfo=' + optyPaymentInfo);
        return optyPaymentInfo;
    }
    
    @RemoteAction
    public static Map<String, Object> associatePaymentContactWithOptyForToken(String token, String paymentMode, Dto.CustomContact contactInfo) {
        Dto.OptyPaymentInfo optyInfo = getOptyPaymentInfoForToken(token);
        return OptyPaymentController.associatePaymentContactWithOpty(optyInfo.opty.id, paymentMode, contactInfo);
    }
    
    /**
     * Because this page is accessed in guest mode which doesn't have access to opty object, we need to
     * return the value using a get method.
     */ 
    public String getOptyName() {
        if (optyPaymentInfo == null) {
            return null;
        }
        return optyPaymentInfo.opty.Name;
    }
    
    /**
     * Because this page is accessed in guest mode which doesn't have access to opty object, we need to
     * return the value using a get method.
     */ 
    public String getOptyId() {
        if (optyPaymentInfo == null) {
            return null;
        }
        return optyPaymentInfo.opty.id;
    }

    /**
     * Because this page is accessed in guest mode which doesn't have access to opty object, we need to
     * return the value using a get method.
     */ 
    public String getOptyProspectId() {
        if (optyPaymentInfo == null) {
            return null;
        }
        return optyPaymentInfo.opty.Prospect_Id__c;
    }
}