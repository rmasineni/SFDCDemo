global class Batch_LeadDistributionLogic implements Database.Batchable<sObject>, Schedulable{ 
  
     
  global Database.QueryLocator start(Database.BatchableContext BC){
      DateTime dt_60  = System.Now();
      DateTime dt_120  = System.Now();
      
      if(Test.isRunningTest()){
          dt_60 = dt_60.addMinutes(-2);
           dt_120 = dt_120.addMinutes(-10);
      }else{
          dt_60 = dt_60.addMinutes(-60);
          dt_120 = dt_120.addMinutes(-120);
      }
      
      
     
      
      return Database.getQueryLocator([ SELECT Account_Type__c,Alternate_Phone__c,Appointment_Set__c,
                                        Baseline_Region__c,Best_Time_to_Contact__c,Best_way_to_reach__c,
                                        Called_In__c,Campaign_ID__c,Campaign_Marketo__c,CDYNE_Address__c,
                                        CDYNE_Result__c,CDYNE_Status__c,Cell_Coverage__c,Channel__c,
                                        City,Company,Competitive_Deal__c,Competitor_Other__c,Competitor__c,
                                        Completed_Lightmile__c,CongressDistrictNumber__c,ConnectionReceivedId,
                                        ConnectionSentId,Costco_Location__c,Costco_Member_ID__c,
                                        Costco_Member_Type__c,Country,CreatedById,CreatedDate,
                                        Creative_marketo__c,Custom_Lead_Source__c,Data_Quality_Description__c,
                                        Data_Quality_Score__c,DB_Created_Date_without_Time__c,
                                        DB_Lead_Age__c,December__c,Dec_Usage__c,Description,
                                        Direct_Sales_Territory__c,DoNotCall,Email,Email2__c,
                                        EmailBouncedDate,EmailBouncedReason,Email_Sent__c,EPCExecutionDate__c,
                                        EPCPartnerName__c,ETA_ZIP__c,E_mail__c,Fax,February__c,Feb_Usage__c,
                                        Field_Marketing_Branch__c,FirstName,HasOptedOutOfEmail,HasOptedOutOfFax,
                                        Has_Confirmed_Lat_Long__c,HOA__c,Homeownership__c,Homeowner_Email__c,
                                        Industry,LastModifiedById,LastModifiedDate,LastName,LastUpdateDifference__c,LeadOrganizationName__c,
                                        LeadOrganizationOffice__c,LeadSource,Lead_Age_In_Days__c,
                                        Lead_Assignment_Control_Field__c,Lead_Category__c,
                                        Lead_Classification__c,Lead_Created_Date__c,Lead_Distribution__c,
                                        Lead_Email__c,Lead_Generated_by__c,Lead_Gen_Agent__c,Lead_Gen_Partner__c,
                                        Lead_Id__c,Lead_Number__c,Lead_Organization_Location_2__c,
                                        Lead_Organization_Location_Blank__c,Lead_Organization_Location__c,
                                        Lead_Origin__c,Lead_Source_Detailed__c,Lead_Status__c,
                                        Level_Of_SolarEvangelism__c,Lock_Assignment__c,Longitude,
                                        Looked_into_solar_before__c,Main_Panel_Amps__c,March__c,
                                        Market_Assignment_Install__c,Market_Assignment_Sales__c,Mar_Usage__c,
                                        MasterRecordId,Master_Lead_Source_TEST__c,Master_Status__c,May_Usage__c,
                                        May__c,MobilePhone,NumberOfEmployees,only_contact_via_email__c,
                                        Other_decision_maker__c,Other_Utility__c,Over_2_stories__c,OwnerId,
                                        PartnerAccountId,Partner_Account_Number__c,Phone,Placement_marketo__c,
                                        PostalCode,Product_Type__c,Promotion_Code__c,Promotion_Name__c,
                                        Promotion_Type__c,Prospect_Id__c,Rate_Schedule__c,Rating,Reason__c,
                                        RecordTypeId,Referral_Input__c,Referral_Program__c,Referral_Promotion__c,
                                        Referral_web_form__c,Referred_by_Account_Name__c,Referred_by_City__c,
                                        Referred_By_Code__c,Referred_by_Contact_Email__c,
                                        Referred_by_Contact_First_Name__c,Referred_by_Contact_Last_Name__c,
                                        Referred_by_Contact_Phone__c,Referred_by_Contact_Salutation__c,
                                        Referred_By_Contact__c,Referred_by_Country__c,Referred_by_Postal_Code__c,
                                        Referred_by_State__c,Referred_by_Street__c,Referred_by__c,RepID__c,
                                        Replied_to_SR_Email__c,Reported_Status__c,
                                        Retail_Lead_Gen__c,Retail_Sales_Partner_Assigned__c,Retail_Store_ID__c,
                                        Roofing_Type__c,Roof_Azimuth__c,Roof_Qualification__c,Round_Robin_ID__c,
                                        SalesCellPhone__c,SalesOrganizationName__c,
                                        SalesOrgContractExecutionDate__c,SalesRep__c,Sales_Contact_Method__c,
                                        Sales_Partner__c,Sales_Rep_Email__c,Sales_rep_of_referrer__c,Salutation,
                                        Screen_share_ID__c,Secondary_Lead_Gen_Agent__c,
                                        Select_Missed_Call_Email__c,State,
                                        StateLegislativeLower__c,StateLegislativeUpper__c,
                                        State__c,Status,Street,
                                        Sunrun_South_Lead_ID__c,Sunrun_South__c,SystemModstamp,
                                        System_Design_Offset__c,Territory__c,Timeline_urgency__c,
                                        TimeZone__c,Title,ToLatitude__c,ToLongitude__c,Total_YEAR_kWh_use__c,
                                        Total_YEAR_utility_bill_before_solar__c,Typical_bill_summer_months__c,
                                        Typical_bill_winter_months__c,Usage_Option__c,Utility_Company__c,Distributin_Logic_Completed__c 
                                        FROM Lead Where   
                                        Called_In__c = false AND  
                                         Sunrun_South__c=false AND Lock_Assignment__c=false AND (Channel__c='Retail' OR Channel__c='Event' OR Channel__c='Canvassing')
                                         AND 
                                        CreatedDate>=:dt_120 and  CreatedDate<=:dt_60 and isconverted=false order by createddate]);
  }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
      List<Lead> lst_Leads = new List<Lead>();
      // Calling Distribution Logic Method
       List<Contact_Preferences__c> ContactPreferenceList=new List<Contact_Preferences__c>([select id from Contact_Preferences__c where contact__r.email=:userinfo.getUserEmail() and Lead_Routing__c='No']);
      if(ContactPreferenceList.isEmpty()){
          Lead_Distribution_SouthNorth.ByPassChannel = true;
          Lead_Distribution_SouthNorth.assignLeads((List<Lead>)scope);   
      }  
  }

  global void finish(Database.BatchableContext BC){
      
  }
  global void execute(SchedulableContext sc)
  {
      Batch_LeadDistributionLogic leads = new Batch_LeadDistributionLogic();
      if(test.isRunningTest()){
      	database.executebatch(leads,20);
      }
      else
      database.executebatch(leads,1);
  }
  /**********************************
  public Static void scheduleBatch(){
      Batch_LeadDistributionLogic  c = new Batch_LeadDistributionLogic ();       
      String sch1 = '0 0 * * * ?';
      System.schedule('Lead Distribution Job1', sch1, c); 
  
  }
  ************************************/
}