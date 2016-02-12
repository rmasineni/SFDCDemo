public with sharing class PartnerTermsConditionsExt {

    private final Contact partnerContact;
    private Id returnId{get;set;}
    private String returnPage{get;set;}
    public List<TermsConditions__c> PartnerTermsConditions;
    public boolean renderTermsConditions{get;set;}
    public String selectedDesign {get;set;} 
    public String prospectId {get;set;}
    public boolean displayURL{get;set;}
    public boolean displayTandCURL{get;set;}
    public boolean displayIntermediateURL{get;set;}
    public String redirectURL{get;set;}
    public String tandCType {get;set;}
    public String src {get;set;}
    public String baseURL {get;set;}
    
    public PartnerTermsConditionsExt(ApexPages.StandardController stdController) {
        System.debug(LoggingLevel.INFO,'Contact Id: '+stdController.getId());
        
        returnPage = ApexPages.currentPage().getParameters().get('returnPage');
        returnId = ApexPages.currentPage().getParameters().get('returnId');
        prospectId = ApexPages.currentPage().getParameters().get('prospectId');
        selectedDesign = ApexPages.currentPage().getParameters().get('selectedDesign');
        tandCType = ApexPages.currentPage().getParameters().get('tandCType');
        src = ApexPages.currentPage().getParameters().get('src');
        baseURL = EDPUtil.getBaseURL();

        System.debug(LoggingLevel.INFO,'prospectId : '+prospectId);
        System.debug(LoggingLevel.INFO,'selectedDesign : '+selectedDesign);
        System.debug(LoggingLevel.INFO,'returnId : '+returnId);
        System.debug(LoggingLevel.INFO,'returnPage : '+returnPage);
        System.debug(LoggingLevel.INFO,'tandCType : '+tandCType);
        System.debug(LoggingLevel.INFO,'src : '+src);

        this.partnerContact = [SELECT Id, T_C_Accepted__c, T_C_Accepted_Date__c FROM Contact WHERE Id =:stdController.getId()];      
        displayIntermediateURL = false; 
        displayTandCURL = false; 
        getPartnerTermsConditions();
    }

    public List<TermsConditions__c> getPartnerTermsConditions(){
        System.debug(LoggingLevel.INFO,'In getPartnerTermsandConditions()');
        renderTermsConditions = true; 
            try{
                 PartnerTermsConditions = [SELECT TermsConditionsInfo__c FROM TermsConditions__c WHERE TermsConditionsType__c = :tandCType AND Active__c = True ORDER BY SeqNo__c];
                 if (PartnerTermsConditions.isEmpty()) {
                     ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Terms and Conditions are not defined. Please contact System Admin');
                     ApexPages.addMessage(myMsg);
                     renderTermsConditions = false;
                 }
                } catch(Exception e) {
                  System.debug(LoggingLevel.INFO,'Exception'); 
                  ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
                  ApexPages.addMessage(myMsg);
            }
           return PartnerTermsConditions;
    }

    public void acceptTermsandConditions() {

        system.debug(LoggingLevel.INFO,'In acceptTermsandConditions');
        try {
             String objectType; 
             partnerContact.T_C_Accepted__c = True;
             partnerContact.T_C_Accepted_Date__c = DateTime.now().Date();

             update partnerContact;
          
             system.debug(LoggingLevel.INFO,'returnPage : '+returnPage);
             
             if (src.equalsIgnoreCase('P')){
                 if (returnPage.equalsIgnoreCase('Lead')) {
                    objectType = 'Lead';
                    redirectURL = redirectToDesignTool(selectedDesign, returnId, prospectId,objectType);
                    displayTandCURL = true; 
                 } else if(returnPage.equalsIgnoreCase('Opty')) {
                    objectType = 'Opportunity';
                    redirectURL = redirectToDesignTool(selectedDesign, returnId, prospectId,objectType);
                    displayTandCURL = true;
                 } else if(returnPage.equalsIgnoreCase('Proposal')){
                    redirectURL = redirectToDesignToolModifyProposal(selectedDesign, returnId);    
                    displayTandCURL = true; 
                 }
             }else if (src.equalsIgnoreCase('B')){   
                 if (returnPage.equalsIgnoreCase('Lead')) {
                    objectType = 'Lead'; 
                    displayIntermediateURL = true; 
                    if(userinfo.getUserType().equalsIgnoreCase('PowerPartner')){
                       redirectURL = '/partner/apex/RedirectLMFromTandC?returnId=' +returnId+ '&selectedDesign=' +selectedDesign+ '&prospectId=' +prospectId+ '&returnPage=' +objectType;
                    }else{
                       redirectURL = '/apex/RedirectLMFromTandC?returnId=' +returnId+ '&selectedDesign=' +selectedDesign+ '&prospectId=' +prospectId+ '&returnPage=' +objectType;
                    }
                 } else if(returnPage.equalsIgnoreCase('Opty')) {
                    objectType = 'Opportunity';
                    displayIntermediateURL = true; 
                    if(userinfo.getUserType().equalsIgnoreCase('PowerPartner')){
                       redirectURL = '/partner/apex/RedirectLMFromTandC?returnId=' +returnId+ '&selectedDesign=' +selectedDesign+ '&prospectId=' +prospectId+ '&returnPage=' +objectType;
                    }else{
                       redirectURL = '/apex/RedirectLMFromTandC?returnId=' +returnId+ '&selectedDesign=' +selectedDesign+ '&prospectId=' +prospectId+ '&returnPage=' +objectType;
                    }
                 } else if(returnPage.equalsIgnoreCase('Proposal')){
                    objectType = 'Proposal';  
                    displayIntermediateURL = true;  
                    if(userinfo.getUserType().equalsIgnoreCase('PowerPartner')){
                       redirectURL = '/partner/apex/RedirectLMFromTandC?returnId=' +returnId+ '&selectedDesign=' +selectedDesign+ '&returnPage=' +objectType;
                    }else{
                       redirectURL = '/apex/RedirectLMFromTandC?returnId=' +returnId+ '&selectedDesign=' +selectedDesign+ '&returnPage=' +objectType;
                    } 
                 }
             }
            system.debug(LoggingLevel.INFO,'redirectURL : '+redirectURL);
        } catch(Exception e) {
            System.debug(LoggingLevel.INFO,'Exception : '+e.getMessage()); 
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
       }
    }

    public void declineTermsandConditions() {
        system.debug(LoggingLevel.INFO,'In declineTermsandConditions');
        displayTandCURL = false; 
    }

    public String redirectToDesignTool(String selectedDesign,String objectId, String prospectId, String objectType) {

        system.debug(LoggingLevel.INFO,'In handleLeadDesign');

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
        baseURL = EDPUtil.getBaseURL();
        system.debug('baseURL: ' +baseURL); 
        
        DesignTool.function=selectedDesign;
        DesignToolWebservice.DesignToolWebserviceResponse responseObj = DesignTool.getModifyProposalURL(objectId);  


        if(responseObj.status == ProposalUtil.FAILURE){
           if(userinfo.getUserType().equalsIgnoreCase('PowerPartner') && baseURL.containsIgnoreCase('partner')){  
              redirectUrl = '/partner/apex/TandCModifyProposalError?returnId='+ objectId +'&src=P&returnPage=Proposal&errorType=Error&errorMessage='+responseObj.errorMessage +'&selectedDesign='+ selectedDesign;            
           }else{
               redirectUrl = '/apex/TandCModifyProposalError?returnId='+ objectId +'&src=P&returnPage=Proposal&errorType=Error&errorMessage='+responseObj.errorMessage +'&selectedDesign='+ selectedDesign;            
           }
        }else if(responseObj.status == 'Warning'){			
           if(userinfo.getUserType().equalsIgnoreCase('PowerPartner') && baseURL.containsIgnoreCase('partner')){   
              redirectUrl = '/partner/apex/TandCModifyProposalError?returnId='+ objectId +'&src=P&returnPage=Proposal&errorType=Warning&errorMessage='+ responseObj.errorMessage +'&selectedDesign='+ selectedDesign;
           }else{
              redirectUrl = '/apex/TandCModifyProposalError?returnId='+ objectId +'&src=P&returnPage=Proposal&errorType=Warning&errorMessage='+ responseObj.errorMessage +'&selectedDesign='+ selectedDesign;
           }    
        }

        if(responseObj.status!=null&&responseObj.status=='SUCCESS'){
           redirectUrl=responseObj.url;
        }  
        
        return redirectUrl;
    }   
    
}