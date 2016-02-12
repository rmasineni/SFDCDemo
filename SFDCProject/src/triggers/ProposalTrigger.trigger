trigger ProposalTrigger on Proposal__c (before insert, after insert, before update, after update) {
	Sf.awsSyncService.handleProposalsTrigger();
}