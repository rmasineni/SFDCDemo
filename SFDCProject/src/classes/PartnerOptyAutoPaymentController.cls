public with sharing class PartnerOptyAutoPaymentController extends OptyPaymentController {
    public Boolean autoPaymentEmail {get;set;}
    public Boolean renderPanel {get;set;}
    public Opportunity opty {get;set;}
    public PartnerOptyAutoPaymentController(){
        autoPaymentEmail = true;
        renderPanel = true;
        opty = Sf.paymentService.queryOptyForPaymentAndAllContactRoles(getParameter('id'));
        if (opty.Number_of_Proposals__c <1){
            addErrorMessage('Please generate a proposal before initiating a financial transaction.');
            autoPaymentEmail = false;
        }
        
        If((optyPaymentInfo.billingContact == null ) || (autoPaymentEmail == false)){
            renderPanel = false;
        }
    }
    public PageReference returnToOpty() {
        return redirectToId();
    }
}