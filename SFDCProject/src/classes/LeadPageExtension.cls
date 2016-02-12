public with sharing class LeadPageExtension {
public id leadId{set;get;}
public string title{set;get;}
public boolean isCloned{set;get;}
public boolean editMode{set;get;}
public Lead leadObj{set;get;}
public decimal score{set;get;}
public decimal scoreBorder{set;get;}
public String Query;
//public string streetAddress{set;get;}
public boolean ShowScore{set;get;}
public boolean editAddress{set;get;}
public boolean ShowConvertLead{set;get;}
public boolean displayPopup {get; set;} 
//public boolean showerror{get;set;}
public List<LeadHistory> LeadHistoryList{get;set;}
private ApexPages.StandardController sController; 
public LeadPageExtension(ApexPages.StandardController stdController){
            editMode=true;
            editAddress=true;
            //showerror=false;
            LeadHistoryList=new List<LeadHistory>();
            sController=stdController;
                title='New Lead';
                leadId=stdController.getId();
                leadObj=(lead)stdController.getrecord();
                if(leadObj!=null&&leadId!=null){
                        title=leadObj.firstname+' '+leadObj.lastname;                   
                }               
                String edit=ApexPages.currentPage().getParameters().get('LeadEdit');
                if(edit=='false'){
                        editMode=false;
                }
                String IsClone=ApexPages.currentPage().getUrl();
                if(IsClone!=null&&IsClone.contains('clone')){
                        isCloned=true;
                }
                else{
                        isCloned=false;
                }
}       
public pagereference onLoad(){              
                if(leadId!=null){
                        /*Query='select id,lastname,reason__c,MobilePhone,Country,firstname,Warm_Transfer__c,Latitude__c,Longitude__c ,Address_Standardization_Status__c ,Lead_Type__c,Lead_Status__c ,Campaign_Marketo__c ,space_for_solar__c,Best_way_to_reach__c,phone,email,Auto_dialer_Opt_in__c,DoNotCall,HasOptedOutOfEmail,Campaign_ID__c,Campaign_Call_Attempts__c,Verbally_confirmed_700_FICO__c,Future_Contact_Date__c,street,state,state__c,city,postalcode,utility_company__c,';
                                        Query+='Install_Branch_Id__c,territory__c,home_type__c,usage_option__c,square_footage__c,rate_schedule__c,shading__c,Average_Monthly_Electric_Bill__c,Status,Custom_Lead_Source__c,channel__c,program__c,ownerid,lead_qualifier__c,salesrep__c,sales_branch__c,notes__c,Offer_Promo_Name__c,Referred_By_Contact__c,Referred_by_Contact_Email__c,Referred_by_Contact_First_Name__c,Sales_rep_of_referrer__c,';
                                        Query+='Total_Call_Attempts__c,Promotion_Name__c,offer__c,Referral_Input__c,referred_by__c,referral_web_form__c,Lead_Gen_Partner__c,Lead_Organization_Location_2__c,Lead_Generated_by__c,Field_Marketing_Branch__c,Lead_Classification__c,Costco_Location__c,Costco_Member_ID__c,Costco_Member_Type__c,prospect_id__c,Referred_by_Contact_Last_Name__c,Referred_by_Contact_Phone__c,';
                                        Query+='createdbyid,Score__c,createddate,lastmodifiedbyid,lastmodifieddate,sales_partner__c,install_partner__c,market_assignment_sales__c,market_assignment_install__c,Address_Batch_Status__c ,isconverted';
                        Map<String,Lead_Fields__c> map_LeadFlds = Lead_Fields__c.getAll();
                        if(!map_LeadFlds.isempty()){
                                for(String fld:map_LeadFlds.keyset()){
                                        Query+=','+fld;
                                }
                        }*/
                        getquery();
                        Query+=LeadId+'\'';                    
                        leadObj=database.query(Query);
                        LeadHistoryList=[select CreatedBy.name,CreatedDate,Field,LeadId,NewValue,OldValue FROM LeadHistory where leadid=:LeadId];
                        if(leadObj.isconverted){
                        Pagereference ref = new PageReference(URL.getSalesforceBaseUrl().toExternalForm()+'/p/lead/ViewConvertedLead/d?id='+ leadId);
                        ref.setredirect(true);
                        return ref;
                        }
                        if(leadObj.score__c!=null){
                                score=leadObj.score__c*10;
                                scoreBorder=100-score;
                                ShowScore=true;
                        }
                        if(leadObj.street!=null&&leadObj.city!=null&&leadObj.postalcode!=null&&leadObj.usage_option__c!=null&&leadObj.firstname!=null
                           &&leadObj.channel__c!=null&&leadObj.Custom_Lead_Source__c!=null&&(leadObj.phone!=null||leadObj.email!=null)){
                                ShowConvertLead=true;
                           }
                }               
                return null;
}
private string getquery(){
                        Query='select id,Call_Center__c ,lastname,reason__c,MobilePhone,Country,firstname,Warm_Transfer__c,Latitude__c,Longitude__c ,Address_Standardization_Status__c ,Lead_Type__c,Lead_Status__c ,Campaign_Marketo__c ,space_for_solar__c,Best_way_to_reach__c,phone,email,Auto_dialer_Opt_in__c,DoNotCall,HasOptedOutOfEmail,Campaign_ID__c,Campaign_Call_Attempts__c,Verbally_confirmed_700_FICO__c,Future_Contact_Date__c,Future_Contact_Date_Time__c,street,state,state__c,city,postalcode,utility_company__c,';
                                        Query+='Install_Branch_Id__c,territory__c,home_type__c,usage_option__c,square_footage__c,rate_schedule__c,shading__c,Average_Monthly_Electric_Bill__c,Status,Custom_Lead_Source__c,channel__c,program__c,ownerid,lead_qualifier__c,salesrep__c,sales_branch__c,notes__c,Offer_Promo_Name__c,Referred_By_Contact__c,Referred_by_Contact_Email__c,Referred_by_Contact_First_Name__c,Sales_rep_of_referrer__c,Address_Standardization_Override__c,';
                                        Query+='Total_Call_Attempts__c,Promotion_Name__c,offer__c,Referral_Input__c,referred_by__c,referral_web_form__c,Lead_Gen_Partner__c,Lead_Organization_Location_2__c,Lead_Generated_by__c,Field_Marketing_Branch__c,Lead_Classification__c,Costco_Location__c,Costco_Member_ID__c,Costco_Member_Type__c,prospect_id__c,Referred_by_Contact_Last_Name__c,Referred_by_Contact_Phone__c,Roofing_Type__c,';
                                        Query+='createdbyid,Score__c,createddate,lastmodifiedbyid,lastmodifieddate,sales_partner__c,install_partner__c,market_assignment_sales__c,market_assignment_install__c,Address_Batch_Status__c ,isconverted,Preferred_Language__c,Call_Consent__c,Text_Opt_Out__c,Hawaii_NEM_Approved__c';
                        Map<String,Lead_Fields__c> map_LeadFlds = Lead_Fields__c.getAll();
                        if(!map_LeadFlds.isempty()){
                                for(String fld:map_LeadFlds.keyset()){
                                        Query+=','+fld;
                                }
                        }
                        Query+=' from lead where id=\'';
                        return query;
}
public pagereference doConvert(){
                convertValidations();
                 if(ApexPages.getMessages() != null && !ApexPages.getMessages().isEmpty()){
                 //showerror=true;
                 return null;
                }            
                String OpptyId;
                try{
                OpptyId = ConvertLead.doConvert(leadId);
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
        String displayName=leadObj.firstname==null?leadObj.lastname+', '+leadObj.street:leadObj.firstname+' '+leadObj.lastname+', '+leadObj.street;                 
        String urlPath = '/apex/OpportunityPage?id='+OpptyId+'&opptyedit=false&object=Opportunity&objectId='+OpptyId+'&objectName='+EncodingUtil.urlEncode(displayName,'UTF-8');
        PageReference pr = new PageReference(urlPath);
        pr.setRedirect(true);
        return pr; 
}
public void convertValidations(){
    if(leadObj.Status=='Out of Market'){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Cannot Create Design or Convert Out of Market Leads'));
    }
    else if(leadObj.install_Branch_Id__c==null&&leadObj.install_partner__c==label.sunrun_inc_id){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Cannot Create Design or Convert as Install Branch doesn\'t exist for this ZipCode'));
    }
    else if(leadObj.Sales_Partner__c ==null||leadObj.install_partner__c==null||leadObj.Market_Assignment_Install__c==null||leadObj.Market_Assignment_Sales__c==null){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Market Assignment Failure'));
    }
}
/*
public pagereference doScheduleAppointment(){
         Pagereference ref = new PageReference('/apex/RepSchedLead?Id=' + leadId);
         ref.setredirect(true);
         return ref;      
}
*/
public void leadValidations(){        
        if((leadObj.email == null || leadObj.email == '') && ((leadObj.Phone == null || leadObj.Phone == ''))){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Enter Email OR Phone'));
        } 
         if(leadObj.Phone != null&&leadObj.Phone.length()<14&&leadObj.id==null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Phone number should be 10 digits'));
        }  
        if(leadObj.mobilephone != null&&leadObj.mobilephone.length()<14&&leadObj.id==null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Mobile number should be 10 digits'));
        }
        if(leadObj.status== 'Closed Lost'&&leadObj.Lead_status__c==null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Status is required'));
        } 
        if(leadObj.Lead_status__c== 'Unqualified'&&leadObj.Reason__c==null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Reason is required'));
        }                    
    }
public pagereference Save(){
        PageReference page = null;   
        Lead oldLead;   
        leadValidations();      
        if(ApexPages.getMessages() != null && !ApexPages.getMessages().isEmpty()){
                 //showerror=true;
         return page;
        } 
        if(leadid!=null){
            getQuery();
            oldLead=database.query(query+=LeadId+'\'');  
            if((oldLead.street!=leadObj.street||oldLead.city!=leadObj.city||leadObj.state!=oldLead.state||leadObj.postalcode!=oldLead.postalcode)&&(oldLead.latitude__c==leadObj.latitude__c&&oldLead.longitude__c==leadObj.longitude__c)){
                leadObj.Address_Standardization_Override__c=true;
            }
        }
        if(Iscloned){                                   
                leadObj.prospect_id__c=null;
                leadObj.id=null;
                leadObj.company=leadObj.lastname+' ,'+leadObj.firstName;
                insert leadObj;         
        }
        else{
        leadObj.company=leadObj.lastname+' ,'+leadObj.firstName;
        leadObj.Synchronous_Assignment__c=true;
                try{
                Upsert leadObj;
                }
                catch(exception e){
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
        }
        editMode=false; 
        String displayName=leadObj.firstname==null?leadObj.lastname:leadobj.firstname+' '+leadObj.lastname;
        page=new PageReference('/apex/LeadPage?id='+leadObj.id+'&LeadEdit=false&object=Lead&objectId='+leadObj.id+'&objectName='+EncodingUtil.urlEncode(displayName,'UTF-8'));
        page.setredirect(true);
        return page;
}
public pagereference SaveConvert(){
        PageReference page = null;      
        leadValidations();      
        if(ApexPages.getMessages() != null && !ApexPages.getMessages().isEmpty()){
         system.debug('Error mss:'+ApexPages.getMessages());        
         return page;
        }       
        leadObj.company=leadObj.lastname+' ,'+leadObj.firstName;
        leadObj.Synchronous_Assignment__c=true;
    
        Sf.addressService.standardizeLeadsAddressWithoutSave(leadObj);
    
                try{
                upsert leadObj;
                }
                catch(exception e){
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
        leadId=leadObj.id;  
        getQuery();
        leadObj=database.query(query+=LeadId+'\'');            
        page=doConvert();
        if(page==null){
                return null;
        }
        editMode=false;
        page.setredirect(true);
        return page;
}
public pagereference editLead(){
        Pagereference page=new PageReference('/apex/LeadPage?Id=' + leadObj.id);
        page.setredirect(true);
        return page;
}
public pagereference doClone(){
         Pagereference ref = new PageReference('/apex/LeadPage?clone=1&id='+leadId+'&retURL=%2F'+leadId);
         leadId=null;
         ref.setredirect(true);  
         return ref;
}
/*
public pagereference findMarkets(){
         doMarketAssignmentsSynchronous.doMarketAssignments(leadId);
         Pagereference ref = new PageReference('/apex/LeadPage?id='+leadId+'&LeadEdit=false');
         leadId=null;
         ref.setredirect(true);  
         return ref;
}
*/
public pagereference shareLead(){
         Pagereference ref;
         String redirectURL = URL.getSalesforceBaseUrl().toExternalForm()+'/p/share/LeadSharingDetail?parentId='+leadObj.id;
         ref = new PageReference(redirectURL);
         ref.setredirect(true);  
         return ref;
        }
public pagereference findDuplicates(){
         String redirectURL = URL.getSalesforceBaseUrl().toExternalForm()+'/lead/leadmergewizard.jsp?retURL='+leadId+'&id='+leadId;
         Pagereference ref = new PageReference(redirectURL);
         leadId=null;
         ref.setredirect(true);  
         return ref;
}
/*
public void editAddress(){
        system.debug('--->lead'+leadObj);
        system.debug('--->lead street'+leadObj.street);      
        editAddress = (editAddress == true)?false:true; 
}
*/
public pagereference cancel(){
         Pagereference ref;
         if(leadId!=null){
                ref = new PageReference('/apex/LeadPage?id='+leadId+'&LeadEdit=false');
         }
         else{
                String redirectURL = URL.getSalesforceBaseUrl().toExternalForm()+'/00Q/o?nooverride=1&retURL=';
                ref = new PageReference(redirectURL);
         }
         ref.setredirect(true);  
         return ref;
}
public pagereference closePopup() {        
     displayPopup = false; 
     //System.debug('leadObj street---'+streetAddress);
     return null;   
 }     
 public pagereference showPopup() {        
      displayPopup = true;
      return null;    
}
}