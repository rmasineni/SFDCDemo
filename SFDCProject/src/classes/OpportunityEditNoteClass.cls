/********************************************************************************
*   Author      : Chandrika Dasaradharaman (chandrikad@sunrunhome.com)          *
*   Date        : April 2013                                                    *
*   Name        : OpportunityEditNoteClass.cls                                  *
*   Description : This class is used to Edit and save the Notes                 * 
*                 related to a Opportunity                                      *
*                                                                               *
*********************************************************************************/
public class OpportunityEditNoteClass {
     String bodyVal = null;
     public boolean isSaved {get;set;}
     public Notes__c noteRecord {get;set;} 
     public string noteValue {get;set;} 
     public ID Opportunityid {get;set;}
     public String parentURL{get;set;}
     public String baseURL{get;set;}
     public Boolean showEditContent {get;set;}
     public Boolean disEditButton {get;set;}
     public Boolean disSaveButton {get;set;}
     public Boolean isAEEUser;
     //public boolean showEditSec {get; set;}
     
     public OpportunityEditNoteClass(ApexPages.StandardController stdController) { 
        
        isAEEUser = false;
        Notes__c noteRecordObj;
        noteRecordObj = (Notes__c)stdController.getRecord();
 
        isSaved  = false;
        //showEditSec = true;
        noteRecord = [Select n.Opportunity__c, n.Notes__c, n.Id From Notes__c n where n.Id =:noteRecordObj.Id];
        System.debug('noteRecord'+noteRecord);
        
        Opportunityid = noteRecord.Opportunity__c;
        
        //Building Parent URL
        baseURL = EDPUtil.getBaseURL();
        parentURL = baseURL + '/' + Opportunityid;

        system.debug('Parent URL *******' + parentURL);
        getIsAEEUser();
    }
    
    public boolean getIsAEEUser(){
        string AEEDiv = label.AEE_Label;
        User loggedInUser = [Select Id, DefaultDivision, User_Division_Custom__c from User where id =: UserInfo.getUserId()];
        isAEEUser = loggedInUser.User_Division_Custom__c.contains(AEEDiv)?True:False;
        system.debug('>>>isAEEUser'+isAEEUser);
        return isAEEUser;
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
        system.debug('BodyVal----' + this.bodyVal);
        
        /*
        if(bodyVal != null && bodyVal != '' && bodyVal.Length() < 2){
            String errorMessage = 'Your Notes must have 2 or more characters';
            Exception expObj = new BaseException(errorMessage);
            expObj.setMessage(errorMessage);
            ApexPages.addMessages(expObj);
            return null;
        }*/
        
        if(bodyVal != null && bodyVal != '') { 
           noteRecord.Notes__c = this.bodyVal;
           update  noteRecord;  
           isSaved  = true;    
           //showEditSec = false;
        }
        return null;
    }
    
    public class BaseException extends Exception {}
}