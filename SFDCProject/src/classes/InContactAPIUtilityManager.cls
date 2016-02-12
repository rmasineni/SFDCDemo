public class InContactAPIUtilityManager {
    public static void  InContactLeadInfo(List<Lead> leadAPIList){
     if(!leadAPIList.isEmpty()){
            Set<Id> leadIds = new Set<Id>();
            List<InContactService.LeadFilterClass> leadFilterList =  new List<InContactService.LeadFilterClass>();
            for(Lead lead :leadAPIList){
                InContactService.LeadFilterClass lfList =new InContactService.LeadFilterClass();
                Id leadId= lead.id;
                lfList.Lead_Id_18= leadId;
                lfList.Phone= lead.Phone;
                lfList.State=lead.State;
                lfList.Lead_Source= lead.Custom_Lead_Source__c;
                lfList.Lead_Type= lead.Lead_Type__c;
                lfList.Dial_Status= lead.Dial_Status__c;
                lfList.Future_Contact_Date_Time= lead.Future_Contact_Date_Time__c;
                lfList.FirstName=lead.FirstName;
                lfList.LastName= lead.LastName;
                lfList.PostalCode= lead.PostalCode;
                lfList.Campaign_Call_Attempts= lead.Campaign_Call_Attempts__c;
                lfList.InContact_Priority=true;
                lfList.Voicemail= lead.Voicemail__c;
                lfList.Caller_ID= lead.Caller_ID__c;
                leadFilterList.add(lfList);
                
            }
            system.debug('leadFilterListleadFilterList>' +  leadFilterList);
            InContactService.InConatctList(leadFilterList);
     }
    }
        
  
}