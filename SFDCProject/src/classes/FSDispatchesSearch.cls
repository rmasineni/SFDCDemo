public with sharing class FSDispatchesSearch {
   
        public FS_Dispatch__c  dispatchObj;
        private string CustomernameLike = '%%';
        private string CityLike = '%%';
        private string DispatchIDLike = '%%';
        private string DispatchstateLike ='%%';
        private string CasereasonLike = '%%';
        private string PartnerTrackingIdLike = '%%';
        private Boolean bAllView = false;        
    
        public String viewName{get;set;} 
        public String searchvalue{get;set;}
        public String searchcolumnname{get;set;}
        public boolean displayFSDispatchName{get;set;}
        public Date partnerGoLiveDate {get;set;}
        public Date partnerContactGoLiveDate {get;set;}
        public String loginProfileId {get;set;}
        public String partnerType {get;set;}
        private List<FSDispatches> dispatchList;
        public Id loginPartnerAccountId {get;set;}
        public Id loginContactId {get;set;}
        public Boolean isOpsProfile {get;set;}
        public String urlPrefix {get;set;}

        public FSDispatchesSearch(){

            urlPrefix = '/partner';
            String baseURL = EDPUtil.getBaseURL();
            if(baseURL != null && !baseURL.contains(urlPrefix)){
            urlPrefix = '';
        }
        
        displayFSDispatchName = false;
        isOpsProfile = false;
        Contact contactObj = PRMContactUtil.getLoginUserAccountAndContact();
        if (contactObj !=null){
            loginPartnerAccountId = contactObj.account.Id;
            loginContactId = contactObj.Id;
            partnerType = contactObj.Account.Partner_Type__c;
            partnerGoLiveDate = contactObj.Account.EDP_Go_Live_Date__c;
            partnerContactGoLiveDate = contactObj.EDP_Go_Live_Date__c;
        }
        loginProfileId = UserInfo.getProfileId();
        }
   
   // the current sort direction. defaults to asc
       public String sortDir {
        // To set a Direction either in ascending order or descending order.
                                get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;}
        set;
      }

    // the current field to sort by. defaults to last name
      public String sortField {
        // To set a Field for sorting.
                                get  { if (sortField == null) {sortField = 'Name'; } return sortField;  }
        set;
      } 
              
     public PageReference doSearch()
     {
        if(searchValue != null && searchValue !='' && searchValue.Length() < 2) {
            String errorMessage = CustomErrorMessages.MINIMUM_SEARCH_STRING;
            Exception expObj = new FSException(errorMessage);
            expObj.setMessage(errorMessage);
            ApexPages.addMessages(expObj);
            return null;
        }
         con = null;    
         con = createSQOLConnection();
                con.setPageSize(25);
                return null;
         
     }
     public ApexPages.standardSetController con {
        get {
            if (con!= null) {
               return con;
            }
            con =  createSQOLConnection();
            con.setPageSize(25);
            return con; 
        }
     set;
    }  
     public class  FSDispatches{
         public FSDispatches() {
      }   
     public FS_Dispatch__c dispatchObj{get;set;}
     }
     
       //Following is to get the list of FSDispatches based on the View and Search String 
     public List<FSDispatches> getFSDispatches(){
              dispatchList = new List<FSDispatches>();
                if(con != null){
                   List<FS_Dispatch__C> tempFSDispatches = con.getRecords();
                   dispatchList =  populateFSDispatchList(tempFSDispatches);           
            }
            return dispatchList;
      }
        
        private List<FSDispatches> populateFSDispatchList(List<FS_Dispatch__c> fsdispatchList){
            List<FSDispatches> tempFSDispatchList = new List<FSDispatches>();
            FSDispatches tempFSDispatches = null;
            for(FS_Dispatch__c dispatchObj : fsdispatchList){
                tempFSDispatches = new FSDispatches();
                tempFSDispatches.dispatchObj  = dispatchObj;
                tempFSDispatchList.add(tempFSDispatches);
            }
            return tempFSDispatchList;
         } 
      
          public List<SelectOption> getViews() {
            List<SelectOption> Views = new List<SelectOption>();
                 Views.add(new SelectOption('ALL', 'ALL'));
                 Views.add(new SelectOption('ACTIVE', 'ACTIVE'));
              // Views.add(new SelectOption('ACTIVE(REC)', 'ACTIVE(REC)'));      
                 Views.add(new SelectOption('NEW', 'NEW'));
                  return Views;
        }
     
       //Search Option  Picklist
    
     public List<SelectOption> getSearchBy() {
            List<SelectOption> searchBy = new List<SelectOption>();
                  searchBy.add(new SelectOption('Customer Name', 'Customer Name'));
                  searchBy.add(new SelectOption('City','City'));
                  searchBy.add(new SelectOption('Dispatch ID','Dispatch ID'));
                  searchBy.add(new SelectOption('Dispatch state', 'Dispatch State'));
                  searchBy.add(new SelectOption('Case Reason', 'Case Reason'));
                  searchBy.add(new SelectOption('Partner Tracking Id','Partner Tracking ID'));
                  return searchBy;
    }       
      
     public pageReference clearSearchValue() {
            searchValue = '';
            return null;
            
    }
    //Following is to build SOQL connection
       private ApexPages.StandardSetController createSQOLConnection() {
               ApexPages.StandardsetController tempConnection;
               String soqlQuery;
               String opsProfileId = Label.Partner_Ops_Profile;
               System.debug('opsProfileId: ' + opsProfileId);
                           
               String userName = UserInfo.getName();
               soqlQuery = getSelectionQuery();
                
         System.debug('soqlQuery: ' + soqlQuery);
         
         tempConnection = new ApexPages.StandardSetController(Database.getQueryLocator(soqlQuery));        
         return  tempConnection;
       }    
          //TO Build the query based on selected view and enetered search string
       private String getSelectionQuery () {
           CustomernameLike = '%%';
           cityLike = '%%';
           DispatchIDLike = '%%';
           DispatchstateLike = '%%';
           CasereasonLike  = '%%';
           PartnerTrackingIdLike='%%';
           String soqlQuery = '';
           String userId = UserInfo.getUserId();
           String userName = UserInfo.getName(); 
           String searchCondition = '';
           System.debug(SearchValue);
           bAllView = false;
           
           if(searchValue != null && searchValue != '' ) {
              if(searchColumnName == 'Customer Name'){
                 system.debug('search value Customername..'+searchValue);
                 CustomernameLike = '%'+ searchvalue + '%';
                 SearchCondition = ' (FS_Customer_Name__c like :CustomernameLike) ';
                 SearchCondition += ' AND ';                
                 SearchCondition += getSearchConditionByViewName(userId,userName); 
            }
            else if(searchColumnName == 'City') {
                    system.debug('search value city..'+searchValue);
                    CityLike = '%' + searchvalue + '%';
                    SearchCondition = ' (FS_City__c like :CityLike) ';
                    SearchCondition += ' AND ';                
                    SearchCondition += getSearchConditionByViewName(userId,userName);
             }       
             else if(searchColumnName == 'Dispatch ID') {
                    system.debug('search value dispatch name..' +searchValue);
                    DispatchIDLike = '%' + searchvalue +'%';
                    SearchCondition = ' (Name like :DispatchIDLike) ';
                    SearchCondition += ' AND ';                
                    SearchCondition += getSearchConditionByViewName(userId,userName);
             } 
             else if(searchColumnName == 'Dispatch State') {
                    system.debug('search value dispatch state..' +searchValue);
                    DispatchStateLike = '%' + searchvalue +'%';
                    SearchCondition = ' (FS_Dispatch_State__c like :DispatchStateLike) ';
                    SearchCondition += ' AND ';                
                    SearchCondition += getSearchConditionByViewName(userId,userName);
             } 
             else if(searchColumnName == 'Case Reason') {
                    system.debug('search value Case reason..' +searchValue);
                    CaseReasonLike = '%' + searchvalue +'%';
                    SearchCondition = ' (Case_Reason__c like :CasereasonLike) ';
                    SearchCondition += ' AND ';                
                    SearchCondition += getSearchConditionByViewName(userId,userName);
             } 
             else if(searchColumnName == 'Partner Tracking ID') {
                    system.debug('search value PartnerTrackingId..' +searchValue);
                    PartnerTrackingIdLike = '%' + searchvalue +'%';
                    SearchCondition = ' (FS_Partner_Tracking_ID__c like :PartnerTrackingIdLike) ';
                    SearchCondition += ' AND ';                
                    SearchCondition += getSearchConditionByViewName(userId,userName);
             }
              }
            else {
                  searchCondition = getSearchConditionByViewName(userId,userName);
                
             }
            
            soqlQuery = 'select ID, FS_Customer_Name__c,Name,FS_City__c,FS_Gen_Asset_State__c,Case_Reason__c,';
            soqlQuery +=  'Subreason__c,FS_Selected_Partner_Name__c, Case_Priority__c,FS_Partner_Tracking_ID__c,';
            soqlQuery +=  'FS_Dispatch_State__c,FS_Time_Dispatched__c,FS_Time_Submitted__c, FS_Service_Contract__c, FS_Service_Contract_Event__c from FS_Dispatch__c '; 
            if (!bAllView){
                soqlQuery += ' where '; 
            }
            else if(bAllView && searchValue != null && searchValue != ''){
                soqlQuery += ' where ';
                searchCondition = searchCondition.substring(0, searchCondition.indexOf(' AND '));
            }    
            soqlQuery += searchCondition; 
            
            // simply toggle the direction
            sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        
            if (sortField==null || sortField ==''){
                soqlQuery += ' ORDER BY CreatedDate DESC limit 10000 ';
            }
            else{
                soqlQuery += ' ORDER BY ' + sortField + ' ' + sortDir + ' limit 10000 ';
                //soqlQuery += ' ORDER BY CreatedDate DESC limit 10000 ';
            }
            system.debug (soqlquery); 
            
                                            
             return soqlQuery;
            } 
           //Following is to get the selected views
         public Pagereference userActions(){
                 System.debug('ViewName Sample: ' + viewName);
                 Pagereference pageRef = null;
                 searchValue = null;
                 if(viewName == null || viewName == ''){
                 return null;
                 }else{
                 System.debug('ViewName Sample: ' + viewName);
                 pageRef = getFSdispatchSelectedView();
                 return pageRef;         
        }
                
    }

    //Following is to get the list of prposals for the selected views
     public PageReference getFSdispatchSelectedView() {
        con = null;
        con = createSQOLConnection();   
        con.setPageSize(25);
        return null;
     }   
         
         public Boolean hasNext{
        get
        {
            return con.getHasNext();
        }
        set;
    }
 

    public Boolean hasPrevious{
        get
        {
            return con.getHasPrevious();
        }
        set;
    }
 
    
    public Integer pageNumber{
        get
        {
            return con.getPageNumber();
        }
        set;
    }

    public void first(){
        con.first();
    }  
 
    public void last(){
        con.last();
    }
        
    public void previous(){
        con.previous();
    }

    public void next(){
        con.next();
    }  
    
     private String getSearchConditionByViewName(String userId, String userName){
        String SearchCondition = '';
        bAllView = False;
        if(viewName == null || viewName == '') {
          // viewName = 'ALL';  //CommentedBy Suneetha "BSKY-6106"
           viewName = 'ACTIVE';
        }   
        if(viewName == 'ACTIVE'){          
            displayFSDispatchName = true;
            SearchCondition += ' FS_Dispatch_State__c IN (\'Dispatch Accepted\',\'Dispatch Findings Rejected\') ';  
             system.debug('Searchcondition******' + searchCondition);  
         }
         
      /*  else if(viewName == 'ACTIVE(REC)'){          
           displayFSDispatchName = true;
           SearchCondition += ' FS_Dispatch_State__c IN (\'Dispatch Accepted\',\'Dispatch Findings Rejected\') ';  
           system.debug('Searchcondition******' + searchCondition);  
         }*/
         
        else if(viewName == 'ALL'){          
                displayFSDispatchName = true;
                bAllView = True;            
               //SearchCondition += ' FS_Dispatch_State__c = \'Dispatched\' ';  
                system.debug('Searchcondition******' + searchCondition);  
         }
           else if(viewName == 'NEW'){          
                 displayFSDispatchName = true;
                 SearchCondition += ' FS_Dispatch_State__c IN (\'Dispatched\') ';
          }
         
          return SearchCondition;
    
        } 
             
 // }
   public class FSException extends Exception {}
  
   }