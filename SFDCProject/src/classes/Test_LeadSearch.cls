@isTest
public with sharing class Test_LeadSearch {
    public static testmethod void LeadSearchTest(){
        Test.StartTest();
        LeadSearch leadSearchObj = new LeadSearch();
        leadSearchObj.getUrl();
        leadSearchObj.doEdit();
        leadSearchObj.getIsPartnerUser();
        leadSearchObj.getViews();
        leadSearchObj.doDownTemp();     
        leadSearchObj.doNew();
        leadSearchObj.doSearch();
        leadSearchObj.clearSearchValue();
        leadSearchObj.doUpload();
        leadSearchObj.first();
        leadSearchObj.searchValue='1';
        leadSearchObj.doSearch();
        
        leadSearchObj.getLeads();
        leadSearchObj.getLeadsForSelectedView();
        leadSearchObj.getSearchBy();
        leadSearchObj.getViews();
        leadSearchObj.last();
        leadSearchObj.next();
        leadSearchObj.previous();       
        leadSearchObj.userActions();
        leadSearchObj.redirectLead();          
        
        leadSearchObj.viewName = 'allLeads';
        leadSearchObj.userActions();
        leadSearchObj.viewName = 'Leads1Month';
        leadSearchObj.userActions();
        leadSearchObj.viewName = 'Leads7days';
        leadSearchObj.userActions();
        leadSearchObj.viewName = 'Leads14days';
        leadSearchObj.userActions();
        leadSearchObj.viewName = '';
        leadSearchObj.userActions();  
        
            
        Test.StopTest();
                
    }
}