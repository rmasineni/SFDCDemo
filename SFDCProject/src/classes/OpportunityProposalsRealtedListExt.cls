public class OpportunityProposalsRealtedListExt  

{  
    public opportunity opportunityObj{set;get;}
    public List<proposal__c> ProposalList  
    {  
        get  
        {  
            if(con != null)  
                return (List<Proposal__c>)con.getRecords();  
            else  
                return null ;  
        }  
        set;}  
      
    public Proposal__c pro {get; set;}  
      
    public OpportunityProposalsRealtedListExt()  
    {  
        ProposalList = new List<Proposal__c>() ;  
        pro = new Proposal__c() ;  
    }  
      
     public void Search()  
    {     
        if(opportunityObj.id != null)  
        {  
            con = new ApexPages.StandardSetController(Database.getQueryLocator([select Id ,name, Proposal_Name__c ,Original_Proposal_ID__c, Agreement_Type__c , Stage__c, Signed__c,Equipment_Summary__c,createddate from proposal__c where opportunity__c = :opportunityObj.id and Status__c='Valid' order by createddate desc]));  
            con.setPageSize(5);  
        }  
        else  
        {  
            con = null;  
        }  
    }     
    public OpportunityProposalsRealtedListExt(ApexPages.StandardController stdController){    	    
            opportunityObj = (Opportunity)stdController.getRecord();            
            search();
    }
      
    public ApexPages.StandardSetController con{get; set;}  
      
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
    public Integer pageSize  
    {  
        get  
        {  
            return con.getPageSize();  
        }  
        set;  
    }  
    public void previous()  
    {  
        con.previous();  
    }     
    public void next()  
    {  
        con.next();  
    }    
}