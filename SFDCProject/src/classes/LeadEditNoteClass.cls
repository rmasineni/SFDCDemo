/********************************************************************************
*	Author  	: Chandrika Dasaradharaman (chandrikad@sunrunhome.com)			*
*	Date    	: April 2013													*
*	Name		: LeadEditNoteClass.cls										*
*	Description	: This class is used to Edit and save the Notes					* 
*				  related to a Lead											*
*																				*
*********************************************************************************/
public class LeadEditNoteClass {
     String bodyVal = null;
     public boolean isSaved {get;set;}
     public Notes__c noteRecord {get;set;} 
     public string noteValue {get;set;} 
     public ID leadid {get;set;}
     public String parentURL{get;set;}
     public String baseURL{get;set;}
     //public String editFlag {get;set;}
     public Boolean showEditContent {get;set;}
     public Boolean disEditButton {get;set;}
     public Boolean disSaveButton {get;set;}
     //public boolean showEditSec {get; set;}
     
     public LeadEditNoteClass(ApexPages.StandardController stdController) { 
        
        Notes__c noteRecordObj;
        noteRecordObj = (Notes__c)stdController.getRecord();
        //editFlag = ApexPages.currentPage().getParameters().get('mode');
        //system.debug(ApexPages.currentPage().getParameters().get('mode'));
        /*showEditContent = true;
        disEditButton = false;
        disSaveButton = false;
        if(editFlag == 'Read'){
        	showEditContent = false;
        	disEditButton = false;
        	disSaveButton = true;
        }else if(editFlag == 'Edit'){
        	showEditContent = true;
        	disEditButton = true;
        	disSaveButton = false;
        }*/
        
        isSaved  = false;
     // showEditSec = true;
        noteRecord = [Select n.Lead__c, n.Notes__c, n.Id From Notes__c n where n.Id =:noteRecordObj.Id];
        System.debug('noteRecord'+noteRecord);
        
        leadid = noteRecord.Lead__c;
        
        //Building Parent URL
        baseURL = EDPUtil.getBaseURL();
		parentURL = baseURL + '/apex/customizeLeadDetailPage?Id=' + leadid;

		system.debug('Parent URL *******' + parentURL);
       
    }
    
	//Getting Existing Value in the Notes Field
	public String getBodyVal() {
        
         System.debug('noteRecord'+noteRecord);
         return noteRecord.Notes__c; 
                  
    }
    
    //To show the Block in Edit or Read Mode
    public PageReference contentMode() {  

		showEditContent = true;  
        return null;  
    } 
                   
    //Get the Input Value entered by user
    public void setBodyVal(String bodyVal){ 
    	this.bodyVal = bodyVal;
    }
    
    //Save the Updated Record
    public PageReference save(){
		noteRecord.Notes__c = this.bodyVal;
        if (noteRecord.Notes__c != null && noteRecord.Notes__c != '') {
           update  noteRecord;  
           isSaved  = true;
           //showEditSec = false;
        }    
        return null;
    }
     
}