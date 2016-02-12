trigger trg_before_insert_update_fillAccstate on Opportunity (after insert) {
	Map<string,string> accIds=new Map<string,string>();
	for(opportunity opp:trigger.new){
	accIds.put(opp.accountid,opp.state__c);
	}
	List<Account> accList;
	if(!accIds.isempty())
	accList=[select id,state__c from account where id in:accIds.keyset()];
	for(Account acc:accList){
	acc.state__c=accIds.get(acc.id);
	}
	if(!accList.isempty())	
	update accList;

}