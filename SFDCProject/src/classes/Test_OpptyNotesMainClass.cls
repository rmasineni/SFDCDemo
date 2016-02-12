@isTest(SeeAllData=true)
public with sharing class Test_OpptyNotesMainClass {
	public static testMethod void myUnitTest() {
   		Account acc = new Account(name='Test1',billingpostalcode='00000',billingstate='CA'); 
        insert acc; 
        Opportunity opp = new Opportunity(name='Test11',Accountid=acc.id,stagename='Created',CloseDate=system.today());
        insert opp;
		       
    	ApexPages.StandardController stdController = new Apexpages.StandardController(opp);
        OpportunityNotesMainClass opptynotesobj = new OpportunityNotesMainClass(stdController);
        opptynotesobj.getoppId();
        opptynotesobj.getAllNotes();
        opptynotesobj.first();
        opptynotesobj.last();
        opptynotesobj.previous();
        opptynotesobj.next();
    }

}