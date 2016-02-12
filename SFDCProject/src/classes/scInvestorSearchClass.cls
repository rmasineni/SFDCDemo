public class scInvestorSearchClass {
  
    private String scNameLike = '%%';
    private String accNameLike = '%%';
    private String CounterParnterLike = '%%';
    private String teFundNameLike = '%%';
     List <string> teFundName = new List<String>();
    public String loginProfileId {get;set;}
    public Integer totalPageCount{get;set;}
    public Integer pageNumber = 0;
    public Integer totalCount {get;set;}
    public Integer pageSize = 10;
    public List<ServiceContract> ScList{get;set;}    
    public String userId{get;set;}
    public String searchColumnName{get;set;}
    public String searchValue{get;set;}
    public Id loginContactId {get;set;}
    public String viewName{get;set;}
    public String baseURL{get;set;}
    public String scId{set;get;}
    public set<id> InvestorSCIdSet = new set<id>();
    public String urlPrefix {get;set;}
    public string dummyName {get; set;}
  	public map <id, id> accToSCIdMap = new map<id,id> ();
    public map <id, String> accountToTeFnameMap = new map<id, String>();
    set <String> invBorrowerSet = new set<string>{'Investor', 'Borrower'};
 
    
    public scInvestorSearchClass() {  
           try{
               /* if(invBorrowerSet.isEmpty() && invBorrowerSet == null ){
                   invBorrowerSet.add('Investor');
                   invBorrowerSet.add('Borrower');
               } */
               viewName = 'myServiceContract';
                loginProfileId = UserInfo.getProfileId();
                userId = UserInfo.getUserId(); 
                system.debug('loginProfileId------>'+loginProfileId);
                Contact contactObj = PRMContactUtil.getLoginUserAccountAndContact();
                system.debug('contactObj------>'+contactObj);
                loginContactId = contactObj.Id;
                InvestorSCIdSet = getInvestorScIdList(contactObj);
               	userActions();
                }catch(Exception exceptionObj){
            ApexPages.addMessages(exceptionObj);               
        }           
        initialize();
        querySCList();
        calculatePageCount();
        
    }
    
    public List<ServiceContract> getScList(){
        return scList;
    }   
   public List<SelectOption> getViews() {
        List<SelectOption> Views = new List<SelectOption>();
        Views.add(new SelectOption('myServiceContract', 'My ServiceContract'));
        Views.add(new SelectOption('myNewSC', 'My New SC'));              
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
        scNameLike = '%%';
        accNameLike = '%%';   
        CounterParnterLike = '%%';
        teFundNameLike = '%%';
        String userName = UserInfo.getName();          
        String searchCondition = '';
        if(searchValue != null && searchValue != ''){
            if(searchColumnName == 'name' && searchValue != null && searchValue != ''){
                system.debug('Search value name...'+searchValue);
                scNameLike = '%' + searchValue + '%';
                searchCondition = ' AND (Name like :scNameLike) ';
                searchCondition += getSearchConditionByViewName(userId,userName);
            }  
            else if(searchColumnName == 'CounterPartner' && searchValue != null && searchValue != ''){
                system.debug('Search Value Name...' + searchValue);
                CounterParnterLike = '%' + searchValue + '%';
                teFundName = getTeFundNameListFromInvestorMap(CounterParnterLike.removeEnd(' ')) ;     
                 searchCondition = ' AND (TE_FUND_NAME__C in :teFundName )';
                 searchCondition += getSearchConditionByViewName(userId,userName);
                 system.debug('TE_FUND_NAME__C...' + teFundName);
            }
            else if(searchColumnName == 'TEFundName' && searchValue != null && searchValue != ''){
                system.debug('Search Value Name...' + searchValue);
                teFundNameLike = '%' + searchValue + '%';   
                searchCondition = ' AND (TE_FUND_NAME__C Like :teFundNameLike )';
                searchCondition += getSearchConditionByViewName(userId,userName);
            }
            
        }else{
                searchCondition = getSearchConditionByViewName(userId,userName);
        }           
        
        String soqlQuery = 'Select ID,Name,Agreement_Type__c,Accountid,Account.name,Proposal__c,status__c,Purchased_Thru__c,CreatedDate,Service_Contract_Event__c,TE_Fund_Name__c,Phone__c,Opportunity__c,Customer_Signoff__c'; 
        soqlQuery += ' from ServiceContract ';
        //if(test.isRunningTest())
        //loginContactId = '003g000000GFnMXAA1';        
        if(Userinfo.getProfileId()==system.label.Investor_Profile_id){
        soqlQuery += ' where Status__c != null';
        }
        //system.debug('>>Profile id' + Userinfo.getProfileId() + system.label.Test_Investor_Profile_id  );
        soqlQuery += searchCondition;
        soqlQuery += ' ORDER BY CreatedDate desc' ;
        return soqlQuery;
    	
    }
    
    public List<SelectOption> getSearchBy() {
        List<SelectOption> searchBy = new List<SelectOption>();
   	    searchBy.add(new SelectOption('name', 'Service Contract Name'));        
        searchBy.add(new SelectOption('CounterPartner', 'Counter Partner'));
        searchBy.add(new SelectOption('ContractNumber', 'Contract Number'));
        searchBy.add(new SelectOption('TEFundName','TE Fund Name')) ;
      
        return searchBy;
    }
    
    private set<id> getInvestorScIdList( contact con){
        set <id> InvScId = new set<id>();
    	id accid= con.account.id;
        system.debug('>>invBorrowerset ' + invBorrowerset);
    	if(accid != null)
    	for (account acc : [select Id, name, (select id, name,account__c,type__c, ServiceContract__c 
                                              from Service_Contract_Partner_Rels__r 
                                              where type__c in :invBorrowerset ) from account where id =:accid ]){
                                                  system.debug('>>acc ' +acc );
    		for(Service_Contract_Partner_Rel__c relPartner: acc.Service_Contract_Partner_Rels__r){
                system.debug('>>Service_Contract_Partner_Rels__r ' + relPartner);
                InvScId.add(relPartner.ServiceContract__c);
    			accToSCIdMap.put(relPartner.account__c,relPartner.ServiceContract__c);
    		}
    	}
        System.debug('>> List of SC' + InvScId);
    	return InvScId;
    }
    
    private list<String>  getTeFundNameListFromInvestorMap(string CounterParntner){
        system.debug('>>CounterParntner ' + CounterParntner);
        list<String> TEFundNameList = new list<string>();
        for(Investor_Mapping__c inv: [Select te_Fund_name__c,Name__c, name__r.name from Investor_Mapping__c 
                                      where name__r.name Like :CounterParntner]){
                                          TEFundNameList.add(inv.te_Fund_name__c);
                                          accountToTeFnameMap.put(inv.name__c, inv.te_fund_Name__c);
                                      }
        return TEFundNameList; 
    }
    
    private String getSearchConditionByViewName(String userId, String userName){
        String searchCondition = '';
        dummyName = 'xyz543!!!';
        system.debug('viewName' + viewName + InvestorSCIdSet);
        if(viewName == 'myServiceContract'){
           searchCondition = '';
           if(Userinfo.getProfileId()==system.label.Investor_Profile_id && !InvestorSCIdSet.isEmpty() && InvestorSCIdSet.size()>0){
           
            searchCondition+=' AND (id  in:InvestorSCIdSet) ';
           }
            else{
                 searchCondition += 'AND (name  =: dummyName) ';
                system.debug('>> srchCond' + searchCondition);
            }
        }else if(viewName == 'myNewSC'){
            searchCondition = '';
        }
      
        return searchCondition;
    }
    
    public Pagereference userActions(){
        initialize();
        querySCList();
        calculatePageCount();
        return null;

    }
    
    private void querySCList()
    {
        Integer offset = pageNumber * pageSize;
        List<ServiceContract> scListSize=new List<ServiceContract>();
        String baseQuery = getSelectionQuery();
        String countQuery=baseQuery+' LIMIT 2000';        
        String query = baseQuery + ' LIMIT '+ pageSize +' OFFSET '+ offset;
        System.debug('countQuery:'+ countQuery);
        System.debug('query:'+ query);
        try{
            scListSize= Database.Query(countQuery);
            scList= Database.query(query); 
            totalCount=scListSize.size();                      
        }
        catch(Exception e){
            ApexPages.addMessages(e);
        }      
    }
    
   private void initialize(){
        totalCount = 0;
        pageNumber = 0;
        totalPageCount = 0;
              
    }
    
        public PageReference first(){
        pageNumber = 0;
        querySCList();
        return null;
    }  
 
    public PageReference last(){
        pageNumber = totalPageCount - 1;
        querySCList();
        return null;
    } 
        
    public PageReference previous(){
        pageNumber--;
        if (pageNumber < 0)
            return null;
        querySCList();
        return null;
    }

    public PageReference next(){
        pageNumber++;
        querySCList();
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
 
    public pagereference redirectSC(){
                baseURL = EDPUtil.getBaseURL();
                system.debug('--->base'+baseURL);
                String urlPath = baseURL + '/apex/scInvestorDetail?id='+scId;
                PageReference pageRef = new PageReference(urlPath);     
                return pageRef;
    }   
    
   public class BaseException extends Exception {} 

}