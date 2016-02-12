/********************************************************************************
*   Author      : Chandrika Dasaradharaman (chandrikad@sunrunhome.com)          *
*   Date        : March 2012                                                    *
*   Name        : ProposalSearch.cls                                            *
*   Description : This class is used to list the available                      * 
*                 notes for a proposal and also allows to add or edit the notes *
*                                                                               *
*********************************************************************************/
public with sharing class ProposalSearch {
    Id proposalId;
    public Proposal__c proposalObj;
    private String propsIdLike = '%%';
    private String nameLike = '%%';
    private String addrLike = '%%';
    private String stageLike = '%%';
    private String salesRepLike = '%%';
    public string partnerStr {get;set;}
    public Set<String> ExcludedUsers;
    
    public String viewName{get;set;}
    public String searchColumnName{get;set;}
    public String searchValue{get;set;}
    public boolean displayProposalName{get;set;}

    public Date partnerGoLiveDate {get;set;}
    public Date partnerContactGoLiveDate {get;set;}
    public String loginProfileId {get;set;}
    public String partnerType {get;set;}
    private List<Proposals> propList;
    public Id loginPartnerAccountId {get;set;}
    public Id loginContactId {get;set;}
    public Boolean isOpsProfile {get;set;}
    public String urlPrefix {get;set;}

    public ProposalSearch(){

        try{
            urlPrefix = '/partner';
            String baseURL = EDPUtil.getBaseURL();
            if(baseURL != null && !baseURL.contains(urlPrefix)){
                urlPrefix = '';
            }
            
            displayProposalName = false;
            isOpsProfile = false;
            Contact contactObj = PRMContactUtil.getLoginUserAccountAndContact();
            if(contactObj == null){
                String errorMessage = 'Sunrun user is not associated with a valid Contact. Please contact Sunrun Salesforce Administrator.';
                Exception expObj = new BaseException(errorMessage);
                expObj.setMessage(errorMessage);
                ApexPages.addMessages(expObj);          
            }           

            if(PRMContactUtil.isPartnerContact(contactObj)){
                loginPartnerAccountId = contactObj.account.Id;
                loginContactId = contactObj.Id;
                partnerType = contactObj.Account.Partner_Type__c;
                partnerGoLiveDate = contactObj.Account.EDP_Go_Live_Date__c;
                partnerContactGoLiveDate = contactObj.EDP_Go_Live_Date__c;
                loginProfileId = UserInfo.getProfileId();   
            }   
            initializeExcludedUsers();  
        }catch(Exception exceptionObj){
            ApexPages.addMessages(exceptionObj);    
        }
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
            
            con = null;
            con = createSQOLConnection();   
            con.setPageSize(10);
            
        }catch(Exception exceptionObj){
            ApexPages.addMessages(exceptionObj);    
        }
        return null;
    }
    

    public ApexPages.StandardSetController con {
        get {
            
            if(con == null){
                String userId = UserInfo.getUserId();
                String userIdTemp = userId.substring(0, 15);                    
                if(viewName == '' || viewName == null){
                    viewName = 'myProps';
                    displayProposalName = true;
                }
            }

            
            //if(con != null){
           //         return con;
           // }
            //con = createSQOLConnection();
            //con.setPageSize(10);
            return con;
        }
        set;
    }       

    public class Proposals{
        public Proposals(){
        }
        public Proposal__c proposalObj{get;set;}   
    }
        
    //Following is to get the list of proposals based on the View and Search String
    public List<Proposals> getProposals(){
        propList = new List<Proposals>();
        if(con != null){
            List<Proposal__c> tempProposals = con.getRecords();
            if(tempProposals == null)
                tempProposals = new List<Proposal__c>();
            propList =  populateProposalList(tempProposals);           
        }
        return propList;
    }
    
    private List<Proposals> populateProposalList(List<Proposal__c> proposalList){
        List<Proposals> tempProposalList = new List<Proposals>();
        Proposals tempProposals = null;
        for(Proposal__c proposalObj : proposalList){
            tempProposals = new Proposals();
            tempProposals.proposalObj  = proposalObj;
            tempProposalList.add(tempProposals);
        }
        return tempProposalList;
    }
    
   
    //Following is to build the views
    public List<SelectOption> getViews() {
        List<SelectOption> Views = new List<SelectOption>();
        
       /* //Following is to dispaly All Porposals view for only Partner Ops
        String opsProfileId = Label.Partner_Ops_Profile;
        String adminOpsProfileId = Label.Partner_AdminOps_Profile;
        
        System.debug('opsProfileId: ' + opsProfileId);
        System.debug('AdminOpsProfileId: ' + adminOpsProfileId); */
        
        if(loginProfileId != null){
            system.debug('loginProfileId' + loginProfileId);
            String tempProfileId = loginProfileId;
            tempProfileId = tempProfileId.substring(0,15);
            String profileLike = '%'+ tempProfileId +'%';
            System.debug('profileLike: ' + profileLike);
            List<Partner_Ops_Profiles__c> opsProfileList = [Select Id, profile_Id__c from Partner_Ops_Profiles__c where profile_Id__c like :profileLike];
            if(opsProfileList != null && opsProfileList.size() > 0){
                isOpsProfile = true;
            }
        }
        
        system.debug('isOpsProfile' + isOpsProfile);
        if(loginProfileId != null && isOpsProfile == true){
            Views.add(new SelectOption('allProps', 'All Proposals'));
            //Views.add(new SelectOption('allChange', 'All Change Orders'));    
            viewName = 'allProps';  
        }
        
        Views.add(new SelectOption('myProps', 'My Proposals'));
        //Views.add(new SelectOption('myChange', 'My Change Orders'));
        
        //Following is to dispaly Proposals created by SR Operations view for Install partners only
       /* if(partnerType != null && partnerType != '' && 
            (partnerType.contains('Install'))){
            Views.add(new SelectOption('CreadBySROPS', 'Proposals created by SR Operations'));          
        }*/

        Views.add(new SelectOption('Props7days', 'Proposals created in last 7 days'));
        Views.add(new SelectOption('Props14days','Proposals created in last 14 days'));
        Views.add(new SelectOption('Props1Month', 'Proposals created in last 1 month'));
        return Views;
    }
    
    //Following is to build the Searchby options picklist
    public List<SelectOption> getSearchBy() {
        List<SelectOption> searchBy = new List<SelectOption>();
        searchBy.add(new SelectOption('name', 'Customer Name'));
        searchBy.add(new SelectOption('addr','Customer Address'));
        searchBy.add(new SelectOption('stage','Proposal Stage'));
        searchBy.add(new SelectOption('propsId', 'Proposal ID'));
        searchBy.add(new SelectOption('SalesRep', 'Sales Rep'));
        return searchBy;
    }
    
    //Following is to clear the searchstring entered by user
    public PageReference clearSearchValue() {
        searchValue = '';
        return  null;
    }
    
    //Following is to build the SOQL connection
    private ApexPages.StandardSetController createSQOLConnection(){
        ApexPages.StandardSetController tempConnection;
              
        String soqlQuery;
        String opsProfileId = Label.Partner_Ops_Profile;
        
        System.debug('opsProfileId: ' + opsProfileId);

        //if((viewName == '' || viewName == null) && (loginProfileId != null && loginProfileId.contains(opsProfileId))){
        //    viewName = 'allProps';
        //}else 
        
        if(viewName == '' || viewName == null){
            viewName = 'myProps';
            displayProposalName = true;
        }
        
        String userName = UserInfo.getName();
        soqlQuery = getSelectionQuery();
        
        Set<String> proposalStages = initializeProposalStages();
        System.debug('soqlQuery: ' + soqlQuery);
        tempConnection = new ApexPages.StandardSetController(Database.getQueryLocator(soqlQuery));
        return tempConnection;          
    }
    
    //Follwoing is to build the query dynamically to fetch records based on the selected view and entered search string
    private String getSelectionQuery(){
        propsIdLike = '%%';
        nameLike = '%%';
        addrLike = '%%';
        stageLike = '%%';
        salesRepLike = '%%';
        String userId = UserInfo.getUserId();
        String userName = UserInfo.getName();
        
        
        //Following is to build the Where Condition dynmaically for SOQL query
        String searchCondition = '';
        if(searchValue != null && searchValue != ''){
            if(searchColumnName == 'propsId' && searchValue != null && searchValue != ''){
                system.debug('Search value proposid...'+searchValue);
                propsIdLike = '%' + searchValue + '%';
                searchCondition = ' AND (Name like :propsIdLike ) ';
                searchCondition += getSearchConditionByViewName(userId,userName);
                            
            }else if(searchColumnName == 'name' && searchValue != null && searchValue != ''){
                system.debug('Search value name...'+searchValue);
                nameLike = '%' + searchValue + '%';
                searchCondition = ' AND (Homeowner_Name__c like :nameLike) ';
                searchCondition += getSearchConditionByViewName(userId,userName); 
                
            }else if(searchColumnName == 'addr' && searchValue != null && searchValue != ''){
                system.debug('Search value addr...'+searchValue);
                addrLike = '%' + searchValue + '%';
                searchCondition = ' AND (Customer_Address__c like :addrLike) ';
                searchCondition += getSearchConditionByViewName(userId,userName);        
                
            }else if(searchColumnName == 'stage' && searchValue != null && searchValue != ''){
                system.debug('Search value Stage...'+searchValue);
                stageLike = '%' + searchValue + '%';
                searchCondition = ' AND (Stage__c like :stageLike) ';
                searchCondition += getSearchConditionByViewName(userId,userName); 
            }else if(searchValue != null && searchValue != '' && searchColumnName == 'SalesRep'){
                system.debug('Search value by Sales Rep...'+searchValue);
                salesRepLike = '%' + searchValue + '%';
                searchCondition = ' AND (Partner_Sales_Rep__r.name like :salesRepLike ) ';
                searchCondition += getSearchConditionByViewName(userId,userName); 
            }
            searchCondition +=  (partnerGoLiveDate != null ) ? ' AND CreatedDate >= :partnerGoLiveDate ' : ' '; 
            
        }else{
            searchCondition = getSearchConditionByViewName(userId,userName);

        }             
        //String expirationDays = (Label.Proposal_Expiration_Days != null && Label.Proposal_Expiration_Days != '') ? Label.Proposal_Expiration_Days : '60';
        
        String soqlQuery = 'Select ID,Name,Original_Proposal_ID__c,Original_Proposal_ID__r.name,Change_Order_ID__c,Change_Order_ID__r.name,Stage__c,CreatedDate,'; 
        soqlQuery += ' Homeowner_Name__c,Homeowner_Phone__c,Customer_Address__c, User_Name__c, Agreement_Type__c, Proposal_Name__c, ';
        soqlQuery += ' Original_Proposal_ID__r.createdDate, LastModifiedDate  from proposal__c ';
        soqlQuery += ' where stage__c in :proposalStages AND status__c = \'Valid\' ';
        soqlQuery += ' and (createdDate >= :partnerGoLiveDate) ';
        if(loginPartnerAccountId != null){
            soqlQuery += ' and (Sales_Partner__c =:loginPartnerAccountId OR Install_Partner__c =:loginPartnerAccountId) ';
        }
        
        soqlQuery += searchCondition;
        soqlQuery += ' ORDER BY CreatedDate DESC ' ;
        soqlQuery += (partnerGoLiveDate != null ) ? ' limit 100000 ' : ' limit 0 ' ;
        return soqlQuery;
    }
    
    //Following is to get the selected views
    public Pagereference userActions(){
        System.debug('ViewName Sample: ' + viewName);
        Pagereference pageRef = null;
        searchValue = '';
        if(viewName == null || viewName == ''){
            return null;
        }else{
            pageRef = getProposalsForSelectedView();
            return pageRef;         
        }
                
    }

    //Following is to get the list of prposals for the selected views
    public PageReference getProposalsForSelectedView() {
        con = null;
        con = createSQOLConnection();   
        con.setPageSize(10);
        return null;
    }
        
    //Following methods are used for Pagination
    public Boolean hasNext{
        get
        {
            return (con != null) ? con.getHasNext() : false;  
        }
        set;
    }
 

    public Boolean hasPrevious{
        get
        {
            return (con != null) ? con.getHasPrevious() : false;
        }
        set;
    }
 
    
    public Integer pageNumber{
        get
        {
            return (con != null) ? con.getPageNumber() : 0;
        }
        set;
    }

    public void first(){
        
        if(con != null){
            con.first();
        }
        
    }  
 
    public void last(){
        if(con != null){
            con.last();
        }
        
    }
        
    public void previous(){
        if(con != null){
            con.previous();
        }
    }

    public void next(){
        if(con != null){
            con.next();
        }
        
    }   
  
    //Following is to built the Search condition based on the viwes selected
    private String getSearchConditionByViewName(String userId, String userName){
        String searchCondition = '';
        String onlyP = 'P%';
        String onlyC = 'C%';
        String onlyH = 'H%';
        String salesProfileId = Label.Partner_Sales_Profile;
        System.debug('salesProfileId: ' + salesProfileId);
        displayProposalName = false;
        if(viewName == 'myProps'){
            displayProposalName = true;
            //searchCondition += ' AND Original_Proposal_ID__c = NULL ' ;
            searchCondition += ' AND (Assigne__c = \''+ userId +'\' OR Sales_Rep__c =:userName  OR createdById = \''+ userId + '\' ' ;
            searchCondition += (loginContactId != null) ? ' OR Partner_Sales_Rep__c = \'' + loginContactId + '\' ' : '';
            searchCondition +=  ') ' ;
            searchCondition +=  (partnerContactGoLiveDate != null) ? ' AND CreatedDate >= :partnerContactGoLiveDate ' : ' ';

            system.debug('Searchcondition******' + searchCondition);
        }
        
        //else if(viewName == 'myChange'){
        //    searchCondition = ' AND (Assigne__c = \''+ userId+'\' OR Sales_Rep__c =:userName OR createdById = \''+ userId + '\' ';
        //  searchCondition += (loginContactId != null) ? ' OR Partner_Sales_Rep__c = \'' + loginContactId + '\' ' : '' ;
        //  searchCondition +=  ') ' ;
        //  
         //   searchCondition += ' AND Original_Proposal_ID__c != NULL ' ;
         //   searchCondition +=  (partnerContactGoLiveDate != null) ? ' AND CreatedDate >= :partnerContactGoLiveDate ' : ' ';
        //}
        
        else if(viewName == 'allProps'){
            displayProposalName = true;
            //searchCondition += ' AND Original_Proposal_ID__c = NULL ' ;
            searchCondition +=  (partnerGoLiveDate != null) ? ' AND CreatedDate >= :partnerGoLiveDate ' : ' ';
        }
        //else if(viewName == 'allChange'){
        //    searchCondition += ' AND Original_Proposal_ID__c != NULL ' ;
        //    searchCondition +=  (partnerGoLiveDate != null) ? ' AND CreatedDate >= :partnerGoLiveDate ' : ' ';
        //}
        
        else if(viewName == 'CreadBySROPS'){
            searchCondition = ' AND (user_name__c like  \'%'+ EDPUtil.SUNRUN_EMAIL_EXTENSION +'\') ';
            searchCondition +=  (partnerContactGoLiveDate != null) ? ' AND CreatedDate >= :partnerContactGoLiveDate ' : ' ';
        }
        
        else if(viewName == 'Props1Month'){
            displayProposalName = true;
            //searchCondition += ' AND Original_Proposal_ID__c = NULL ' ;
            if(loginProfileId != null && loginProfileId.contains(salesProfileId)){
                if(partnerGoLiveDate == null){
                   // searchCondition += ' AND (Assigne__c = \''+ userId+'\' OR Sales_Rep__c =:userName OR createdById = \''+ userId + '\' ' ;
                    //searchCondition += (loginContactId != null) ? ' OR Partner_Sales_Rep__c = \'' + loginContactId + '\' ' : '';
                    //searchCondition +=  ') ' ;                    
                  //  searchCondition += ' AND CreatedDate = null ';
                }else{
                    Date requestedDate = Date.today().addDays(-30);
                    searchCondition += ' AND (Assigne__c = \''+ userId+'\' OR Sales_Rep__c =:userName OR createdById = \''+ userId + '\' ';
                    searchCondition += (loginContactId != null) ? ' OR Partner_Sales_Rep__c = \'' + loginContactId + '\' ' : '';
                    searchCondition +=  ') ' ;                     
                    
                    searchCondition +=  (requestedDate > partnerGoLiveDate ) ? ' AND CreatedDate = LAST_N_DAYS:30 ' : ' AND CreatedDate >= :partnerGoLiveDate  ';
                }
            }else{
                if(partnerGoLiveDate == null){
                    //searchCondition += ' AND CreatedDate = null ';
                }else{
                    Date requestedDate = Date.today().addDays(-30);
                    searchCondition +=  (requestedDate > partnerGoLiveDate ) ? ' AND CreatedDate = LAST_N_DAYS:30 ' : ' AND CreatedDate >= :partnerGoLiveDate  ';
                }
            }
        }else if(viewName == 'Props7days'){
            displayProposalName = true;
            //searchCondition += ' AND Original_Proposal_ID__c = NULL ' ;
            if(loginProfileId != null && loginProfileId.contains(salesProfileId)){
                if(partnerGoLiveDate == null){
                   // searchCondition += ' AND (Assigne__c = \''+ userId+'\' OR Sales_Rep__c =:userName OR createdById = \''+ userId + '\' ';
                    
                    //searchCondition += (loginContactId != null) ? ' OR Partner_Sales_Rep__c = \'' + loginContactId + '\' ' : '';
                    //searchCondition +=  ') ' ; 
                                        
                    //OR Partner_Sales_Rep__c = \'' + loginContactId + '\') ';
                  //  searchCondition += ' AND CreatedDate = null ';
                }else{
                    Date requestedDate = Date.today().addDays(-7);
                    searchCondition += ' AND (Assigne__c = \''+ userId+'\' OR Sales_Rep__c =:userName OR createdById = \''+ userId + '\' ';

                    searchCondition += (loginContactId != null) ? ' OR Partner_Sales_Rep__c = \'' + loginContactId + '\' ' : '';
                    searchCondition +=  ') ' ; 
                    
                    //OR Partner_Sales_Rep__c = \'' + loginContactId + '\') ';
                    searchCondition +=  (requestedDate > partnerGoLiveDate ) ? ' AND CreatedDate = LAST_N_DAYS:7 ' : ' AND CreatedDate >= :partnerGoLiveDate  ';
                }
            }else{
                if(partnerGoLiveDate == null){
                    //searchCondition += ' AND CreatedDate = null ';
                }else{
                    Date requestedDate = Date.today().addDays(-7);
                    searchCondition +=  (requestedDate > partnerGoLiveDate ) ? ' AND CreatedDate = LAST_N_DAYS:7 ' : ' AND CreatedDate >= :partnerGoLiveDate  ';
                }
            }
        }else if(viewName == 'Props14days'){
            displayProposalName = true;
            //searchCondition += ' AND Original_Proposal_ID__c = NULL ' ;
            if(loginProfileId != null && loginProfileId.contains(salesProfileId)){
                if(partnerGoLiveDate == null){
                    //searchCondition += ' AND (Assigne__c = \''+ userId+'\' OR Sales_Rep__c =:userName OR createdById = \''+ userId + '\' ';

                    //searchCondition += (loginContactId != null) ? ' OR Partner_Sales_Rep__c = \'' + loginContactId + '\' ' : '';
                    //searchCondition +=  ') ' ; 
                    //searchCondition += ' AND CreatedDate = null AND Original_Proposal_ID = NULL ';
                }else{
                    Date requestedDate = Date.today().addDays(-14);
                    searchCondition += ' AND (Assigne__c = \''+ userId+'\' OR Sales_Rep__c =:userName OR createdById = \''+ userId + '\' ';
                    
                    searchCondition += (loginContactId != null) ? ' OR Partner_Sales_Rep__c = \'' + loginContactId + '\' ' : '';
                    searchCondition +=  ') ' ; 
                                        
                    // OR Partner_Sales_Rep__c = \'' + loginContactId + '\') ';
                    searchCondition +=  (requestedDate > partnerGoLiveDate ) ? ' AND CreatedDate = LAST_N_DAYS:7 ' : ' AND CreatedDate >= :partnerGoLiveDate  ';
                }
            }else{
                if(partnerGoLiveDate == null){
                   // searchCondition += ' AND CreatedDate = null ';
                }else{
                    Date requestedDate = Date.today().addDays(-14);
                    searchCondition +=  (requestedDate > partnerGoLiveDate ) ? ' AND CreatedDate = LAST_N_DAYS:14 ' : ' AND CreatedDate >= :partnerGoLiveDate  ';
                }
            }
        }
        return searchCondition;
    }
    public class BaseException extends Exception {}
    
    public void initializeExcludedUsers(){
        if(ExcludedUsers == null){
            ExcludedUsers = new Set<String>();
            for (Proposal_Search_Filter__c filterObj: Proposal_Search_Filter__c.getAll().values()) {
                ExcludedUsers.add(filterObj.User_Id__c);
            } 
        }
    }
    
    Set<String> proposalStagesForSearch;
    public Set<String> initializeProposalStages(){
        
        if(proposalStagesForSearch == null || proposalStagesForSearch.isEmpty()){
            proposalStagesForSearch = new Set<String>();
            proposalStagesForSearch.add('Created');
            proposalStagesForSearch.add('On Hold');
            proposalStagesForSearch.add('Pending');
            proposalStagesForSearch.add('Pending Task Completed');
            proposalStagesForSearch.add('Ready for Submission');
            proposalStagesForSearch.add('Replaced');
            proposalStagesForSearch.add('SR Approved');
            proposalStagesForSearch.add('SR Credit Approved');
            proposalStagesForSearch.add('SR Credit Review');
            
            proposalStagesForSearch.add('SR Declined');
            proposalStagesForSearch.add('SR Ops Received');
            proposalStagesForSearch.add('SR Ops Reviewed');
            proposalStagesForSearch.add('SR Signoff Review');
            proposalStagesForSearch.add('Submitted');
            proposalStagesForSearch.add('Voided');
            proposalStagesForSearch.add('Withdrawn');
        }
        return proposalStagesForSearch;
    }

}