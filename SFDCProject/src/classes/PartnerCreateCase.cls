public with sharing class PartnerCreateCase {
    
    Id newCaseId;
    public Case caseRec {get;set;}
    public String title {get;set;}
    public String parentURL{get;set;}
    public String baseURL{get;set;}
    public String errorMessage{get;set;}
    public String caseId {get;set;}
    public boolean editCase {get; set;}
    public boolean reqResolution {get; set;}
    public String ContactName{get; set;}
    public String userId{get;set;}
    public Contact contactObj; 
    public String helpCategory{get;set;}
    public String priority{get; set;}
    public String recTypeName {get;set;}
    public boolean displayCustomerName {get; set;}
    
    public PartnerCreateCase(ApexPages.StandardController stdController) {
        title = 'New Case';
        errorMessage = '';
        if(caseRec == null){
            caseRec = new Case();
        }
        
        caseId = System.currentPageReference().getParameters().get('caseId');
        System.debug('CaseId: ' + CaseId);
        
        init();
        checkLoginUser();
        
        //Building Parent URL
        baseURL = EDPUtil.getBaseURL();
        parentURL = baseURL + '/apex/CaseSearch?retURL=';

    }
    
    private void init(){
        
        System.debug('caseId: ' + caseId);
        editCase = false;
        reqResolution = false;
        displayCustomerName = false;
        recTypeName = Label.Partner_Help_Record_Type;
        
        if(caseId != null && caseId != ''){
            title = 'Edit Case';
            Case Caseobj = [select id,ContactId, Status, Reason, Priority, Subject, Description ,Issue_Type__c, ETA__c, Proposal__c,Case_Resolution__c,
                            Help_Category_Type__c,Help_Category__c,CaseNumber,Opportunity__c ,Lead__c                               
                            from Case where id =: CaseId limit 1];

            if(Caseobj != null){
                caseRec = Caseobj;
                editCase = true;
            }
        }
        /*showProposal = false;
        if(CaseRec.Help_Category_Type__c != null && CaseRec.Help_Category_Type__c == Label.Show_Proposal_on_Case)
        {
            showProposal = true;
        }*/
        
                
    }
     public void checkLoginUser(){
        userId = UserInfo.getUserId();
        User userObj = [Select Id, contactId from User where Id =:userId ];
        if(userObj.contactId != null){
            contactObj = [Select Id, Name from Contact where Id =:userObj.contactId];
            ContactName = contactObj.Name;
        }
     }
        
    /*public List<SelectOption> gethelpCategoryOption(){
        List<SelectOption> helpCategoryOption = new List<SelectOption>();
        
        helpCategoryOption.add(new SelectOption('', '--None--'));
        helpCategoryOption.add(new SelectOption('login', 'Log In'));
        helpCategoryOption.add(new SelectOption('editCont','Editing Contacts'));
       helpCategoryOption.add(new SelectOption('esign','eSignatures'));
        helpCategoryOption.add(new SelectOption('uploadDoc','Uploading Documents'));
         helpCategoryOption.add(new SelectOption('submitProp','Submitting Proposals'));
          helpCategoryOption.add(new SelectOption('reqCredit','Requesting Credit Check'));
          helpCategoryOption.add(new SelectOption('reports','Reports'));
          helpCategoryOption.add(new SelectOption('other','Other'));
          
        return helpCategoryOption;
        
    }*/
    
    public List<SelectOption> getpriorityOption(){
        List<SelectOption> priorityOption = new List<SelectOption>();
        
        priorityOption.add(new SelectOption('low', 'Low'));
        priorityOption.add(new SelectOption('medium','Medium'));
        priorityOption.add(new SelectOption('high','High'));
        
        return priorityOption;
    }
    public pageReference submitCase() {
        
        Pagereference ref;
        boolean inputMissing = false;
        
        if(caseRec.Subject == null || caseRec.Subject == '' || caseRec.Description == null || caseRec.Description == ''){
            inputMissing = true;   
         }
        
        // *****3/24/2015: Removing Help_Category__c validation.  *****
        
        /* if(caseRec.Help_Category__c == ''||caseRec.Help_Category__c == null){ 
            inputMissing = true;
        
        }else if(caseRec.Subject == null || caseRec.Subject == '' || caseRec.Description == null || caseRec.Description == ''){
            inputMissing = true;
        }else if((caseRec.Help_Category__c == 'eSignatures' || caseRec.Help_Category__c == 'Uploading documents' || caseRec.Help_Category__c == 'Submitting proposals')
                && (caseRec.proposal__c == null)){
                    errorMessage = 'Proposal Id is required for the selected help category';
                    Exception expObj = new BaseException(errorMessage);
                    expObj.setMessage(errorMessage);
                    ApexPages.addMessages(expObj);
                    return null;
        } */
        
        if(inputMissing == true){
            errorMessage = 'Please enter values for the required fields';
            Exception expObj = new BaseException(errorMessage);
            expObj.setMessage(errorMessage);
            ApexPages.addMessages(expObj);
            return null;
        }
        
        if(caseRec != Null){
            if(editCase == false){
                
                 RecordType recType = [Select Id from RecordType where Name = :recTypeName and SobjectType = 'Case'];
                
                //caseRec.Reason = helpCategory;
                caseRec.RecordTypeId = recType.Id;
                if(Priority == 'low'){
                    caseRec.Priority = 'Low';
                }else if(Priority == 'medium'){
                    caseRec.Priority = 'Medium';
                }else if(Priority == 'high'){
                    caseRec.Priority = 'High';
                }
                
                caseRec.ContactId = contactObj.id;
                caseRec.Status = 'Open';

                 try{
                    insert caseRec;
                     }
                  Catch (DMLException ex) {
                       ApexPages.addMessages(ex);
                  return null;    
                      }

                newCaseId = [select id from Case where id =: caseRec.id].id;
                ref = new PageReference('/apex/PartnerCaseDetail?Id=' + newCaseId);
                ref.setRedirect(true);  
                //return ref;
            }else if(editCase = true){
                update caseRec;
                ref = new PageReference('/apex/PartnerCaseDetail?Id=' + caseId);
                ref.setRedirect(true);  
                //return ref;
            }
        }
        
        return ref;
    }

    /*public pageReference SaveAndCloseCase() {
        
        if(helpCategory == Null || helpCategory == '' || 
            caseRec.Case_Resolution__c == Null || caseRec.Case_Resolution__c == ''){
                reqResolution = true;   
                errorMessage = 'Please enter values for the required fields';
                Exception expObj = new BaseException(errorMessage);
                expObj.setMessage(errorMessage);
                ApexPages.addMessages(expObj);
                return null;
        }
        
        if(caseRec != Null){
            if(editCase == false){
                caseRec.Status = EDPUTIl.CLOSED;
                insert caseRec;
            }else if(editCase = true){
                caseRec.Status = EDPUTIl.CLOSED;
                update caseRec;
            }
        }
        PageReference pr=new PageReference(parentURL);
        pr.setRedirect(true);
            
        return pr;
    }*/
    
    public pageReference doCancel() {
        PageReference pr;
        if(editCase == false){
            pr=new PageReference(parentURL);
            pr.setRedirect(true);
            //return pr;
        }else if(editCase == true){
            pr=new PageReference('/apex/PartnerCaseDetail?Id=' + caseId);
            pr.setRedirect(true);
            //return pr;
        }
        return pr;
        
    }
    
    // Removing  Help_Category__c  dependency  
   /*  public Boolean showProposal{
        get{
            Boolean show = false;
            if(caseRec.Help_Category__c == 'eSignatures' || caseRec.Help_Category__c == 'Uploading documents' || caseRec.Help_Category__c == 'Submitting proposals')
            {
                show = true;
                return show;
            }
            
            return show;
        }
        set;
    } */
    
    public String propCustomerName {
        get{
            String CustomerName ='';
            if(CaseRec.Proposal__c != null){
                Proposal__c propObj = [Select Id, Homeowner_Name__c from Proposal__c where Id = :CaseRec.Proposal__c];
                CustomerName = propObj.Homeowner_Name__c;
                displayCustomerName = true;
            }
            return CustomerName;
        }
        set;
    }
    
    public class BaseException extends Exception {}
}