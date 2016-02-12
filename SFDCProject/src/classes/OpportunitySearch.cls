public with sharing class OpportunitySearch{
    private String custnameLike = '%%';
    private String emailLike = '%%';
    private String phoneLike = '%%';
    private String oppNameLike = '%%';
    private String accNameLike = '%%';
    private String stageLike = '%%';
    private String addrLike = '%%';
    public String loginProfileId {get;set;}
    public Integer totalPageCount{get;set;}
    public Integer pageNumber = 0;
    public Integer totalCount {get;set;}
    public Integer pageSize = 10;
    public List<Opportunity> OpptyList{get;set;}    
    public String userId{get;set;}
    public String searchColumnName{get;set;}
    public String searchValue{get;set;}
    Set<id> Ids=new Set<id>();
    public Id loginContactId {get;set;}
    public String viewName{get;set;}
    public String baseURL{get;set;}
    public String opptyId{set;get;}
    public Set<id> PTOpptyIds=new Set<id>();
    public OpportunitySearch() {  
           try{
                loginProfileId = UserInfo.getProfileId();
                userId = UserInfo.getUserId(); 
                system.debug('loginProfileId------>'+loginProfileId);
                Contact contactObj = PRMContactUtil.getLoginUserAccountAndContact();
                system.debug('contactObj------>'+contactObj);
                loginContactId = contactObj.Id;
                if(contactObj!=null&&contactObj.email!=null){
                for(Proposal__c propObj:[select opportunity__c from Proposal__c where sales_rep_email__c=:contactObj.email and Proposal_Source__c='PT' and createddate>N_DAYS_AGO:90 order by createddate desc limit 1000]){
                    PTOpptyIds.add(propObj.opportunity__c);
                }
                }
                }catch(Exception exceptionObj){
            ApexPages.addMessages(exceptionObj);               
        }           
        initialize();
        queryOpptyList();
        calculatePageCount();
        
    }
    
    public List<Opportunity> getOpptyList(){
        return OpptyList;
    }   
   public List<SelectOption> getViews() {
        List<SelectOption> Views = new List<SelectOption>();
        
        //Following is to dispaly All Porposals view for only Partner Ops
        String opsProfileId = Label.Partner_Ops_Profile;
        if(loginProfileId != null && loginProfileId.contains(opsProfileId)){
            Views.add(new SelectOption('allOppty', 'All Opportunities'));      
        }
        
        Views.add(new SelectOption('myOppty', 'My Opportunities'));
        Views.add(new SelectOption('myNewOppty', 'My New Opportunities'));        
        Views.add(new SelectOption('myActiveOppty', 'My Active Opportunities'));
        Views.add(new SelectOption('myClosedOppty', 'My Closed Opportunities'));        
        Views.add(new SelectOption('Oppty7days', 'Opportunities created in last 7 days'));
        Views.add(new SelectOption('Oppty14days','Opportunities created in last 14 days'));
        Views.add(new SelectOption('Oppty1Month', 'Opportunities created in last 1 month'));             
        return Views;
    }
    public PageReference doSearch() 
    {
        try{
                if(searchValue != null && searchValue != '' && searchValue.Length() < 2){
                    String errorMessage = CustomErrorMessages.MINIMUM_SEARCH_STRING;
                    Exception expObj = new BaseException(errorMessage);
                    expObj.setMessage(errorMessage);
                    ApexPages.addMessages(expObj);
                    return null;
                }
                
                                 
                 userActions();              
                }catch(Exception exceptionObj){
            ApexPages.addMessages(exceptionObj);               
        }  
        return null;
    }    
    private String getSelectionQuery(){
        oppNameLike = '%%';
        accNameLike = '%%';
        stageLike = '%%';
        addrLike = '%%';
        custnameLike = '%%';
        emailLike = '%%';
        phoneLike = '%%';        
        String userName = UserInfo.getName();        
        
        String searchCondition = '';
        if(searchValue != null && searchValue != ''){
            if(searchColumnName == 'name' && searchValue != null && searchValue != ''){
                system.debug('Search value name...'+searchValue);
                oppNameLike = '%' + searchValue + '%';
                searchCondition = ' AND (Name like :oppNameLike) ';
                searchCondition += getSearchConditionByViewName(userId,userName);
                            
            }else if(searchColumnName == 'accname' && searchValue != null && searchValue != ''){
                system.debug('Search value accname...'+searchValue);
                accNameLike = '%' + searchValue + '%';
                searchCondition = ' AND (Account.name like :accNameLike) ';
                searchCondition += getSearchConditionByViewName(userId,userName); 
                
            }else if(searchColumnName == 'stage' && searchValue != null && searchValue != ''){
                system.debug('Search value stage...'+searchValue);
                stageLike = '%' + searchValue + '%';
                searchCondition = ' AND (StageName like :stageLike) ';
                searchCondition +=  getSearchConditionByViewName(userId,userName);        
                
            
            }else if(searchColumnName == 'address' && searchValue != null && searchValue != ''){
                system.debug('Search value stage...'+searchValue);
                addrLike = '%' + searchValue + '%';
                searchCondition = ' AND (Address__c like :addrLike) ';
                searchCondition +=  getSearchConditionByViewName(userId,userName);        
                
            }else if(searchColumnName == 'email' && searchValue != null && searchValue != ''){
                system.debug('Search value email...'+searchValue);
                emailLike = '%' + searchValue + '%';
                Ids=getOpptyBasedOnContactrole('email',searchValue);
                searchCondition = ' AND (id  in:Ids)';
                searchCondition +=  getSearchConditionByViewName(userId,userName);        
                
            }else if(searchColumnName == 'phone' && searchValue != null && searchValue != ''){
                system.debug('Search value phone...'+searchValue);
                phoneLike = '%' + searchValue + '%';
                Ids=getOpptyBasedOnContactrole('phone',searchValue);
                searchCondition = ' AND (id  in :Ids) ';
                searchCondition +=  getSearchConditionByViewName(userId,userName);        
                
            }else if(searchColumnName == 'Custname' && searchValue != null && searchValue != ''){
                system.debug('Search value custname...'+searchValue);
                custnameLike = '%' + searchValue + '%';
                Ids=getOpptyBasedOnContactrole('name',searchValue);
                searchCondition = ' AND (id  in :Ids) ';
                searchCondition +=  getSearchConditionByViewName(userId,userName);        
                
            }
            else if(searchColumnName == 'readyfor' && searchValue != null && searchValue != ''){
                system.debug('Search value readyfor...'+searchValue);
                searchCondition = ' AND (Ready_for__c  = :searchValue) ';
                searchCondition +=  getSearchConditionByViewName(userId,userName);        
                
            }
            
        }else{
                searchCondition = getSearchConditionByViewName(userId,userName);
        }           
        
        String soqlQuery = 'Select ID,Name,Ready_For__c,address__c,Accountid,Account.name,Amount,StageName,CloseDate,CreatedDate,Homeowner_Full_Name__c,Homeowner_Email__c,Phone__c,Sales_Representative__c,Utility_Company__c,street__c,city__c,state__c,zip_code__C ,(select Contact.Name,Contact.email,Contact.phone from OpportunityContactRoles where isprimary=true)'; 
        soqlQuery += ' from Opportunity ';
        if(test.isRunningTest())
        loginContactId = '003g000000GFnMXAA1';        
        if(Userinfo.getProfileId()==system.label.Partner_Ops_Profile_Id){
        soqlQuery += ' where StageName != null';
        }
        else{
        if(!PTOpptyIds.isEmpty()){
        soqlQuery += ' where StageName != null AND ((sales_representative__c=\''+loginContactId+'\') or(Opportunity_Source_Type__c=\'PT\' AND id in :PTOpptyIds) OR createdById = \''+ userId + '\' OR ownerid= \''+ userId + '\')';        
        }
        else{
        soqlQuery += ' where StageName != null AND ((sales_representative__c=\''+loginContactId+'\') OR createdById = \''+ userId + '\'OR ownerid= \''+ userId + '\') ';
        }
        }
        soqlQuery += searchCondition;
        soqlQuery += ' ORDER BY CreatedDate desc' ;
        return soqlQuery;
    }
    
    public List<SelectOption> getSearchBy() {
        List<SelectOption> searchBy = new List<SelectOption>();
   //   searchBy.add(new SelectOption('name', 'Opportunity Name'));        
        searchBy.add(new SelectOption('Custname', 'Customer Name'));
        searchBy.add(new SelectOption('Address', 'Customer Address'));
        searchBy.add(new SelectOption('email','Customer Email'));
        searchBy.add(new SelectOption('phone','Customer Phone'));
        searchBy.add(new SelectOption('readyfor','Ready For'));
        return searchBy;
    }
    public Set<id> getOpptyBasedOnContactrole(String view,String keyword){
        Set<id> Ids=new Set<id>();
        String query;
        if(view=='email'){
            query='select opportunityid from OpportunityContactRole where Contact.email like'+ '\'%'+keyword+'%\'';         
        }
        else if(view=='phone'){
            query='select opportunityid from OpportunityContactRole where Contact.phone like'+ '\'%'+keyword+'%\'';
        }
        else if(view=='name'){
            query='select opportunityid from OpportunityContactRole where Contact.name like'+ '\'%'+keyword+'%\'';
        }
        List<OpportunityContactRole> OpptyContRoleList=database.query(query);
        for(OpportunityContactRole opptyContRole:OpptyContRoleList){
            Ids.add(opptyContRole.opportunityid);
        }
        return Ids;
    }
    private String getSearchConditionByViewName(String userId, String userName){
        String searchCondition = '';
        if(viewName == 'myOppty'){
           searchCondition = '';
           if(Userinfo.getProfileId()==system.label.Partner_Ops_Profile_Id){
            searchCondition+=' AND ((sales_representative__c=\''+loginContactId+'\') OR createdById = \''+ userId + '\'OR ownerid= \''+ userId + '\') ';
           }        
        }else if(viewName == 'allOppty'){
            searchCondition = '';
        }
        else if(viewName == 'myNewOppty'){
            searchCondition += ' AND StageName in (\'1. Created\') ';
            if(Userinfo.getProfileId()==system.label.Partner_Ops_Profile_Id){
            searchCondition+=' AND ((sales_representative__c=\''+loginContactId+'\') OR createdById = \''+ userId + '\'OR ownerid= \''+ userId + '\') ';
           }
        }
        else if(viewName == 'myActiveOppty'){
            searchCondition += ' AND StageName in (\'1. Created\',\'Scheduled\',\'Missed Consultation\',\'Negotiation\') ';
            if(Userinfo.getProfileId()==system.label.Partner_Ops_Profile_Id){
            searchCondition+=' AND ((sales_representative__c=\''+loginContactId+'\') OR createdById = \''+ userId + '\'OR ownerid= \''+ userId + '\') ';
           }
        }
        else if(viewName == 'myClosedOppty'){
            searchCondition += ' AND StageName in (\'Cancelled\',\'7. Closed Won\',\'9. Closed lost\') ';
            if(Userinfo.getProfileId()==system.label.Partner_Ops_Profile_Id){
            searchCondition+=' AND ((sales_representative__c=\''+loginContactId+'\') OR createdById = \''+ userId + '\'OR ownerid= \''+ userId + '\') ';
           }
        }else if(viewName == 'Oppty1Month'){
                Date requestedDate = Date.today().addDays(-30);
                searchCondition +=  ' AND CreatedDate = LAST_N_DAYS:30 ' ;
            
        }else if(viewName == 'Oppty7days'){
                Date requestedDate = Date.today().addDays(-7);
                searchCondition +=  ' AND CreatedDate = LAST_N_DAYS:7 ' ;
            
        }else if(viewName == 'Oppty14days'){
                Date requestedDate = Date.today().addDays(-14);
                searchCondition += ' AND CreatedDate = LAST_N_DAYS:14 ' ;
        }
        return searchCondition;
    }
    
    public Pagereference userActions(){
        initialize();
        queryOpptyList();
        calculatePageCount();
        return null;

    }
    
    private void queryOpptyList()
    {
        Integer offset = pageNumber * pageSize;
        List<Opportunity> opList=new List<Opportunity>();
        String baseQuery = getSelectionQuery();
        String countQuery=baseQuery+' LIMIT 2000';        
        String query = baseQuery + ' LIMIT '+ pageSize +' OFFSET '+ offset;
        System.debug('countQuery:'+ countQuery);
        System.debug('query:'+ query);
        try{
            opList= Database.Query(countQuery);
            OpptyList= Database.query(query); 
            totalCount=opList.size();                      
        }
        catch(Exception e){
            ApexPages.addMessages(e);
        }      
    }
    
   private void initialize(){
        totalCount = 0;
        pageNumber = 0;
        totalPageCount = 0;
        //setOpptyCount();        
    }
    
        public PageReference first(){
        pageNumber = 0;
        queryOpptyList();
        return null;
    }  
 
    public PageReference last(){
        pageNumber = totalPageCount - 1;
        queryOpptyList();
        return null;
    } 
        
    public PageReference previous(){
        pageNumber--;
        if (pageNumber < 0)
            return null;
        queryOpptyList();
        return null;
    }

    public PageReference next(){
        pageNumber++;
        queryOpptyList();
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
    /*private void setOpptyCount(){ 
    userId = UserInfo.getUserId();       
    String soqlQuery = ' Select count()'; 
        soqlQuery += ' from Opportunity ';
        if(test.isRunningTest())
        loginContactId = '003g000000GFnMXAA1';        
        if(Userinfo.getProfileId()==system.label.Partner_Ops_Profile_Id){
        soqlQuery += ' where StageName != null';
        }
        else{
        if(!PTOpptyIds.isEmpty()){
        soqlQuery += ' where StageName != null AND ((sales_representative__c=\''+loginContactId+'\') or(Opportunity_Source_Type__c=\'PT\' AND id in :PTOpptyIds) OR createdById = \''+ userId + '\' OR ownerid= \''+ userId + '\')';        
        }
        else{
        soqlQuery += ' where StageName != null AND ((sales_representative__c=\''+loginContactId+'\') OR createdById = \''+ userId + '\'OR ownerid= \''+ userId + '\') ';
        }
        }
        soqlQuery += ' LIMIT 2000';
        System.debug('soqlQuery1: ' + soqlQuery);
        totalCount= Database.countQuery(soqlQuery);
    } 
    */
    public pagereference redirectOppty(){
                baseURL = EDPUtil.getBaseURL();
                system.debug('--->base'+baseURL);
                String urlPath = baseURL + '/apex/partneropportunitycreate?id='+opptyId;
                PageReference pageRef = new PageReference(urlPath);     
                return pageRef;
    }   
    
   public class BaseException extends Exception {} 
}