public with sharing class PartnerDesignOption {
	
	public static Integer PAGE_SIZE1 = 5;
	public Integer pageSize {get; set;}
	public List<Design_Option__c> desOptionObj;
	public Lead leadObj;
	
	public PartnerDesignOption(ApexPages.StandardController stdController) { 
        
        leadObj = (Lead)stdController.getRecord();
        System.debug('leadObj'+leadObj);
	}
	
	public ApexPages.StandardSetController con {
        get
        {
            if(con != null){
                    return con;
                }
            con = createSQOLConnection();
            pageSize = (pageSize == null || pageSize <= 0) ? PAGE_SIZE1 : pageSize;
            if(pageSize != null){
                con.setPageSize(pageSize);
            }  
            return con;
        }
        set;
    } 
    
    //Creates the SOQL connection to get the records
    private ApexPages.StandardSetController createSQOLConnection(){
        ApexPages.StandardSetController tempConnection;
              
        String soqlQuery;
        System.debug('leadObj.Id'+leadObj.Id);

        soqlQuery = 'Select costPerYearkWh__c,Serial_Number__c, Module__c, Lead__c , KWP__c, KWH_KWP__c,';
        soqlQuery += ' KWH__c, Usage__c From Design_Option__c ';
        soqlQuery += ' Where Lead__c =\''+leadObj.Id+'\'' ;
        soqlQuery += ' ORDER BY LastModifiedDate DESC limit 10000';
        
        System.debug('soqlQuery: ' + soqlQuery);
        
        tempConnection = new ApexPages.StandardSetController(Database.getQueryLocator(soqlQuery));
        return tempConnection;          
    }
    
    public List<Design_Option__c> getleadDesignOption(){

        List<Design_Option__c> allDesOpt = new List<Design_Option__c>();
        if(con != null) {
            allDesOpt = con.getRecords();
        }
        return allDesOpt;
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
  
}