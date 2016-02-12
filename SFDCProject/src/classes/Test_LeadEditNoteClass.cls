@isTest (SeeAllData=true)
public class Test_LeadEditNoteClass {
  public static testMethod void TestLeadEditNoteClass(){
    
     //
     
     StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('PartnerPortal');
		mock.setStatusCode(200); // Or other appropriate HTTP status code
		mock.setHeader('Content-Type', 'application/json'); // Or other appropriate MIME type like application/xml
		Test.setMock(HttpCalloutMock.class, mock);
		
    Test.startTest();
       /* Lead lead = new Lead();
        lead.FirstName = 'Helena';
        lead.LastName = 'Suermann';
        lead.Company = 'Test Company';
        lead.Utility_Company__c = 'P&G';
        lead.Email = 'Helena.Suermann@yopMail.com';
        lead.Phone = '4102556542';
        lead.Street = '897 Independence Ave';
        lead.City = 'Mountain View';
        lead.State = 'CA';
        lead.Country = 'USA';
        lead.Average_Monthly_Electric_Bill__c = 75;
        lead.Status = 'Open';
        insert lead; */
        Lead lead = [select id,name from Lead where isConverted = false limit 1];
        
        Notes__c notes = new Notes__c();
	    notes.Notes__c = 'Testing Notes';
	    notes.Lead__c = lead.id;
	    notes.Notes_Added_By__c = 'SunRun';
	    insert notes;
	             
    ApexPages.StandardController stdcon = new ApexPages.StandardController(notes);
    LeadEditNoteClass editNotesObj = new LeadEditNoteClass(stdcon);
   	
   	
   	String bodyVal = editNotesObj.getBodyVal();
   	editNotesObj.contentMode();
   	editNotesObj.save();
   	editNotesObj.setBodyVal(bodyVal);
    
    Test.stopTest();
   
  
  }
  
}