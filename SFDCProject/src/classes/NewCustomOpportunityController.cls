public class NewCustomOpportunityController {
    
    public String PartnerNotes{get;set;}
    private String LicenseKey = Label.Cdyne_LicenseKey;           
    private String EndPoint = Label.Cdyne_VerifyAddressAdvanced; 
    public String AddValidStateVal{get;set;}
    public String Zip6Val{get;set;}
    public String OpptyId {get;set;}
    public boolean editOppty {get; set;}
    public String parentURL{get;set;}
    public String baseURL{get;set;}
    public String CDYNECounty{get;set;}
    ApexPages.StandardController controller;
    public String errorMessage{get;set;}
    Public string selectedPickListVal { get; set; }
    public Opportunity opportunity {get;set;}
    public Opportunity oldOpportunity {get;set;}
    
    public Account accountObj {get;set;}
    public Account oldaccountObj {get;set;}
    
    public Contact contactObj {get;set;}
    public Contact oldcontactObj {get;set;}
    
    public OpportunityContactRole OppyContactRole {get;set;}
    public String retURL = '';
    public String RecordTypeId = '';
        public boolean enableConfirmSave {get;set;}
    public boolean userConfirmed {get;set;}
    public boolean isAddressChange {get;set;}
    public boolean isNameChange {get;set;}
    public Energy_Storage__c energyStorage { get;set;}
    public SR_Attachment__c srattachment {get;set;}
    public boolean isAEEUser{get;set;}

    static final private String opportunityPrefix = Schema.SObjectType.Opportunity.getKeyPrefix();
    public NewCustomOpportunityController (ApexPages.StandardController c) 
    {
        try{
            system.debug('Apexpages Inside Constructor');
            controller = c;
            IsEngStApplicable = true;
            isAEEUser = false;
            //opportunity = (Opportunity)c.getRecord();
            if(opportunity == null)
            { opportunity = new opportunity();}
            
            OpptyId = System.currentPageReference().getParameters().get('opptyId');
            System.debug('opptyId: ' + opptyId);
            energyStorage = new Energy_Storage__c(Opportunity__c=OpptyId);
            if(contactObj == null){
                    contactObj = new Contact();
            } 
            if(accountObj == null){
                    accountObj = new Account();
            }
            
            OppyContactRole = new OpportunityContactRole();
            retURL = System.currentPagereference().getParameters().get('retURL');
            RecordTypeId = System.currentPagereference().getParameters().get('RecordType');
           
            baseURL =  EDPUtil.getBaseURL();
            parentURL = baseURL + '/apex/OpportunitySearch?retURL='; 
            system.debug('ParentURL' + parentURL);
            init();
        }catch(Exception exceptionObj){
            ApexPages.addMessages(exceptionObj);               
        }   
    }
    
   public NewCustomOpportunityController(){
        system.debug('Inside Constructor');
        IsEngStApplicable = true;
        contactObj = new Contact();
        accountObj = new Account();
        opportunity = new Opportunity();
                OppyContactRole = new OpportunityContactRole();
        init();
    }
    public boolean IsEngStApplicable { get; set;}
    public Pagereference onChangeEnergyApplicable()
    {
        IsEngStApplicable = opportunity.Energy_Storage_Applicable__c;
        return null;    
    }
    private void init(){
         editOppty = false;
         oldcontactObj = new Contact();
         oldaccountObj = new Account();
         
         if(OpptyId != null && OpptyId != ''){
             Opportunity opptyobj = [select Id,Site_Visit_Date_Time__c,Deal_ID__c,Offer_Promotion_Name__c,Referral_Promotion_Name__c,Offer__c,Sales_rep_of_referrer__c,Referral__c,lead_qualifier__c,Designer__c,Opportunity_Source_Type__c,ownerid,Opportunity_Status__c,Reason__c,Consultation_Time__c,SalesRep__c,ready_for__c, Best_way_to_reach__c,Sales_Contact_Method__c,Home_Type__c ,Over_2_stories__c,HOA__c ,Unable_to_create_proposal__c,Date_and_time_request__c,Date_and_time_response__c,
                            Reason_for_not_generating_proposal__c,Reason_for_redesign__c,Request_redesign__c,Name,square_footage__c, county__c,Prospect_Id__c,Homeowner_First_Name__c,Homeowner_Last_Name__c,Homeowner_Email__c,Street__c,
                            city__c,state__c,phone__c,CloseDate,Alternate_Phone__c,Email_Opt_Out__c,zip_code__c,StageName,Sales_Representative__c,Site_Design_Priority__c,Site_Design_Status__c,Site_Designer__c ,
                            Utility_Company__c,Why_Closed_Lost__c,Competitive_Deal__c,Why_Unqualified__c,Partner_notes__c,Notes__c,Average_Monthly_Electric_Bill__c,
                            CDYNE_Status__c, Zip_6__c,Territory__c,Competitor__c,Why_Inactive__c,Why_Postponed__c,Average_Monthly_Electricity_Usage__c,
                            Jan_Usage__c,Feb_Usage__c,Mar_Usage__c,Apr_Usage__c,May_Usage__c,Jun_Usage__c,Void_Proposals__c,Energy_Storage_Applicable__c,
                            Jul_Usage__c,Aug_Usage__c,Sep_Usage__c,Oct_Usage__c, Nov_Usage__c,Dec_Usage__c,Purchased_Thru__c,
                            Installation_Type__c,Roof_Azimuth__c,Shading__c,Age_of_Roof__c,Roofing_Type__c,AccountId,usage_option__c,Rate_Schedule__c,Hawaii_NEM_Approved__c,Division                    
                            from Opportunity where id =: OpptyId limit 1];
            List<OpportunityContactRole> OpptyRoleobjlist = [SELECT id, ContactId, OpportunityId, Role, isPrimary FROM OpportunityContactRole WHERE OpportunityId =: OpptyId and isPrimary = true limit 1 ];
            OpportunityContactRole OpptyRoleobj = new OpportunityContactRole();
            selectedPickListVal=opptyobj.StageName;
            if(OpptyRoleobjlist.size() > 0 && OpptyRoleobjlist != null){
                OpptyRoleobj = OpptyRoleobjlist[0];
                Contact contobj = [SELECT id, name,HomePhone,MobilePhone, otherphone,AccountId, Firstname, Lastname, Email, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode,
                                     Alternate_Phone__c, Phone, HasOptedOutOfEmail, Void_Proposals__c,Preferred_Language__c FROM Contact WHERE id =: OpptyRoleobj.ContactId limit 1];
                if(contobj != null){
                    contactObj = contobj;
                    ContactUtil.copyContactNameInformation(oldcontactObj, contactObj);
                }
            }
            
            if(opptyobj != null){
                Account acctobj = [SELECT id, Name,Phone,County__c, BillingStreet, BillingCity, BillingState, State__c, BillingCountry, BillingPostalCode, 
                                                Zip_6__c,CDYNE_Status__c, Void_Proposals__c,Address_Standardization_Override__c,Latitude__c,Longitude__c FROM Account WHERE id =:opptyobj.AccountId limit 1];
                if(acctobj != null){
                        accountObj = acctobj;
                        AccountUtil.copyAcctAddressInformation(oldaccountObj, accountObj);
                        
                }
                
                opportunity = opptyobj;
                editOppty = true;
                oldOpportunity = new Opportunity();
                
                                OpportunityUtil.copyOptyUtilityInformation(oldOpportunity, opportunity);
                }
             List<Energy_Storage__c> lstEnergyStorage = [Select Id,Number_of_adults_home_during_the_day__c,Use_A_C__c,Date_of_Meter_Instal__c,Meter_Sensor_ID__c,ES_kWh__c,Opportunity__c,PV_kWdc__c,Time_return_from_work__c,Prepaid_20_Year_PPA_Lease_Savings__c,Monthly_20_Year_Savings__c,Prepaid_20_Year_PPA_Lease__c,Monthly_20_Year_PPA_Lease_Payment__c,Electric_vehicle_charged_after_4PM__c,Current_Blended_Utility_Rate__c,PV_Turnkey__c,Yearly_kWh_consumption__c,Name from Energy_Storage__c where Opportunity__c=: OpptyId];
              if(lstEnergyStorage !=null && lstEnergyStorage.size()>0)
                  energyStorage = lstEnergyStorage[0];
              else
                 energyStorage = new Energy_Storage__c(Opportunity__c=OpptyId);
         
             string OptyDivision = opptyobj.Division;
             system.debug('==>Opty Div'+OptyDivision);
             string AEEDiv = label.AEE_label;
             isAEEUser = OptyDivision.EqualsIgnoreCase(AEEDiv)?true:false;
             system.debug('===> AEE User :'+isAEEuser);
         }
         
         if(editOppty == true){
            AddValidStateVal = accountObj.CDYNE_Status__c;
            Zip6Val = accountObj.Zip_6__c;
        }
        enableConfirmSave = false;
        userConfirmed = false;
        isAddressChange = false;
        isNameChange = false;
    }
    public pagereference getUtilities(){
    opportunity.State__c=accountObj.State__c;
    return null;
    }
    public List<SelectOption> getPickLstValue(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('None','--None--'));
        Schema.DescribeFieldResult fieldResult = Schema.sObjectType.Opportunity.fields.stageName;
        fieldResult=fieldResult.getSObjectField().getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple){
            if(p.getValue()!='Referral of partner'&&p.getValue()!='Passed to Verengo')
            options.add(new SelectOption(p.getValue(), p.getValue()));
        }        
        return options;         
     }
    
    public PageReference submit(){
        
        try{
                Id userId = UserInfo.getUserId();
                User loginUser = PRMContactUtil.getUser(userId);
                Contact loginContact = PRMContactUtil.getLoginUserContact();

               // if(hasSRApprovedProposals() == true){
               //     errorMessage = 'You may not edit the Opportunity when Proposal Stage is SR Approved';
              //      Exception expObj = new BaseException(errorMessage);
               //     expObj.setMessage(errorMessage);
               //     ApexPages.addMessages(expObj);
                //    return null;                    
               // }
  //              opportunity.StageName=selectedPickListVal;
                /*
                if(contactObj.Firstname == null || contactObj.Firstname == '' ||
                        contactObj.Lastname == null || contactObj.Lastname == '' ||
                        contactObj.Email == null || contactObj.Email == '' ||
                    accountObj.BillingStreet == null || accountObj.BillingStreet == '' ||
                    accountObj.BillingCity == null || accountObj.BillingCity  == '' ||
                    accountObj.State__c == null || accountObj.State__c  == '' ||
                    accountObj.BillingPostalCode  == null || accountObj.BillingPostalCode  == '' ||
                    contactObj.Phone == '' || opportunity.CloseDate == null)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter values for the required fields'));
                    return null;
                }
                */
                //list<Proposal__c> proposalList = [Select Id, Stage__c from proposal__c where Opportunity__c =: opportunity.Id];
                
                if(contactObj.Firstname == null || contactObj.Firstname == ''){
                contactObj.Firstname.addError('You must enter a value');
                return null;
                }
                if(contactObj.Lastname == null || contactObj.Lastname == ''){
                contactObj.Lastname.addError('You must enter a value');
                return null;
                }
                if((contactObj.Email == null || contactObj.Email == '')&&(contactObj.Phone == null || contactObj.Phone == '')){
                //contactObj.Phone.addError('Phone or email is required');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Phone or Email is required'));
                return null;
                }
                if(accountObj.BillingStreet == null || accountObj.BillingStreet == ''){
                accountObj.BillingStreet.addError('You must enter a value');
                return null;
                }
                if(accountObj.BillingCity == null || accountObj.BillingCity == ''){
                accountObj.BillingCity.addError('You must enter a value');
                return null;
                }
                if(accountObj.State__c == null || accountObj.State__c == ''){
                accountObj.State__c.addError('You must enter a value');
                return null;
                }
                if(accountObj.BillingPostalCode == null || accountObj.BillingPostalCode == ''){
                accountObj.BillingPostalCode.addError('You must enter a value');
                return null;
                }
                /*if(contactObj.Phone == null || contactObj.Phone == ''){
                contactObj.Phone.addError('You must enter a value');
                return null;
                }
                */
                /*
                if(opportunity.CloseDate == null){
                opportunity.CloseDate.addError('You must enter a value');
                return null;
                }
                */
                if(opportunity.Average_Monthly_Electric_Bill__c != null && opportunity.Average_Monthly_Electric_Bill__c < 50 && opportunity.Average_Monthly_Electric_Bill__c != 0){
                    
                   /* errorMessage = 'Average Monthly Electric Bill should be $50 or greater';
                    Exception expObj = new BaseException(errorMessage);
                    expObj.setMessage(errorMessage);
                    ApexPages.addMessages(expObj);
                    */
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000011').error_message__c;
                    opportunity.Average_Monthly_Electric_Bill__c.adderror(errorMessage);
                    return null;
                }
                /*
                if(opportunity.Jan_Usage__c < 0 || opportunity.Feb_Usage__c < 0 || opportunity.Mar_Usage__c < 0 || opportunity.Apr_Usage__c < 0 || opportunity.May_Usage__c < 0 || 
                   opportunity.Jun_Usage__c < 0 ||  opportunity.Jul_Usage__c < 0 ||  opportunity.Aug_Usage__c < 0 || opportunity.Sep_Usage__c < 0 || opportunity.Oct_Usage__c < 0 ||  
                   opportunity.Nov_Usage__c < 0 ||  opportunity.Dec_Usage__c < 0 ) {
                    
                    errorMessage = 'Negative values not allowed on Monthly kwh use';
                    Exception expObj = new BaseException(errorMessage);
                    expObj.setMessage(errorMessage);
                    ApexPages.addMessages(expObj);
                    return null;
                   } 
                   */
                 /*  
                 if(opportunity.Jan_Usage__c < 0 ) {
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000012').error_message__c;
                    opportunity.Jan_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Feb_Usage__c < 0){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000012').error_message__c;
                    opportunity.Feb_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Mar_Usage__c < 0){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000012').error_message__c;
                    opportunity.Mar_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Apr_Usage__c < 0){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000012').error_message__c;
                    opportunity.Apr_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.May_Usage__c < 0){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000012').error_message__c;
                    opportunity.May_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Jun_Usage__c < 0){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000012').error_message__c;
                    opportunity.Jun_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Jul_Usage__c < 0){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000012').error_message__c;
                    opportunity.Jul_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Aug_Usage__c < 0){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000012').error_message__c;
                    opportunity.Aug_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Sep_Usage__c < 0){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000012').error_message__c;
                    opportunity.Sep_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Oct_Usage__c < 0){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000012').error_message__c;
                    opportunity.Oct_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Nov_Usage__c < 0){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000012').error_message__c;
                    opportunity.Nov_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Dec_Usage__c < 0){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000012').error_message__c;
                    opportunity.Dec_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 */
                 /*
                 if(opportunity.Jan_Usage__c == null || opportunity.Feb_Usage__c == null || opportunity.Mar_Usage__c == null || opportunity.Apr_Usage__c == null || opportunity.May_Usage__c == null
                    || opportunity.Jun_Usage__c == null || opportunity.Jul_Usage__c == null || opportunity.Aug_Usage__c == null || opportunity.Sep_Usage__c == null || opportunity.Oct_Usage__c == null 
                    || opportunity.Nov_Usage__c == null || opportunity.Dec_Usage__c== null ) {
                    
                    errorMessage = 'Minimum monthly use should be 0 kWh. No blank value is allowed';
                    Exception expObj = new BaseException(errorMessage);
                    expObj.setMessage(errorMessage);
                    ApexPages.addMessages(expObj);
                    return null;
                   } */
                   /*
                 if(opportunity.Jan_Usage__c == null ) {
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000013').error_message__c;
                    opportunity.Jan_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Feb_Usage__c == null){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000013').error_message__c;
                    opportunity.Feb_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Mar_Usage__c == null){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000013').error_message__c;
                    opportunity.Mar_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Apr_Usage__c == null){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000013').error_message__c;
                    opportunity.Apr_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.May_Usage__c == null){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000013').error_message__c;
                    opportunity.May_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Jun_Usage__c == null){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000013').error_message__c;
                    opportunity.Jun_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Jul_Usage__c == null){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000013').error_message__c;
                    opportunity.Jul_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Aug_Usage__c == null){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000013').error_message__c;
                    opportunity.Aug_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Sep_Usage__c == null){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000013').error_message__c;
                    opportunity.Sep_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Oct_Usage__c == null){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000013').error_message__c;
                    opportunity.Oct_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Nov_Usage__c == null){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000013').error_message__c;
                    opportunity.Nov_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Dec_Usage__c == null){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000013').error_message__c;
                    opportunity.Dec_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 */
                 /*
                 if(opportunity.Jan_Usage__c  > 10000 || opportunity.Feb_Usage__c > 10000 || opportunity.Mar_Usage__c > 10000 || opportunity.Apr_Usage__c > 10000 || opportunity.May_Usage__c > 10000
                    || opportunity.Jun_Usage__c > 10000 || opportunity.Jul_Usage__c > 10000 || opportunity.Aug_Usage__c > 10000 || opportunity.Sep_Usage__c > 10000 || opportunity.Oct_Usage__c > 10000 
                    || opportunity.Nov_Usage__c > 10000 || opportunity.Dec_Usage__c > 10000) {
                    
                    errorMessage = 'Maximum monthly use is 10,000 kWh';
                    Exception expObj = new BaseException(errorMessage);
                    expObj.setMessage(errorMessage);
                    ApexPages.addMessages(expObj);
                    return null;
                   } 
                 */
                 if(opportunity.Jan_Usage__c > 10000) {
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000014').error_message__c;
                    opportunity.Jan_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Feb_Usage__c > 10000){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000014').error_message__c;
                    opportunity.Feb_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Mar_Usage__c > 10000){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000014').error_message__c;
                    opportunity.Mar_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Apr_Usage__c > 10000){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000014').error_message__c;
                    opportunity.Apr_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.May_Usage__c > 10000){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000014').error_message__c;
                    opportunity.May_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Jun_Usage__c > 10000){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000014').error_message__c;
                    opportunity.Jun_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Jul_Usage__c > 10000){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000014').error_message__c;
                    opportunity.Jul_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Aug_Usage__c > 10000){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000014').error_message__c;
                    opportunity.Aug_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Sep_Usage__c > 10000){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000014').error_message__c;
                    opportunity.Sep_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Oct_Usage__c > 10000){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000014').error_message__c;
                    opportunity.Oct_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Nov_Usage__c > 10000){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000014').error_message__c;
                    opportunity.Nov_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.Dec_Usage__c > 10000){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000014').error_message__c;
                    opportunity.Dec_Usage__c.adderror(errorMessage);
                    return null;
                 }
                 if(opportunity.StageName=='9. Closed Lost' && opportunity.Opportunity_Status__c==null){
                System.debug('====');
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Closed Reason: You Must enter a value' ));
                return null;
                }  
                if((contactObj.Phone != null && contactObj.Phone.length() < 9)||(contactObj.Phone != null && contactObj.Phone.length() < 14 && contactObj.Phone.length() > 9) ){ 
                    //    errorMessage = 'Invalid phone number';
                   /* Exception expObj = new BaseException(errorMessage);
                    expObj.setMessage(errorMessage);
                    ApexPages.addMessages(expObj);
                    */
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000015').error_message__c;
                    contactObj.Phone.addError(errorMessage);
                    return null;
                }
                
                if((contactObj.Alternate_Phone__c != null && contactObj.Alternate_Phone__c.length() < 9)||(contactObj.Alternate_Phone__c != null && contactObj.Alternate_Phone__c.length() < 14 && contactObj.Alternate_Phone__c.length() > 9)){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000016').error_message__c;
                    contactObj.Alternate_Phone__c.addError(errorMessage);
                    return null;
                }
            
                //if((contactObj.HomePhone != null && contactObj.HomePhone.length() < 9)||(contactObj.HomePhone != null && contactObj.HomePhone.length() < 14 && contactObj.HomePhone.length() > 9)){
                     //   errorMessage = 'Invalid Alternate phone number';
                  /*  Exception expObj = new BaseException(errorMessage);
                    expObj.setMessage(errorMessage);
                    ApexPages.addMessages(expObj);
                    */
                /*    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000016').error_message__c;
                    contactObj.HomePhone.addError(errorMessage);
                    return null;
                }*/
                /*
                if(contactObj.Phone != null && contactObj.Phone.length() < 14 && contactObj.Phone.length() > 9 ){ 
                        errorMessage = 'Invalid phone number';
                    Exception expObj = new BaseException(errorMessage);
                    expObj.setMessage(errorMessage);
                    ApexPages.addMessages(expObj);                    
                    contactObj.Phone.addError('Invalid phone number');
                    return null;
                }
                */
                /*
                if(contactObj.HomePhone != null && contactObj.HomePhone.length() < 14 && contactObj.HomePhone.length() > 9){
                        errorMessage = 'Invalid Alternate phone number';
                    Exception expObj = new BaseException(errorMessage);
                    expObj.setMessage(errorMessage);
                    ApexPages.addMessages(expObj);
                    return null;
                }
                */
                //validateAddress();
                if(opportunity != null){
                    if(editOppty == false){
                //accountObj.BillingStreet = opportunity.Street__c;
                //accountObj.BillingCity = opportunity.city__c;
                accountObj.BillingState = accountObj.state__c;
                accountObj.BillingCountry = 'USA';    
                accountObj.Phone=contactObj.Phone;           
                //accountObj.BillingPostalCode = opportunity.zip_code__c;
                accountObj.name = accountObj.BillingStreet + '-' + accountObj.BillingPostalCode;
                //accountObj.Zip_6__c = Zip6Val;
                //accountObj.CDYNE_Status__c = AddValidStateVal;                
                insert accountObj;
        
                contactObj.AccountId = accountObj.Id;
                //contactObj.Firstname = Opportunity.Homeowner_First_Name__c;
                //contactObj.Lastname = Opportunity.Homeowner_Last_Name__c;
                //contactObj.Email = Opportunity.Homeowner_Email__c;
                contactObj.MailingStreet = accountObj.BillingStreet;
                contactObj.MailingCity = accountObj.BillingCity;
                contactObj.MailingState = accountObj.BillingState;
                contactObj.MailingCountry = 'USA';
                contactObj.MailingPostalCode = accountObj.BillingPostalCode;
                //Opportunity.Alternate_Phone__c = contactObj.Alternate_Phone__c;                
                //contactObj.OtherPhone = Opportunity.Alternate_Phone__c;
                //contactObj.Phone = Opportunity.phone__c;
                // contactObj.HasOptedOutOfEmail = Opportunity.Email_Opt_Out__c;
                insert contactObj;
                
                if(RecordTypeId != null && RecordTypeId != ''){
                    opportunity.RecordTypeId = RecordTypeId;
                }
                
                
                opportunity.name = accountObj.name;
                //opportunity.Lead_transfer_method__c = 'Warm transfer + email';
                opportunity.AccountId = accountObj.Id;
                
                opportunity.Zip_6__c = accountObj.Zip_6__c;
                opportunity.CDYNE_Status__c = accountObj.CDYNE_Status__c;
                opportunity.StageName = 'Referral of partner';
                if(loginContact != null){
                        opportunity.Sales_Representative__c = loginContact.id;
                }
                opportunity.Partner_Notes__c = PartnerNotes;
                opportunity.Homeowner_Full_Name__c = contactObj.Firstname + ' ' + contactObj.Lastname;
                opportunity.Homeowner_First_Name__c = contactObj.Firstname;
                opportunity.Homeowner_Last_Name__c = contactObj.Lastname;
                opportunity.Homeowner_Email__c = contactObj.Email;
              //  opportunity.Phone__c = contactObj.Phone;
              //  opportunity.Alternate_Phone__c = contactObj.Otherphone;
                opportunity.Street__c = accountObj.BillingStreet;
                opportunity.City__c = accountObj.BillingCity;
                opportunity.State__c = accountObj.BillingState;
                opportunity.Zip_Code__c = accountObj.BillingPostalCode;              
                 insert opportunity;
                
                OppyContactRole.ContactId = contactObj.id;
                OppyContactRole.OpportunityId = opportunity.id;
                OppyContactRole.Role = 'Homeowner';
                OppyContactRole.isPrimary = true;
                insert OppyContactRole;
        
                Set<Id> optyIds = new Set<Id>();
                optyIds.add(opportunity.Id);
                //ProposalUtil.updateOpportunityOwner(optyIds);
                }else{
                    if(editOppty == true)
                    {
                        
                        Set<Id> optyIds = new Set<Id>();
                        Map<Id, Boolean> contractResultMap = new Map<Id, Boolean>();
                        if(opportunity.Id != null){
                            optyIds.add(opportunity.Id);
                            contractResultMap = ServiceContractUtil.checkForCompletedServiceContracts('Opportunity', optyIds);
                        }
                        Boolean addressChanged = false;
                        Boolean contactChanged = false;
                        if(accountObj != null){
                            addressChanged = AccountUtil.isAddressInformationChanged(accountObj, oldaccountObj);
                        }
                        if(contactObj != null){
                            contactChanged = ContactUtil.isContactInfoChanged(contactObj, oldcontactObj);
                        }
                        
                        //validateAddress();
                        if(accountObj != null){
                            //accountObj.Zip_6__c = Zip6Val;
                            //accountObj.CDYNE_Status__c = AddValidStateVal;
                            accountObj.name = accountObj.BillingStreet + '-' + accountObj.BillingPostalCode;
                            accountObj.BillingState = accountObj.state__c;
                            accountObj.Phone=contactObj.Phone;
                            if(!accountObj.Address_Standardization_Override__c ){
                                Account oldAcc=[select id,billingstreet,billingcity,billingpostalcode,billingstate,Latitude__c,Longitude__c,Address_Standardization_Status__c from account where id=:accountObj.id];
                                if((oldAcc.billingstreet!=accountObj.billingstreet||oldAcc.billingcity!=accountObj.billingcity||oldAcc.billingstate!=accountObj.billingstate||oldAcc.billingpostalcode!=accountObj.billingpostalcode)&&(oldAcc.latitude__c==accountObj.latitude__c&&oldAcc.longitude__c==accountObj.longitude__c)){
                                        accountObj.Address_Standardization_Override__c=true;
                                } 
                            }
                            if(addressChanged == true){
                                if(contractResultMap.containsKey(opportunity.Id)){
                                    Boolean result = contractResultMap.get(opportunity.Id);
                                    if(result == true){
                                        String errormessage = SunrunErrorMessage.getErrorMessage('ERROR_000019').error_message__c;                              
                                        Exception expObj = new BaseException(errorMessage);
                                        expObj.setMessage(errorMessage);
                                        ApexPages.addMessages(expObj);
                                        return null; 
                                    }                               
                                }
                            }
                          
                            if(oldaccountObj != null && addressChanged == true){
                                optyIds.add(opportunity.Id);
                                Map<Id, Map<Id, Proposal__C>> activeProposals = ProposalUtil.getActiveProposalsForOpportunities(optyIds);
                                if(activeProposals != null && !activeProposals.isempty() && accountObj.Void_Proposals__c != true){
                                    enableConfirmSave = true;
                                    isAddressChange = true;
                                    errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000020').error_message__c;
                                    Exception expObj = new BaseException(errorMessage);
                                    expObj.setMessage(errorMessage);
                                    ApexPages.addMessages(expObj);
                                    System.debug('Inside error1');
                                    return null;                                        
                                }
                                
                                if(activeProposals != null && activeProposals.isempty() && accountObj.Void_Proposals__c == true){
                                    accountObj.Void_Proposals__c = false;
                                }
                            }
                            update accountObj;
                        }

                        if(contactObj != null){
                            if(contactChanged == true){
                                if(contractResultMap.containsKey(opportunity.Id)){
                                    Boolean result = contractResultMap.get(opportunity.Id);
                                    if(result == true){
                                        String errormessage = SunrunErrorMessage.getErrorMessage('ERROR_000019').error_message__c;                              
                                        Exception expObj = new BaseException(errorMessage);
                                        expObj.setMessage(errorMessage);
                                        ApexPages.addMessages(expObj);
                                        return null; 
                                    }                               
                                }
                            }

                            if(oldcontactObj != null && contactChanged == true){
                                optyIds.add(opportunity.Id);
                                Map<Id, Map<Id, Proposal__C>> activeProposals = ProposalUtil.getActiveProposalsForOpportunities(optyIds);
                                if(activeProposals != null && !activeProposals.isEmpty()
                                    && contactObj.Void_Proposals__c != true){
                                    enableConfirmSave = true;
                                    isNameChange = true;
                                    errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000020').error_message__c;
                                    Exception expObj = new BaseException(errorMessage);
                                    expObj.setMessage(errorMessage);
                                    ApexPages.addMessages(expObj);
                                    return null;                                        
                                }
                                if(activeProposals != null && activeProposals.isEmpty() && contactObj.Void_Proposals__c == true){
                                    contactObj.Void_Proposals__c = false;   
                                }
                            }
                            update contactObj;
                        }
                        
                        String reason = '';        
                        if(oldOpportunity != null){
                            Map<Id, String> resultMap = OpportunityUtil.isUtilityInformationChanged(opportunity, oldOpportunity);
                            if(contractResultMap.containsKey(opportunity.Id) && resultMap.containsKey(opportunity.Id)){
                                Boolean result = contractResultMap.get(opportunity.Id);
                                if(result == true){
                                    String errormessage = SunrunErrorMessage.getErrorMessage('ERROR_000019').error_message__c;                              
                                    Exception expObj = new BaseException(errorMessage);
                                    expObj.setMessage(errorMessage);
                                    ApexPages.addMessages(expObj);
                                    return null; 
                                }                               
                            }                   
                            
                            if(resultMap.containsKey(opportunity.Id)){
                                optyIds.add(opportunity.Id);
                                Map<Id, Map<Id, Proposal__C>> activeProposals = ProposalUtil.getActiveProposalsForOpportunities(optyIds);
                                if(activeProposals != null && !activeProposals.isEmpty() && opportunity.Void_Proposals__c != true){
                                    enableConfirmSave = true;
                                    errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000020').error_message__c;             
                                    Exception expObj = new BaseException(errorMessage);
                                    expObj.setMessage(errorMessage);
                                    ApexPages.addMessages(expObj);
                                    return null;                                        
                                }
                                
                                if(activeProposals != null && activeProposals.isEmpty() && opportunity.Void_Proposals__c == true){
                                    opportunity.Void_Proposals__c = false;
                                }
                            }
                        }   
                         
                        opportunity.Zip_6__c = accountObj.Zip_6__c;
                        opportunity.CDYNE_Status__c = accountObj.CDYNE_Status__c;
                        If(PartnerNotes != Null){
                            opportunity.Partner_Notes__c = PartnerNotes;
                        }
                        
                        opportunity.name = accountObj.name;   
                        opportunity.Homeowner_Full_Name__c = contactObj.Firstname + ' ' + contactObj.Lastname;
                        opportunity.Homeowner_First_Name__c = contactObj.Firstname;
                        opportunity.Homeowner_Last_Name__c = contactObj.Lastname;
                        opportunity.Homeowner_Email__c = contactObj.Email;
                        //opportunity.Phone__c = contactObj.Phone;
                        //opportunity.alternate_phone__c=contactObj.OtherPhone;
                        opportunity.Street__c = accountObj.BillingStreet;
                        opportunity.City__c = accountObj.BillingCity;
                        opportunity.State__c = accountObj.BillingState;
                        opportunity.Zip_Code__c = accountObj.BillingPostalCode;
                        update opportunity;
                   }
                }
              }
            if(opportunity.Energy_Storage_Applicable__c == true)
            {   
                   energyStorage.Opportunity__c = opportunity.Id;
                   //insert energyStorage;
                  // if(Iscloned)
                   //  energyStorage.Id=null;
                    Upsert energyStorage;
            }else{
                if(energyStorage.Id !=null)
                {
                   delete energyStorage;
                } 
            List<SR_Attachment__c> lstSrattachment = [Select Id,Active__c,Opportunity__c,Document_Type_Name__c from SR_Attachment__c where Opportunity__c=: OpptyId];
            System.debug('##This is###:'+ lstSrattachment);   
            If(lstSrattachment !=null && lstSrattachment.size()>0)
                {
                   for(SR_Attachment__c lstofSrAttachments:lstSrattachment)
                   {
                      If( (lstofSrAttachments.Active__c==True) && (lstofSrAttachments.Document_Type_Name__c=='MOU') )
                      {
                           lstofSrAttachments.Active__c=False;
                           Update lstofSrAttachments;
                          System.debug('##This is###:'+ lstofSrAttachments.Active__c);
                      }
                      
                   }   
                } 
            }
            String urlString = baseURL+'/apex/partneropportunitycreate?id=' + opportunity.Id;
            PageReference pageRef = new PageReference( urlString);
            return pageRef;
        }catch(DMLException exceptionObj){
            
          if(exceptionObj.getDmlStatusCode(0) == 'FIELD_CUSTOM_VALIDATION_EXCEPTION' 
            && exceptionObj.getDmlMessage(0).contains('Modifying the Name, Address, Utility') ){
        enableConfirmSave = true;
      }else{
        ApexPages.addMessages(exceptionObj);
      }
      System.debug('End: ' +  ApexPages.getMessages());
      return null;                
        }catch(Exception exceptionObj){
          System.debug('From Exception ....');
            ApexPages.addMessages(exceptionObj);
            return null;                
        }     
    }


    public PageReference cancel() {
       /* if(retURL == null || retURL == ''){
            retURL = '/partner/OpportunitySearch?retURL=';
        }
        PageReference pageRef = new PageReference( retURL);
        return pageRef;  */
        
         if(editOppty == false){
            PageReference pr=new PageReference(parentURL);
            pr.setRedirect(true);
            return pr;
        }
        if(editOppty == true){
            PageReference pr=new PageReference('/apex/partneropportunitycreate?id=' + OpptyId);
            pr.setRedirect(true);
            return pr;
        }
        return null;
    
    }
    
//     public Void calculateMonUsage(){
//        if(accountObj.state__c == null || accountObj.state__c == ''){
//           /* errorMessage = 'Please enter state to calculate the monthly kwh usage';
//            Exception expObj = new BaseException(errorMessage);
//            expObj.setMessage(errorMessage);
//            ApexPages.addMessages(expObj);
//            */
//            accountObj.state__c.addError('Please enter state to calculate the monthly kwh usage');            
//            
//        }else if(opportunity.Average_Monthly_Electric_Bill__c == null){
//           /* errorMessage = 'Please enter Average Monthly Electric Bill to calculate the monthly kwh usage';
//            Exception expObj = new BaseException(errorMessage);
//            expObj.setMessage(errorMessage);
//            ApexPages.addMessages(expObj);
//            */
//           opportunity.Average_Monthly_Electric_Bill__c.addError('Please enter Average Monthly Electric Bill to calculate the monthly kwh usage');            
            
//        }else {
        
//        Decimal monthlyUsage;
//        List<Average_kWh_by_State__c> AveragekwhList = [Select id,Name,kwh__c from Average_kWh_by_State__c where Name =:accountObj.state__c limit 1];
//        if(AveragekwhList.size() > 0)
//        {
//            Average_kWh_by_State__c Averagekwh = AveragekwhList[0];
        
        
//        monthlyUsage = opportunity.Average_Monthly_Electric_Bill__c/Averagekwh.kwh__c;
//        system.debug('monthlyUsage' + monthlyUsage);
        
//        }else if(AveragekwhList.size() == 0){
//            Average_kWh_by_State__c AveragekwhOther = [Select id,Name,kwh__c from Average_kWh_by_State__c where Name = 'Other' limit 1];
//            monthlyUsage = opportunity.Average_Monthly_Electric_Bill__c/AveragekwhOther.kwh__c;
//            system.debug('monthlyUsage' + monthlyUsage);
//        }
        
        
//        if(monthlyUsage != null){
//            opportunity.Jan_Usage__c = monthlyUsage.intvalue();
//            opportunity.Feb_Usage__c = monthlyUsage.intvalue();
//            opportunity.Mar_Usage__c = monthlyUsage.intvalue();
//            opportunity.Apr_Usage__c = monthlyUsage.intvalue();
//            opportunity.May_Usage__c = monthlyUsage.intvalue();
//            opportunity.Jun_Usage__c = monthlyUsage.intvalue();
//            opportunity.Jul_Usage__c = monthlyUsage.intvalue();
//            opportunity.Aug_Usage__c = monthlyUsage.intvalue();
//            opportunity.Sep_Usage__c = monthlyUsage.intvalue();
//            opportunity.Oct_Usage__c = monthlyUsage.intvalue();
//            opportunity.Nov_Usage__c = monthlyUsage.intvalue();
//            opportunity.Dec_Usage__c = monthlyUsage.intvalue();
//        }
//        }
//    }
    
    public class BaseException extends Exception {}
     /*
    public String description{get;set;}
    public String DeliveryPoint{get;set;}
    public String ZipPlus4{get;set;}
    public String CDYNEStreet{get;set;}
    public String CDYNECity{get;set;}
    public String CDYNEState{get;set;}
    public String CDYNEPostalCode{get;set;}
    public String CDYNEReturnCode{get;set;}   
     public Void validateAddress(){
    // Synchronous calls (from button on page) call this method to return an immediate response to the user.
        //if(editLead == false){
            String XMLResponse = getAddressfromCDYNE(accountObj.BillingStreet, accountObj.BillingCity, accountObj.state__c, accountObj.BillingPostalCode);
            String zipplussix = parse(XMLResponse, getMapCDYNEReturnCodes()); 
            
            
            if(CDYNEReturnCode == '100'){ // All others are "Failure" codes, aka, the ones WE consider as failures as they do not yield a Valid Zip+6
                 AddValidStateVal = 'Success';
                Zip6Val = zipplussix;
                accountObj.BillingStreet = CDYNEStreet;
                accountObj.BillingCity = CDYNECity;
                accountObj.state__c = CDYNEState;
                accountObj.BillingPostalCode = CDYNEPostalCode;
                accountObj.county__c = CDYNECounty;
                accountObj.CDYNE_Address__c = CDYNEStreet + CDYNECity + CDYNEState + CDYNEPostalCode;
            }else{
                  AddValidStateVal  = 'Failure';
                Zip6Val ='';
                accountObj.CDYNE_Address__c = '';
            }
    }
    
    public String getAddressfromCDYNE(String Street, String City, String State, String postalCode){
        // http://pav3.cdyne.com/PavService.svc/help/operations/VerifyAddressAdvanced
       HttpRequest req = new HttpRequest();
       HttpResponse res = new HttpResponse();
       Http http = new Http();
       req.setEndpoint(EndPoint);
       req.setMethod('POST');
       req.setHeader(LicenseKey, LicenseKey);
       req.setHeader('Content-type', 'text/xml;charset=utf-8');
       req.setHeader('SOAPAction', 'VerifyAddressAdvanced');
       //
       String strRequest = '';
       strRequest += '<PavRequest xmlns="pav3.cdyne.com">';
       strRequest += '<CityName>' + City + '</CityName>';
       strRequest += '<FirmOrRecipient></FirmOrRecipient>';
       strRequest += '<LicenseKey>' + LicenseKey + '</LicenseKey>';
       strRequest += '<PrimaryAddressLine>' + Street + '</PrimaryAddressLine>';
       strRequest += '<ReturnCaseSensitive>true</ReturnCaseSensitive>';
       strRequest += '<ReturnCensusInfo>true</ReturnCensusInfo>';
       strRequest += '<ReturnCityAbbreviation>true</ReturnCityAbbreviation>';
       strRequest += '<ReturnGeoLocation>true</ReturnGeoLocation>';
       strRequest += '<ReturnLegislativeInfo>true</ReturnLegislativeInfo>';
       strRequest += '<ReturnMailingIndustryInfo>true</ReturnMailingIndustryInfo>';
       strRequest += '<ReturnResidentialIndicator>true</ReturnResidentialIndicator>';
       strRequest += '<ReturnStreetAbbreviated>true</ReturnStreetAbbreviated>';
       strRequest += '<SecondaryAddressLine></SecondaryAddressLine>';
       strRequest += '<State>' + State + '</State>';
       strRequest += '<Urbanization></Urbanization>';
       strRequest += '<ZipCode>' + postalCode + '</ZipCode>';
       strRequest += '</PavRequest>';
       //
       req.setBody(strRequest);
       //
       if(!test.isrunningtest()){
       res = http.send(req);
       }
       //           
       System.Debug(res.getBody());
       System.Debug(res.getStatusCode());   
       System.Debug(res.getStatus());
       //
       return res.getBody();
    }
    
    public Map<String, String> getMapCDYNEReturnCodes(){
    // Used to store a mapping of CDYNE Return Code to the desired Message that is writ to the record accordingly.
        Map<String, String> mapCDYNERetCodes = new Map<String, String>();
        for(CDYNE_Return_Codes__c CRC:[select id, Name, Description__c from CDYNE_Return_Codes__c]){
             mapCDYNERetCodes.put(CRC.Name, CRC.Description__c);
        }
        return mapCDYNERetCodes;
    }
    
    public String parse(String toParse, Map<String, String> mapCDYNEReturnCodes) {
     // Used to parse out the response from CDYNE to get what we need for ZIP+6.
        DOM.Document doc = new DOM.Document();      
        try {
            doc.load(toParse);    
            DOM.XMLNode root = doc.getRootElement();
            String callparser = walkThrough(root);
            if(mapCDYNEReturnCodes.get(CDYNEReturnCode) != null){
                description = mapCDYNEReturnCodes.get(CDYNEReturnCode);
            }
            return  callparser; 
        } catch (System.XMLException e) {  // invalid XML
            System.Debug('XML Error Message: ' + e.getMessage());
            return null;
        }
    }
    
    public String walkThrough(DOM.XMLNode node) {
        String result = '/n';
        //
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            //
            // Get the values from the XML that we need to calculate ZIP+6 
            // and also return the CDYNE Address values.
            //
            if(node.getName() == 'DeliveryPoint')
            {
                DeliveryPoint = node.getText().trim();
            }
            if(node.getName() == 'ZipCode')
            {
                ZipPlus4 = node.getText().trim().replace('-', '');
            }
            if(node.getName() == 'PrimaryDeliveryLine')
            {
                CDYNEStreet = node.getText().trim();
            }
            if(node.getName() == 'PreferredCityName')
            {
                CDYNECity = node.getText().trim();
            }    
            if(node.getName() == 'StateAbbreviation')
            {
                CDYNEState = node.getText().trim();
            }
            if(node.getName() == 'ZipCode')
            {
                CDYNEPostalCode = node.getText().trim();
            } 
            if(node.getName() == 'County')
           {
               CDYNECounty = node.getText().trim();
             }           
            if(node.getName() == 'ReturnCode')
            {
                CDYNEReturnCode = node.getText().trim();
            }
            
            
            for (Dom.XMLNode child: node.getChildElements()) {
                result += walkThrough(child);
            }
        }
        
        if(DeliveryPoint != '' && ZipPlus4 != ''){
            return DeliveryPoint + ZipPlus4;
        }
        return DeliveryPoint + ZipPlus4;  //should never reach here 
    }
    */    
    public Pagereference confirmSubmit(){

        opportunity.Void_Proposals__c = true;
        accountObj.Void_Proposals__c = true;
        contactObj.Void_Proposals__c = true;
        userConfirmed = true;
        return submit();
    }
    
    public boolean hasSRApprovedProposals(){
        boolean result = false;
        if(opportunity != null && opportunity.Id != null){
            String proposalSource = ProposalUtil.BLACK_BIRD;
            String srApproved = EDPUtil.SR_OPS_APPROVED;
            List<Proposal__c> srApprovedProposals = [Select Id, stage__c from Proposal__C where Proposal_Source__c =:proposalSource 
                                                        and Opportunity__c =:opportunity.Id and stage__c =:srApproved];
        
            if(srApprovedProposals != null && !srApprovedProposals.isEmpty()){
                result = true;
            }
        }
        return result;
    }   
    
}