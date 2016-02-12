public with sharing class SalesRepRedirectExt {
    public static string redirectUrl{set;get;}
    public static string returnUrl{set;get;}    
    public string message{set;get;}
    public ID Id{set;get;}
 //   public ID returnId{set;get;}
 //   public string returnPage{set;get;}
 //   public string selectedDesign{set;get;}
 //   public string prospectId{set;get;}
 //   public string redirectLMUrl{set;get;}
    public boolean displayTandCURL{set;get;}
    public boolean displayURL{set;get;}
    // Variables for Partner Terms and Conditions
    public List<TermsConditions__c> PartnerTermsConditions;
    Id OppId = null;
    
    public SalesRepRedirectExt(ApexPages.StandardController controller) {
        /*
        redirectUrl=System.currentPagereference().getParameters().get('redirectUrl');
        redirectUrl+='&expires='+System.currentPagereference().getParameters().get('expires');
        redirectUrl+='&userId='+System.currentPagereference().getParameters().get('userId');
        String function=System.currentPagereference().getParameters().get('function');
        if(function!=null)
        redirectUrl+='&function='+function;
        String authorities=System.currentPagereference().getParameters().get('authorities');
        if(authorities!=null)
        redirectUrl+='&authorities='+authorities;
        redirectUrl+='&signature='+System.currentPagereference().getParameters().get('signature');
        redirectUrl+='&returnUrl='+System.currentPagereference().getParameters().get('returnUrl');
        returnUrl=System.currentPagereference().getParameters().get('returnUrl');
        */
        OppId = System.currentPagereference().getParameters().get('Id');
        Id = System.currentPagereference().getParameters().get('partnerContactId');
        /*
        returnId = System.currentPagereference().getParameters().get('Id');
        selectedDesign = System.currentPagereference().getParameters().get('selectedDesign');
        prospectId = System.currentPagereference().getParameters().get('prospectId');
        returnPage = System.currentPagereference().getParameters().get('returnPage');
        */
        message=System.currentPagereference().getParameters().get('message');
        if(message=='Sales Rep Message'){
            message='You won\'t be able to generate proposal as Sales Rep is not identified.Click on OK to continue or Cancel to select a Sales Rep';
        }
        else if(message=='Sales Rep Division Message'){
            message='You won\'t be able to generate proposal as Sales Rep Division is not identified.Click on OK to continue or Cancel to select a Sales Rep Division';
        }
        else if(message=='County Message'){
            message='You won\'t be able to generate proposal as County is not identified.Click on OK to continue or Cancel to select a County';
        }
        //BSKY-7265
        else if(message=='Design Only Message'){
            message='You won\'t be able to generate proposal because information is missing on the Opportunity. Click on OK to continue or Cancel to enter all required information';
        }
        system.debug('return url:'+redirectUrl);
    }
    public void redirectToDesign(){
       
          if(System.currentPagereference().getParameters().get('partnerTandCAccepted') == 'true') {
            System.debug(LoggingLevel.INFO,'In redirectToDesign()');
            redirectToDesignNewProposal();
            /*  
            redirectUrl=System.currentPagereference().getParameters().get('redirectUrl');
            redirectUrl+='&expires='+System.currentPagereference().getParameters().get('expires');
            redirectUrl+='&userId='+System.currentPagereference().getParameters().get('userId');
            String function=System.currentPagereference().getParameters().get('function');
            if(function!=null)
            redirectUrl+='&function='+function;
            String authorities=System.currentPagereference().getParameters().get('authorities');
            if(authorities!=null)
            redirectUrl+='&authorities='+authorities;
            redirectUrl+='&signature='+System.currentPagereference().getParameters().get('signature');
            redirectUrl+='&returnUrl='+System.currentPagereference().getParameters().get('returnUrl');
            returnUrl=System.currentPagereference().getParameters().get('returnUrl');
            PageReference pr = new PageReference(redirectUrl);  
            pr.setRedirect(true);
            return pr;   
            */
        }else{ 
            displayTandCURL = true; 
        }
        if(OppId!= null)
        {
            Opportunity opptyObj = new Opportunity(id=OppId,Site_Designer__c=UserInfo.getUserId());
            update opptyObj;    
        } 
    }
    
    public pagereference returnBack(){      
        returnUrl=System.currentPagereference().getParameters().get('returnUrl');
        PageReference pr = new PageReference(returnUrl);    
        pr.setRedirect(true);
        return pr; 
    }
    
    public void redirectToDesignNewProposal(){
            redirectUrl=System.currentPagereference().getParameters().get('redirectUrl');
            redirectUrl+='&expires='+System.currentPagereference().getParameters().get('expires');
            redirectUrl+='&userId='+System.currentPagereference().getParameters().get('userId');
            String function=System.currentPagereference().getParameters().get('function');
            if(function!=null)
            redirectUrl+='&function='+function;
            String authorities=System.currentPagereference().getParameters().get('authorities');
            if(authorities!=null)
            redirectUrl+='&authorities='+authorities;
            //BSKY-7266
                        
            String DesignOnly=System.currentPagereference().getParameters().get('DesignOnly');
            if(DesignOnly!=null)
            redirectUrl+='&DesignOnly';

            redirectUrl+='&signature='+System.currentPagereference().getParameters().get('signature');
            redirectUrl+='&returnUrl='+System.currentPagereference().getParameters().get('returnUrl');
            returnUrl=System.currentPagereference().getParameters().get('returnUrl');
            displayURL = true; 
    }
    
    // Methods related to Partner Terms and Conditions
    public List<TermsConditions__c> getPartnerTermsConditions(){
        System.debug(LoggingLevel.INFO,'In getPartnerTermsandConditions()');

        PartnerTermsConditions = TermsConditionsUtil.fetchPartnerTermsConditions('PARTNER');
        return PartnerTermsConditions;         
    }

    public void acceptTermsandConditions() {

        system.debug(LoggingLevel.INFO,'In acceptTermsandConditions');
        
        TermsConditionsUtil.updateTermsandConditions(Id);
        displayTandCURL = false;
        redirectToDesignNewProposal();

    }
    
    public void declineTermsandConditions() {
        system.debug(LoggingLevel.INFO,'In declineTermsandConditions');        
        displayTandCURL = false;
    }
    
}