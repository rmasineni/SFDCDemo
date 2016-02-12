public with sharing class CustomContactLookup {
	public Integer pageSize = 10;
	public Contact contactObj {get;set;}
	public Contact addCon {get;set;}
	public List<Contact> results;// search results
	public string searchString{get;set;} // search keyword
	public String proposalId{get;set;} // search keyword
	public String opportunityId {get;set;}
	public String accountId {get;set;}
	public Id contactRecordTypeId{get;set;}
	
	public Set<Id> contactIds {get;set;}
	private String OCR_ROLE_CREDIT = 'Credit Contact';
	private Account acct;
    public Integer totalCount {get;set;}
    public Integer totalPageCount{get;set;}
 	public CustomContactLookup() {
 		System.debug('Inside constructor ... ');
 		intializeResidentialRecordTypeId();
		contactIds = new Set<Id>();
		contactObj = new Contact();
    	// get the current search string
    	searchString = System.currentPageReference().getParameters().get('lksrch');
    	proposalId = System.currentPageReference().getParameters().get('proposalId');
    	results = new List<Contact>();
    	initialize();
	}

    private void initialize(){
    	System.debug('Inside initialize ... ');
    	con = null;
        totalCount = 0;
        pageNumber = 0;
        totalPageCount = 0;
        intializeOptyAndAccountIds(proposalId);
    }
 
	// performs the keyword search
	public PageReference search() {
		System.debug('Invoke search ... ');
		initialize();
		return null;
	}

	// used by the visualforce page to send the link to the right dom element
	public string getFormTag() {
    	return System.currentPageReference().getParameters().get('frm');
	}
 
	// used by the visualforce page to send the link to the right dom element for the text box
	public string getTextBox() {
    	return System.currentPageReference().getParameters().get('txt');
	}

    public ApexPages.StandardSetController con {
        
        get {
            System.debug('con: ' + con);
            System.debug('searchString:  '  +searchString); 
            if(con != null)
            {
                return con;
            }
            con = createSQOLConnection();
            con.setPageSize(pageSize);
            return con;
        }
        set;
    } 

    private ApexPages.StandardSetController createSQOLConnection(){
        ApexPages.StandardSetController tempConnection;
        String soqlQuery = getSelectionQuery();
		System.debug('contactRecordTypeId: ' + contactRecordTypeId);
        tempConnection = new ApexPages.StandardSetController(Database.getQueryLocator(soqlQuery));
        return tempConnection;          
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

    public List<Contact> getResults(){
		results = con.getRecords();
        return results;
    }

	Private void intializeOptyAndAccountIds(String proposalId){
		if(proposalId != null && proposalId != ''){
			Proposal__c proposalObj = [Select Id, Opportunity__c from Proposal__c where Id =:proposalId];
			opportunityId = proposalObj.Opportunity__c;
			Opportunity optyObj = [Select Id, accountId from Opportunity where Id =:opportunityId];
			if(optyObj.AccountId != null){
				accountId = optyObj.AccountId;
			}
			System.debug('accountId: ' + accountId);
		}
	}

    private string getSelectionQuery(){   
    	System.debug('searchString:  '  +searchString);  
		String soql = 'select Id, Name, email, MailingCity, MailingStreet, MailingState, MailingCountry, ';
		soql = soql + ' MailingPostalCode, accountId from Contact where RecordTypeId =:contactRecordTypeId ';
	    if(searchString != '' && searchString != null)
	    	soql = soql +  ' AND Name != null AND Name LIKE \'%' + searchString +'%\'';

	    if(accountId != null && accountId != ''){
			soql = soql +  ' AND accountId =: accountId ';
	    }
	    soql = soql + ' Order by Name ASC ';
	    soql = soql + ' limit 10000 ' ;
	    System.debug('soql: ' + soql);
        return soql;
    }

	public void intializeResidentialRecordTypeId(){
		if(contactRecordTypeId == null){
			List<RecordType> recordTypeObjs = [select Id, Name, SobjectType from RecordType where SObjectType = 'Contact' and name = 'Residential' limit 1 ];
			if(recordTypeObjs != null && recordTypeObjs.size() > 0){
				contactRecordTypeId = recordTypeObjs[0].Id;
			}			
		}
	}

}