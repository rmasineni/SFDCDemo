@isTest(SeeAllData=true)
public with sharing class Test_CustomOpptyContactRole {
    public static testmethod void Test_CustomOpptyContactRole(){         
        Test.StartTest();
        Account acc = new Account(name='Test1',billingpostalcode='00000',billingstate='CA'); 
        insert acc;       
        Opportunity opp = new Opportunity(name='Test11',Accountid=acc.id,stagename='Created',CloseDate=system.today());
        insert opp; 
        Contact c = new contact(firstname='FirstTest',lastname='contact1',Ultimate_Parent_Account__c = acc.Id); 
         insert c;
        OpportunityContactRole ocr=new OpportunityContactRole(opportunityid=opp.id,contactid=c.id,isprimary=true);
        insert ocr;
        ApexPages.StandardController controller = new Apexpages.Standardcontroller(opp);
        system.currentPageReference().getParameters().put('oppid',opp.id); 
        CustomOptyContactRole.ContactRoleWrapper crwrapper=new CustomOptyContactRole.ContactRoleWrapper();      
        
        CustomOptyContactRole controle = new CustomOptyContactRole(controller);
        
        
        controle.getContactRoles();
        controle.getActions();
        controle.userActions();
        controle.actionName='New Contact';
        Pagereference ref;
        //ref = new PageReference('/apex/NewCustomerContactOverridden');
        ref=controle.userActions();
        
        controle.actionName='NewContact';
        ref=controle.userActions(); 
        controle.actionName='EditContactRoles';
        ref=controle.userActions(); 

        controle.getContactRoleWrapperListSize();
        controle.ConfirmSaveContactRoles();
        controle.saveContactRoles();        
        controle.voidProposals=true;
        controle.enableConfirmSave=false;
        controle.saveContactRoles();
        controle.isPartnerUser=true;
        controle.actionName='NewContact';
        ref=controle.userActions(); 
        controle.actionName='EditContactRoles';
        ref=controle.userActions();                 
        controle.cancel();
        
        
        Test.StopTest();
    }


}