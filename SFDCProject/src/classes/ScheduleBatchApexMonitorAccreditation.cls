global class ScheduleBatchApexMonitorAccreditation implements Schedulable{  
    global void execute(SchedulableContext SC) {
            id contactRecId=[select id from recordtype where sobjecttype='Contact' and name='Partner' limit 1].id;
            id contactEmpRecId=[select id from recordtype where sobjecttype='Contact' and name='Employee' limit 1].id;
            String query='select id,createddate,Deactivation_Reason__c,Previous_Proposal_Tool__c,Previous_Partner_Portal__c,Previous_Design_Tool__c,active__c,Proposal_Tool_Access__c,Partner_Portal_Access__c,Design_Tool_Access__c from contact where Sells_Sunrun__c=\'Yes\' and Accreditation_Status__c!=\'Accredited\' and Accreditation_Status__c!=\'Not a salesperson - accreditation not needed\' and active__c=true and (recordtypeid=:contactRecId or recordtypeid=:contactEmpRecId) and createddate<N_DAYS_Ago:21';
            if(Test.isRunningTest())
            query='select id,createddate,Deactivation_Reason__c,Previous_Proposal_Tool__c,Previous_Partner_Portal__c,Previous_Design_Tool__c,active__c,Proposal_Tool_Access__c,Partner_Portal_Access__c,Design_Tool_Access__c from contact where Sells_Sunrun__c=\'Yes\' and Accreditation_Status__c!=\'Accredited\' and Accreditation_Status__c!=\'Not a salesperson - accreditation not needed\' and active__c=true and (recordtypeid=:contactRecId or recordtypeid=:contactEmpRecId) and createddate<N_DAYS_Ago:21 limit 10';            
            BatchApexMonitorAccreditation  batch=new BatchApexMonitorAccreditation(query);
            batch.contactRecId=contactRecId;
            batch.contactEmpRecId=contactEmpRecId;
            database.executeBatch(batch,10);
    }
    
}