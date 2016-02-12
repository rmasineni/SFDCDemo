@isTest(SeeAllData=true)
private class Test_LeadNotesMainClass {

   public static testMethod void myUnitTest() {
   		Lead lead = new lead(lastname='Test',company='Tst');		
		insert lead;
		       
    	ApexPages.StandardController stdController = new Apexpages.StandardController(lead);
        LeadNotesMainClass leadnotesobj = new LeadNotesMainClass(stdController);
        leadnotesobj.getLId();
        leadnotesobj.getAllNotes();
        leadnotesobj.first();
        leadnotesobj.last();
        leadnotesobj.previous();
        leadnotesobj.next();
    }
}