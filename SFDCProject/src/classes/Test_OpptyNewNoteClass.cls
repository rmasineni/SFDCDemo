@isTest(SeeAllData=true)
public with sharing class Test_OpptyNewNoteClass {
 public static testmethod void Test_OpptyNewNoteClass(){
 	Test.StartTest();
 	StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('PartnerPortal');
		mock.setStatusCode(200); // Or other appropriate HTTP status code
		mock.setHeader('Content-Type', 'application/json'); // Or other appropriate MIME type like application/xml
		Test.setMock(HttpCalloutMock.class, mock);
		Opportunity opp = [select id,name from Opportunity limit 1];
		ApexPages.StandardController stdcon = new ApexPages.StandardController(opp);
	    OpportunityNewNoteClass opptynewnotes = new OpportunityNewNoteClass(stdcon);
 
       opptynewnotes.getwhichOrg();
		opptynewnotes.saveForm();
		opptynewnotes.noteValue='222';
		opptynewnotes.saveForm();
		
		Id userId = LeadTestAccount__c.getValues('Sunrun CRM').TestPartnerUserId__c;
		//Id userId = '005g0000000NUUc';
		User partnerUser = [Select id, name, email from User where Id =:userId];
	
		System.runAs(partnerUser){
			        
			opptynewnotes.getwhichOrg();
      		opptynewnotes.saveForm();
		}
		 Test.stopTest();
      		
		}
 }