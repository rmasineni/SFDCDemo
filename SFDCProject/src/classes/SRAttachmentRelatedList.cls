/****************************************************************************************************************
Name    : SRAttachmentRelatedList
Author  : ZCloud Team
Date    : Mar, 2013
Description: This class is used to display the SR Attachment records as a related list on Proposal detail page. 
*****************************************************************************************************************/
global class SRAttachmentRelatedList {
    public static Integer PAGE_SIZE1 = 5;
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
    public String proposalprefix  {get;set;}
    public String scprefix  {get;set;}
    
    public void setRelatedObjectId(ID relatedObjIdVal){relatedObjectId = relatedObjIdVal;}
    public string uploadStageError{get { return uploadStageError = CustomErrorMessages.INVALID_UPLOAD_STAGE;} set;} 
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
            if(relatedObjectIdStr.startsWith(proposalprefix)){
                actions.add(new SelectOption('Upload_Proposal_GeneralDocs', 'Upload Documents'));
            }else if(relatedObjectIdStr.startsWith(scprefix)){
                actions.add(new SelectOption('Upload_SC_GeneralDocs', 'Upload Documents'));
            }
            actions.add(new SelectOption('Delete', 'Delete Documents'));
        }else{
            actions.add(new SelectOption('Upload', 'Upload Documents'));
            actions.add(new SelectOption('InitiateESignature', 'Initiate eSignature'));
            actions.add(new SelectOption('VoidESignature', 'Void eSignature'));
            actions.add(new SelectOption('ResendESignature', 'Resend eSignature'));
            actions.add(new SelectOption('Delete', 'Delete Documents'));
        }
        return actions;
    }

    public List<SRAttachmentWrapper> getSRAttachments(){
        if(relatedObjectId != null ){
            String relatedObjectIdStr = relatedObjectId + ''; 
            if(relatedObjectIdStr.startsWith(proposalprefix)){
                initializeSRAttachments();
            }else if(relatedObjectIdStr.startsWith(scprefix)){
                initializeSCAttachments();
            }
        }       
        return srAttachments;
    }

    public void initializeSCAttachments(){
        srAttachments = new List<SRAttachmentWrapper>();
        Set<String> modes = new Set<String>();
        Set<String> proposalStagesNotAllowedForUplaod = new Set<String>();
        
        System.debug('relatedObjectId: ' + relatedObjectId);
        ServiceContract scObj = [Select Id, Opportunity__c from ServiceContract where Id =:relatedObjectId];
        opportunityId = scObj.Opportunity__c;
        canAttachDocs = true;   
        proposalSource = '';
        changeOrderType = '';
        isSigned = 'FALSE';
        
        opportunityLookupLabelId = '01I600000005rT7.00N60000001aEf1-_help'; 
        salesRepEmailLabelId = '01I600000005rT7.00N60000001aEer-_help';
        opportunityLookupId = 'lookup' + String.valueOf(scObj.Opportunity__c).substring(0, 15) + '00N60000001aEf1';     
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
                whereClause += ' and Service_Contract__c =:relatedObjectId ';
            }
            whereClause += ' and Document_Classification__r.Category__c = :documentCategory ';
            queryString += whereClause;
            queryString += ' order by Document_Type_Name__c asc ';
            System.debug('queryString: ' + queryString);
            
            ssc = new ApexPages.StandardSetController(Database.query(queryString));
            pageSize = (pageSize == null || pageSize <= 0) ? PAGE_SIZE1 : pageSize;
            if(pageSize != null){
                ssc.setPageSize(pageSize);
            }  
            canAttachDocs = false; 
         }  
             
        List<SR_Attachment__C> tempSRAttachment = ssc.getRecords();
        Map<String, SRAttachmentWrapper> srAttachmentsWithESignMap = new Map<String, SRAttachmentWrapper>();
        List<SRAttachmentWrapper> tempSRAttachmentWrapperList = new List<SRAttachmentWrapper>();
        for(SR_Attachment__C srAttchmentObj: tempSRAttachment){
            SRAttachmentWrapper srAttachmentWrapperObj = new SRAttachmentWrapper(srAttchmentObj);
            srAttachmentWrapperObj.signatureRequired = false;   
            srAttachmentWrapperObj.readyForSubmission = false;
            tempSRAttachmentWrapperList.add(srAttachmentWrapperObj);    
        }           
        
        for(SRAttachmentWrapper srAttchmentWrapperObj: tempSRAttachmentWrapperList){
            srAttachments.add(srAttchmentWrapperObj);
        }
    }
    
    


    public void initializeSRAttachments(){
        
        Set<String> proposalStagesNotAllowedForUplaod = new Set<String>();
        
        proposalStagesNotAllowedForUplaod.add(EDPUtil.REPLACED_BY);
        proposalStagesNotAllowedForUplaod.add(EDPUtil.INACTIVE);
        proposalStagesNotAllowedForUplaod.add(ProposalUtil.SUNRUN_VOID);
        proposalStagesNotAllowedForUplaod.add(EDPUtil.WITH_DRAWN);
        proposalStagesNotAllowedForUplaod.add(EDPUtil.EXPIRED);
        proposalStagesNotAllowedForUplaod.add(EDPUtil.SR_DECLINED);
        
        System.debug('relatedObjectId: ' + relatedObjectId);
        Proposal__c proposalObj = [Select Id, Install_Partner__c,Opportunity__c, Sales_Partner__c, Proposal_Source__c,Signed__c,
                                        Change_Order_Information__c, stage__c from Proposal__C where Id =:relatedObjectId];
        opportunityId = proposalObj.Opportunity__c;
        if(proposalStagesNotAllowedForUplaod.contains(proposalObj.stage__c)){// == EDPUtil.CREATED || proposalObj.stage__c  == EDPUtil.PENDING ){
            canAttachDocs = false;
            canInitiateESignature = false;
        }
        else{
             canAttachDocs = true;  
             canInitiateESignature = true;
        }
        proposalSource = (proposalObj.Proposal_Source__c == null) ? '' : proposalObj.Proposal_Source__c;
        changeOrderType = (proposalObj.Change_Order_Information__c == null) ? '' : proposalObj.Change_Order_Information__c;
        isSigned = (proposalObj.signed__c == true) ? 'TRUE' : 'FALSE';
        
        opportunityLookupLabelId = '01I600000005rT7.00N60000001aEf1-_help'; 
        salesRepEmailLabelId = '01I600000005rT7.00N60000001aEer-_help';
        opportunityLookupId = 'lookup' + String.valueOf(proposalObj.Opportunity__c).substring(0, 15) + '00N60000001aEf1';       
        pagesize = PAGE_SIZE1;
        srAttachments = new List<SRAttachmentWrapper>();
        String categoryType = null;
        Set<String> modes = new Set<String>();
        modes.add('Read');
        modes.add('Edit');
        
        if(displayGeneralDocuments == false){
            documentTypes = EDPDocumentSettings.getVisibleDocumentTypesByCategroy(categoryType, modes, proposalObj.Sales_Partner__c,
                                                                                                proposalObj.Install_Partner__c);
        }
        
        if(ssc == null){
            String queryString ;
            String whereClause = '';
            
            queryString = SRAttachmentManager.getSRAttachmentSOQL();
            documentCategory = 'General';
            whereClause = ' where ';
            if(displayGeneralDocuments == false){
                whereClause += ' Document_Type_Name__c in :documentTypes and Active__c = true ';
            }else{
                whereClause += ' Active__c = true ' ;
            }
            if(relatedObjectId != null){
                System.debug('relatedObjectId: ' + relatedObjectId);
                whereClause += ' and Proposal__c =:relatedObjectId ';
            }
            System.debug('documentTypes: ' + documentTypes);

            System.debug('displayMasterDocuments: ' + displayMasterDocuments);
            if(displayMasterDocuments == true){
                whereClause += ' and document_source__c =: documentSource ';
                pagesize = 8;
                showActions = false;
                showCheckbox = false;
                
            }else if(displayGeneralDocuments == true){
                whereClause += ' and Document_Classification__r.Category__c = :documentCategory ';
            }else{
                whereClause += ' and document_source__c != :documentSource and (Document_Classification__r.Category__c = null OR Document_Classification__r.Category__c = \'EOP\' ) ';
            }
            System.debug('documentSource: ' + documentSource);
            queryString += whereClause;
            queryString += ' order by Document_Type_Name__c asc ';
            System.debug('queryString: ' + queryString);
            
            ssc = new ApexPages.StandardSetController(Database.query(queryString));
            pageSize = (pageSize == null || pageSize <= 0) ? PAGE_SIZE1 : pageSize;
            if(pageSize != null){
                ssc.setPageSize(pageSize);
            }  
            canAttachDocs = false; 
         }  
             
        List<SR_Attachment__C> tempSRAttachment = ssc.getRecords();
        Map<String, SRAttachmentWrapper> srAttachmentsWithESignMap = new Map<String, SRAttachmentWrapper>();
        List<SRAttachmentWrapper> tempSRAttachmentWrapperList = new List<SRAttachmentWrapper>();
        for(SR_Attachment__C srAttchmentObj: tempSRAttachment){
            SRAttachmentWrapper srAttachmentWrapperObj = new SRAttachmentWrapper(srAttchmentObj);
            if(srAttchmentObj.Document_Classification__r.ESignature_allowed__c == null 
                || srAttchmentObj.Document_Classification__r.ESignature_allowed__c != true
                || (srAttchmentObj.Document_Classification__r.ESignature_allowed__c != null 
                    && srAttchmentObj.Document_Classification__r.ESignature_allowed__c == true
                    && srAttchmentObj.Wet_Sign_Status__c != null && srAttchmentObj.Wet_Sign_Status__c == EDPUtil.NA)){
                srAttachmentWrapperObj.signatureRequired = false;   
            }   
            System.debug('srAttachmentWrapperObj.signatureRequired: ' + srAttachmentWrapperObj.signatureRequired);
            
            Set<String> wetSignedStatus = new Set<String>();
            wetSignedStatus.add(EDPUtil.SIGNED);
            wetSignedStatus.add(EDPUtil.SR_COUNTERSIGNED);
            wetSignedStatus.add(EDPUtil.NA);

            Set<String> docuSignStatus = new Set<String>();
            docuSignStatus.add(EDPUtil.SENT);
            docuSignStatus.add(EDPUtil.DELIVERED);
            docuSignStatus.add(EDPUtil.COMPLETED);
                    
            if((!wetSignedStatus.contains(srAttchmentObj.Wet_Sign_Status__c)
                && srAttchmentObj.DocuSign_Status__c != NULL && !docuSignStatus.contains(srAttchmentObj.DocuSign_Status__c))
                || (srAttchmentObj.Wet_Sign_Status__c != null && srAttchmentObj.Wet_Sign_Status__c == EDPUtil.UNSIGNED
                    && srAttchmentObj.document_source__c == EDPUtil.MANUAL_UPLOAD_SOURCE)){
                srAttachmentWrapperObj.readyForSubmission = false;
            }           

            if(srAttchmentObj.Envelop_Id__c != null && srAttchmentObj.Envelop_Id__c != ''){
                srAttachmentsWithESignMap.put(srAttchmentObj.Envelop_Id__c, srAttachmentWrapperObj);
            }else{
                tempSRAttachmentWrapperList.add(srAttachmentWrapperObj);    
            }
        }           
        Map<String, List<dsfs__DocuSign_Recipient_Status__c>> recipientMap = new Map<String, List<dsfs__DocuSign_Recipient_Status__c>>();
        Set<String> emailIds = new Set<String>();
        Set<String> Names = new Set<String>();
        Map<String, String> contactRecordTypeMap = new Map<String, String>();
        Map<Id, RecordType> contactRecordTypes = PRMLibrary.getContactRecordTypes();
        if(srAttachmentsWithESignMap.size() > 0){
            for(dsfs__DocuSign_Recipient_Status__c docuSignRecipientStatusObj : [Select Id, dsfs__Envelope_Id__c, Name, In_Person_Email_Id__c,
                                                                                    dsfs__Recipient_Status__c, dsfs__DocuSign_Recipient_Email__c, dsfs__DocuSign_Routing_Order__c 
                                                                                    from dsfs__DocuSign_Recipient_Status__c where dsfs__Envelope_Id__c in :srAttachmentsWithESignMap.keySet()]){

                List<dsfs__DocuSign_Recipient_Status__c> recipientList = recipientMap.containskey(docuSignRecipientStatusObj.dsfs__Envelope_Id__c) ? 
                                                                         recipientMap.get(docuSignRecipientStatusObj.dsfs__Envelope_Id__c) : new List<dsfs__DocuSign_Recipient_Status__c>();
            
                recipientList.add(docuSignRecipientStatusObj);
                recipientMap.put(docuSignRecipientStatusObj.dsfs__Envelope_Id__c, recipientList);
                Names.add(docuSignRecipientStatusObj.Name);
                String tempEmailId = (docuSignRecipientStatusObj.In_Person_Email_Id__c != null && docuSignRecipientStatusObj.In_Person_Email_Id__c !=  '') ? docuSignRecipientStatusObj.In_Person_Email_Id__c : docuSignRecipientStatusObj.dsfs__DocuSign_Recipient_Email__c;
                emailIds.add(tempEmailId);
            }
            for(Contact contactObj : [Select Id, email, name, recordTypeId from Contact where name in :Names and email in :emailIds]){
                contactRecordTypeMap.put(contactObj.email, contactObj.recordTypeId);
            }

            for(SRAttachmentWrapper srAttachmentWrapperObj : srAttachmentsWithESignMap.values()){
                String envelopId = srAttachmentWrapperObj.srAttachment.Envelop_Id__c;

                System.debug('Wet_Sign_Status__c: ' + srAttachmentWrapperObj.srAttachment.Wet_Sign_Status__c);
                if(srAttachmentWrapperObj.srAttachment.Wet_Sign_Status__c == EDPUtil.SIGNED 
                    || srAttachmentWrapperObj.srAttachment.Wet_Sign_Status__c == EDPUtil.SR_COUNTERSIGNED){
                    srAttachmentWrapperObj.sunrunOperationName = srAttachmentWrapperObj.srAttachment.SunRun_Signed__c;
                    srAttachmentWrapperObj.partnerName = srAttachmentWrapperObj.srAttachment.Partner_Signed__c;
                    srAttachmentWrapperObj.primaryCustomerName = srAttachmentWrapperObj.srAttachment.Customer_Signed__c;
                    srAttachmentWrapperObj.secondaryCustomerName = 'N/A';                   
                }else if(srAttachmentWrapperObj.srAttachment.Wet_Sign_Status__c == EDPUtil.UNSIGNED 
                    && srAttachmentWrapperObj.srAttachment.document_source__c == EDPUtil.MANUAL_UPLOAD_SOURCE){
                    srAttachmentWrapperObj.readyForSubmission = false;
                }
                if(recipientMap.containsKey(envelopId)){
                    List<dsfs__DocuSign_Recipient_Status__c> recipientList  = recipientMap.get(envelopId);
                    if(recipientList != null && recipientList.size() > 0){
                        srAttachmentWrapperObj.sunrunOperationName = (srAttachmentWrapperObj.sunrunOperationName == '') ? 'N/A' : srAttachmentWrapperObj.sunrunOperationName ;
                        srAttachmentWrapperObj.partnerName = (srAttachmentWrapperObj.partnerName == '') ? 'N/A' : srAttachmentWrapperObj.partnerName ;
                        srAttachmentWrapperObj.primaryCustomerName = (srAttachmentWrapperObj.primaryCustomerName == '') ? 'N/A' : srAttachmentWrapperObj.primaryCustomerName ;
                        srAttachmentWrapperObj.secondaryCustomerName = (srAttachmentWrapperObj.secondaryCustomerName == '') ? 'N/A' : srAttachmentWrapperObj.secondaryCustomerName ;
                    }
                    
                    for(dsfs__DocuSign_Recipient_Status__c recipientStatusObj : recipientList){
                        String tempEmailId = (recipientStatusObj.In_Person_Email_Id__c != null && recipientStatusObj.In_Person_Email_Id__c !=  '') ? recipientStatusObj.In_Person_Email_Id__c : recipientStatusObj.dsfs__DocuSign_Recipient_Email__c;
                        
                        if(tempEmailId == Label.SunRun_DocuSign_Email){
                            String sunrunOpsName = (recipientStatusObj.name == 'Any Signer') ? 'Sunrun Operations' : recipientStatusObj.name;
                            
                            srAttachmentWrapperObj.sunrunOperationName = sunrunOpsName + ' | ' + recipientStatusObj.dsfs__Recipient_Status__c;
                            srAttachmentWrapperObj.sunrunOperationEmail = tempEmailId;
                            srAttachmentWrapperObj.sunrunOperationStatus = recipientStatusObj.dsfs__Recipient_Status__c;                            
                        }else{
                            String contactRecordTypesId =  contactRecordTypeMap.get(tempEmailId);
                            RecordType recordTypeObj = contactRecordTypes.get(contactRecordTypesId);
                            if(recordTypeObj != null){
                                if((recordTypeObj.name == PRMLibrary.PARTNER) || (recordTypeObj.name == PRMLibrary.EMPLOYEE)){
                                    srAttachmentWrapperObj.partnerName = recipientStatusObj.name + ' | ' + recipientStatusObj.dsfs__Recipient_Status__c ; 
                                    srAttachmentWrapperObj.partnerEmail = tempEmailId;
                                    srAttachmentWrapperObj.partnerStatus = recipientStatusObj.dsfs__Recipient_Status__c;                                    

                                }else if(recordTypeObj.name == 'Residential'){
                                    if(recipientStatusObj.dsfs__DocuSign_Routing_Order__c == 1){
                                        srAttachmentWrapperObj.primaryCustomerName = recipientStatusObj.name + ' | ' + recipientStatusObj.dsfs__Recipient_Status__c;
                                        srAttachmentWrapperObj.primaryCustomerEmail = tempEmailId;                                  
                                    }if(recipientStatusObj.dsfs__DocuSign_Routing_Order__c == 2){
                                        srAttachmentWrapperObj.secondaryCustomerName = recipientStatusObj.name + ' | ' + recipientStatusObj.dsfs__Recipient_Status__c;
                                        srAttachmentWrapperObj.secondaryCustomerEmail = tempEmailId;                    
                                    }
                                }
                                if(recipientStatusObj.dsfs__Recipient_Status__c != EDPUtil.COMPLETED){
                                    srAttachmentWrapperObj.readyForSubmission = false;
                                }                           
                            }                           
                        }
                    }
                }else{
                    srAttachmentWrapperObj.readyForSubmission = false;
                }
                srAttachments.add(srAttachmentWrapperObj);
            }
        }
        
        for(SRAttachmentWrapper srAttchmentWrapperObj: tempSRAttachmentWrapperList){
            srAttachments.add(srAttchmentWrapperObj);
        }
    }

    public SRAttachmentRelatedList(){
        proposalprefix = Schema.SObjectType.Proposal__c.getKeyPrefix();
        scprefix = Schema.SObjectType.ServiceContract.getKeyPrefix();  
        displayMasterDocuments = false;
        isEDPProfile = false;
        baseURL = EDPUtil.getBaseURL();
        User userObj = PRMContactUtil.getLoginUser();
        if(userObj != null && userObj.contactId != null){
            isPartnerUser = true;
        }
        checkUserProfile();
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
                System.debug('srAttachmentObj.proposal__C: ' + srAttachmentObj.proposal__C);
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

        Set<String> proposalStagesAllowedForVoid = new Set<String>();
        Set<String> proposalStagesNotAllowedForVoid = new Set<String>();
        Set<String> proposalStagesForConditionalVoid = new Set<String>();
        
        proposalStagesNotAllowedForVoid.add(EDPUtil.REPLACED_BY);
        proposalStagesNotAllowedForVoid.add(EDPUtil.WITH_DRAWN);
        proposalStagesNotAllowedForVoid.add(EDPUtil.SR_OPS_APPROVED);
        proposalStagesNotAllowedForVoid.add(EDPUtil.SR_DECLINED);
        proposalStagesNotAllowedForVoid.add(EDPUtil.EXPIRED);
        
        proposalStagesAllowedForVoid.add(EDPUtil.CREATED);
        proposalStagesAllowedForVoid.add(EDPUtil.ON_HOLD);
        proposalStagesAllowedForVoid.add(EDPUtil.PENDING);
        proposalStagesAllowedForVoid.add(EDPUtil.READY_FOR_SUBMISSION);

        proposalStagesForConditionalVoid.add(EDPUtil.SUBMITTED);
        proposalStagesForConditionalVoid.add(EDPUtil.SR_OPS_RECEIVED);
        proposalStagesForConditionalVoid.add(EDPUtil.SR_OPS_REVIEWED);
        proposalStagesForConditionalVoid.add(EDPUtil.CREDIT_REVIEW);
        proposalStagesForConditionalVoid.add(EDPUtil.CREDIT_APPROVED);
        proposalStagesForConditionalVoid.add(EDPUtil.SR_SIGNOFF_REVIEW);
        proposalStagesForConditionalVoid.add(EDPUtil.PENDING_TASK_COMPLETED);
        Set<String> modes = new Set<String>();
        modes.add(EDPUtil.READ);
        modes.add(EDPUtil.EDIT);
                    
        User userObj = PRMContactUtil.getLoginUser();
        if(srAttachmentObj.proposal__r.stage__c != null && srAttachmentObj.proposal__r.stage__c != '' 
            && userObj != null && userObj.contactId != null){
            System.debug('srAttachmentObj.proposal__r.stage__c: ' + srAttachmentObj.proposal__r.stage__c);
            if(proposalStagesForConditionalVoid.contains(srAttachmentObj.proposal__r.stage__c)){
                Map<String, Document_Classification__c> documentClassificationMap;
                documentClassificationMap = EDPDocumentSettings.getDocumentClassificationByCategroy(null, 
                                                                                                    EDPDocumentSettings.MANDATORY_REQUIREMENTS,
                                                                                                    modes, srAttachmentObj.proposal__r.Sales_Partner__c, 
                                                                                                    srAttachmentObj.proposal__r.Install_Partner__c);
                Document_Classification__c documentClassificationObj = documentClassificationMap.get(srAttachmentObj.Document_Type_Name__c);
                
                System.debug('documentClassificationObj: ' + documentClassificationObj);
                Partner_Document_Relationship__c ptrDocRelObj;
                if(documentClassificationObj != null && documentClassificationObj.Partner_Document_Relationships__r != null 
                    && documentClassificationObj.Partner_Document_Relationships__r.size() > 0){
                    ptrDocRelObj = documentClassificationObj.Partner_Document_Relationships__r[0];
                }
                System.debug('ptrDocRelObj: ' + ptrDocRelObj);
                if(ptrDocRelObj != null && ptrDocRelObj.Mandatory_Document__c == true){
                    String errorMessage = 'The proposal is under review and eSign requests can\'t be voided at this time';
                    Exception expObj = new BaseException(errorMessage);
                    expObj.setMessage(errorMessage);
                    ApexPages.addMessages(expObj);
                    return null;                    
                }
            }else if(proposalStagesNotAllowedForVoid.contains(srAttachmentObj.proposal__r.stage__c) || 
                !proposalStagesAllowedForVoid.contains(srAttachmentObj.proposal__r.stage__c)){
                String errorMessage = 'Invalid proposal stage to void this document';
                Exception expObj = new BaseException(errorMessage);
                expObj.setMessage(errorMessage);
                ApexPages.addMessages(expObj);
                return null;                
            } 
        }
        String result = '';
        SRAttachmentVoidESignController voidControllerObj = new SRAttachmentVoidESignController();
        voidControllerObj.documentType = srAttachmentObj.Document_Type_Name__c;
        voidControllerObj.voidReason = 'Voided by Sunrun';
        voidControllerObj.voidDocuSignRequest(); 
        if(apexpages.getMessages().size() > 0){
            return null;
        }
        
        System.debug('srAttachment.proposal__r: ' + srAttachmentObj.proposal__r);
        System.debug('srAttachment.Document_Type_Name__c: ' + srAttachmentObj.Document_Type_Name__c);
        Proposal__c proposalObj = srAttachmentObj.proposal__r;
        if(ProposalUtil.canUpdateProposalSignedStatus(proposalObj, srAttachmentObj.Document_Type_Name__c) == true){
            proposalObj.signed__c = false;
            update  proposalObj;
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
            
            if(relatedObjectIdStr.startsWith(proposalprefix)){
                tempProposalObj = [Select Id, name, Change_Order_Information__c, Signed__c, Proposal_Source__c, Install_Partner__c, Sales_Partner__c from Proposal__C where Id =:tempSRAttachmentObj.Proposal__c];
            }
            
            Contact contactObj = PRMContactUtil.getLoginUserAccountAndContact();
            Boolean isPartnerContact = PRMContactUtil.isPartnerContact(contactObj);
            Set<String> modes = new Set<String>();
            modes.add(EDPUtil.READ);
            modes.add(EDPUtil.EDIT);
            if(tempProposalObj != null){        
                Map<String, Document_Classification__c> documentClassificationMap;
                documentClassificationMap = EDPDocumentSettings.getDocumentClassificationByCategroy(null,EDPDocumentSettings.MANDATORY_REQUIREMENTS,modes, tempProposalObj.Sales_Partner__c, tempProposalObj.Install_Partner__c);
                if(isPartnerContact){
                    if(proposalStagesNotAllowedForDelete.contains(tempSRAttachmentObj.proposal__r.stage__c)){
                        String errorMessage = 'Invalid proposal stage to delete the documents';
                        Exception expObj = new BaseException(errorMessage);
                        expObj.setMessage(errorMessage);
                        ApexPages.addMessages(expObj);
                        return null;                
                    }
                }           
                
                Document_Classification__c documentClassificationObj;
                for(SR_Attachment__c srAttachmentObj : selectedSRAttachments.values()){
                    documentClassificationObj = documentClassificationMap.get(srAttachmentObj.Document_Type_Name__c);
                    
                    if((srAttachmentObj.Envelop_Id__c != null && srAttachmentObj.Envelop_Id__c != '') 
                        && (srAttachmentObj.DocuSign_Status__c != null && srAttachmentObj.DocuSign_Status__c != '' 
                            && srAttachmentObj.DocuSign_Status__c != EDPUtil.VOIDED
                            && srAttachmentObj.DocuSign_Status__c != EDPUtil.COMPLETED)){
                            String errorMessage = 'eSign request is under progress for one OR more of the selected documents and they can\'t be deleted. \n Please modify your selection and resubmit the request.';
                            Exception expObj = new BaseException(errorMessage);
                            expObj.setMessage(errorMessage);
                            ApexPages.addMessages(expObj);
                            return null;
                    }
                    if(proposalStagesForConditionalDelete.contains(srAttachmentObj.proposal__r.stage__c)){
                        Partner_Document_Relationship__c ptrDocRelObj;
                        
                        if(documentClassificationObj != null && documentClassificationObj.Partner_Document_Relationships__r != null 
                            && documentClassificationObj.Partner_Document_Relationships__r.size() > 0){
                            ptrDocRelObj = documentClassificationObj.Partner_Document_Relationships__r[0];
                        }
                        
                        if(isPartnerContact){
                            if(srAttachmentObj.DocuSign_Status__c == EDPUtil.COMPLETED){
                                String errorMessage = CustomErrorMessages.CONTACT_SUNRUN_TO_DELETE_ESIGNED_DOCS;
                                Exception expObj = new BaseException(errorMessage);
                                expObj.setMessage(errorMessage);
                                ApexPages.addMessages(expObj);
                                return null;                            
                            }
    
                            if(ptrDocRelObj != null && !excludedProposalStages.contains(srAttachmentObj.proposal__r.stage__c) && 
                                (ptrDocRelObj.Mandatory_Document__c == true || documentClassificationObj.Allow_To_Over_Write__c != true)){
                                String errorMessage = 'The proposal is under review and one OR more of the selected documents can\'t be deleted. \n Please modify your selection and resubmit the request.';
                                Exception expObj = new BaseException(errorMessage);
                                expObj.setMessage(errorMessage);
                                ApexPages.addMessages(expObj);
                                return null;                            
                            }
                        }
                        
                        if(ProposalUtil.canUpdateProposalSignedStatus(tempProposalObj, srAttachmentObj.Document_Type_Name__c) == true){
                            resetSignedStatus = true;
                            tempProposalObj.signed__c = false;                          
                        }

                        if((documentClassificationObj != null && documentClassificationObj.Allow_To_Over_Write__c == true)
                            && (srAttachmentObj.Envelop_Id__c == null || srAttachmentObj.Envelop_Id__c == '' || 
                                srAttachmentObj.DocuSign_Status__c == null && srAttachmentObj.DocuSign_Status__c == '' 
                                || srAttachmentObj.DocuSign_Status__c == EDPUtil.VOIDED
                                || srAttachmentObj.DocuSign_Status__c == EDPUtil.COMPLETED)){
                            continue;
                        }
                    }               
                }
            }
            update selectedSRAttachments.values();   
            if(resetSignedStatus){
                update tempProposalObj;
            }
        }
        
        String url = '/apex/';
        if(displayGeneralDocuments == true){
            
            if(relatedObjectIdStr.startsWith(scprefix)){
                url += 'ServiceContract_GeneralDocuments' ;
            }else{
                url += 'Proposal_GeneralDocuments' ;
            }
        }else if(displaySignedDocuments == true){
            url += 'Proposal_eSignDocuments' ;
        }else{
            url += 'Proposal_SRAttachmentListView';
        }
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