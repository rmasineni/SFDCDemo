/********************************************************************************
*	Author  	: Chandrika Dasaradharaman (chandrikad@sunrunhome.com)			*
*	Date    	: March 2012													*
*	Name		: ProposalEditNoteClass.cls										*
*	Description	: This class is used to Edit and save the Notes					* 
*				  related to a Proposal											*
*																				*
*********************************************************************************/
public class ProposalEditNoteClass {
     String bodyVal = null;
     public boolean isSaved {get;set;}
     public Notes__c noteRecord {get;set;} 
     public string noteValue {get;set;} 
     public ID propid {get;set;}
     public String parentURL{get;set;}
     public String baseURL{get;set;}
     public Boolean showEditContent {get;set;}
     public Boolean disEditButton {get;set;}
     public Boolean disSaveButton {get;set;}
     
     public ProposalEditNoteClass(ApexPages.StandardController stdController) { 
        
        Notes__c noteRecordObj;
        noteRecordObj = (Notes__c)stdController.getRecord();
        
        isSaved  = false;
        noteRecord = [Select n.Proposal__c, n.Notes__c, n.Id From Notes__c n where n.Id =:noteRecordObj.Id];
        System.debug('noteRecord'+noteRecord);
        
        propid = noteRecord.Proposal__c;
        
        //Building Parent URL
        baseURL = EDPUtil.getBaseURL();
		parentURL = baseURL + '/' + propid;

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
        if(this.bodyVal != null && this.bodyVal != ''){
		noteRecord.Notes__c = this.bodyVal;
        update  noteRecord;  
        isSaved  = true;    
        }
        return null;
    }
 
    
}