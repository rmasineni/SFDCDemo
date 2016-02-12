@isTest(SeeAllData=true)
public with sharing class Test_OpptyEditNoteClass {
	public static testmethod void Test_OpptyEditNoteClass (){
		   
     StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('PartnerPortal');
		mock.setStatusCode(200); // Or other appropriate HTTP status code
		mock.setHeader('Content-Type', 'application/json'); // Or other appropriate MIME type like application/xml
		Test.setMock(HttpCalloutMock.class, mock);
		Test.StartTest();
		
		Opportunity opp = [select id,name from Opportunity limit 1];
        Notes__c notes = new Notes__c();
	    notes.Notes__c = 'Testing Notes';
	    notes.Opportunity__c = opp.id;
	    notes.Notes_Added_By__c = 'SunRun';
	    insert notes;
	    
	       ApexPages.StandardController stdcon = new ApexPages.StandardController(notes);
    OpportunityEditNoteClass  editNotesObj = new OpportunityEditNoteClass (stdcon);
    
    	
   	String bodyVal = editNotesObj.getBodyVal();
   	editNotesObj.contentMode();
   	editNotesObj.save();
   	editNotesObj.setBodyVal(bodyVal);
   	
    
    Test.stopTest();
	}

}