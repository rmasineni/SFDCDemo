global class BatchApexWarningEmail implements Database.Batchable<sObject>,Database.AllowsCallouts {
    public string query;
    public id contactRecId;
    public id contactEmpRecId;
    public date stDate;
    public date endDate;
  global BatchApexWarningEmail(string q){
      query = q;
    }        
       
    global Database.QueryLocator start(Database.BatchableContext BC) {        
        return Database.getQueryLocator(query);        
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope) {  
        OrgWideEmailAddress org=[select id, Address, DisplayName from OrgWideEmailAddress where displayname='Sunrun Partner Concierge'or displayname='Sunrun Sales Help' limit 1];
        List<Contact> contactList=new List<Contact>();
        List< Messaging.SingleEmailMessage> emailList=new List< Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplate = [SELECT id,body,subject,HtmlValue
                            FROM EmailTemplate
                            WHERE  name = 'Salesman Accreditation- Warning' limit 1];
    
        for(sObject s: scope){ 
          Contact c = (Contact )s;          
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage() ;
            mail.setTargetObjectId(c.id);
            mail.setTemplateId(emailTemplate.id);
            mail.setOrgWideEmailAddressId(org.id);
            if(c.email!=null)
            emailList.add(mail);                                                                      
         }              
         if(!emailList.isempty()){
            Messaging.sendEmail(emailList);
         }                                
    }
     global void finish(Database.BatchableContext BC) {   
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];    
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email, Label.BatchUserId};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Batch Apex Job ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed '+ a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
        try{
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(exception e){
        	system.debug(e);
        }
    }
}