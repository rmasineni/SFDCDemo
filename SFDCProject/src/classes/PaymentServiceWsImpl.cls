/**
 * This is the extended implementation of PaymentService but with 'sharing' model so that data can only be read
 * if current context user has access to it.
 */
public with sharing class PaymentServiceWsImpl extends PaymentServiceImpl {
   
    //Declaring variables for determine the preferred language
    String preferredLanguageParam='en';
    String preferredLanguage='English';
    public static string SPANISHLANGUAGE='Spanish';
    
    public override Dto.OptyPaymentInfo getOptyPaymentInfo(Id optyId) {
        Dto.OptyPaymentInfo info = new Dto.OptyPaymentInfo();
        info.paymentContactRole = Sf.settingsService.getString(Constants.PaymentOptyContactRole);
        Opportunity opty = queryOptyForPaymentAndAllContactRoles(optyId);
        if (opty == null) {
            return null;
        }
    
        info.opty = opty;
    
        OpportunityContactRole role = getOptyContactRoleByRole(info.opty, info.paymentContactRole);
            if (role != null) {
                info.billingContact = role.Contact;
            }
              
        return info;
    }
    
    public String getSalesPartnerName(Id optyId) {
        Opportunity opty = [select id, (select Partner_Name__r.Name from Partner_Roles__r where Role__c = 'Sales') from Opportunity where id = :optyId limit 1];
        if (!opty.Partner_Roles__r.isEmpty()) {
            return opty.Partner_Roles__r.get(0).Partner_Name__r.Name;
        }
        
        return null;
    }
    
    //need more information to get the preferred language 
    
    public String getPreferredLanguage(Id optyId, Id roleId){
    
        OpportunityContactRole con  = [Select  ContactId,  contact.preferred_language__c from OpportunityContactRole where OpportunityId =: optyId and IsPrimary = true limit 1 ];
        if(con.Contact.preferred_language__c!=null && con.Contact.preferred_language__c!=''){
            
            preferredLanguage=con.Contact.preferred_language__c;
        }
        return preferredLanguage;
    }
    
    
    public override Contact sendPaymentRequestEmail(Id optyId, Id roleId) {
        Map<String, String> pageMap = Sf.settingsService.getStringMap('PaymentBrandingOptyPaymentPage', new Map<String, String>());
        String salesPartnerName = getSalesPartnerName(optyId);
        String vfPage = pageMap.get(salesPartnerName);
        if (vfPage == null) {
            vfPage = 'CustomerOptyPayment';
        }
         preferredLanguage= getPreferredLanguage(optyId,roleId);
        
         Map<String, String> emalTemplateMap = Sf.settingsService.getStringMap('PaymentBrandingOptyPaymentEmail', new Map<String, String>());
         String emailTemplate = emalTemplateMap.get(salesPartnerName);
         //Adding Template based on language
        if (emailTemplate == null) {
            emailTemplate =preferredLanguage==SPANISHLANGUAGE?'Request_for_Payment_Email_Default_SPANISH':'Request_for_Payment_Email_Default';
          
        }
        
        return sendRequestForPaymentEmail(optyId, roleId, vfPage, emailTemplate);
    }

    public override Contact sendRequestForAutoPaymentEmail(Id optyId, Id roleId) {
        Map<String, String> pageMap = Sf.settingsService.getStringMap('PaymentBrandingOptyAutoPaymentPage', new Map<String, String>());
        String salesPartnerName = getSalesPartnerName(optyId);
        String vfPage = pageMap.get(salesPartnerName);
        if (vfPage == null) {
            vfPage = 'CustomerOptyAutoPayment';
        }
       preferredLanguage= getPreferredLanguage(optyId,roleId);
       Map<String, String> emalTemplateMap = Sf.settingsService.getStringMap('PaymentBrandingOptyAutoPaymentEmail', new Map<String, String>());
       String emailTemplate = emalTemplateMap.get(salesPartnerName);
        //Adding Template based on language
       if (emailTemplate == null) {
            emailTemplate =preferredLanguage==SPANISHLANGUAGE?'Request_For_Auto_Payment_SPANISH':'Request_For_Auto_Payment';
             
         }

        return sendRequestForPaymentEmail(optyId, roleId, vfPage, emailTemplate);
    }
    
    public Contact sendRequestForPaymentEmail(Id optyId, Id roleId, String vfPage, String emailTemplate) {
        Opportunity opty = queryOptyForPaymentAndAllContactRoles(optyId);
        if (opty == null) {
            throw new BusinessException('Opportunity not found with Id ' + optyId);
        }
        
        OpportunityContactRole optyRole = getOptyContactRoleById(opty, roleId);
        if (optyRole == null) {
            throw new BusinessException('Selected contact is not associated with opportunity (' + opty.name + ')');
        }
        
        //Adding the logic to find the Preferred Language of primary contact
         preferredLanguage= getPreferredLanguage(optyId,roleId);
          system.debug('preferredLanguage118' + preferredLanguage ); 
        //Adding param based on language
         preferredLanguageParam = preferredLanguage==SPANISHLANGUAGE?'es':'en';
        //The payment request url would look like below
        //https://majdev-sunrun.cs9.force.com/partner/apex/{VfPage}?token={Token}&&language={preferredLanguageParam}
        String paymentRequestUrl = Sf.settingsService.getString('PaymentRequestUrl');
        String token = generateVerificationToken();
        Map<String, String> parms = new Map<String, String>();
        parms.put('VfPage', vfPage);
        parms.put('Token', token);
        //Adding language param to payment url
        parms.put('Language',preferredLanguageParam);
        paymentRequestUrl = replaceMergeTokens(paymentRequestUrl, parms);
        
        system.debug('paymentRequestUrl' + paymentRequestUrl );
        opty.Payment_Request_Url__c = paymentRequestUrl;
        opty.Payment_Request_Token__c = token;
        opty.Payment_Request_Token_Status__c = 'Valid';
        opty.Payment_Request_Contact_Role_Id__c =  roleId;
        
        update opty;
        
        sendEmail(emailTemplate, null, optyRole.Contact.Id, opty.id, true);
        return optyRole.Contact;
    }

}