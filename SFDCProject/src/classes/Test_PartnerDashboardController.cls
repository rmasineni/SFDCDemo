@isTest (SeeAllData=false)
public with sharing class Test_PartnerDashboardController {

    public static testmethod void TestPartnerDashboardController(){
        Test.StartTest();
        Opportunity opportunity=new Opportunity(name='TEst',stagename='Approved',closedate=system.today());
        Opportunity opportunity2=new Opportunity(name='Test2',stagename='Closed Won',closedate=system.today());  
        List<Opportunity> oppList=new List<Opportunity>();
        oppList.add(opportunity);
        oppList.add(opportunity2);
        insert oppList;
        Proposal__c proposal=new Proposal__c(Upfront_Payment__c=1,date_issued__c=system.now(),sales_rep_email__c='test22@yopmail.com',stage__c='SR Approved',
        System_Size_STC_DC__c=1,opportunity__c=opportunity.id,Mode_Name__c='Test',Guaranteed_production_to_date__c='111',Yearly_refund_rate__c='111');
        insert proposal;     
        String startdate=system.today()-10+'';    
        String enddate=system.today()+10+'';  
        ApexPages.currentPage().getParameters().put('startDate',startdate.trim());
        ApexPages.currentPage().getParameters().put('endDate',enddate.trim());
        PartnerDashboardController PartnerDashboardControllerobj = new PartnerDashboardController();              
        PartnerDashboardControllerobj.getDashboardTypes();
        PartnerDashboardControllerobj.getOpportunitiesByStageByMonthJSON();
        PartnerDashboardControllerobj.getOpportunitiesByStageJSON();
       // PartnerDashboardControllerobj.getOpportunitiesClosedByMonthJSON();
        PartnerDashboardControllerobj.getProposalsByStageByMonthJSON();
        PartnerDashboardControllerobj.getProposalsByStageJSON();
        PartnerDashboardControllerobj.dashboardName='Proposals';
        PartnerDashboardControllerobj.proposalDashboard=true;
        PartnerDashboardControllerobj.optyDashboard=false;
        PartnerDashboardControllerobj.refreshdashboards();
        PartnerDashboardControllerobj.dashboardName='Opportunities';
        PartnerDashboardControllerobj.proposalDashboard=false;
        PartnerDashboardControllerobj.optyDashboard=true;
        PartnerDashboardControllerobj.refreshdashboards();
       Test.StopTest();

    }

}