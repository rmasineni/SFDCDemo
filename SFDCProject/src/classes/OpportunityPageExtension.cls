public with sharing class OpportunityPageExtension {
    public id OpptyId{set;get;}
    public String baseURL {get;set;}
    public String scRedirectUrl {get;set;}
    public boolean editMode{set;get;}
    public Opportunity opptyObj{set;get;}
    public Account accObj{set;get;}
    public Contact contactobj{set;get;}
    public boolean displayPopup{get;set;}
    //public boolean showError{get;set;}
    public string title{set;get;}
    public boolean displaySalesRepPopup{get;set;}
    public DesignToolWebservice.DesignToolWebserviceResponse responseObj{get;set;}
    public String  displayPopupMessage{get;set;}
    public boolean displayURL{get;set;}
    public boolean displayTandCURL{get;set;}
    public boolean displaySalesRepURL{get;set;}
    public boolean displayWarningMessage{get;set;}
    public String SalesRepURL{get;set;}
    public String redirectURL{get;set;}
    public boolean showConfirm {get;set;}
    public Id partnerContactId{get;set;} 
    public String selectedDesign {get;set;}
    public boolean isCloned{set;get;}
    public boolean partnerTandCAccepted{get;set;}
    public String returnPageVal;
    public List<TermsConditions__c> PartnerTermsConditions;
    private ApexPages.StandardController sController; 
    public Energy_Storage__c energyStorage { get;set;}
    public SR_Attachment__c srattachment {get;set;}
   // Opportunity[] oldRecords;
    public OpportunityPageExtension(ApexPages.StandardController stdController){
        editMode=true;
        //showError=false;
        IsEngStApplicable = true;
        sController=stdController;
        OpptyId=stdController.getId();
        opptyObj=(Opportunity)stdController.getrecord();
        energyStorage = new Energy_Storage__c(Opportunity__c=OpptyId);
        //if(opptyObj!=null&&OpptyId!=null){
        //  title=opptyObj.Account.BillingStreet;           
        //}
        String edit=ApexPages.currentPage().getParameters().get('OpptyEdit');
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
        baseURL = EDPUtil.getBaseURL();
     //   oldrecords= opptyObj.deepClone(true,true,true);
    }
    public pagereference onLoad(){
        if(OpptyId!=null){
            String Query='SELECT name,Primary_Title__c,deal_id__c,Secondary_Title__c,Notes__c,AccountId,Referral_Id_for_Reference__c,Account.BillingCountry,Account.County__c,Account.Address_Standardization_Status__c,Account.BillingStreet,Account.BillingCity,Account.BillingState,Account.BillingPostalCode,Account.Latitude__c,Account.Longitude__c, Apr_Usage__c, Aug_Usage__c, Average_Monthly_Electric_Bill__c, Avg__c, Channel__c, CloseDate, Costco_Member_ID__c, Costco_Member_Type__c, CreatedDate, Dec_Usage__c, Designer__c, Designer_Assigned_Once__c, Do_not_call__c, Feb_Usage__c,usage_option__c,Void_Proposals__c,Warm_Transfer__c,Reason__c,Preferred_Language__c,Work_Order_Status__c,BOM_Org__c,Homeowner_First_Name__c,Homeowner_Last_Name__c,Homeowner_Full_Name__c,Number_of_Proposals__c,';
                   Query+='Sales_Branch__c,Appointment_Type_Requested_del__c,Offer_Id_for_Reference__c,Referral_Promotion_Name__c,Offer_Promotion_Name__c,Prospect_Id__c,Email_Opt_Out__c ,Sales_Partner__c,LastModifiedById ,CreatedById ,Jun_Usage__c,Costco_Purchase_Thru_Warehouse__c,Field_Marketing_Branch__c, Home_Type__c, Install_Partner__c, Install_Branch_Id__c, Installation_Type__c, InstallationOffice__c, Jan_Usage__c, Jul_Usage__c, LastModifiedDate, Lead_Created_Date__c, Lead_Gen_Partner__c, Lead_Generated_by__c, Lead_Source__c,Rate_Schedule__c,Sales_Team__c,Lead_Type__c,Annual_kWh_usage__c,Core_Logic_Land_Type__c,site_Design_Priority__c,Site_Design_Failure_Reason__c,Site_Designer__c,Site_Design_Requested__c,Energy_Storage_Applicable__c,Site_Design_Status__c,';
                   Query+='appointment_category__c, Best_way_to_reach__c,square_footage__c,Referral__c,Offer__c,Sales_rep_of_referrer__c,Referred_by_Contact_Email__c ,Roofing_type__c,Number_of_Stories__c,hoa__c,Age_of_Roof__c,Purchased_Thru__c,Lead_Organization_Location_2__c, Probability,Lead_Qualifier__c,Follow_up__c,OwnerId ,Sales_Rep__c ,StageName,Opportunity_Status__c ,channel_2__c,Lead_Source_2__c, Mar_Usage__c, May_Usage__c, Nov_Usage__c, Oct_Usage__c, Opportunity_Source_Type__c, Ready_for__c, SalesRep__c, Sales_Representative__c, Sep_Usage__c, Utility_Company__c, Why_Closed_Lost__c, Territory__c, State__c,Hawaii_NEM_Approved__c,Project_Manager__c,Project_Manager_Email__c,Project_Manager_Phone__c,(select id,name,Appointment_Date_Time__c,Cancellation_Reason__c,Event_Assigned_To__c,Status__c, duration__c, Appointment_Time_Local__c, appointment_type__c,Text_Opt_Out__c, Mobile_for_SMS__c from appointments__r order by createddate)';
                    
            Map<String,Opportunity_Fields__c> map_OpptyFlds = Opportunity_Fields__c.getAll();
            if(!map_OpptyFlds.isempty()){
                for(String fld:map_OpptyFlds.keyset()){
                    Query+=','+fld;
                }
            }
            Query+=' from Opportunity where id=\''+OpptyId+'\'';    
            System.debug('---Query'+query);     
            opptyObj=database.query(Query);

            String costcoMemberId = null;
            Boolean updateMemberId = false;
            String preferredLanguage = null;
            Boolean updatePreferredLanguage = false;
            String homeOwnerFirstName = null;
            String homeOwnerLastName = null;
            String homeOwnerFullName = null;
            Boolean updateHomeOwnerName = false;
            List<Appointment__c> updateApptList = new List<Appointment__c>();
            try{  
              accObj=[select id,billingstreet,billingcity,billingpostalcode,billingstate,void_proposals__c,Latitude__c,Longitude__c,Address_Standardization_Status__c
 from account where id=:opptyObj.accountid];
              OpportunityContactRole OpptyRoleobj=[select id,contactid from OpportunityContactRole where opportunityId=:opptyObj.id and isprimary=true limit 1];
              List<Appointment__c> apptList = new List<Appointment__c>();
              if(opptyObj.appointments__r.size()>0){
               apptList = opptyObj.appointments__r; 
              }
              
              if(OpptyRoleobj != null) {
                
                contactobj = [SELECT id, name,HomePhone,MobilePhone, otherphone,AccountId, Firstname, Lastname, Email, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode,
                                            Phone, HasOptedOutOfEmail, Void_Proposals__c, Member_ID__c, Preferred_Language__c,Text_Opt_Out__c FROM Contact WHERE id =: OpptyRoleobj.ContactId limit 1];
                if(contactobj != null) {
                   
                   title = contactobj.name+', '+accObj.billingstreet;                               
                   
                   if(opptyObj.Costco_Member_ID__c != contactobj.Member_ID__c) {
                      
                      costcoMemberId = contactobj.Member_ID__c;
                      updateMemberId = true; 
                   }
                   if(opptyObj.Preferred_Language__c != contactobj.Preferred_Language__c){
                   
                      preferredLanguage = contactobj.Preferred_Language__c;
                      updatePreferredLanguage = true;
                   }
                   if(opptyObj.Homeowner_First_Name__c != contactobj.FirstName || opptyObj.Homeowner_Last_Name__c != contactobj.LastName){
                      
                      homeOwnerFirstName = contactobj.FirstName;
                      homeOwnerLastName = contactobj.LastName;
                      homeOwnerFullName = contactobj.FirstName + ' ' + contactobj.LastName;
                      updateHomeOwnerName = true;
                   }
                   if(!apptList.isEmpty()){
                    for(Appointment__c apptObj : apptList){
                     if(apptObj.Text_Opt_Out__c != contactObj.Text_Opt_Out__c || apptObj.Mobile_for_SMS__c != contactObj.Phone){
                       apptObj.Text_Opt_Out__c = contactObj.Text_Opt_Out__c;
                       apptObj.Mobile_for_SMS__c = contactObj.Phone;
                       updateApptList.add(apptObj);
                     } 
                    }
                   }
                } 
              }  
                List<Energy_Storage__c> lstEnergyStorage = [Select Id,Number_of_adults_home_during_the_day__c,Use_A_C__c,Date_of_Meter_Instal__c,Meter_Sensor_ID__c,ES_kWh__c,Opportunity__c,PV_kWdc__c,Time_return_from_work__c,Prepaid_20_Year_PPA_Lease_Savings__c,Monthly_20_Year_Savings__c,Prepaid_20_Year_PPA_Lease__c,Monthly_20_Year_PPA_Lease_Payment__c,Electric_vehicle_charged_after_4PM__c,Current_Blended_Utility_Rate__c,PV_Turnkey__c,Yearly_kWh_consumption__c,Name from Energy_Storage__c where Opportunity__c=: OpptyId];
                if(lstEnergyStorage !=null && lstEnergyStorage.size()>0)
                  energyStorage = lstEnergyStorage[0];
                else
                  energyStorage = new Energy_Storage__c(Opportunity__c=OpptyId);
            }
            catch(exception e){
                system.debug('Print exp'+e);
                updateMemberId = true; 
            }            

            if(updateMemberId){
               System.debug('Costco Member ID will be updated to ' +costcoMemberId); 
               opptyObj.Costco_Member_ID__c = costcoMemberId;
               //update opptyObj;                                                         
            }
            if(updatePreferredLanguage){
               system.debug('Preferred Language will be updated to'+preferredLanguage);
               opptyObj.Preferred_Language__c = preferredLanguage;
               //update opptyObj;
            }
            if(updateHomeOwnerName){
               system.debug('Home Owner First Name will be updated to'+homeOwnerFirstName);
               opptyObj.Homeowner_First_Name__c = homeOwnerFirstName;
               opptyObj.Homeowner_Last_Name__c = homeOwnerLastName;
               opptyObj.Homeowner_Full_Name__c = homeOwnerFullName;
               //update opptyObj;       
            }
            if(updateMemberId || updatePreferredLanguage || updateHomeOwnerName){
               update opptyObj;
            }
            if(!updateApptList.isEmpty()){
               update updateApptList;
            }
        }       
        return null;
    }   
    public void OpptyValidations(){        
        if(opptyObj.StageName == '9. Closed Lost' && opptyObj.Opportunity_Status__c==null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Status is required'));
        } 
         if((opptyObj.Opportunity_Status__c == 'Unqualified'||opptyObj.Opportunity_Status__c=='Not Interested')&&opptyObj.Reason__c==null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Reason is required'));
        }  
       /* System.debug('This is usuage:'+ opptyObj.Jan_Usage__c);
        if((opptyObj.Site_Design_Priority__c!=null && ((opptyObj.Square_footage__c==null ||opptyObj.Square_footage__c==0) && 
                                                       (opptyObj.Jan_Usage__c==null || opptyObj.Feb_Usage__c==null || opptyObj.Mar_Usage__c==null || opptyObj.Apr_Usage__c==null || 
                                                        opptyObj.May_Usage__c==null || opptyObj.Jun_Usage__c==null || opptyObj.Jul_Usage__c==null || opptyObj.Aug_Usage__c==null ||
                                                        opptyObj.Sep_Usage__c==null || opptyObj.Oct_Usage__c==null || opptyObj.Nov_Usage__c==null || opptyObj.Dec_Usage__c==null
                                                       )))){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Monthly usage or Square Footage is required to update Site Design Priority.'));
        } 
        if(opptyObj.Site_Design_Priority__c!=null && opptyObj.Purchased_Thru__c==null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Purchased Thru is required to update Site Design Priority.'));
        } */
       // Opportunity o=[select id,Account.Latitude__c,Account.Longitude__c,Account.BillingState,Account.County__c,Square_footage__c,channel_2__c,Lead_Source_2__c,Home_Type__c,Jan_Usage__c,Feb_Usage__c,Mar_Usage__c,Apr_Usage__c,May_Usage__c,Jun_Usage__c,Jul_Usage__c,Aug_Usage__c,Sep_Usage__c,Oct_Usage__c,Nov_Usage__c,Dec_Usage__c,Average_Monthly_Electric_Bill__c,Number_of_Proposals__c,Sales_Partner__c,Install_Partner__c,Market_Assignment_Sales__c,Market_Assignment_Install__c,Address_Validation_Status__c,SalesRep__c,Annual_kWh_usage__c,Utility_Company__c,Territory__c,Opportunity_Source_Type__c,Usage_Option__c,Purchased_Thru__c,Opportunity_Division_Custom__c,Site_Design_Priority__c from opportunity where id=:opptyId];
                OpportunityContactRole ocr;
                Contact con;        
                Partner_Role__c prSales;
                Partner_Role__c prInstall;
                try{
                ocr=[select id , contactId from opportunitycontactrole where opportunityid=:OpptyId and isprimary=true limit 1];
                con = [select id, Member_ID__c from contact where id = : ocr.ContactId];    
                //pr=[select Sales_Rep_Email__c,Sales_Rep_Phone__c,Sales_Rep_Division__c from Partner_Role__c where opportunity__c=:o.id and role__c='Sales' order by partner_name__c nulls last limit 1];                
              /*  for(Partner_Role__c pr:[select Sales_Rep_Email__c,Sales_Rep_Phone__c,Sales_Rep_Division__c,Partner_Name__c, Role__c
                                          from Partner_Role__c 
                                         where opportunity__c=:OpptyId 
                                           and role__c in ('Sales', 'Install')
                                           and partner_name__c != null]){
                        if(pr.Role__c == 'Sales'){
                           prSales = pr;
                        }else if(pr.Role__c == 'Install'){
                           prInstall = pr;
                        }
                } */
                }
                catch(exception e){
                    system.debug(e);
                }
                /*
                if(o.Address_Validation_Status__c!='Success'){
                    return 'A valid address is required to create design';
                }
                */
               list<Contact> CurrentContact=[select id, T_C_Accepted__c from Contact where Sunrun_User__c=:userinfo.getUserId() AND Email= :userinfo.getUserEmail() AND Contact_Type__c='Employee'];     
            if((opptyObj.Site_Design_Priority__c=='High'||opptyObj.Site_Design_Priority__c=='Normal' ) && CurrentContact.size() == 1){
               partnerContactId = CurrentContact[0].id;
               partnerTandCAccepted = CurrentContact[0].T_C_Accepted__c;   
            }else if ((opptyObj.Site_Design_Priority__c=='High'||opptyObj.Site_Design_Priority__c=='Normal' ) && CurrentContact.size() == 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'The valid user contact is required.'));
                // displayPopupMessage='The valid user contact is required';
                // displayPopup=true;
               //  return null;   
            } 
                
                if(opptyObj.Site_Design_Priority__c!=null && opptyObj.Opportunity_Source_Type__c!='BB' && opptyObj.Number_of_Proposals__c>0){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Opportunities created by Proposal Tool are not eligible for design in BrightPath.'));
                    
                }                
                else if((opptyObj.Site_Design_Priority__c!=null && ((opptyObj.Square_footage__c==null||opptyObj.Square_footage__c==0) &&
                                                                    ((opptyObj.Annual_kWh_usage__c==null||opptyObj.Annual_kWh_usage__c==0)||
                                                                      (
                                                                          opptyObj.Annual_kWh_usage__c>0&&(opptyObj.Jan_Usage__c==null||opptyObj.Feb_Usage__c==null||opptyObj.Mar_Usage__c==null||opptyObj.Apr_Usage__c==null||
                                                                                                        opptyObj.Mar_Usage__c==null||opptyObj.May_Usage__c==null||opptyObj.Jun_Usage__c==null||opptyObj.Jul_Usage__c==null||
                                                                                                        opptyObj.Aug_Usage__c==null||opptyObj.Sep_Usage__c==null||opptyObj.Oct_Usage__c==null||opptyObj.Oct_Usage__c==null||
                                                                                                        opptyObj.Nov_Usage__c==null||opptyObj.Dec_Usage__c==null
                                                                                                       )))) ))
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Monthly Usage or Square Footage is required to update Site Design Priority.'));
                     
                }   
                else if(opptyObj.Site_Design_Priority__c!=null && opptyObj.Jan_Usage__c==0&&opptyObj.Feb_Usage__c==0&&opptyObj.Mar_Usage__c==0
                &&opptyObj.Apr_Usage__c==0&&opptyObj.Mar_Usage__c==0&&opptyObj.May_Usage__c==0&&opptyObj.Jun_Usage__c==0&&opptyObj.Jul_Usage__c==0&&opptyObj.Aug_Usage__c==0
                &&opptyObj.Sep_Usage__c==0&&opptyObj.Oct_Usage__c==0&&opptyObj.Oct_Usage__c==0&&opptyObj.Nov_Usage__c==0&&opptyObj.Dec_Usage__c==0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'All monthly usage cannot be zero.'));
                    
                }              
                else if(opptyObj.Site_Design_Priority__c!=null && (opptyObj.channel_2__c==null||opptyObj.Lead_Source_2__c==null)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Channel & Lead Source is required to update Site Design Priority.'));
                        
                }
                else if((opptyObj.Site_Design_Priority__c=='High'||opptyObj.Site_Design_Priority__c=='Normal' ) && ocr==null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Primary contact is required to update Site Design Priority.'));
                    
                }
                else if(opptyObj.Site_Design_Priority__c!=null && Userinfo.getUserType()!='PowerPartner' && opptyObj.Sales_Partner__c==System.label.Sunrun_Inc_Id && (opptyObj.Purchased_Thru__c == ' ' || opptyObj.Purchased_Thru__c == null)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Purchased Thru is required to update Site Design Priority.'));
                        
                }
                else if(opptyObj.Site_Design_Priority__c!=null && opptyObj.Purchased_Thru__c == 'Costco' && (con.Member_ID__c == null || con.Member_ID__c == '')){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Costco Member Id is required on primary contact.'));
                   
                }
                /*
                else if(o.Annual_kWh_usage__c==null||o.Annual_kWh_usage__c==0){
                    return 'Annual kWh use is required to continue to system design';
                }
                */
                /*
                else if(o.Opportunity_Source_Type__c!='BB' && o.Number_of_Proposals__c>0){
                    return 'Opportunities created by Proposal Tool are not eligible for design in BrightPath.';
                }*/                
                else if(opptyObj.Site_Design_Priority__c!=null && (opptyObj.Utility_Company__c==null||opptyObj.Utility_Company__c=='')){
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Utility Company is required to update Site Design Priority.'));
                   
                }
                else if((opptyObj.Site_Design_Priority__c!=null)&&(opptyObj.Utility_Company__c=='Pacific Gas & Electric (PG&E)'||opptyObj.Utility_Company__c=='PG&E'||opptyObj.Utility_Company__c=='SDG&E'||opptyObj.Utility_Company__c=='SCE'||opptyObj.Utility_Company__c=='SMUD'||opptyObj.Utility_Company__c=='Southern California Edison (SCE)'||opptyObj.Utility_Company__c=='San Diego Gas & Electric (SDG&E)')&&(opptyObj.Usage_Option__c==null||opptyObj.Usage_Option__c==''||opptyObj.Usage_Option__c=='NA')){
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Usage Option is required for this Utility to navigate into Design Tool.'));
                   
                }
                else if(opptyObj.Site_Design_Priority__c!=null && opptyObj.territory__c==null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Territory is required to navigate into Design Tool.'));
                  
                }
                else if(opptyObj.Site_Design_Priority__c!=null && opptyObj.home_type__c==null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Home type is required to update Site Design Priority.'));
                       
                }
                
               /* else if(opptyObj.Opportunity_Division_Custom__c != label.AEE_label && (opptyObj.Market_Assignment_Sales__c==null||opptyObj.Market_Assignment_Install__c==null)){
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Sales Partner & Install Partner Adders are required to create design.'));
                   
                } */
               /* else if(opptyObj.Site_Design_Priority__c!=null && opptyObj.Purchased_Thru__c == 'Costco' && prSales.Partner_Name__c != System.label.sunrun_inc_Id){
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Sales Partner should be Sunrun for Costco deal.'));
                    
                }                       
                else if(opptyObj.Site_Design_Priority__c!=null && opptyObj.Site_Design_Priority__c!=null && opptyObj.Purchased_Thru__c == 'Costco' && prInstall.Partner_Name__c != System.label.sunrun_inc_Id){
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Install Partner should be Sunrun for Costco deal.'));
                   
                }  */                                   
                else if(opptyObj.Site_Design_Priority__c!=null && (opptyObj.Sales_Partner__c==null||opptyObj.Install_Partner__c==null)){
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Sales Partner & Install Partner are required to create design.'));
                    
                }  
               /* else if(opptyObj.Site_Design_Priority__c!=null && opptyObj.Opportunity_Division_Custom__c != label.AEE_label && (prSales==null||(prSales!=null&&(prSales.Sales_Rep_Email__c==null&&prSales.Sales_Rep_Phone__c==null)))){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Sales Rep Message'));
                   
                }
                else if(opptyObj.Site_Design_Priority__c!=null && opptyObj.Opportunity_Division_Custom__c != label.AEE_label && (Userinfo.getUserType()!='PowerPartner'&&prSales!=null&&prSales.Sales_Rep_Division__c==null&&!(opptyObj.channel_2__c=='Partner'))){
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Sales Rep Division Message'));
                    
                }                                 
                else if((opptyObj.Site_Design_Priority__c!=null) && (opptyObj.Account.County__c==null||opptyObj.Account.County__c==''||opptyObj.Account.County__c=='NA')&&(opptyObj.account.billingstate!=null&&(opptyObj.account.billingstate.equalsIgnoreCase('NY')||opptyObj.account.billingstate.equalsIgnoreCase('New York')))){
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'County Message')); 
                   
                } */
    }
    public boolean IsEngStApplicable { get; set;}
    public Pagereference onChangeEnergyApplicable()
    {
        IsEngStApplicable = OpptyObj.Energy_Storage_Applicable__c;
        return null;    
    }
    public pagereference Save(){
    PageReference page = null;      
        if(ApexPages.getMessages() != null && !ApexPages.getMessages().isEmpty()){
             return page;
        } 
        Account oldAcc=[select id,billingstreet,billingcity,billingpostalcode,billingstate,Latitude__c,Longitude__c,Address_Standardization_Status__c from account where id=:opptyObj.accountid];
        if((oldAcc.billingstreet!=accObj.billingstreet||oldAcc.billingcity!=accObj.billingcity||oldAcc.billingstate!=accObj.billingstate||oldAcc.billingpostalcode!=accObj.billingpostalcode)&&(oldAcc.latitude__c==accObj.latitude__c&&oldAcc.longitude__c==accObj.longitude__c)){
                accObj.Address_Standardization_Override__c=true;
            } 
        if(opptyObj.void_proposals__c){
            accObj.void_proposals__c=true;
            contactObj.void_proposals__c=true;
        }           
        if(Iscloned){                   
        OpptyObj.prospect_id__c=null;
        OpptyObj.id=null;
        insert OpptyObj;        
        }
        else{   
        try{
        OpptyValidations(); 
        if(ApexPages.getMessages() != null && !ApexPages.getMessages().isEmpty()){          
            return page;
        } 
        
        update accObj;
        upsert opptyObj;
        update contactObj;
        dispositionAppointments();
        if(opptyObj.Energy_Storage_Applicable__c == true)
        {   
           // energyStorage.Opportunity__c = opptyObj.Id;
           // update energyStorage;
            if(Iscloned)
                energyStorage.Id=null;
            Upsert energyStorage;
        }else{
            if(!Iscloned && energyStorage.Id !=null)
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
        
        }
        catch(exception e){
                        String expType=e.getTypeName();
                        String errMessage;
                        system.debug('errMessage'+expType);
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
    page=new PageReference('/apex/OpportunityPage?Id=' + opptyObj.id+'&OpptyEdit=false'+'&nooverride=1');
    page.setredirect(true);
    return page;
    }
    private void dispositionAppointments(){
        List<Appointment__c> newApptList=new List<Appointment__c>();
        List<Appointment__c> updateApptList=new List<Appointment__c>();
        newApptList=opptyObj.appointments__r;
        if(!newApptList.isempty()){
        List<Appointment__c> oldApptList=new List<Appointment__c>();
        oldApptList=[select id,name,appointment_type__c, Cancellation_Reason__c,Appointment_Date_Time__c,Event_Assigned_To__c,Status__c from appointment__c where opportunity__c=:opptyObj.id order by createddate]; 
        for(Integer i=0;i<oldApptList.size();i++){
            if(oldApptList[i].status__c!=newApptList[i].status__c){
                updateApptList.add(newApptList[i]);
            }
        }
        }
        if(!updateApptList.isempty()){
            update updateApptList;
        }
    }
    public pagereference editOppty(){
    Pagereference page=new PageReference('/apex/OpportunityPage?Id=' + opptyObj.id);
    page.setredirect(true);
    return page;
    }    
    public pagereference createAppointment(){
    update opptyObj;
    return null;
    }
    public pagereference cancel(){
     Pagereference ref;
     if(OpptyId!=null){
        ref = new PageReference('/apex/OpportunityPage?id='+OpptyId+'&OpptyEdit=false');
     }
     else{
        String redirectURL = URL.getSalesforceBaseUrl().toExternalForm()+'/00Q/o?nooverride=1&retURL=';
        ref = new PageReference(redirectURL);
     }
     ref.setredirect(true);  
     return ref;
    }
    public pagereference shareOppty(){
     Pagereference ref;
     String redirectURL = URL.getSalesforceBaseUrl().toExternalForm()+'/p/share/OppSharingDetail?parentId='+OpptyObj.id;
     ref = new PageReference(redirectURL);
     ref.setredirect(true);  
     return ref;
    }
    public pagereference doReferral(){
     Pagereference ref;
     String redirectURL;
     if(opptyObj.Referral_Id_for_Reference__c==null){
        redirectURL = '/a0Z/e?CF00N60000002WGc4='+opptyObj.name+'&CF00N60000002WGc4_lkid='+OpptyObj.id;
     } 
     else{
        redirectURL =  '/a0Z/e?id='+opptyObj.Referral_Id_for_Reference__c; 
     }
     ref = new PageReference(redirectURL);
     ref.setredirect(true);  
     return ref;
    }
    public pagereference doOffer(){
     Pagereference ref;
     String redirectURL;
     if(opptyObj.Offer_Id_for_Reference__c==null){
        redirectURL = '/a5a/e?CF00N60000002YGtr='+opptyObj.Name+'&CF00N60000002YGtr_lkid='+opptyObj.Id; 
     } 
     else{
        redirectURL =  '/a5a/e?id='+opptyObj.Offer_Id_for_Reference__c; 
     }
     ref = new PageReference(redirectURL);
     ref.setredirect(true);  
     return ref;
    }
    public pagereference doClone(){
     Pagereference ref = new PageReference('/apex/OpportunityPage?clone=1&id='+opptyObj.Id+'&retURL=%2F'+opptyObj.Id);
     OpptyId=null;
     ref.setredirect(true);  
     return ref;
    }   
     // Methods related to Partner Terms and Conditions
    public List<TermsConditions__c> getPartnerTermsConditions(){
        System.debug(LoggingLevel.INFO,'In getPartnerTermsandConditions()');

        PartnerTermsConditions = TermsConditionsUtil.fetchPartnerTermsConditions('PARTNER');
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
     public pageReference redirectDesignTool(){
        if(selectedDesign=='--None--'||selectedDesign==null){
            return null;
        } 
       /* if(opptyObj.Site_Design_Status__c=='In Progress')
                {
                    this.displayPopup = true;
                    this.displayPopupMessage = 'This site design is currently in progress!';
                    return null;
                } */
        String message=CDYNEStandardButtonCall.callOpportunity(opptyObj.id);
        System.debug(LoggingLevel.INFO,'message : '+message);         
        if(message!='Success'&&message!='Sales Rep Message'&&message!='Sales Rep Division Message'&&message!='County Message'){
         displayPopupMessage=message;
         displayPopup=true; 
         return null;   
        }       
          list<Contact> CurrentContact=[select id, T_C_Accepted__c from Contact where Sunrun_User__c=:userinfo.getUserId() AND Email= :userinfo.getUserEmail() AND Contact_Type__c='Employee'];     
            if(CurrentContact.size() == 1){
               partnerContactId = CurrentContact[0].id;
               partnerTandCAccepted = CurrentContact[0].T_C_Accepted__c;   
            }else{
                 displayPopupMessage='The valid user contact is required';
                 displayPopup=true;
                 return null;   
            }                                   
         if(!partnerTandCAccepted && message != null && message.equalsIgnoreCase('Success')){          
                system.debug('In T&C not accepted');
                returnPageVal = 'Opty';
                PageReference partnerTandCPage = TermsConditionsUtil.redirectToTermsConditions(partnerContactId,opptyObj.Id,'Opty',selectedDesign,opptyObj.Prospect_Id__c,'PARTNER','P');                               
                redirectURL= partnerTandCPage.getUrl();
                displayTandCURL=true;
                return null;                 
         }else{
            responseObj = new DesignToolWebservice.DesignToolWebserviceResponse();
            selectedDesign=selectedDesign.trim();
            selectedDesign=selectedDesign.replaceAll('(\\s+)', '');
            if(selectedDesign!='--None--')
            DesignTool.function=selectedDesign;
            DesignToolWebservice.DesignToolWebserviceResponse responseObj2 = DesignTool.getDesignToolURL(opptyObj.id, opptyObj.Prospect_Id__c, 'Opportunity');
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
                responseObj = DesignTool.canUserCreateORModifyProposal(opptyObj.id);
                if(responseObj.status == ProposalUtil.SUCCESS){
                    redirectURL=responseObj2.url;
                    if(message=='Success'){
                    displayURL=true;  
                    If(opptyObj.Site_Designer__c==null)    
                    opptyObj.Site_Designer__c=UserInfo.getUserId();
                   // If(opptyObj.Site_Design_Status__c=='Open')    
                   // opptyObj.Site_Design_Status__c='In Progress';   
                    System.debug('This is Site Desinger:'+opptyObj.Site_Designer__c);    
                     update opptyObj;    
                    }                    
                }else if(responseObj.status == ProposalUtil.WARNING){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000022').error_message__c;  
                     displayPopupMessage=errorMessage ;
                     //displayPopup=true;
                     displayWarningMessage=true;
                     redirectURL=responseObj2.url; 
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));     
                     showConfirm = true;  
                    If(opptyObj.Site_Designer__c==null)  
                       opptyObj.Site_Designer__c=UserInfo.getUserId(); 
                   // If(opptyObj.Site_Design_Status__c=='Open')    
                   // opptyObj.Site_Design_Status__c='In Progress';
                       update opptyObj;
                }else if(responseObj.status == ProposalUtil.ERROR){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000023').error_message__c;  
                    displayPopupMessage=errorMessage ;
                    displayPopup=true; 
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));                     
                }
                if((message=='Sales Rep Message'||message=='Sales Rep Division Message'&&userinfo.getUserType()!='PowerPartner')||message=='County Message'){
                    String partnerTCAccepted = partnerTandCAccepted ? 'true' : 'false';
                    returnPageVal = 'Opty';                    
                    displaySalesRepUrl=true;                     
                    SalesRepURL='/apex/SalesRepRedirect?Id='+OpptyObj.id+'&message='+message+'&redirectUrl='+redirectURL+'&partnerTandCAccepted='+partnerTCAccepted+'&partnerContactId='+partnerContactId;
                    return null;
                }
            }
         }   
        return null;
     }  


    public pagereference showScheduler(){
        Pagereference page;
        scRedirectUrl = '';
        Boolean PartnerPP=baseURL.containsIgnoreCase('partner');
        
        if(!String.isEmpty(opptyObj.appointment_category__c) && opptyObj.appointment_category__c != '--None--'){
            scRedirectUrl = '/apex/CallcenterOptyScheduler?scontrolCaching=1&id=' + OpptyId + '&category=' + opptyObj.appointment_category__c;
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