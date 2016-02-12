@ isTest (seeAllData = true)
public class ProposalSearchOffset_Test {
  /*
    public static testmethod void ProposalSearchOffset_Test(){
      //  Profile p = [select id from profile where Name ='PartnerSales' limit 1];   
      //  User pu = new User(profileId = p.id, username ='testemail', email ='one@email.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US',  languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',  alias='cspu', lastname='lastname', firstname = 'firstname', title = 'developer');
      //  Account a = new Account (Name ='Test12');
      //  insert a ;
        //Contact c = new Contact(AccountId = a.id, firstname = 'firstname', lastname = 'lastname',email = 'one@email.com', phone='9998887776', EDP_Go_Live_Date__c = system.Today()-200,Profile__c = 'Partner Sales', Sunrun_User__c=pu.Id,Ultimate_Parent_Account__c = a.Id);
      //  Opportunity opty = new Opportunity(name = 'Test Opty' ,StageName = 'New',AccountId = a.id);
       // insert opty;   
        List<Proposal__c> propList = [select Id,Proposal_Name__c,Original_Proposal_ID__c,Agreement_Type__c,LastModifiedDate,Homeowner_Name__c,Customer_Address__c from Proposal__c where createddate > n_days_ago:3 order by lastmodifieddate desc limit 10];      
        ApexPages.StandardSetController con = new ApexPages.standardSetController(propList);
        ApexPages.Message[] msgrep = ApexPages.getMessages();
        ProposalSearchOffset propsearch  = new ProposalSearchOffset();
        Test.startTest();
        propsearch.getProposalsForSelectedView();
        propsearch.searchColumnName = 'propsId';
        propsearch.searchValue ='namevalue';
        propsearch.doSearch();
        
        propsearch.searchColumnName = 'name';
        propsearch.searchValue = 'namevalue';
        propsearch.doSearch();
        
        propsearch.searchColumnName = 'addr';
        propsearch.searchValue = 'namevalue';
        propsearch.doSearch();
        
        propsearch.searchColumnName = 'stage';
        propsearch.searchValue ='namevalue';
        propsearch.doSearch();
        
        propsearch.searchColumnName = 'SalesRep';
        propsearch.searchValue = 'namevalue';
        propsearch.doSearch();
        
        propsearch.searchValue = null;
        propsearch.doSearch();
        
        propsearch.viewName = 'myprops';
        propsearch.searchValue = 'viewvalue';
        propsearch.getViews();
        
        propsearch.viewName = 'CreadBySprops';
        propsearch.getViews();
        
        propsearch.viewName = 'PropslMonth';
        propsearch.getViews();
        
        propsearch.viewName ='Props7days';
        propsearch.getViews();
        
        propsearch.viewName ='Props14days';
        propsearch.getViews();
        
        propsearch.getSearchBy();
        propsearch.clearSearchValue();
        propsearch.userActions();
        propsearch.first();
        propsearch.Next();
        propsearch.previous();
        propsearch.last();
        propsearch.getHasNext();
        propsearch.getHasPrevious();
        propsearch.getTotal_size();
        propsearch.getPageNumber();
        propsearch.getTotalPages();
        propsearch.getProposals();
        Test.stopTest();
    }
    */
}