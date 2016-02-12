@isTest(SeeAllData=true)
public with sharing class UnitTest_doMarketAssignmentsSynchronous{
    static testmethod void UnitTest_doMarketAssignmentsSynchronous(){
    Lead l=new lead(lastname='Test',company='test');
    insert l;
    doMarketAssignmentsSynchronous.doMarketAssignments(l.id);
    }
    }