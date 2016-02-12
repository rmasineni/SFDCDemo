public  class Contact_ExpiredCSLBApplications {
	public static String GRANTED = 'Granted';
	public static String NOT_NEEDED = 'Not Needed';
	public static String REQUESTED = 'Requested';
	public static String RECEIVED = 'Received';
	public static String REVOKED = 'Revoked';
	
	public static String  emailTemplateName = 'CSLBApplicationStatusNotReceived';
	public static Map<String, EmailTemplate> mapEmailTemplatesByName;
    public String getExpiredCSLBApplicationsQuery(List<Id> contactIds, Boolean testing){
        String sqlQuery = 'Select Id, CSLB_application_end_date__c, Application_Status__c, Application_Submitted__c, ' ;
        sqlQuery += '  e_sign_documents_access__c, Delegated_Admin_Access__c, Can_Run_Change_Orders__c, ';      
        sqlQuery += '  Proposal_Tool_Access__c, Design_Tool_Access__c, Partner_Portal_Access__c, active__c ';     
        sqlQuery += '  from Contact ';      
        sqlQuery += '  where Application_Status__c != :APPROVED ';
        sqlQuery += ' and Sells_Sunrun__c = :YES AND Sells_in_CA__c =: YES ' ;
        sqlQuery += ' and CSLB_application_end_date__c != null '; 
        sqlQuery += ' and CSLB_application_end_date__c < today ';   
        sqlQuery += ' and (e_sign_documents_access__c != :RevokedStatus ';
        sqlQuery += ' OR Can_Run_Change_Orders__c != :RevokedStatus ';
        sqlQuery += ' OR Proposal_Tool_Access__c != :RevokedStatus ';
        sqlQuery += ' OR Design_Tool_Access__c != :RevokedStatus ) ';
        if(contactIds != null && contactIds.size() > 0){
            sqlQuery += ' AND Id in :contactIds ';
        }
        System.debug('sqlQuery: ' + sqlQuery);
        return sqlQuery;
    }
    
    public void processExpiredCSLBApplications(List<Contact> contactRecords){
        
        List<Contact> rejectedApplications = new List<Contact>();
        List<Messaging.SingleEmailMessage> lstEmails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = null;
        Map<Id, Contact> expiredApplicationStatus = new Map<Id, Contact>();

		// Create a cache of EmailTemplates, indexed by Name
		if (mapEmailTemplatesByName == null) {
		    List<EmailTemplate> lstEmailTemplates = [select id, Name from   EmailTemplate 
		                                                where  IsActive=true 
		                                                and (Name = :emailTemplateName)];
		    mapEmailTemplatesByName = new Map<String, EmailTemplate>();
		    for (EmailTemplate et : lstEmailTemplates) mapEmailTemplatesByName.put(et.Name, et);
		}

		List<Contact> modifiedContacts = new List<Contact>();
        for(Contact contactObj : contactRecords){
            if(contactObj.CSLB_application_end_date__c < date.today()){
				revokeSalesToolsAccess(contactObj);
				modifiedContacts.add(contactObj);
            }
        }
        
        if(modifiedContacts.size() > 0){
            update modifiedContacts;
        }
 		
 		System.debug('modifiedContacts: ' + modifiedContacts);
        for(Contact contactObj : modifiedContacts){
        	if(contactObj.active__c == true){
            	email = processEmail(contactObj);
            	if (email != null) lstEmails.add(email);
        	}			
        }        

        if(lstEmails.size() > 0){
            Messaging.sendEmail(lstEmails, false); 
        }        

    }

	public static void revokeSalesToolsAccess(Contact contactObj){
		contactObj.Proposal_Tool_Access__c = (contactObj.Proposal_Tool_Access__c == GRANTED) ? REVOKED 
												: ((contactObj.Proposal_Tool_Access__c == NOT_NEEDED 
													|| contactObj.Proposal_Tool_Access__c == REQUESTED) ? NOT_NEEDED : contactObj.Proposal_Tool_Access__c);

		contactObj.Design_Tool_Access__c = (contactObj.Design_Tool_Access__c == GRANTED) ? REVOKED 
												: ((contactObj.Design_Tool_Access__c == NOT_NEEDED 
													|| contactObj.Design_Tool_Access__c == REQUESTED) ? NOT_NEEDED : contactObj.Design_Tool_Access__c);

		contactObj.e_sign_documents_access__c = (contactObj.e_sign_documents_access__c == GRANTED) ? REVOKED 
												: ((contactObj.e_sign_documents_access__c == NOT_NEEDED 
													|| contactObj.e_sign_documents_access__c == REQUESTED) ? NOT_NEEDED : contactObj.e_sign_documents_access__c);

		contactObj.Can_Run_Change_Orders__c = (contactObj.Can_Run_Change_Orders__c == GRANTED) ? REVOKED 
												: ((contactObj.Can_Run_Change_Orders__c == NOT_NEEDED 
													|| contactObj.Can_Run_Change_Orders__c == REQUESTED) ? NOT_NEEDED : contactObj.Can_Run_Change_Orders__c);
	}
 
    public static Messaging.SingleEmailMessage processEmail(Contact contactObj){
    	System.debug('Messaging.SingleEmailMessage processEmail');
        Messaging.SingleEmailMessage email = null;
        EmailTemplate et = mapEmailTemplatesByName.get(emailTemplateName);
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