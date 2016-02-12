@isTest(SeeAllData=true)
public with sharing class UnitTest_SearchSalesInstallForPartners {

    static testmethod void UnitTest_SearchSalesInstallForPartners(){
    Lead l=new lead(lastname='testkkk',company='tss',street='595 market street',city='San francisco',state='CA',postalcode='94114');
    insert l;
    Set<id> ids=new set<id>();
    ids.add(l.id);
    SearchSalesInstallForPartners.SearchSalesInstallForPartners(ids);
    }
    }