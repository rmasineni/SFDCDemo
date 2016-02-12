public with sharing class LeadSearch {
    
    private String nameLike = '%%';
    private String emailLike = '%%';
    private String phoneLike = '%%';
    private String statusLike = '%%';
    private String addrLike = '%%';
    private List<Leads> leadList;
    public Lead leadObj;
    public String viewName{get;set;}
    public String searchColumnName{get;set;}
    public String searchValue{get;set;}
    public String loginProfileId {get;set;}
    public Boolean ispartnerUser;
    public String baseURL{get;set;}
    public boolean isUnAuthorizedUser{get;set;}
    
    public String Url;    
    public String getUrl(){
        baseURL = EDPUtil.getBaseURL();
        String urlPath = baseURL + '/apex/customizeLeadDetailPage?Id=';
        return urlPath;
    }
    public void setUrl(){
        this.url=url;
    }
    
    
    public LeadSearch(){
        loginProfileId = UserInfo.getProfileId();
        ispartnerUser = false;
        isUnAuthorizedUser = false;
        getIsPartnerUser();
        getIsUnAuthorizedUser();
    }
    
    public boolean getIsPartnerUser(){
        
        String userType = UserInfo.getUserType();
        if(userType != null && userType != ''){
            if(userType.contains('Partner')){
                ispartnerUser = true;
                return ispartnerUser;
            }
        }
        return ispartnerUser;
    }
    
    public User getUserAccountName(){
      user u = [select Id, Account_Name__c from User where Id =: userinfo.getUserId()];
      return u;
    }
    
    public boolean getIsUnAuthorizedUser(){
     
      set<string> unAuthorizedUserAccountSet = new set<String>();
      for(Disable_Button__c db : Disable_Button__c.getAll().Values()){
        if(db.Account_Name__c != null ){
          unAuthorizedUserAccountSet.add(db.Account_Name__c);
        }
      }
      user u = getUserAccountName();
      system.debug('==>user'+u);
      system.debug('==>UnAuthorized'+isUnAuthorizedUser);
      if(!UnAuthorizedUserAccountSet.isEmpty()){
        isUnAuthorizedUser = UnAuthorizedUserAccountSet.contains(u.Account_Name__c)?true:false;
      }
     return isUnAuthorizedUser;
    }
    
    public PageReference doSearch() 
    {
        if(searchValue != null && searchValue != '' && searchValue.Length() < 2){
            String errorMessage = CustomErrorMessages.MINIMUM_SEARCH_STRING;
            Exception expObj = new BaseException(errorMessage);
            expObj.setMessage(errorMessage);
            ApexPages.addMessages(expObj);
            return null;
        }
        
        con = null;
        con = createSQOLConnection();   
        con.setPageSize(10);
        return null;
    }
    
    public PageReference doEdit() 
    {
        return null;
    }
    
    public PageReference doNew() 
    {
        baseURL = EDPUtil.getBaseURL();
        
        String urlPath = baseURL + '/apex/PartnerLeadCreate?gmaps=1';
        PageReference pageRef = new PageReference(urlPath);
        pageRef.setRedirect(true);
        return pageRef;   
    }
    
    public PageReference doUpload() 
    {
        return null;
    }
    
    public PageReference doDownTemp() 
    {
        return null;
    }
    
    public ApexPages.StandardSetController con {
        get {
                if(con != null)
                {
                    return con;
                }
                con = createSQOLConnection();
                con.setPageSize(10);
                return con;
        }
        set;
    }       
    
    public class Leads{
        public Leads(){
         
        }
        public Lead leadObj{get;set;}   
    }
    
    public List<Leads> getLeads(){
        leadList = new List<Leads>();
        if(con != null){
            List<Lead> tempLead = con.getRecords();
            leadList =  populateLeadList(tempLead);           
        }
        return leadList;
    }
    
    private List<Leads> populateLeadList(List<Lead> leadList){
        List<Leads> tempLeadList = new List<Leads>();
        Leads tempLeads = null;
        for(Lead leadObj : leadList){
            tempLeads = new Leads();
            tempLeads.leadObj  = leadObj;
            tempLeadList.add(tempLeads);
        }
        return tempLeadList;
    }
    
    public List<SelectOption> getViews() {
        List<SelectOption> Views = new List<SelectOption>();
        
        String opsProfileId = Label.Partner_Ops_Profile;
        System.debug('opsProfileId: ' + opsProfileId);
        if(loginProfileId != null && loginProfileId.contains(opsProfileId)){
            Views.add(new SelectOption('allLeads', 'All Leads'));
        }
        Views.add(new SelectOption('myLeads', 'My Leads'));
        Views.add(new SelectOption('myActiveLeads', 'My Active Leads'));        
        Views.add(new SelectOption('myNewLeads', 'My New Leads'));        
        Views.add(new SelectOption('myClosedLeads', 'My Closed Leads'));
        Views.add(new SelectOption('Leads7days', 'Leads created in last 7 days'));
        Views.add(new SelectOption('Leads14days','Leads created in last 14 days'));
        Views.add(new SelectOption('Leads1Month', 'Leads created in last 1 month'));      
        return Views;
    }
    
    public List<SelectOption> getSearchBy() {
        List<SelectOption> searchBy = new List<SelectOption>();
        searchBy.add(new SelectOption('name', 'Customer Name'));
        searchBy.add(new SelectOption('addr', 'Customer Address'));
        searchBy.add(new SelectOption('email','Customer Email'));
        searchBy.add(new SelectOption('phone','Customer Phone'));
        //searchBy.add(new SelectOption('status', 'Lead Status'));
        return searchBy;
    }
    
    public PageReference clearSearchValue() {
        searchValue = '';
        return  null;
    }
    
   private ApexPages.StandardSetController createSQOLConnection(){
        ApexPages.StandardSetController tempConnection;
              
        String soqlQuery;
        if(viewName == '' || viewName == null){
            viewName = 'myLeads';
        }
        
        soqlQuery = getSelectionQuery();

        System.debug('soqlQuery: ' + soqlQuery);
        tempConnection = new ApexPages.StandardSetController(Database.getQueryLocator(soqlQuery));
        return tempConnection;          
    }
    
    private String getSelectionQuery(){
        nameLike = '%%';
        addrLike = '%%';
        emailLike = '%%';
        phoneLike = '%%';
        statusLike = '%%';
        
        String userId = UserInfo.getUserId();
        String userName = UserInfo.getName();
        
        String searchCondition = '';
        if(searchValue != null && searchValue != ''){
            if(searchColumnName == 'name' && searchValue != null && searchValue != ''){
                system.debug('Search value name...'+searchValue);
                nameLike = '%' + searchValue + '%';
                searchCondition = ' AND (Name like :nameLike) ';
                searchCondition += getSearchConditionByViewName(userId,userName);
                            
            }else if(searchColumnName == 'addr' && searchValue != null && searchValue != ''){
                system.debug('Search value addr...'+searchValue);
                addrLike = '%' + searchValue + '%';
                searchCondition = ' AND (Address_for_Search__c like :addrLike) ';
                searchCondition += getSearchConditionByViewName(userId,userName); 
                
            }else if(searchColumnName == 'email' && searchValue != null && searchValue != ''){
                system.debug('Search value email...'+searchValue);
                emailLike = '%' + searchValue + '%';
                searchCondition = ' AND (Email like :emailLike) ';
                searchCondition += getSearchConditionByViewName(userId,userName); 
                
            }else if(searchColumnName == 'phone' && searchValue != null && searchValue != ''){
                system.debug('Search value phone...'+searchValue);
                phoneLike = '%' + searchValue + '%';
                searchCondition = ' AND (Phone like :phoneLike) ';
                searchCondition +=  getSearchConditionByViewName(userId,userName);        
                
            }/*else if(searchColumnName == 'status' && searchValue != null && searchValue != ''){
                system.debug('Search value Status...'+searchValue);
                statusLike = '%' + searchValue + '%';
                searchCondition = ' AND (Status like :statusLike) ';
                searchCondition += getSearchConditionByViewName(userId,userName); 
            }*/
            //Change code from status to Lead_Status__c
            else if(searchColumnName == 'status' && searchValue != null && searchValue != ''){
                system.debug('Search value Status...'+searchValue);
                statusLike = '%' + searchValue + '%';
                searchCondition = ' AND (Lead_Status__c like :statusLike) ';
                searchCondition += getSearchConditionByViewName(userId,userName); 
            }
            
        }else{
                    searchCondition = getSearchConditionByViewName(userId,userName);

        }           

        String soqlQuery = 'Select ID,street,city,Lead_Status__c,state,postalcode,Name,Email,Phone,Status,CreatedDate,Utility_Company__c,Address_for_Search__c '; 
        soqlQuery += ' from Lead ';
        soqlQuery += ' where status != null and Status != \'Converted\'';
        soqlQuery += searchCondition;
        soqlQuery += ' ORDER BY CreatedDate DESC limit 10000' ;
        return soqlQuery;
    }
    
    public Pagereference userActions(){
        System.debug('ViewName Sample: ' + viewName);
        Pagereference pageRef = null;
        searchValue = '';
        if(viewName == null || viewName == ''){
            return null;
        }else{
            pageRef = getLeadsForSelectedView();
            return pageRef;         
        }
    }   
    
    public PageReference getLeadsForSelectedView() {
        con = null;
        con = createSQOLConnection();
        con.setPageSize(10);
        return null;
    }
    
    private String getSearchConditionByViewName(String userId, String userName){
        String searchCondition = '';
        if(viewName == 'myLeads'){
         //   searchCondition = ' AND CreatedById = \''+ userId+'\' ';
        }else if(viewName == 'allLeads'){
            searchCondition = '';
        }
        else if(viewName == 'myNewLeads'){
         //   searchCondition = ' AND CreatedById = \''+ userId+'\' ';
            searchCondition += ' AND status in (\'Created\') ';
        }
        else if(viewName == 'myActiveLeads'){
        //    searchCondition = ' AND CreatedById = \''+ userId+'\' ';
            searchCondition += ' AND status in (\'Created\',\'Qualification\') ';
        }
        else if(viewName == 'myClosedLeads'){
        //    searchCondition = ' AND CreatedById = \''+ userId+'\' ';
            searchCondition += ' AND status in (\'Converted\',\'Closed Lost\',\'Duplicate\') ';
        }
        else if(viewName == 'Leads1Month'){
                Date requestedDate = Date.today().addDays(-30);
         //       searchCondition = ' AND CreatedById = \''+ userId+'\' ';
                searchCondition +=  ' AND CreatedDate = LAST_N_DAYS:30 ' ;
            
        }else if(viewName == 'Leads7days'){
                Date requestedDate = Date.today().addDays(-7);
          //      searchCondition = ' AND CreatedById = \''+ userId+'\' ';
                searchCondition +=  ' AND CreatedDate = LAST_N_DAYS:7 ' ;
            
        }else if(viewName == 'Leads14days'){
                Date requestedDate = Date.today().addDays(-14);
          //      searchCondition = ' AND CreatedById = \''+ userId+'\' ';
                searchCondition += ' AND CreatedDate = LAST_N_DAYS:14 ' ;
        }
        return searchCondition;
    }
    
    
    public Boolean hasNext
    {
        get
        {
            return con.getHasNext();
        }
        set;
    }
 

    public Boolean hasPrevious
    {
        get
        {
            return con.getHasPrevious();
        }
        set;
    }
 
    
    public Integer pageNumber
    {
        get
        {
            return con.getPageNumber();
        }
        set;
    }

    public void first()
    {
        con.first();
    }  
 
    public void last()
    {
        con.last();
    }
        
    public void previous()
    {
        con.previous();
    }

    public void next()
    {
        con.next();
    } 
    public string retURL {get;set;}
    Id recordTypeId;
    String entStr;  
    public String leadId{set;get;}
    public pagereference redirectLead(){
    String leadPrefix = Schema.SObjectType.lead.getKeyPrefix();
    retURL = System.currentPagereference().getParameters().get('retURL');
    recordTypeId = System.currentPagereference().getParameters().get('RecordType');
    entStr = System.currentPagereference().getParameters().get('ent');

    String redirectUrl = System.URL.getCurrentRequestUrl().getPath();
    Boolean isPartnerPortalURL = false;
    if(redirectUrl.startsWith('/partner')){
       isPartnerPortalURL = true;
    }   
    Id userId = UserInfo.getUserId();
    User loginUser = PRMContactUtil.getUser(userId);
    String url = '';
    if(retURL == null){
       retURL = '';
    }
    if(loginUser.contactId == null){
        url = '/'+ leadPrefix +'/e?retURL=' + retURL  + '&nooverride=1';
        if(recordTypeId != null){
            url +=  '&RecordType='  + recordTypeId;
        }
                
        if(entStr != null && entStr != ''){
            url +=  '&ent='  + entStr;
        }
        }
    else{
         url = (isPartnerPortalURL) ? '/partner/apex/customizeLeadDetailPage?id='+leadId : '/apex/customizeLeadDetailPage?id='+leadId ;
         url += retURL;
         if(recordTypeId != null){
                url +=  '&RecordType='  + recordTypeId;
         }
                
        if(entStr != null && entStr != ''){
            url +=  '&ent='  + entStr;
        }           
        }
        System.debug('url: ' + url);
        PageReference pageRef = new PageReference(url); 
        return pageRef;
    }
    
    public class BaseException extends Exception {}
}