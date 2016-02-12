global class ScheduleBatchApexWaringEmail implements Schedulable{  
    global void execute(SchedulableContext SC) {
            id contactRecId=[select id from recordtype where sobjecttype='Contact' and name='Partner' limit 1].id;
            id contactEmpRecId=[select id from recordtype where sobjecttype='Contact' and name='Employee' limit 1].id;
            String query='select id,email,createddate from contact where Sells_Sunrun__c=\'Yes\' and Accreditation_Status__c!=\'Accredited\' and Accreditation_Status__c!=\'Not a salesperson - accreditation not needed\' and active__c=true and (recordtypeid=:contactRecId or recordtypeid=:contactEmpRecId) and createddate=N_DAYS_Ago:14';
            if(Test.isRunningTest())
            query='select id,email,createddate from contact where Sells_Sunrun__c=\'Yes\' and Accreditation_Status__c!=\'Accredited\' and Accreditation_Status__c!=\'Not a salesperson - accreditation not needed\' and active__c=true and (recordtypeid=:contactRecId or recordtypeid=:contactEmpRecId) and createddate=N_DAYS_Ago:14 limit 10';            
            BatchApexWarningEmail  batch=new BatchApexWarningEmail(query);
            batch.contactRecId=contactRecId;
            batch.contactEmpRecId=contactEmpRecId;
            database.executeBatch(batch,90);
    }
    
}