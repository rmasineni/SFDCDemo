public with sharing class PartnerCaseDetail {
    public Case caseObj;
    public Case caseRec;
    public Id caseId;
    public String parentURL{get;set;}
    public String baseURL{get;set;}
    private List<CaseComment> caseCommentsList;
    public Boolean showProposal{get;set;}
    public Boolean showcloseButton{get;set;}
    
    public PartnerCaseDetail(ApexPages.StandardController stdController){
            
        this.CaseObj = (Case)stdController.getRecord(); 
        CaseId = String.ValueOf(this.CaseObj.Id);
        CaseRec = [select id,ContactId, Status, Reason, Priority, Subject, Description ,Issue_Type__c, ETA__c, Proposal__c,Case_Resolution__c,
                    Help_Category_Type__c,Help_Category__c,Proposal__r.name, CaseNumber, Assignee_Email__c, Assignee__c, CreatedDate, Prop_Customer_Name__c
                    from Case where id =:CaseId];
        
        //Building Parent URL
        baseURL = EDPUtil.getBaseURL();
        parentURL = baseURL + '/apex/CaseSearch?retURL=';
        initialize();
    }  
    
    public void initialize(){
        showProposal = false;
        if(caseRec.Status != 'Closed'){ 
            showCloseButton = true;
        }
        
        if(caseRec.proposal__c != null){
            showProposal = true;
        }
    }
    public string getCaseId(){
        return caseId;
    }
    
    public PageReference editCase(){

        PageReference pr = new PageReference('/apex/PartnerCreateCase?CaseId=' + CaseId); 
        pr.setRedirect(true);   
        return pr; 
    }
    
    public PageReference doClose(){
        if(caseRec != null && caseRec.status != 'Closed'){
            caseRec.Status = 'Closed';
            caseRec.Case_Resolution__c = 'Request Cancelled by user';
            update caseRec;
            showCloseButton = false;
        }
        
        PageReference pageRef = ApexPages.currentPage();
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /* public pageReference doDelete() {
            
            if(caseRec != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                List<String> toAddresses = new List<String>();
                String toAddr = '';
                if(caseRec.Assignee_Email__c != null){
                    toAddr = caseRec.Assignee_Email__c;
                }else {
                    toAddr = Label.SunrunHelpdeskEmail;
                }
                toAddresses.add(toAddr);
                
                String subject = 'Case ' + caseRec.CaseNumber + ' has been deleted on ' + datetime.now();
                String htmlBody = '<html>';
                
                htmlBody += EmailService.getHTMLHeader();
                htmlBody += '<p></p>';
                htmlBody += 'Hi ' + caseRec.Assignee__c +',' + '<br/>';
                htmlBody += '<br/>';
                htmlBody += UserInfo.getName() + ' deleted the case ' + caseRec.CaseNumber;
                htmlBody += '<br/> <br/> Case Details : ';
                htmlBody += '<br/> Case Id : '+ caseRec.Id;
                htmlBody += '<br/> Case Subject : '+ caseRec.Subject;
                htmlBody += '<br/> Case Created On : '+ caseRec.CreatedDate;
                htmlBody += '<br/> <br/>';
                htmlBody += 'Thank you';
                htmlBody += '<br/> From <br/> SFDC Portal <br/> <br/>';
                htmlBody += EmailService.getHTMLFooter();
                htmlBody += '</html>';
                mail.setHtmlBody(htmlBody);
                mail.setSubject(subject);
                mail.setToAddresses(toAddresses);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });    
                
                delete caseRec;
            }
            
            PageReference pr=new PageReference(parentURL);
            pr.setRedirect(true);
            return pr;
    } */
    
    public List<CaseComment> getCaseComment()
    {
        if (CaseRec != null)
        caseCommentsList = [Select ParentId, LastModifiedDate, LastModifiedById, Id, CreatedDate, CreatedById, ConnectionSentId, ConnectionReceivedId, CommentBody From CaseComment c where ParentId = :CaseId];
        return caseCommentsList;
    }

}