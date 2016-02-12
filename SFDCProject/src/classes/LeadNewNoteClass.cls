/********************************************************************************
*	Author  	: Chandrika Dasaradharaman (chandrikad@sunrunhome.com)			*
*	Date    	: March 2012													*
*	Name		: LeadNewNoteClass.cls											*
*	Description	: This class is used to add new notes for a 					* 
*				  Lead Record													*
*																				*
*********************************************************************************/
public class LeadNewNoteClass {
     String bodyVal = null;
     public boolean isSaved {get;set;}
     public Lead noteRecord {get;set;} 
     public string noteValue {get;set;} 
     public ID leadid {get;set;}
     public String parentURL{get;set;}
     public String baseURL{get;set;}
     public Boolean ispartnerUser;
     public String whichOrgValue;
     public String errorMessage{get;set;}
     public boolean showEditSec {get; set;}
     
     public LeadNewNoteClass(ApexPages.StandardController stdController) { 
        errorMessage = '';
        Lead noteRecordObj;
        ispartnerUser = false;
		isSaved = false;
        noteRecordObj = (Lead)stdController.getRecord();

        leadid = noteRecordObj.id;
        System.debug('noteRecord'+leadid);
        
        //Building Parent URL
        baseURL = EDPUtil.getBaseURL();
		parentURL = baseURL + '/apex/customizeLeadDetailPage?id=' + leadid;
		
		system.debug('Parent URL *******' + parentURL);
        showEditSec = true;
       
    }
    
    //Getting the Organisation Name of the Login user
    public string getwhichOrg(){
    	
    	String userType = UserInfo.getUserType();
 		if(userType != null && userType != ''){
			if(userType.contains('Partner')){
				ispartnerUser = true;
			}
		}
		
		if(ispartnerUser == true){
			User userRec = [Select ContactId From User WHERE Id = :Userinfo.getUserid()];
			Contact conRec = [Select Id, Account.Name From Contact Where Id = :userRec.ContactId];
        	
        	system.debug('Organization Name' + conRec.Account.Name);
			whichOrgValue = conRec.Account.Name;
			return whichOrgValue;
		}
    	
    	whichOrgValue = 'SunRun';
    	return whichOrgValue;
    	
    }
    
    //To save the Updated Record
    public PageReference saveForm(){
    	system.debug('Saving New Record');
		 
        if(noteValue != null && noteValue != '' ) {
           Notes__c newNoteObj = new Notes__c();
           newNoteObj.Lead__c = leadid;
           newNoteObj.Notes__c = noteValue;

           newNoteObj.Notes_Added_By__c = getwhichOrg();
        
           insert newNoteObj;
           isSaved  = true;
           showEditSec = false;
        }      
        return null;
    }
	
	public class BaseException extends Exception {}
}