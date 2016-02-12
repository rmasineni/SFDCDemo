@isTest(SeeAllData=true)
public with sharing class Test_OverridePartnerCaseTab {
	public static testmethod void Test_OverridePartnerCaseTab(){
	
	Case c = new Case(status='Test1',reason='test11',Cause_of_Issue__c='test',Origin='yyy'); 
	insert c;	
    List<Case>caselist = new List<Case>();
    caselist.add(c);
    ApexPages.StandardSetController controller = new Apexpages.StandardSetController(caselist);
    	
    	
    	ApexPages.currentPage().getParameters().put('retURL','/apex/CaseSearch');
    	//ApexPages.currentPage().getParameters().put('oppId',opp.id);
    	ApexPages.currentPage().getParameters().put('RecordType','012g00000008Y19');
    	ApexPages.currentPage().getParameters().put('ent','entvalue1');
    	OverridePartnerCaseTab opct = new OverridePartnerCaseTab(controller);
    	opct.redirectCaseTab();
	}

}