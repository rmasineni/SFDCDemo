public with sharing class InstallAuditExtension {

	public Boolean isGenAsset{get;set;}
    public List<selectOption> installerOptions { get; set; }
    public List<selectOption> auditorOptions { get; set; }
    public List<selectOption> statusOptions { get; set; }
    public List<selectOption> auditTypeOptions {get; set; }

    public String UserType {get; set;}
    private String AccountName {get; set;}
    private InstallAuditService installAuditService = new InstallAuditService();
    public List<selectOption> auditorAccountContacts {get; set;}
    public String parentObjectId {get;set;}
    
    private ApexPages.StandardController sc; 
    public Install_Audit__c ia {get;set;}
    
    //For Search Page
    public String strView{get;set;}
    public String srchType{get;set;}
    public String srchString{get;set;}
    public String srchStringAuditor{get;set;}
    public List<selectOption> auditFilterSelectOptions{get;set;}
    public List<selectOption> searchFields{get;set;}
    public List<Install_Audit__c> iaList{get;set;}
    
    public Decimal Score{get;set;}
    public Integer EPCDiscrepancies{get;set;}
    public Integer PriorityCriteriaMissed{get;set;}
    public String PassFail {get;set;}
    public String CorporatePassFail {get; set;}
    
    //Sorting
    public InstallAuditSortHelper sorter = new InstallAuditSortHelper ();
    public String sortedBy {get;set;} 
    public Boolean sortAscending  {get;set;}
    private List<Sun_Run_Audit_List_Settings__c> resultsPerPageList;
    private Decimal listResultsPerPage {get;set;}
    private List<Sun_Run_Audit_List_Settings__c> criteriaPerPageList;
    private Integer criteriaPerPage {get;set;}
    private static Integer DEFAULT_LIST_RESULTS_PER_PAGE = 50;
    private static Integer DEFAULT_CRITERIA_PER_PAGE = 50;      
    
    //Pagination
    private ApexPages.StandardSetController installAuditSet;
    public Map<Id, Install_Audit__c> installAuditMap {get;set;}
    public Map<String, List<selectOption>> searchMap {get;set;}//= new Map<String, List<selectOption>>();
    
    public String urlPrefix {get;set;}
    public Boolean getIsPartnerPortal(){
    	if(urlPrefix == '/partner'){
    		return true;
    	}
    	return false;
    }
        
    public InstallAuditExtension(){
        
        urlPrefix = '/partner';
        String baseURL = EDPUtil.getBaseURL();
        if(baseURL != null && !baseURL.contains(urlPrefix)){
            urlPrefix = '';
        }

        isGenAsset = false;
        UserType = installAuditService.getUserTypeFromUserProfile();
        resultsPerPageList = [select Id, Value__c from Sun_Run_Audit_List_Settings__c where Name = 'List View Rows' limit 1];
        if(resultsPerPageList.size() > 0)
            listResultsPerPage = resultsPerPageList[0].Value__c;
        else
            listResultsPerPage = DEFAULT_LIST_RESULTS_PER_PAGE;
        srchType = 'SRH';
        buildSearchOptionLists();
                          
        if(UserType != 'Sunrun')
        {
            strView = 'My Audits Last 30 Days';
            AccountName = installAuditService.getAccountNameFromUser();
        }
        else
            strView = 'All Audits Last 30 Days';
           
        PageReference pr = srchAudits();
    }

    private List<selectOption> getInstallerOptions()
    {    
        List<SelectOption> installers = new List<SelectOption>(); 
        installers.add(new SelectOption('', '-None-'));     
		Set<String> accountNames = new Set<String>();
		for(Account accountObj : [Select Id, name, IsPartner from Account where IsPartner = true and Ultimate_Parent_Account__c = null and Partner_Type__c in ('Full Service', 'Install') order by name]){
	       	accountNames.add(accountObj.name);
		} 
		for(String name : accountNames){
			installers.add(new SelectOption( name, name));
		}
        return installers ;
    }

    private List<selectOption> getStatusOptions()
    {    
        List<selectOption> options = new List<selectOption>();
        options.add(new SelectOption('','-None-'));
        Schema.DescribeFieldResult fieldResult = Install_Audit__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPickListValues();
        for(Schema.PicklistEntry p : ple)
        {
            options.add(new SelectOption(p.getLabel(), p.getValue()));
        }
        
        return options;
    }
    
    private List<selectOption> getAuditTypeOptions()
    {
        List<selectOption> options = new List<selectOption>();
        options.add(new SelectOption('','-None-'));
        Schema.DescribeFieldResult fieldResult = Install_Audit__c.Install_Audit_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPickListValues();
        for(Schema.PicklistEntry p : ple)
        {
            options.add(new SelectOption(p.getLabel(), p.getValue()));
        }
        
        return options;
    }
    
    private void buildSearchOptionLists()
    {    
        auditorOptions = getAuditors();
        installerOptions = getInstallerOptions();
        statusOptions = getStatusOptions();
        auditTypeOptions = getAuditTypeOptions();
    }
      
    public PageReference getTestGet()
    {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '1'));

           return null;
 
    }
    

    public PageReference srchAudits(){
        iaList = new List<Install_Audit__c>();
        String auditSOQL = 'Select Id, Name, Generation_Asset__r.Name '; 
		auditSOQL += ',Generation_Asset__r.Id,Generation_Asset__r.Account_Name__r.Name, Generation_Asset__r.Customer_Contact__r.Name ';
        auditSOQL += ',Generation_Asset__r.Home_Address__c, Generation_Asset__r.Installer__r.Name ';
		auditSOQL += ',Service_Contract__r.Id,Service_Contract__r.Account.Name, Service_Contract__r.Contact.Id, Service_Contract__r.Contact.Name';
		auditSOQL += ',Service_Contract__r.Install_Partner__c, Service_Contract__r.Customer_Name__c,Service_Contract__r.Name, Service_Contract__r.Home_Address__c ';
                
        auditSOQL += ',Status__c, Install_Audit_Type__c, Auditor_Account__c, Auditor_Account__r.Name from Install_Audit__c';
        if(strView == 'My Audits Last Week')
        {
            if(UserType == 'Auditor')
                auditSOQL += ' where CreatedDate >= LAST_WEEK and Auditor_Account__r.Name = \'' + AccountName + '\'';  
            else
                auditSOQL += ' where CreatedDate >= LAST_WEEK and Service_Contract__r.Install_Partner__c = \'' + AccountName + '\' and Status__c = \'SR Approved\'';   
        }
        else if (strView == 'My Audits Last 30 Days')
        {
            if(UserType == 'Auditor')
                auditSOQL += ' where CreatedDate >= LAST_N_DAYS:30 and Auditor_Account__r.Name = \'' + AccountName  + '\'';  
            else
                auditSOQL += ' where CreatedDate >= LAST_N_DAYS:30 and Service_Contract__r.Install_Partner__c = \'' + AccountName  + '\'  and Status__c = \'SR Approved\'';   
        }
        else if (strView == 'My Audits All Time')
        {
            if(UserType == 'Auditor')
                auditSOQL += ' where Auditor_Account__r.Name = \'' + AccountName  + '\''; 
            else
                auditSOQL += ' where Service_Contract__r.Install_Partner__c = \'' + AccountName  + '\' and Status__c = \'SR Approved\'';               
        }   
        else if (strView == 'All Audits Last 30 Days')
        {
            auditSOQL += ' where CreatedDate >= LAST_N_DAYS:30';   
        }  
        else if (strView == 'All Audits Last 60 Days')
        {
            auditSOQL += ' where CreatedDate >= LAST_N_DAYS:60';   
        }      
        else if (strView == 'All Audits Last 90 Days')
        {
            auditSOQL += ' where CreatedDate >= LAST_N_DAYS:90';   
        }     
        else if (strView == 'All Audits Last Week')
        {
            auditSOQL += ' where CreatedDate >= LAST_WEEK';   
        }  
        else if (strView == 'All Audits All Time')
        {
            auditSOQL += ' where CreatedDate < TOMORROW';   
        }          
        
        if((srchString != '' && srchString != null) || (srchStringAuditor!= '' && srchStringAuditor!= null  ))
        {
           if(srchType == 'SRH')
           {
               auditSOQL += ' and Service_Contract__r.Name Like \'%' + srchString + '%\'';
           }
           if(srchType == 'Name')
           {
               auditSOQL += ' and Service_Contract__r.Contact.Name Like \'%' + srchString + '%\'';   
           }            
           if(srchType == 'Address')
           {
               auditSOQL += ' and Service_Contract__r.Home_Address__c Like \'%' + srchString + '%\'';
           }
           if(srchType == 'Installer')
           {
               auditSOQL += ' and Service_Contract__r.Install_Partner__c Like \'%' + srchString + '%\'';
           }       
           if(srchType == 'Status')
           {
           	   System.debug('srchString: ' + srchString);
               auditSOQL += ' and Status__c Like \'%' + srchString + '%\'';
           }       
           if(srchType == 'Auditor')
           {
               auditSOQL += ' and Auditor_Account__c = \'' + srchStringAuditor+ '\'';
           }       
                  
           if(srchType == 'Audit Type')
           {
               auditSOQL += ' and Install_Audit_Type__c Like \'%' + srchString + '%\'';
           }       
        }
        System.Debug('SOQL = ' + auditSOQL); 
		auditSOQL += ' ORDER BY CreatedDate DESC limit 500 ';
        iaList = database.query(auditSOQL); 
        System.debug('iaList: ' + iaList);
        setSortedBy('Service_Contract__r.Name');        
        sortAscending = true;        
        iaList = sorter.getSortedList(iaList , 'Service_Contract__r.Name', sortAscending);
        iaList = PaginateList(iaList);    
            
        return null;
    }	
    public List<Install_Audit__c> PaginateList(List<Install_Audit__c> installAuditList)
    {
        installAuditSet = PaginationHelper.getStdSetController(installAuditList,Integer.valueOf(listResultsPerPage));        
        return installAuditSet.getRecords();
    }
    
    public PageReference nextInstallAuditPage() { 
        iaList = PaginationHelper.getNextSetOfRecords(installAuditSet);        
        return null;
    }
    
    public PageReference previousInstallAuditPage() { 
        iaList = PaginationHelper.getPreviousSetOfRecords(installAuditSet);                      
        return null;
    }
    public boolean next{
    	get{
    		return installAuditSet.getHasNext();
    	}
    	set;
    }
    public boolean prev{
    	get{
    		return installAuditSet.getHasPrevious();
    	}
    	set;
    }
    public Integer pageNumber {
        get {
            return integer.valueOf(math.ceil((decimal.valueOf(installAuditSet.getResultSize())/decimal.valueOf(installAuditSet.getPageSize()))));
        }
        set;
    }

  // get page number that is being displayed in results device table.
    public Integer iaPageNumber {
        get {
            if(installAuditSet != null)
                return installAuditSet.getPageNumber();
            else
                return 0;
        } 
        set;
    }
    
    // get the total pages that were returned for photos.
    public Integer iaTotalPageNumber {
        get {
            if(installAuditSet != null)
                return PaginationHelper.getTotalNumberOfPages(installAuditSet );
            else
                return 0;
        } 
        set;
    }    

    public PageReference SortBySRH()
    {
       setSortedBy('SRH');
       iaList = sorter.getSortedList(iaList , 'Service_Contract__r.Name', sortAscending);
       return null;
    }
    
    public PageReference SortByAccount()
    {
       setSortedBy('Account');
       iaList = sorter.getSortedList(iaList , 'Service_Contract__r.Contact.Name', sortAscending);
       return null;
    }
    
    public PageReference SortByStatus()
    {
       setSortedBy('Status');
       iaList = sorter.getSortedList(iaList, 'Status__c', sortAscending);
       return null;
    }
    
    public PageReference SortByAuditType()
    {
       setSortedBy('Audit Type');
       iaList = sorter.getSortedList(iaList, 'Install_Audit_Type__c', sortAscending);
       return null;
    }
    
    public PageReference SortByAuditor()
    {
       setSortedBy('Auditor');
       iaList = sorter.getSortedList(iaList, 'Auditor_Account__r.Name', sortAscending);
       return null;
    }
    
    public PageReference SortByInstaller()
    {
       setSortedBy('Installer');
       iaList = sorter.getSortedList(iaList, 'Service_Contract__r.Install_Partner__c ', sortAscending);
       return null;
    }
    
    public PageReference SortByAddress()
    {
       setSortedBy('Address');
       iaList = sorter.getSortedList(iaList, 'Service_Contract__r.Home_Address__c', sortAscending);
       return null;
    }
    
    private void setSortedBy(String value) {
         if (sortedBy == value) {
             sortAscending = !sortAscending;
         } else {
             sortAscending = true;
         }
         sortedBy = value;
    }
    
    public InstallAuditExtension( ApexPages.StandardController sc ){

		urlPrefix = '/partner';
		String baseURL = EDPUtil.getBaseURL();
		if(baseURL != null && !baseURL.contains(urlPrefix)){
		    urlPrefix = '';
		}

		isGenAsset = false;
		this.ia = (Install_Audit__c)sc.getRecord();
		if(this.ia.Id != null){
			Install_Audit__c tempInstallAudit = [Select Id, name, Generation_Asset__r.Name, Generation_Asset__r.Home_Address__c,
		  										Generation_Asset__r.Id, Generation_Asset__r.Proposal_Unique_ID__c, Service_Contract__r.Name, 
		  										Service_Contract__r.Install_Partner__c, Service_Contract__r.Customer_Name__c,
		  										Service_Contract__r.Id, Service_Contract__r.Home_Address__c, Service_Contract__r.Proposal__c 
		  										from Install_Audit__c where Id = :this.ia.Id];
		  		if(tempInstallAudit.Service_Contract__r.Id != null){
		  			parentObjectId = tempInstallAudit.Service_Contract__r.Id;
		  		}
		}

		UserType = installAuditService.getUserTypeFromUserProfile();
		auditorAccountContacts = installAuditService.getContactsForAuditorAccount(this.ia.Auditor_Account__c);
		if(UserType != 'Auditor' && (ia.Status__c != 'Assigned' && ia.Status__c != 'Accepted' && ia.Status__c != 'Denied' && ia.Status__c != 'Unassigned' && ia.Status__c != 'In Progress'))
			calculateScorecard();      
	}
    
    private void calculateScorecard()
    {
        Decimal pointsPossible = 0;
        Decimal pointsAccrued = 0;
        Integer epc = 0;
        Integer priority = 0;
        Integer substantialFails = 0;
        
        List<Audit_Feedback__c> auditFeedback = installAuditService.getInstallAuditFeedback(this.ia.Id);
        for(Audit_Feedback__c afc: auditFeedback )
        {
            pointsPossible  += afc.Audit_Criteria__r.Point_Value__c;
            if(afc.QA_Score__c == 'Pass')
                pointsAccrued += afc.Audit_Criteria__r.Point_Value__c;
            
            if(afc.Audit_Criteria__r.Priority_Criteria__c == 'Y' && afc.QA_Score__c != 'Pass')
                priority++;
                            
            if(afc.Audit_Criteria__r.Criteria_Type__c == 'EPC Compliance' && (afc.QA_Score__c == 'Fail' || afc.QA_Score__c == 'Substantial Fail'))
                epc++;     
            
            if(afc.QA_Score__c == 'Substantial Fail')
                substantialFails ++;     
        }     
        this.PriorityCriteriaMissed = priority;
        this.EPCDiscrepancies = epc;  
        if(pointsPossible > 0)
            this.Score = ((pointsAccrued/pointsPossible) * 100).SetScale(0);
        else
            this.Score = 0;
 
        if(this.Score > 85 && this.PriorityCriteriaMissed == 0)
            PassFail = 'Pass';
        else
            PassFail = 'Fail';    
            
        if(this.Score > 85 && substantialFails  == 0)
            CorporatePassFail = 'Pass';
        else
            CorporatePassFail = 'Fail';  
    }
    
    public PageReference findContacts()
    {
        if(this.ia.Auditor_Account__c != null)
        {
            this.auditorAccountContacts = installAuditService.getContactsForAuditorAccount(this.ia.Auditor_Account__c);
            this.ia.Status__c = 'Assigned';
        }
        else{
            this.ia.Status__c = 'Unassigned';
            this.auditorAccountContacts = null;
        }
        return null;
    }
    
    public List<selectOption> getAuditorAccountContacts()
    {
        auditorAccountContacts = installAuditService.getContactsForAuditorAccount(null);
        return auditorAccountContacts;   
    }    
    
    public PageReference showScorecard(){
        Boolean errors = false;
        if(UserType == 'Auditor' && this.ia.Status__c == 'Assigned')
        {
            errors = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please change Status to Accepted before proceeding.'));
        }
        
        if(UserType == 'Auditor' && this.ia.Auditor_Contact__c == null)
        {
            errors = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a Reviewer Name before proceeding.'));
        }        
        
         if(UserType == 'Auditor' && (this.ia.Install_Audit_Type__c == 'Onsite' && (this.ia.Site_Visit_Date__c == null)))
        {
            errors = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a Site Visit Date for an Onsite Audit before proceeding'));
        }   
               
        if(errors == false)
        {
            saveInstallAudit();
            PageReference pr =  new PageReference('/apex/AuditFeedback?Install_Audit__c=' + this.ia.Id + '&retURL=/apex/InstallAudit?id=' + this.ia.Id);
            return pr;
        }
        return null;
    }
        
    public PageReference uploadAuditPhotos(){
        PageReference pr =  new PageReference('/apex/Audit_PhotoUploader?id=' + this.ia.Id);
        return pr;            
    }
    
    public boolean getIsDenied()
    {
        if(ia.Status__c == 'Denied')
            return true;
        return false;
    }
        
    public boolean getIsAuditor(){
        if(UserType == 'Auditor')
            return true;
        return false;
    }
    
    public boolean getIsSunrun(){
        if(UserType == 'Sunrun')
            return true;
        return false;
    }      
    
    public boolean getIsPartner(){
        if(UserType == 'Partner')
            return true;
        return false;
    }      
      
    public List<selectOption> getAuditors(){
        List<selectOption> options = new List<selectOption>();
        options.add(new selectOption('','-None-'));
        for(Account a:[SELECT Id, Name, RecordType.Name, Partner_Type__c
                           FROM Account Where Partner_Type__c Includes ('Auditor')
                          Order By Name])
        {
            options.add(new selectOption(a.Id, a.Name));
        }
        return options;  
    }
   
    public Boolean getStatusReadOnly()
    {
        if(this.UserType == 'Partner')
            return true;
        
        if(this.UserType == 'Sunrun') //&& (this.ia.Status__c == 'Accepted'  || this.ia.Status__c == 'In Progress' || this.ia.Status__c == 'Denied' 
                                     //                 || this.ia.Status__c == 'SR Approved' || this.ia.Status__c == 'Rejected'))
            return true;

        if(this.UserType == 'Auditor' && (this.ia.Status__c == 'Submitted' || this.ia.Status__c == 'Denied' || this.ia.Status__c == 'SR Approved' || this.ia.Status__c == 'Unassigned'))           
            return true;
            
        return false;
            
    }
    
    public List<selectOption> getStatuses()
    {
        List<selectOption> options = new List<selectOption>();
        
        if(UserType == 'Admin')
        {
            options.add(new selectOption('Unassigned','Unassigned'));
            options.add(new selectOption('Assigned','Assigned'));
            options.add(new selectOption('Accepted','Accepted'));
            options.add(new selectOption('Denied', 'Denied'));
            options.add(new selectOption('In Progress', 'In Progress'));
            options.add(new selectOption('Submitted', 'Submitted'));
            options.add(new selectOption('SR Approved', 'SR Approved'));
            options.add(new selectOption('Rejected', 'Rejected')); 
            return options;         
        }
        else
        {          
            if(this.ia.Status__c == 'Unassigned')
            {
                options.add(new selectOption('Unassigned','Unassigned'));
                options.add(new selectOption('Assigned','Assigned'));                 
            }
            else if(this.ia.Status__c == 'Assigned')
            {
                if(this.UserType == 'Auditor')
                {
                    options.add(new selectOption('Assigned','Assigned'));
                    options.add(new selectOption('Accepted','Accepted'));
                    options.add(new selectOption('Denied', 'Denied'));
                }
                else
                {
                    options.add(new selectOption('Unassigned','Unassigned'));
                    options.add(new selectOption('Assigned','Assigned'));           
                }
            }    
            else if(this.ia.Status__c == 'Denied')
            {
                options.add(new selectOption('Denied', 'Denied'));
            }            
            else if(this.ia.Status__c == 'Accepted')
            {
                options.add(new selectOption('Accepted', 'Accepted'));
                options.add(new selectOption('In Progress', 'In Progress'));
                options.add(new selectOption('Submitted', 'Submitted'));
            }
            else if(this.ia.Status__c == 'In Progress')
            {
                options.add(new selectOption('In Progress', 'In Progress'));
                options.add(new selectOption('Submitted', 'Submitted'));
            }
            else if(this.ia.Status__c == 'Submitted')
            {
                if(this.UserType == 'Sunrun')
                {
                    options.add(new selectOption('Submitted', 'Submitted'));        
                    options.add(new selectOption('SR Approved', 'SR Approved'));
                    options.add(new selectOption('Rejected', 'Rejected'));
                }
            }
            else if(this.ia.Status__c == 'Rejected')
            {
                    options.add(new selectOption('Rejected', 'Rejected'));        
                    options.add(new selectOption('In Progress', 'In Progress'));
            }
            else if(this.ia.Status__c == 'SR Approved')
            {
                options.add(new selectOption('SR Approved', 'SR Approved'));        
            }        
            
            return options;
        }
    }

    public PageReference saveInstallAudit()
    {
        PageReference pr;
        update this.ia;
        if(UserType == 'Sunrun'  || UserType == 'Admin')
            pr =  new PageReference('/apex/InstallAuditListView');
        else
            pr = null;
        return pr; 
    }
       
    public PageReference ReturnToListView(){
        PageReference pr =  new PageReference('/apex/InstallAuditListView');
        return pr;    
    }
}