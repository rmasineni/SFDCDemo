@isTest (SeeAllData=true)
public with sharing class Test_PartnerDashboard {
    public static testmethod void TestPartnerDashboard(){
        
        Account acc = new Account(name='Test1',billingpostalcode='00000',billingstate='CA'); 
        insert acc;
          
        Opportunity opp = new Opportunity(name='Test11',Accountid=acc.id,stagename='Created',CloseDate=system.today());
        insert opp; 
        
       
        List<Opportunity> opportunitiesClosedByMonth = new List<Opportunity>();
        opportunitiesClosedByMonth.add(opp);
        List<Opportunity> opportunitiesClosedByYearAndMonth = new List<Opportunity> ();
        opportunitiesClosedByYearAndMonth.add(opp);
        Map<String, String> statusByMonthMap = new Map<String,String>();
        statusByMonthMap.put(opp.id,opp.StageName);
         ApexPages.StandardSetController controller = new Apexpages.StandardSetController(opportunitiesClosedByMonth);
        ApexPages.StandardSetController controller1 = new Apexpages.StandardSetController(opportunitiesClosedByYearAndMonth);
         PartnerDashboard PartnerDashboardobj = new PartnerDashboard();    
       
       Test.StartTest();       
       
        PartnerDashboardobj.getDashboardTypes();
        //PartnerDashboardobj.getLeadsByStatus();
        //PartnerDashboardobj.getLeadStatusByMonth();
        PartnerDashboardobj.getOpportunitiesClosedByMonth();
        PartnerDashboardobj.getSeriesChartDataList();
        //PartnerDashboardobj.initializeLeadManager();
        PartnerDashboardobj.initializeOpportunityManager();
        PartnerDashboardobj.dashboardName='oppotunities';
       // PartnerDashboardobj.leadsDashboard=false;
        PartnerDashboardobj.optyDashboard=true;
        PartnerDashboardobj.refreshdashboards();
        //PartnerDashboardobj.dashboardName='leads';
        PartnerDashboardobj.leadsDashboard=true;
        PartnerDashboardobj.optyDashboard=false;
        PartnerDashboardobj.refreshdashboards();
        PartnerDashboard.OpportunityManager OptyMgr=new PartnerDashboard.OpportunityManager(system.today()-10,system.today());        
        
        Test.StopTest();
        
    }

}