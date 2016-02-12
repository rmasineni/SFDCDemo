public class Contact_CSLBApplications {
    
    public static Map<String, EmailTemplate> mapEmailTemplatesByName;
    public String getCSLBApplicationsQuery(List<Id> contactIds, Boolean testing){
        String sqlQuery = 'Select Id, CSLB_application_end_date__c, Application_Status__c, Application_Submitted__c, ' ;
        sqlQuery += '  active__c from Contact ';      
        sqlQuery += ' where CSLB_application_end_date__c != null ';
		sqlQuery += ' AND Sells_Sunrun__c = :YES AND Sells_in_CA__c =: YES ' ;
        sqlQuery += ' AND Application_Status__c in :applicationstatus ';        
        if(contactIds != null && contactIds.size() > 0){
            sqlQuery += ' AND Id in :contactIds ';
        }
        System.debug('sqlQuery: ' + sqlQuery);
        return sqlQuery;
    }

    public void processCSLBApplications(List<Contact> contactRecords){
        
        List<Contact> rejectedApplications = new List<Contact>();
        Map<Id, Contact> applicationStatus90days = new Map<Id, Contact>();
        Map<Id, Contact> applicationStatus60days = new Map<Id, Contact>();
        Map<Id, Contact> applicationStatus30days = new Map<Id, Contact>();
        Map<Id, Contact> applicationStatus15days = new Map<Id, Contact>();
        Map<Id, Contact> applicationStatus7days = new Map<Id, Contact>();
        Map<Id, Contact> applicationStatus1day = new Map<Id, Contact>();
        Map<Id, Contact> expiredApplicationStatus = new Map<Id, Contact>();
        Date days90 = date.today().addDays(90);
        Date days60 = date.today().addDays(60);
        Date days30 = date.today().addDays(30);
        Date days15 = date.today().addDays(5);
        Date days7 = date.today().addDays(7);
        Date day1 = date.today().addDays(1);
        
        for(Contact contactObj : contactRecords){
            
            if((contactObj.Application_Status__c != 'Submitted') 
            && (contactObj.Application_Status__c != 'Resubmitted'))
             {
                continue;
             }
            if(contactObj.CSLB_application_end_date__c == days90){
                applicationStatus90days.put(contactObj.Id, contactObj);
            }else if(contactObj.CSLB_application_end_date__c == days60){
                applicationStatus60days.put(contactObj.Id, contactObj);
            }else if(contactObj.CSLB_application_end_date__c == days30){
                applicationStatus30days.put(contactObj.Id, contactObj);
            }else if(contactObj.CSLB_application_end_date__c == days15){
                applicationStatus15days.put(contactObj.Id, contactObj);
            }else if(contactObj.CSLB_application_end_date__c == days7){
                applicationStatus7days.put(contactObj.Id, contactObj);
            }else if(contactObj.CSLB_application_end_date__c == day1){
                applicationStatus1day.put(contactObj.Id, contactObj);
            }
        }
        
        // Create a cache of EmailTemplates, indexed by Name
        if (mapEmailTemplatesByName == null) {
            List<EmailTemplate> lstEmailTemplates = [select id, Name from   EmailTemplate 
                                                        where  IsActive=true 
                                                        and (Name like 'CSLBApplicationStatus%')];
            mapEmailTemplatesByName = new Map<String, EmailTemplate>();
            for (EmailTemplate et : lstEmailTemplates) mapEmailTemplatesByName.put(et.Name, et);
        }

        String strEmailTemplateName = '';
        List<Messaging.SingleEmailMessage> lstEmails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = null;
        for(Contact contactObj : applicationStatus90days.values()){
            strEmailTemplateName = 'CSLBApplicationStatus_90days';
            email = processEmail(contactObj, strEmailTemplateName);
            if (email != null) lstEmails.add(email);
        }
        for(Contact contactObj : applicationStatus60days.values()){
            strEmailTemplateName = 'CSLBApplicationStatus_60days';
            email = processEmail(contactObj, strEmailTemplateName);
            if (email != null) lstEmails.add(email);
        }
        for(Contact contactObj : applicationStatus30days.values()){
            strEmailTemplateName = 'CSLBApplicationStatus_30days';
            email = processEmail(contactObj, strEmailTemplateName);
            if (email != null) lstEmails.add(email);
        }
        for(Contact contactObj : applicationStatus15days.values()){
            strEmailTemplateName = 'CSLBApplicationStatus_15days';
            email = processEmail(contactObj, strEmailTemplateName);
            if (email != null) lstEmails.add(email);
        }
        for(Contact contactObj : applicationStatus7days.values()){
            strEmailTemplateName = 'CSLBApplicationStatus_07days';
            email = processEmail(contactObj, strEmailTemplateName);
            if (email != null) lstEmails.add(email);
        }
        for(Contact contactObj : applicationStatus1day.values()){
            strEmailTemplateName = 'CSLBApplicationStatus_01days';
            email = processEmail(contactObj, strEmailTemplateName);
            if (email != null) lstEmails.add(email);
        }

        if(lstEmails.size() > 0){
            Messaging.sendEmail(lstEmails, false); 
        }
    }
    
    public static Messaging.SingleEmailMessage processEmail(Contact contactObj, String strEmailTemplateName){
        Messaging.SingleEmailMessage email = null;
        if(contactObj.active__c != true)
        	return email;
        System.debug('strEmailTemplateName: ' + strEmailTemplateName);
        EmailTemplate et = mapEmailTemplatesByName.get(strEmailTemplateName);
        System.debug('et: ' + et);
        if (et != null) {
            // Construct the email message
            email = new Messaging.SingleEmailMessage();
            email.setSenderDisplayName(Label.EmailNotificationDisplayName);
            email.setTemplateID(et.id);
            email.setSaveAsActivity(true);
            email.setTargetObjectId(contactObj.Id);  // A validation rule ensures that Contact is populated
            //email.setWhatId();        
        }
        return  email;
    }

}