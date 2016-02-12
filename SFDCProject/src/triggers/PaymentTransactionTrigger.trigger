trigger PaymentTransactionTrigger on Payment_Transaction__c (before insert, after insert) {
	
	//We need to change the owner of the payment transaction to same as opportunity, if this payment
	//belongs to an opportunity
	if (Trigger.isBefore && Trigger.isInsert) {
		Sf.paymentService.changeOwnerToOptyOwner(Trigger.new);
	}
    
    Sf.awsSyncService.handlePaymentsTrigger();
}