global class SRAttachmentRelatedListOpp {
    public static Integer PAGE_SIZE1 = 4;
    public Integer pageSize {get; set;}
    
    public String proposalSource {get;set;}
    public String changeOrderType {get;set;}
    public String isSigned {get;set;}
    
    public String salesRepEmailLabelId {get;set;}
    public String opportunityLookupLabelId {get;set;}
    public String opportunityLookupId {get;set;}
    public String opportunityId {get;set;}
    public String documentCategory {get;set;}

    private boolean isSystemAdmin;
    public boolean isPartnerUser{get;set;}
    public boolean canAttachDocs{get;set;}
    public boolean canInitiateESignature{get;set;}
    public String baseURL{get;set;}
    public String refreshURL{get;set;}
    public ApexPages.StandardSetController ssc {get; set;}
    public List<SRAttachmentWrapper> srAttachments;
    public ID relatedObjectId;
    public boolean displaySignedDocuments{get;set;}
    public boolean displayMasterDocuments{get;set;}
    public boolean displayGeneralDocuments{get;set;}
    public ID getRelatedObjectId(){ return relatedObjectId; }
    public Set<String> documentTypes{get;set;}
    public String actionName{get;set;}
    public Set<Id> selectedIds{get;set;}
    public String message {get;set;}
    public Boolean isEDPProfile {get;set;}
    public boolean editMode{set;get;}
    public void setRelatedObjectId(ID relatedObjIdVal){relatedObjectId = relatedObjIdVal;}
    public string uploadStageError{get { return uploadStageError = CustomErrorMessages.INVALID_UPLOAD_STAGE;} set;} 
    
    public SRAttachmentRelatedListOpp(){
        editMode=true;
        displayMasterDocuments = false;
        isEDPProfile = false;
        canAttachDocs = true;
        baseURL = EDPUtil.getBaseURL();
        User userObj = PRMContactUtil.getLoginUser();
        if(userObj != null && userObj.contactId != null){
            isPartnerUser = true;
        }
        String edit=ApexPages.currentPage().getParameters().get('OpptyEdit');
        if(edit=='false'){
            editMode=false;
        }
        checkUserProfile();
    }
    
    
    public Integer getSRAttachmentsSize(){
        Integer value = 0;
        if(ssc != null){
            value = srAttachments.size();
        }
        return value;
    }
    private String documentSource = EDPUtil.PROPOSAL_TOOL_SOURCE;
    
    public String voidReason {get;set;}
    public boolean showActions {
        get{ 
            System.debug('displayMasterDocuments1: ' + displayMasterDocuments);
            if((displayMasterDocuments == null || displayMasterDocuments == false) 
                && (isEDPProfile == true || displayGeneralDocuments == true)){
                showActions = true;
                return showActions;
            }else{
                showActions = false;
                return showActions;
            }
        }
        set;
    }
    public boolean showCheckbox {
        get{ 
            System.debug('displayMasterDocuments2: ' + displayMasterDocuments);
            if((displayMasterDocuments == null || displayMasterDocuments == false) 
                && isEDPProfile == true){
                showCheckbox = true;
                return showCheckbox;
            }else{
                showCheckbox = false;
                return showCheckbox;
            }
        }
        set;
    }

    public List<SelectOption> getActions() {
        List<SelectOption> actions = new List<SelectOption>();
        actions.add(new SelectOption('', '-- None --'));
        
        if(displayMasterDocuments == true){
            showActions = false;
            showCheckbox = false;
        }if(displayGeneralDocuments == true){
            String relatedObjectIdStr = relatedObjectId + ''; 
            actions.add(new SelectOption('Upload_SC_GeneralDocs', 'Upload Documents'));
          //  actions.add(new SelectOption('Delete', 'Delete Documents'));
        }else{
            actions.add(new SelectOption('Upload', 'Upload Documents'));
         // actions.add(new SelectOption('InitiateESignature', 'Initiate eSignature'));
         // actions.add(new SelectOption('VoidESignature', 'Void eSignature'));
         // actions.add(new SelectOption('ResendESignature', 'Resend eSignature'));
         //   actions.add(new SelectOption('Delete', 'Delete Documents'));
        }
        return actions;
    }

    public List<SRAttachmentWrapper> getSRAttachments(){
        if(relatedObjectId != null ){
            String relatedObjectIdStr = relatedObjectId + ''; 
            initializeSCAttachments();
        }       
        return srAttachments;
    }

    public void initializeSCAttachments(){
        srAttachments = new List<SRAttachmentWrapper>();
        Set<String> modes = new Set<String>();
        Set<String> proposalStagesNotAllowedForUplaod = new Set<String>();
        
        System.debug('relatedObjectId: ' + relatedObjectId);
        //ServiceContract scObj = [Select Id from Opportunity where Id =:relatedObjectId];
        opportunityId = relatedObjectId;
        canAttachDocs = true;   
        proposalSource = '';
        changeOrderType = '';
        isSigned = 'FALSE';
        
        opportunityLookupLabelId = '01I600000005rT7.00N60000001aEf1-_help'; 
        salesRepEmailLabelId = '01I600000005rT7.00N60000001aEer-_help';
        opportunityLookupId = 'lookup' + String.valueOf(relatedObjectId).substring(0, 15) + '00N60000001aEf1';     
        pagesize = PAGE_SIZE1;
        String categoryType = null;

        if(ssc == null){
            String queryString ;
            String whereClause = '';
            
            queryString = SRAttachmentManager.getSCAttachmentSOQL();
            documentCategory = 'General';
            whereClause = ' where ';
            whereClause += ' Active__c = true ' ;
            
            if(relatedObjectId != null){
                System.debug('relatedObjectId: ' + relatedObjectId);
                whereClause += ' and Opportunity__c =:relatedObjectId ';
            }
            //whereClause += ' and Document_Classification__r.Category__c = :documentCategory ';
            queryString += whereClause;
            queryString += ' order by Document_Type_Name__c asc ';
            System.debug('queryString: ' + queryString);
            
            ssc = new ApexPages.StandardSetController(Database.query(queryString));
            pageSize = (pageSize == null || pageSize <= 0) ? PAGE_SIZE1 : pageSize;
            if(pageSize != null){
                ssc.setPageSize(pageSize);
            }  
            canAttachDocs = true; 
         }  
             
        List<SR_Attachment__C> tempSRAttachment = ssc.getRecords();
        Map<String, SRAttachmentWrapper> srAttachmentsWithESignMap = new Map<String, SRAttachmentWrapper>();
        List<SRAttachmentWrapper> tempSRAttachmentWrapperList = new List<SRAttachmentWrapper>();
        for(SR_Attachment__C srAttchmentObj: tempSRAttachment){
            SRAttachmentWrapper srAttachmentWrapperObj = new SRAttachmentWrapper(srAttchmentObj,true);
            srAttachmentWrapperObj.signatureRequired = false;   
            srAttachmentWrapperObj.readyForSubmission = false;
            tempSRAttachmentWrapperList.add(srAttachmentWrapperObj);    
        }           
        
        for(SRAttachmentWrapper srAttchmentWrapperObj: tempSRAttachmentWrapperList){
            srAttachments.add(srAttchmentWrapperObj);
        }
    }
    
    public void initializeSRAttachments(){
        
        
    }    

    public Pagereference updateDocuSignStatus(){
        //eSignServiceNew.getAndUpdateDocuSignStatus();
        return null;
    }
    
    public Pagereference resend(){
        return null;
    }

    public Pagereference userActions(){
        Pagereference pageRef = null;
        System.debug('actionName: ' + actionName);
        message = '';
        
        if(canAttachDocs == false){
            message = 'Invalid Proposal Stage to modify the proposal documents';
            return null;
        }
        if(actionName == null || actionName == ''){
            message = 'Please select an user action';
            return null;
        }else if(actionName == 'VoidESignature'){
            return voidESignature();
        }else if(actionName == 'ResendESignature'){
            return resendESignature();
        }else if(actionName == 'Delete'){
            return deleteSRAttachments() ;
        }else{
            return null;
        }
    }

    public String getRelatedlistRefreshURL(){
        String url = '/apex/';
        if(displaySignedDocuments == true){
            url +=  'Proposal_eSignDocuments';
        }else if(displayGeneralDocuments == true){
            url +=  'Proposal_GeneralDocuments';
        }else{
            url +=  'Proposal_SRAttachmentListView';
        }
        url += '?id=' + relatedObjectId;
        return url;
    }

    public void getSelectedIds(){
        if(srAttachments != null){
            selectedIds = new Set<Id>();
            for(SRAttachmentWrapper srAttachmentWrapperObj :srAttachments){
                if(srAttachmentWrapperObj.selected){
                    selectedIds.add(srAttachmentWrapperObj.srAttachment.Id);
                }
            }
        }
    }

    public void selectSRAttachments(){
        for(SRAttachmentWrapper srAttachmentWrapperObj :srAttachments){
            srAttachmentWrapperObj.selected = true;
        }
    }
    
    private Map<Id, SR_Attachment__c> getSelectedSRAttachments(boolean forDelete){
        Map<Id, SR_Attachment__c> selectedSRAttachments = new Map<Id, SR_Attachment__c>();
        List<Id> selectedIds = null;
        List<SR_Attachment__c> tempList = new List<SR_Attachment__c>();
        if(srAttachments != null){
            selectedIds = new List<Id>();
            for(SRAttachmentWrapper srAttachmentWrapperObj :srAttachments){
                if(srAttachmentWrapperObj.selected){
                    selectedIds.add(srAttachmentWrapperObj.srAttachment.Id);
                }
            }
            String soqlStr = SRAttachmentManager.getSRAttachmentSOQL();
            soqlStr += ' Where Id in : selectedIds ' ;
            
            System.debug('selectedIds: ' + selectedIds);
            
            for(SR_Attachment__c srAttachmentObj : Database.query(soqlStr)){            
                srAttachmentObj.Active__c = (forDelete == true) ? false : srAttachmentObj.Active__c;
                selectedSRAttachments.put(srAttachmentObj.Id, srAttachmentObj);
                System.debug('srAttachmentObj.Opportunity__c: ' + srAttachmentObj.Opportunity__c);
                System.debug('srAttachmentObj: ' + srAttachmentObj);
            }
        }
        return selectedSRAttachments;
    }
    
    public PageReference voidESignature(){  
        System.debug('Start: voidESignature');
        Map<Id, SR_Attachment__c> selectedSRAttachments = getSelectedSRAttachments(false);
        SR_Attachment__c srAttachmentObj;
        if(selectedSRAttachments.size() <= 0 ){
            String errorMessage = 'Select a record to void the eSignature request';
            Exception expObj = new BaseException(errorMessage);
            expObj.setMessage(errorMessage);
            ApexPages.addMessages(expObj);
            return null;        
        }
        srAttachmentObj = selectedSRAttachments.values()[0];
        if(srAttachmentObj.Envelop_Id__c == null || srAttachmentObj.Envelop_Id__c == '' 
            || srAttachmentObj.DocuSign_Status__c == 'Voided'){
            String errorMessage = 'No eSign requests are in pending for this record';
            Exception expObj = new BaseException(errorMessage);
            expObj.setMessage(errorMessage);
            ApexPages.addMessages(expObj);
            return null;                
        }

        return getRefreshPage();    
    }
    
    
    public PageReference resendESignature(){    
        Map<Id, SR_Attachment__c> selectedSRAttachments = getSelectedSRAttachments(false);
        SR_Attachment__c srAttachmentObj;
        if(selectedSRAttachments.size() <= 0 ){
            String errorMessage = 'Select a record to resend the eSignature request';
            Exception expObj = new BaseException(errorMessage);
            expObj.setMessage(errorMessage);
            ApexPages.addMessages(expObj);
            return null;        
        }
        srAttachmentObj = selectedSRAttachments.values()[0];
        if(srAttachmentObj.Envelop_Id__c == null || srAttachmentObj.Envelop_Id__c == ''){
            String errorMessage = CustomErrorMessages.NO_PENDING_ESIGN_REQUESTS;
            Exception expObj = new BaseException(errorMessage);
            expObj.setMessage(errorMessage);
            ApexPages.addMessages(expObj);
            return null;                
        }

        String result = '';
        
        Contact primaryContact;
        Contact secondaryContact;
        Contact partnerContact;
        String sunrunRecipientName = Label.SunRun_DocuSign_User;
        String sunrunRecipientEmail = Label.SunRun_DocuSign_Email; 
        String envelopId = srAttachmentObj.Envelop_Id__c;
        System.debug('envelopId: ' + envelopId);
        List<dsfs__DocuSign_Status__c> docuSignStatusList = [Select Id, dsfs__DocuSign_Envelope_ID__c, dsfs__Envelope_Status__c from 
                                                            dsfs__DocuSign_Status__c where dsfs__DocuSign_Envelope_ID__c =:envelopId];      
        if(docuSignStatusList.size() > 0){
            if(docuSignStatusList[0].dsfs__Envelope_Status__c == 'Voided' 
                || docuSignStatusList[0].dsfs__Envelope_Status__c == 'Completed'){
                String errorMessage = CustomErrorMessages.RESEND_NOT_ALLOWED;
                Exception expObj = new BaseException(errorMessage);
                expObj.setMessage(errorMessage);
                ApexPages.addMessages(expObj);
                return null;                    
            }
        }else{
            String errorMessage = CustomErrorMessages.NO_PENDING_ESIGN_REQUESTS;
            Exception expObj = new BaseException(errorMessage);
            expObj.setMessage(errorMessage);
            ApexPages.addMessages(expObj);
            return null;
        }
        
        Set<String> emailSet = new Set<String>();
        Set<String> contactNameSet = new Set<String>();
        Map<Id, RecordType> contactRecordTypeMap = PRMLibrary.getContactRecordTypes();
        Map<String, dsfs__DocuSign_Recipient_Status__c> recipientMap = new Map<String, dsfs__DocuSign_Recipient_Status__c>();
        for(dsfs__DocuSign_Recipient_Status__c recipientStatusObj : [Select Id, dsfs__DocuSign_Recipient_Email__c, Name, dsfs__DocuSign_Routing_Order__c 
                                                                        from dsfs__DocuSign_Recipient_Status__c where dsfs__Envelope_Id__c =:envelopId]){
            emailSet.add(recipientStatusObj.dsfs__DocuSign_Recipient_Email__c);
            contactNameSet.add(recipientStatusObj.Name);
            recipientMap.put(recipientStatusObj.dsfs__DocuSign_Recipient_Email__c, recipientStatusObj);
        }
        
        for(Contact contactObj : ([Select Id, email, recordTypeId, name from Contact where email in :emailSet and name in :contactNameSet])){
            RecordType recordTypeObj =  contactRecordTypeMap.get(contactObj.recordTypeId);  
            dsfs__DocuSign_Recipient_Status__c recipientObj = recipientMap.get(contactObj.email);
            if((recordTypeObj.name == PRMLibrary.PARTNER) || (recordTypeObj.name == PRMLibrary.EMPLOYEE)){
                partnerContact = contactObj;
            }else if(recordTypeObj.name == 'Residential'){
                if(recipientObj.dsfs__DocuSign_Routing_Order__c == 1){
                    primaryContact = contactObj;
                }else{
                    secondaryContact = contactObj;
                }
            }                                   
        }

        result = eSignServiceNew.resendDocumentsToDocusign(srAttachmentObj);
        if(result != EDPUtil.SUCCESS){
            Exception expObj = new BaseException();
            expObj.setMessage(result);
            ApexPages.addMessages(expObj);
            return null;            
        }
        return getRefreshPage();
    }

    public PageReference getRefreshPage(){
        String url = '/apex/';
        url +=  'Proposal_GeneralDocuments';
        if(displayGeneralDocuments == true ){
            url +=  'Proposal_GeneralDocuments';
        }else if(displaySignedDocuments == true || displayMasterDocuments == true){
            url +=  'Proposal_eSignDocuments';
        }else{
            url +=  'Proposal_SRAttachmentListView';
        }
        url += '?id=' + relatedObjectId;
        System.debug('url: ' + url);
        PageReference pageRef = new Pagereference(url); 
        return pageRef;     
    }


    public PageReference deleteSRAttachments(){
        Set<String> proposalStagesNotAllowedForDelete = new Set<String>();
        Set<String> proposalStagesAllowedForDelete = new Set<String>();
        Set<String> proposalStagesForConditionalDelete = new Set<String>();
        Set<String> excludedProposalStages = new Set<String>();     

        excludedProposalStages.add(EDPUtil.CREATED);
        excludedProposalStages.add(EDPUtil.ON_HOLD);
        excludedProposalStages.add(EDPUtil.PENDING);
        excludedProposalStages.add(EDPUtil.READY_FOR_SUBMISSION);
        
        proposalStagesNotAllowedForDelete.add(EDPUtil.REPLACED_BY);
        proposalStagesNotAllowedForDelete.add(EDPUtil.WITH_DRAWN);
        proposalStagesNotAllowedForDelete.add(EDPUtil.SR_OPS_APPROVED);
        proposalStagesNotAllowedForDelete.add(EDPUtil.SR_DECLINED);
        proposalStagesNotAllowedForDelete.add(EDPUtil.EXPIRED);

        proposalStagesForConditionalDelete.add(EDPUtil.CREATED);
        proposalStagesForConditionalDelete.add(EDPUtil.ON_HOLD);
        proposalStagesForConditionalDelete.add(EDPUtil.PENDING);        
        proposalStagesForConditionalDelete.add(EDPUtil.READY_FOR_SUBMISSION);
        proposalStagesForConditionalDelete.add(EDPUtil.SUBMITTED);
        proposalStagesForConditionalDelete.add(EDPUtil.SR_OPS_RECEIVED);
        proposalStagesForConditionalDelete.add(EDPUtil.SR_OPS_REVIEWED);
        proposalStagesForConditionalDelete.add(EDPUtil.CREDIT_REVIEW);
        proposalStagesForConditionalDelete.add(EDPUtil.CREDIT_APPROVED);
        proposalStagesForConditionalDelete.add(EDPUtil.SR_SIGNOFF_REVIEW);
        proposalStagesForConditionalDelete.add(EDPUtil.PENDING_TASK_COMPLETED);
        Boolean resetSignedStatus = false;
        String relatedObjectIdStr = relatedObjectId + ''; 
        
        List<SR_Attachment__c> srAttachmentsForDelete = new List<SR_Attachment__c>();
        Map<Id, SR_Attachment__c> selectedSRAttachments = getSelectedSRAttachments(true);
        if(selectedSRAttachments.size() > 0 ){
            SR_Attachment__c tempSRAttachmentObj = selectedSRAttachments.values()[0];
            Proposal__c tempProposalObj;
            
            
            Contact contactObj = PRMContactUtil.getLoginUserAccountAndContact();
            Boolean isPartnerContact = PRMContactUtil.isPartnerContact(contactObj);
            Set<String> modes = new Set<String>();
            modes.add(EDPUtil.READ);
            modes.add(EDPUtil.EDIT);
            
            update selectedSRAttachments.values();   
            
        }
        
        String url = '/apex/';
        
        url += 'Opportunity_eSignDocuments' ;
        //url +=  (displaySignedDocuments == true) ? 'Proposal_eSignDocuments' :  'Proposal_SRAttachmentListView';
        url += '?id=' + relatedObjectId;
        PageReference pageRef = new Pagereference(url); 
        return pageRef;
        
    }

    public boolean getIsSystemAdmin(){
        isSystemAdmin = false;
        Id profileId = UserInfo.getProfileId();
        Profile profileObj = [Select Name from Profile where Id =:profileId];
        if(profileObj.name == 'System Administrator'){
            isSystemAdmin = true;
        }
        return isSystemAdmin;
    }


    public void checkUserProfile(){
        Id profileId = UserInfo.getProfileId();
        String tempProfileId = profileId;
        tempProfileId = tempProfileId.substring(0,15);
        String profileLike = '%'+ tempProfileId +'%';
        System.debug('profileLike: ' + profileLike);
        List<EDP_Profile__C> edpProfileList = [Select Id, profile_Id__c from EDP_Profile__C where profile_Id__c like :profileLike];
        if(edpProfileList != null && edpProfileList.size() > 0){
            isEDPProfile = true;
        }
        System.debug('isEDPProfile: ' + isEDPProfile);
    }
        
    public boolean getIsPartnerUser(){
        Boolean ispartnerUser = false;
        String userType = UserInfo.getUserType();
        if(userType != null && userType != ''){
            if(userType.contains('Partner'))
                return true;
        }
        return ispartnerUser;
    }
    public boolean displayValue{get;set;}
    public class BaseException extends Exception {}
}