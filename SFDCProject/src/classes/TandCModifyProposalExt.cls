public class TandCModifyProposalExt {
    public String errorMessage{get;set;}
    public String errorType{get;set;}
    public Id returnId{get;set;}
    public String returnPage{get;set;}
    public String selectedDesign {get;set;} 
    public String src {get;set;}
    public String redirectURL{get;set;}
    public boolean showError{get;set;} 
    public boolean showWarning{get;set;}
    public boolean displayURL{get;set;}
    public boolean displayTandCURL{get;set;}
    public String baseURL {get;set;}
     
    public TandCModifyProposalExt(ApexPages.StandardController controller){

        errorMessage = ApexPages.currentPage().getParameters().get('errorMessage'); 
        errorType = ApexPages.currentPage().getParameters().get('errorType'); 
        returnPage = ApexPages.currentPage().getParameters().get('returnPage');
        returnId = ApexPages.currentPage().getParameters().get('returnId');
        selectedDesign = ApexPages.currentPage().getParameters().get('selectedDesign');
        src = ApexPages.currentPage().getParameters().get('src');

        baseURL = EDPUtil.getBaseURL();
        
        If(errorType.equalsIgnoreCase('Error')){
           showError = true; 
           ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage);
           ApexPages.addMessage(myMsg); 
        } else if(errorType.equalsIgnoreCase('Warning')){
           ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,errorMessage);
           ApexPages.addMessage(myMsg);             
           showWarning = true;  
        }
        
        System.debug(LoggingLevel.INFO,'errorMessage : '+errorMessage);
        System.debug(LoggingLevel.INFO,'errorType : '+errorType);
        System.debug(LoggingLevel.INFO,'returnId : '+returnId);
        System.debug(LoggingLevel.INFO,'returnPage : '+returnPage);    
        System.debug(LoggingLevel.INFO,'selectedDesign : '+selectedDesign);
        System.debug(LoggingLevel.INFO,'src : '+src);

    }
    
    public PageReference goBackToProposal() {
        system.debug(LoggingLevel.INFO,'In goBackToProposal');  
        PageReference pr;
        baseURL = EDPUtil.getBaseURL();
        
        if(returnPage.equalsIgnoreCase('Proposal')){
           if(userinfo.getUserType().equalsIgnoreCase('PowerPartner') && baseURL.containsIgnoreCase('partner')){
               pr = new PageReference('/partner'+'/'+returnId);
            } else{ 
               pr = new PageReference('/'+returnId);
            } 
        } 
        
        system.debug(LoggingLevel.INFO,'pr:'+pr);
        pr.setRedirect(true);
        return pr;
    }
    
    public void redirectToDesignTool() {
         system.debug(LoggingLevel.INFO,'In redirectToDesignTool');  
         system.debug(LoggingLevel.INFO,'selectedDesign :' +selectedDesign);  
         system.debug(LoggingLevel.INFO,'Proposal ID :' +returnId);  
        
         If(selectedDesign!='' && selectedDesign != null && src.equalsIgnoreCase('P')){
            DesignTool.function=selectedDesign;    
         }
         
         DesignToolWebservice.DesignToolWebserviceResponse responseObj = DesignTool.getModifyProposalURL(returnId);  
        
         redirectURL = responseObj.url;
         displayURL = true; 
        
         system.debug(LoggingLevel.INFO,'redirectURL :' +redirectURL);  
    }
}