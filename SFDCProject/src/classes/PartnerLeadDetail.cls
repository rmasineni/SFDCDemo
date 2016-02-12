public with sharing class PartnerLeadDetail {
    
    public Lead leadObj;
    public Id leadId;
    public List<Notes__c> noteObj;
    public string prospectId;
    public boolean showViewProj {get;set;}
    public boolean showGetDirections {get;set;}
    public List<Design_Option__c> desOptionObj;
    public String errorMessage{get;set;}
    public Lead leadRec;
    public String baseURL {get;set;}
    public boolean BBEligible{get;set;}
    public boolean isLGCYUser{get;set;}
    public boolean displayPopup{get;set;}
    public boolean displayURL{get;set;}
    public boolean displayTandCURL{get;set;}
    public String displayPopupMessage{get;set;}
    public String selectedDesign {get;set;}//Santosh Changes
    public String redirectURL{get;set;}
    public boolean displaySalesRepURL{get;set;} 
    public String SalesRepURL{get;set;}      
    public boolean partnerTandCAccepted{get;set;}
    public Id partnerContactId{get;set;}    
    public String returnPageVal;    
    public User CurrentUser;
    public Boolean isAEEUser;
    public boolean isSunrunDivision{get;set;}
    // Variables for Partner Terms and Conditions
    public List<TermsConditions__c> PartnerTermsConditions;

    public PartnerLeadDetail(ApexPages.StandardController stdController){
        system.debug('PartnerLeadDetail Constructor');
        baseURL = EDPUtil.getBaseURL(); 
        this.leadObj = (Lead)stdController.getRecord(); 
        leadId = String.ValueOf(this.leadObj.Id);
        showViewProj = true;
        showGetDirections = true;
        isLGCYUser=false;
        isAEEUser=false;
        leadRec = [select id,name,email,FirstName,lastName,Street,City,State,State__c,PostalCode,country,Phone,Lead_Organization_Location_2__c,
                            Utility_Company__c,Average_Monthly_Electric_Bill__c,Status,LeadSource,Which_SR_product__c,Alternate_Phone__c,Partner_Notes__c,
                            dt_Product_Type__c,dt_Upfront_Payment__c,dt_Escalator__c,dt_Turnkey_Price__c,dt_Gross_margin__c,Prospect_Id__c,
                            Sales_partner__c,Install_partner__c,market_assignment_sales__c,market_assignment_install__c,CDYNE_Status__c, CDYNE_Result__c,CDYNE_Address__c,Zip_6__c,CongressDistrictNumber__c,StateLegislativeUpper__c,StateLegislativeLower__c,FromLongitude__c,FromLatitude__c,
                            ToLongitude__c,ToLatitude__c ,AvgLongitude__c,AvgLatitude__c,HasDaylightSavings__c,TimeZone__c,AreaCode__c,Territory__c,
                            Jan_Usage__c,Feb_Usage__c,Mar_Usage__c,Apr_Usage__c,May_Usage__c,Jun_Usage__c,
                            Jul_Usage__c,Aug_Usage__c,Sep_Usage__c,Oct_Usage__c, Nov_Usage__c,Dec_Usage__c,dt_Annual_Kwh_Usage__c,usage_option__c,Preferred_Language__c,Rate_Schedule__c,Hawaii_NEM_Approved__c,Lead_Division_Custom__c   
                           from Lead where id =:   leadId];
   
        prospectId =    leadRec.Prospect_Id__c;

        if((leadRec.Street == null || leadRec.Street == '') && 
           (leadRec.City == null || leadRec.City == '') && 
           (leadRec.PostalCode == null || leadRec.PostalCode == '') && 
           (leadRec.State == null || leadRec.State == '')) {
            showViewProj = false;
            showGetDirections = false;
           }
         CurrentUser=[select id,DefaultDivision,Email,contact.Account.BB_Eligible__c,contact.Account.name,contact.id, contact.T_C_Accepted__c from user where id=:userinfo.getUserId()];  
         BBEligible=CurrentUser.contact.Account.BB_Eligible__c;
          if(CurrentUser.contact.Account.name!=null){
            isLGCYUser=(CurrentUser.contact.Account.name.contains('LGCY')||CurrentUser.contact.Account.name.contains('BrightCurrent'));
         }
         if(CurrentUser.defaultdivision!=null){
         getisAEEUser();
         getisSunrunDiv();
         }
    }
    
    public boolean getisAEEUser(){
        isAEEUser = String.valueof(currentUser.defaultdivision).contains(System.label.AEE_label)?True:False;
        return isAEEUser;
    }
    public boolean getisSunrunDiv(){
        isSunrunDivision = String.valueof(currentUser.defaultdivision).EqualsIgnoreCase(System.label.Sunrun_Division)?True:False;
        return isSunrunDivision;
    }
    public string getLeadId(){
        return leadId;
    }
    /**************************** Santosh Changes ************************/
    public List<SelectOption> getDesignTypes(){
        Contact loggedInUserContact=PRMContactUtil.getLoginUserAccountAndContact();
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('--None--','--None--'));
        if(loggedInUserContact!=null){
            /*
            if(loggedInUserContact.As_Built__c=='Granted'){
                options.add(new SelectOption('As Built','As Built'));    
            }
            if(loggedInUserContact.Managing_Partner_AVL_Costs__c=='Granted'){
                options.add(new SelectOption('Managing Partner AVL Costs','Managing Partner AVL Costs'));
            }
            if(loggedInUserContact.Managing_Partner_AVL_Prices__c=='Granted'){
                options.add(new SelectOption('Managing Partner AVL Prices','Managing Partner AVL Prices'));
            }
            if(loggedInUserContact.eAudit__c=='Granted'){
                options.add(new SelectOption('eAudit','eAudit'));
            }
            if(loggedInUserContact.Modify_Proposal__c=='Granted'){
                options.add(new SelectOption('Modify Proposal','Modify Proposal'));
            }            
            if(loggedInUserContact.Manual_Design__c=='Granted')    {
                options.add(new SelectOption('Manual Design','Manual Design'));
            } 
            */                       
            if(loggedInUserContact.Design_New_Proposal__c=='Granted'){
                options.add(new SelectOption('Design New Proposal','Design New Proposal'));
            }            
            
        }
        return options;
    }
    /**************************** End of Santosh Changes *****************/
    /*public PageReference validateAddress(){
    
        CDYNEService CDYNE = new CDYNEService();
        Set<String> setLeadIds = new Set<String>();
        setLeadIds.add(String.ValueOf(this.leadObj.Id));
        // Call CDYNE Service to get immediate ZIP+6 Response and then refresh the page. 
        CDYNE.processZipPlusSixForLeadsImmediate(setLeadIds); 
        return getPageRef();   

    }*/
    
    public PageReference viewProject(){
            /*
            if(leadRec.CDYNE_Status__c != 'Success'){                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'A valid address is required to View Design'));
                return null;
            }
            if(leadRec.Utility_Company__c == null || leadRec.Utility_Company__c == ''){               
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Utility Company is required to View Design'));
                return null;
            }
            if((leadRec.Utility_Company__c.trim() == 'Pacific Gas & Electric (PG&E)'||leadRec.Utility_Company__c.trim() =='PG&E' ||leadRec.Utility_Company__c.trim() == 'San Diego Gas & Electric (SDG&E)'||leadRec.Utility_Company__c.trim() == 'SDG&E' ||leadRec.Utility_Company__c.trim() == 'Southern California Edison (SCE)'||leadRec.Utility_Company__c.trim() == 'SCE') && string.isEmpty(leadRec.Usage_Option__c)){               
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Usage Option Is required for the Utility to View Design'));
                return null;
            }
            List<Territory_Information__c> isTerritoryList = [Select id, Name, IsTerritory__c from Territory_Information__c where IsTerritory__c =: true];
            set<string> isTerritoryTrue = new set<string>();
            Boolean isTerritory = false;
            if(isTerritoryList != null && isTerritoryList.size() > 0){
                for(Territory_Information__c terriInfo : isTerritoryList){
                    isTerritoryTrue.add(terriInfo.name);
                }
                
                if(isTerritoryTrue.contains(leadRec.Utility_Company__c)){
                    isTerritory = true;
                }
            }
            
            if(isTerritory == true && leadRec.Utility_Company__c != null && leadRec.Territory__c == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill in territory information. Territory is needed to price a proposal.'));
                return null;
            }
            if(leadRec.dt_Annual_KWh_Usage__c == null || (leadRec.dt_Annual_KWh_Usage__c < 2000 || leadRec.dt_Annual_KWh_Usage__c >45000)){                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Annual kWh use should be inbetween 2000kWh and 45,000kWh when transferring to Design'));
                return null;
            }
            if(leadRec.Average_Monthly_Electric_Bill__c == null){                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Average Monthly Electric Bill is required to View Design'));
                return null;
            }        
        if(apexpages.getMessages().size() > 0){
            return null;
        }
        */
        String message=CDYNEStandardButtonCall.callCDYNE(leadRec.id);
        if(message!='Success'){
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
         return null;   
        }
        String ObjectType = 'Lead'; 
        DesignToolWebservice.DesignToolWebserviceResponse responseObj = DesignTool.getDesignToolURL(leadId, prospectId, ObjectType);
        PageReference pr = new PageReference(responseObj.url);
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference getPageRef(){
        PageReference pr = new PageReference('/partner/apex/CustomizeLeadDetailPage?Id=' + leadId + '&gmaps=1');
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference convertLead(){
        if(leadRec.city==null||leadRec.state==null||leadRec.Street==null){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Address is required to convert lead'));
        return null;
        }
        /*else if(leadRec.status=='Out of Market'){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ERROR: This Lead may not be converted because Sunrun does not operate in this market.'));
        return null;
        }*/
        else if(leadRec.Lead_Division_Custom__c != label.AEE_label && (leadRec.Sales_partner__c==null||leadRec.market_assignment_sales__c==null)){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ERROR: Market Assignment failure. Please contact Sunrun for assistance.'));
        return null;
        }
        else if(leadRec.Lead_Division_Custom__c != label.AEE_label && (leadRec.Install_partner__c==null||leadRec.market_assignment_install__c==null)){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ERROR: Market Assignment failure. Please contact Sunrun for assistance.'));
        return null;
        }  
        String OpptyId;
        try{
        OpptyId = ConvertLead.doConvert(leadId);
        }
        catch(exception e){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.FATAL, e.getDMLMessage(0));
            ApexPages.addMessage(errorMessage);
            return null;                
        }
        //String baseURL = EDPUtil.getBaseURL();
        String urlPath = baseURL + '/apex/partneropportunitycreate?Id=';
        PageReference pr = new PageReference( urlPath + OpptyId);
        pr.setRedirect(true);
        return pr; 
    }
    
    public PageReference editLead(){
        system.debug('leadId****'+leadId);
        PageReference pr = new PageReference('/apex/PartnerLeadCreate?gmaps=1&leadId=' + leadId);
        pr.setRedirect(true);   
        return pr; 
    }
    
    public PageReference goToDesign() {

        System.debug(LoggingLevel.INFO,'goToDesign');

        if(selectedDesign == '--None--' || selectedDesign == null) {
            return null;
        }

        // Calling CDYNE
        String message = CDYNEStandardButtonCall.callCDYNE(leadRec.id);  
        System.debug(LoggingLevel.INFO,'message : '+message);
        
        if(message!='Success' && message!='Sales Rep Message' && message!='Sales Rep Message' && message!='Sales Rep Division Message' 
            && message!='County Message') {
            displayPopupMessage=message;
            displayPopup=true;
             //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
            return null;   
        }
        
//Redirect to Terms & Conditions page if the user has not accepted Terms & Conditions and there is no error from CDYNE
        if(userinfo.getUserType().equalsIgnoreCase('PowerPartner')){
           CurrentUser = [SELECT id,Email,contact.Account.BB_Eligible__c,contact.id, contact.T_C_Accepted__c FROM user WHERE id=:userinfo.getUserId()];  
           partnerContactId = CurrentUser.contact.id; 
           partnerTandCAccepted = CurrentUser.contact.T_C_Accepted__c; 
        }else{
          list<Contact> CurrentContact=[select id, T_C_Accepted__c from Contact where Sunrun_User__c=:userinfo.getUserId() AND Email= :CurrentUser.Email AND Contact_Type__c='Employee'];     
            if(CurrentContact.size() == 1){
               partnerContactId = CurrentContact[0].id;
               partnerTandCAccepted = CurrentContact[0].T_C_Accepted__c;   
            }else{
                 displayPopupMessage='The valid user contact is required';
                 displayPopup=true;
                 return null;   
            }           
        }
        
        system.debug('userId:' +userinfo.getUserId());
        system.debug('partnerContactId:' +partnerContactId);
        system.debug('partnerTandCAccepted:' +partnerTandCAccepted);
        
        if(!partnerTandCAccepted && message != null && message.equalsIgnoreCase('Success')) {
            if(userinfo.getUserType().equalsIgnoreCase('PowerPartner')){
               displayTandCURL=true;
               return null;   
            }else{
                    system.debug('In T&C not accepted');
                    PageReference partnerTandCPage = TermsConditionsUtil.redirectToTermsConditions(partnerContactId,leadRec.Id,'Lead',selectedDesign,prospectId,'PARTNER','P');
                    
                    system.debug('partnerTandCPage pageRef : ' +partnerTandCPage.getUrl());

/*                    if(userinfo.getUserType()=='PowerPartner'&&baseURL.containsIgnoreCase('partner'))               
                        redirectURL= '/partner' + partnerTandCPage.getUrl();
                    else */
                    redirectURL= partnerTandCPage.getUrl();
                    system.debug('redirectURL:' +redirectURL); 
                    displayTandCURL=true;
                    return null;  
            }                       
        } else {
            String ObjectType = 'Lead';
            selectedDesign=selectedDesign.trim();
            selectedDesign=selectedDesign.replaceAll('(\\s+)', '');
            system.debug('---Print'+selectedDesign);
            if(selectedDesign!='--None--'){
            DesignTool.function=selectedDesign;
            }
            DesignToolWebservice.DesignToolWebserviceResponse responseObj = DesignTool.getDesignToolURL(leadId, prospectId, ObjectType);
            system.debug('---Print url'+responseObj.url);   
            if(message!='Sales Rep Message'&&message!='Sales Rep Division Message'&&message!='County Message') {
                displayURL=true;               
            }
            redirectURL=responseObj.url;

            if(message=='Sales Rep Message'||message=='Sales Rep Division Message'||message=='County Message') {
                
                String partnerTCAccepted = partnerTandCAccepted ? 'true' : 'false';
                String returnPage = 'Lead';

                displaySalesRepUrl=true;  
                if(userinfo.getUserType()=='PowerPartner'&&baseURL.containsIgnoreCase('partner'))               
                SalesRepURL='/partner/apex/SalesRepRedirectLead?Id='+leadId+'&message='+message+'&redirectUrl='+redirectURL+'&partnerTandCAccepted='+partnerTCAccepted+'&partnerContactId='+partnerContactId;
                else
                SalesRepURL='/apex/SalesRepRedirectLead?Id='+leadId+'&message='+message+'&redirectUrl='+redirectURL+'&partnerTandCAccepted='+partnerTCAccepted+'&partnerContactId='+partnerContactId;
                return null;
            }
        }
      
        
        return null;
    }
    public List<Notes__c> getLeadNotes(){

        noteObj = [Select n.Lead__c, n.Notes__c, n.Id , n.createdDate, n.CreatedById,
                    n.LastModifiedDate, n.LastModifiedById,n.Notes_Added_By__c From Notes__c n Where n.Lead__c = :leadId ];
        return noteObj; 

    }
    
    public List<Design_Option__c> getleadDesignOption(){

        desOptionObj = [Select Serial_Number__c, Module__c, Lead__c , KWP__c, 
                             KWH__c, KWH_KWP__c,Usage__c From Design_Option__c Where Lead__c = :leadId ];

        return desOptionObj;
    }
    
    public class BaseException extends Exception {}

// Methods related to Partner Terms and Conditions
    public List<TermsConditions__c> getPartnerTermsConditions(){
        System.debug(LoggingLevel.INFO,'In getPartnerTermsandConditions()');

        PartnerTermsConditions = TermsConditionsUtil.fetchPartnerTermsConditions('PARTNER');
        return PartnerTermsConditions;         
    }

    public void acceptTermsandConditions() {

        system.debug(LoggingLevel.INFO,'In acceptTermsandConditions');
     //   String objectType = 'Lead'; 
        TermsConditionsUtil.updateTermsandConditions(partnerContactId);
        displayTandCURL = false;
        this.goToDesign();
    }
    
    public void declineTermsandConditions() {
        system.debug(LoggingLevel.INFO,'In declineTermsandConditions');        
        displayTandCURL = false;
    }
    
}