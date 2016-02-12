@isTest(SeeAllData=true)
    public with sharing class Test_PartnerDesignOption {    
        static testmethod void myTest(){
            Account acc = new Account(name='Test13',billingpostalcode='9000',billingstate='CA'); 
            insert acc; 
            Opportunity opp = new Opportunity(name='Test123',Accountid=acc.id,stagename='Created',CloseDate=system.today());
            insert opp;
            Lead lead = new Lead(Channel__c='Email',LastName='Testq',Company='Sunrun');
            insert Lead;
            
                ApexPages.StandardController stdController = new Apexpages.StandardController(lead);
                PartnerDesignOption partnerdesopt = new PartnerDesignOption(stdController);
                partnerdesopt.getleadDesignOption();
            
                partnerdesopt.first();
                partnerdesopt.last();
                partnerdesopt.previous();
                partnerdesopt.next();
        }
        

}