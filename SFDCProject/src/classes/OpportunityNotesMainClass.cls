/********************************************************************************
*   Author      : Chandrika Dasaradharaman (chandrikad@sunrunhome.com)          *
*   Date        : April 2013                                                    *
*   Name        : OpportunityNotesMainClass.cls                                 *
*   Description : This class is used to list the available                      * 
*                 notes for a Opportunity record and also allows                *
*                 to add or edit the notes                                      *
*********************************************************************************/
public with sharing class OpportunityNotesMainClass {
    
    public static Integer PAGE_SIZE1 = 5;
    public Integer pageSize {get; set;}
    List<Notes__c> selectNote;
    public Opportunity OpportunityObj;
    public string whichOrgValue;
    public Boolean ispartnerUser;
    public Boolean isAEEUser; 
    public string editNoteError{get { return editNoteError = CustomErrorMessages.EDIT_NOTE;} set;} 
    
    
    public OpportunityNotesMainClass(ApexPages.StandardController stdController) { 
        ispartnerUser = false;
        isAEEUser = false;
        whichOrgValue = '';
        OpportunityObj = (Opportunity)stdController.getRecord();
        System.debug('OpportunityObj'+OpportunityObj);
        getIsPartnerUser();
        getIsAEEUser();
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
        System.debug('OpportunityObj.Id'+OpportunityObj.Id);
        soqlQuery = 'Select n.Opportunity__c, n.Notes__c, n.Id , n.createdDate, n.CreatedById,';
        soqlQuery += ' n.LastModifiedDate, n.LastModifiedById,n.Notes_Added_By__c From Notes__c n ';
        soqlQuery += ' Where n.Opportunity__c =\''+OpportunityObj.Id+'\'' ;
        soqlQuery += ' ORDER BY n.LastModifiedDate DESC limit 10000';
        System.debug('soqlQuery: ' + soqlQuery);
        
        tempConnection = new ApexPages.StandardSetController(Database.getQueryLocator(soqlQuery));
        return tempConnection;          
    }      
    
    //Gets the Current Opportunity Record id
    public string getOppId()
    {
        return OpportunityObj.Id;
    }
    
    //Gets all the availbale notes for the Current Opportunity Record
    public List<Notes__c> getAllNotes()
    {
        System.debug('OpportunityObj.Id'+OpportunityObj.Id);
        List<Notes__c> allNotes = new List<Notes__c>();
        if(con != null) {
            allNotes = con.getRecords();
        }
        return allnotes;
    }    
    
    public void selectNote()
    {
        String selNoteid = System.currentPagereference().getParameters().get('noteid');

        Notes__c note = [Select n.Opportunity__c, n.Notes__c, n.Id From Notes__c n where Id=:selNoteid];
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
    }
    
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
    
    public boolean getIsAEEUser(){
      string AEEDivision = label.AEE_label;
      User u = [select id, User_Division_Custom__c from User where id =: UserInfo.getUserId()];
      if(u.User_Division_Custom__c.contains(AEEDivision)){
        isAEEUser = true;
      }
     return isAEEUser; 
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