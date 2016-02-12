@isTest (SeeAllData=true)
public class Test_LeadNewNoteClass {
	public static testMethod void TestLeadNewNoteClass(){
	    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('PartnerPortal');
		mock.setStatusCode(200); // Or other appropriate HTTP status code
		mock.setHeader('Content-Type', 'application/json'); // Or other appropriate MIME type like application/xml
		Test.setMock(HttpCalloutMock.class, mock);
		
		Test.startTest();     
        Lead lead = [select id,name from Lead where isConverted = false limit 1];       
        
	    ApexPages.StandardController stdcon = new ApexPages.StandardController(lead);
	    LeadNewNoteClass newNotesObj = new LeadNewNoteClass(stdcon);				
		
		newNotesObj.getwhichOrg();
		newNotesObj.saveForm();
		newNotesObj.noteValue='222';
		newNotesObj.saveForm();
		/* Notes__c notes = new Notes__c();
	    notes.Notes__c = 'Testing Notes';
	    notes.Lead__c = lead.id;
	    notes.Notes_Added_By__c = 'SunRun';
	    insert notes;
	    newNotesObj.isSaved=true;*/
		Id userId = LeadTestAccount__c.getValues('Sunrun CRM').TestPartnerUserId__c;
		//Id userId = '005g0000000NUUc';
		User partnerUser = [Select id, name, email from User where Id =:userId];
	
		System.runAs(partnerUser){
			        
			newNotesObj.getwhichOrg();
      		newNotesObj.saveForm();
      		
		}
	    Test.stopTest();
	    
  	}
}