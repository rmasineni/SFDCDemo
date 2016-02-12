trigger ServiceContractTrigger on ServiceContract (before insert, after insert, before update, after update) {
	Sf.awsSyncService.handleContractsTrigger();
}