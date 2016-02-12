public class PartnerOpportunityCreateExt {
    private id id;
    public String URL {get;set;}
    public String baseURL {get;set;}
    public String scRedirectUrl {get;set;}
    public boolean isPartnerUser{get;set;}
    public boolean showConfirm {get;set;}
    public DesignToolWebservice.DesignToolWebserviceResponse responseObj{get;set;}
    public opportunity opp {get;set;}   
    public Contact contactObj {get;set;}
    public boolean BBEligible{set;get;}
    public boolean createAppointment{set;get;}
    public String selectedDesign {get;set;}//Santosh Changes
    public String selectedPayTransc {get;set;}
    public boolean displayPopup{get;set;}
    public boolean displaySalesRepPopup{get;set;}
    public boolean displayWarningMessage{get;set;}
    public String displayPopupMessage{get;set;}
    public String redirectURL{get;set;}
    public boolean display {get;set;}
    public boolean displayURL{get;set;}
    public boolean displayTandCURL{get;set;}
    public boolean displaySalesRepURL{get;set;}
    public String SalesRepURL{get;set;}
    public boolean partnerTandCAccepted{get;set;}
    public Id partnerContactId{get;set;}  
    public String returnPageVal;
    public User CurrentUser;
    public boolean isAEEuser{get;set;}
    public boolean isSunrunDivision{get;set;}
    public Energy_Storage__c energyStorage { get;set;}
    // Variables for Partner Terms and Conditions
    public List<TermsConditions__c> PartnerTermsConditions;
    
    public PartnerOpportunityCreateExt(ApexPages.StandardController controller) {
        try{
            baseURL = EDPUtil.getBaseURL(); 
            id=controller.getId();    
            showConfirm = false;
            isPartnerUser = false;
            createAppointment = false;
            isAEEuser = false;
            opp=[select id,Account.Zip_6__c,Zip_6_Account__c,Prospect_Id__c,primary_title__c,secondary_title__c,appointment_category__c,home_type__c,Core_Logic_Land_Type__c,
                 Install_Branch_Id__c, install_partner__r.Name,Sales_partner__r.Name,Installation_Type__c,Unable_to_create_proposal__c,HOA__c,Over_2_stories__c,Ready_for__c,
                 Site_Design_Priority__c,Site_Design_Status__c,Designer__c,
                 Date_and_time_request__c,Request_redesign__c,Reason_for_redesign__c,Date_and_time_response__c,Reason_for_not_generating_proposal__c,
                 Usage_Option__c,Annual_kWh_usage__c,Utility_Company__c,Territory__c,Site_Designer__c,Rate_Schedule__c,Hawaii_NEM_Approved__c,
                 (select id,name,First_Name__c,Last_Name__c,Payment_Mode__c,Payment_Type__c,Status__c,Amount__c,Transaction_DateTime__c from payment_transactions__r order by createddate desc), 
                 (select id,name, Appointment_Date_Time__c, duration__c, Appointment_Time_Local__c, Appointment_End_Date_Time__c, Appointment_Type__c, Event_Assigned_To__r.name, Status__c, Sub_Region__c, lastmodifieddate from Appointments__r order by createddate desc)  
                 
                 from opportunity where id=:id];
            List<OpportunityContactRole> OpptyRoleobjlist = [SELECT id, ContactId, OpportunityId, Role, isPrimary FROM OpportunityContactRole WHERE OpportunityId =: opp.id and isPrimary = true limit 1 ];
            if(!OpptyRoleobjlist.isempty())
            contactObj = [SELECT id, MobilePhone,otherphone,name, AccountId, Firstname, Lastname, Email, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode, HomePhone,
                                 Alternate_Phone__c, Phone, HasOptedOutOfEmail, Void_Proposals__c, Preferred_Language__c FROM Contact WHERE id =: OpptyRoleobjlist[0].ContactId limit 1];
            CurrentUser=[select id,Email,contact.Account.BB_Eligible__c,contact.id, contact.T_C_Accepted__c,Division,User_Division_Custom__c,DefaultDivision from user where id=:userinfo.getUserId()];  
            BBEligible=CurrentUser.contact.Account.BB_Eligible__c;  
            
            User userObj = PRMContactUtil.getLoginUser();
            if(userObj != null && userObj.contactId != null){
                isPartnerUser = true;
            }
            string userDivision = CurrentUser.DefaultDivision;
            system.debug('==>userDiv'+userDivision);
            if(userDivision != null){
              isAEEAccountUser(userDivision);
              isSunrunDiv(userDivision);
            }

            if(opp.Install_Branch_Id__c != null && opp.install_partner__r.Id !=null){
                String tempString1 = opp.install_partner__r.Id + '';
                String tempString2 = System.Label.Sunrun_Inc_Id;
                if(tempString1.contains(tempString2)){
                    createAppointment = true;
                }
                System.debug('tempString1: ' + tempString1 + 'tempString2: ' + tempString2 + ' createAppointment: ' + createAppointment);
            }

            List<Energy_Storage__c> lstEnergyStorage = [Select Id,Number_of_adults_home_during_the_day__c,Use_A_C__c,Date_of_Meter_Instal__c,Meter_Sensor_ID__c,ES_kWh__c,Opportunity__c,PV_kWdc__c,Time_return_from_work__c,Prepaid_20_Year_PPA_Lease_Savings__c,Monthly_20_Year_Savings__c,Prepaid_20_Year_PPA_Lease__c,Monthly_20_Year_PPA_Lease_Payment__c,Electric_vehicle_charged_after_4PM__c,Current_Blended_Utility_Rate__c,PV_Turnkey__c,Yearly_kWh_consumption__c,Name from Energy_Storage__c where Opportunity__c=: id];
              if(lstEnergyStorage !=null && lstEnergyStorage.size()>0)
                  energyStorage = lstEnergyStorage[0];
              else
                 energyStorage = new Energy_Storage__c(Opportunity__c=id);
        }catch(Exception exceptionObj){
            ApexPages.addMessages(exceptionObj);               
        }     
    }
    
    public boolean isAEEAccountUser(string userDiv){
    string AEEDiv = label.AEE_label;
    system.debug('AEElabel'+AEEDiv);
    isAEEuser = userDiv.EqualsIgnoreCase(AEEDiv)?true:false;
    system.debug('==>AEEuser'+isAEEuser);
    return isAEEuser;
    }
    public boolean isSunrunDiv(string userDiv){         
        isSunrunDivision = String.valueof(userDiv).EqualsIgnoreCase(System.label.Sunrun_Division)?true:false;
        return isSunrunDivision;
    }
    public pageReference redirect(){    
    PageReference editOpp = new PageReference('/apex/NewCustomOpportunity?OpptyId='+id + '&gmaps=1');
    editOpp.setRedirect(true);
    return editOpp;
    }

    public pageReference cancel(){
        PageReference viewOPty = new PageReference('/apex/partneropportunitycreate?id='+id);
        viewOPty.setRedirect(true);
        return viewOPty;        
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
            if(loggedInUserContact.ePermitting__c=='Granted'){
                options.add(new SelectOption('ePermitting','ePermitting'));
            }
            if(loggedInUserContact.Modify_Proposal__c=='Granted'){
                options.add(new SelectOption('Modify Proposal','Modify Proposal'));
            }            
            if(loggedInUserContact.Manual_Design__c=='Granted')    {
                options.add(new SelectOption('Manual Design','Manual Design'));
            } 
            */           
           if(loggedInUserContact.Design_New_Proposal__c=='Granted'){
                //options.add(new SelectOption('Design New Proposal','Design New Proposal'));
                //options.add(new SelectOption('Pricing','Pricing'));
                //options.add(new SelectOption('ShoppingCart','Shopping Cart'));
                options.add(new SelectOption('DesignNewProposal','New Project'));
                if(!isAEEUser){
                options.add(new SelectOption('SavedProject','Saved Project'));
                }
           }           
            
        }
        return options;
    }

     public List<SelectOption> getApptCategories(){
        display = false;
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('--None--','--None--'));
        options.add(new SelectOption('Site Audit','Site Audit'));
        return options;
     }

     public List<SelectOption> getPayTransOptions(){
        display = false;
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('--None--','--None--'));
        options.add(new SelectOption('OneTimePayment','One Time Payment'));
        options.add(new SelectOption('EnrollForAutoPayment','Enroll for Auto Payment'));
        options.add(new SelectOption('SendRequestForPaymentEmail','Email: One Time Payment'));
        options.add(new SelectOption('SendRequestForAutoPaymentEmail','Email: Auto Payment'));
        return options;
     }
    /**************************** End of Santosh Changes *****************/
    public pageReference confirmRedirectToDesign(){
        DesignToolWebservice.DesignToolWebserviceResponse responseObj = DesignTool.getDesignToolURL(opp.id, opp.Prospect_Id__c, 'Opportunity');
        PageReference redirectDesign = new PageReference(responseObj.url);
        redirectDesign.setRedirect(true);
        showConfirm = false;
        return redirectDesign;      
    }
    
    public pageReference redirectToDesign(){
        String message=CDYNEStandardButtonCall.callOpportunity(opp.id);
        if(message!='Success'){
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
         return null;   
        }
        responseObj = new DesignToolWebservice.DesignToolWebserviceResponse();
        /*if(opp.Account.Zip_6__c == null||opp.Annual_kWh_usage__c==null||opp.Utility_Company__c==null || 
            opp.Account.Zip_6__c == '' ||opp.Annual_kWh_usage__c == 0.0 ||opp.Utility_Company__c== ''){
            responseObj.errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000007').error_message__c; 
            responseObj.status = ProposalUtil.ERROR;                        
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, responseObj.errorMessage));       
        }
        if((opp.Utility_Company__c !=null && opp.Utility_Company__c != '' &&(opp.Utility_Company__c.trim() == 'Pacific Gas & Electric (PG&E)'||opp.Utility_Company__c.trim() == 'San Diego Gas & Electric (SDG&E)' ||opp.Utility_Company__c.trim() == 'Southern California Edison (SCE)')||opp.Utility_Company__c.trim() == 'SCE'||opp.Utility_Company__c.trim() == 'SDG&E'||opp.Utility_Company__c.trim() == 'PG&E') && string.isEmpty(opp.Usage_Option__c)){               
            String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000008').error_message__c;                              
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));       
            //responseObj.errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000008').error_message__c;   
            //responseObj.status = ProposalUtil.ERROR; 
        }
        */
        //else{
            DesignToolWebservice.DesignToolWebserviceResponse responseObj2 = DesignTool.getDesignToolURL(opp.id, opp.Prospect_Id__c, 'Opportunity');
            if(responseObj2.errorMessage == 'InValidRange' ){
                String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000009').error_message__c;                              
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));       
                //responseObj.errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000009').error_message__c;   
                //responseObj.status = ProposalUtil.ERROR; 
            }else if(responseObj2.errorMessage == 'NoTerritory' ){
                String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000010').error_message__c;                              
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));       
                //responseObj.errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000010').error_message__c;   
                //responseObj.status = ProposalUtil.ERROR; 
            }
            else{
                //DesignToolWebservice.DesignToolWebserviceResponse responseObj;
                responseObj = DesignTool.canUserCreateORModifyProposal(opp.id);
                System.debug('responseObj.status: ' + responseObj.status);
                if(responseObj.status == ProposalUtil.SUCCESS){
                    PageReference redirectDesign = new PageReference(responseObj2.url);
                    redirectDesign.setRedirect(true);
                    return redirectDesign;
                }else if(responseObj.status == ProposalUtil.WARNING){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000022').error_message__c;  
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));     
                    showConfirm = true;             
                }else if(responseObj.status == ProposalUtil.ERROR){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000023').error_message__c;  
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));                     
                }
            }
        //}  
        return null;
    }

     public pageReference redirectDesignTool(){
        if(selectedDesign=='--None--'||selectedDesign==null){
            return null;
        }
        
        String message=CDYNEStandardButtonCall.callOpportunity(opp.id);
        System.debug(LoggingLevel.INFO,'message : '+message);
         
        if(message!='Success'&&message!='Sales Rep Message'&&message!='Sales Rep Division Message'&&message!='County Message'){
         displayPopupMessage=message;
         displayPopup=true; 
         //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
         return null;   
        }

//Redirect to Terms & Conditions page if the user has not accepted Terms & Conditions and there is no error from CDYNE

        if(userinfo.getUserType().equalsIgnoreCase('PowerPartner')){
           CurrentUser=[select id,Email,contact.Account.BB_Eligible__c,contact.id, contact.T_C_Accepted__c from user where id=:userinfo.getUserId()];   
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
         
         if(!partnerTandCAccepted && message != null && message.equalsIgnoreCase('Success')){
            if(userinfo.getUserType().equalsIgnoreCase('PowerPartner')){
               displayTandCURL=true;
               return null;   
            }else{
                system.debug('In T&C not accepted');
                returnPageVal = 'Opty';
                PageReference partnerTandCPage = TermsConditionsUtil.redirectToTermsConditions(partnerContactId,opp.Id,'Opty',selectedDesign,opp.Prospect_Id__c,'PARTNER','P');
               
                system.debug('partnerTandCPage pageRef : ' +partnerTandCPage.getUrl());           
                
/*                if(userinfo.getUserType()=='PowerPartner' && baseURL.containsIgnoreCase('partner'))               
                   redirectURL= '/partner' + partnerTandCPage.getUrl();
                else */
                redirectURL= partnerTandCPage.getUrl();
                system.debug('redirectURL:' +redirectURL); 
                displayTandCURL=true;
                return null;    
              }
         }else{
            responseObj = new DesignToolWebservice.DesignToolWebserviceResponse();
            selectedDesign=selectedDesign.trim();
            selectedDesign=selectedDesign.replaceAll('(\\s+)', '');
            if(selectedDesign!='--None--')
            DesignTool.function=selectedDesign;
            DesignToolWebservice.DesignToolWebserviceResponse responseObj2 = DesignTool.getDesignToolURL(opp.id, opp.Prospect_Id__c, 'Opportunity');
            if(responseObj2.errorMessage == 'InValidRange' ){
                String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000009').error_message__c;   
                displayPopupMessage=errorMessage ;
                displayPopup=true;                           
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));       
            }else if(responseObj2.errorMessage == 'NoTerritory' ){
                String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000010').error_message__c;    
                displayPopupMessage=errorMessage ;
                displayPopup=true;                           
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));       
             }
            else{
                responseObj = DesignTool.canUserCreateORModifyProposal(opp.id);
                System.debug('responseObj.status: ' + responseObj.status);
                System.debug('message: ' + message);
                System.debug('responseObj.url: ' + responseObj.url);
                System.debug('responseObj: ' + responseObj);
                if(responseObj.status == ProposalUtil.SUCCESS){
                    redirectURL=responseObj2.url;
                    if(message=='Success'){
                    displayURL=true; 
                        If(opp.Site_Designer__c==null) 
                        { 
                          opp.Site_Designer__c=UserInfo.getUserId(); 
                          update opp;   
                        } 
                    }                    
                    //return null;                 
                 //   PageReference redirectDesign = new PageReference(responseObj2.url);
                 //   redirectDesign.setRedirect(true);
                 //   return redirectDesign;
                }else if(responseObj.status == ProposalUtil.WARNING){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000022').error_message__c;  
                     displayPopupMessage=errorMessage ;
                     displayWarningMessage=true; 
                     redirectURL=responseObj2.url;
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));     
                    showConfirm = true;             
                }else if(responseObj.status == ProposalUtil.ERROR){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000023').error_message__c;  
                     displayPopupMessage=errorMessage ;
                    displayPopup=true; 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));                     
                }
                if((message=='Sales Rep Message'||message=='Sales Rep Division Message'&&userinfo.getUserType()!='PowerPartner')||message=='County Message'){
                    String partnerTCAccepted = partnerTandCAccepted ? 'true' : 'false';
                    returnPageVal = 'Opty';
                    
                    displaySalesRepUrl=true;  
                    if(userinfo.getUserType()=='PowerPartner'&&baseURL.containsIgnoreCase('partner'))               
                    SalesRepURL='/partner/apex/SalesRepRedirect?Id='+id+'&message='+message+'&redirectUrl='+redirectURL+'&partnerTandCAccepted='+partnerTCAccepted+'&partnerContactId='+partnerContactId;
                    else
                    SalesRepURL='/apex/SalesRepRedirect?Id='+id+'&message='+message+'&redirectUrl='+redirectURL+'&partnerTandCAccepted='+partnerTCAccepted+'&partnerContactId='+partnerContactId;
                    //PageReference editOpp = new PageReference('/apex/SalesRepRedirect?Id='+id);
                    ///editOpp.setRedirect(true);
                    return null;
                }
            }
         }   
        return null;
     }
    /*
    public void redirectToDesign(){
        responseObj = new DesignToolWebservice.DesignToolWebserviceResponse();
        if(opp.Account.Zip_6__c == null||opp.Annual_kWh_usage__c==null||opp.Utility_Company__c==null || 
            opp.Account.Zip_6__c == '' ||opp.Annual_kWh_usage__c == 0.0 ||opp.Utility_Company__c== ''){
            responseObj.errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000007').error_message__c; 
            responseObj.status = ProposalUtil.ERROR;                        
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));          
        }
        if((opp.Utility_Company__c !=null && opp.Utility_Company__c != '' &&(opp.Utility_Company__c.trim() == 'Pacific Gas & Electric (PG&E)'||opp.Utility_Company__c.trim() == 'San Diego Gas & Electric (SDG&E)' ||opp.Utility_Company__c.trim() == 'Southern California Edison (SCE)')) && string.isEmpty(opp.Usage_Option__c)){               
            //String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000008').error_message__c;                                
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));       
            responseObj.errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000008').error_message__c; 
            responseObj.status = ProposalUtil.ERROR; 
        }
        else{
            URL = DesignTool.getDesignToolURL(opp.id, opp.Prospect_Id__c, 'Opportunity');
            if(URL == 'InValidRange' ){
                //String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000009').error_message__c;                                
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));       
                responseObj.errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000009').error_message__c; 
                responseObj.status = ProposalUtil.ERROR; 
            }else if(URL == 'NoTerritory' ){
                //String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000010').error_message__c;                                
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));       
                responseObj.errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000010').error_message__c; 
                responseObj.status = ProposalUtil.ERROR; 
            }
            else{
                //DesignToolWebservice.DesignToolWebserviceResponse responseObj;
                responseObj = DesignTool.canUserCreateORModifyProposal(opp.id);
                //if(responseObj.status == ProposalUtil.SUCCESS || responseObj.status == ProposalUtil.WARNING){
                    //PageReference redirectDesign = new PageReference(URL);
                    //redirectDesign.setRedirect(true);
                    //return redirectDesign;
                //}else if(responseObj.status == ProposalUtil.ERROR){
                    //String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000010').error_message__c;    
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));                   
                //}
            }
        }   
        //return null;
    }
    */
    
    /*
    public void redirectToDesign1(){
        responseObj = new DesignToolWebservice.DesignToolWebserviceResponse();
        if(opp.Account.Zip_6__c==null||opp.Annual_kWh_usage__c==null||opp.Utility_Company__c==null){
            String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000007').error_message__c;                              
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));          
        }
        if((opp.Utility_Company__c!=null&&(opp.Utility_Company__c.trim() == 'Pacific Gas & Electric (PG&E)'||opp.Utility_Company__c.trim() == 'San Diego Gas & Electric (SDG&E)' ||opp.Utility_Company__c.trim() == 'Southern California Edison (SCE)')) && string.isEmpty(opp.Usage_Option__c)){               
            String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000008').error_message__c;                              
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));       
        }
        else{
            URL = DesignTool.getDesignToolURL(opp.id, opp.Prospect_Id__c, 'Opportunity');
            if(URL == 'InValidRange' ){
                String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000009').error_message__c;                              
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));       
            }else if(URL == 'NoTerritory' ){
                String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000010').error_message__c;                              
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));       
            }
            else{
                //DesignToolWebservice.DesignToolWebserviceResponse responseObj;
                responseObj = DesignTool.canUserCreateORModifyProposal(opp.id);
                if(responseObj.status == ProposalUtil.SUCCESS || responseObj.status == ProposalUtil.WARNING){
                    //PageReference redirectDesign = new PageReference(URL);
                    //redirectDesign.setRedirect(true);
                    //return redirectDesign;
                }else if(responseObj.status == ProposalUtil.ERROR){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000010').error_message__c;  
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));                     
                }
            }
        }   
        //return null;
    }
    
    */
    public void closePopup() {
        displaySalesRepPopup = false;
    }
    private String standardPageURL {
        get {
            return '/' + id;
        }
        set;
    }   
    public pagereference onLoad(){
        //String baseUrl=EDPUtil.getBaseURL();
        //system.debug('--->'+baseUrl);
        //return null;
        Contact contactObj = PRMContactUtil.getLoginUserAccountAndContact();
        User loginUser = PRMContactUtil.getUser(UserInfo.getUserId());   
        if(loginUser.contactId !=null){
            return null;
        }           
        else{  
            Pagereference p=new Pagereference(standardPageURL); 
            p.setRedirect(true);
            return p;   
        }    
    }
    
    public pagereference partnerSungevity(){
    if(selectedPayTransc=='OneTimePayment'  && (opp.Sales_Partner__r.Name == 'Sungevity' || opp.Install_Partner__r.Name == 'Sungevity')){
        display = true;
        system.debug('Display is '+display);
    }
    else if(selectedPayTransc=='SendRequestForPaymentEmail' && (opp.Sales_Partner__r.Name == 'Sungevity' || opp.Install_Partner__r.Name == 'Sungevity')){
        display = true;
        system.debug('Display is '+display);
    }
    else{
        display = false;
        system.debug('Display is '+display);
    }
    return null;
    }
     public pagereference paymentTransactionRedirect(){
        Pagereference page;
        String redirectUrl;
        Boolean PartnerPP=baseURL.containsIgnoreCase('partner');
        
        system.debug('Display before loop is '+display);
        
        if(selectedPayTransc=='OneTimePayment'){
           redirectUrl=isPartnerUser&&PartnerPP?'/partner/apex/PartnerOptyPayment':'/apex/CallCenterOptyPayment';
        }        
        else if(selectedPayTransc=='SendRequestForAutoPaymentEmail'){
            redirectUrl=isPartnerUser&&PartnerPP?'/partner/apex/RequestForOptyAutoPayment':'/apex/RequestForOptyAutoPayment';
        }
        else if(selectedPayTransc=='SendRequestForPaymentEmail'){
            redirectUrl=isPartnerUser&&PartnerPP?'/partner/apex/RequestForOptyPayment':'/apex/RequestForOptyPayment';
        }
        else if(selectedPayTransc=='EnrollForAutoPayment'){
            redirectUrl=isPartnerUser&&PartnerPP?'/partner/apex/PartnerOptyAutoPayment':'/apex/CallcenterOptyAutoPayment';
        }   
        
        system.debug('Redirect is '+redirectUrl);
        
        if(redirectUrl!=null){
        redirectUrl=redirectUrl+'?id='+id;  
        page=new Pagereference(redirectUrl);
        page.setRedirect(true);
        return page;
        }       
        return null;
     }
    /* 
    @RemoteAction
    public static DesignToolWebservice.DesignToolWebserviceResponse getModifyProposalURLForOpty(String objectId){
        DesignToolWebservice.DesignToolWebserviceResponse responseObj = new DesignToolWebservice.DesignToolWebserviceResponse();
        responseObj.status = 'Status ...';
        responseObj.errorMessage = 'Error ...';
        //responseObj = DesignTool.getModifyProposalURLForOpty(objectId);
        //System.debug('responseObj: ' +responseObj);
        return  responseObj;
    } 
    */   
    
    // Methods related to Partner Terms and Conditions
    public List<TermsConditions__c> getPartnerTermsConditions(){
        System.debug(LoggingLevel.INFO,'In getPartnerTermsandConditions()');

        if(isAEEUser){
        PartnerTermsConditions = TermsConditionsUtil.fetchPartnerTermsConditions('AEE');
        }
        else{
        PartnerTermsConditions = TermsConditionsUtil.fetchPartnerTermsConditions('PARTNER');
        }
        return PartnerTermsConditions;         
    }

    public void acceptTermsandConditions() {

        system.debug(LoggingLevel.INFO,'In acceptTermsandConditions');
   //     String objectType = 'Lead'; 
        TermsConditionsUtil.updateTermsandConditions(partnerContactId);
        displayTandCURL = false;
        this.redirectDesignTool();
    }
    
    public void declineTermsandConditions() {
        system.debug(LoggingLevel.INFO,'In declineTermsandConditions');        
        displayTandCURL = false;
    }

    public pagereference showScheduler(){
        Pagereference page;
        scRedirectUrl = '';
        Boolean PartnerPP=baseURL.containsIgnoreCase('partner');
        
        if(!String.isEmpty(opp.appointment_category__c) && opp.appointment_category__c != '--None--'){
            scRedirectUrl = '/apex/CallcenterOptyScheduler?scontrolCaching=1&id=' + Id + '&category=' + opp.appointment_category__c;
        }
        System.debug('scRedirectUrl: ' + scRedirectUrl);
        
        if(!String.isEmpty(scRedirectUrl)){
            page=new Pagereference(scRedirectUrl);
            page.setRedirect(true);
            return page;
        }       
        return null;
    }
    
}