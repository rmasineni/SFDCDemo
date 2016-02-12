trigger ReferralTrigger on Referral_Input__c (before insert, after insert, before update, after update, before delete, after delete) {
    Sf.ambassadorSyncService.handleReferralsTrigger();
}