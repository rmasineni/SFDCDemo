public with sharing class PartnerCreateCaseComment {

	public Id caseId {get;set;}
	public String parentURL{get;set;}
	public String baseURL{get;set;}
     
    public boolean isSaved {get;set;}
	public string commentValue {get;set;} 
    public boolean showEditSec {get; set;}
     
     public PartnerCreateCaseComment(ApexPages.StandardController stdController) { 
        
        System.debug('Case Comment');
        Case caseRec;
        caseRec = (Case)stdController.getRecord();

        caseId = caseRec.id;
        System.debug('caseId: '+caseId);
        
        //Building Parent URL
        baseURL = EDPUtil.getBaseURL();
		parentURL = baseURL + '/PartnerCaseDetail?Id=' + caseId;
        showEditSec = true;
       
    }
    
    public PageReference saveComment(){
    	 
        showEditSec = false; 
    	CaseComment caseCommentRec = new CaseComment();
    	caseCommentRec.ParentId = CaseId;
        caseCommentRec.CommentBody = commentValue;
    	
    	//insert caseCommentRec;
    	
    	Database.DMLOptions dmlo = new Database.DMLOptions();
		dmlo.EmailHeader.triggerUserEmail = true;
		Database.insert(caseCommentRec, dmlo);
    	
    	isSaved  = true;
        return null;
    }

}