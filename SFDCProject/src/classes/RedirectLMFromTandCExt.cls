public class RedirectLMFromTandCExt {

    private Id returnId{get;set;}
    public String returnPage{get;set;}
    public String selectedDesign {get;set;} 
    public String prospectId {get;set;}
    public String redirectURL{get;set;}
    public String baseURL {get;set;}
        
    public RedirectLMFromTandCExt(ApexPages.StandardController stdController) {
        System.debug(LoggingLevel.INFO,'In RedirectLMFromTandC');
    }
    
    public PageReference Init()
	{ 	
        returnPage = ApexPages.currentPage().getParameters().get('returnPage');
        returnId = ApexPages.currentPage().getParameters().get('returnId');
        prospectId = ApexPages.currentPage().getParameters().get('prospectId');
        selectedDesign = ApexPages.currentPage().getParameters().get('selectedDesign');
        baseURL = EDPUtil.getBaseURL();
        
        System.debug(LoggingLevel.INFO,'prospectId : '+prospectId);
        System.debug(LoggingLevel.INFO,'selectedDesign : '+selectedDesign);
        System.debug(LoggingLevel.INFO,'returnId : '+returnId);
        System.debug(LoggingLevel.INFO,'returnPage : '+returnPage);
        
        if (returnPage.equalsIgnoreCase('Lead') || returnPage.equalsIgnoreCase('Opportunity')) {
            redirectURL = redirectToDesignProposal(selectedDesign, returnId, prospectId,returnPage);
        } else if (returnPage.equalsIgnoreCase('Proposal')) {
            redirectURL = redirectToDesignToolModifyProposal(selectedDesign, returnId);   
        }           
           
        System.debug(LoggingLevel.INFO,'redirectURL : '+redirectURL);
       	PageReference pr = new PageReference(redirectURL);
       	return pr.setRedirect(true);
	}
    
    public String redirectToDesignProposal(String selectedDesign,String objectId, String prospectId, String objectType) {

        system.debug(LoggingLevel.INFO,'In redirectToDesignNewProposal');

        String responseURL = null;
        
        String tempSelectedDesign = selectedDesign.trim();
        tempSelectedDesign = tempSelectedDesign.replaceAll('(\\s+)', '');
        
        if(tempSelectedDesign != '--None--') {
            DesignTool.function = tempSelectedDesign;
        }
        
        DesignToolWebservice.DesignToolWebserviceResponse responseObj = DesignTool.getDesignToolURL(objectId, prospectId, objectType);
        System.debug(LoggingLevel.INFO,'responseObj.url : '+responseObj.url);

        responseURL = responseObj.url;
        return responseURL;
    }  
    
    public String redirectToDesignToolModifyProposal(String selectedDesign, Id objectId) {
        system.debug(LoggingLevel.INFO,'In Modify Proposal');
        
        String responseURL = null;
        baseURL = EDPUtil.getBaseURL();
        
        //DesignTool.function=selectedDesign;
        DesignToolWebservice.DesignToolWebserviceResponse responseObj = DesignTool.getModifyProposalURL(objectId);  
 
        if(responseObj.status == ProposalUtil.FAILURE){
           if(userinfo.getUserType().equalsIgnoreCase('PowerPartner') && baseURL.containsIgnoreCase('partner')){ 
              responseURL = '/partner/apex/TandCModifyProposalError?returnId='+ objectId +'&src=B&returnPage=Proposal&errorType=Error&errorMessage='+responseObj.errorMessage +'&selectedDesign='+ selectedDesign;            
           }else{
              responseURL = '/apex/TandCModifyProposalError?returnId='+ objectId +'&src=B&returnPage=Proposal&errorType=Error&errorMessage='+responseObj.errorMessage +'&selectedDesign='+ selectedDesign;             
           }               
        }else if(responseObj.status == 'Warning'){		
           if(userinfo.getUserType().equalsIgnoreCase('PowerPartner') && baseURL.containsIgnoreCase('partner')){  
              responseURL = '/partner/apex/TandCModifyProposalError?returnId='+ objectId +'&src=B&returnPage=Proposal&errorType=Warning&errorMessage='+ responseObj.errorMessage +'&selectedDesign='+ selectedDesign;
           }else{
              responseURL = '/apex/TandCModifyProposalError?returnId='+ objectId +'&src=B&returnPage=Proposal&errorType=Warning&errorMessage='+ responseObj.errorMessage +'&selectedDesign='+ selectedDesign; 
           }
        }

        system.debug(LoggingLevel.INFO,'responseObj.status :' +responseObj.status);
        if(responseObj.status!=null&&responseObj.status=='SUCCESS'){
           responseURL=responseObj.url;
        }  
        return responseURL;
    }       
}