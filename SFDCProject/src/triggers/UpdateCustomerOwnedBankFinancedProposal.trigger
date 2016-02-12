trigger UpdateCustomerOwnedBankFinancedProposal on Proposal__c (before update) {
    CustomerOwnedBankFinanceUtil.setCountBankFinancedProposal(Trigger.new);
}