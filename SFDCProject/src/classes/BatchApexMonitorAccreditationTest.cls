@istest(SeeAllData=true)
public with sharing class BatchApexMonitorAccreditationTest {
	static testmethod void BatchApexMonitorAccreditationTest(){
			Test.starttest();			
			String query='select id,createddate,Deactivation_Reason__c,Previous_Proposal_Tool__c,Previous_Partner_Portal__c,Previous_Design_Tool__c,active__c,Proposal_Tool_Access__c,Partner_Portal_Access__c,Design_Tool_Access__c from contact limit 10';
	   		BatchApexMonitorAccreditation  batch=new BatchApexMonitorAccreditation(query);	   		
	   		ID batchprocessid =database.executeBatch(batch,10);
	   		Test.stopTest();
	}
}