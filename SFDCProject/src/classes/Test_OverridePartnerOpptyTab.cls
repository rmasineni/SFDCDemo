@isTest(SeeAllData=true)
public with sharing class Test_OverridePartnerOpptyTab {
	public static testmethod void Test_OverridePartnerOpptyTab(){
		 Account acc = new Account(name='Test1',billingpostalcode='00000',billingstate='CA'); 
    insert acc; 
    Opportunity opp = new Opportunity(name='Test11',Accountid=acc.id,stagename='Created',CloseDate=system.today());
    insert opp;
    List<Opportunity>opplist = new List<Opportunity>();
    opplist.add(opp);
    ApexPages.StandardSetController controller = new Apexpages.StandardSetController(opplist);
    	
    	
    	ApexPages.currentPage().getParameters().put('retURL','/apex/OpportunitySearch');
    	//ApexPages.currentPage().getParameters().put('oppId',opp.id);
    	ApexPages.currentPage().getParameters().put('RecordType','012g00000008Y19');
    	ApexPages.currentPage().getParameters().put('ent','entvalue1');
    	OverridePartnerOpptyTab opot = new OverridePartnerOpptyTab(controller);
    	opot.redirectOpptyTab();
	}

}