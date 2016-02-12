public with sharing class CallCenterOptyPaymentController extends OptyPaymentController {
    public Boolean autoPaymentEmail {get;set;}
    public Boolean renderPanel {get;set;}
    public Opportunity opty {get;set;}
    public CallCenterOptyPaymentController(ApexPages.StandardController controller) {
        autoPaymentEmail = true;
        renderPanel = true;
        opty = Sf.paymentService.queryOptyForPaymentAndAllContactRoles(getParameter('id'));
        if (opty.Number_of_Proposals__c <1){
            addErrorMessage('Please generate a proposal before initiating a financial transaction.');
            autoPaymentEmail = false;
        }

        If((optyPaymentInfo.billingContact == null ) || (autoPaymentEmail == false)){
        renderPanel = false;
        system.debug(renderPanel);
        }
        
    }
    public PageReference returnToOpty() {
        return redirectToId();
    }
}