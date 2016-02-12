@isTest (SeeAllData=true)
public class ATest_ProposalSearch {
    public static testMethod void Test_ProposalSearch(){
        Test.startTest();
        Id userId = PartnerDetail__c.getValues('PartnerSalesTestAccount').PartnerUserId__c;
        User partnerUser = [Select id, name, email from User where Id =:userId];
        
        System.runAs(partnerUser){
            ProposalSearch propSearchObj = new ProposalSearch();
            propSearchObj.searchValue = 'Test';
            propSearchObj.searchColumnName = 'SalesRep';
            propSearchObj.doSearch();
            
            Boolean testVar1 = propSearchObj.hasNext;
            Boolean testVar2 = propSearchObj.hasprevious;
            Integer testVar3 = propSearchObj.pageNumber;
            propSearchObj.clearSearchValue();
            propSearchObj.first();
            propSearchObj.getProposals();
            propSearchObj.viewName ='';
            propSearchObj.getProposalsForSelectedView();
            propSearchObj.getSearchBy();
            propSearchObj.getViews();
            propSearchObj.last();
            propSearchObj.previous();
            propSearchObj.userActions();
            propSearchObj.next();
            
            
            propSearchObj.searchValue = 'Test1';
            propSearchObj.doSearch();
            propSearchObj.viewName ='';
            propSearchObj.getProposalsForSelectedView();
            
            propSearchObj.searchColumnName = 'propsId';
            propSearchObj.searchValue = 'P123';
            propSearchObj.viewName = 'myProps';
            propSearchObj.getProposalsForSelectedView();
            
            propSearchObj.viewName = 'myChange';
            propSearchObj.getProposalsForSelectedView();
            propSearchObj.viewName = 'allProps';
            propSearchObj.getProposalsForSelectedView();
            
            propSearchObj.searchColumnName = 'name';
            propSearchObj.searchValue = 'Mary';
            propSearchObj.viewName = 'allChange';
            propSearchObj.getProposalsForSelectedView();
            
            propSearchObj.searchColumnName = 'addr';
            propSearchObj.searchValue = 'Benton';
            propSearchObj.viewName = 'Props1Month';
            propSearchObj.partnerGoLiveDate =  date.today();
            propSearchObj.getProposalsForSelectedView();
            
            propSearchObj.searchColumnName = 'stage';
            propSearchObj.searchValue = 'Created';
            propSearchObj.viewName = 'Props7days';
            propSearchObj.getProposalsForSelectedView();
            propSearchObj.viewName = 'Props14days';
            propSearchObj.getProposalsForSelectedView();
            propSearchObj.viewName = 'CreadBySROPS';
            propSearchObj.getProposalsForSelectedView();
            
        }
        Test.stopTest();    

    }
}