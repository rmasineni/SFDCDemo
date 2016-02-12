/**
 * This is the extended implementation of PaymentService but with 'sharing' model so that data can only be read
 * if current context user has access to it.
 */
public with sharing class PaymentServiceWsImpl extends PaymentServiceImpl {
   
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
    
    public override Contact sendPaymentRequestEmail(Id optyId, Id roleId) {
        return sendRequestForPaymentEmail(optyId, PaymentMode_OneTime, roleId);
    }

    public override Contact sendRequestForAutoPaymentEmail(Id optyId, Id roleId) {
        return sendRequestForPaymentEmail(optyId, PaymentMode_Recurring, roleId);
    }
    
    public Contact sendRequestForPaymentEmail(Id optyId, String paymentMode, Id optyContactRoleId) {
        Opportunity opty = queryOptyForPaymentAndAllContactRoles(optyId);
        if (opty == null) {
            throw new BusinessException('Opportunity not found with Id ' + optyId);
        }
        
        OpportunityContactRole optyRole = getOptyContactRoleById(opty, optyContactRoleId);
        if (optyRole == null) {
            throw new BusinessException('Selected contact is not associated with opportunity (' + opty.name + ')');
        }
        
        String salesPartnerName = getSalesPartnerName(opty.id);
        String paymentLanguageCode = getPaymentLanguageCode(opty.id);
        
        createPaymentUrl(opty, paymentMode, optyContactRoleId, salesPartnerName, paymentLanguageCode);
        
        update opty;
        
        sendEmail(getPaymentEmailTemplate(paymentMode, salesPartnerName, paymentLanguageCode), null, optyRole.Contact.Id, opty.id, true);
        return optyRole.Contact;
    }

}