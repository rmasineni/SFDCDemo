@isTest(SeeAllData=true)
public with sharing class Test_OverrideFSDispatch {
    static testmethod void Test_OverrideFSDispatch(){
        User u;
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        FS_Dispatch__c fsd = new FS_Dispatch__c();
        insert fsd;
        ApexPages.StandardController controller = new Apexpages.Standardcontroller(fsd);
        
        ApexPages.currentPage().getParameters().put('retURL','/apex/FSDispatchesSearch');
        ApexPages.currentPage().getParameters().put('fsdId',fsd.id);
        ApexPages.currentPage().getParameters().put('RecordType','01260000000UF3O');
        ApexPages.currentPage().getParameters().put('ent','entvalue1');
        OverrideFSDispatch ofsd=new OverrideFSDispatch(controller);
        ofsd.redirectFSDispatchTab();
    }
    static testmethod void Test_OverrideFSDispatch2(){
        FS_Dispatch__c fsd = new FS_Dispatch__c();
        insert fsd;
        ApexPages.StandardController controller = new Apexpages.Standardcontroller(fsd);
        OverrideFSDispatch ofsd=new OverrideFSDispatch(controller);
        ofsd.redirectFSDispatchTab();
    }

}