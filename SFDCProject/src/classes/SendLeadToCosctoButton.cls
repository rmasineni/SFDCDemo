global class SendLeadToCosctoButton extends BaseClass{
   public static final String Failure = 'Sync Failed, Please Contact System Admin';
   public static final String Success = 'Success';
   webservice static String sendLead(Id leadId){
   List<Lead> leadsToBeSynced = new List<Lead>();  
   Lead LeadObj=[Select FirstName,
                    LastName,
                    Title,
                    Street,
                    City,
                    State,
                    PostalCode,
                    Phone,
                    Alternate_Phone__c,
                    Email,
                    Notes__c,
                    Contact_Costco_Member_ID__c,
                    External_Sync_InProgress__c,
                    External_Sync_Details__c,
                    External_Sync_Status__c,
                    External_Sync_System__c,
                    External_Id__c,
                    Channel__c,
                    Custom_lead_source__c,
                    Costco_Store_Id__c,
                    Retail_Lead_Source__c from lead where id=:leadId];
   if(Sf.settingsService.getBoolean('CostcoLeadSyncEnabled', false)){
      if (leadObj.external_id__c==null && LeadObj.Channel__c == 'Retail' && LeadObj.Custom_lead_source__c!=null && LeadObj.Custom_lead_source__c.contains('Costco') && LeadObj.firstname!=null && LeadObj.street!=null && LeadObj.city!=null && LeadObj.state!=null &&
            LeadObj.postalcode!=null && LeadObj.phone!=null && LeadObj.Costco_Store_Id__c!=null) {
             leadsToBeSynced.add(LeadObj);
         }
         else return Failure;
     }
     else return Failure;
    if (!leadsToBeSynced.isEmpty()) {
        CallCostcoFromButton  CCB=new CallCostcoFromButton();  
        CCB.CallCostco(leadsToBeSynced);
       }
       return Success;     
   }
}