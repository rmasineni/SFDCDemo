@isTest(SeeAllData=true)
public with sharing class UnitTest_OverrideOpptyEditButton {
    static testmethod void UnitTest_OverrideOpptyEditButton(){
        
        User u;
        Account acc;
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        /*system.runAs(thisUser){       
        
        acc = new Account(name='Test1',billingpostalcode='00000',billingstate='CA'); 
        insert acc;
        
        Profile p = [SELECT Id FROM Profile WHERE usertype ='PowerPartner' limit 1]; 
        //Contact c=TestPRMLibrary.insertContact('Test','Partner', 'lastName', 'TestOpptyEdit@gmail.com');
        contact cont = new contact(lastname='contact1',Ultimate_Parent_Account__c = acc.id,accountId = acc.Id);
        insert cont;
        UserRole ur = [Select PortalType, PortalAccountId From UserRole where PortalType =:'partner' limit 1];
        
        u = new User(Alias = 'standt', Email='standarduser@testorg.com', title='Test',
        EmailEncodingKey='UTF-8',firstname='firstname', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, contactid=cont.id,userroleId = ur.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='TestOpptyEdit@gmail.com');  
        }*/
        
        
        
        
        acc = new Account(name='Test1',billingpostalcode='00000',billingstate='CA'); 
        insert acc;
          
        Opportunity opp = new Opportunity(name='Test11',Accountid=acc.id,stagename='Created',CloseDate=system.today());
        insert opp; 
        ApexPages.StandardController controller = new Apexpages.Standardcontroller(opp);
        OverrideOpptyEditButton ooe=new OverrideOpptyEditButton(controller);
        ApexPages.currentPage().getParameters().put('retURL','/apex/NewCustomOpportunity');
        ApexPages.currentPage().getParameters().put('oppId',opp.id);
        ApexPages.currentPage().getParameters().put('RecordType','01260000000UF3O');
        ApexPages.currentPage().getParameters().put('ent','entvalue1');
        
        ooe.redirectEditPage();
    }   
    
    static testmethod void UnitTest_OverrideOpptyEditButton2(){
        Account acc = new Account(name='Test1',billingpostalcode='00000',billingstate='CA'); 
        insert acc;
          
        Opportunity opp = new Opportunity(name='Test11',Accountid=acc.id,stagename='Created',CloseDate=system.today());
        insert opp; 
        ApexPages.StandardController controller = new Apexpages.Standardcontroller(opp);
        OverrideOpptyEditButton ooe=new OverrideOpptyEditButton(controller);
        ooe.retURL='salesforce.com/apex/NewCustomOpportunity';
        ooe.redirectEditPage();
    }
    
    
    
    
    
    
    
}