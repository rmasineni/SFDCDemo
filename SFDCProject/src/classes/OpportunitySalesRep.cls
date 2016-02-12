public with sharing class OpportunitySalesRep {
	@future
	public static void OpportunitySalesRep(set <id> ids){
	List<opportunity> OppList=new List<Opportunity>([select id,salesrep__c,Proposal_ID__c from opportunity where id in:ids]);
	List<opportunity> updateList=new List<Opportunity>();
	for(opportunity o:OppList){
		if(o.SalesRep__c!=null&&o.Proposal_ID__c!=null){
		 o.ownerid=o.salesrep__c;
		 updateList.add(o);
		}
	}
	if(!updateList.isempty())
	update updateList;
	}
}