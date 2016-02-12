public with sharing class Test_OpportunityProposalRelatedListExt {
	@isTest(SeeAllData=true)
	static void Test_OpportunityProposalRelatedListExt(){
	Opportunity optyObj1 = TestPRMLibrary.insertOpportunity('ResidentialAccount-3', 'Residential',
																'ResOpty-3', 'Platinum');	
		List<Proposal__C> proposalList = new List<Proposal__C>();
		Proposal__C proposalObj1 = new Proposal__C();
		proposalObj1.Name = 'Proposal-1';
		proposalObj1.Opportunity__c = optyObj1.Id;
		proposalObj1.Upfront_Payment__c = 1000;
		proposalObj1.Proposal_ID__c = 2441242;
		proposalObj1.System_Size_STC_DC__c = 1;
		proposalObj1.Mode_Name__c = 'Mode-1';
		proposalObj1.Date_Issued__c =  date.today();
		proposalObj1.Sales_Rep_Email__c = 'test@gmail.com';
		proposalList.add(proposalObj1);
	insert proposalList;
	OpportunityProposalsRealtedListExt opp1=new OpportunityProposalsRealtedListExt();
	ApexPages.StandardController controller = new Apexpages.Standardcontroller(optyObj1); 
	OpportunityProposalsRealtedListExt opp=new OpportunityProposalsRealtedListExt(controller);
	List<proposal__c> pList=opp.ProposalList;
	boolean b=opp.hasNext;
	b=opp.hasPrevious;
	opp.next();
	opp.previous();
	Integer i;
	i=opp.pageNumber;
	i=opp.pageSize;
	pList=opp1.ProposalList;
	}

}