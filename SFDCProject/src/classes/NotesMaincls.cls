/********************************************************************************
*	Author  	: Chandrika Dasaradharaman (chandrikad@sunrunhome.com)			*
*	Date    	: March 2012													*
*	Name		: NotesMaincls.cls												*
*	Description	: This class is used to list the available         				* 
*				  notes for a proposal and also allows to add or edit the notes	*
*																				*
*********************************************************************************/
public class NotesMaincls {
	
	public static Integer PAGE_SIZE1 = 5;
	public Integer pageSize {get; set;}
	List<Notes__c> selectNote;
	public Proposal__c proposalObj;
	public string whichOrgValue;
	//public Boolean temp {get;set;}
	public Boolean ispartnerUser;
	public string editNoteError{get { return editNoteError = CustomErrorMessages.EDIT_NOTE;} set;} 
	
	
	public NotesMaincls(ApexPages.StandardController stdController) { 
        ispartnerUser = false;
        whichOrgValue = '';
        proposalObj = (Proposal__c)stdController.getRecord();
        System.debug('proposalObj'+proposalObj);
        getIsPartnerUser();
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
        System.debug('proposalObj.Id'+proposalObj.Id);
        soqlQuery = 'Select n.Proposal__c, n.Notes__c, n.Id , n.createdDate, n.CreatedById,';
        soqlQuery += ' n.LastModifiedDate, n.LastModifiedById,n.Notes_Added_By__c From Notes__c n ';
        soqlQuery += ' Where n.Proposal__c =\''+proposalObj.Id+'\'' ;
        soqlQuery += ' ORDER BY n.LastModifiedDate DESC limit 10000';
		System.debug('soqlQuery: ' + soqlQuery);
		
        tempConnection = new ApexPages.StandardSetController(Database.getQueryLocator(soqlQuery));
        return tempConnection;          
    }      

    public String getBaseURL() {
        String baseURL = EDPUtil.getBaseURL();
        return baseURL;
    } 
	
	//Gets the Current Proposal Record id
	public string getPId()
	{
		return proposalObj.Id;
	}
	
	//Gets all the availbale notes for the Current Proposal Record
	public List<Notes__c> getAllNotes()
	{
    	System.debug('proposalObj.Id'+proposalObj.Id);
    	List<Notes__c> allNotes = new List<Notes__c>();
    	if(con != null) {
    		allNotes = con.getRecords();
    	}
    	return allnotes;
	}    
	
	/*public void selectNote()
	{
    	String selNoteid = System.currentPagereference().getParameters().get('noteid');

    	Notes__c note = [Select n.Proposal__c, n.Notes__c, n.Id From Notes__c n where Id=:selNoteid];
    	selectNote =  new List<Notes__c>();
    	selectNote.add(note);
    	
	}
	
	//Gets the Note record which is selected by the radio button
	public List<Notes__c> getselectedNote()
	{
    	return selectNote;
	}
	
	public string getselectedNoteId()
	{
    	return null;
	}*/
	
	//Checks whether login user is a Partner user or not
	public boolean getIsPartnerUser(){
		
		String userType = UserInfo.getUserType();
		if(userType != null && userType != ''){
			if(userType.contains('Partner')){
				ispartnerUser = true;
				return ispartnerUser;
			}
		}
		return ispartnerUser;
	}
	
   	//The below methods are used for the pagination
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