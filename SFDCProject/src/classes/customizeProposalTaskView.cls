public with sharing class customizeProposalTaskView {

    public String PickList1{get;set;}
    public String PickList2{get;set;}
    public Integer totalPageCount{get;set;}
    public Integer pageNumber = 0;
    public Integer totalCount {get;set;}
    public Integer pageSize = 5;
    public List<Task> lstTask{get;set;}
    public Date dateVal = Date.today();
    public  Date dateValWeek = Date.today().addDays(7);
    public String userId{get;set;}
    
    
    public customizeProposalTaskView() {
        
        PickList2 = 'allTasks';
        userId = UserInfo.getUserId();
       // userId = '005g0000000MwB2';
        initialize();
        queryTaskList();
        
    }
    
    public List<Task> getlstTask(){
        System.debug(lstTask);
        return lstTask;
    }
    
   /* public List<SelectOption> getView1() {
        List<SelectOption> View1 = new List<SelectOption>();
        View1.add(new SelectOption('myTasks', 'Tasks I Created'));
        View1.add(new SelectOption('allTasks', 'All Tasks'));
        return View1;
    } */
    
    public List<SelectOption> getView2() {
        List<SelectOption> View2 = new List<SelectOption>();
        View2.add(new SelectOption('allTasks', 'All Tasks'));
        View2.add(new SelectOption('dToday', 'Tasks Due Today'));
        View2.add(new SelectOption('dWeek', 'Tasks Due in Next 7 days'));
        View2.add(new SelectOption('dOver', 'Overdue Tasks'));
        
        return View2;
    }
        
    private string getSelectionQuery(String userId){      
        String soqlQuery = ' Select ID,status,ActivityDate,createddate,OwnerId,WhatId,What.Name,Subject,Pending_Proposal_Reason__c ';
        soqlQuery += ' from Task ';
        soqlQuery += ' where Status = \'Open\' ';
        soqlQuery += ' AND WhatId != null AND OwnerId = \''+ userId+'\' AND ActivityDate != null AND what.type = \'Proposal__c\' ';
        soqlQuery += ' ' + getFilterCondition();
        soqlQuery +=' AND Createddate>N_DAYS_AGO: 90';
        soqlQuery += ' ORDER BY ActivityDate DESC' ;
        System.debug('soqlQuery2: ' + soqlQuery);
        return soqlQuery;
    }
    
    private String getFilterCondition(){
                     
       String searchCondition = '';
        
       if(PickList2 == 'dToday'){
            
            searchCondition = ' And ActivityDate = :dateVal';
        }else if(PickList2 == 'dWeek'){
            
            searchCondition = ' And ActivityDate >= :dateVal And ActivityDate < :dateValWeek';
        }else if(PickList2 == 'dOver'){
            
            searchCondition = ' And ActivityDate < :dateVal';
        }else if(PickList2 == 'allTasks'){
            
            searchCondition = '';
        }
              
        return searchCondition;
    }
    
    public Pagereference userActions(){
        initialize();
        queryTaskList();
        return null;

    }
    
    private void queryTaskList()
    {
        Integer offset = pageNumber * pageSize;
        String baseQuery = getSelectionQuery(userId);
        String query = baseQuery + ' LIMIT '+ pageSize +' OFFSET '+ offset;
        
        System.debug('query:'+ query);
        try{

            lstTask = Database.query(query);
            System.debug('lstTask Inside Try: ' + lstTask);

        }
        catch(Exception e){
            ApexPages.addMessages(e);
        }
        System.debug('lstTask: ' + lstTask);
    }
    
   private void initialize(){
        totalCount = 0;
        pageNumber = 0;
        totalPageCount = 0;
        setTaskCount(userId);
        calculatePageCount();
    }
    
        public PageReference first(){
        pageNumber = 0;
        queryTaskList();
        return null;
    }  
 
    public PageReference last(){
        pageNumber = totalPageCount - 1;
        queryTaskList();
        return null;
    } 
        
    public PageReference previous(){
        pageNumber--;
        if (pageNumber < 0)
            return null;
        queryTaskList();
        return null;
    }

    public PageReference next(){
        pageNumber++;
        queryTaskList();
        return null;
    }   

    public boolean getHasPrevious(){
        if(pageNumber <= 0){
            return false;
        }else{
            return true;
        }
    }

    private void calculatePageCount(){
        if(totalCount <= 0)
            return;
        
        Integer tempValue = totalCount / pagesize;
        Integer reminderVal = math.mod(totalCount, pagesize);
        
        if(reminderVal > 0){
            totalPageCount = tempValue + 1;
        }else{
            totalPageCount = tempValue;
        }
        
    }
    
    public boolean getHasNext(){
        if((pageNumber + 1) < totalPageCount){
            return true;
        }else{
            return false;
        }
    }
    
    public Integer getTotalPageCount(){
        return totalPageCount;
    }
    
    public Integer getPageNumber(){
        return pageNumber+1;
    }
    
    private void setTaskCount(String userId){      
        String soqlQuery = ' Select count()'; 
        soqlQuery += ' from Task ';
        soqlQuery += ' where Status = \'Open\' ';
        soqlQuery += ' And WhatId != null and OwnerId = \''+ userId+'\' AND ActivityDate != null and what.type = \'Proposal__c\' ';
        soqlQuery += ' ' + getFilterCondition();
        soqlQuery +=' AND Createddate>N_DAYS_AGO: 90';
        System.debug('soqlQuery1: ' + soqlQuery);
        totalCount = Database.countQuery(soqlQuery);
    }
    
}