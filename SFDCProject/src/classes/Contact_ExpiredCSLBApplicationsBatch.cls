global class Contact_ExpiredCSLBApplicationsBatch implements Database.Batchable <sObject>, Database.Stateful{

    public Date today;
    public List<Id> contactIds;
    public String query = null;
    Public Boolean testing;
    public String RevokedStatus = 'Revoked';
    public String YES = 'Yes';
    public String APPROVED = 'Approved';
    Contact_ExpiredCSLBApplications expiredCSLBApplicationsObj; 
    public Contact_ExpiredCSLBApplicationsBatch(){
        contactIds = new List<Id>();
        testing = false;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        expiredCSLBApplicationsObj = new  Contact_ExpiredCSLBApplications();
        query = expiredCSLBApplicationsObj.getExpiredCSLBApplicationsQuery(contactIds, testing);
        System.debug('CSLB query: ' + query );
        return Database.getQueryLocator(query);
    }

   global void execute(Database.BatchableContext BC, List<sObject> scope) {
        System.debug('scope: ' + scope);
        expiredCSLBApplicationsObj.processExpiredCSLBApplications((List<Contact>) scope);
        return;
    }
    
    global void finish(Database.BatchableContext BC){
		BatchUtil.processBatchErrors(bc);
    }  

}