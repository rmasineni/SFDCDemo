@isTest(SeeAllData=true)
private class Test_FSDispatchSearch {
     public static testMethod void Test_FSDispatchSearch(){
            Test.startTest();
            Id userId = PartnerDetail__c.getValues('PartnerSalesTestAccount').PartnerUserId__c;
            User partnerUser = [Select id, name, email from User where Id =:userId];
     System.runAs(partnerUser){
     FSdispatchesSearch fsdispatchSearchObj = new  FSdispatchesSearch();
     fsdispatchSearchObj.searchValue = 'Test';
     fsdispatchSearchObj.searchColumnName = 'Customer Name';
     fsdispatchSearchObj.doSearch();
                     
     Boolean testvar1 = fsdispatchSearchObj.hasNext;
     Boolean testvar2 = fsdispatchSearchObj.hasprevious;
     Integer testVar3 = fsdispatchSearchObj.pageNumber;
     fsdispatchSearchObj.clearSearchValue();
     fsdispatchSearchObj.first();
     fsdispatchSearchObj.getFSDispatches();
     fsdispatchSearchObj.viewName = '';
     fsdispatchSearchObj.getFSdispatchSelectedView();
     fsdispatchSearchObj.getSearchBy();
     fsdispatchSearchObj.getViews();
     fsdispatchSearchObj.last();
     fsdispatchSearchObj.previous();
     fsdispatchSearchObj.userActions();
     fsdispatchSearchObj.next();
     
   // FSdispatchesSearch fsdispatchSearchObj2 = new  FSdispatchesSearch();
     fsdispatchSearchObj.searchValue = 'Test1';
     fsdispatchSearchObj.searchColumnName = 'City';
     fsdispatchSearchObj.doSearch();
     
     fsdispatchSearchObj.searchColumnName = 'Dispatch State';
     fsdispatchSearchObj.searchValue = 'Test2';
     fsdispatchSearchObj.viewName = 'ACTIVE';
     fsdispatchSearchObj.getFSdispatchSelectedView();
     
     fsdispatchSearchObj.searchColumnName = 'Dispatch ID';
     fsdispatchSearchObj.searchValue = 'Test2';
     fsdispatchSearchObj.viewName = 'ACTIVE';
     fsdispatchSearchObj.getFSdispatchSelectedView();
     
     fsdispatchSearchObj.searchColumnName = 'Partner Tracking ID';
     fsdispatchSearchObj.searchValue = 'Test2';
     fsdispatchSearchObj.viewName = 'ACTIVE';
     fsdispatchSearchObj.getFSdispatchSelectedView();
     
     fsdispatchSearchObj.searchColumnName = 'Case Reason';
     fsdispatchSearchObj.searchValue = 'Test2';
     fsdispatchSearchObj.viewName = 'ACTIVE';
     fsdispatchSearchObj.getFSdispatchSelectedView();
     
     fsdispatchSearchObj.searchValue = 'T';
     fsdispatchSearchObj.searchColumnName = 'City';
     fsdispatchSearchObj.doSearch();
     
    /* Boolean testvar4 = fsdispatchSearchObj2.hasNext;
     Boolean testvar5 = fsdispatchSearchObj2.hasprevious;
     Integer testVar6 = fsdispatchSearchObj2.pageNumber;
     fsdispatchSearchObj2.clearSearchValue();
     fsdispatchSearchObj2.first();
     fsdispatchSearchObj2.getFSDispatches();
     fsdispatchSearchObj2.viewName = '';
     fsdispatchSearchObj2.getFSdispatchSelectedView();
     fsdispatchSearchObj2.getSearchBy();
     fsdispatchSearchObj2.getViews();
     fsdispatchSearchObj2.last();
     fsdispatchSearchObj2.previous();
     fsdispatchSearchObj2.userActions();
     fsdispatchSearchObj2.next(); */ 
     
   } 
          
    Test.stopTest();
    
    
    }
}