trigger CustomerCreditTrigger on Customer_Credit__c (before insert, after insert) {
	Sf.awsSyncService.handleCreditsTrigger();
}