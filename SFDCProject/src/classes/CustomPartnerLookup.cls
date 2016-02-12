public with sharing class CustomPartnerLookup {
	
	public Contact loginContact;
	public Contact salesRepContact;
	Set<Id> contactIdSet {get;set;}
	Set<Id> userIdSet {get;set;}
	public Id locationId {get;set;}
	public Id salesRepLocationId {get;set;}
	public Integer pageSize = 10;
	public Contact contactObj {get;set;}
	public Contact addCon {get;set;}
	public List<User> results;// search results
	public List<Contact> contactResults{get;set;} // search results
	public string searchString{get;set;} // search keyword
	public String proposalId{get;set;} // search keyword
	public String opportunityId {get;set;}
	public String accountId {get;set;}
	public Set<Id> contactRecordTypeIds{get;set;}
	Set<Id> salesRepLocations{get;set;}
	Set<Id> partnerIds{get;set;}
	public boolean sunrunDirect {get;set;}
	
	public Set<Id> contactIds {get;set;}
	private String OCR_ROLE_CREDIT = 'Credit Contact';
	private Account acct;
    public Integer totalCount {get;set;}
    public Integer totalPageCount{get;set;}
    public boolean showContactId {get;set;}
    
 	public CustomPartnerLookup() {
 		System.debug('Start ... CustomPartnerLookup');
 		showContactId = false;
 		intializePartnerRecordTypeIds();
		contactIds = new Set<Id>();
		contactObj = new Contact();
    	// get the current search string
    	searchString = System.currentPageReference().getParameters().get('lksrch');
    	proposalId = System.currentPageReference().getParameters().get('proposalId');
    	String idValueStr = System.currentPageReference().getParameters().get('idValue');
    	if(idValueStr == 'Contact'){
    		showContactId = true;
    	}
    	results = new List<User>();
    	
    	initialize();
	}
	
    private void initialize(){
    	con = null;
    	contactResults = new List<Contact>();
        totalCount = 0;
        pageNumber = 0;
        totalPageCount = 0;
		initializeLoginUserInfo();
		initializeSalesRep();
	}
 
	// performs the keyword search
	public PageReference search() {
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
        initializeContactIds();
        String soqlQuery = getSelectionQuery();
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

    public List<User> getResults(){
		results = con.getRecords();
		System.debug('results: ' + results);
        return results;
    }

	private void initializeSalesRep(){
		Set<Id> tempHeadquarters = new Set<Id>();
		salesRepLocations = new Set<Id>();
		partnerIds = new Set<Id>();
		Proposal__c proposalObj = [Select Id, Opportunity__c, sales_partner__c, Install_Partner__c, 
									Sales_Rep_Email__c from Proposal__c where Id =:proposalId];
		List<Contact> contacts = new List<Contact>();
		if(proposalObj.sales_partner__c != null){
			partnerIds.add(proposalObj.sales_partner__c);
		}
		if(proposalObj.Install_Partner__c != null){
			partnerIds.add(proposalObj.Install_Partner__c);
		}
		System.debug('proposalObj.Sales_Rep_Email__c: ' + proposalObj.Sales_Rep_Email__c);
		System.debug('contactRecordTypeIds: ' + contactRecordTypeIds);
		
		if(loginContact != null && loginContact.AccountId == proposalObj.Sales_Partner__c){
			contacts = [Select Id, Name, accountId, email, Location__c, Location__r.Id, 
										Location__r.Headquarters__c from Contact where 
										Id = :loginContact.Id
										//email =:proposalObj.Sales_Rep_Email__c 
										and RecordTypeId  in :contactRecordTypeIds ];
		}else if(loginContact != null && loginContact.AccountId == proposalObj.Install_Partner__c){
			contacts = [Select Id, Name, accountId, email, Location__c, Location__r.Id, 
										Location__r.Headquarters__c from Contact where accountId = :loginContact.AccountId 
										and Location__r.Headquarters__c = true
										and RecordTypeId in :contactRecordTypeIds ];			
		}
		
		if(loginContact != null && loginContact.Sunrun_User__c != null){
			sunrunDirect = true;
		}
		
		if(contacts.size() > 0){
			salesRepContact = contacts[0];
			tempHeadquarters.add(salesRepContact.accountId);
			if(salesRepContact.Location__r.Headquarters__c == true){
				salesRepLocations.add(salesRepContact.Location__r.Id);
			}else{
				salesRepLocations.add(salesRepContact.Location__r.Id);
				Map<Id, Partner_Location__c> headquartersLocation = EDPUtil.getHeadquartersLocation(tempHeadquarters);
				salesRepLocations.addall(headquartersLocation.keySet());
			}
			System.debug('salesRepLocations1: ' + salesRepLocations);
		}
	}

	private void initializeLoginUserInfo(){
		loginContact = PRMContactUtil.getLoginUserAccountAndContact();
		if(PRMContactUtil.isPartnerContact(loginContact)){
			locationId = loginContact.Location__c;
			accountId = loginContact.AccountId;			
		}	
	}

	/*
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
	*/

    private string getSelectionQuery(){ 
		String soql = 'select Id, Name, email, contactId, phone ';
		soql = soql + ' from User where ' ;
		soql = soql + ' ( Id in :userIdSet OR ';	
		soql = soql + ' contactId in :contactIdSet ) and isActive = true ';	    
    	return soql;
    }

   public void initializeContactIds(){     
   	    System.debug('initializeContactIds start ..' );
		String soql = 'select Id, Name, Sunrun_User__c , email, Location__c, Location__r.Id, Location__r.Headquarters__c  ';
		soql = soql + ' from Contact where RecordTypeId in :contactRecordTypeIds ';	    
	    System.debug('salesRepLocations2: ' + salesRepLocations);
	    if(salesRepLocations != null && salesRepLocations.size() > 0){
	    	soql = soql + ' and Location__c in :salesRepLocations ';
	    }
	    if(searchString != '' && searchString != null){
			soql = soql +  ' AND ((Name != null AND Name LIKE \'%' + searchString +'%\' ) OR ( EMAIL LIKE  \'%' + searchString +'%\' ))' ;
	    }
	    if(accountId != null && accountId != ''){
			soql = soql +  ' AND accountId =:accountId ';
	    }else{
	    	soql = soql +  ' AND accountId in :partnerIds ' ;
	    }
	    soql = soql + ' Order by Name ASC limit 500 ';
	    System.debug('soql: ' + soql);
		contactIdSet = new Set<Id>();
		userIdSet = new Set<Id>();
		for(Contact ptrContactObj : Database.query(soql)){
			contactIdSet.add(ptrContactObj.Id);
			contactResults.add(ptrContactObj);
			if(ptrContactObj.Sunrun_User__c != null){
				userIdSet.add(ptrContactObj.Sunrun_User__c);
			}
		}
    }

	public void intializePartnerRecordTypeIds(){

 		if(contactRecordTypeIds == null || contactRecordTypeIds.isEmpty()){
			Set<String> nameValues = new Set<String>();
			nameValues.add(PRMLibrary.PARTNER);
			nameValues.add(PRMLibrary.EMPLOYEE);
			contactRecordTypeIds = new Set<Id>();
			List<RecordType> recordTypeObjs = [select Id, Name, SobjectType from RecordType where SObjectType = 'Contact' and name in :nameValues];
			for(RecordType recordTypeObj : recordTypeObjs){
				contactRecordTypeIds.add(recordTypeObj.Id);
			}
			
			//if(recordTypeObjs != null && recordTypeObjs.size() > 0){
			//	contactRecordTypeId = recordTypeObjs[0].Id;
			//}			
		}
	}


}