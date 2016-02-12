/********************************************************************************
*   Author      : Chandrika Dasaradharaman (chandrikad@sunrunhome.com)          *
*   Date        : April 2013                                                    *
*   Name        : OpportunityNewNoteClass.cls                                   *
*   Description : This class is used to add new notes for a                     * 
*                 Opportunity Record                                            *
*                                                                               *
*********************************************************************************/
public class OpportunityNewNoteClass {
     String bodyVal = null;
     public boolean isSaved {get;set;}
     public Opportunity noteRecord {get;set;} 
     public string noteValue {get;set;} 
     public ID Opportunityid {get;set;}
     public String parentURL{get;set;}
     public String baseURL{get;set;}
     public Boolean ispartnerUser;
     public Boolean isAEEUser;
     public String whichOrgValue;
     public boolean showEditSec {get; set;}
     
     public OpportunityNewNoteClass(ApexPages.StandardController stdController) { 
        
        Opportunity noteRecordObj;
        ispartnerUser = false;
        isAEEUser = false;
        isSaved = false;
        showEditSec = true;
        noteRecordObj = (Opportunity)stdController.getRecord();

        Opportunityid = noteRecordObj.id;
        System.debug('noteRecord'+Opportunityid);
        
        //Building Parent URL
        baseURL = EDPUtil.getBaseURL();
        parentURL = baseURL + '/apex/partneropportunitycreate?id=' + Opportunityid;
        getIsAEEUser();
    }
    
    public boolean getIsAEEUser(){
        string AEEDiv = label.AEE_Label;
        User loggedInUser = [Select Id, DefaultDivision, User_Division_Custom__c from User where id =: UserInfo.getUserId()];
        isAEEUser = loggedInUser.User_Division_Custom__c.contains(AEEDiv)?True:False;
        system.debug('>>>isAEEUser'+isAEEUser);
        return isAEEUser;
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
        /*
        if(noteValue != null && noteValue != '' && noteValue.Length() < 2){
            String errorMessage = 'Your Notes must have 2 or more characters';
            Exception expObj = new BaseException(errorMessage);
            expObj.setMessage(errorMessage);
            ApexPages.addMessages(expObj);
            return null;
        }*/
        
        if(noteValue != null && noteValue != '' ) { 
            Notes__c newNoteObj = new Notes__c();
            newNoteObj.Opportunity__c = Opportunityid;
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