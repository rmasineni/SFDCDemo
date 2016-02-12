public class PartnerDashboard {
	
	public CustomLookup__c customLookUp {get;set;}
    LeadManager leadManagerObj;
    OpportunityManager opptyManagerObj;
    
    public Integer maximumValue {get;set;}
    public boolean leadsDashboard {get;set;}
    public boolean optyDashboard {get;set;}
    public string dashboardName {get;set;}
    List<SelectOption> dashboardTypes = new List<SelectOption>();
    
    List<PieWedgeData> data = new List<PieWedgeData>(); 
    List<SeriesChartData> seriesChartDataList;
    public List<SeriesChartData> getSeriesChartDataList() {
        return seriesChartDataList;
    }
 
    public PartnerDashboard(){
        maximumValue = 10;
        dashboardName = System.currentPagereference().getParameters().get('type');
        initializeDashboardTypes();
        if(dashboardName == 'oppotunities'){
            leadsDashboard = false;
            optyDashboard = true;           
        }else{
            leadsDashboard = true;
            optyDashboard = false;
            dashboardName = 'leads';
        }
        customLookUp = new CustomLookup__c();
        String startDateStr = '1/1/' + date.today().year();
        customLookUp.Start_Date__c = date.parse(startDateStr);
        customLookUp.End_Date__c = date.today();
    }

    private void initializeDashboardTypes(){
        dashboardTypes.add(new SelectOption('leads', 'Leads'));
        dashboardTypes.add(new SelectOption('oppotunities', 'Oppotunities'));
    }

    public List<SelectOption> getDashboardTypes() {
        return dashboardTypes;
    }

    public void initializeLeadManager(){
        
        if(leadManagerObj != null){
        System.debug('leadManagerObj.startDate: ' + leadManagerObj.startDate);
        System.debug('leadManagerObj.endDate: ' + leadManagerObj.endDate);
        System.debug('customLookUp.Start_Date__c: ' + customLookUp.Start_Date__c);
        System.debug('customLookUp.End_Date__c: ' + customLookUp.End_Date__c);
        }
        
        if(leadManagerObj == null 
            || (leadManagerObj.startDate != customLookUp.Start_Date__c)
            || (leadManagerObj.endDate != customLookUp.End_Date__c)){
            leadManagerObj = new LeadManager(customLookUp.Start_Date__c, customLookUp.End_Date__c);
        }       

        System.debug('leadManagerObj.startDate2: ' + leadManagerObj.startDate);
        System.debug('leadManagerObj.endDate2: ' + leadManagerObj.endDate);
        System.debug('customLookUp.Start_Date__c2: ' + customLookUp.Start_Date__c);
        System.debug('customLookUp.End_Date__c2: ' + customLookUp.End_Date__c);

    }

    public void initializeOpportunityManager(){
        if(opptyManagerObj != null){
        System.debug('opptyManagerObj.startDate: ' + opptyManagerObj.startDate);
        System.debug('opptyManagerObj.endDate: ' + opptyManagerObj.endDate);
        System.debug('customLookUp.Start_Date__c: ' + customLookUp.Start_Date__c);
        System.debug('customLookUp.End_Date__c: ' + customLookUp.End_Date__c);          
        }

        if(opptyManagerObj == null 
            || (opptyManagerObj.startDate != customLookUp.Start_Date__c)
            || (opptyManagerObj.endDate != customLookUp.End_Date__c)){
            opptyManagerObj = new OpportunityManager(customLookUp.Start_Date__c, customLookUp.End_Date__c);
        }   
        System.debug('opptyManagerObj.startDate2: ' + opptyManagerObj.startDate);
        System.debug('opptyManagerObj.endDate2: ' + opptyManagerObj.endDate);
        System.debug('customLookUp.Start_Date__c2: ' + customLookUp.Start_Date__c);
        System.debug('customLookUp.End_Date__c2: ' + customLookUp.End_Date__c);

    }

    public Pagereference refreshdashboards(){

        if(dashboardName == 'oppotunities'){
            leadsDashboard = false;
            optyDashboard = true;           
        }else{
            leadsDashboard = true;
            optyDashboard = false;
            dashboardName = 'leads';
        }

        String urlString = '/apex/Partner_Dashboard';
        urlString += '?type=' + dashboardName ;
        PageReference pageRef = new PageReference( urlString);
        //pageRef.setRedirect(true);
        return pageRef;         
    }

    public List<SeriesChartData> getOpportunitiesClosedByMonth(){
        initializeOpportunityManager();
        maximumValue = opptyManagerObj.maximumValue;
        //return opptyManagerObj.opportunitiesClosedByMonth;
        return opptyManagerObj.opportunitiesClosedByYearAndMonth;
    }

    public List<SeriesChartData> getLeadStatusByMonth(){
        initializeLeadManager();
        maximumValue = leadManagerObj.maximumValue;
        return leadManagerObj.leadStatusByMonth;
    }

    public List<PieWedgeData> getLeadsByStatus(){
        initializeLeadManager();
        return leadManagerObj.leadsByStatus;
    }

    public with sharing class LeadManager{
        public Date startDate {get;set;}
        public Date endDate {get;set;}
        
        public Integer maximumValue {get;set;}
        List<Lead> leadObjects = new List<Lead>();
        List<PieWedgeData> leadsByStatus {get;set;} 
        List<SeriesChartData> leadStatusByMonth {get;set;}  
        
        public LeadManager(Date startDate, Date endDate){
            maximumValue = 10;
            this.startDate = startDate;
            this.endDate = endDate;
            initializeLeadsByStatus();
            //initializeLeadsStatusByMonth();
        }
        
        private void initializeLeadsByStatus(){
            leadsByStatus = new List<PieWedgeData>();
            //Code Changed from status to Lead_Status__c(values changed from Sent Quote-Agreement', 'Sent Quote-Pass' to 'Closed-Lost')
            List<aggregateResult> results = [Select Lead_Status__c, count(Id) total from Lead where 
                                                Lead_Status__c in ('Converted', 'Open', 'Not Interested', 'Closed-Lost') 
                                                group by Lead_Status__c limit 100];
            for (AggregateResult ar : results){
                String status = (String)ar.get('Lead_Status__c');
                Integer total = Integer.ValueOf(ar.get('total'));
                System.debug(status +'-'+total);
                leadsByStatus.add(new PieWedgeData(status, total));
            }           
        }
		
		/*
        private void initializeLeadsStatusByMonth(){
            leadStatusByMonth = new List<SeriesChartData>();
            Map<String, Map<String, Integer>> statusByMonthMap = new Map<String, Map<String, Integer>>();
            //Code changed from status to Lead_Status__c
            List<aggregateResult> results = [Select CALENDAR_Month(Lead_Created_Date__c) month, Lead_Status__c, 
                                                count(Id) total from Lead 
                                                //WHERE CALENDAR_YEAR(Lead_Created_Date__c) = 2012 
                                                //and status in ('Converted', 'Open', 'Not Interested')
                                                //where Lead_Status__c in ('Converted', 'Open', 'Not Interested')
                                                where Lead_Status__c in ('Open')
                                                group by CALENDAR_Month(Lead_Created_Date__c), Lead_Status__c limit 10];
            List<String> monthList = new List<String>();
            for (AggregateResult ar : results){
                String month = String.valueOf((Integer)ar.get('month'));
                String status = (String)ar.get('Lead_Status__c');
                Integer total = Integer.ValueOf(ar.get('total'));
                System.debug(status +'-'+total);
                
                if(!statusByMonthMap.containskey(month)){
                    monthList.add(month);
                }
                
                Map<String, Integer> statusCountMap = (statusByMonthMap.containskey(month) ) ? statusByMonthMap.get(month) 
                                                        : new Map<String, Integer>(); 
                statusCountMap.put(status, total);
                statusByMonthMap.put(month, statusCountMap);
            }
            Integer maximumValue1 = 0;
            Integer maximumValue2 = 0;
            Integer maximumValue3 = 0;
                        
            for(String month : monthList){
                Map<String, Integer> statusCountMap = statusByMonthMap.get(month);
                Integer openCount = 0;
                Integer convertedCount = 0;
                Integer notInterestedCount = 0;
                for(String status : statusCountMap.keySet()){
                    if(status == 'Open'){
                        openCount = statusCountMap.get(status);
                    }else if(status == 'Converted'){
                        convertedCount = statusCountMap.get(status);
                    }else if(status == 'Not Interested'){
                        notInterestedCount = statusCountMap.get(status);
                    }
                }
                String monthName = PartnerDashboard.getMonthName(month);
                maximumValue1 = (maximumValue1 > openCount) ? maximumValue1 : openCount;
                maximumValue2 = (maximumValue2 > notInterestedCount) ? maximumValue2 : notInterestedCount;
                maximumValue3 = (maximumValue3 > convertedCount) ? maximumValue3 : convertedCount;
                leadStatusByMonth.add(new SeriesChartData(monthName, openCount, convertedCount, notInterestedCount));
            }
            maximumValue = maximumValue1 + maximumValue2 + maximumValue3 + 10;
            System.debug('leadStatusByMonth: ' + leadStatusByMonth);            
                
        }
        */
    }


    public with sharing class OpportunityManager{
        public Integer maximumValue {get;set;}
        public Date startDate {get;set;}
        public Date endDate {get;set;}
        List<Lead> leadObjects = new List<Lead>();
        ApexPages.StandardSetController leadCon;
        List<SeriesChartData> opportunitiesClosedByMonth {get;set;}
        List<SeriesChartData> opportunitiesClosedByYearAndMonth {get;set;}
        
        public OpportunityManager(Date startDate, Date endDate){
            this.startDate = startDate;
            this.endDate = endDate;
            maximumValue = 10;
            //getOpportunitiesClosedByMonth();
            getOpportunitiesClosedByYearAndMonth();
        }

        /*
        private void getOpportunitiesClosedByMonth(){
            opportunitiesClosedByMonth = new List<SeriesChartData>();
            Map<String, Map<String, Integer>> statusByMonthMap = new Map<String, Map<String, Integer>>();
            
            List<aggregateResult> results = [Select CALENDAR_Month(CloseDate) month, StageName, 
                                                count(Id) total from Opportunity 
                                                WHERE CALENDAR_YEAR(CloseDate) = 2012 
                                                and StageName in ('Approved')
                                                and CreatedDate >= :startDate 
                                                and CreatedDate <= :endDate
                                                group by CALENDAR_Month(CloseDate), StageName ];
            List<String> monthList = new List<String>();
            for (AggregateResult ar : results){
                String month = String.valueOf((Integer)ar.get('month'));
                String StageName = (String)ar.get('StageName');
                Integer total = Integer.ValueOf(ar.get('total'));
                System.debug(StageName +'-'+total);
                
                if(!statusByMonthMap.containskey(month)){
                    monthList.add(month);
                }
                
                Map<String, Integer> statusCountMap = (statusByMonthMap.containskey(month) ) ? statusByMonthMap.get(month) 
                                                        : new Map<String, Integer>(); 
                statusCountMap.put(StageName, total);
                statusByMonthMap.put(month, statusCountMap);
            }
            Integer maximumValue1 = 0;
            Integer maximumValue2 = 0;
            Integer maximumValue3 = 0;

            for(String month : monthList){
                Map<String, Integer> statusCountMap = statusByMonthMap.get(month);
                Integer closedCount = 0;
                Integer convertedCount = 0;
                Integer notInterestedCount = 0;
                for(String status : statusCountMap.keySet()){
                    if(status == 'Closed Won'){
                        closedCount = statusCountMap.get(status);
                    }else if(status == 'Converted'){
                        convertedCount = statusCountMap.get(status);
                    }else if(status == 'Not Interested'){
                        notInterestedCount = statusCountMap.get(status);
                    }
                }
                String monthName = PartnerDashboard.getMonthName(month);
                maximumValue1 = (maximumValue1 > closedCount) ? maximumValue1 : closedCount;
                maximumValue2 = (maximumValue2 > notInterestedCount) ? maximumValue2 : notInterestedCount;
                maximumValue3 = (maximumValue3 > convertedCount) ? maximumValue3 : convertedCount;
                opportunitiesClosedByMonth.add(new SeriesChartData(monthName, closedCount, convertedCount, notInterestedCount));
            }
            maximumValue = maximumValue1 + maximumValue2+ maximumValue3 +  10;
            System.debug('opportunitiesClosedByMonth: ' + opportunitiesClosedByMonth);          
        }
        */
        private void getOpportunitiesClosedByYearAndMonth(){
            opportunitiesClosedByYearAndMonth = new List<SeriesChartData>();
            Map<String, Map<String, Integer>> statusByYearAndMonthMap = new Map<String, Map<String, Integer>>();
            
            List<aggregateResult> results = [Select CALENDAR_Year(CloseDate) Year, CALENDAR_Month(CloseDate) Month, StageName, 
                                                count(Id) total from Opportunity 
                                                where CALENDAR_YEAR(CloseDate) in (2007, 2008, 2009, 2010, 2011, 2012) 
                                                and StageName in ('Approved')
                                                and CreatedDate >= :startDate 
                                                and CreatedDate <= :endDate
                                                group by CALENDAR_Year(CloseDate), CALENDAR_Month(CloseDate), StageName ];
            List<String> monthList = new List<String>();
            for (AggregateResult ar : results){
                String year = String.valueOf((Integer)ar.get('Year'));
                String month = String.valueOf((Integer)ar.get('Month'));
                String StageName = (String)ar.get('StageName');
                Integer total = Integer.ValueOf(ar.get('total'));
                System.debug(StageName +'-'+total);
                
                String yearMonth = year + '-' + month;
                System.debug('yearMonth: ' + yearMonth);
                
                if(!statusByYearAndMonthMap.containskey(yearMonth)){
                    monthList.add(yearMonth);
                }
                
                Map<String, Integer> statusCountMap = (statusByYearAndMonthMap.containskey(yearMonth) ) ? statusByYearAndMonthMap.get(yearMonth) 
                                                        : new Map<String, Integer>(); 
                statusCountMap.put(StageName, total);
                statusByYearAndMonthMap.put(yearMonth, statusCountMap);
            }
            Integer maximumValue1 = 0;
            Integer maximumValue2 = 0;
            Integer maximumValue3 = 0;
            System.debug('monthList: ' + monthList);
            for(String month : monthList){
                
                Map<String, Integer> statusCountMap = statusByYearAndMonthMap.get(month);
                Integer closedCount = 0;
                Integer convertedCount = 0;
                Integer notInterestedCount = 0;
                for(String status : statusCountMap.keySet()){
                    if(status == 'Closed Won'){
                        closedCount = statusCountMap.get(status);
                    }else if(status == 'Converted'){
                        convertedCount = statusCountMap.get(status);
                    }else if(status == 'Not Interested'){
                        notInterestedCount = statusCountMap.get(status);
                    }
                }
                //String monthName = PartnerDashboard.getMonthName(month);
                String monthName = month;
                maximumValue1 = (maximumValue1 > closedCount) ? maximumValue1 : closedCount;
                maximumValue2 = (maximumValue2 > notInterestedCount) ? maximumValue2 : notInterestedCount;
                maximumValue3 = (maximumValue3 > convertedCount) ? maximumValue3 : convertedCount;
                opportunitiesClosedByYearAndMonth.add(new SeriesChartData(monthName, closedCount, convertedCount, notInterestedCount));
            }
            maximumValue = maximumValue1 + maximumValue2+ maximumValue3 +  10;
            System.debug('opportunitiesClosedByYearAndMonth: ' + opportunitiesClosedByYearAndMonth);            
                
        }
    }

    public static String getMonthName(String month){
        String monthName = '';
        if(month == '1'){
            monthName = 'Jan';
        }else if(month == '2'){
            monthName = 'Feb';
        }else if(month == '3'){
            monthName = 'Mar';
        }else if(month == '4'){
            monthName = 'Apr';
        }else if(month == '5'){
            monthName = 'May';
        }else if(month == '6'){
            monthName = 'Jun';
        }else if(month == '7'){
            monthName = 'Jul';
        }else if(month == '8'){
            monthName = 'Aug';
        }else if(month == '9'){
            monthName = 'Sep';
        }else if(month == '10'){
            monthName = 'Oct';
        }else if(month == '11'){
            monthName = 'Nov';
        }else if(month == '12'){
            monthName = 'Dec';
        }           
        return monthName;       
    }

}