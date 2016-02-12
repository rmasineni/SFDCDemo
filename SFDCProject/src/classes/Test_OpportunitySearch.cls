@isTest(SeeAllData=true)
public with sharing class Test_OpportunitySearch {
static testMethod void OpptySearch(){
        OpportunitySearch oppSearch=new OpportunitySearch();
        oppSearch.redirectOppty();
        oppSearch.getPageNumber();
        oppSearch.getTotalPageCount();
        oppSearch.getHasNext();
        oppSearch.getHasPrevious();
        oppSearch.next();
        oppSearch.previous();
        oppSearch.last();
        oppSearch.first();
        oppSearch.userActions();
        oppSearch.getOpptyBasedOnContactrole('email','test@yopmail.com');
        oppSearch.getOpptyBasedOnContactrole('phone','1234567891');
        oppSearch.getOpptyBasedOnContactrole('name','Test');
        oppSearch.getSearchBy();
        oppSearch.doSearch();
        oppSearch.getViews();
        oppSearch.getOpptyList();
        oppSearch.searchValue='name';
        oppSearch.viewName='allOppty';
        oppSearch.searchColumnName='accname';
        oppSearch.userActions();
        oppSearch.viewName='myNewOppty';
        oppSearch.searchColumnName='stage';
        oppSearch.userActions();
        oppSearch.viewName='myActiveOppty';
        oppSearch.searchColumnName='address';
        oppSearch.userActions();
        oppSearch.viewName='myClosedOppty';
        oppSearch.searchColumnName='email';
        oppSearch.userActions();
        oppSearch.viewName='Oppty1Month';
        oppSearch.searchColumnName='phone';
        oppSearch.userActions();
        oppSearch.viewName='Oppty7days';
        oppSearch.searchColumnName='Custname';
        oppSearch.userActions();
        oppSearch.viewName='Oppty14days';
        oppSearch.searchColumnName='readyfor';
        oppSearch.userActions();
    }
  
  }