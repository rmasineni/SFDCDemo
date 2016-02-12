public with sharing class PartnerDashboardController {
    public Integer maximumValue {get;set;}
    public boolean proposalDashboard {get;set;}
    public boolean optyDashboard {get;set;}
    public string dashboardName {get;set;}
    public CustomLookup__c customLookUp {get;set;}
    public static boolean initializeValues = false;
    public string errorMessage {get;set;}
    public string startDate {get;set;}
    public string endDate {get;set;}
    
    public List<SelectOption> getDashboardTypes() { return dashboardTypes;}
    List<SelectOption> dashboardTypes = new List<SelectOption>();

    public PartnerDashboardController(){
        System.debug('Start: ');
        dashboardName = System.currentPagereference().getParameters().get('type');
        initializeDashboardTypes();
        if(dashboardName == 'Proposals'){
            proposalDashboard = true;
            optyDashboard = false;          
        }else{
            proposalDashboard = false;
            optyDashboard = true;
            dashboardName = 'Opportunities';
        }
        
        customLookUp = new CustomLookup__c();
        String tempStartDateStr = '1/1/' + date.today().year();
        startDate = System.currentPagereference().getParameters().get('startDate');
        endDate = System.currentPagereference().getParameters().get('endDate');
        if( startDate != null && startDate != ''){
            //System.debug('startDate1: ' + startDate);
            customLookUp.Start_Date__c = Date.valueOf(startDate);
        }else{
            customLookUp.Start_Date__c = date.parse(tempStartDateStr);
        }

        if(endDate != null && endDate != ''){
            customLookUp.End_Date__c = date.valueOf(endDate);
        }else{
            customLookUp.End_Date__c = date.today();
        }
        startDate = String.valueOf(customLookUp.Start_Date__c);
        endDate = String.valueOf(customLookUp.End_Date__c);
            
    }

    private void initializeDashboardTypes(){
        dashboardTypes.add(new SelectOption('Opportunities', 'Opportunities'));
        dashboardTypes.add(new SelectOption('Proposals', 'Proposals'));
    }
    
    public static set<String> oppurtunityStages = new Set<String> {'Closed Lost', 'Closed Won', 'Created',                                                                      
                                                                    'Negotiation'};

    public static set<String> proposalStages = new Set<String> {'Created', 'Credit Approved', 'Credit Review', 
                                                                    'Pending', 'Deal received by SR', 
                                                                    'Deal review completed by SR', 'Submitted',
                                                                    'SR Approved', 'Cancelled', 'Inactive'};

    public String getOpportunitiesByStageJSON() {
        String jsonResponse = '';
        JSONGenerator jsonGen = JSON.createGenerator(false);
        jsonGen.writeStartArray();      
        for(AggregateResult ar : [Select count(Id) total, stagename from Opportunity where StageName in :oppurtunityStages group by stagename]){
            jsonGen.writeStartObject();         
            jsonGen.writeObjectField('name', ar.get('stageName'));
            jsonGen.writeObjectField('data1', ar.get('total'));
            jsonGen.writeEndObject();                       
        }       
        jsonGen.writeEndArray();
        jsonResponse = jsonGen.getAsString();       
        return jsonResponse;        
    }
    
    /*
    public String getOpportunitiesClosedByMonthJSON() {
        String jsonResponse = '';
        JSONGenerator jsonGen = JSON.createGenerator(false);
        jsonGen.writeStartArray();      
        for(AggregateResult ar : [Select count(Id) total, stagename from Opportunity where StageName in :oppurtunityStages group by stagename]){
            jsonGen.writeStartObject();         
            jsonGen.writeObjectField('name', ar.get('stageName'));
            jsonGen.writeObjectField('data1', ar.get('total'));
            jsonGen.writeEndObject();                       
        }       
        jsonGen.writeEndArray();
        jsonResponse = jsonGen.getAsString();       
        return jsonResponse;        
    }
    */
/*
    public String getOpportunitiesClosedByMonthJSON(){
        
        System.debug('customLookUp.Start_Date__c: ' + customLookUp.Start_Date__c);
        System.debug('customLookUp.End_Date__c: ' + customLookUp.End_Date__c);
        String jsonResponse = '';       
        try{
            List<SeriesChartData> opportunitiesClosedByYearAndMonth = new List<SeriesChartData>();
            Map<String, Map<String, Integer>> statusByYearAndMonthMap = new Map<String, Map<String, Integer>>();
            List<aggregateResult> results = [Select CALENDAR_Year(CloseDate) Year, CALENDAR_Month(CloseDate) Month, StageName, 
                                                count(Id) total from Opportunity 
                                                where StageName in ('Approved')
                                                and CreatedDate >= :customLookUp.Start_Date__c 
                                                and CreatedDate <= :customLookUp.End_Date__c
                                                group by CALENDAR_Year(CloseDate), CALENDAR_Month(CloseDate), StageName ];
            List<String> monthList = new List<String>();
    
            JSONGenerator jsonGen = JSON.createGenerator(false);
            jsonGen.writeStartArray();  
            Integer rowCount = 0;
            for (AggregateResult ar : results){
                System.debug('Row Count start: ' + rowCount);
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

                jsonGen.writeStartObject();         
                jsonGen.writeObjectField('name', yearMonth);
                jsonGen.writeObjectField('data1', total);
                jsonGen.writeEndObject();
                System.debug('Row Count End: ' + rowCount);
                rowCount += 1;
            }
            jsonGen.writeEndArray();
            jsonResponse = jsonGen.getAsString();       

        }catch(Exception expObj){
            errorMessage = expObj.getMessage();
            System.debug('errorMessage2: ' + errorMessage);
        }
        return jsonResponse;   
    }
*/
    public String getOpportunitiesByStageByMonthJSON(){
        String jsonResponse = '';       
        try{
                List<SeriesChartData> opportunitiesClosedByYearAndMonth = new List<SeriesChartData>();
                Map<String, Map<String, Integer>> statusByYearAndMonthMap = new Map<String, Map<String, Integer>>();
                List<aggregateResult> results = [Select CALENDAR_Year(CloseDate) Year, CALENDAR_Month(CloseDate) Month, StageName, 
                                                    count(Id) total from Opportunity 
                                                    where StageName in ('7. Closed Won' , 'Unqualified', 'Proposal Presented')
                                                    and CreatedDate >= :customLookUp.Start_Date__c 
                                                    and CreatedDate <= :customLookUp.End_Date__c
                                                    group by CALENDAR_Year(CloseDate), CALENDAR_Month(CloseDate), StageName ];
                List<String> monthList = new List<String>();
        
                JSONGenerator jsonGen = JSON.createGenerator(false);
                jsonGen.writeStartArray();  
                Integer rowCount = 0;
                for (AggregateResult ar : results){
                    System.debug('Row Count start: ' + rowCount);
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
                for(String monthName : monthList){
                    Map<String, Integer> statusCountMap = statusByYearAndMonthMap.get(monthName);
                    Integer closedWon = 0;
                    Integer cloasedLost = 0;
                    Integer contractNegotiation = 0;
                    for(String status : statusCountMap.keySet()){
                        if(status == 'Closed Won'){
                            closedWon = statusCountMap.get(status);
                        }else if(status == 'Closed Lost'){
                            cloasedLost = statusCountMap.get(status);
                        }else if(status == '4 - Contract Negotiation'){
                            contractNegotiation = statusCountMap.get(status);
                        }
                    }
                    jsonGen.writeStartObject();         
                    jsonGen.writeObjectField('name', monthName);
                    jsonGen.writeObjectField('Won', closedWon);
                    jsonGen.writeObjectField('Lost', cloasedLost);
                    jsonGen.writeObjectField('ContractNegotiation', contractNegotiation);
                    jsonGen.writeEndObject();
                }
                jsonGen.writeEndArray();
                jsonResponse = jsonGen.getAsString();   
                //System.debug('jsonResponse: ' + jsonResponse);  
        }catch(Exception expObj){
            errorMessage = expObj.getMessage();
            System.debug('errorMessage1: ' + errorMessage);
        }
        return jsonResponse;    
    }

    public String getProposalsByStageJSON() {
        String jsonResponse = '';
        JSONGenerator jsonGen = JSON.createGenerator(false);
        jsonGen.writeStartArray();      
        for(AggregateResult ar : [Select count(Id) total, Stage__c from Proposal__c where Stage__c in :proposalStages group by Stage__c]){
            jsonGen.writeStartObject();         
            jsonGen.writeObjectField('name', ar.get('Stage__c'));
            jsonGen.writeObjectField('data1', ar.get('total'));
            jsonGen.writeEndObject();                       
        }       
        jsonGen.writeEndArray();
        jsonResponse = jsonGen.getAsString();       
        return jsonResponse;        
    }


    public String getProposalsByStageByMonthJSON(){
        String jsonResponse = '';       
        try{
                List<SeriesChartData> opportunitiesClosedByYearAndMonth = new List<SeriesChartData>();
                Map<String, Map<String, Integer>> statusByYearAndMonthMap = new Map<String, Map<String, Integer>>();
                List<aggregateResult> results = [Select CALENDAR_Year(lastmodifieddate) Year, CALENDAR_Month(lastmodifieddate) Month, Stage__c, 
                                                    count(Id) total from Proposal__c 
                                                    where Stage__c in ('Created', 'Submitted', 'Credit Approved', 'SR Approved')
                                                    and CreatedDate >= :customLookUp.Start_Date__c 
                                                    and CreatedDate <= :customLookUp.End_Date__c
                                                    group by CALENDAR_Year(lastmodifieddate), CALENDAR_Month(lastmodifieddate), Stage__c limit 1000];
                List<String> monthList = new List<String>();
        
                JSONGenerator jsonGen = JSON.createGenerator(false);
                jsonGen.writeStartArray();  
                Integer rowCount = 0;
                for (AggregateResult ar : results){
                    System.debug('Row Count start: ' + rowCount);
                    String year = String.valueOf((Integer)ar.get('Year'));
                    String month = String.valueOf((Integer)ar.get('Month'));
                    String StageName = (String)ar.get('Stage__c');
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

                for(String monthName : monthList){
                    Map<String, Integer> statusCountMap = statusByYearAndMonthMap.get(monthName);
                    Integer created = 0;
                    Integer creditApproved = 0;
                    Integer srApproved = 0;
                    Integer submitted = 0;
                    for(String status : statusCountMap.keySet()){
                        if(status == 'Created'){
                            created = statusCountMap.get(status);
                        }else if(status == 'Credit Approved'){
                            creditApproved = statusCountMap.get(status);
                        }else if(status == 'SR Approved'){
                            srApproved = statusCountMap.get(status);
                        }else if(status == 'Submitted'){
                            submitted = statusCountMap.get(status);
                        }
                    }
                    jsonGen.writeStartObject();         
                    jsonGen.writeObjectField('name', monthName);
                    jsonGen.writeObjectField('Created', created);
                    jsonGen.writeObjectField('Submitted', submitted);
                    jsonGen.writeObjectField('Credit Approved', creditApproved);
                    jsonGen.writeObjectField('SR Approved', srApproved);
                    jsonGen.writeEndObject();
                }
                jsonGen.writeEndArray();
                jsonResponse = jsonGen.getAsString();   
                System.debug('jsonResponse: ' + jsonResponse);  
        }catch(Exception expObj){
            errorMessage = expObj.getMessage();
            System.debug('errorMessage1: ' + errorMessage);
        }
        return jsonResponse;    
    }


    public Pagereference refreshdashboards(){
        startDate = String.valueOf(customLookUp.Start_Date__c);
        endDate = String.valueOf(customLookUp.End_Date__c);
        if(dashboardName == 'Opportunities'){
            proposalDashboard = false;
            optyDashboard = true;           
        }else{
            proposalDashboard = true;
            optyDashboard = false;
            dashboardName = 'Proposals';
        }
        
        String urlString = '/apex/PartnerDashboard';
        urlString += '?type=' + dashboardName ;
        urlString += '&startDate=' +  startDate;
        urlString += '&endDate=' + endDate;
        PageReference pageRef = new PageReference( urlString);
        //pageRef.setRedirect(true);
        return pageRef; 
    }
    
    
}