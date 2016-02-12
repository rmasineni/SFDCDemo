public with sharing class CaseSearch {
    
    private String propsIdLike = '%%';
    private String caseLike = '%%';
    private String subLike = '%%';
    private String statusLike = '%%';
    private String custNameLike = '%%';
    private String opptyIdLike = '%%';
    private String leadIdLike = '%%';
    private List<Cases> caseList;
    
    public String baseURL{get;set;}
    public Case CaseObj;
    public String searchValue{get;set;}
    public String searchColumnName{get;set;}
    public String recTypeName {get;set;}
    
    public CaseSearch() {
        baseURL = EDPUtil.getBaseURL();
        recTypeName = Label.Partner_Help_Record_Type;
    }
    public PageReference doviewCase() {
        return null;
    }
    
    public PageReference doNewCase() {
        
        system.debug('BASE URL:' + baseURL);
        String urlPath = baseURL + '/apex/PartnerCreateCase';
        PageReference pageRef = new PageReference(urlPath);
        system.debug('PageReference: '+pageRef);
        pageRef.setRedirect(true);
        return pageRef;   
    }
    
     public List<Cases> getcases(){
        caseList = new List<Cases>();
        if(con != null){
            List<Case> tempCase= con.getRecords();
            caseList =  populateCaseList(tempCase);           
        }
        return caseList;
    }
    
    private List<Cases> populateCaseList(List<Case> CaseList){
        List<Cases> tempCaseList = new List<Cases>();
        Cases tempCases = null;
        for(Case CaseObj : caseList){
            tempCases = new Cases();
            tempCases.CaseObj  = CaseObj;
            tempCaseList.add(tempCases);
        }
        return tempcaseList;
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
    
    public PageReference redirectToDoc() {
        
        String docFolderId = Label.Partner_SelfHelp_Folder;
        String docURLPath = baseURL + '/015?fcf=' + docFolderId;
        PageReference pageRef = new PageReference(docURLPath);
        pageRef.setRedirect(true);
        return pageRef;   
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
    
    public class Cases{
        public Cases(){
         
        }
        public Case caseObj{get;set;}   
    }
    
    private ApexPages.StandardSetController createSQOLConnection(){
        ApexPages.StandardSetController tempConnection;
              
        String soqlQuery;
        soqlQuery = getSelectionQuery();
        
        System.debug('soqlQuery: ' + soqlQuery);
        tempConnection = new ApexPages.StandardSetController(Database.getQueryLocator(soqlQuery));
        return tempConnection;          
    }
    
    private String getSelectionQuery(){
        propsIdLike = '%%';
        caseLike = '%%';
        subLike = '%%';
        statusLike = '%%';
        custNameLike = '%%';
        opptyIdLike = '%%';
        leadIdLike = '%%';
        String userId = UserInfo.getUserId();
        RecordType recType = [Select Id from RecordType where Name = :recTypeName and SobjectType = 'Case'];
        String recTypeId = recType.Id;
        
        String searchCondition = '';
        if(searchValue != null && searchValue != ''){
            if(searchColumnName == 'case' && searchValue != null && searchValue != ''){
                system.debug('Search value case Number...'+searchValue);
                caseLike = '%' + searchValue + '%';
                searchCondition = ' AND (CaseNumber like :caseLike) ';
                            
            }else if(searchColumnName == 'subj' && searchValue != null && searchValue != ''){
                system.debug('Search value Subject...'+searchValue);
                subLike = '%' + searchValue + '%';
                searchCondition = ' AND (subject like :subLike) ';
                
            }else if(searchColumnName == 'status' && searchValue != null && searchValue != ''){
                system.debug('Search value Status...'+searchValue);
                statusLike = '%' + searchValue + '%';
                searchCondition = ' AND (status like :statusLike) ';
                
            }else if(searchColumnName == 'leadId' && searchValue != null && searchValue != ''){
                system.debug('Search value Lead Id...'+searchValue);
                leadIdLike = '%' + searchValue + '%';
                searchCondition = ' AND (Lead__r.name like :leadIdLike) ';
                
            }else if(searchColumnName == 'propsId' && searchValue != null && searchValue != ''){
                system.debug('Search value Proposal Id...'+searchValue);
                propsIdLike = '%' + searchValue + '%';
                searchCondition = ' AND (Proposal__r.name like :propsIdLike) ';
                 
            }else if(searchColumnName == 'opptyId' && searchValue != null && searchValue != ''){
                system.debug('Search value Opportunity Id...'+searchValue);
                opptyIdLike = '%' + searchValue + '%';
                system.debug('Search value Opportunity Id...'+opptyIdLike );
                searchCondition = ' AND (Opportunity__r.name like :opptyIdLike) ';
            
            }else if(searchColumnName == 'propCustName' && searchValue != null && searchValue != ''){
                system.debug('Search value Proposal Customer Name...'+searchValue);
                custNameLike = '%' + searchValue + '%';
                searchCondition = ' AND (Prop_Customer_Name__c like :custNameLike) ';
                 
            }
        }
        String soqlQuery;
            
        soqlQuery = 'Select ID,casenumber,subject,proposal__c, priority,Status,Opportunity__c,Lead__c,Lead__r.name,';
        soqlQuery += ' LastModifiedById,LastModifiedDate,CreatedById,Prop_Customer_Name__c, '; 
        soqlQuery += ' proposal__r.name, Opportunity__r.name from Case ';
        soqlQuery += ' where createdById = \''+ userId + '\'';
        soqlQuery += ' And RecordTypeId = \''+ recTypeId + '\'';
        soqlQuery += searchCondition;
        soqlQuery += ' ORDER BY LastModifiedDate DESC limit 10000' ;
        
        return soqlQuery;
    }
             
    
    public List<SelectOption> getSearchBy() {
        List<SelectOption> searchBy = new List<SelectOption>();
        searchBy.add(new SelectOption('case', 'Case Number'));
        searchBy.add(new SelectOption('subj','Subject'));
        searchBy.add(new SelectOption('status','Status'));
        searchBy.add(new SelectOption('leadId', 'Lead ID'));
        searchBy.add(new SelectOption('propsId', 'Proposal ID'));
        searchBy.add(new SelectOption('opptyId', 'Opportunity ID'));
        
        //searchBy.add(new SelectOption('propCustName', 'Customer Name'));
        return searchBy;
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
    
    public class BaseException extends Exception {}
       
}