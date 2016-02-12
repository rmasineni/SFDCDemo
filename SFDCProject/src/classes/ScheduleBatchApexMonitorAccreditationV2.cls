global class ScheduleBatchApexMonitorAccreditationV2 implements Schedulable{  
    global void execute(SchedulableContext SC) {
            id contactRecId=[select id from recordtype where sobjecttype='Contact' and name='Partner' limit 1].id;
            id contactEmpRecId=[select id from recordtype where sobjecttype='Contact' and name='Employee' limit 1].id;
            date stDate = date.newInstance(2014, 5, 15);
            date endDate = date.newInstance(2014, 7, 31);
            date today=system.today();
            String query='select id,Professional_Certification__c,Tools_Deactivation_Date__c,createddate,Previous_Proposal_Tool__c,Previous_Design_Tool__c,active__c,Proposal_Tool_Access__c,Design_Tool_Access__c from contact where Sells_Sunrun__c=\'Yes\' and Professional_Certification__c!=\'Yes\' and Professional_Certification__c!=\'NA\' and Accreditation_Status__c!=\'Not a salesperson - accreditation not needed\' and active__c=true and (recordtypeid=:contactRecId or recordtypeid=:contactEmpRecId) and (createddate<N_DAYS_Ago:21 and createddate>:stDate) and Tools_Deactivation_Date__c=null';
            if(today>endDate)
            query='select id,Professional_Certification__c,Tools_Deactivation_Date__c,createddate,Previous_Proposal_Tool__c,Previous_Design_Tool__c,active__c,Proposal_Tool_Access__c,Design_Tool_Access__c from contact where Sells_Sunrun__c=\'Yes\' and Professional_Certification__c!=\'Yes\' and Professional_Certification__c!=\'NA\' and Accreditation_Status__c!=\'Not a salesperson - accreditation not needed\' and active__c=true and (recordtypeid=:contactRecId or recordtypeid=:contactEmpRecId) and ((createddate<N_DAYS_Ago:21 and createddate>:stDate) or (createddate<:stDate)) and Tools_Deactivation_Date__c=null';
            if(Test.isRunningTest())
            query='select id,Professional_Certification__c,createddate,Tools_Deactivation_Date__c,Previous_Proposal_Tool__c,Previous_Design_Tool__c,active__c,Proposal_Tool_Access__c,Design_Tool_Access__c from contact where Sells_Sunrun__c=\'Yes\' and Professional_Certification__c!=\'Yes\' and Professional_Certification__c!=\'NA\' and Accreditation_Status__c!=\'Not a salesperson - accreditation not needed\' and active__c=true and (recordtypeid=:contactRecId or recordtypeid=:contactEmpRecId) and createddate<N_DAYS_Ago:21 limit 10';            
            BatchApexMonitorAccreditation  batch=new BatchApexMonitorAccreditation(query);
            batch.contactRecId=contactRecId;
            batch.contactEmpRecId=contactEmpRecId;
            batch.stDate=stDate;
            batch.enddate=endDate;
            database.executeBatch(batch,50);
    }
    
}