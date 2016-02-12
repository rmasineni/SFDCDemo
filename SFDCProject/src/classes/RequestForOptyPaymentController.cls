public virtual with sharing class RequestForOptyPaymentController extends BaseClass {
    
    public Opportunity opty {get;set;}
    public Id contactRoleId {get;set;}
    public Boolean emailSent {get;set;}
    public Boolean autoPaymentEmail {get;set;}
    public Boolean optyrole {get;set;}
    public Boolean renderedPanel {get;set;}
    public Boolean proposalno {get;set;}
    
    public RequestForOptyPaymentController(ApexPages.StandardController controller) {
        autoPaymentEmail = false;
        renderedPanel = true;
        optyrole = true;
        
        opty = Sf.paymentService.queryOptyForPaymentAndAllContactRoles(getParameter('id'));
        
        if (opty.OpportunityContactRoles.isEmpty()) {
            addErrorMessage('There are no contact roles defined for the Opportunity. Please return to Opportunity, add Contact Roles and try again.');
            optyrole  = false;
        }
        if (opty.Number_of_Proposals__c < 1){
            addErrorMessage('Please generate a proposal before initiating a financial transaction.');
            proposalno = false;
        }
       
        If( optyrole == false || proposalno == false){
            renderedPanel = false;
            }   
    }

    public PageReference returnToOpty() {
        return redirectToId();
    }
    
    public PageReference sendRequestForPaymentEmail() {
        try {
            if (isEmpty(contactRoleId)) {
                 throw new BusinessException('Please select a Contact to send Payment Request email');
            }
            
            debug('Contact role id ' + contactRoleId );
            Contact contact = null;
            
            if (autoPaymentEmail) {
                contact = Sf.paymentWsService.sendRequestForAutoPaymentEmail(opty.id, contactRoleId );
            } else {
                contact = Sf.paymentWsService.sendPaymentRequestEmail(opty.id, contactRoleId );
            }
            
            addInfoMessage('Payment request email has been sent to ' + contact.Email);
            emailSent = true;
        } catch (Exception e) {
            addErrorMessage(e);
        }
        return null;
    }
}