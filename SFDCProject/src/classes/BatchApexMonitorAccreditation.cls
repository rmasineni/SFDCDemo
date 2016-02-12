global class BatchApexMonitorAccreditation implements Database.Batchable<sObject>,Database.AllowsCallouts {
    public string query;
    public id contactRecId;
    public id contactEmpRecId;
    public date stDate;
    public date enddate;
  global BatchApexMonitorAccreditation(string q){
      query = q;
    }        
       
    global Database.QueryLocator start(Database.BatchableContext BC) {        
        return Database.getQueryLocator(query);        
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope) {  
    	List<Contact> contactList=new List<Contact>();
    	Set<id> DeActivatedContactIds=new Set<id>();   
    	
        for(sObject s: scope){ 
          Contact c = (Contact )s;         	  
          c.Previous_Design_Tool__c=c.Design_Tool_Access__c;
          c.Previous_Proposal_Tool__c=c.Proposal_Tool_Access__c;
          c.Tools_Deactivation_Date__c=system.today();
          c.Proposal_Tool_Access__c=null;
          c.Design_Tool_Access__c=null;         
          contactList.add(c);          	  
	     }
	     if(!contactList.isempty()){
	     	update contactList;	     		     	
	     }	        	     	 	          
    }
     global void finish(Database.BatchableContext BC) {   
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];    
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Batch Apex Job' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed '+ a.TotalJobItems + 'batches with '+ a.NumberOfErrors + ' failures.');
        try{
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(exception e){
        system.debug(e);
        }
    }
}