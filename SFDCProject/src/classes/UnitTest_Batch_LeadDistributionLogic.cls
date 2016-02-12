@isTest(SeeAllData=true)
public with sharing class UnitTest_Batch_LeadDistributionLogic {
	static testmethod void UnitTest_Batch_LeadDistributionLogic(){
            Test.starttest();             
            Lead l=new Lead(lastname='TEst',company='TEst',channel__c='Event',Field_marketing_branch__c='TEst');
            insert l;
            List<Contact_Preferences__c> ContactPreferenceList=new List<Contact_Preferences__c>([select id from Contact_Preferences__c where contact__r.email=:userinfo.getUserEmail() and Lead_Routing__c='No']);
            if(!ContactPreferenceList.isempty()){
            	delete ContactPreferenceList;
            }           
            Batch_LeadDistributionLogic  batch=new Batch_LeadDistributionLogic();          
            ID batchprocessid =database.executeBatch(batch,10);
            String chron = '0 0 23 * * ?';        
         	system.schedule('Test Sched', chron, batch);
            Test.stopTest();
    }
}