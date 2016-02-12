/****************************************************************************
Author  : ZCloudInc.net
Date    : July 2012
Description: This class contains all the common methods required for EDP.
*****************************************************************************/
public class EDPUtil {
    
    public static string SR_FINANCE = Label.SR_Finance_Profile;
    public static string SR_OPS = Label.SR_Operations_Profile;
    public static string USER_NAME_SR_OPS = Label.SR_Operations_User;
    public static string USER_NAME_SR_FINANCE = Label.SR_Finance_User;
    public static string USER_NAME_TEST = Label.DefaultTestUser;
    
    public static string CUSTOMER = 'Customer';
    public static string PARTNER = 'Partner';
    
    public static string VOIDED = 'Voided';
    public static string SR_OPS_APPROVED = 'SR Approved';
    public static string SR_OPS_RECEIVED = 'SR Ops Received';
    public static string SR_OPS_REVIEWED = 'SR Ops Reviewed';
    public static string CREDIT_APPROVED = 'SR Credit Approved';
    public static string SR_SIGNOFF_REVIEW = 'SR Signoff Review';
    public static string CREDIT_REVIEW = 'SR Credit Review';
    public static string SUBMITTED = 'Submitted';
    public static string PENDING = 'Pending';
    public static string CREATED = 'Created';
    public static string CANCELLED = 'Cancelled';
    public static string DEAL_CANCELLED = 'Deal Cancelled';
    public static string FINAL_INPUTS_HYBRID_ID = 'FINAL INPUTS HYBRID ID';
    public static string REPLACED_BY = 'Replaced';
    public static string ON_HOLD = 'On Hold';
    public static string READY_FOR_SUBMISSION = 'Ready for Submission';
    public static string COMPLETED = 'Completed';
    public static string SFDC = 'SFDC';
    public static string E_SIGN = 'eSign';
    public static string PROPOSAL_TOOL_SOURCE = 'Proposal Tool';
    public static string MANUAL_UPLOAD_SOURCE = 'Manual Upload';
    public static string SR_COUNTERSIGNED = 'SR Countersigned';
    public static string SIGNED = 'Signed';
    public static string WET_SIGNED = 'Wet Signed';
    public static string UNSIGNED = 'Unsigned';
    public static string NA = 'Not Applicable';
    public static string READ = 'Read';
    public static string EDIT = 'Edit';
    public static string NONE = 'None';
    public static string OCR_ROLE_CREDIT = 'Credit Contact';
    public static string HEAD_QUARTERS = 'Headquarters';
    public static string HEADQUARTERS = 'Headquarters';
    public static string FRANCHISE = 'Franchise';
    public static string UTILITY_BILL = 'Utility Bill';
    public static string LIVING_SPACE = 'Living Space Square Footage';

    public static string FULL_SERVICE = 'Full Service';
    public static string SALES = 'Sales';
    public static string SUNRUN_SALES = 'Sunrun Sales';
    public static string INSTALL = 'Install';
    public static string SUCCESS = 'Success';
    public static string FAILURE = 'Failure';
    public static string PROPOSAL_ACTIVATE = 'Activate';

    public static string CREDIT_MEMO = 'Credit Memo';
    public static string CUSTOMER_AGREEMENT = 'Customer Agreement';
    public static string CONDITIONAL_APPROVAL = 'Conditional Approval';
    public static string ELECTORNIC_DEAL_PROCESSING = 'Electronic Deal Processing';
    public static string EPC = 'EPC';
    public static string REBATE_RESERVATION = 'Rebate Reservation';
    public static string CHANGE_ORDER_COVER_SHEET = 'Customer Change Order Cover Sheet';
    public static string CONTACT_APPROVAL_FORM_75K = 'Contact Approval Form for Deals > 75k';
    public static string CUSTOMER_ORIG_ADDENDUM = 'Customer Origination Addendum';
    public static string EMPLOYEE_VERIFICATION_FORM = 'Employee Verification form';
    public static string VERIFICATION_LETTER = 'Verification Letter';
    public static string OTHER = 'Other';
    public static string HOME_OWNER = 'Home Owner';
    public static string CUSTOMER_CREDIT_APPROVED = 'Credit Approved';
    public static string CREDIT_STATUS_APPROVED = 'Approved';
    public static string INACTIVE = 'Inactive';
    public static string OPPTY_CLOSED_WON_ERROR = 'Opportunity should have an approved proposal for \'Closed/Won\' stage';
    public static string HYBRID_CHANGEORDER_ERROR = 'The Final Inputs Hybrid ID does not correspond with the original proposal. Submit the Final Inputs Hybrid ID on proposal ';
    public static string HYBRID_CHANGEORDER_ERROR_NULL_PARENT = 'The Final Inputs Hybrid ID should have a parent Id';

    public static string SENT = 'Sent';
    public static string IN_PROGRESS = 'In Progress'; 
    public static string SR_OPS_APPROVED_ERROR = 'Error Msg';
    public static string IN_FLIGHT_ERROR = ' esignature for this Document is In Progress. You cannot Upalod at this state.';
    public static string EXISTING_ERROR = ' The Proposal is Under Review, you cannot Overwrite an existing document.';
    public static string SIGNED_EXISTING_ERROR = ' Signed Document is Existing. To Upload , Kindly Delete the Exisitng Document';
    public static string MANDATORY_ERROR = 'The Proposal is Under Review, you cannot Overwrite a Mandatory Document at this stage';
    public static string DELIVERED = 'Delivered';
    public static string NOT_SENT = 'Not Sent';
    public static string RESOLVED = 'Resolved';
    public static string CLOSED = 'Closed';
    public static string SUNRUN_EMAIL_EXTENSION = Label.Sunrun_Email_Domain ;

    public static string WITH_DRAWN = 'Withdrawn';
    public static string SR_DECLINED = 'SR Declined';
    public static string PENDING_TASK_COMPLETED = 'Pending Task Completed';
    public static String LARGE_SYSTEM_CONTRACT_REQUEST = 'Large System Contract Approval Request';
    public static String CUSTOMER_CHANGEORDER_COVER_SHEET = 'Customer Change Order Cover Sheet';
    public static String EPBB = 'EPBB';
    public static String LARGE_SYSTEM_NTP_REQUEST = 'Large System NTP Request';
    public static string EXPIRED = 'Expired';
    public static string REBATE_FORM='Rebate Form';
    public static string NEM_FORM='NEM Agreement';

    public static Set<Id> pendingTaskProposalIds = new Set<Id>();
    static final public String ProposalPrefix = Schema.SObjectType.Proposal__c.getKeyPrefix(); 

    public static Map<Id, Profile> profileMap;
    public static Map<Id, Profile> getProfiles(Set<String> profileNames){
        if(profileMap == null || profileMap.size() <= 0){
            profileMap = new Map<Id, Profile>();
            for(Profile profileObj : [Select Id, name from Profile where name in :profileNames]){
                profileMap.put(profileObj.Id, profileObj);
            }
        }
        return profileMap;
    }
    
    private static Map<Id, User> staticUserMap;
    public static Map<Id, User> getUserdetails(Set<Id> userIds){
        Boolean runQuery = false;
        if(staticUserMap != null && staticUserMap.size() > 0){
            for(Id userId : userIds){
                if(!staticUserMap.containsKey(userId)){
                    runQuery = true;
                    break;
                }
            }           
        }
        if(staticUserMap == null || runQuery == true){
            staticUserMap = new Map<Id, User>();
            for(User userObj : [Select Id, name, Proposal_Approval_Limit__c, 
                                profileId from User where Id in :userIds]){
                staticUserMap.put(userObj.Id, userObj);
            }           
        }
        return staticUserMap;
    }

    public static List<User> srUserList;
    public static List<User> getSRUserDetails(){
        if(srUserList == null || srUserList.size() <=0){
            Set<String> userNames = new Set<String>();
            userNames.add(EDPUtil.USER_NAME_SR_OPS);
            userNames.add(EDPUtil.USER_NAME_SR_FINANCE);
            userNames.add(EDPUtil.USER_NAME_TEST);
            User defaultOpsUser = null;
            User defaultFinanceUser = null;
            srUserList = EDPUtil.getUserDetails(userNames); 
        }   
        return srUserList;
    }

    public static User loginUser;
    public static User getLoginUser(){
        if(loginUser == null){
            Id currentLoginUserId = UserInfo.getUserId();
            Set<Id> loginUserIds = new Set<Id>();
            loginUserIds.add(currentLoginUserId);           
            Map<Id, User> loginUsers = EDPUtil.getUserDetails(loginUserIds);
            loginUser = loginUsers.get(currentLoginUserId);         
        }
        return loginUser;
    }

    public static List<User> getUserDetails(Set<String> nameSet){
        List<User> userList = new List<User>();
        userList = [Select Id, name from User where name in :nameSet];
        return userList;
    }

    public static Map<Id, Proposal__C> getProposals(Set<Id> proposalIds){
        Map<Id, Proposal__C> proposalMap = new Map<Id, Proposal__C>();
        for(Proposal__C proposalObj : [Select Id, name, Assigne__c,Agreement_type__c 
                                       from Proposal__C 
                                        where Id in :proposalIds and Assigne__c != null]){
            proposalMap.put(proposalObj.Id, proposalObj);
        }
        //System.debug('proposalMap: ' + proposalMap);
        return proposalMap;
    }


    public static Map<Id, Opportunity> getOpportunities(Set<Id> opportunityIds){
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        for(Opportunity opportunityObj : [Select Id, name, OwnerId,Credit_Status__c from Opportunity 
                                        where Id in :opportunityIds]){
            opportunityMap.put(opportunityObj.Id, opportunityObj);
        }
        //System.debug('proposalMap: ' + opportunityMap);
        return opportunityMap;
    }
    
    public static Map<Id, RecordType> getRecordTypes(List<String> sObjectTypes){
        Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>();
        for(RecordType recordTypeoBJ : [select Id, Name, SobjectType from RecordType 
                                        where SObjectType = :sObjectTypes 
                                        and isactive = true]){
            recordTypeMap.put(recordTypeoBJ.Id, recordTypeoBJ);                     
        }
        return recordTypeMap;
    }
    public static String generateVerificationToken() {
        String randomString = formatAsUtcIsoDateTime(DateTime.now()) + getRandomLongString();
        String key = EncodingUtil.base64Encode(Crypto.generateDigest('SHA-256', Blob.valueOf(randomString)));
        String urlSafeKey = Encodingutil.urlEncode(key, 'UTF-8').replaceAll('%','_');
        
        if (urlSafeKey.length() > 255) {
            urlSafeKey =  urlSafeKey.substring(0, 254); 
        }
        
        return urlSafeKey;
    }    
    
    public static String getRandomLongString() {
        return String.valueOf(Math.abs(Crypto.getRandomLong()));
    }
    
    public static String formatAsUtcIsoDateTime(DateTime dateTimeVal) {
        if (dateTimeVal == null) {
            return null;
        }
        return dateTimeVal.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    }

    public static void cancelProposals(Set<Id> opportunityIds){
        User defaultOpsUser = null;
        User defaultFinanceUser = null;
        Set<String> userNames = new Set<String>();
        userNames.add(USER_NAME_SR_OPS);
        userNames.add(USER_NAME_SR_FINANCE);
        userNames.add(USER_NAME_TEST);
        List<User> userList = EDPUtil.getUserDetails(userNames);
        for(User userObj : userList){
            
            if(defaultOpsUser == null && userObj.name == USER_NAME_TEST){
                defaultOpsUser = userObj;
            }
            if(defaultFinanceUser == null && userObj.name == USER_NAME_TEST){
                defaultFinanceUser = userObj;
            }
            
            if(userObj.name == USER_NAME_SR_OPS){
                defaultOpsUser = userObj;
            }           
            else if(userObj.name == USER_NAME_SR_FINANCE){
                defaultFinanceUser = userObj;
            }
        }   

        Id srOpsOwnerId;
        Id defaultSROpsOwnerId;
        List<Task> taskList = new List<Task>();
        List<Proposal__C> proposalList = new List<Proposal__C>();
        Map<Id, Generation_Assets__c> genAssetMap = new Map<Id, Generation_Assets__c>();
        Generation_Assets__c genAssetObj;
        for(Proposal__C propsalObj: [Select Id, Generation_Asset__r.Id, Generation_Asset__r.Asset_Status__c, Assigne__c, 
                                    Opportunity__c, name, stage__C from Proposal__C 
                                    where Opportunity__c in :opportunityIds
                                    and Stage__c != :CANCELLED]){
            if(propsalObj.Stage__c == SR_OPS_APPROVED){
                srOpsOwnerId = (propsalObj.assigne__C != null) ? propsalObj.assigne__C : defaultOpsUser.Id;
                propsalObj.assigne__C = srOpsOwnerId;           
            }
            
            if(propsalObj.Generation_Asset__r != null 
            && propsalObj.Generation_Asset__r.Asset_Status__c != 'Deal Cancelled' 
            && !genAssetMap.containsKey(propsalObj.Generation_Asset__r.Id)){
                genAssetObj = new Generation_Assets__c(Id=propsalObj.Generation_Asset__r.Id);
                genAssetObj.Asset_Status__c = DEAL_CANCELLED;
                genAssetMap.put(genAssetObj.Id, genAssetObj);
            }
            
            propsalObj.Stage__c = CANCELLED;
            proposalList.add(propsalObj);
        }
        
        if(genAssetMap.size() > 0){
            update genAssetMap.values();
        }
        
        if(proposalList.size() > 0){
            update proposalList;
        }
    }

    public static Map<Id, Opportunity> getOppsWithProposals(Set<Id> opportunityIds){
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        for(Opportunity oppObj : [Select Id, 
                                    (Select Id, Change_Order_ID__c, Change_Order__c, Stage__c from Proposals__r 
                                        where Stage__c != 'Created' 
                                            AND Stage__c != 'Cancelled' 
                                            AND Stage__c != :INACTIVE) 
                                    from Opportunity where Id in :opportunityIds]){
            opportunityMap.put(oppObj.Id, oppObj);          
        }
        return opportunityMap;
    }

    //Following code is not in the scope of Ham Release
    public static Map<Id, RecordType> taskRecordTypes;
    public static Id getTaskEDPRecordType(){
        //Get Task record type
        if(taskRecordTypes == null || taskRecordTypes.size() <= 0){
            List<String> sObjectTypes = new List<String>();
            sObjectTypes.add('Task');
            taskRecordTypes = EDPUtil.getRecordTypes(sObjectTypes);
        }

        Id electronicDealProcessing = null;
        for(RecordType recordTypeObj : taskRecordTypes.values()){
            if(recordTypeObj.name == ELECTORNIC_DEAL_PROCESSING){
                electronicDealProcessing = recordTypeObj.Id;
                break;
            }       
        }   
        return  electronicDealProcessing;
    }

    public static String processWelcomeEmailRequestForPartners(String proposalIdVal){

        try{

            String errorMessage = '';
            List<Proposal__c> prposalList = [Select Id, name, Stage__c, Generation_Asset__c,Sales_Partner__c, Install_Partner__c,Change_Order__c,
                                                Sales_Partner_Name__c, Install_Partner_Name__c, submitted_by__c, Welcome_Email_Sent__c,Original_Proposal_ID__c,
                                                Change_Order_Type__c, Opportunity__c 
                                                from Proposal__c where Id =:proposalIdVal and submitted_by__c != null];
            String partnerName1 = 'Verengo';
            String partnerName2 = 'Sunrun';
            
            if(prposalList == null || prposalList.size() <=0){
                errorMessage = CustomErrorMessages.INVALID_PROPOSAL;
                return  errorMessage;
            }       
            Map<Id, Id> proposalOpportunityMap = new Map<Id, Id>();
            Map<Id, Proposal__c> proposalMap = new Map<Id, Proposal__c>();

            Proposal__c parentProposal;
            Set<Id> originalProposalIds = new Set<Id>();
            for(Proposal__c proposalObj: prposalList){
                System.debug('Test proposalObj.Stage__c: ' + proposalObj.Stage__c);
                //if((proposalObj.Sales_Partner_Name__c != null && proposalObj.Sales_Partner_Name__c != '' && proposalObj.Sales_Partner_Name__c.contains(partnerName1))){
                //  errorMessage = CustomErrorMessages.WELCOME_EMAIL_NOT_SUPPORTED;
                //  return  errorMessage;               
                //}else 
                
                if(proposalObj.Stage__c == EDPUtil.SR_OPS_APPROVED){
                    if(proposalObj.Opportunity__c != null){
                        proposalOpportunityMap.put(proposalObj.Id, proposalObj.Opportunity__c);
                        proposalMap.put(proposalObj.Id, proposalObj);
                    }
                    if(proposalObj.Original_Proposal_ID__c != null){
                        originalProposalIds.add(proposalObj.Original_Proposal_ID__c);
                    }       
                }else if(proposalObj.Stage__c != EDPUtil.SR_OPS_APPROVED){
                    errorMessage = CustomErrorMessages.WELCOME_EMAILS_FOR_APPROVED_PROPOSALS;
                    return  errorMessage;               
                }
            }

            Id templateId;
            Id contactId;
            Generation_Assets__c genAssetObj;
            OpportunityContactRole roleObj;
            String tempMessage = '';
            List<Proposal__c> modifiedProposals = new List<Proposal__c>();
            List<String> docuSignStatusList = new List<String>();
            docuSignStatusList.add(EDPUtil.COMPLETED);
            docuSignStatusList.add(EDPUtil.WET_SIGNED);
            OrgWideEmailAddress oweaObj = getOrgWideEmailAddress(Label.Sunrun_Operations_Email);
            for(Id proposalId : proposalOpportunityMap.keySet()){
                Proposal__C proposalObj = proposalMap.get(proposalId);
                Id submittedUserId ;
                if(proposalObj.submitted_by__c == null){
                    errorMessage = CustomErrorMessages.MISSING_WELCOME_PARTNER_INFO;
                    return  errorMessage;
                }

                Map<String, Document_Classification__c> welcomeEmailDocumentTypesMap;
                Set<String> welcomeEmailDocumentTypes = new Set<String>();
                welcomeEmailDocumentTypesMap = EDPDocumentSettings.getWelcomeDocumentTypes(PARTNER, proposalObj.submitted_by__c, 
                                                                                            proposalObj.Sales_Partner__c, proposalObj.install_Partner__c);
                for(Document_Classification__c docClassificationObj : welcomeEmailDocumentTypesMap.values()){
                    if(docClassificationObj != null && (docClassificationObj.Partner_Document_Relationships__r != null 
                        && docClassificationObj.Partner_Document_Relationships__r.size() > 0 
                        && (docClassificationObj.Partner_Document_Relationships__r[0].mode__c == EDPUtil.EDIT || 
                            docClassificationObj.Partner_Document_Relationships__r[0].mode__c == EDPUtil.READ))){
                        
                        welcomeEmailDocumentTypes.add(docClassificationObj.Document_Name__c);
                    }
                }

                Map<Id, List<Messaging.EmailFileAttachment>> proposalAttachments = new Map<Id, List<Messaging.EmailFileAttachment>>();
            
                Set<Id> proposalsSet = proposalOpportunityMap.keyset();
                String edpCompleted = EDPUtil.COMPLETED;
                String documentSource = EDPUtil.PROPOSAL_TOOL_SOURCE;
                String soqlStr ;
                soqlStr = SRAttachmentManager.getSRAttachmentSOQL();
                soqlStr += '  where proposal__c in :proposalsSet ' ;
                soqlStr += '  AND Document_Type_Name__c = :welcomeEmailDocumentTypes ' ;
                soqlStr += '  AND document_source__c != :documentSource ' ;
                soqlStr += '  AND active__c = true AND DocuSign_Status__c in :docuSignStatusList ' ;
                
                Map<Id, SR_Attachment__c> tempSRAttachmentMap = new Map<Id, SR_Attachment__c>();
                for(SR_Attachment__c attachmentObj : Database.query(soqlStr)){
                    tempSRAttachmentMap.put(attachmentObj.Id, attachmentObj);
                }
                Boolean documentSizeException = false;  
                Integer fileSize = 0;
                Integer maxFileSize = 1024 * 5 * 1000;          
                for(SR_Attachment__c attachmentObj : Database.query(soqlStr)){                                              
                    Messaging.EmailFileAttachment emailAttachment ;
                    EDPUtil.WelcomeDocS3Status statusObj = new EDPUtil.WelcomeDocS3Status();
                    emailAttachment = SRAttachmentManager.getEmailAttachments(attachmentObj, statusObj);
                    if(emailAttachment == null){
                        proposalAttachments = new Map<Id, List<Messaging.EmailFileAttachment>>();
                        documentSizeException = true;
                        break;
                    }
                    if(emailAttachment.getBody() != null && emailAttachment.getBody().size() > 0){
                        fileSize += emailAttachment.getBody().size();
                        if(maxFileSize < fileSize){
                            proposalAttachments = new Map<Id, List<Messaging.EmailFileAttachment>>();
                            documentSizeException = true;
                            break;                          
                        }
                    }
                    List<Messaging.EmailFileAttachment> srAttachments = proposalAttachments.containskey(attachmentObj.Proposal__C) ? 
                                                                proposalAttachments.get(attachmentObj.Proposal__C) : new List<Messaging.EmailFileAttachment>(); 
                    srAttachments.add(emailAttachment);
                    proposalAttachments.put(attachmentObj.Proposal__C, srAttachments);      
                }
                
                String emailId = '';

                String recContactEmail = Label.REC_Contact_Email;
                List<User> userObjectList = [Select Id, contactId, email from user where Id =:proposalObj.submitted_by__c and contactId != null];
                if(userObjectList == null || userObjectList.isEmpty()){
                    list<Contact> tempContactList = [Select Id, Name, email, Sunrun_User__c, Sunrun_User__r.email from Contact where Sunrun_User__c =:proposalObj.submitted_by__c];
                    if(tempContactList != null && !tempContactList.isEmpty()){
                        submittedUserId = tempContactList[0].Id;
                        emailId = tempContactList[0].Sunrun_User__r.email;
                    }
                }else{
                    submittedUserId = userObjectList[0].contactId;
                    emailId = userObjectList[0].email;
                }
                
                List<String> recContactEmailList = new List<String>();
                if(proposalObj.Sales_Partner__c != null && 
                    proposalObj.Install_Partner__c != null && 
                    proposalObj.Sales_Partner__c != proposalObj.Install_Partner__c && 
                    proposalObj.Install_Partner_Name__c.contains(partnerName2)){
                    recContactEmailList.add(recContactEmail);
                }

                if(documentSizeException == false){
                    templateId = EDPUtil.getEmailTemplateId('Proposal - Partner Welcome Email 1');
                    tempMessage = CustomErrorMessages.WELCOME_EMAIL_SENT + ' ' + emailId;                       
                }else{
                    templateId = EDPUtil.getEmailTemplateId('Proposal - Partner Welcome Email 2');
                    tempMessage = CustomErrorMessages.WELCOME_EMAIL_SENT + ' ' + emailId;                   
                }
                
                if(templateId == null){
                    errorMessage = CustomErrorMessages.MISSING_WELCOME_EMAIL_TEMPLATE;  
                    return  errorMessage;
                }
                
                List<Messaging.EmailFileAttachment> srAttachments = proposalAttachments.get(proposalId);
                EDPUtil.sendCustomerWelcomeEmail(templateId, submittedUserId, proposalId, srAttachments, recContactEmailList, oweaObj);
                errorMessage = tempMessage;
            }
            if(modifiedProposals.size() > 0){
                update modifiedProposals;
            }
            return  errorMessage;
            
        }catch(Exception e){
            System.debug(e.getMessage());
            return CustomErrorMessages.UNABLE_TO_SEND_WELCOME_EMAIL;
        }
        return '';
    }

    public static String processWelcomeEmailRequest(String proposalIdVal){

        try{

            String errorMessage = '';
            List<Proposal__c> prposalList = [Select Id,agreement_type__c, name, Stage__c, Generation_Asset__c,Sales_Partner__c, Install_Partner__c,Change_Order__c,
                                                Original_Proposal_Welcome_Email_Sent__c, Sales_Partner_Name__c, Install_Partner_Name__c, submitted_by__c, 
                                                Welcome_Email_Sent__c, Original_Proposal_ID__c,Revised_Proposal__c, Change_Order_Type__c, Opportunity__c, Url_For_Payment__c 
                                                from Proposal__c where Id =:proposalIdVal];
            String partnerName = 'Verengo';
            if(prposalList == null || prposalList.size() <=0){
                errorMessage = CustomErrorMessages.INVALID_PROPOSAL;
                return  errorMessage;
            }else if(prposalList != null && prposalList.size() > 0){
                if((prposalList[0].name.indexOf('H') == 0 ) &&  (prposalList[0].Change_Order__c == true) && 
                    prposalList[0].Original_Proposal_Welcome_Email_Sent__c != null &&
                        prposalList[0].Original_Proposal_Welcome_Email_Sent__c == true){
                    errorMessage = CustomErrorMessages.H_TYPE_PROPOSAL_NOT_SUPPORTED;
                    return  errorMessage;                   
                }
            }       
            Map<Id, Id> proposalOpportunityMap = new Map<Id, Id>();
            Map<Id, Proposal__c> proposalMap = new Map<Id, Proposal__c>();
            Map<Id, Id> proposalGenAssetMap = new Map<Id, Id>();
            

            Proposal__c parentProposal;
            Set<Id> originalProposalIds = new Set<Id>();
            for(Proposal__c proposalObj: prposalList){
                if((proposalObj.Sales_Partner_Name__c != null && proposalObj.Sales_Partner_Name__c != '' && proposalObj.Sales_Partner_Name__c.contains(partnerName))){
                    errorMessage = CustomErrorMessages.WELCOME_EMAIL_NOT_SUPPORTED;
                    return  errorMessage;               
                }else if(proposalObj.Stage__c == EDPUtil.SR_OPS_APPROVED){
                    if(proposalObj.Opportunity__c != null){
                        proposalOpportunityMap.put(proposalObj.Id, proposalObj.Opportunity__c);
                        proposalMap.put(proposalObj.Id, proposalObj);
                        if(proposalObj.Generation_Asset__c != null){
                            proposalGenAssetMap.put(proposalObj.Id, proposalObj.Generation_Asset__c);
                        }
                    }
                    if(proposalObj.Original_Proposal_ID__c != null){
                        originalProposalIds.add(proposalObj.Original_Proposal_ID__c);
                    }       
                }else if(proposalObj.Stage__c != EDPUtil.SR_OPS_APPROVED){
                    errorMessage = CustomErrorMessages.WELCOME_EMAILS_FOR_APPROVED_PROPOSALS;
                    return  errorMessage;               
                }
            }
            
            Map<Id, Opportunity> OppToBeUpdated = new Map<Id, Opportunity>([Select Id, Payment_Mode__c, Payment_Request_Url__c, Payment_Request_Token__c, Payment_Request_Token_Status__c,Payment_Request_Contact_Role_Id__c from Opportunity where Id =:proposalOpportunityMap.get(proposalIdVal)]);
            
            Map<Id, Proposal__c> originalProposalMap = new Map<Id, Proposal__c>([Select Id, Welcome_Email_Sent__c from Proposal__c where Id in :originalProposalIds]);
            Map<Id, Map<Id, OpportunityContactRole>> opportunityContactMap = EDPUtil.getOpportunityRoleMap(proposalOpportunityMap.values());
            System.debug('opportunityContactMap: ' + opportunityContactMap);

            Id templateId;
            Id contactId;
            Generation_Assets__c genAssetObj;
            OpportunityContactRole roleObj;
            String tempMessage = '';
            List<Proposal__c> modifiedProposals = new List<Proposal__c>();
            OrgWideEmailAddress oweaObj = getOrgWideEmailAddress(Label.Sunrun_Customer_Care_Email);
            for(Id proposalId : proposalOpportunityMap.keySet()){
                Proposal__C proposalObj = proposalMap.get(proposalId);
                Map<String, Document_Classification__c> welcomeEmailDocumentTypesMap;
                welcomeEmailDocumentTypesMap = EDPDocumentSettings.getWelcomeDocumentTypes(proposalObj.Sales_Partner__c, proposalObj.Install_Partner__c);
                Map<Id, List<Messaging.EmailFileAttachment>> proposalAttachments = new Map<Id, List<Messaging.EmailFileAttachment>>();
            
                Set<Id> proposalsSet = proposalOpportunityMap.keyset();
                String documentSource = EDPUtil.PROPOSAL_TOOL_SOURCE;
                Set<String> welcomeEmailDocumentTypes = welcomeEmailDocumentTypesMap.keySet();
                System.debug('welcomeEmailDocumentTypes: ' + welcomeEmailDocumentTypes);
                String soqlStr ;
                soqlStr = SRAttachmentManager.getSRAttachmentSOQL();
                soqlStr += '  where proposal__c in :proposalsSet ' ;
                soqlStr += '  AND Document_Type_Name__c = :welcomeEmailDocumentTypes ' ;
                soqlStr += '  AND document_source__c != :documentSource ' ;
                soqlStr += '  AND active__c = true ' ;
                
                Integer fileSize = 0;
                Integer maxFileSize = 1024 * 5 * 1000;                  
                for(SR_Attachment__c attachmentObj : Database.query(soqlStr)){                                              

                    if((proposalObj.Revised_Proposal__c == null || proposalObj.Revised_Proposal__c == false)
                        && proposalObj.Original_Proposal_ID__c != null && proposalObj.Original_Proposal_Welcome_Email_Sent__c != null &&
                        proposalObj.Original_Proposal_Welcome_Email_Sent__c == true && attachmentObj.Document_Type_Name__c == EDPUtil.CUSTOMER_AGREEMENT){  
                        continue;
                    }   

                    Messaging.EmailFileAttachment emailAttachment ;
                    EDPUtil.WelcomeDocS3Status statusObj = new EDPUtil.WelcomeDocS3Status();
                    emailAttachment = SRAttachmentManager.getEmailAttachments(attachmentObj, statusObj);
                    if(emailAttachment == null || (statusObj != null && statusObj.statusMessage!= null && statusObj.statusMessage != '') ){
                        errorMessage = CustomErrorMessages.MAXIMUM_FILE_SIZE_TO_DOWNLOAD;   
                        return  errorMessage;                           
                    }else if(emailAttachment == null){
                        errorMessage = CustomErrorMessages.MISSING_WELCOME_EMAIL_DOCS;  
                        return  errorMessage;                           
                    }
                    
                    if(emailAttachment.getBody() != null && emailAttachment.getBody().size() > 0){
                        fileSize += emailAttachment.getBody().size();
                        System.debug('fileSize: ' + fileSize);
                        if(maxFileSize < fileSize){
                            errorMessage = CustomErrorMessages.MAXIMUM_FILE_SIZE_TO_DOWNLOAD;   
                            return  errorMessage;                           
                        }
                    }                   
                    
                    List<Messaging.EmailFileAttachment> srAttachments = proposalAttachments.containskey(attachmentObj.Proposal__C) ? 
                                                                proposalAttachments.get(attachmentObj.Proposal__C) : new List<Messaging.EmailFileAttachment>(); 
                    srAttachments.add(emailAttachment);
                    proposalAttachments.put(attachmentObj.Proposal__C, srAttachments);      
                }

                if(proposalAttachments.size() == 0){
                    errorMessage = CustomErrorMessages.MISSING_WELCOME_EMAIL_DOCS;  
                    return  errorMessage;               
                }
                
                String emailId = '';
                Id primaryContactId = null;
                Id secondaryContactId = null; 
               String primaryContactLanguage='English';              
                Map<Id, OpportunityContactRole> roleMap = opportunityContactMap.get(proposalObj.Opportunity__c);
                if(roleMap != null && roleMap.size() > 0 ){
                    for(OpportunityContactRole optyContactRoleObj : roleMap.values()){
                        System.debug('optyContactRoleObj: ' + optyContactRoleObj);
                        if(optyContactRoleObj.role == 'Homeowner'){
                            primaryContactId = optyContactRoleObj.contactId;
                            emailId = optyContactRoleObj.contact.email;
                            System.debug('primaryContactId: ' + primaryContactId);
                        }else{
                            secondaryContactId = optyContactRoleObj.contactId;
                            System.debug('secondaryContactId: ' + secondaryContactId);
                            emailId = optyContactRoleObj.contact.email;
                        }
                        if(optyContactRoleObj.IsPrimary==true)
                        {
                            primaryContactLanguage= optyContactRoleObj.contact.preferred_language__c; 
                        }                               
                                    
                        if(optyContactRoleObj.role == 'Homeowner' && optyContactRoleObj.isprimary == true){
                            break;
                        }
                    }
                }
                
                primaryContactId = (primaryContactId == null) ? secondaryContactId : primaryContactId;  
                System.debug('primaryContactId: ' + primaryContactId);
                if(primaryContactId == null){
                    errorMessage = CustomErrorMessages.MISSING_WELCOME_CUSTOMER_INFO;
                    return  errorMessage;
                }

               //Adding logic to determine the email template based preferred language
                String templateName='Proposal - Welcome Email';
                if(primaryContactLanguage=='Spanish'){
                    templateName = 'Proposal - Welcome Email_SPANISH';
                    tempMessage = CustomErrorMessages.WELCOME_EMAIL_SENT + ' ' + emailId;   
                    if(proposalObj.Original_Proposal_Welcome_Email_Sent__c != null 
                        && proposalObj.Original_Proposal_Welcome_Email_Sent__c == true){
                        templateName = 'Change Orders - Welcome Email_SPANISH';
                    }
                    
                    if(OppToBeUpdated.get(proposalOpportunityMap.get(proposalId)).Payment_Mode__c != 'Recurring' && (proposalObj.Agreement_Type__c != 'Customer Owned - Full Upfront' && proposalObj.Agreement_Type__c != 'Prepaid Lease' && proposalObj.Agreement_Type__c != 'Prepaid PPA' && proposalObj.Agreement_Type__c != 'Prepaid PPA SREC')){
                        templateName = 'Proposal - Welcome Email Payment_SPANISH';
                        if(proposalObj.Original_Proposal_Welcome_Email_Sent__c != null 
                        && proposalObj.Original_Proposal_Welcome_Email_Sent__c == true){
                        templateName = 'Change Orders - Welcome Email Payment_SPANISH';
                        
                    }
                    }
                }
                else{

                    templateName = 'Proposal - Welcome Email';
                    tempMessage = CustomErrorMessages.WELCOME_EMAIL_SENT + ' ' + emailId;   
                    if(proposalObj.Original_Proposal_Welcome_Email_Sent__c != null 
                        && proposalObj.Original_Proposal_Welcome_Email_Sent__c == true){
                        templateName = 'Change Orders - Welcome Email';
                    }
                    
                    if(OppToBeUpdated.get(proposalOpportunityMap.get(proposalId)).Payment_Mode__c != 'Recurring' && (proposalObj.Agreement_Type__c != 'Customer Owned - Full Upfront' && proposalObj.Agreement_Type__c != 'Prepaid Lease' && proposalObj.Agreement_Type__c != 'Prepaid PPA' && proposalObj.Agreement_Type__c != 'Prepaid PPA SREC')){
                        templateName = 'Proposal - Welcome Email Payment';
                        if(proposalObj.Original_Proposal_Welcome_Email_Sent__c != null 
                        && proposalObj.Original_Proposal_Welcome_Email_Sent__c == true){
                        templateName = 'Change Orders - Welcome Email Payment';
                    }
                    }
                }
                    
                templateId = EDPUtil.getEmailTemplateId(templateName);
                
                
                if(templateId == null){
                    errorMessage = CustomErrorMessages.MISSING_WELCOME_EMAIL_TEMPLATE;  
                    return  errorMessage;
                }
                
                String baseUrl = Sf.settingsService.getString(Constants.RequestPaymentBaseUrl);
               
                if (!baseUrl.endsWith('/')) {
                baseUrl += '/';
                }
                String vfPage = 'CustomerOptyAutoPayment';
                String token = EDPUtil.generateVerificationToken();
                String languageCode=primaryContactLanguage=='Spanish'?'es':'en';
                 baseUrl += vfPage + '?token=' + token+'&&'+'language='+languageCode;
                system.debug('baseUrl' + baseUrl);
                Proposal__c propurl = proposalMap.get(proposalId);
                propurl.Url_For_Payment__c = baseUrl;
                update propurl;
                
                Opportunity opty = OppToBeUpdated.get(proposalOpportunityMap.get(proposalId));
                opty.Payment_Request_Url__c = baseUrl;
                opty.Payment_Request_Token__c = token;
                opty.Payment_Request_Token_Status__c = 'Valid';
                opty.Payment_Request_Contact_Role_Id__c =  opportunityContactMap.get(OppToBeUpdated.get(proposalOpportunityMap.get(proposalId)).Id).get(primaryContactId).Id;
                update opty;
        

                List<Messaging.EmailFileAttachment> srAttachments = proposalAttachments.get(proposalId);
                EDPUtil.sendCustomerWelcomeEmail(templateId, primaryContactId, proposalId, srAttachments, null, oweaObj);
                proposalObj.Welcome_Email_Sent__c = true;
                modifiedProposals.add(proposalObj);
                errorMessage = tempMessage;
            }
            if(modifiedProposals.size() > 0){
                update modifiedProposals;
            }
            return  errorMessage;

        }catch(Exception e){
            System.debug(e.getMessage());
            return CustomErrorMessages.UNABLE_TO_SEND_WELCOME_EMAIL;
        }
    }

    public static PendingTask createProposalPendingTask(Id recordTypeId, Proposal__C proposalObj){

        if(proposalObj.Submitted_By__c == null)
            return null;
            
        PendingTask pendingTaskObj = new PendingTask();

        Id currentLoginUserId = UserInfo.getUserId();
        //String subject = 'Pending Proposal: ' + proposalObj.name;
        String subject =  'Pending Task : ' + proposalObj.name  ;
        pendingTaskObj.subject = subject;

        Task taskObj = new Task();
        taskObj.recordTypeId = recordTypeId;
        taskObj.OwnerId = proposalObj.Submitted_By__c;
        taskObj.whatId = proposalObj.Id;

        taskObj.Activity_Reason__c = 'Credit';
        taskObj.Activity_Channel__c = 'Email Outbound';
        taskObj.ActivityDate = date.today().addDays(5);
        taskObj.Description = 'Please review the pending proposal ' + proposalObj.Name + '.';
        taskObj.Description += '\n Pending Reason(s): \n';
        String tempPendingReasonStr = '';
        if(proposalObj.Pending_Proposal_Reason__c != null 
            && proposalObj.Pending_Proposal_Reason__c != ''){
            String [] pendingReasons = proposalObj.Pending_Proposal_Reason__c.split(';');
            for(String pendingReason : pendingReasons){
                tempPendingReasonStr += pendingReason + '\n';
            }
        }
        taskObj.Description += tempPendingReasonStr;
        //if(tempPendingReasonStr != null && tempPendingReasonStr != ''){
        //  subject += + ': ';
        //  subject += tempPendingReasonStr;
        //  Integer len = (subject.length() > 254) ? 254 : subject.length();
        //  subject = subject.substring(0, len);
        //}
        
        //if(proposalObj.Pending_Comments__c != null && proposalObj.Pending_Comments__c != ''){
        //  taskObj.Description += '\n Pending Comments: \n';
        //  taskObj.Description += proposalObj.Pending_Comments__c ;
        //}

        if(proposalObj.Pending_Notes__c != null && proposalObj.Pending_Notes__c != ''){
            taskObj.Description += '\n Pending Comments: \n' ;
            taskObj.Description += proposalObj.Pending_Notes__c ;
        }

        taskObj.subject = subject;
        taskobj.Pending_Proposal_Reason__c = proposalObj.Pending_Proposal_Reason__c;
        taskObj.Status = 'Open';
        taskObj.Priority = 'Normal';
        //taskObj.IsReminderSet = false;
        taskObj.Original_Task_Owner__c = currentLoginUserId;
        
        pendingTaskObj.taskObj = taskObj;
        return pendingTaskObj;   
        
    }

    public static Id getEmailTemplateId(String templateName){
        //EDP Customer Welcome Email 1
        List<EmailTemplate> emailTemplates = [Select Id, name from EmailTemplate where name =:templateName];
        Id templateId;
        if(emailTemplates != null && emailTemplates.size() > 0){
            templateId = emailTemplates[0].Id;
        }
        return templateId;
    }

    private static OrgWideEmailAddress getOrgWideEmailAddress(String fromEmail){
        OrgWideEmailAddress oweaObj = null;
        if(fromEmail != null && fromEmail != ''){
            OrgWideEmailAddress[] owea = [select Id, DisplayName from OrgWideEmailAddress where Address = :fromEmail];
            if(owea != null && owea.size() > 0 ){
                oweaObj = owea.get(0);
            }
        }
        return oweaObj;
    }

    public static void sendCustomerWelcomeEmail(Id templateId, Id contactId,  
                                                Id proposalId, List<Messaging.EmailFileAttachment> srAttachments,
                                                List<String> recContactEmailList, OrgWideEmailAddress oweaObj){
        if(contactId != null){
            System.debug('contactId: ' + contactId);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(oweaObj != null ){
                mail.setOrgWideEmailAddressId(oweaObj.Id);
            }
            mail.setTemplateId(templateId);
            mail.setTargetObjectId(contactId);
            mail.setWhatId(proposalId);
            if(recContactEmailList != null && recContactEmailList.size() > 0){
                mail.setCcAddresses(recContactEmailList);
            }
            mail.setSaveAsActivity(true);
            if(srAttachments != null && srAttachments.size() > 0){
                mail.setFileAttachments(srAttachments);
            }
            Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
            System.debug('resultMail: ' + resultMail);  
        }
    }

    public static Map<Id, Opportunity> getOpportunitiesAndRoles(Set<Id> opportunityIds){
        Map<Id, Opportunity> optyMap = new Map<Id, Opportunity>([Select Id, name, stageName,deal_Id__c,Channel_2__c,lead_source_2__c,Sales_Partner__c, SalesRep__c, Install_Partner__c,home_type__c,
                                                            (Select Id, contactId, OpportunityId, opportunity.Home_Type__c, isPrimary from 
                                                            OpportunityContactRoles) FROM Opportunity where Id in :opportunityIds]);
        return optyMap;                         
    }   


    public static Map<Id, List<OpportunityContactRole> > getContactRoles(Set<Id> opportunityIds){
        Map<Id, List<OpportunityContactRole> > opportunityContactRoles = new Map<Id, List<OpportunityContactRole> >();
        
        for(OpportunityContactRole optyContactRoleObj : [Select Id, contactId, OpportunityId, opportunity.Home_Type__c, isPrimary from 
                                                            OpportunityContactRole where OpportunityId in :opportunityIds]){
            List<OpportunityContactRole> optyContactRoles = opportunityContactRoles.containsKey(optyContactRoleObj.OpportunityId) 
                                        ? opportunityContactRoles.get(optyContactRoleObj.OpportunityId) : new List<OpportunityContactRole>();
            
            optyContactRoles.add(optyContactRoleObj);
            opportunityContactRoles.put(optyContactRoleObj.OpportunityId, optyContactRoles);
        }   
        System.debug('opportunityContactRoles: ' + opportunityContactRoles);    
        return opportunityContactRoles;
    } 

    public static Map<Id, Set<Id> > getContactIdsForOpportunities(Set<Id> opportunityIds){
        Map<Id, Set<Id> > opportunityContactRoles = new Map<Id, Set<Id> >();
        for(OpportunityContactRole optyContactRoleObj : [Select Id, contactId, OpportunityId, isPrimary from 
                                                            OpportunityContactRole where OpportunityId in :opportunityIds]){
            Set<Id> optycontactIds = opportunityContactRoles.containsKey(optyContactRoleObj.OpportunityId) 
                                        ? opportunityContactRoles.get(optyContactRoleObj.OpportunityId) : new Set<Id>();
            
            optycontactIds.add(optyContactRoleObj.contactId);
            opportunityContactRoles.put(optyContactRoleObj.OpportunityId, optycontactIds);
        }   
        System.debug('opportunityContactRoles: ' + opportunityContactRoles);    
        return opportunityContactRoles;
    } 

    public static Map<Id, Id> getPrimaryContactIdForOpportunities(Set<Id> opportunityIds){
        Map<Id, Id> opportunityContactRoles = new Map<Id, Id>();
        for(OpportunityContactRole optyContactRoleObj : [Select Id, contactId, OpportunityId from 
                                                            OpportunityContactRole where OpportunityId in :opportunityIds and isPrimary = true]){
            
            opportunityContactRoles.put(optyContactRoleObj.OpportunityId, optyContactRoleObj.contactId);
        }   
        System.debug('opportunityContactRoles: ' + opportunityContactRoles);    
        return opportunityContactRoles;
    } 
 
    public static Map<Id, Map<Id,OpportunityContactRole> > getContactsForOpportunities(Set<Id> opportunityIds){
        Map<Id, Map<Id,OpportunityContactRole> > opportunityContactRoles = new Map<Id, Map<Id,OpportunityContactRole> >();
        for(OpportunityContactRole optyContactRoleObj : [Select Id, contactId, OpportunityId, isPrimary from 
                                                            OpportunityContactRole where OpportunityId in :opportunityIds]){
            Map<Id, OpportunityContactRole> optycontactRoleMap = opportunityContactRoles.containsKey(optyContactRoleObj.OpportunityId) 
                                        ? opportunityContactRoles.get(optyContactRoleObj.OpportunityId) : new Map<Id, OpportunityContactRole>();
            
            optycontactRoleMap.put(optyContactRoleObj.Id, optyContactRoleObj);
            opportunityContactRoles.put(optyContactRoleObj.OpportunityId, optycontactRoleMap);
        }   
        System.debug('opportunityContactRoles: ' + opportunityContactRoles);    
        return opportunityContactRoles;
    } 

    public static Map<Id, Map<Id, OpportunityContactRole>> getOpportunityRoleMap(List<Id> opportunityIds){
        System.debug('opportunityIds: ' + opportunityIds);
        Map<Id, Map<Id, OpportunityContactRole>> opportunityContactMap = new Map<Id, Map<Id, OpportunityContactRole>>();
        for(OpportunityContactRole roleObj: [Select Id, contactId, OpportunityId, role, isprimary,
                                                Contact.Name, contact.email,contact.preferred_language__c from OpportunityContactRole 
                                                where OpportunityId in :opportunityIds
                                                and contact.email != null and contact.email  != '' ]){
            if(roleObj.contactId != null){
                Map<Id, OpportunityContactRole> roleMap = opportunityContactMap.containsKey(roleObj.OpportunityId) ? 
                                                            opportunityContactMap.get(roleObj.OpportunityId) : new Map<Id, OpportunityContactRole>();
                roleMap.put(roleObj.contactId, roleObj);    
                opportunityContactMap.put(roleObj.OpportunityId, roleMap);  
            }
        }
        return opportunityContactMap;
    }   
      
    public static Map<Id, Id> getOpptyIdsForContactIds(Set<Id> contactIds){
        Map<Id, Id> optycontactIdsMap = new Map<Id, Id>();
        for(OpportunityContactRole optyContactRoleObj : [Select Id, contactId, OpportunityId, isPrimary from 
                                                            OpportunityContactRole where ContactId in :contactIds and isPrimary = true]){
            optycontactIdsMap.put(optyContactRoleObj.OpportunityId, optyContactRoleObj.contactId);
        }   
        System.debug('optycontactIdsMap: ' + optycontactIdsMap);    
        return optycontactIdsMap;
    } 
 
    public static String getBaseURL() {
        String baseURL = '';
        String redirectUrl = System.URL.getCurrentRequestUrl().getPath();
        
        Boolean isPartnerPortalURL = false;
        if(redirectUrl.startsWith('/partner')){
            isPartnerPortalURL = true;
        } 
        System.debug('isPartnerPortalURL: ' + isPartnerPortalURL);
        if(isPartnerPortalURL){
            baseURL = System.URL.getSalesforceBaseUrl().toExternalForm() + '/partner';          
        }
        else if(redirectUrl.startsWith('/aeepartner')){
            baseURL = System.URL.getSalesforceBaseUrl().toExternalForm() + '/aeepartner';  
        }
        else{
            String Instance = null;
            List<String> parts = System.URL.getSalesforceBaseUrl().getHost().replace('-api','').split('\\.');
           
            if (parts.size() == 3) Instance = parts[0];
            else if (parts.size() == 5) Instance = parts[1];
            else Instance = null; 
            if(Instance != null){
                baseURL = 'https://' + Instance + '.salesforce.com';    
            }               
        }
        system.debug('==>URL : '+baseURL);
        return baseURL;
    }
    
    public static void getSubmittedProposals(Set<Id> opportunityIds, Map<Id, Map<Id, Proposal__C>> submittedProposalMapForOptys,
                                                                    Map<Id, Map<Id, Proposal__C>> proposalsByOpty ){
        Set<String> submittedStages = new Set<String>();

        //Following proposal stages are considered 
        //as the submitted proposals
        submittedStages.add(SUBMITTED);
        submittedStages.add(SR_OPS_APPROVED);
        submittedStages.add(SR_OPS_RECEIVED);
        submittedStages.add(SR_OPS_REVIEWED);
        submittedStages.add(SR_SIGNOFF_REVIEW);
        submittedStages.add(CREDIT_APPROVED);
        submittedStages.add(CREDIT_REVIEW);
        //submittedStages.add(REPLACED_BY);
        submittedStages.add(PENDING);
        submittedStages.add(ON_HOLD);

        String proposalSOQLStr = ProposalUtil.getProposalSQLStr();
        proposalSOQLStr += '  where Opportunity__c =:opportunityIds ' ;
        for(Proposal__c proposalObj : Database.query(proposalSOQLStr)){
            if(submittedStages.contains(proposalObj.Stage__c)){
                Map<Id, Proposal__C> submittedProposals = submittedProposalMapForOptys.containsKey(proposalObj.Opportunity__c) ? 
                                                            submittedProposalMapForOptys.get(proposalObj.Opportunity__c) 
                                                            : new Map<Id, Proposal__C>();
                submittedProposals.put(proposalObj.Id, proposalObj);
                submittedProposalMapForOptys.put(proposalObj.Opportunity__c, submittedProposals);
            }

            Map<Id, Proposal__C> allProposals = proposalsByOpty.containsKey(proposalObj.Opportunity__c) ? 
                                                        proposalsByOpty.get(proposalObj.Opportunity__c) 
                                                        : new Map<Id, Proposal__C>();
            allProposals.put(proposalObj.Id, proposalObj);
            proposalsByOpty.put(proposalObj.Opportunity__c, allProposals);
        }
    }

    public static void copySRAttachmentsForRevisedProposals(Map<Id, Id> proposalToOriginalPorpsMap){
        
        Map<Id, Map<String, List<SR_Attachment__C>>> proposalToSRAttachmentMap = new Map<Id, Map<String, List<SR_Attachment__C>>>();
        Map<String, boolean> recipientSignedStatusMap = new Map<String, boolean>();
        String manualUploadStr = EDPUtil.MANUAL_UPLOAD_SOURCE;
        Set<Id> modifiedParentProposaLIds = new Set<Id>();
        if(proposalToOriginalPorpsMap.size() > 0){
            List<Id> originalProposalIds = proposalToOriginalPorpsMap.values();
            String soqlStr;
            String replacedStr = EDPUtil.REPLACED_BY;
            soqlStr = SRAttachmentManager.getSRAttachmentSOQL();
            soqlStr += '  WHERE Proposal__c IN : originalProposalIds ' ;
            soqlStr += '  and Proposal__r.stage__c != :replacedStr ' ;
            soqlStr += '  and Active__c = true ' ;
            soqlStr += '  and Document_Source__c =:manualUploadStr ' ;
            soqlStr += '  and Document_Classification__r.ESignature_allowed__c = false ' ;

            for(SR_Attachment__c srAttachmentObj : Database.query(soqlStr)){                            
                if(srAttachmentObj.Document_Classification__c != null){
                    Map<String, List<SR_Attachment__C>> srAttachmentsMap = proposalToSRAttachmentMap.containsKey(srAttachmentObj.Proposal__c) ? 
                                                            proposalToSRAttachmentMap.get(srAttachmentObj.Proposal__c) : new Map<String, List<SR_Attachment__C>>();

                    List<SR_Attachment__C> srAttachments = srAttachmentsMap.containskey(srAttachmentObj.Document_Classification__c) ? 
                                                                srAttachmentsMap.get(srAttachmentObj.Document_Classification__c) : new List<SR_Attachment__C>();
                    srAttachments.add(srAttachmentObj);
                    srAttachmentsMap.put(srAttachmentObj.Document_Classification__c, srAttachments);
                    proposalToSRAttachmentMap.put(srAttachmentObj.Proposal__c, srAttachmentsMap);
                }
            }
            
            List<SR_Attachment__c> newSRAttachments = new List<SR_Attachment__c>();
            for(Id proposalId : proposalToOriginalPorpsMap.KeySet()){
                Id originalProposalId = proposalToOriginalPorpsMap.get(proposalId);
                Map<String, List<SR_Attachment__C>> parentSRAttachmentsMap = proposalToSRAttachmentMap.get(originalProposalId);
                System.debug('parentSRAttachmentsMap: ' + parentSRAttachmentsMap);
                
                if(parentSRAttachmentsMap != null && parentSRAttachmentsMap.size() > 0){
                    for(String documentType : parentSRAttachmentsMap.keySet()){
                        List<SR_Attachment__C> parentSRAttachments = parentSRAttachmentsMap.get(documentType);
                        if(parentSRAttachments != null && parentSRAttachments.size() > 0){
                            for(SR_Attachment__c srAttachment : parentSRAttachments){
                                if(srAttachment.Active__c == false || srAttachment.Document_Source__c != EDPUtil.MANUAL_UPLOAD_SOURCE)
                                    continue;
                                SR_Attachment__c newSRAttachmentObj = cloneSRAttachmentOnSFDC(srAttachment, proposalId);
                                newSRAttachments.add(newSRAttachmentObj);
                            }                           
                        }
                    }
                }
            }
            System.debug('Before Update: ');
            if(newSRAttachments.size() > 0){
                insert newSRAttachments;
            }
            System.debug('newSRAttachments: ' + newSRAttachments);
            List<Proposal__C> modifiedOriginalProposals = new List<Proposal__C>();
            for(Proposal__c proposalObj : [Select Id, name, stage__c from Proposal__c where Id in :proposalToOriginalPorpsMap.values()]){
                proposalObj.Stage__c = EDPUtil.REPLACED_BY;
                modifiedOriginalProposals.add(proposalObj);             
            }
            
            if(modifiedOriginalProposals.size() > 0 ){
                update modifiedOriginalProposals;
            }
            
        }
    }   
    
    
    public static Map<Id, String> processSubmittedProposals(Set<Id> oprtyIds, Map<Id, Proposal__c> proposalMap,
                                                             Map<Id, Proposal__c> parentProposalMap){
        Map<Id, Id> changeOrderToSubmittedProposalMap = new Map<Id, Id>();
        Map<Id, String> proposalValidationMap = new Map<Id, String> ();
        String sunrunId = System.Label.Sunrun_Inc_Id;
        Set<Id> validProposalIds = proposalMap.keySet();
        Map<Id, Proposal__C> replacedByProposalsMap = new Map<Id, Proposal__C>();
        Map<Id, Map<Id, Proposal__C>> submittedOptyProposalMap = new Map<Id, Map<Id, Proposal__C>>();
        Map<Id, Map<Id, Proposal__C>> allProposalsByOptyMap = new Map<Id, Map<Id, Proposal__C>>();
        getSubmittedProposals(oprtyIds, submittedOptyProposalMap, allProposalsByOptyMap);
        Set<Id> proposalIdsForSRAttachments = new Set<Id>();
        Set<String> missingDocumentsSet = new Set<String>();

        Map<Id, Id> proposalToOriginalPorpsMap = new Map<Id, Id>();
        for(Id proposalId : validProposalIds){
            Proposal__c tempProposalobj =  proposalMap.get(proposalId);
            if(tempProposalobj.Revised_Proposal__c == true && tempProposalobj.Original_Proposal_ID__c != null){
                proposalToOriginalPorpsMap.put(tempProposalobj.Id, tempProposalobj.Original_Proposal_ID__c);
            }
        }
        
        if(proposalToOriginalPorpsMap != null && proposalToOriginalPorpsMap.size() > 0){
            copySRAttachmentsForRevisedProposals(proposalToOriginalPorpsMap);
        }

        for(Id proposalId : validProposalIds){
            Proposal__c tempProposalobj =  proposalMap.get(proposalId);

            Map<Id, Proposal__C> submittedProposalsMap = submittedOptyProposalMap.get(tempProposalobj.Opportunity__c);
            System.debug('submittedProposalsMap: ' + submittedProposalsMap);
            if(tempProposalobj.Original_Proposal_ID__c != null && tempProposalobj.Change_Order__c == true){
                Id srAttachmentProposalId = null;
                if(submittedProposalsMap != null && submittedProposalsMap.size() > 0){
                    for(Proposal__C submittedProposalObj : submittedProposalsMap.values()){
                        replacedByProposalsMap.put(submittedProposalObj.Id, submittedProposalObj);
                        if(submittedProposalObj.Original_Proposal_ID__c == tempProposalobj.Original_Proposal_ID__c){
                            srAttachmentProposalId = submittedProposalObj.Id;
                            System.debug('submittedProposalObj.Id: ' + submittedProposalObj.Id);
                            parentProposalMap.put(tempProposalobj.Id, submittedProposalObj);
                        }
                    }
                }
                
                if(srAttachmentProposalId == null){
                    srAttachmentProposalId = tempProposalobj.Original_Proposal_ID__c;
                    Map<Id, Proposal__C> relatedProposalMap = allProposalsByOptyMap.get(tempProposalobj.Opportunity__c);
                    if(relatedProposalMap != null && relatedProposalMap.containsKey(tempProposalobj.Original_Proposal_ID__c)){
                        Proposal__c parentProposalobj = relatedProposalMap.get(tempProposalobj.Original_Proposal_ID__c);
                        replacedByProposalsMap.put(tempProposalobj.Original_Proposal_ID__c, parentProposalobj);
                        parentProposalMap.put(tempProposalobj.Id, parentProposalobj);
                    }
                    
                    System.debug('tempProposalobj.Original_Proposal_ID__c: ' + tempProposalobj.Original_Proposal_ID__c);
                }
                
                if(srAttachmentProposalId != null){
                    changeOrderToSubmittedProposalMap.put(tempProposalobj.Id, srAttachmentProposalId);
                    proposalIdsForSRAttachments.add(srAttachmentProposalId);
                    proposalIdsForSRAttachments.add(tempProposalobj.Id);
                    System.debug('srAttachmentProposalId: ' + srAttachmentProposalId);
                }
            }else{
                proposalIdsForSRAttachments.add(tempProposalobj.Id);
                if(submittedProposalsMap != null && submittedProposalsMap.size() > 0){
                    for(Proposal__C submittedProposalObj : submittedProposalsMap.values()){
                        replacedByProposalsMap.put(submittedProposalObj.Id, submittedProposalObj);
                    }
                }               
            }
        }
        
        //Map<Id, List<SR_Attachment__C>> proposalToSRAttachmentMap = new Map<Id, List<SR_Attachment__C>>();
        Map<Id, Map<String, List<SR_Attachment__C>>> proposalToSRAttachmentMap = new Map<Id, Map<String, List<SR_Attachment__C>>>();
        Set<String> envelopIds = new Set<String>();
        Map<String, boolean> recipientSignedStatusMap = new Map<String, boolean>();
        if(proposalIdsForSRAttachments.size() > 0){
            String soqlStr;
            String replacedStr = EDPUtil.REPLACED_BY;
            soqlStr = SRAttachmentManager.getSRAttachmentSOQL();
            soqlStr += '  WHERE Proposal__c IN :proposalIdsForSRAttachments ' ;
            soqlStr += '  and Proposal__r.stage__c != :replacedStr ' ;
            soqlStr += '  and Active__c = true ' ;
            for(SR_Attachment__c srAttachmentObj : Database.query(soqlStr)){                            
                if(srAttachmentObj.Document_Classification__c != null){
                    Map<String, List<SR_Attachment__C>> srAttachmentsMap = proposalToSRAttachmentMap.containsKey(srAttachmentObj.Proposal__c) ? 
                                                            proposalToSRAttachmentMap.get(srAttachmentObj.Proposal__c) : new Map<String, List<SR_Attachment__C>>();

                    List<SR_Attachment__C> srAttachments = srAttachmentsMap.containskey(srAttachmentObj.Document_Classification__c) ? 
                                                                srAttachmentsMap.get(srAttachmentObj.Document_Classification__c) : new List<SR_Attachment__C>();
                    srAttachments.add(srAttachmentObj);
                    srAttachmentsMap.put(srAttachmentObj.Document_Classification__c, srAttachments);
                    proposalToSRAttachmentMap.put(srAttachmentObj.Proposal__c, srAttachmentsMap);
                }
                if(srAttachmentObj.Envelop_Id__c != null && srAttachmentObj.Envelop_Id__c != ''){
                    envelopIds.add(srAttachmentObj.Envelop_Id__c);
                }
            }
            recipientSignedStatusMap = isDocumentSignedByCustomersAndPartners(envelopIds);
        }
        
        if(changeOrderToSubmittedProposalMap.size() > 0 ){
            createSRAttachmentsForChangeOrders(changeOrderToSubmittedProposalMap, proposalMap, proposalToSRAttachmentMap);
        }
        
        List<Proposal__C> modifiedProposals = new List<Proposal__C>();
        for(Proposal__C proposalObjVal : replacedByProposalsMap.values()){
            if(proposalObjVal != null && !validProposalIds.contains(proposalObjVal.Id) 
                && (proposalObjVal.Stage__c != EDPUtil.REPLACED_BY && proposalObjVal.Stage__c != EDPUtil.VOIDED)){
                proposalObjVal.Stage__c = EDPUtil.REPLACED_BY;
                modifiedProposals.add(proposalObjVal);      
            }
        }   
        try{
            System.debug('Before invoke ..');
            if(modifiedProposals.size() > 0){
                update modifiedProposals;
            }
            System.debug('After invoke ..');

        }catch(Exception e){
            System.debug('System Error: ' + e.getMessage());
            return proposalValidationMap;
        }
        //Verify the required required documents to Submit the Proposal
        Set<String> modes = new Set<String>();
        modes.add(EDPUtil.READ);
        modes.add(EDPUtil.EDIT);
        modes.add(EDPUtil.NONE);
        String strProposalApprovalLimit1 = Label.ProposalApprovalLimit1;
        if(strProposalApprovalLimit1 == null || strProposalApprovalLimit1 == ''){
            strProposalApprovalLimit1 = '15';
        }
        Decimal proposalLimit1 = Decimal.valueOf(strProposalApprovalLimit1);
        Set<String> utlityCompanies = getUtilityCompanies();
        for(Id proposalId : validProposalIds){
            Proposal__c tempProposalobj =  proposalMap.get(proposalId);
            String installPartner = (tempProposalobj.install_partner__C == null) ? '' : tempProposalobj.install_partner__C; 
            if(!String.isEmpty(installPartner) && installPartner.length() >= 15){
                installPartner = installPartner.substring(0,15);
            }

            if((tempProposalobj.name.indexOf('H') == 0 ) &&  tempProposalobj.Change_Order__c == true){
                continue;
            }
            Map<String, Document_Classification__c> mandatoryDocumentClassificationMap;
           // mandatoryDocumentClassificationMap = EDPDocumentSettings.getDocumentClassificationByCategroy(null, 
           //                                                                                     EDPDocumentSettings.MANDATORY_REQUIREMENTS,
           //                                                                                     modes, tempProposalobj.Sales_Partner__c, 
           //                                                                                     tempProposalobj.Install_Partner__c);
            
            //String proposalCostStack = 'INTEGRATED';
            String proposalCostStack = tempProposalobj.cost_stack__c;
            System.debug('proposalCostStack: ' + proposalCostStack);
            EDPDocumentSettings.proposalState =  tempProposalobj.State__c;
            mandatoryDocumentClassificationMap = EDPDocumentSettings.getDocumentClassificationByCategroy(null, 
                                                                                                EDPDocumentSettings.MANDATORY_REQUIREMENTS,
                                                                                                modes, proposalCostStack);
                     system.debug('mandatoryDocumentClassificationMap>>' +mandatoryDocumentClassificationMap);   
            Boolean missingRequiredDocumnets = false;
            Boolean missingSignatures = false;
            String missingDocuments = '';
            String missingSignatureDocs = '';
            if(mandatoryDocumentClassificationMap != null && mandatoryDocumentClassificationMap.size() > 0){
                missingRequiredDocumnets = false;
                missingSignatures = false;
                for(String documentType : mandatoryDocumentClassificationMap.keySet()){
                    Document_Classification__c documentClassificationObj = mandatoryDocumentClassificationMap.get(documentType);
                    Boolean customerChangeOrder = false;
                    String proposalType = tempProposalobj.Change_Order_Information__c;
                    if(proposalType != null && proposalType.contains(ProposalUtil.CUSTOMER_CHANGE_ORDER)){
                        customerChangeOrder = true;
                    }
                    
                    if( ((documentClassificationObj.Document_Name__c == LARGE_SYSTEM_CONTRACT_REQUEST) && (tempProposalobj.System_Size_STC_DC__c == null || tempProposalobj.System_Size_STC_DC__c < proposalLimit1)) ||
                        ((documentClassificationObj.Document_Name__c == CUSTOMER_CHANGEORDER_COVER_SHEET) 
                        && (tempProposalobj.name == null || ((tempProposalobj.name.indexOf('C') != 0) && (customerChangeOrder == false)))) ||
                        (documentClassificationObj.Document_Name__c == EPBB && !utlityCompanies.contains(tempProposalobj.Utility__c)) ||
                        (documentClassificationObj.Document_Name__c == EDPUtil.UTILITY_BILL  && tempProposalobj.New_Home_without_Utility_Bills__c == true) || 
                        (documentClassificationObj.Document_Name__c == EDPUtil.LIVING_SPACE && tempProposalobj.New_Home_without_Utility_Bills__c != true) ||
                        (documentClassificationObj.Document_Name__c == 'EPC' && !String.isEmpty(installPartner) && sunrunId.contains(installPartner)) ||
                         (documentClassificationObj.Document_Name__c == EDPUTIL.NEM_FORM))
                    {
                        continue;
                    }

                    Map<String, List<SR_Attachment__C>> srAttachmentsMap  = proposalToSRAttachmentMap.get(proposalId);
                    system.debug('srAttachmentsMap>'  + srAttachmentsMap);
                    system.debug('documentClassificationObj>' +  documentClassificationObj);
                    if(srAttachmentsMap != null){
                        if(srAttachmentsMap.containskey(documentClassificationObj.Id)){
                            List<SR_Attachment__C> tempSRAttachmentList = srAttachmentsMap.get(documentClassificationObj.Id);
                            Boolean hasSignatures = false;
                            for(SR_Attachment__C srAttachmentObj : tempSRAttachmentList){
                                
                                 system.debug('srAttachmentObj>' +  srAttachmentObj);
                                if(srAttachmentObj.Wet_Sign_Status__c == SIGNED 
                                        && srAttachmentObj.Document_Source__c == MANUAL_UPLOAD_SOURCE){
                                    hasSignatures = true;
                                }else if(srAttachmentObj.Envelop_Id__c != null && srAttachmentObj.Envelop_Id__c != ''){
                                    if(recipientSignedStatusMap.containsKey(srAttachmentObj.Envelop_Id__c)){
                                        hasSignatures = recipientSignedStatusMap.get(srAttachmentObj.Envelop_Id__c);
                                    }
                                }
                            }
                            if(hasSignatures == false){
                                List<Partner_Document_Relationship__c> partnerDocumentRelationships =   documentClassificationObj.Partner_Document_Relationships__r;
                                if(partnerDocumentRelationships != null && partnerDocumentRelationships.size() > 0){
                                    Partner_Document_Relationship__c ptrRelationshipObj = partnerDocumentRelationships[0];
                                    system.debug('ptrRelationshipObj>' +  ptrRelationshipObj);
                                    if(ptrRelationshipObj.Customer_signature_required__c == true 
                                        || ptrRelationshipObj.Partner_signature_required__c == true){
                                        //missingSignatures = true; 
                                        missingDocuments += '\t' +  documentClassificationObj.Document_Name__c + '\t -- Signature required '+ '\n';
                                        missingDocumentsSet.add(documentClassificationObj.Document_Name__c);
                                    }
                                }
                            }
                        }else{
                            //missingRequiredDocumnets = true;
                            missingDocuments += '\t' + documentClassificationObj.Document_Name__c + '\n';
                            missingDocumentsSet.add(documentClassificationObj.Document_Name__c);
                        }
                    }else if(documentClassificationObj != null){
                        //missingRequiredDocumnets = true;
                        missingDocuments += '\t' +  documentClassificationObj.Document_Name__c + '\n';
                        missingDocumentsSet.add(documentClassificationObj.Document_Name__c);
                    }
                }

            }else{
                proposalValidationMap.put(proposalId, CustomErrorMessages.MISSGIN_ALL_REQUIRED_DOCS);
            }   
            
            String errorMessage = '';
            if(missingDocuments != null && missingDocuments != ''){
                errorMessage = CustomErrorMessages.MISSGIN_REQUIRED_DOCS + missingDocuments + '\n\n';
                //if(missingDocumentsSet.size() == 1 && missingDocumentsSet.contains(EDPUtil.UTILITY_BILL)){
                //  errorMessage += CustomErrorMessages.MISSING_UTILITY_BILL  + '\n\n';
                //}
                //if(missingDocumentsSet.size() == 1 && missingDocumentsSet.contains(EDPUtil.LIVING_SPACE)){
                //  errorMessage += CustomErrorMessages.MISSING_LIVING_SPACE  + '\n\n';
                //}
            }
            if(missingSignatureDocs != null && missingSignatureDocs != ''){
                errorMessage += CustomErrorMessages.REQUIRED_DOCS_NOT_SIGNED + missingSignatureDocs ;
            }
            if(errorMessage != null && errorMessage != ''){
                proposalValidationMap.put(proposalId, errorMessage);
            }
        }   
        return proposalValidationMap;
    }
    
    
    
    
    public static void createSRAttachmentsForChangeOrders(Map<Id, Id> changeOrderToSubmittedProposalMap, 
                                                            Map<Id, Proposal__c> proposalMap,
                                                            Map<Id, Map<String, List<SR_Attachment__C>>> proposalToSRAttachmentMap){
        
        List<SR_Attachment__c> newSRAttachments = new List<SR_Attachment__c>();
        Map<String, SR_Attachment__c> envelopToSRAttachmentMap = new Map<String, SR_Attachment__c>();
        for(Id proposalId : changeOrderToSubmittedProposalMap.keySet()){
            Id srAttachmentProposalId = changeOrderToSubmittedProposalMap.get(proposalId);
            Proposal__c proposalObj = proposalMap.get(proposalId);
            Map<String, List<SR_Attachment__C>> parentSRAttachmentsMap = proposalToSRAttachmentMap.get(srAttachmentProposalId);
            Map<String, List<SR_Attachment__C>> existingSRAttachmentsMap = proposalToSRAttachmentMap.get(proposalId);
            Set<String> existingDocumentTypes = new Set<String>(); 
            
            if(existingSRAttachmentsMap == null){
                existingSRAttachmentsMap = new  Map<String, List<SR_Attachment__C>>();
            }
            
            System.debug('existingSRAttachmentsMap: ' + existingSRAttachmentsMap);
            if(parentSRAttachmentsMap != null && parentSRAttachmentsMap.size() > 0){
                for(String documentType : parentSRAttachmentsMap.keySet()){
                    List<SR_Attachment__C> parentSRAttachments = parentSRAttachmentsMap.get(documentType);
                    System.debug('parentSRAttachments: ' + parentSRAttachments);
                    if(parentSRAttachments != null && parentSRAttachments.size() > 0){
                        for(SR_Attachment__c srAttachment : parentSRAttachments){
                            Boolean createSRAttachment = false;
                            
                            if(srAttachment.Active__c == false || srAttachment.Document_Source__c == EDPUtil.PROPOSAL_TOOL_SOURCE)
                                continue;
        
                            if((srAttachment.Document_Source__c != EDPUtil.PROPOSAL_TOOL_SOURCE) 
                                &&(srAttachment.Wet_Sign_Status__c == EDPUtil.SIGNED 
                                || srAttachment.Wet_Sign_Status__c == EDPUtil.NA
                                || (srAttachment.DocuSign_Status__c != null 
                                    && srAttachment.DocuSign_Status__c  != '' 
                                    && srAttachment.DocuSign_Status__c != EDPUtil.VOIDED))){

                                if(!existingSRAttachmentsMap.containsKey(srAttachment.Document_Classification__c)){
                                    createSRAttachment = true;
                                }else{
                                    List<SR_Attachment__C> tempExitingSRAttachmentsList = existingSRAttachmentsMap.get(srAttachment.Document_Classification__c);
                                    System.debug('tempExitingSRAttachmentsList: ' + tempExitingSRAttachmentsList);
                                    createSRAttachment = true;
                                    
                                    for(SR_Attachment__c tempExitingSRAttachment : tempExitingSRAttachmentsList){
                                        System.debug('tempExitingSRAttachment: ' + tempExitingSRAttachment);
                                        System.debug('srAttachment: ' + srAttachment);

                                        if(tempExitingSRAttachment.Document_Type_Name__c != EDPUtil.OTHER && 
                                            tempExitingSRAttachment.Document_Type_Name__c  == srAttachment.Document_Type_Name__c &&
                                            (tempExitingSRAttachment.Document_Source__c == srAttachment.Document_Source__c) || 
                                            (tempExitingSRAttachment.Document_Source__c == EDPUtil.MANUAL_UPLOAD_SOURCE && 
                                                srAttachment.Document_Source__c == EDPUtil.E_SIGN) ||
                                            (tempExitingSRAttachment.Document_Source__c == EDPUtil.E_SIGN && 
                                                srAttachment.Document_Source__c == EDPUtil.MANUAL_UPLOAD_SOURCE)){
                                            createSRAttachment = false;
                                            break;
                                        }                                       
                                    }
                                }
                            }

                            System.debug('proposalObj.Proposal_Source__c: ' + proposalObj.Proposal_Source__c);
                            if(createSRAttachment && (proposalObj.Proposal_Source__c == null || proposalObj.Proposal_Source__c != ProposalUtil.BLACK_BIRD)){
                                SR_Attachment__c newSRAttachmentObj = cloneSRAttachmentOnSFDC(srAttachment, proposalObj.Id);
                                newSRAttachments.add(newSRAttachmentObj);
                                List<SR_Attachment__C> tempSRAttachments = existingSRAttachmentsMap.containskey(srAttachment.Document_Classification__c) ? 
                                                                        existingSRAttachmentsMap.get(srAttachment.Document_Classification__c) : new List<SR_Attachment__C>();
                                
                                tempSRAttachments.add(newSRAttachmentObj);
                                existingSRAttachmentsMap.put(newSRAttachmentObj.Document_Classification__c, tempSRAttachments);
                                
                                if(newSRAttachmentObj.Envelop_Id__c != null && newSRAttachmentObj.Envelop_Id__c != ''){
                                    envelopToSRAttachmentMap.put(newSRAttachmentObj.Envelop_Id__c, newSRAttachmentObj);
                                }
                            }
                        }                       
                    }
                }
            }
        }
        
        System.debug('Before Update: ');
        if(newSRAttachments.size() > 0){
            insert newSRAttachments;
        }
        System.debug('newSRAttachments: ' + newSRAttachments);
        List<dsfs__DocuSign_Status__c> modifiedDocuSignStatusList = new List<dsfs__DocuSign_Status__c>();
        for(dsfs__DocuSign_Status__c docuSignStatusObj : [Select Id, dsfs__DocuSign_Envelope_ID__c, SR_Attachment__c from dsfs__DocuSign_Status__c 
                                                            where dsfs__DocuSign_Envelope_ID__c in :envelopToSRAttachmentMap.keySet()]){
            
            SR_Attachment__c tempSRAttachmentObj  = envelopToSRAttachmentMap.get(docuSignStatusObj.dsfs__DocuSign_Envelope_ID__c);
            System.debug('tempSRAttachmentObj: ' + tempSRAttachmentObj);
            docuSignStatusObj.SR_Attachment__c = tempSRAttachmentObj.Id;
            modifiedDocuSignStatusList.add(docuSignStatusObj);  
        }
        
        if(modifiedDocuSignStatusList.size() > 0 ){
            update modifiedDocuSignStatusList;
        }
    }

    public static SR_Attachment__c cloneSRAttachmentOnSFDC(SR_Attachment__c srAttachmentObj, Id proposalId){
        SR_Attachment__c newSRAttachmentObj = new SR_Attachment__c();
        newSRAttachmentObj.name = srAttachmentObj.name;
        newSRAttachmentObj.Bucket_Name__c = srAttachmentObj.Bucket_Name__c;
        newSRAttachmentObj.Document_Name_On_File_Server__c = srAttachmentObj.Document_Name_On_File_Server__c;
        newSRAttachmentObj.Customer_Signed__c = srAttachmentObj.Customer_Signed__c;
        newSRAttachmentObj.Description__c = srAttachmentObj.Description__c;
        newSRAttachmentObj.Document_Id__c = srAttachmentObj.Document_Id__c;
        newSRAttachmentObj.Document_Name__c = srAttachmentObj.Document_Name__c;
        newSRAttachmentObj.Document_Source__c = srAttachmentObj.Document_Source__c;
        newSRAttachmentObj.DocuSign_Error_Code__c = srAttachmentObj.DocuSign_Error_Code__c;
        newSRAttachmentObj.DocuSign_Error_Message__c = srAttachmentObj.DocuSign_Error_Message__c;
        newSRAttachmentObj.DocuSign_Status__c = srAttachmentObj.DocuSign_Status__c;
        newSRAttachmentObj.Envelop_Id__c = srAttachmentObj.Envelop_Id__c;
        newSRAttachmentObj.ETag__c = srAttachmentObj.ETag__c;
        //newSRAttachmentObj.Opportunity__c = srAttachmentObj.Opportunity__c;
        newSRAttachmentObj.Partner_Signed__c = srAttachmentObj.Partner_Signed__c;
        newSRAttachmentObj.SunRun_Signed__c = srAttachmentObj.SunRun_Signed__c;
        newSRAttachmentObj.Proposal_Document_Type__c = srAttachmentObj.Proposal_Document_Type__c;
        newSRAttachmentObj.Active__c = srAttachmentObj.Active__c;
        newSRAttachmentObj.parent_proposal_name__c = srAttachmentObj.parent_proposal_name__c;

        newSRAttachmentObj.Document_Classification__c = srAttachmentObj.Document_Classification__c;
        //newSRAttachmentObj.OSA_URL__c = srAttachmentObj.OSA_URL__c;
        newSRAttachmentObj.Wet_Sign_Status__c = srAttachmentObj.Wet_Sign_Status__c;
        newSRAttachmentObj.proposal__c = (proposalId == null) ? srAttachmentObj.proposal__c : proposalId;
        //newSRAttachmentObj.Parent_SR_Attachment__c = srAttachmentObj.Id;
        newSRAttachmentObj.Proposal_Source__c = srAttachmentObj.Proposal_Source__c;
        return newSRAttachmentObj;
    }
    
    public static Map<Id, String> validateProposalSubmission(Map<Id, Proposal__c> proposalMap){
        Map<Id, String> proposalValidationMap = new Map<Id, String>();
        Boolean validUser = true;
        Contact loginContact = PRMContactUtil.getLoginUserContact();
        if(loginContact != null && loginContact.Location__r != null && loginContact.Location__r.Headquarters__c == false){
            validUser = false;
        }
        
        for(Proposal__c proposalObj : proposalMap.values()){
            
            if(validUser == false){
                proposalValidationMap.put(proposalObj.Id, CustomErrorMessages.NOT_AUTHORIZED_USER);
            }else if(proposalObj.Opportunity__c == null ){
                proposalValidationMap.put(proposalObj.Id, CustomErrorMessages.FOUND_NO_VALID_OPPORTUNITY);
            }else if( proposalObj.sales_partner__c != System.Label.Sunrun_Inc_Id && 
               (proposalObj.Agreement_Type__c == 'Customer Owned - Bank Financed' || proposalObj.Agreement_Type__c == 'Customer Owned - Full Upfront')){
               proposalValidationMap.put(proposalObj.Id, CustomErrorMessages.PARTNER_CASH_COBF_ERROR);    
            }else if(proposalObj.Required_Loan_Amount__c > proposalObj.Max_Loan_Amount__c){
               proposalValidationMap.put(proposalObj.Id, CustomErrorMessages.MAX_LOAN_AMT_ERROR);   
            }else if(proposalObj.Estimation_Method__c == 'From average monthly bill estimation' ){
                proposalValidationMap.put(proposalObj.Id, CustomErrorMessages.MONTHLY_BILL_ERROR);
            /*}else if(proposalObj.Opportunity__r.Purchased_Thru__c == 'Costco' && proposalObj.Retail_PO__c == null){
                proposalValidationMap.put(proposalObj.Id, CustomErrorMessages.PO_ERROR);                                 */
            }else{
                if(proposalObj.Stage__c == EDPUtil.READY_FOR_SUBMISSION 
                    || proposalObj.Stage__c == EDPUtil.CREATED
                    || proposalObj.Stage__c == EDPUtil.ON_HOLD){
                    continue;
                }else {
                    proposalValidationMap.put(proposalObj.Id, CustomErrorMessages.INVALID_PROPOSAL_STAGE_FOR_SUBMISSION);
                }
            } 
        }
        return proposalValidationMap;
    }
    
    public static Proposal__c getProposalObject(Id proposalId){
        Set<Id> proposalIds = new Set<Id>();
        proposalIds.add(proposalId);
        Map<Id, Proposal__c> proposalMap = getProposalObjects(proposalIds);
        return proposalMap.get(proposalId);
    }
    
    public static Map<Id, Proposal__c> getProposalObjects(Set<Id> proposalIds){
        Map<Id, Proposal__c> proposalMap = new Map<Id, Proposal__c>([Select Id, name, Opportunity__c, Stage__c, Proposal_ID__c,Revised_SR_Signoff__c, cost_stack__c,
                                                                    New_Home_without_Utility_Bills__c, Original_Proposal_ID__r.Revised_Proposal__c,
                                                                    Deposit__c, Upfront_Payment__c, Original_Proposal_ID__c,System_Size_STC_DC__c, Completed_Approval_Process__c,
                                                                    Change_Order__c,Change_Order_ID__c,Electronically_Signed_Document__c,Credit_Status__c,
                                                                    Credit_team_notes__c, Conditional_Approval_Amount__c, ACH_Required__c, Total_Solar_Prepay_Required__c,
                                                                    Partner_Financed__c, Sales_Partner__c, Install_Partner__c, Utility__c, SR_Signoff__c,Revised_Proposal__c,
                                                                    Change_Order_With_New_Proposal__c, Change_Order_Type__c,Deal_Type__c,Generation_Asset__c,
                                                                    Change_Order_Information__c,agreement_type__c,
                                                                    Opportunity__r.Id, Opportunity__r.Name, Opportunity__r.StageName,Customer_Signoff_Date__c,
                                                                    Proposal_Source__c, signed__c,
                                                                    Primary_Customer__c, Current_Customer_Credit_Report__c, Opportunity__r.AccountId
                                                                    from Proposal__C where Id in :proposalIds]);
        return proposalMap;
    }

    public static Map<String, boolean> isDocumentSignedByCustomersAndPartners(Set<string> envelopIds){
        Map<String, boolean> envelopRecipientStatusMap = new Map<String, boolean>();
        System.debug('envelopIds: ' + envelopIds);
        for(dsfs__DocuSign_Status__c docuSignStatusObj : [Select Id, dsfs__DocuSign_Envelope_ID__c, (Select Id, IsDeleted, dsfs__DocuSign_Recipient_Email__c, Name, dsfs__Recipient_Status__c From dsfs__R00NS0000000WUO2MAO__r) from dsfs__DocuSign_Status__c where dsfs__DocuSign_Envelope_ID__c in :envelopIds]){
            if(docuSignStatusObj.dsfs__R00NS0000000WUO2MAO__r != null){
                Boolean recipientsSigned = true;                
                for(dsfs__DocuSign_Recipient_Status__c recipientObj :  docuSignStatusObj.dsfs__R00NS0000000WUO2MAO__r){
                    if(recipientObj.dsfs__DocuSign_Recipient_Email__c == Label.SunRun_DocuSign_Email){
                        continue;       
                    }
                    System.debug('recipientObj: ' + recipientObj);
                    if(recipientObj.dsfs__Recipient_Status__c != EDPUtil.COMPLETED){
                        recipientsSigned = false;
                        System.debug('recipientObj1: ' + recipientObj);
                    }
                }
                envelopRecipientStatusMap.put(docuSignStatusObj.dsfs__DocuSign_Envelope_ID__c, recipientsSigned);
            }
        }
        return envelopRecipientStatusMap;
    }

    //Calculate the parent proposal name for change orders.
    //Parent Proposal Name format: PXXXXXXX-A OR PXXXXXXX-B -- where A & B represents the product
    //Change order Proposal Name format: CXXXXXXX:YYY-A OR CXXXXXXX:YYY-A -- where A & B represents the product
    public Static String getParentProposalName(String proposalName){
        String parentProposalName = '';
        if(proposalName != null && ((proposalName.indexOf('C') == 0 ) || (proposalName.indexOf('H') == 0 ))){
            Integer colonPosition = proposalName.indexOf(':');
            Integer hyphenPosition = proposalName.lastIndexOf('-');
            if(colonPosition <=0 || hyphenPosition <= 0 || hyphenPosition+2 <= 0)
                return  parentProposalName;
                        
            String name1 = proposalName.substring(1,colonPosition);
            String name2 = proposalName.substring(hyphenPosition,hyphenPosition+2);
            parentProposalName = 'P' + name1 + name2;

        }
        return parentProposalName;
    }
    
    //This method will be invoked from Task trigger when the Partner Contact resolves the task.
    public static void updateProposalStageForPendingTasks(Set<Id> proposalIds){
        List<Proposal__c> proposalList = new List<Proposal__c> ();
        for(Proposal__c proposalObj : [Select Id, stage__c from Proposal__c where Id in:proposalIds]){
            proposalObj.stage__c = EDPUtil.PENDING_TASK_COMPLETED;
            proposalList.add(proposalObj);
        }
        
        if(proposalList.size() > 0 ){
            upsert proposalList;
        }
    }

    public static String getProposalNameForMasterDocs(String proposalName){
        String tempProposalName = proposalName;
        Integer index = tempProposalName.indexOf('-');
        proposalName = tempProposalName.substring(0, index);
        return proposalName;
    }
    
    
    public static Map<Id, Partner_Location__c> locationMap;
    public static Map<Id, Partner_Location__c> getHeadquartersLocation(Set<Id> accountIds) {
        if(locationMap != null && locationMap.size() > 0){
            for(Id accountId : accountIds){
                if(!locationMap.containsKey(accountId)){
                    locationMap = null;
                    break;
                }
            }           
        }
        if(locationMap == null){
            locationMap = new Map<Id, Partner_Location__c>();
            locationMap = new Map<Id, Partner_Location__c>([Select Id, name, Account__c, Description__c, 
                                                Headquarters__c from Partner_Location__c 
                                                where Account__c =:accountIds and Headquarters__c = true]);         
        }
        return locationMap;
    }

    
    
    private static Set<string> utilityCompaniesSet;
    public static Set<String> getUtilityCompanies(){
        if(utilityCompaniesSet == null || utilityCompaniesSet.size() == 0){
            utilityCompaniesSet = new Set<string>();
            for(Utility_Companies__c utilityCompanyObj : [Select Id, name from Utility_Companies__c]){
                utilityCompaniesSet.add(utilityCompanyObj.name);
            }           
        }
        return utilityCompaniesSet;
    }

    public static void performDocumentValidationsForSRApproval(Map<Id, Proposal__c> proposalMap, 
                                                            Map<Id, String> proposalValidationMap){
        
        Set<Id> proposalIds = proposalMap.keySet();
        Map<Id, Map<String, List<SR_Attachment__C>>> proposalToSRAttachmentMap = new Map<Id, Map<String, List<SR_Attachment__C>>>();
        Map<String, boolean> recipientSignedStatusMap = new Map<String, boolean>();
        recipientSignedStatusMap = getSRAttachmentInfoForProposals(proposalIds, proposalToSRAttachmentMap);
        System.debug('recipientSignedStatusMap2: ' + recipientSignedStatusMap);
        Boolean skipChangeOrders = false;
        checkRequiredDcouments(proposalMap, skipChangeOrders, recipientSignedStatusMap, 
                                proposalToSRAttachmentMap,proposalValidationMap);
        System.debug('proposalValidationMap: ' + proposalValidationMap);
    }
    
    public static Map<String, boolean>  getSRAttachmentInfoForProposals(Set<Id> proposalIdsForSRAttachments, 
                                                    Map<Id, Map<String, List<SR_Attachment__C>>> proposalToSRAttachmentMap){
        Map<String, boolean> recipientSignedStatusMap;
        Set<String> envelopIds = new Set<String>();
        if(proposalIdsForSRAttachments.size() > 0){
            String soqlStr;
            soqlStr = SRAttachmentManager.getSRAttachmentSOQL();
            soqlStr += '  WHERE Proposal__c IN :proposalIdsForSRAttachments ' ;
            soqlStr += '  and Active__c = true ' ;
            for(SR_Attachment__c srAttachmentObj : Database.query(soqlStr)){                            
                if(srAttachmentObj.Document_Classification__c != null){
                    Map<String, List<SR_Attachment__C>> srAttachmentsMap = proposalToSRAttachmentMap.containsKey(srAttachmentObj.Proposal__c) ? 
                                                            proposalToSRAttachmentMap.get(srAttachmentObj.Proposal__c) : new Map<String, List<SR_Attachment__C>>();

                    List<SR_Attachment__C> srAttachments = srAttachmentsMap.containskey(srAttachmentObj.Document_Classification__c) ? 
                                                                srAttachmentsMap.get(srAttachmentObj.Document_Classification__c) : new List<SR_Attachment__C>();
                    srAttachments.add(srAttachmentObj);
                    srAttachmentsMap.put(srAttachmentObj.Document_Classification__c, srAttachments);
                    proposalToSRAttachmentMap.put(srAttachmentObj.Proposal__c, srAttachmentsMap);
                }
                if(srAttachmentObj.Envelop_Id__c != null && srAttachmentObj.Envelop_Id__c != ''){
                    envelopIds.add(srAttachmentObj.Envelop_Id__c);
                }
            }
            recipientSignedStatusMap = isDocumentSignedByCustomersAndPartners(envelopIds);
            System.debug('recipientSignedStatusMap: ' + recipientSignedStatusMap);
        }       
        return recipientSignedStatusMap;
    }
    
    public static Map<Id, Id> getSubmittedByPartnerDetails(Set<id> submittedByUserIds){
        Map<Id, Id> submittedToPartnerMap = new Map<Id, Id>();
        Map<Id, Id> contactUserIdMap = new Map<Id, Id>();
        for(User userObj : [Select Id, contactId from user where id in :submittedByUserIds]){
            contactUserIdMap.put(userObj.contactId, userObj.Id);
        }
        for(Contact contactObj : [Select Id, accountId from Contact where id in :contactUserIdMap.keySet()]){
            Id userId = contactUserIdMap.get(contactObj.Id);
            submittedToPartnerMap.put(userId, contactObj.accountId);
        }       
        return submittedToPartnerMap;
    }
    
    public static String getPartnerType(Proposal__c prposalObj, Id partnerId){
        String partnerType = EDPUtil.FULL_SERVICE;
        if(partnerId == null || 
            (prposalObj.Sales_Partner__c == prposalObj.Install_Partner__c && prposalObj.Sales_Partner__c == partnerId)){
            partnerType = EDPUtil.FULL_SERVICE;
        }else if(prposalObj.Sales_Partner__c == partnerId){
            partnerType = EDPUtil.SALES;
        }else if(prposalObj.Install_Partner__c == partnerId){
            partnerType = EDPUtil.INSTALL;
        }
        return partnerType;
    }
    
    public static void checkRequiredDcouments(Map<Id, Proposal__c> proposalMap, Boolean skipChangeOrders,
                                                Map<String, boolean> recipientSignedStatusMap,
                                                Map<Id, Map<String, List<SR_Attachment__C>>> proposalToSRAttachmentMap,
                                                Map<Id, String> proposalValidationMap){

        Set<Id> submittedByUserIds = new Set<Id>();
        String sunrunId = System.Label.Sunrun_Inc_Id;
        for(Proposal__c proposalObj : proposalMap.values()){
            if(proposalObj.submitted_by__c != null){
                submittedByUserIds.add(proposalObj.submitted_by__c);
            }
        }
        Map<Id, Id> submittedPartnerMap = getSubmittedByPartnerDetails(submittedByUserIds);
        
        Set<Id> validProposalIds = proposalMap.keySet();
        //Verify the required required documents to Submit the Proposal
        Set<String> modes = new Set<String>();
        modes.add(EDPUtil.READ);
        modes.add(EDPUtil.EDIT);
        modes.add(EDPUtil.NONE);
        String strProposalApprovalLimit1 = Label.ProposalApprovalLimit1;
        if(strProposalApprovalLimit1 == null || strProposalApprovalLimit1 == ''){
            strProposalApprovalLimit1 = '15';
        }
        Decimal proposalLimit1 = Decimal.valueOf(strProposalApprovalLimit1);
        Set<String> utlityCompanies = getUtilityCompanies();
        for(Id proposalId : validProposalIds){
            Proposal__c tempProposalobj =  proposalMap.get(proposalId);
            String installPartner = (tempProposalobj.install_partner__C == null) ? '' : tempProposalobj.install_partner__C; 
            if(!String.isEmpty(installPartner) && installPartner.length() >= 15){
                installPartner = installPartner.substring(0,15);
            }
            if(tempProposalobj.EDP_Phase__c != 'EDP Phase-1'){
                continue;
            }
            Id partnerId = submittedPartnerMap.get(tempProposalobj.submitted_by__c);
            String partnerType = getPartnerType(tempProposalobj, partnerId);
            if(skipChangeOrders == true && (tempProposalobj.name.indexOf('H') == 0 ) &&  tempProposalobj.Change_Order__c == true){
                continue;
            }

            Map<String, Document_Classification__c> mandatoryDocumentClassificationMap;
            mandatoryDocumentClassificationMap = EDPDocumentSettings.getDocumentClassificationByCategroy(null, 
                                                                                                EDPDocumentSettings.MANDATORY_REQUIREMENTS,
                                                                                                modes, tempProposalobj.Sales_Partner__c, 
                                                                                                tempProposalobj.Install_Partner__c);

            Boolean missingRequiredDocumnets = false;
            Boolean missingSignatures = false;
            String missingDocuments = '';
            String missingSignatureDocs = '';
            if(mandatoryDocumentClassificationMap != null && mandatoryDocumentClassificationMap.size() > 0){
                missingRequiredDocumnets = false;
                missingSignatures = false;
                for(String documentType : mandatoryDocumentClassificationMap.keySet()){
                    Document_Classification__c documentClassificationObj = mandatoryDocumentClassificationMap.get(documentType);
                    List<Partner_Document_Relationship__c> partnerDocumentRelationships =   documentClassificationObj.Partner_Document_Relationships__r;
                    Boolean requiredDoc = false;
                    Partner_Document_Relationship__c ptrRelationshipObj;
                    for(Partner_Document_Relationship__c ptrDocsObj : partnerDocumentRelationships){
                        if(ptrDocsObj.partner_type__c == partnerType){
                            requiredDoc = true;
                            ptrRelationshipObj = ptrDocsObj;
                            break;
                        }
                    }

                    Boolean customerChangeOrder = false;
                    String proposalType = tempProposalobj.Change_Order_Information__c;
                    if(proposalType != null && proposalType.contains(ProposalUtil.CUSTOMER_CHANGE_ORDER)){
                        customerChangeOrder = true;
                    }

                    if( (requiredDoc == false) ||
                        ((documentClassificationObj.Document_Name__c == LARGE_SYSTEM_CONTRACT_REQUEST) && (tempProposalobj.System_Size_STC_DC__c == null || tempProposalobj.System_Size_STC_DC__c < proposalLimit1)) ||
                        ((documentClassificationObj.Document_Name__c == CUSTOMER_CHANGEORDER_COVER_SHEET) 
                        && (tempProposalobj.name == null || ((tempProposalobj.name.indexOf('C') != 0) && (customerChangeOrder == false)))) ||
                        (documentClassificationObj.Document_Name__c == EPBB && !utlityCompanies.contains(tempProposalobj.Utility__c)) ||
                        (documentClassificationObj.Document_Name__c == EDPUtil.UTILITY_BILL  && tempProposalobj.New_Home_without_Utility_Bills__c == true) || 
                        (documentClassificationObj.Document_Name__c == EDPUtil.LIVING_SPACE && tempProposalobj.New_Home_without_Utility_Bills__c != true) || 
                        (documentClassificationObj.Document_Name__c == 'EPC' && !String.isEmpty(installPartner) && sunrunId.contains(installPartner))){
                        continue;
                    }

                    Map<String, List<SR_Attachment__C>> srAttachmentsMap  = proposalToSRAttachmentMap.get(proposalId);
                    if(srAttachmentsMap != null){
                        if(srAttachmentsMap.containskey(documentClassificationObj.Id)){
                            List<SR_Attachment__C> tempSRAttachmentList = srAttachmentsMap.get(documentClassificationObj.Id);
                            Boolean hasSignatures = false;
                            
                            for(SR_Attachment__C srAttachmentObj : tempSRAttachmentList){
                                if(srAttachmentObj.active__c == true && 
                                    (srAttachmentObj.DocuSign_Status__c == EDPUtil.COMPLETED || srAttachmentObj.DocuSign_Status__c == EDPUtil.WET_SIGNED)){
                                    hasSignatures = true;
                                }
                            }
                            if(hasSignatures == false && ptrRelationshipObj != null){
                                if(ptrRelationshipObj.Customer_signature_required__c == true 
                                    || ptrRelationshipObj.Partner_signature_required__c == true
                                    || ptrRelationshipObj.SR_Ops_signature_required__c == true){
                                    System.debug('documentClassificationObj.Document_Name__c 1: ' + documentClassificationObj.Document_Name__c);
                                    missingDocuments += '\t' +  documentClassificationObj.Document_Name__c + '\t -- Signature required,'+ '\n';
                                }
                            }
                        }else{
                            System.debug('documentClassificationObj.Document_Name__c 2: ' + documentClassificationObj.Document_Name__c);
                            //missingRequiredDocumnets = true;
                            missingDocuments += '\t' + documentClassificationObj.Document_Name__c + ',' + '\n';
                        }
                    }else if(documentClassificationObj != null){
                        //missingRequiredDocumnets = true;
                        System.debug('documentClassificationObj.Document_Name__c 3: ' + documentClassificationObj.Document_Name__c);
                        missingDocuments += '\t' +  documentClassificationObj.Document_Name__c  + ','  + '\n';
                    }
                }

            }else{
                proposalValidationMap.put(proposalId, CustomErrorMessages.MISSGIN_ALL_REQUIRED_DOCS);
            }   
            
            String errorMessage = '';
            if(missingDocuments != null && missingDocuments != ''){
                errorMessage = CustomErrorMessages.MISSGIN_REQUIRED_DOCS + missingDocuments + '\n\n';
            }
            if(missingSignatureDocs != null && missingSignatureDocs != ''){
                errorMessage += CustomErrorMessages.REQUIRED_DOCS_NOT_SIGNED + missingSignatureDocs ;
            }
            
            if(errorMessage != null && errorMessage != ''){
                proposalValidationMap.put(proposalId, errorMessage);
            }
        }   
    }

    public static Boolean isPartnerPortalURL(){
        String redirectUrl = System.URL.getCurrentRequestUrl().getPath();
        Boolean isPartnerPortalURL = false;
        if(redirectUrl != null && redirectUrl.startsWith('/partner')){
            isPartnerPortalURL = true;
        }
        return isPartnerPortalURL;  
    }

    
    public static Map<Id, Proposal__c> getApprovedProposals(Set<Id> optyIds){
        String stageStr = EDPUtil.SR_OPS_APPROVED;
        Map<Id, Proposal__c> approvedProposalMap = new Map<Id, Proposal__c>();
        for(Proposal__c proposalObj : [Select Id, Stage__c, Original_Proposal_ID__c, Opportunity__c, Customer_Signoff_Date__c, 
                                        Current_Customer_Credit_Report__c, SR_Signoff__c, Revised_SR_Signoff__c,Change_Order_ID__c, 
                                        Proposal_ID__c from Proposal__c where Opportunity__c =:optyIds and stage__c =:stageStr]){

            approvedProposalMap.put(proposalObj.Original_Proposal_ID__c, proposalObj);
        }
        return approvedProposalMap;
    }
    public static string getAccessRights(){
        String Authorities='';
        Contact loggedInUserContact=PRMContactUtil.getLoginUserAccountAndContact();
        if(loggedInUserContact!=null){
            if(loggedInUserContact.As_Built__c=='Granted'){
                Authorities+='AsBuilt'+','; 
            }
            if(loggedInUserContact.Managing_Partner_AVL_Costs__c=='Granted'){
                Authorities+='ManagingPartnerAVLCosts'+',';
            }
            if(loggedInUserContact.Managing_Partner_AVL_Prices__c=='Granted'){
                Authorities+='ManagingPartnerAVLPrices'+',';
            }
            if(loggedInUserContact.Manual_Design__c=='Granted') {
                Authorities+='ManualDesign'+',';
            }
            if(loggedInUserContact.ePermitting__c=='Granted'){
                Authorities+='ePermitting'+',';
            }
            if(loggedInUserContact.Modify_Proposal__c=='Granted'){
                Authorities+='ModifyProposal'+',';
            }
            if(loggedInUserContact.Design_New_Proposal__c=='Granted'){
                Authorities+='DesignNewProposal'+',';
            }
            if(loggedInUserContact.Pricing_Only__c==true){
                Authorities+='PricingOnly'+',';
            }
            if(loggedInUserContact.Business_Division_Description__c=='Sunrun'){
                Authorities+='Sunrun'+',';
            }
            if(loggedInUserContact.Business_Division_Description__c=='AEE'){
                Authorities+='AEE'+',';
            }
            if(loggedInUserContact.eAudit__c=='Granted'){
                Authorities+='eAudit';
            }
            if(Authorities.endsWith(',')){
                Authorities=Authorities.substring(0, Authorities.length()-1);
            }
        }
        system.debug('---> Print Authorities'+authorities);
        return Authorities;
    }
    public class PendingTask{
        public String subject {get;set;}
        public String htmlBody {get;set;}
        public List<String> toAddressList {get;set;}
        public Task taskObj{get;set;}
        public PendingTask(){
            subject = '';
            htmlBody = '';
            toAddressList = new List<String>();
            taskObj = new Task();
        }
    }
    
    public class WelcomeDocS3Status{
        public String statusMessage;
        public WelcomeDocS3Status(){
            statusMessage = '';
        }
    }
    
}