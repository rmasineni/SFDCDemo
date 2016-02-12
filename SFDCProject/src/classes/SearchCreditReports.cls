public class SearchCreditReports {
	static final public String customerCreditPrefix = Schema.SObjectType.Customer_Credit__c.getKeyPrefix();
	
	private List<Customer_Credit__c> allPRMUsers = null;
	private List<Customer_Credit__c> prmUsers = null;
	private List<CreditReportWrapper> creditReportList = null;

	private String firstNameLike = '%%';
	private String firstNameEq = null;
	private String lastNameLike = '%%';
	private String lastNameEq = null; 
	private String emailLike = '%%';
	private String emailEq = null; 

	private String streetLike = '%%';
	private String streetEq = null;
	private String cityLike = '%%';
	private String cityEq = null; 
	private String stateLike = '%%';
	private String stateEq = null;
	private String countryLike = '%%';
	private String countryEq = null;

	private String contactId = '';
	public String newCreditReporturl{get;set;}
	public String address1{get;set;}
	public String address2{get;set;}
	public String city{get;set;}
	public String state{get;set;}
	public String country{get;set;}

	public Customer_Credit__c creditReportObj = new Customer_Credit__c();
	public Proposal__c proposalObj {get;set;}
	
	public Customer_Credit__c getCreditReportObj(){
		return creditReportObj;
	}
	
	public Proposal__c getProposalObj(){
		return proposalObj;
	}	
    
    public String searchColumnName{get;set;}
    public String searchValue{get;set;}

    public PageReference CancelSearch(){
    	PageReference pr = new PageReference('/' + proposalObj.Id); 
    	pr.setRedirect(true);
    	return pr;
    }       
    
    public PageReference NewCreditReport(){
    	String customerCreditEdit = '/' + customerCreditPrefix + '/e';
     	PageReference pr = new PageReference(customerCreditEdit); 
    	pr.setRedirect(true);
    	return pr;
    }    

	public SearchCreditReports(){
		initializeProposal();
	}  
    
    public SearchCreditReports(ApexPages.StandardController stdController){
 		this.proposalObj = (Proposal__c)stdController.getRecord();
		initializeProposal();
    }

	public void initializeProposal(){
		string returnUrl = EncodingUtil.urlEncode('/apex/SearchCreditReports', 'UTF-8');
		String customerCreditEdit = '/' + customerCreditPrefix + '/e?retURL=';
		newCreditReporturl = customerCreditEdit + returnUrl;
		if(this.proposalObj != null && this.proposalObj.Id != null){
			Proposal__c tempProposalObj = [Select Id, name, Opportunity__c from Proposal__c where Id =:this.proposalObj.Id];
			if(tempProposalObj != null && tempProposalObj.Opportunity__c != null){
				Opportunity oppObj = [Select Id, name, account.name, account.Id,  account.BillingStreet, account.BillingCity, 
								account.BillingState, account.BillingCountry from Opportunity where Id =:tempProposalObj.Opportunity__c];
				
				if(oppObj.account.BillingStreet != null && oppObj.account.BillingStreet != ''){
					creditReportObj.street__c = oppObj.account.BillingStreet.substring(0,oppObj.account.BillingStreet.indexOf(' ',0)+3);
				}
				//creditReportObj.city__c = oppObj.account.BillingCity;
				creditReportObj.state__c = oppObj.account.BillingState;
				//creditReportObj.country__c = oppObj.account.BillingCountry;
				
			}
		}
		
	}

    
    //private static Boolean fieldHasValue(String field) {
    //    return field != null && field.trim() != '';
    //}

    private String getSelectionQuery(){
        firstNameLike = '%%';
        firstNameEq = null;
        lastNameLike = '%%';
        lastNameEq = null; 
        emailLike = '%%';
        emailEq = null; 
  
		String searchCondition = '';
        if(creditReportObj.First_Name__c != null && creditReportObj.First_Name__c != ''){
            firstNameLike = '%' + creditReportObj.First_Name__c + '%';
            firstNameEq = creditReportObj.First_Name__c;
			searchCondition += '  (first_name__c like :firstNameLike OR first_name__c = :firstNameEq) ';
        }


        if(creditReportObj.last_Name__c != null && creditReportObj.last_Name__c != ''){
            lastNameLike = '%' + creditReportObj.last_Name__c + '%';
            lastNameEq = creditReportObj.last_Name__c;

			if(searchCondition != ''){
         		searchCondition += ' AND ';
        	} 
			searchCondition += '  (last_name__c like :lastNameLike OR last_name__c = :lastNameEq) ';
        }       
        
        if(creditReportObj.Customer_Email__c != null && creditReportObj.Customer_Email__c != ''){
            emailLike = '%' + creditReportObj.Customer_Email__c + '%';
            emailEq = creditReportObj.Customer_Email__c;
			
			if(searchCondition != ''){
         		searchCondition += ' AND ';
        	} 
			searchCondition += '  (Customer_Email__c like :emailLike OR Customer_Email__c =:emailEq) ';
        }

        if(creditReportObj.Street__c != null && creditReportObj.Street__c != ''){
            streetLike = '%' + creditReportObj.Street__c + '%';
            streeteq = creditReportObj.Street__c;
			
			if(searchCondition != ''){
         		searchCondition += ' AND ';
        	} 
			searchCondition += '  (Street__c like :streetLike OR Street__c =:streeteq) ';
        }

        if(creditReportObj.city__c != null && creditReportObj.city__c != ''){
            cityLike = '%' + creditReportObj.city__c + '%';
            cityEq = creditReportObj.city__c;
			
			if(searchCondition != ''){
         		searchCondition += ' AND ';
        	} 
			searchCondition += '  (city__c like :cityLike OR city__c =:cityEq) ';
        }
        
        System.debug('creditReportObj.city__c: ' + creditReportObj.city__c);
        System.debug('creditReportObj.state__c: ' + creditReportObj.state__c);
        if(creditReportObj.state__c != null && creditReportObj.state__c != ''){
            stateLike = '%' + creditReportObj.state__c + '%';
            stateEq = creditReportObj.state__c;
			
			if(searchCondition != ''){
         		searchCondition += ' AND ';
        	} 
			searchCondition += '  (state__c like :stateLike OR state__c =:stateEq) ';
        }

        if(creditReportObj.country__c != null && creditReportObj.country__c != ''){
           // countryLike = '%' + creditReportObj.country__c + '%';
            //countryEq = creditReportObj.country__c;
			
			if(searchCondition != ''){
         		searchCondition += ' AND ';
        	} 
			searchCondition += '  (country__c like :countryLike OR country__c =:countryEq) ';
        }
        
        if(creditReportObj.contact__c != null ){
        	contactId = creditReportObj.contact__c;
			if(searchCondition != ''){
         		searchCondition += ' AND ';
        	}  
 
 			searchCondition += '  (contact__c =:contactId) ';
        } 
 
        String sunrunCreditStr = ProposalUtil.SUNRUN_CUSTOMER_CREDIT;
        String soqlQuery = 'select Id,first_name__c,last_name__c,Customer_Email__c, type__c '; 
		soqlQuery += ' ,Street__c, City__c, State__c, Country__c, 	Zip__c, Date_Pulled__c, Date_Submitted__c ';
        soqlQuery += ' from Customer_Credit__c  ';
       
       	if(searchCondition != null && searchCondition != ''){
			soqlQuery += ' where ';
			soqlQuery += searchCondition;
       	}
        soqlQuery += ' ORDER BY first_name__c, last_name__c, Date_Pulled__c desc, Date_Submitted__c desc ' ;
		soqlQuery += ' limit 1000 ';
        System.Debug('SOQL QUERY: ' + soqlQuery);
        return soqlQuery;
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
    
    private ApexPages.StandardSetController createSQOLConnection(){
        ApexPages.StandardSetController tempConnection;
        String soqlQuery = getSelectionQuery();
        tempConnection = new ApexPages.StandardSetController(Database.getQueryLocator(soqlQuery));
        return tempConnection;          
    }
    
 

    public Void applySearchFilter(){
        con = null;
    }


    public List<CreditReportWrapper> getCreditReportList(){
        List<CreditReportWrapper> creditReportList = new List<CreditReportWrapper>();
        for(Customer_Credit__c creditReportObj: (List<Customer_Credit__c>)con.getRecords()){
			creditReportList.add(new CreditReportWrapper(creditReportObj));
        }
        return creditReportList;
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
    
    public class CreditReportWrapper{
    	
    	public String address{
    		get;set;
    	}
    	public Customer_Credit__c customerCreditObj{
    		get;set;
    	}
    	public CreditReportWrapper(Customer_Credit__c customerCreditObj){
    		address = '';
    		this.customerCreditObj = customerCreditObj;
    		if(this.customerCreditObj.Street__c != null){
    			address = this.customerCreditObj.Street__c;
    		}
    		
			if(this.customerCreditObj.City__c != null){
				if(address != '' && this.customerCreditObj.City__c != ''){
					address += ', ';
				}
    			address += this.customerCreditObj.City__c;
    		}

			if(this.customerCreditObj.State__c != null){
				if(address != '' && this.customerCreditObj.State__c != ''){
					address += ', ';
				}
    			address += this.customerCreditObj.State__c;
    		}
    		
 			if(this.customerCreditObj.Country__c != null){
				if(address != '' && this.customerCreditObj.Country__c != ''){
					address += ', ';
				}
    			address += this.customerCreditObj.Country__c;
    		}   		

 			if(this.customerCreditObj.Zip__c != null){
				if(address != '' && this.customerCreditObj.Zip__c != ''){
					address += ', ';
				}
    			address += this.customerCreditObj.Zip__c;
    		} 


    	}
    }

}