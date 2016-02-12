/********************************************************************************
*   Author      : Chandrika Dasaradharaman (chandrikad@sunrunhome.com)          *
*   Date        : March 2012                                                    *
*   Name        : ProposalNewNoteClass.cls                                      *
*   Description : This class is used to add new notes for a                     * 
*                 Proposal                                                      *
*                                                                               *
*********************************************************************************/
public class ProposalNewNoteClass {
     String bodyVal = null;
     public boolean isSaved {get;set;}
     public Proposal__c noteRecord {get;set;} 
     public string noteValue {get;set;} 
     public ID propid {get;set;}
     public String parentURL{get;set;}
     public String baseURL{get;set;}
     public Boolean ispartnerUser;
     public String whichOrgValue;
     
     public ProposalNewNoteClass(ApexPages.StandardController stdController) { 
        
        Proposal__c noteRecordObj;
        ispartnerUser = false;
        noteRecordObj = (Proposal__c)stdController.getRecord();

        propid = noteRecordObj.id;
        System.debug('noteRecord'+propid);
        
        //Building Parent URL
        baseURL = EDPUtil.getBaseURL();
        parentURL = baseURL + '/' + propid;
       
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
        if(noteValue != null && noteValue != ''){
        Notes__c newNoteObj = new Notes__c();
        newNoteObj.Proposal__c = propid;
        newNoteObj.Notes__c = noteValue;

        newNoteObj.Notes_Added_By__c = getwhichOrg();
        
        insert newNoteObj;
        
        isSaved  = true;
        }
        return null;
    }
    
}