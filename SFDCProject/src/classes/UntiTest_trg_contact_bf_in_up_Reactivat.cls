@istest
public with sharing class UntiTest_trg_contact_bf_in_up_Reactivat {
    static testmethod void UntiTest_trg_contact_bf_in_up_Reactivat(){
        Account a=new Account(name='Test');
        insert a;       
        Contact c=new contact(firstname='Test11',lastname='Test',account=a,active__c=false,Previous_Design_Tool__c='Revoked',Previous_Partner_Portal__c='Revoked',Previous_Proposal_Tool__c='Revoked');
        insert c;
        c.Accreditation_Status__c='Accredited';
        c.Accreditation_date__c=system.today();
        update c;
    }
}