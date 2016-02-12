global class Contact_CSLBApplicationsBatch implements Database.Batchable <sObject>, Database.Stateful{
    public List<Id> contactIds;
    public List<String> applicationstatus;
    public String query = null;
    Public Boolean testing;
    public String YES = 'Yes';
    Contact_CSLBApplications cslb; 
    public Contact_CSLBApplicationsBatch(){
        contactIds = new List<Id>();
        applicationstatus = new List<String>();
        applicationstatus.add('Submitted');
        applicationstatus.add('Resubmitted');
        testing = false;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        cslb = new  Contact_CSLBApplications();
        query = cslb.getCSLBApplicationsQuery(contactIds, testing);
        System.debug('CSLB query: ' + query );
        return Database.getQueryLocator(query);
    }

   global void execute(Database.BatchableContext BC, List<sObject> scope) {
        System.debug('scope: ' + scope);
        cslb.processCSLBApplications((List<Contact>) scope);
        return;
    }
    
    global void finish(Database.BatchableContext BC){
		BatchUtil.processBatchErrors(bc);
    }  
}