public with sharing class PartnerLeadCreate {
    
    Id newLeadId;
    private String LicenseKey = Label.Cdyne_LicenseKey;           
    private String EndPoint = Label.Cdyne_VerifyAddressAdvanced;
    private Lead oldLead;
    public String title {get;set;}
    public String lastName{get;set;}
    public Lead addLead {get;set;}
    public boolean showEditSec {get; set;}
    public boolean showReadSec {get; set;}
    public boolean showNotes {get; set;}
    public Id leadRecordTypeId {get;set;}
    public String errorMessage{get;set;}
    public String parentURL{get;set;}
    public String refreshURL{get;set;}
    public String baseURL{get;set;}
    public Boolean confirmMode {get;set;}
    public String leadId {get;set;}
    public boolean editLead {get; set;}
    public List<Notes__c> noteObj;
    public String PartnerNotes{get;set;}
    public String AddValidStateVal{get;set;}
    public String Zip6Val{get;set;}
    public String description{get;set;}
    public List<Design_Option__c> desOptionObj;
    //
    public String DeliveryPoint{get;set;}
    public String ZipPlus4{get;set;}
    public String CDYNEStreet{get;set;}
    public String CDYNECity{get;set;}
    public String CDYNEState{get;set;}
    public String CDYNEPostalCode{get;set;}
    public String CDYNEReturnCode{get;set;}
    //To Store LegislativeInfo and GeoLocationInfo
    public String CDYNECongressDistrictNumber{get;set;}
    public String CDYNEStateLegislativeUpper{get;set;}
    public String CDYNEStateLegislativeLower{get;set;}
    public String CDYNEFromlongitude{get;set;}
    public String CDYNEFromLatitude{get;set;}
    public String CDYNEToLongitude{get;set;}
    public String CDYNEToLatitude{get;set;}
    public String CDYNEAvgLongitude{get;set;}
    public String CDYNEAvgLatitude{get;set;}
    public String CDYNEHasDaylightSavings{get;set;}
    public String CDYNETimeZone{get;set;}
    public String CDYNEAreaCode{get;set;}
    public String CDYNECounty{get;set;}
    public Boolean onSaveCalculateUse {get;set;}
    Public List<String> utilitiesList;
    public User currentUser;
    public Boolean isAEEUser;
     
    public PartnerLeadCreate(ApexPages.StandardController stdController){
        title = 'New Lead';
        intializeLeadRecordTypeId();
        isAEEUser=false;
        getCurrentUser();
        errorMessage = '';
        if(addLead == null){
            addLead = new Lead();
            addLead.Street = '';
            addLead.City = '';
            addLead.State__c = '';
            addLead.postalCode = '';
            addLead.country = '';
            
        }
        
        leadId = System.currentPageReference().getParameters().get('leadId');
        System.debug('contactId: ' + leadId);
        
        showEditSec = true;
        showReadSec = false;
        confirmMode = false;
        showNotes = false;
        
        //Building Parent URL
        baseURL = EDPUtil.getBaseURL();
        parentURL = baseURL + '/apex/LeadSearch?retURL=';
        refreshURL = '';
        init();

    }
    
    public PartnerLeadCreate(){
        addLead = new Lead();
        confirmMode = false;
        init();
    }
    private void getCurrentUser(){
        currentUser=[select defaultdivision from user where id=:userinfo.getuserid()];
        getisAEEUser();
    }
    public boolean getisAEEUser(){
        isAEEUser = String.valueof(currentUser.defaultdivision).contains(System.label.AEE_label)?True:False;
        return isAEEUser;
    }
    public List<Notes__c> getLeadNotes()
    {
        if(editLead == false){
            return null;
        }else if(editLead == true){
        noteObj = [Select n.Lead__c, n.Notes__c, n.Id , n.createdDate, n.CreatedById,
                    n.LastModifiedDate, n.LastModifiedById,n.Notes_Added_By__c From Notes__c n Where n.Lead__c = :leadId ];
        return noteObj; 
        }
        return noteObj;
    }
    
    private void intializeLeadRecordTypeId(){
        if(leadRecordTypeId == null){
            List<RecordType> recordTypeObjs = [select Id, Name, SobjectType from RecordType where SObjectType = 'Lead' and name = 'Partner Leads' limit 1 ];
            if(recordTypeObjs != null && recordTypeObjs.size() > 0){
                leadRecordTypeId = recordTypeObjs[0].Id;
            }           
        }
    }
    
    public Pagereference saveLead(){
    try{
        confirmMode = false;
        onSaveCalculateUse = false;
        errorMessage = '';          
       /* if(addLead.email == null || addLead.FirstName == null || addLead.lastName == null || addLead.Phone == null){                   
            errorMessage = 'Please enter values for the required fields';
            Exception expObj = new BaseException(errorMessage);
            expObj.setMessage(errorMessage);
            ApexPages.addMessages(expObj);
            addLead.FirstName.addError('First Name is Required');
            return null;
        }
        */
        if(addLead.email == null&&addLead.Phone == null){          
            //addLead.phone.addError('Phone or Email is required');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Phone or Email is required'));
            return null;
        }
        if(addLead.FirstName == null){          
            addLead.FirstName.addError('You must enter a value');
            return null;
        }
        if(addLead.LastName == null){           
            addLead.LastName.addError('You must enter a value');
            return null;
        }
        /*if(addLead.Phone == null){          
            addLead.Phone.addError('You must enter a value');
            return null;
        }
        */
        if(addLead.Average_Monthly_Electric_Bill__c != null && addLead.Average_Monthly_Electric_Bill__c < 50 && addLead.Average_Monthly_Electric_Bill__c != 0){
            /*errorMessage = 'Average Monthly Electric Bill should be $50 or greater';
            Exception expObj = new BaseException(errorMessage);
            expObj.setMessage(errorMessage);
            ApexPages.addMessages(expObj);*/
            addLead.Average_Monthly_Electric_Bill__c.addError('Average Monthly Electric Bill should be $50 or greater');
            return null;
        }
          /*
        if(addLead.Jan_Usage__c < 0 || addLead.Feb_Usage__c < 0 || addLead.Mar_Usage__c < 0 || addLead.Apr_Usage__c < 0 || addLead.May_Usage__c < 0 || 
           addLead.Jun_Usage__c < 0 ||  addLead.Jul_Usage__c < 0 ||  addLead.Aug_Usage__c < 0 || addLead.Sep_Usage__c < 0 || addLead.Oct_Usage__c < 0 ||  
           addLead.Nov_Usage__c < 0 ||  addLead.Dec_Usage__c < 0 ) {          
            errorMessage = 'Negative values not allowed on Monthly kwh use';
            Exception expObj = new BaseException(errorMessage);
            expObj.setMessage(errorMessage);            
            ApexPages.addMessages(expObj);           
            
            return null;
           } 
            */
         /*   
         if(addLead.Jan_Usage__c < 0){ 
         String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000012').error_message__c;         
         addLead.Jan_Usage__c.addError(errorMessage);
         return null;
         }
         else if(addLead.Feb_Usage__c < 0){
         String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000012').error_message__c; 
         addLead.Feb_Usage__c.addError(errorMessage);
         return null;
         }
         else if(addLead.Mar_Usage__c < 0){
         String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000012').error_message__c; 
         addLead.Mar_Usage__c.addError(errorMessage);
         return null;
         }
         else if(addLead.Apr_Usage__c < 0){
         String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000012').error_message__c; 
         addLead.Apr_Usage__c.addError(errorMessage);
         return null;
         }
         else if(addLead.May_Usage__c < 0){
         String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000012').error_message__c; 
         addLead.May_Usage__c.addError(errorMessage);
         return null;
         }
         else if(addLead.Jun_Usage__c < 0){
         String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000012').error_message__c; 
         addLead.Jun_Usage__c.addError(errorMessage);
         return null;
         }
         else if(addLead.Jul_Usage__c < 0){
         String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000012').error_message__c; 
         addLead.Jul_Usage__c.addError(errorMessage);
         return null;
         }
         else if(addLead.Aug_Usage__c < 0){
         String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000012').error_message__c; 
         addLead.Aug_Usage__c.addError(errorMessage);
         return null;
         }
         else if(addLead.Sep_Usage__c < 0){
         String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000012').error_message__c; 
         addLead.Sep_Usage__c.addError(errorMessage);
         return null;
         }
         else if(addLead.Oct_Usage__c < 0){
         String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000012').error_message__c; 
         addLead.Oct_Usage__c.addError(errorMessage);
         return null;
         }
         else if(addLead.Nov_Usage__c < 0){
         String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000012').error_message__c; 
         addLead.Nov_Usage__c.addError(errorMessage);
         return null;
         }
         else if(addLead.Dec_Usage__c < 0){
         String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000012').error_message__c; 
         addLead.Dec_Usage__c.addError(errorMessage);
         return null;
         } 
         */
         if(addLead.Jan_Usage__c > 10000){         
         String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000014').error_message__c; 
         addLead.Jan_Usage__c.addError(errorMessage);
         return null;
         }
         else if(addLead.Feb_Usage__c > 10000){
         String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000014').error_message__c; 
         addLead.Feb_Usage__c.addError(errorMessage);
         return null;
         }
         else if(addLead.Mar_Usage__c > 10000){
         String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000014').error_message__c; 
         addLead.Mar_Usage__c.addError(errorMessage);
         return null;
         }
         else if(addLead.Apr_Usage__c > 10000){
         String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000014').error_message__c; 
         addLead.Apr_Usage__c.addError(errorMessage);
         return null;
         }
         else if(addLead.May_Usage__c > 10000){
         String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000014').error_message__c; 
         addLead.May_Usage__c.addError(errorMessage);
         return null;
         }
         else if(addLead.Jun_Usage__c > 10000){
         String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000014').error_message__c; 
         addLead.Jun_Usage__c.addError(errorMessage);
         return null;
         }
         else if(addLead.Jul_Usage__c > 10000){
         String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000014').error_message__c; 
         addLead.Jul_Usage__c.addError(errorMessage);
         return null;
         }
         else if(addLead.Aug_Usage__c > 10000){
         String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000014').error_message__c; 
         addLead.Aug_Usage__c.addError(errorMessage);
         return null;
         }
         else if(addLead.Sep_Usage__c > 10000){
         String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000014').error_message__c; 
         addLead.Sep_Usage__c.addError(errorMessage);
         return null;
         }
         else if(addLead.Oct_Usage__c > 10000){
         String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000014').error_message__c; 
         addLead.Oct_Usage__c.addError(errorMessage);
         return null;
         }
         else if(addLead.Nov_Usage__c > 10000){
         String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000014').error_message__c; 
         addLead.Nov_Usage__c.addError(errorMessage);
         return null;
         }
         else if(addLead.Dec_Usage__c > 10000){
         String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000014').error_message__c; 
         addLead.Dec_Usage__c.addError(errorMessage);
         return null;
         }  
         /* 
         if(((addLead.Jan_Usage__c == null && addLead.Feb_Usage__c == null && addLead.Mar_Usage__c == null && addLead.Apr_Usage__c == null && addLead.May_Usage__c == null
            && addLead.Jun_Usage__c == null && addLead.Jul_Usage__c == null && addLead.Aug_Usage__c == null && addLead.Sep_Usage__c == null && addLead.Oct_Usage__c == null 
            && addLead.Nov_Usage__c == null && addLead.Dec_Usage__c== null ) || (addLead.Jan_Usage__c == 0 && addLead.Feb_Usage__c == 0 && addLead.Mar_Usage__c == 0 && addLead.Apr_Usage__c == 0 && addLead.May_Usage__c == 0
            && addLead.Jun_Usage__c == 0 && addLead.Jul_Usage__c == 0 && addLead.Aug_Usage__c == 0 && addLead.Sep_Usage__c == 0 && addLead.Oct_Usage__c == 0 
            && addLead.Nov_Usage__c == 0 && addLead.Dec_Usage__c== 0 ) ) && (addLead.Average_Monthly_Electric_Bill__c != null && addLead.Average_Monthly_Electric_Bill__c != 0))  {
            system.debug('onSaveCalculateUse : ' + onSaveCalculateUse);
            onSaveCalculateUse = true;
//            calculateMonUsage();
           }
           */ 
         /*
         if(addLead.Jan_Usage__c  > 10000 || addLead.Feb_Usage__c > 10000 || addLead.Mar_Usage__c > 10000 || addLead.Apr_Usage__c > 10000 || addLead.May_Usage__c > 10000
            || addLead.Jun_Usage__c > 10000 || addLead.Jul_Usage__c > 10000 || addLead.Aug_Usage__c > 10000 || addLead.Sep_Usage__c > 10000 || addLead.Oct_Usage__c > 10000 
            || addLead.Nov_Usage__c > 10000 || addLead.Dec_Usage__c > 10000) {
            
            errorMessage = 'Maximum monthly use is 10,000 kWh';
            Exception expObj = new BaseException(errorMessage);
            expObj.setMessage(errorMessage);
            ApexPages.addMessages(expObj);
            return null;
           } 
         */
           
        if((addlead.Phone != null && addlead.Phone.length() < 9)){
            /*
            errorMessage = 'Invalid phone number';
            Exception expObj = new BaseException(errorMessage);
            expObj.setMessage(errorMessage);
            ApexPages.addMessages(expObj);
            */
            String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000015').error_message__c;  
            addLead.Phone.addError(errorMessage);
            return null;
        }
        
        if(addlead.Alternate_Phone__c != null && addlead.Alternate_Phone__c.length() < 9){
            /*
            errorMessage = 'Invalid alternate phone number';
            Exception expObj = new BaseException(errorMessage);
            expObj.setMessage(errorMessage);
            ApexPages.addMessages(expObj);
            */
            String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000016').error_message__c;  
            addLead.Alternate_Phone__c.addError(errorMessage);
            return null;
        }
        if(addlead.MobilePhone != null && addlead.MobilePhone.length() < 9){
            /*
            errorMessage = 'Invalid alternate phone number';
            Exception expObj = new BaseException(errorMessage);
            expObj.setMessage(errorMessage);
            ApexPages.addMessages(expObj);
            */
            String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000026').error_message__c;  
            addLead.MobilePhone.addError(errorMessage);
            return null;
        }
        
         if(addlead.Phone != null && addlead.Phone.length() < 14 && addlead.Phone.length() > 9) {
           /* errorMessage = 'Invalid  phone number';
            Exception expObj = new BaseException(errorMessage);
            expObj.setMessage(errorMessage);
            ApexPages.addMessages(expObj);
            */
            String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000015').error_message__c;  
            addLead.phone.addError(errorMessage);
            return null;
        }
        
        if((addlead.Alternate_Phone__c != null && addlead.Alternate_Phone__c.length() < 14 && addlead.Alternate_Phone__c.length() > 9)){
            /*errorMessage = 'Invalid alternate phone number';
            Exception expObj = new BaseException(errorMessage);
            expObj.setMessage(errorMessage);
            ApexPages.addMessages(expObj);
            */
            String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000016').error_message__c;  
            addLead.Alternate_Phone__c.addError(errorMessage);
            return null;
        }
        if((addlead.MobilePhone != null && addlead.MobilePhone.length() < 14 && addlead.MobilePhone.length() > 9)){
            /*errorMessage = 'Invalid alternate phone number';
            Exception expObj = new BaseException(errorMessage);
            expObj.setMessage(errorMessage);
            ApexPages.addMessages(expObj);
            */
            String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000026').error_message__c;  
            addLead.MobilePhone.addError(errorMessage);
            return null;
        }
        /*if(addlead.Utility_Company__c == null){
            errorMessage = 'Please enter Utility Company';
            Exception expObj = new BaseException(errorMessage);
            expObj.setMessage(errorMessage);
            ApexPages.addMessages(expObj);
            return null;
        }*/
        
        if((addLead.Street != null || addLead.Street != '') && 
           (addLead.PostalCode != null || addLead.PostalCode != '')) {
                validateAddress();
           }
        if(leadId!=null&&!addLead.Address_Standardization_Override__c){
            System.debug('---->old Lead');
            oldLead=[select id,street,city,state,postalcode,latitude__c,longitude__c from lead where id=:leadId];
            if((oldLead.street!=addLead.street||oldLead.city!=addLead.city||addLead.state!=oldLead.state||addLead.postalcode!=oldLead.postalcode)&&(oldLead.latitude__c==addLead.latitude__c&&oldLead.longitude__c==addLead.longitude__c)){
               addLead.Address_Standardization_Override__c=true;    
            }
        }
        if(addLead != null){
            if(editLead == false){
                
                addLead.RecordTypeId = leadRecordTypeId;
                addLead.Company = addLead.LastName + ',' + addLead.FirstName;
                addLead.Country = 'USA';
                addLead.State = addLead.State__c;
                addLead.Partner_Notes__c = PartnerNotes;
                addLead.Zip_6__c = Zip6Val;
                addLead.CDYNE_Status__c = AddValidStateVal;
                addLead.CDYNE_Result__c = description;
                addLead.CDYNE_Address__c = CDYNEStreet+CDYNECity+CDYNEState+CDYNEPostalCode;
                if(AddValidStateVal == 'Success'){
                    addLead.Street = CDYNEStreet;
                    addLead.City = CDYNECity;
                    addLead.State__c = CDYNEState;
                    addLead.PostalCode = CDYNEPostalCode;
                }
                
                addLead.CongressDistrictNumber__c = CDYNECongressDistrictNumber;
                addLead.StateLegislativeUpper__c = CDYNEStateLegislativeUpper;
                addLead.StateLegislativeLower__c = CDYNEStateLegislativeLower;
                addLead.FromLongitude__c = CDYNEFromlongitude;
                addLead.FromLatitude__c = CDYNEFromLatitude;
                addLead.ToLongitude__c = CDYNEToLongitude;
                addLead.ToLatitude__c = CDYNEToLatitude;
                addlead.AvgLongitude__c = CDYNEAvgLongitude;
                addLead.AvgLatitude__c = CDYNEAvgLatitude;
                addlead.HasDaylightSavings__c = CDYNEHasDaylightSavings;
                addlead.TimeZone__c = CDYNETimeZone;
                addLead.AreaCode__c = CDYNEAreaCode;
                insert addLead;
                
                system.debug('Lead Created:' + addLead);
                //newLeadId = [select id from Lead where id =: addLead.id].id;
                newLeadId=addLead.id;
                
            }else{
                If(PartnerNotes != Null){
                    addLead.Partner_Notes__c = PartnerNotes;
                }
                
                addLead.Zip_6__c = Zip6Val;
                addLead.CDYNE_Status__c = AddValidStateVal;
                addLead.State = addLead.State__c;
                update addLead;
            }
        }
        if(currentUser.defaultdivision!=null && String.valueof(currentUser.defaultdivision).contains(System.label.AEE_label) && editLead==false){
            
            PageReference pr=doConvert();
            if(pr!=null){
                pr.setRedirect(true);
                return pr; 
            }
        }
        confirmMode = true;
        if(confirmMode == true && editLead == false){
            Pagereference ref = new PageReference('/apex/CustomizeLeadDetailPage?Id=' + newLeadId);
            refreshURL = baseURL + '/apex/CustomizeLeadDetailPage?Id=' + newLeadId;
            ref.setRedirect(true);  
            return ref;
        }
        
          if(confirmMode == true && editLead == true){
            Pagereference ref = new PageReference('/apex/CustomizeLeadDetailPage?Id=' + leadId);
            refreshURL = baseURL + '/apex/CustomizeLeadDetailPage?Id=' + leadId;
            ref.setRedirect(true);  
            return ref;
        }
        return null;
    }catch(Exception exceptionObj){
            ApexPages.addMessages(exceptionObj);
            return null;                
        }    
    }
    
    public pagereference doConvert(){                           
                String OpptyId;
                try{
                OpptyId = ConvertLead.doConvert(addLead.id);
                }
                Catch(exception e){
                        String expType=e.getTypeName();
                        String errMessage;
                        if(expType=='System.DmlException'||expType=='DmlException'){
                            errMessage=e.getDMLMessage(0);
                        }
                        else{
                            errMessage=e.getMessage();
                        }
                        //showerror=true;
                        ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.FATAL, errMessage);
                        ApexPages.addMessage(errorMessage);            
                        return null;                                
                }
        String urlPath = baseURL+'/apex/PartnerOpportunityCreate?id='+OpptyId;
        PageReference pr = new PageReference(urlPath);
        pr.setRedirect(true);
        return pr; 
    }
    private void init(){
        System.debug('leadId: ' + leadId);
        editLead = false;
        
        Zip6Val = '';
        AddValidStateVal = '';
        DeliveryPoint = '';
        ZipPlus4 = '';
        CDYNEStreet = '';
        CDYNECity = '';
        CDYNEState = '';
        CDYNEPostalCode = '';
        CDYNEReturnCode = '';
        description = '';
        CDYNECongressDistrictNumber = '';
        CDYNEStateLegislativeUpper = '';
        CDYNEStateLegislativeLower = '';
        CDYNEFromlongitude = '';
        CDYNEFromLatitude = '';
        CDYNEToLongitude = '';
        CDYNEToLatitude = '';
        CDYNEAvgLongitude = '';
        CDYNEAvgLatitude = '';
        CDYNEHasDaylightSavings = '';
        CDYNETimeZone = '';
        CDYNEAreaCode = '';
        
        if(leadId != null && leadId != ''){
            title = 'Edit Lead';
            Lead Leadobj = [select id,ownerid,mobilephone,Best_way_to_reach__c,Best_time_to_Contact__c,square_footage__c,county__c,name,email,FirstName,lastName,Street,City,State,State__c,PostalCode,country,Phone,Lead_Organization_Location_2__c,
                            Utility_Company__c,Home_Type__c ,Roofing_Type__c ,Offer_Promo_Name__c ,Sales_rep_of_referrer__c,Offer__c ,SalesRep__c,Age_of_Roof__c ,Installation_Type__c ,HOA__c ,Over_2_stories__c ,Average_Monthly_Electric_Bill__c,Status,LeadSource,Which_SR_product__c,Alternate_Phone__c,HasOptedOutOfEmail,Partner_Notes__c,
                            dt_Product_Type__c,Promotion_Name__c ,Consultation_Date_and_Time__c ,Referral_Input__c ,Consultation_Time__c ,Referred_By_Contact__c,dt_Upfront_Payment__c,Sales_Contact_Method__c,dt_Escalator__c,dt_Turnkey_Price__c,dt_Gross_margin__c,Prospect_Id__c,
                            CDYNE_Status__c, Zip_6__c,CongressDistrictNumber__c,Offer_Promo_Code__c,Promotion_Code__c,StateLegislativeUpper__c,StateLegislativeLower__c,FromLongitude__c,FromLatitude__c,
                            ToLongitude__c,ToLatitude__c ,AvgLongitude__c,AvgLatitude__c,HasDaylightSavings__c,TimeZone__c,AreaCode__c,Territory__c,Lead_Qualifier__c ,
                            Jan_Usage__c,Feb_Usage__c,Mar_Usage__c,Apr_Usage__c,May_Usage__c,Jun_Usage__c,Address_Standardization_Override__c,
                            Jul_Usage__c,Aug_Usage__c,Sep_Usage__c,Oct_Usage__c, Nov_Usage__c,Dec_Usage__c,usage_option__c,Lead_Status__c,Reason__c, Latitude__c, Longitude__c, Address_Standardization_Status__c, Preferred_Language__c,Rate_Schedule__c,Hawaii_NEM_Approved__c 
                            from Lead where id =: leadId limit 1];

            if(Leadobj != null){
                addLead = Leadobj;            
                System.debug('LeadObj : ' + addLead);
                editLead = true;
                showReadSec = true;
            }
        }
        
        if(editLead == true){
            AddValidStateVal = addLead.CDYNE_Status__c;
            Zip6Val = addLead.Zip_6__c;
        }
        
    }
    
    public PageReference doCancel() {
        if(editLead == false){
            PageReference pr=new PageReference(parentURL);
            pr.setRedirect(true);
            return pr;
        }
        if(editLead == true){
            PageReference pr=new PageReference('/apex/CustomizeLeadDetailPage?Id=' + leadId);
            pr.setRedirect(true);
            return pr;
        }
        return null;
    }
    public boolean isLGCYUser{
        get{
            User LGCYUser=[select Contact.account.name from user where id=:userinfo.getuserid() limit 1];
            return (LGCYUser.Contact.account.name.contains('LGCY')||LGCYUser.Contact.account.name.contains('BrightCurrent'));
        }
        set;
    }
    public pageReference validateAddress(){
        //New Address Service Integration
        /*
    // Synchronous calls (from button on page) call this method to return an immediate response to the user.
        //if(editLead == false){
            String XMLResponse = getAddressfromCDYNE(addLead.Street, addlead.City, addLead.State__c, addLead.PostalCode);
            String zipplussix = parse(XMLResponse, getMapCDYNEReturnCodes()); 
            
            
            if(CDYNEReturnCode == '100'){ // All others are "Failure" codes, aka, the ones WE consider as failures as they do not yield a Valid Zip+6
                AddValidStateVal = 'Success';
                Zip6Val = zipplussix;
                addLead.Street = CDYNEStreet;
                addLead.City = CDYNECity;
                addLead.State__c = CDYNEState;
                addLead.PostalCode = CDYNEPostalCode;
                addLead.county__c=CDYNECounty;
            }else{
                AddValidStateVal = 'Failure';
                Zip6Val ='';
            }
         */
    return null;
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
       res = http.send(req);
       //    
       System.Debug('test---->'+res.getBody());       
       System.Debug(res.getBody());
       System.Debug(res.getStatusCode());
       System.Debug(res.getStatus());
       //
       return res.getBody();
    }
    
    /*public class CDYNEInformation{
        String status{get;set;}
        String description{get;set;}
        String street{get;set;}
        String city{get;set;}
        String state{get;set;}
        String postalcode{get;set;}
        String zipplussix{get;set;}

        public CDYNEInformation(Map<String, String> mapReturnCode, String CDYNERet, String zip6, String CStreet, String CCity, String CState, String CZip, String status, String result){
           //
           if(CDYNERet == '100') // All others are "Failure" codes, aka, the ones WE consider as failures as they do not yield a Valid Zip+6
           {
                this.status = 'Success';
           }
           else
           {
                this.status = 'Failure';
           }
           if(mapReturnCode.get(CDYNERet) != null)
           {
               this.description = mapReturnCode.get(CDYNERet);
           }
           this.street = CStreet;
           this.city = CCity;
           this.state = CState;
           this.postalcode = CZip;
           this.zipplussix = zip6;
        }
    }*/
    
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
            if(node.getName() == 'ReturnCode')
            {
                CDYNEReturnCode = node.getText().trim();
            }
            //Getting LegislativeInfo and GeoLocationInfo
    if(node.getName() == 'CongressionalDistrictNumber')
    {
        CDYNECongressDistrictNumber = node.getText().trim();
    }
    if(node.getName() == 'StateLegislativeUpper')
    {
        CDYNEStateLegislativeUpper = node.getText().trim();
        system.debug('StateLegislativeUpper:' + CDYNEStateLegislativeUpper);
    } 
    if(node.getName() == 'StateLegislativeLower')
    {
        CDYNEStateLegislativeLower = node.getText().trim();
    } 
    if(node.getName() == 'Fromlongitude')
    {
        CDYNEFromlongitude = node.getText().trim();
    } 
    if(node.getName() == 'FromLatitude')
    {
        CDYNEFromLatitude = node.getText().trim();
    } 
    if(node.getName() == 'ToLongitude')
    {
        CDYNEToLongitude = node.getText().trim();
    } 
    if(node.getName() == 'ToLatitude')
    {
        CDYNEToLatitude = node.getText().trim();
    } 
    if(node.getName() == 'AvgLongitude')
    {
        CDYNEAvgLongitude = node.getText().trim();
    } 
    if(node.getName() == 'AvgLatitude')
    {
        CDYNEAvgLatitude = node.getText().trim();
    } 
    if(node.getName() == 'HasDaylightSavings')
    {
        CDYNEHasDaylightSavings = node.getText().trim();
    } 
    if(node.getName() == 'TimeZone')
    {
        CDYNETimeZone = node.getText().trim();
    } 
    if(node.getName() == 'AreaCode')
    {
        CDYNEAreaCode = node.getText().trim();
    }
    if(node.getName() == 'County')
    {
        CDYNECounty = node.getText().trim();
    } 
    //
           
            for (Dom.XMLNode child: node.getChildElements()) {
                result += walkThrough(child);
            }
        }
        
        if(DeliveryPoint != '' && ZipPlus4 != ''){
            return DeliveryPoint + ZipPlus4;
        }
        return DeliveryPoint + ZipPlus4;  //should never reach here 
    }
    
    public List<Design_Option__c> getleadDesignOption(){

        if(editLead == false){
            return null;
        }else if(editLead == true){
            desOptionObj = [Select Serial_Number__c, Module__c, Lead__c , KWP__c,
                             KWH__c, KWH_KWP__c,Usage__c,costPerYearkWh__c From Design_Option__c Where Lead__c = :leadId ];
        return desOptionObj;    
        }
        return desOptionObj;
    }
    
//     public pagereference calculateMonUsage(){
//                system.debug('onSaveCalculateUse ' + onSaveCalculateUse);               
//       try{
//        if((addLead.State__c == null || addLead.state__c == '') && onSaveCalculateUse == false){
//            errorMessage = 'Please enter state to calculate the monthly kWh usage';
//            Exception expObj = new BaseException(errorMessage);
//            expObj.setMessage(errorMessage);
//            ApexPages.addMessages(expObj);
            
//        }/*else if(addLead.Average_Monthly_Electric_Bill__c == null){
//            errorMessage = 'Please enter Average Monthly Electric Bill to calculate the monthly kWh usage';
//            Exception expObj = new BaseException(errorMessage);
//            expObj.setMessage(errorMessage);
//            ApexPages.addMessages(expObj);
//            
//        }*/else if((addLead.Average_Monthly_Electric_Bill__c != null && addLead.Average_Monthly_Electric_Bill__c < 50) && onSaveCalculateUse == false){
//            errorMessage = 'Average Monthly Electric Bill should be $50 or greater to calculate monthly kWh use';
//           Exception expObj = new BaseException(errorMessage);
//            expObj.setMessage(errorMessage);
//            ApexPages.addMessages(expObj);
//        }
//        else {
//                if(addLead.State__c != null && addLead.Average_Monthly_Electric_Bill__c != null && addLead.Average_Monthly_Electric_Bill__c != 0){
//                        Decimal monthlyUsage;
//                        List<Average_kWh_by_State__c> AveragekwhList = [Select id,Name,kwh__c from Average_kWh_by_State__c where Name =:addlead.State__c limit 1];
//                        if(AveragekwhList.size() > 0)
//                        {
//                            Average_kWh_by_State__c Averagekwh = AveragekwhList[0];
                        
                        
//                        monthlyUsage = addLead.Average_Monthly_Electric_Bill__c/Averagekwh.kwh__c;
//                        system.debug('monthlyUsage' + monthlyUsage);
                        
//                        }else if(AveragekwhList.size() == 0){
//                            Average_kWh_by_State__c AveragekwhOther = [Select id,Name,kwh__c from Average_kWh_by_State__c where Name = 'Other' limit 1];
//                            monthlyUsage = addLead.Average_Monthly_Electric_Bill__c/AveragekwhOther.kwh__c;
//                            system.debug('monthlyUsage' + monthlyUsage);
//                        }
                        
                        
//                        if(monthlyUsage != null){
//                            addLead.Jan_Usage__c = monthlyUsage.intvalue();
//                            addLead.Feb_Usage__c = monthlyUsage.intvalue();
//                            addLead.Mar_Usage__c = monthlyUsage.intvalue();
//                            addLead.Apr_Usage__c = monthlyUsage.intvalue();
//                            addLead.May_Usage__c = monthlyUsage.intvalue();
//                            addLead.Jun_Usage__c = monthlyUsage.intvalue();
//                            addLead.Jul_Usage__c = monthlyUsage.intvalue();
//                            addLead.Aug_Usage__c = monthlyUsage.intvalue();
//                            addLead.Sep_Usage__c = monthlyUsage.intvalue();
//                            addLead.Oct_Usage__c = monthlyUsage.intvalue();
//                            addLead.Nov_Usage__c = monthlyUsage.intvalue();
//                            addLead.Dec_Usage__c = monthlyUsage.intvalue();
//                        }
//                }                      
//        }
//        return null;
//       }catch(Exception exceptionObj){
//            ApexPages.addMessages(exceptionObj);
//           return null;
//        } 
//    }
    
   
    
    public class BaseException extends Exception {}

}