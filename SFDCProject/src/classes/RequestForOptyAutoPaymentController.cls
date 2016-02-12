public with sharing class RequestForOptyAutoPaymentController extends RequestForOptyPaymentController{
    public Boolean optyrole {get;set;}
    public Boolean renderedPanel {get;set;}
    public Boolean proposalno {get;set;}
    
    public RequestForOptyAutoPaymentController (ApexPages.StandardController controller) {
        super(controller);
        autoPaymentEmail = true;
        proposalno = true;
        renderedPanel = true;
        optyrole = true;
        
        opty = Sf.paymentService.queryOptyForPaymentAndAllContactRoles(getParameter('id'));
        
        if (opty.OpportunityContactRoles.isEmpty()) {
            addErrorMessage('There are no contact roles defined for the Opportunity. Please return to Opportunity, add Contact Roles and try again.');
            optyrole  = false;
        }
        
        if (opty.Number_of_Proposals__c <1){
            addErrorMessage('Please generate a proposal before initiating a financial transaction.');
            proposalno = false;
        }
        
        if( optyrole == false||  proposalno == false){
            renderedPanel = false;
        }  
    }
}