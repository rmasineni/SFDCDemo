global class BatchApexDeletePAS implements Database.Batchable<sObject>,Database.AllowsCallouts {
    public string query;
  global BatchApexDeletePAS(string q){
      query = q;
    }        
       
    global Database.QueryLocator start(Database.BatchableContext BC) {        
        return Database.getQueryLocator(query);        
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope) {      	
          List<Partner_Assignment_Staging__c> pasList = (List<Partner_Assignment_Staging__c> )scope;
          delete pasList;               	 	          
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