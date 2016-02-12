public class DocuSignUtil {
    public static string ESIGN_IN_PERSON = 'InPerson';
    public static string ESIGN_EMAIL = 'Email';
    public static string ESIGN_INITIATE = 'signing_initiate';
    public static string PRIMARY='Primary';
    public static string SECONDARY='Secondary';
    public static string  INITIALSTAB= 'Initial Tab';
    public static string  TITLESTAB= 'Title Tab';
    public static string  SIGNTAB= 'Sign Tab';
    public static string  DATESTAB= 'Date Tab';
    public static string  FNAMETAB= 'FullName Tab';
    public static string  PHONESTAB= 'Phone Tab';
    public static string  NUMBERSTAB= 'Number Tab';
    public static string  DATESIGNEDTAB= 'Date Signed Tab';
    public static string MAILTAB= 'Email Tab';
    //public static string PARTNER='Partner';
    // public static string SROPS='SROps';
    
    public static void resetCustomerSignOffDate(List<String> envelopIds){
        String documentType  = EDPUtil.CUSTOMER_AGREEMENT;
        Set<Id> srAttachmentIds = new Set<Id>();
        for(dsfs__DocuSign_Status__c docuSignStatus : [Select Id, dsfs__DocuSign_Envelope_ID__c, SR_Attachment__c from dsfs__DocuSign_Status__c 
                                                       where dsfs__DocuSign_Envelope_ID__c in :envelopIds and SR_Attachment__c != null]){
                                                           srAttachmentIds.add(docuSignStatus.SR_Attachment__c);
                                                       }
        Set<Id> proposalIds = new Set<Id>();
        for(SR_Attachment__c srAttachmentObj : [Select Id, Proposal__c FROM SR_Attachment__c where Document_Type_Name__c =:documentType and Id in :srAttachmentIds ]){
            if(srAttachmentObj.proposal__c != null){
                proposalIds.add(srAttachmentObj.proposal__c);	
            }	
        }
        System.debug('proposalIds: ' + proposalIds);
        
        List<Proposal__c> modifiedProposals = new List<Proposal__c>();
        if(!proposalIds.isEmpty()){
            for(Proposal__c proposalObj : [Select Id, Customer_SignOff_Date__c	from Proposal__c where Id in :proposalIds]){
                proposalObj.Customer_SignOff_Date__c = null;
                modifiedProposals.add(proposalObj);
            }	
        }
        System.debug('modifiedProposals: ' + modifiedProposals);
        if(!modifiedProposals.isEmpty()){
            update modifiedProposals;
        }
    }
    
    public static Map<Id, dsfs__DocuSign_Recipient_Status__c> getDocuSignRecipients(Set<String> envelopIds, Boolean documentStatus){
        Map<Id, dsfs__DocuSign_Recipient_Status__c> recipientMap = new Map<Id, dsfs__DocuSign_Recipient_Status__c>([Select Id, Update_Document__c, dsfs__Envelope_Id__c from 
                                                                                                                    dsfs__DocuSign_Recipient_Status__c where dsfs__Envelope_Id__c in :envelopIds and 
                                                                                                                    Update_Document__c =:documentStatus ]);
        return recipientMap;
    }
    
    @future
    public static void updateProposalsAsynchronously(Map<String, String> recipientEnvelopMap){
        updateProposals(recipientEnvelopMap);
    }
    
    public static void notifyProposalUpdateError(Map<String, String> recipientEnvelopMap, String errorDescription){
        List<String> toAddresses = new List<String>();
        toAddresses.add(Label.Sunrun_SFDC_Admin);
        
        String subject = 'Unable to update the proposals: ';
        String emailBody = '';		
        
        String htmlBody = '<html>';
        htmlBody += EmailService.getHTMLHeader();
        htmlBody += '<p></p>';
        htmlBody += 'Salesforce is processing the following Proposals in a batch job. <br/>';
        htmlBody += '<p></p>';
        emailBody += 'Proposals: ' + recipientEnvelopMap + '<br/>';
        emailBody += '<br/>';
        htmlBody += emailBody;		
        
        htmlBody += '<p/>';
        htmlBody += 'Error: <br/> ';
        htmlBody += 'Description: ' + errorDescription + '<br/>';
        htmlBody += EmailService.getHTMLFooter();
        htmlBody += '</html>';
        PRMEmailManager.sendEmail(toAddresses, subject, htmlBody);
    }
    
    public static void updateProposals(Map<String, String> recipientEnvelopMap){
        
        System.debug('recipientEnvelopMap: ' + recipientEnvelopMap);
        String sunrunOpsEmail = Label.SunRun_DocuSign_Email;
        Set<String> Names = new Set<String>();
        Set<String> emailIds = new Set<String>();
        Map<String, DateTime> envelopToSignedDate = new Map<String, DateTime>();
        Map<String, Map<String,dsfs__DocuSign_Recipient_Status__c>> envelopToRecipientMap = new Map<String, Map<String,dsfs__DocuSign_Recipient_Status__c>>();
        for(dsfs__DocuSign_Recipient_Status__c recipientStatusObj : [Select Id, dsfs__Envelope_Id__c, dsfs__Recipient_Status__c, dsfs__DocuSign_Recipient_Email__c, 
                                                                     In_Person_Email_Id__c, dsfs__Date_Signed__c, 
                                                                     dsfs__DocuSign_Recipient_Id__c, Name, dsfs__DocuSign_Routing_Order__c from dsfs__DocuSign_Recipient_Status__c 
                                                                     where dsfs__Envelope_Id__c =:recipientEnvelopMap.values() 
                                                                     and dsfs__DocuSign_Recipient_Id__c =:recipientEnvelopMap.keySet()]){
                                                                         
                                                                         String tempEmailId = (recipientStatusObj.In_Person_Email_Id__c != null && recipientStatusObj.In_Person_Email_Id__c !=  '') ? recipientStatusObj.In_Person_Email_Id__c : recipientStatusObj.dsfs__DocuSign_Recipient_Email__c;
                                                                         Map<String, dsfs__DocuSign_Recipient_Status__c> recipientMap = envelopToRecipientMap.containsKey(recipientStatusObj.dsfs__Envelope_Id__c) ?
                                                                             envelopToRecipientMap.get(recipientStatusObj.dsfs__Envelope_Id__c) 
                                                                             : new Map<String, dsfs__DocuSign_Recipient_Status__c>();
                                                                         recipientMap.put(recipientStatusObj.dsfs__DocuSign_Recipient_Id__c, recipientStatusObj);
                                                                         envelopToRecipientMap.put(recipientStatusObj.dsfs__Envelope_Id__c, recipientMap);
                                                                         if(tempEmailId != null &&
                                                                            tempEmailId != ''){
                                                                                Names.add(recipientStatusObj.Name);
                                                                                emailIds.add(tempEmailId);
                                                                            }
                                                                         
                                                                     }
        Map<String, String> contactRecordTypeMap = new Map<String, String>();
        for(Contact contactObj : [Select Id, email, name, recordTypeId from Contact where name in :Names and email in :emailIds]){
            contactRecordTypeMap.put(contactObj.email, contactObj.recordTypeId);
        }
        
        Set<String> customerSignOffEnvelopes = new Set<String>();
        Set<String> customerSignOffDateEnvelopes = new Set<String>();
        Map<Id, RecordType> contactRecordTypes = PRMLibrary.getContactRecordTypes();
        for(String recipientIdStr : recipientEnvelopMap.keySet()){
            String envelopIdStr = recipientEnvelopMap.get(recipientIdStr);
            Map<String, dsfs__DocuSign_Recipient_Status__c> recipientMap = envelopToRecipientMap.get(envelopIdStr);
            if(recipientMap != null && recipientMap.containsKey(recipientIdStr)){
                Integer customerNumber = 0;
                Integer signedCusomers = 0;
                Integer partnerSigned = 0;
                for(dsfs__DocuSign_Recipient_Status__c recipientObj : recipientMap.values()){
                    String tempEmailId = (recipientObj.In_Person_Email_Id__c != null && recipientObj.In_Person_Email_Id__c !=  '') ? recipientObj.In_Person_Email_Id__c : recipientObj.dsfs__DocuSign_Recipient_Email__c;
                    String contactRecordTypesId =  contactRecordTypeMap.get(tempEmailId);
                    RecordType recordTypeObj = contactRecordTypes.get(contactRecordTypesId);
                    if(recordTypeObj != null){
                        if(recordTypeObj.name == 'Residential'){
                            customerNumber ++;
                            if(recipientObj.dsfs__Recipient_Status__c == 'Completed'){
                                signedCusomers++;
                                DateTime dateSigned = (recipientObj.dsfs__Date_Signed__c == null) ? Datetime.now() : recipientObj.dsfs__Date_Signed__c;
                                DateTime tempDateSigned = envelopToSignedDate.get(recipientObj.dsfs__Envelope_Id__c);
                                if(dateSigned != null && (tempDateSigned == null || dateSigned > tempDateSigned)){
                                    envelopToSignedDate.put(envelopIdStr, dateSigned);
                                }
                            }
                        }else if((recordTypeObj.name == PRMLibrary.PARTNER || recordTypeObj.name == PRMLibrary.EMPLOYEE ) && recipientObj.dsfs__Recipient_Status__c == 'Completed'){
                            partnerSigned++;
                            DateTime dateSigned = recipientObj.dsfs__Date_Signed__c;
                            DateTime tempDateSigned = envelopToSignedDate.get(recipientObj.dsfs__Envelope_Id__c);
                            if(dateSigned != null && (tempDateSigned == null || dateSigned > tempDateSigned)){
                                envelopToSignedDate.put(envelopIdStr, dateSigned);
                            }
                        }						
                    }						
                }
                if(customerNumber > 0 && customerNumber == signedCusomers){
                    customerSignOffDateEnvelopes.add(envelopIdStr);
                }
                if((customerNumber > 0 && customerNumber == signedCusomers) || partnerSigned > 0){
                    customerSignOffEnvelopes.add(envelopIdStr);
                }
            }
            
        }	
        System.debug('customerSignOffEnvelopes: ' + customerSignOffEnvelopes);
        Map<String, String> documentTypeNameToEnvelopId = new Map<String, String>();
        if(customerSignOffEnvelopes.size() > 0)	{
            Set<String> documentTypeNames = new Set<String>();
            documentTypeNames.add(EDPUtil.CUSTOMER_AGREEMENT);
            documentTypeNames.add(EDPUtil.CHANGE_ORDER_COVER_SHEET);
            documentTypeNames.add(EDPUtil.EPC);
            Map<Id, SR_Attachment__c> srAttachmentMap = SRAttachmentManager.getSRAttachmentsByEnvelopId(recipientEnvelopMap.values(), documentTypeNames);			
            Set<Id> proposalIds = new Set<Id>();
            Map<String, Id> documentToProposalMap = new Map<String, Id>();
            for(SR_Attachment__c srAttachmentObj : srAttachmentMap.values()){
                if(srAttachmentObj.proposal__c != null){
                    //proposalIds.add(srAttachmentObj.proposal__c);	
                    documentToProposalMap.put(srAttachmentObj.Document_Type_Name__c, srAttachmentObj.proposal__c);
                    if(srAttachmentObj.Envelop_Id__c != null && srAttachmentObj.Envelop_Id__c != ''){
                        documentTypeNameToEnvelopId.put(srAttachmentObj.Document_Type_Name__c, srAttachmentObj.Envelop_Id__c);
                    }
                }	
            }
            
            List<Proposal__c> modifiedProposals = new List<Proposal__c>();
            Map<Id, Proposal__c> proposalMap = new Map<Id, Proposal__c>();
            if(documentToProposalMap.size() > 0 ){
                
                proposalMap = new Map<Id, Proposal__c>([Select Id, name, Assigne__c, Homeowner_Name__c, Assigne__r.name, Assigne__r.email, 
                                                        Signed__c, Change_Order_Information__c, Proposal_Source__c,Original_Proposal_ID__c, 
                                                        Revised_Customer_SignOff_Date__c,Customer_SignOff_Date__c	from Proposal__c 
                                                        where Id in :documentToProposalMap.values()]);
                for(String documentTypeName : documentToProposalMap.keySet()){
                    Id proposalId = documentToProposalMap.get(documentTypeName);
                    Proposal__c proposalObj = proposalMap.get(proposalId);
                    String envelopId = documentTypeNameToEnvelopId.get(documentTypeName);
                    Datetime customerSignOffTime;
                    if(envelopId != null && envelopId != ''){
                        customerSignOffTime = envelopToSignedDate.get(envelopId);
                    }
                    
                    if( (proposalObj != null && documentTypeName == EDPUtil.CUSTOMER_AGREEMENT) 
                       || (proposalObj != null && documentTypeName == EDPUtil.CHANGE_ORDER_COVER_SHEET)
                       || (proposalObj != null && documentTypeName == EDPUtil.EPC)){
                           Boolean modified = false;
                           System.debug('customerSignOffDateEnvelopes: ' + customerSignOffDateEnvelopes);
                           if(documentTypeName == EDPUtil.CUSTOMER_AGREEMENT && customerSignOffTime != null 
                              && proposalObj.Customer_SignOff_Date__c == null
                              && customerSignOffDateEnvelopes.contains(envelopId)){
                                  modified = true;
                                  proposalObj.Customer_SignOff_Date__c = customerSignOffTime;
                              }
                           System.debug('1: proposalObj.signed__c: ' + proposalObj.signed__c);
                           System.debug('proposalObj: ' + proposalObj);
                           System.debug('documentTypeName: ' + documentTypeName);
                           if(ProposalUtil.canUpdateProposalSignedStatus(proposalObj, documentTypeName) == true){
                               proposalObj.signed__c = true;	
                               modified = true;					
                           }
                           System.debug('2: proposalObj.signed__c: ' + proposalObj.signed__c );
                           if( proposalObj != null 
                              && (documentTypeName == EDPUtil.CHANGE_ORDER_COVER_SHEET || documentTypeName == EDPUtil.CUSTOMER_AGREEMENT)  
                              &&  customerSignOffDateEnvelopes.contains(envelopId) ){ // && proposalObj.Original_Proposal_ID__c != null
                                  System.debug('3: Revised_Customer_SignOff_Date__c: ' + proposalObj.signed__c);
                                  modified = true;
                                  proposalObj.Revised_Customer_SignOff_Date__c = DateTime.now();
                              }
                           
                           if(modified){
                               modifiedProposals.add(proposalObj);	
                           }					
                       }
                    
                    if(proposalObj != null && ((proposalObj.Name.indexOf('C') == 0) || (proposalObj.Name.indexOf('H') == 0))
                       && proposalObj.Assigne__c != null && documentTypeName == EDPUtil.CHANGE_ORDER_COVER_SHEET){
                           System.debug('proposalObj: ' + proposalObj);
                           List<String> toAddressList = new List<String>();
                           toAddressList.add(proposalObj.Assigne__r.email);
                           String subject = proposalObj.Homeowner_Name__c + ' has eSigned Change Order ' +  proposalObj.Name ;		                
                           String htmlBody = PRMEmailManager.getChangeOrderHTMLBody(proposalObj);
                           PRMEmailManager.sendEmail(toAddressList, subject, htmlBody, Label.Sunrun_Documents);           
                       }
                }
                
                System.debug('modifiedProposals1: ' + modifiedProposals);
                if(modifiedProposals.size() > 0){
                    update modifiedProposals;
                }				
            }
        }
        
    }
    
    public Static String getBaseURL() {
        String baseURL = EDPUtil.getBaseURL();
        return baseURL;
    }
    
    public static SR_Attachment__c getSRAttachmentForDocument(String  proposalId, String documentType){
        SR_Attachment__c srAttachment = null;
        
        String soqlStr = SRAttachmentManager.getSRAttachmentSOQL();
        soqlStr += '  where Proposal__c =:proposalId AND active__c = true ' ;
        //  soqlStr += '  AND Document_Source__c = :documentSource ' ;
        soqlStr += '  AND Document_Type_Name__c =:documentType' ;
        system.debug('soqlStrsoqlStr' +  soqlStr);
        for(SR_Attachment__c tempSRAttachment : Database.query(soqlStr)){
            srAttachment =tempSRAttachment;
        }
        system.debug('srAttachment' + srAttachment);
        return srAttachment;
    }
    
    
    public static SR_Attachment__c getSRAttachmentsForESignature(String proposalId, String documentType){
        system.debug('documentTypedocumentType>' + documentType);
        SR_Attachment__c srAttachment = null;
        String soqlStr = SRAttachmentManager.getSRAttachmentSOQL();
        soqlStr += '  where Proposal__c =:proposalId AND active__c = true ' ;
        soqlStr += '  AND Document_Type_Name__c =:documentType' ;
        for(SR_Attachment__c tempSRAttachment : Database.query(soqlStr)){
            if(srAttachment == null){
                srAttachment = tempSRAttachment;
            }else{
                if(tempSRAttachment.Document_Source__c != EDPUtil.PROPOSAL_TOOL_SOURCE){
                    srAttachment = tempSRAttachment;
                }
            }														
        }
        return srAttachment;
    }
    
    public static SR_Attachment__c getSRAttachmentsForVoid(String proposalId, String documentType){
        SR_Attachment__c srAttachment = null;
        String documentSource = EDPUtil.PROPOSAL_TOOL_SOURCE;
        
        String soqlStr = SRAttachmentManager.getSRAttachmentSOQL();
        soqlStr += '  where Proposal__c =:proposalId AND active__c = true ' ;
        soqlStr += '  AND Document_Source__c != :documentSource ' ;
        soqlStr += '  AND Document_Type_Name__c =:documentType ' ;
        for(SR_Attachment__c tempSRAttachment : Database.query(soqlStr)){
            srAttachment = tempSRAttachment;														
        }
        return srAttachment;
    }
    
    public static SR_Attachment__c getSRAttachment(String proposalId, String documentType){
        SR_Attachment__c srAttachment;
        String documentSource = EDPUtil.PROPOSAL_TOOL_SOURCE;
        
        String soqlStr = SRAttachmentManager.getSRAttachmentSOQL();
        soqlStr += '  where Proposal__c =:proposalId AND active__c = true ' ;
        soqlStr += '  AND Document_Source__c != :documentSource ' ;
        soqlStr += '  AND Document_Type_Name__c =:documentType limit 1 ' ;
        
        List<SR_Attachment__c> srAttachmentList = Database.query(soqlStr);
        if(srAttachmentList != null && srAttachmentList.size() > 0){
            srAttachment = srAttachmentList[0];
        }
        return srAttachment;
    }
    
    public static String createResendJSONEnvelopString(String envelopId){
        ResendEnvelop resendEnvelopObj = new ResendEnvelop();
        resendEnvelopObj.signers = new List<ResendSigner>();
        for(dsfs__DocuSign_Recipient_Status__c recipientStatusObj : [Select Id, dsfs__Recipient_Status__c, dsfs__DocuSign_Recipient_Email__c, Name, 
                                                                     dsfs__DocuSign_Routing_Order__c from dsfs__DocuSign_Recipient_Status__c 
                                                                     where dsfs__Envelope_Id__c =:envelopId order by dsfs__DocuSign_Routing_Order__c asc]){
                                                                         if(recipientStatusObj.dsfs__Recipient_Status__c == 'Sent' 
                                                                            || recipientStatusObj.dsfs__Recipient_Status__c == 'Delivered'){
                                                                                ResendSigner resendSignerObj = new ResendSigner();
                                                                                resendSignerObj.email = recipientStatusObj.dsfs__DocuSign_Recipient_Email__c;
                                                                                resendSignerObj.name = recipientStatusObj.Name;
                                                                                resendSignerObj.recipientId = Integer.valueOf(recipientStatusObj.dsfs__DocuSign_Routing_Order__c);
                                                                                resendEnvelopObj.signers.add(resendSignerObj);
                                                                            }
                                                                         
                                                                     }
        String JSONString = JSON.serialize(resendEnvelopObj);
        System.debug('JSONString: ' + JSONString);
        return JSONString;
    }
    
    
    public static String createVoidJSONEnvelopString(){
        VoidEnvelop voidEnvelopObj = new VoidEnvelop();
        voidEnvelopObj.status = 'voided';
        voidEnvelopObj.voidedReason = 'Voided by ' + UserInfo.getUserName();
        
        String JSONString = JSON.serialize(voidEnvelopObj);
        System.debug('JSONString: ' + JSONString);
        return JSONString;	
    }
    
    public static String createResendJSONEnvelopString
        (Contact primaryContact, Contact secondaryContact,
         Contact partnerContact, String sunrunRecipientName, 
         String sunrunRecipientEmail){
             
             ResendEnvelop envelopObj = new ResendEnvelop();
             List<ResendSigner> signers = new List<ResendSigner>();
             envelopObj.signers = signers;		
             Integer recipientId = 1;
             Integer routingOrder = 1;
             addResendSigner(recipientId, routingOrder, primaryContact.name, primaryContact.email, envelopObj);
             System.debug('secondaryContact: ' + secondaryContact);
             if(secondaryContact != null){
                 recipientId ++;
                 routingOrder ++;
                 addResendSigner(recipientId, routingOrder, secondaryContact.name, secondaryContact.email, envelopObj);
             }	
             recipientId ++;
             routingOrder ++;
             addResendSigner(recipientId, routingOrder, partnerContact.name, partnerContact.email, envelopObj);
             
             recipientId ++;
             routingOrder ++;
             addResendSigner(recipientId, routingOrder, SunrunRecipientName, sunrunRecipientEmail, envelopObj);
             
             String envelopString = '';
             String JSONString = JSON.serialize(envelopObj);
             System.debug('JSONString: ' + JSONString);
             return JSONString;	
         }
    
    public static String createEmbeddedSigningJSONEnvelopString(In_Person_Recipient__c inpersonObj, String envelopId, Integer recipientId){
        EmbeddedSigningRequest embeddedSigningReuqest = new EmbeddedSigningRequest();
        if(inpersonObj != null){
            embeddedSigningReuqest.email = inpersonObj.Host_Email__c;
            embeddedSigningReuqest.userName = inpersonObj.Host_Name__c;
            embeddedSigningReuqest.clientUserId = inpersonObj.Client_User_Id__c;		
            String baseURL = EDPUtil.getBaseURL();
            if(ApexPages.currentPage() != null){
                baseURL = ApexPages.currentPage().getParameters().get('baseUrl');
            }
            String newBaseUrl = Label.PartnerPortalSiteUrl;
            newBaseUrl += '/apex/InPersonSigningRedirect?recipientId=' + recipientId + '&envelopId=' + envelopId + '&baseUrl='+baseURL;
            embeddedSigningReuqest.returnUrl = newBaseUrl;
        }
        String JSONString = JSON.serialize(embeddedSigningReuqest);
        return JSONString;		
    }
    
    public static String createEmbeddedSigningJSONEnvelopString(String envelopId, Integer recipientId){
        List<In_Person_Recipient__c> inpersonList = [Select Id, Client_User_Id__c, Envelop_Id__c, Host_Email__c, Host_Name__c, In_Person_Contact__c, 
                                                     Recipient_Id__c, Routing_Order__c, Signer_Email__c, Signer_Name__c from In_Person_Recipient__c 
                                                     where Envelop_Id__c =:envelopId and Routing_Order__c =:recipientId limit 1];
        String JSONString = '';
        if(inpersonList.size() > 0){
            JSONString = createEmbeddedSigningJSONEnvelopString(inpersonList[0], envelopId, recipientId);
        }
        return JSONString;
    }
    
    
    public static String createJSONEnvelopString
        (Boolean includeTabs, Integer documentId, String eSigningType,
         String hostName, String hostEmail, SR_Attachment__c srAttachment,
         Contact primaryContact, Contact secondaryContact,
         Contact partnerContact, String sunrunRecipientName, 
         String sunrunRecipientEmail,List<In_Person_Recipient__c> inpersonRecipientList){
             
             CustomerAgreementEnvelop envelopObj = new CustomerAgreementEnvelop();
             envelopObj.status = 'Sent';
             String forStr = (primaryContact != null && primaryContact.Preferred_Language__c == 'Spanish') ? ' para ' : ' for ';
             
             envelopObj.emailSubject = srAttachment.Document_Type_Name__c + ' REPLACE_FOR ' + '[[RecipientName]] (' + srAttachment.proposal__r.name + ')';
             envelopObj.emailBlurb = '\t Please review & sign your document sent on behalf of Sunrun Inc.';
             envelopObj.emailBlurb += ' Thank you for going solar with Sunrun! You can click on the link below to sign your Sunrun agreement.';
             envelopObj.emailBlurb += ' If you have any questions, please contact your solar sales consultant.';
             
             envelopObj.emailBlurb = (primaryContact != null && primaryContact.Preferred_Language__c == 'Spanish') ? '\t Revisa y firmar el documento enviado en nombre de Sunrun Inc.' : '\t Please review & sign your document sent on behalf of Sunrun Inc.';
             envelopObj.emailBlurb += (primaryContact != null && primaryContact.Preferred_Language__c == 'Spanish') ? ' Gracias por ir solar con Sunrun usted! Puede hacer clic en el enlace de abajo para firmar su contrato de Sunrun.' : ' Thank you for going solar with Sunrun! You can click on the link below to sign your Sunrun agreement.';
             envelopObj.emailBlurb += (primaryContact != null && primaryContact.Preferred_Language__c == 'Spanish') ? ' Si usted tiene alguna pregunta, por favor p?ngase en contacto con su asesor de ventas solar.' : ' If you have any questions, please contact your solar sales consultant.';
             
             List<Document> documents = new List<Document>();
             Document documentObj = new Document();
             documentObj.documentId = documentId;
             documentObj.name = srAttachment.Document_Name__c;
             documents.add(documentObj);
             envelopObj.documents = documents;
             
             Integer recipientId = 1;
             Integer routingOrder = 1;
             RecipientList recipientListObj = new RecipientList();
             envelopObj.recipients = recipientListObj;
             List<Signer> signers = new List<Signer>();
             envelopObj.recipients.signers = signers;
             
             Boolean changeOrderCoverSheet = false;
             Boolean isCostcoDoc = isCostcoDocument(srAttachment);
             if(srAttachment.Document_Type_Name__c == EDPUtil.CUSTOMER_CHANGEORDER_COVER_SHEET){
                 changeOrderCoverSheet = true;
                 initializeRequiredTagsByDocType(srAttachment.Document_Type_Name__c, srAttachment.proposal__r.Agreement_Type__c, srAttachment.Proposal__R.Opportunity__r.Purchased_Thru__c, srAttachment.proposal__r.Program_Type__c);
             }
             Boolean isCustomerAgreement = false;
             if(srAttachment.Document_Type_Name__c == EDPUtil.CUSTOMER_AGREEMENT){
                 isCustomerAgreement = true;
                 initializeRequiredTagsByDocType(srAttachment.Document_Type_Name__c, srAttachment.proposal__r.Agreement_Type__c, srAttachment.Proposal__R.Opportunity__r.Purchased_Thru__c, srAttachment.proposal__r.Program_Type__c);
                 
             }		
            
             if(primaryContact != null){
                 In_Person_Recipient__c primaryRecipient = new In_Person_Recipient__c();
                 if((srAttachment.Document_Type_Name__c== EDPUtil.NEM_FORM || srAttachment.Document_Type_Name__c== EDPUtil.REBATE_FORM)){
                     initializeDocusignTagsCustomerAndPartner(includeTabs, recipientId, routingOrder, eSigningType, hostName, hostEmail, srAttachment, primaryContact, envelopObj, primaryRecipient,srAttachment.proposal__r.Utility__c,PRIMARY);
                  }else{
                     addTabsForCustomer(includeTabs, recipientId, routingOrder, eSigningType, hostName, hostEmail, srAttachment, primaryContact, envelopObj, primaryRecipient);
                 }
                 recipientId ++;
                 routingOrder ++;
                 if(eSigningType == DocuSignUtil.ESIGN_IN_PERSON){
                     inpersonRecipientList.add(primaryRecipient);
                 }
             }
             
             System.debug('secondaryContact: ' + secondaryContact);
             if(secondaryContact != null){
                 In_Person_Recipient__c secondaryRecipient = new In_Person_Recipient__c();
                 if((srAttachment.Document_Type_Name__c== EDPUtil.NEM_FORM || srAttachment.Document_Type_Name__c== EDPUtil.REBATE_FORM)){
                     initializeDocusignTagsCustomerAndPartner(includeTabs, recipientId, routingOrder, eSigningType, hostName, hostEmail, srAttachment, secondaryContact, envelopObj, secondaryRecipient,srAttachment.proposal__r.Utility__c,SECONDARY);
                 }else{
                   addTabsForCustomer(includeTabs, recipientId, routingOrder, eSigningType, hostName, hostEmail, srAttachment, secondaryContact, envelopObj, secondaryRecipient);
                 }
                 recipientId ++;
                 routingOrder ++;
                 if(eSigningType == DocuSignUtil.ESIGN_IN_PERSON){
                     inpersonRecipientList.add(secondaryRecipient);
                 }
             }	
             
             if(partnerContact != null){
                 In_Person_Recipient__c partnerRecipient = new In_Person_Recipient__c();
                 if((srAttachment.Document_Type_Name__c== EDPUtil.NEM_FORM || srAttachment.Document_Type_Name__c== EDPUtil.REBATE_FORM)){
                     initializeDocusignTagsCustomerAndPartner(includeTabs, recipientId, routingOrder, eSigningType, hostName, hostEmail, srAttachment, partnerContact, envelopObj, partnerRecipient,srAttachment.proposal__r.Utility__c,'Partner');
                 }
                 else
                 {
                       addTabsForPartner(documentId, includeTabs, recipientId, routingOrder, eSigningType, srAttachment, partnerContact, envelopObj, partnerRecipient);
                   
                 }
                 recipientId ++;
                 routingOrder ++;			
                 if(eSigningType == DocuSignUtil.ESIGN_IN_PERSON){
                     inpersonRecipientList.add(partnerRecipient);
                 }
             }
             if(SunrunRecipientName != null && SunrunRecipientName != '' 
                && sunrunRecipientEmail != null && sunrunRecipientEmail != ''){
                    In_Person_Recipient__c partnerRecipient = new In_Person_Recipient__c();
                    if((srAttachment.Document_Type_Name__c== EDPUtil.NEM_FORM|| srAttachment.Document_Type_Name__c== EDPUtil.REBATE_FORM)){
                       initializeDocusignTagsForSunRunOps(srAttachment.Document_Type_Name__c, includeTabs, recipientId, routingOrder, eSigningType, SunrunRecipientName, sunrunRecipientEmail, envelopObj,
                                            changeOrderCoverSheet, partnerRecipient, srAttachment.proposal__r.Agreement_Type__c ,srAttachment.proposal__r.Utility__c,'SROps',srAttachment.proposal__r.state__c);
                    }else{
                        
                         addTabsForSunRunOPS(srAttachment.Document_Type_Name__c, includeTabs, recipientId, routingOrder, eSigningType, SunrunRecipientName, sunrunRecipientEmail, envelopObj,
                                            changeOrderCoverSheet, partnerRecipient, isCostcoDoc);
                    }
                    if(eSigningType == DocuSignUtil.ESIGN_IN_PERSON){
                        inpersonRecipientList.add(partnerRecipient);
                    }
                }
             
             //envelopObj.emailSubject = '';
             envelopObj.emailBlurb = '';
             
             String envelopString = '';
             String JSONString = JSON.serialize(envelopObj);
             System.debug('JSONString: ' + JSONString);
             return JSONString;	
         }
    
    private static void initializeInPersonRecipient(InpersonSigner contactSigner, In_Person_Recipient__c inpersonRecipient){
        inpersonRecipient.Recipient_Id__c = contactSigner.recipientId;
        inpersonRecipient.Routing_Order__c = contactSigner.routingOrder;
        inpersonRecipient.Host_Email__c = contactSigner.hostEmail;
        inpersonRecipient.Host_Name__c = contactSigner.hostName;
        inpersonRecipient.Client_User_Id__c = contactSigner.clientUserId;
    }
    
    public static void setCustomerEmailBody(Contact contactObj,  CustomerAgreementEnvelop envelopObj, InpersonSigner contactSigner){
        String forStr = (contactObj.Preferred_Language__c == 'Spanish') ? ' para ' : ' for ';
        contactSigner.emailNotification.emailSubject = envelopObj.emailSubject.replace('REPLACE_FOR', forStr);
        contactSigner.emailNotification.supportedLanguage =  (contactObj.Preferred_Language__c == 'Spanish') ? 'es_MX' : 'en';	
        contactSigner.emailNotification.emailBody = (contactObj.Preferred_Language__c == 'Spanish') ? '\t Revisa y firmar el documento enviado en nombre de Sunrun Inc.' : '\t Please review & sign your document sent on behalf of Sunrun Inc.';
        contactSigner.emailNotification.emailBody += (contactObj.Preferred_Language__c == 'Spanish') ? ' Gracias por ir solar con Sunrun usted! Puede hacer clic en el enlace de abajo para firmar su contrato de Sunrun.' : ' Thank you for going solar with Sunrun! You can click on the link below to sign your Sunrun agreement.';
        contactSigner.emailNotification.emailBody += (contactObj.Preferred_Language__c == 'Spanish') ? ' Si usted tiene alguna pregunta, por favor p?ngase en contacto con su asesor de ventas solar.' : ' If you have any questions, please contact your solar sales consultant.';
    } 
    
    public static void setCustomerEmailBody(Contact contactObj,  CustomerAgreementEnvelop envelopObj, Signer contactSigner){
        String forStr = (contactObj.Preferred_Language__c == 'Spanish') ? ' para ' : ' for ';
        contactSigner.emailNotification.emailSubject = envelopObj.emailSubject.replace('REPLACE_FOR', forStr);
        contactSigner.emailNotification.supportedLanguage =  (contactObj.Preferred_Language__c == 'Spanish') ? 'es_MX' : 'en';	
        contactSigner.emailNotification.emailBody = (contactObj.Preferred_Language__c == 'Spanish') ? '\t Revisa y firmar el documento enviado en nombre de Sunrun Inc.' : '\t Please review & sign your document sent on behalf of Sunrun Inc.';
        contactSigner.emailNotification.emailBody += (contactObj.Preferred_Language__c == 'Spanish') ? ' Gracias por ir solar con Sunrun usted! Puede hacer clic en el enlace de abajo para firmar su contrato de Sunrun.' : ' Thank you for going solar with Sunrun! You can click on the link below to sign your Sunrun agreement.';
        contactSigner.emailNotification.emailBody += (contactObj.Preferred_Language__c == 'Spanish') ? ' Si usted tiene alguna pregunta, por favor p?ngase en contacto con su asesor de ventas solar.' : ' If you have any questions, please contact your solar sales consultant.';
    } 
    
    public static void addTabsForCustomer
        (Boolean includeTabs, Integer recipientId , Integer routingOrder,
         String eSignType, String hostName, String hostEmail,
         SR_Attachment__c srAttachment, Contact contactObj, 
         CustomerAgreementEnvelop envelopObj,In_Person_Recipient__c inpersonRecipient){
             
             Boolean changeOrderCoverSheet = false;
             if(srAttachment.Document_Type_Name__c == EDPUtil.CUSTOMER_CHANGEORDER_COVER_SHEET){
                 changeOrderCoverSheet = true;
             }
             Boolean isCustomerAgreement = false;
             if(srAttachment.Document_Type_Name__c == EDPUtil.CUSTOMER_AGREEMENT){
                 isCustomerAgreement = true;
             }
             TabList tabslistObj = new TabList();
             if(eSignType == DocuSignUtil.ESIGN_IN_PERSON){
                 InpersonSigner contactSigner = new InpersonSigner();
                 envelopObj.recipients.inPersonSigners.add(contactSigner);
                 contactSigner.tabs = tabslistObj;	
                 
                 contactSigner.recipientId = recipientId;
                 contactSigner.routingOrder = routingOrder;
                 contactSigner.hostEmail = hostEmail;
                 contactSigner.hostName = hostName;
                 
                 System.debug('contactObj: ' + contactObj);
                 System.debug('contactObj.name: ' + contactObj.name);
                 String name = (String.isEmpty(contactObj.name)) ? contactObj.firstname + ' ' + contactObj.lastname : contactObj.name;
                 contactSigner.signerName = name;
                 contactSigner.clientUserId = name.deleteWhitespace();
                 System.debug('contactSigner.clientUserId1: ' + contactSigner.clientUserId);
                 initializeInPersonRecipient(contactSigner, inpersonRecipient);
                 inpersonRecipient.In_Person_Contact__c = contactObj.Id;
                 contactSigner.emailNotification = new EmailNotification();
                 setCustomerEmailBody(contactObj,  envelopObj, contactSigner);
                 
             }else{
                 Signer contactSigner = new Signer();
                 envelopObj.recipients.signers.add(contactSigner);
                 contactSigner.email = contactObj.email;
                 contactSigner.name = contactObj.name;
                 contactSigner.recipientId = recipientId;
                 contactSigner.routingOrder = routingOrder;
                 contactSigner.tabs = tabslistObj;
                 contactSigner.emailNotification = new EmailNotification();
                 setCustomerEmailBody(contactObj,  envelopObj, contactSigner);
             }	
             
             System.debug('includeTabs : ' + includeTabs);
             if(includeTabs == true){
                 
                 Map<String, Map<String, String>> allRequiredTags = getRequiredTagsByDocType(srAttachment.Document_Type_Name__c);
                 String customerType = (recipientId == 1) ? 'PRIMARY' : 'SECONDARY';
                 Map<String, String> customerRequiredTags = allRequiredTags.get(customerType);
                 if(recipientId == 1 && customerRequiredTags.isEmpty()){
                     if(recipientId == 1 || !(isCostcoDocument(srAttachment))){
                         customerRequiredTags.put('\\s' + recipientId + '\\', '');		
                     }
                     
                     if(recipientId == 1){
                         customerRequiredTags.put('\\d' + recipientId + '\\', '');		
                         //addCostcoTabsForCustomer(srAttachment, tabsListObj, recipientId);
                         //addNYTabsForCustomer(srAttachment, tabsListObj, recipientId);
                         customerRequiredTags.put('\\i' + recipientId + '\\', '');			
                         if(changeOrderCoverSheet == false){
                             customerRequiredTags.put('\\em' + recipientId + '\\', 'Enter Email Id');		
                         }
                         if(isCustomerAgreement == true){
                             customerRequiredTags.put('\\ph' + recipientId + '\\', 'Enter Phone number');
                         }
                     }
                     
                 }else if(recipientId > 1 && customerRequiredTags.isEmpty()){
                     if(recipientId > 1 && !(isCostcoDocument(srAttachment))){
                         customerRequiredTags.put('\\s' + recipientId + '\\', '');
                         customerRequiredTags.put('\\n' + recipientId + '\\', '');
                     }
                 }
                 
                 System.debug('Test1: ' + '\\s' + recipientId);
                 System.debug('customerRequiredTags: ' + customerRequiredTags);
                 if(customerRequiredTags.containsKey('\\s' + recipientId + '\\')){
                     Tab signHereTab = new Tab('\\s' + recipientId + '\\');
                     tabslistObj.signHereTabs.add(signHereTab);
                 }
                 System.debug('Test1: ' + '\\s' + recipientId);
                 
                 if(customerRequiredTags.containsKey('\\d' + recipientId + '\\')){
                     Tab signDateTab = new Tab('\\d' + recipientId + '\\');
                     tabslistObj.dateSignedTabs.add(signDateTab);
                 }
                 if(customerRequiredTags.containsKey('\\i' + recipientId + '\\')){
                     Tab initialTab = new Tab('\\i' + recipientId + '\\');
                     tabslistObj.initialHereTabs.add(initialTab);	
                 }
                 
                 System.debug('Before em1');
                 if(customerRequiredTags.containsKey('\\em' + recipientId + '\\')){
                     EmailTab emailTab = new EmailTab('Enter Email Id', '\\em' + recipientId + '\\');
                     emailTab.value = (contactObj.email != null) ? contactObj.email : '';
                     emailTab.width = '42';
                     tabslistObj.emailTabs.add(emailTab);
                     
                     System.debug('contactObj.email  ' + contactObj.email );	
                 }
                 
                 System.debug('Before PH1');
                 if(customerRequiredTags.containsKey('\\ph' + recipientId + '\\')){
                     PhoneTab phoneNumber = new PhoneTab('Enter Phone number', '\\ph' + recipientId + '\\');
                     phoneNumber.value = contactObj.Phone + '';
                     phoneNumber.width = '15';
                     tabslistObj.textTabs.add(phoneNumber);
                     
                     System.debug('contactObj.Phone  ' + contactObj.Phone );	
                 }	
                 System.debug('After PH1');		
                 if(customerRequiredTags.containsKey('\\n' + recipientId + '\\')){
                     Tab fullNameTab = new Tab('\\n' + recipientId + '\\');
                     tabslistObj.fullNameTabs.add(fullNameTab);
                 }			
                 
                 if(customerRequiredTags.containsKey('\\txtph\\')){
                     PhoneTab txtTab1 = new PhoneTab('Enter Phone Number ', '\\txtph\\');
                     txtTab1.value =  '';
                     txtTab1.tabLabel =  '\\txtph\\';
                     txtTab1.width = '15';
                     tabslistObj.textTabs.add(txtTab1);
                 }
                 if(customerRequiredTags.containsKey('\\txthm\\')){
                     Datetab dateTab = new Datetab('Enter Date Home Built (MM/DD/YYYY) ', '\\txthm\\');
                     dateTab.recipientId = '' + recipientId;
                     tabslistObj.datetabs.add(dateTab);
                 }
                 if(customerRequiredTags.containsKey('\\txtmem\\')){
                     PhoneTab txtTab2 = new PhoneTab('Enter Membership Number ', '\\txtmem\\');
                     txtTab2.value =  '';
                     txtTab2.width = '25';
                     txtTab2.tabLabel =  '\\txtmem\\';
                     tabslistObj.textTabs.add(txtTab2);
                 }
                 
             }
         }
    
    public static Boolean isNewyorkDocument(SR_Attachment__c srAttachment){
        Boolean result = false;
        String sunrunId = System.Label.Sunrun_Inc_Id;
        String legacyPowerId = System.Label.LGCY_Power_Acc_Id;
        Set<String> billingCities = new Set<String>();
        Map<String, New_York_Cities__c> nyCities = New_York_Cities__c.getAll();
        String salesPartner = (srAttachment.Proposal__R.Opportunity__r.Sales_Partner__c == null) ? '' : srAttachment.Proposal__R.Opportunity__r.Sales_Partner__c; 
        if(!String.isEmpty(salesPartner) && salesPartner.length() >= 15){
            salesPartner = salesPartner.substring(0,15);
        }
        Datetime createdDate = (Test.isRunningTest()) ? datetime.now().addhours(-10) : DateTime.parse(Label.Customer_Agreement_NY_Tags);
        if(srAttachment != null && srAttachment.createddate >= createdDate 
           && nyCities.containskey(srAttachment.Proposal__R.Opportunity__r.Account.BillingCity)
           &&  !String.isEmpty(salesPartner) && (sunrunId.contains(salesPartner) || legacyPowerId.contains(salesPartner))){
               result = true;
           }
        System.debug('New york result: ' + result);
        return result;
    }
    
    public static Boolean isCostcoDocument(SR_Attachment__c srAttachment){
        Boolean result = false;
        Datetime createdDate = (Test.isRunningTest()) ? datetime.now().addhours(-10) :  DateTime.parse(Label.Customer_Agreement_CostcoTags);
        if(srAttachment != null && srAttachment.createddate >= createdDate &&
           srAttachment.Proposal__R.Opportunity__r.Purchased_Thru__c == 'Costco'){
               result = true;
           }
        return result;
    }
    
    public static void addCostcoTabsForCustomer(SR_Attachment__c srAttachment, TabList tabsListObj, Integer recipientId ){
        if(srAttachment != null && isCostcoDocument(srAttachment) && srAttachment.Document_Type_Name__c == EDPUtil.CUSTOMER_AGREEMENT){
            PhoneTab txtTab1 = new PhoneTab('Enter Phone Number', '\\txtph\\');
            txtTab1.value =  '';
            txtTab1.tabLabel =  '\\txtph\\';
            txtTab1.width = '15';
            tabslistObj.textTabs.add(txtTab1);
            
            Datetab dateTab = new Datetab('Enter Date Home Built (MM/DD/YYYY) ', '\\txthm\\');
            dateTab.recipientId = '' + recipientId;
            tabslistObj.datetabs.add(dateTab);
            
            PhoneTab txtTab2 = new PhoneTab('Enter Membership Number', '\\txtmem\\');
            txtTab2.value =  '';
            txtTab2.width = '25';
            txtTab2.tabLabel =  '\\txtmem\\';
            tabslistObj.textTabs.add(txtTab2);
        }
    }
    
    public static void addCostcoTabsForSalesRep(SR_Attachment__c srAttachment, TabList tabsListObj, Integer recipientId){
        //if(srAttachment != null && isCostcoDocument(srAttachment)){
        //	Tab signDateTab = new Tab('\\txtr5\\');
        //	tabslistObj.dateSignedTabs.add(signDateTab);
        //}
    }
    
    public static void addNYTabsForCustomer(SR_Attachment__c srAttachment, TabList tabsListObj, Integer recipientId){
        if(srAttachment != null && isNewyorkDocument(srAttachment) && srAttachment.Document_Type_Name__c == EDPUtil.CUSTOMER_AGREEMENT){
            //REFER: BSKY-6270
            //PhoneTab txtTab1 = new PhoneTab('Enter Phone Number: ', '\\txtph\\');
            //txtTab1.value =  '';
            //txtTab1.width = '15';
            //tabslistObj.textTabs.add(txtTab1);
            
            //Tab initialTab1 = new Tab('\\txtil1\\');
            //initialTab1.optional = true;
            //tabslistObj.initialHereTabs.add(initialTab1);
            
            //Tab initialTab2 = new Tab('\\txtil2\\');
            //initialTab2.optional = true;
            //tabslistObj.initialHereTabs.add(initialTab2);
            //REFER: BSKY-6270
            
            //
            /*
            PhoneTab txtTab2 = new PhoneTab('', '\\txtil1\\');
            txtTab2.value =  '';
            txtTab2.width = '3';
            tabslistObj.textTabs.add(txtTab2);
            
            PhoneTab txtTab3 = new PhoneTab('', '\\txtil2\\');
            txtTab3.value =  '';
            txtTab3.width = '3';
            tabslistObj.textTabs.add(txtTab3);
            */
            
        }
    }
    
    private static void addTabsForPartner
        (Integer documentId, Boolean includeTabs, Integer recipientId ,
         Integer routingOrder, String eSignType, SR_Attachment__c srAttachment, 
         Contact contactObj, CustomerAgreementEnvelop envelopObj,In_Person_Recipient__c inpersonRecipient){
             TabList tabslistObj = new TabList();
             
             if(eSignType == DocuSignUtil.ESIGN_IN_PERSON){
                 InpersonSigner contactSigner = new InpersonSigner();
                 envelopObj.recipients.inPersonSigners.add(contactSigner);
                 contactSigner.recipientId = recipientId;
                 contactSigner.routingOrder = routingOrder;
                 contactSigner.tabs = tabslistObj;			
                 contactSigner.hostEmail = contactObj.email;
                 contactSigner.hostName = contactObj.name;
                 
                 String name = (String.isEmpty(contactObj.name)) ? contactObj.firstname + ' ' + contactObj.lastname : contactObj.name;
                 contactSigner.signerName = name;
                 contactSigner.clientUserId = name.deleteWhitespace();
                 
                 initializeInPersonRecipient(contactSigner, inpersonRecipient);
                 inpersonRecipient.In_Person_Contact__c = contactObj.Id;
             }else{
                 
                 Signer contactSigner = new Signer();
                 envelopObj.recipients.signers.add(contactSigner);
                 contactSigner.email = contactObj.email;
                 String name = (String.isEmpty(contactObj.name)) ? contactObj.firstname + ' ' + contactObj.lastname : contactObj.name;
                 contactSigner.name = name;
                 contactSigner.recipientId = recipientId;
                 contactSigner.routingOrder = routingOrder;
                 contactSigner.tabs = tabslistObj;			
                 
                 contactSigner.emailNotification = new EmailNotification();
                 String forStr = ' for ';
                 contactSigner.emailNotification.emailSubject = envelopObj.emailSubject.replace('REPLACE_FOR', forStr);
                 contactSigner.emailNotification.supportedLanguage =  'en';	
                 contactSigner.emailNotification.emailBody = '\t Please review & sign your document sent on behalf of Sunrun Inc.';
                 contactSigner.emailNotification.emailBody += ' Thank you for going solar with Sunrun! You can click on the link below to sign your Sunrun agreement.';
                 contactSigner.emailNotification.emailBody += ' If you have any questions, please contact your solar sales consultant.';
             }
             
             if(includeTabs == true){
                 
                 Map<String, Map<String, String>> allRequiredTags = getRequiredTagsByDocType(srAttachment.Document_Type_Name__c);
                 Map<String, String> partnerRequiredTags = allRequiredTags.get('PARTNER');
                 
                 if(!String.isEmpty(srAttachment.Document_Type_Name__c) && srAttachment.Document_Type_Name__c  == EDPUtil.CUSTOMER_AGREEMENT){
                     if(partnerRequiredTags.isEmpty()){
                         partnerRequiredTags.put('\\r1\\', '');
                         partnerRequiredTags.put('\\r2\\', '');
                         partnerRequiredTags.put('\\r4\\', '');
                     }
                     
                     if(srAttachment.Proposal__r != null && srAttachment.Proposal__r.state__C != null 
                        && srAttachment.Proposal__r.state__C == 'CA'){
                            //Tab cslbNumber = new Tab('\\r3\\');
                            //cslbNumber.value = (contactObj.Sales_Registration_Number__c != null) ? contactObj.Sales_Registration_Number__c : '' ;
                            //tabslistObj.numberTabs.add(cslbNumber);
                        }
                     addCostcoTabsForSalesRep(srAttachment, tabslistObj, recipientId);
                 }else if(!String.isEmpty(srAttachment.Document_Type_Name__c) 
                          && srAttachment.Document_Type_Name__c  != EDPUtil.CUSTOMER_AGREEMENT
                          && srAttachment.Document_Type_Name__c  != EDPUtil.CUSTOMER_CHANGEORDER_COVER_SHEET){
                              if(partnerRequiredTags.isEmpty()){
                                  Tab signHereTab = new Tab('\\ps\\');
                                  Tab signDateTab = new Tab('\\pd\\');
                                  Tab titleTab = new Tab('\\pt\\');
                                  Tab fullNameTab = new Tab('\\pn\\');
                                  
                                  tabslistObj.signHereTabs.add(signHereTab);
                                  tabslistObj.dateSignedTabs.add(signDateTab);
                                  tabslistObj.titleTabs.add(titleTab);
                                  tabslistObj.fullNameTabs.add(fullNameTab);	
                              }		
                          }
                 
                 if(partnerRequiredTags.containsKey('\\r1\\')){
                     Tab signHereTab = new Tab('\\r1\\');
                     tabslistObj.signHereTabs.add(signHereTab);	
                 }
                 
                 if(partnerRequiredTags.containsKey('\\r2\\')){
                     Tab fullNameTab = new Tab('\\r2\\');
                     tabslistObj.fullNameTabs.add(fullNameTab);
                 }
                 
                 if(partnerRequiredTags.containsKey('\\r4\\')){
                     Tab sunrunId = new Tab('\\r4\\');
                     sunrunId.value = (contactObj.Contact_Number__c != null) ? contactObj.Contact_Number__c : '' ;
                     tabslistObj.numberTabs.add(sunrunId);
                 }
                 
                                     /*
                    if(partnerRequiredTags.containsKey('\\txtsrappid\\')){
                    PhoneTab txtTab2 = new PhoneTab('Enter application ID', '\\txtsrappid\\');
                    txtTab2.value =  '';
                    txtTab2.width = '25';
                    txtTab2.tabLabel =  '\\txtsrappid\\';
                    tabslistObj.textTabs.add(txtTab2);
                    
                    }
                    if(partnerRequiredTags.containsKey('\\txtsracc\\')){
                    PhoneTab txtTab2 = new PhoneTab('Enter application ID', '\\txtsracc\\');
                    txtTab2.value =  '';
                    txtTab2.width = '25';
                    txtTab2.tabLabel =  '\\txtsracc\\';
                    tabslistObj.textTabs.add(txtTab2);
                    }
                    if(partnerRequiredTags.containsKey('\\txtsrsec\\')){
                    PhoneTab txtTab2 = new PhoneTab('Enter application ID', '\\txtsrsec\\');
                    txtTab2.value =  '';
                    txtTab2.width = '25';
                    txtTab2.tabLabel =  '\\txtsrsec\\';
                    tabslistObj.textTabs.add(txtTab2);
                    }
                    
                    if(partnerRequiredTags.containsKey('\\txtsrexp\\')){
                    Datetab dateTab = new Datetab('Enter loan expiration date (MM/DD/YYYY)', '\\txtsrexp\\');
                    tabslistObj.datetabs.add(dateTab);
                    }	
                    */
                                     
                 if(partnerRequiredTags.containsKey('\\txtr5\\')){
                     Tab signDateTab = new Tab('\\txtr5\\');
                     tabslistObj.dateSignedTabs.add(signDateTab);
                 }
                 
                 if(srAttachment.Document_Type_Name__c == 'Conditional Approval'){
                     RadioGroupTab radioGroupsTab = new RadioGroupTab('Payment Type');
                     radioGroupsTab.documentId = '' + documentId;
                     radioGroupsTab.recipientId = '' + recipientId;
                     RadioTab radioButton1 = new RadioTab('\\ach\\');
                     radioButton1.selected = true;
                     radioButton1.value = 'Radio';
                     RadioTab radioButton2 = new RadioTab('\\chk\\');
                     radioButton1.selected = false;
                     radioButton1.value = 'Radio';				
                     radioGroupsTab.radios.add(radioButton1);
                     radioGroupsTab.radios.add(radioButton2);
                     tabslistObj.radioGroupTabs.add(radioGroupsTab);
                 }
             }
         }
    
    
    private static void addTabsForSunRunOPS
        (String documentName, Boolean includeTabs, Integer recipientId , Integer routingOrder, 
         String eSignType, String recipientName, String recipientEmail, 
         CustomerAgreementEnvelop envelopObj,Boolean changeOrderCoverSheet,
         In_Person_Recipient__c inpersonRecipient, Boolean isCostcoDoc){
             
             TabList tabslistObj = new TabList();
             String sunrunOpsEmail = Label.SunRun_DocuSign_Email;
             String loginUserName = UserInfo.getName();
             
             Signer contactSigner = new Signer();
             envelopObj.recipients.signers.add(contactSigner);
             contactSigner.email = recipientEmail;
             contactSigner.name = recipientName;
             contactSigner.recipientId = recipientId;
             contactSigner.routingOrder = routingOrder;
             contactSigner.tabs = tabslistObj;
             
             contactSigner.emailNotification = new EmailNotification();
             String forStr = 'for';
             contactSigner.emailNotification.emailSubject = envelopObj.emailSubject.replace('REPLACE_FOR', forStr);
             contactSigner.emailNotification.supportedLanguage =  'en';	
             contactSigner.emailNotification.emailBody = '\t Please review & sign your document sent on behalf of Sunrun Inc.';
             contactSigner.emailNotification.emailBody += ' Thank you for going solar with Sunrun! You can click on the link below to sign your Sunrun agreement.';
             contactSigner.emailNotification.emailBody += ' If you have any questions, please contact your solar sales consultant.';
             if(includeTabs == true){
                 Map<String, Map<String, String>> allRequiredTags = getRequiredTagsByDocType(documentName);
                 Map<String, String> srOPSRequiredTags = allRequiredTags.get('SR_OPS');
                 if(srOPSRequiredTags.isEmpty()){
                     srOPSRequiredTags.put('\\os\\', '');
                     srOPSRequiredTags.put('\\od\\', '');
                     if(!(isCostcoDoc)){
                         srOPSRequiredTags.put('\\on\\', '');
                     }
                     if(changeOrderCoverSheet == false && !(isCostcoDoc)){
                         srOPSRequiredTags.put('\\ot\\', '');
                     }
                 }
                 
                 if(srOPSRequiredTags.containskey('\\os\\')){
                     Tab signHereTab = new Tab('\\os\\');
                     tabslistObj.signHereTabs.add(signHereTab);
                 }
                 if(srOPSRequiredTags.containskey('\\od\\')){
                     Tab signDateTab = new Tab('\\od\\');
                     tabslistObj.dateSignedTabs.add(signDateTab);
                 }
                 if(srOPSRequiredTags.containskey('\\on\\')){
                     Tab fullNameTab = new Tab('\\on\\');
                     tabslistObj.fullNameTabs.add(fullNameTab);	
                 }						
                 if(srOPSRequiredTags.containskey('\\ot\\')){
                     Tab titleTab = new Tab('\\ot\\');
                     tabslistObj.titleTabs.add(titleTab);
                 }	
                 
                 
             }
         }
    
    public static dsfs__DocuSign_Status__c getDocuSignStatus(String envelopId){
        dsfs__DocuSign_Status__c statusObj;
        List<dsfs__DocuSign_Status__c> statusObjList = [Select Id, dsfs__DocuSign_Envelope_ID__c, dsfs__Envelope_Status__c from dsfs__DocuSign_Status__c 
                                                        where dsfs__DocuSign_Envelope_ID__c =:envelopId limit 1];
        if(statusObjList.size() > 0 ){
            statusObj = statusObjList[0];
        }	
        return statusObj;
    }
    
    public static void testInnerClasses(){
        EmbeddedSigningRequest obj1 = new EmbeddedSigningRequest();
        RadioGroupTab obj2 = new RadioGroupTab('TestRadio1');
        RadioTab obj3 = new RadioTab('Tab1');
    }
    
    
    public static Map<String, Map<String, Map<String, String>>> requiredTagsByDocType = new Map<String, Map<String, Map<String, String>>>();
    public static Map<String, Map<String, String>> getRequiredTagsByDocType(String documentType){
        System.debug('documentType: ' + documentType);
        if(requiredTagsByDocType != null && requiredTagsByDocType.containskey(documentType)){
            System.debug('requiredTagsByDocType1: ' + requiredTagsByDocType);
            return requiredTagsByDocType.get(documentType);
        }else{
            Map<String, Map<String, String>> requiredTagsMap = new Map<String, Map<String, String>>();
            Map<String, String> customer1 = new Map<String, String>();
            Map<String, String> customer2 = new Map<String, String>();
            Map<String, String> partner = new Map<String, String>();
            Map<String, String> srOps = new Map<String, String>();
                        /* if(documentType==EDPUtil.REBATE_FORM){
            requiredTagsMap.put('PRIMARY', customer1);
            }
            else {*/
            requiredTagsMap.put('PRIMARY', customer1);
            requiredTagsMap.put('SECONDARY', customer2);
            requiredTagsMap.put('PARTNER', partner);
            requiredTagsMap.put('SR_OPS', srOps); 
            //}
            
            System.debug('requiredTagsMap: ' + requiredTagsMap);
            return requiredTagsMap;
        }		
    }
    
    
    
    public static void initializeRequiredTagsByDocType(String documentType, String agreementType, String purchasedThrough, String programType){
        if(!String.isEmpty(documentType) && (documentType == EDPUtil.CUSTOMER_CHANGEORDER_COVER_SHEET || documentType == EDPUtil.CUSTOMER_AGREEMENT )){       //|| documentType==EDPUtil.REBATE_FORM)){
            System.debug('agreementType: ' + agreementType);
            System.debug('documentType: ' + documentType);
            System.debug('purchasedThrough: ' + purchasedThrough);
            System.debug('programType: ' + programType);
            
            Map<String, Map<String, String>> requiredTagsMap = new Map<String, Map<String, String>>();
            Map<String, String> customer1 = new Map<String, String>();
            Map<String, String> customer2 = new Map<String, String>();
            Map<String, String> partner = new Map<String, String>();
            Map<String, String> srOps = new Map<String, String>();
            
            requiredTagsMap.put('PRIMARY', customer1);
            requiredTagsMap.put('SECONDARY', customer2);
            requiredTagsMap.put('PARTNER', partner);
            requiredTagsMap.put('SR_OPS', srOps);
            requiredTagsByDocType.put(documentType, requiredTagsMap);
            if(documentType == EDPUtil.CUSTOMER_AGREEMENT){
                if(agreementType  == 'Customer Owned - Full Upfront'){
                    if(purchasedThrough == 'Costco'){
                        if(programType == 'Program 1'){
                            addCustomerTagSet1(customer1);
                            addCustomerTagSet2(customer1);
                            addCustomerTagSet3(customer1);
                            addSecondaryCustomerTagSet1(customer2);			
                            
                            addSROpsTagSet1(srOps);
                            
                            addSalesRepTagSet1(partner);
                            addSalesRepTagSet3(partner);						
                        }else if(programType == 'Program 2'){
                            addCustomerTagSet1(customer1);
                            addCustomerTagSet3(customer1);
                            addSecondaryCustomerTagSet1(customer2);
                            
                            addSROpsTagSet1(srOps);
                            addSROpsTagSet2(srOps);
                            
                            addSalesRepTagSet1(partner);						
                        }
                    }else{
                        addCustomerTagSet1(customer1);
                        addCustomerTagSet3(customer1);
                        
                        addSecondaryCustomerTagSet1(customer2);		
                        
                        addSROpsTagSet1(srOps);
                        addSROpsTagSet2(srOps);
                        
                        addSalesRepTagSet1(partner);					
                    }
                }else if(agreementType  == 'Customer Owned - Bank Financed'){
                    if(purchasedThrough == 'Costco'){
                        if(programType == 'Program 1'){
                            addCustomerTagSet1(customer1);
                            addCustomerTagSet2(customer1);
                            addCustomerTagSet3(customer1);
                            addSecondaryCustomerTagSet1(customer2);		
                            
                            addSROpsTagSet1(srOps);
                            
                            addSalesRepTagSet1(partner);
                            addSalesRepTagSet2(partner);
                            addSalesRepTagSet3(partner);						
                        }else if(programType == 'Program 2'){
                            addCustomerTagSet1(customer1);
                            addCustomerTagSet3(customer1);
                            addSecondaryCustomerTagSet1(customer2);		
                            
                            addSROpsTagSet1(srOps);
                            addSROpsTagSet2(srOps);
                            
                            addSalesRepTagSet1(partner);
                            addSalesRepTagSet2(partner);						
                        }
                    }else{
                        addCustomerTagSet1(customer1);
                        addCustomerTagSet3(customer1);
                        addSecondaryCustomerTagSet1(customer2);	
                        System.debug('customer2 2 ' + customer2);				
                        
                        addSROpsTagSet1(srOps);
                        addSROpsTagSet2(srOps);
                        
                        addSalesRepTagSet1(partner);
                        addSalesRepTagSet2(partner);					
                    }
                }
            }else if(documentType == EDPUtil.CUSTOMER_CHANGEORDER_COVER_SHEET){
                if(agreementType  == 'Customer Owned - Full Upfront'){
                    if(purchasedThrough == 'Costco'){
                        if(programType == 'Program 1'){
                            addCustomerTagSet1(customer1);
                            addCustomerTagSet2(customer1);
                            addCustomerTagSet3(customer1);
                            
                            addSecondaryCustomerTagSet1(customer2);			
                            addSROpsTagSet3(srOps);						
                        }else if(programType == 'Program 2'){
                            addCustomerTagSet1(customer1);
                            addCustomerTagSet3(customer1);
                            addSecondaryCustomerTagSet1(customer2);			
                            addSROpsTagSet3(srOps);						
                        }
                    }else{
                        addCustomerTagSet1(customer1);
                        addSecondaryCustomerTagSet1(customer2);			
                        addSROpsTagSet3(srOps);					
                    }
                }else if(agreementType  == 'Customer Owned - Bank Financed'){
                    if(purchasedThrough == 'Costco'){
                        if(programType == 'Program 1'){
                            addCustomerTagSet1(customer1);
                            addCustomerTagSet2(customer1);
                            addCustomerTagSet3(customer1);
                            
                            addSecondaryCustomerTagSet1(customer2);			
                            addSROpsTagSet3(srOps);
                            addSalesRepTagSet2(partner);						
                        }else if(programType == 'Program 2'){
                            addCustomerTagSet1(customer1);
                            addCustomerTagSet3(customer1);
                            
                            addSecondaryCustomerTagSet1(customer2);			
                            addSROpsTagSet3(srOps);
                            addSalesRepTagSet2(partner);						
                        }
                    }else{
                        addCustomerTagSet1(customer1);
                        addSecondaryCustomerTagSet1(customer2);			
                        addSROpsTagSet3(srOps);
                        addSalesRepTagSet2(partner);					
                    }
                }
            }
                    //adding for rebate form
                    /*  else if (documentType == EDPUtil.REBATE_FORM){
        addRebateFormTagSet1(customer1);
        }*/
                    
                    
                }		
                //return requiredTagsMap;
            }
            
            //added tags for Rebate form
            
            /*  public static void addRebateFormTagSet1(Map<String, String> tagMap){
        tagMap.put('\\n1\\', '');
        tagMap.put('\\s1\\', '');
        tagMap.put('\\d1\\', '');
        }*/
            
            
            
    public static void addCustomerTagSet1(Map<String, String> tagMap){
        tagMap.put('\\i1\\', '');
        tagMap.put('\\d1\\', '');
        tagMap.put('\\s1\\', '');
    }
    
    public static void addCustomerTagSet2(Map<String, String> tagMap){
        tagMap.put('\\txtph\\', '');
        tagMap.put('\\txthm\\', '');
        tagMap.put('\\txtmem\\', '');
    }
    
    public static void addCustomerTagSet3(Map<String, String> tagMap){
        tagMap.put('\\em1\\', 'Enter Email Id');
        tagMap.put('\\ph1\\', 'Enter Phone number');
    }
    
    public static void addSecondaryCustomerTagSet1(Map<String, String> tagMap){
        System.debug('Adding tags for secondary customer ');
        tagMap.put('\\s2\\', '');
        tagMap.put('\\n2\\', '');
        System.debug('Adding tags for secondary customer ');
    }
    
    public static void addSROpsTagSet1(Map<String, String> tagMap){
        tagMap.put('\\od\\', '');
        tagMap.put('\\os\\', '');
    }
    
    public static void addSROpsTagSet2(Map<String, String> tagMap){
        tagMap.put('\\on\\', '');
        tagMap.put('\\ot\\', '');
    }
    
    public static void addSROpsTagSet3(Map<String, String> tagMap){
        tagMap.put('\\od\\', '');
        tagMap.put('\\os\\', '');
        tagMap.put('\\on\\', '');
    }
    
    public static void addSalesRepTagSet1(Map<String, String> tagMap){
        tagMap.put('\\r1\\', '');
        tagMap.put('\\r2\\', '');
        tagMap.put('\\r4\\', '');
    }
    
    public static void addSalesRepTagSet2(Map<String, String> tagMap){
        //tagMap.put('\\txtsrappid\\', 'Enter application ID');
        //tagMap.put('\\txtsracc\\', 'Enter account number');
        //tagMap.put('\\txtsrexp\\', 'Enter loan expiration date');
        //tagMap.put('\\txtsrsec\\', 'Enter security code OR CVV');
    }
    
    public static void addSalesRepTagSet3(Map<String, String> tagMap){
        tagMap.put('\\txtr5\\', '');
    }
    
    /*--------------------------------------------------------------------------*/
    // Adding logic to Docusign Tags for NEM and Rebate
    /*------------------------------------------------------------------------*/
    private static void initializeDocusignTagsForSunRunOps
        (String documentName, Boolean includeTabs, Integer recipientId , 
         Integer routingOrder, String eSignType, String recipientName, 
         String recipientEmail, CustomerAgreementEnvelop envelopObj,
         Boolean changeOrderCoverSheet, In_Person_Recipient__c inpersonRecipient, String agreementType,
         String UtilityName,String CustomerType,String State  ){
             
             system.debug('initializeDocusignTagsForSunRunOps');
             
             TabList tabslistObj = new TabList();
             String sunrunOpsEmail = Label.SunRun_DocuSign_Email;
             String loginUserName = UserInfo.getName();
             
             Signer contactSigner = new Signer();
             envelopObj.recipients.signers.add(contactSigner);
             contactSigner.email = recipientEmail;
             contactSigner.name = recipientName;
             contactSigner.recipientId = recipientId;
             contactSigner.routingOrder = routingOrder;
             contactSigner.tabs = tabslistObj;
             
             contactSigner.emailNotification = new EmailNotification();
             String forStr = 'for';
             contactSigner.emailNotification.emailSubject = envelopObj.emailSubject.replace('REPLACE_FOR', forStr);
             contactSigner.emailNotification.supportedLanguage =  'en';	
             contactSigner.emailNotification.emailBody = '\t Please review & sign your document sent on behalf of Sunrun Inc.';
             contactSigner.emailNotification.emailBody += ' Thank you for going solar with Sunrun! You can click on the link below to sign your Sunrun agreement.';
             contactSigner.emailNotification.emailBody += ' If you have any questions, please contact your solar sales consultant.';
             // if(includeTabs == true){
             
             Map<String,Map<String,String>> CompleteDocuSignMap =  getDocuSignTagInformation(documentName, UtilityName,agreementType,State);
             system.debug('CompleteDocuSignMap' + CompleteDocuSignMap);
             Map<String,string> CustomerTagMap = new  Map<String,string>();
             if(CompleteDocuSignMap.containsKey(CustomerType)){
                 CustomerTagMap= CompleteDocuSignMap.get(CustomerType);
             }
             
             for(string TabKey :CustomerTagMap.keySet()){
                 system.debug('key>>'  + TabKey);
                 system.debug(' CustomerTagMap.get(key)>>'  +  CustomerTagMap.get(TabKey));
                 
                 if(TabKey.containsIgnoreCase(INITIALSTAB)){
                     Tab initialTab = new Tab(String.valueOf(CustomerTagMap.get(TabKey)));
                     tabslistObj.initialHereTabs.add(initialTab);
                 }
                 
                 if(TabKey.containsIgnoreCase(TITLESTAB)){
                     system.debug('PrimaryCustomerMap.get(Title Tab)' +  CustomerTagMap.get(TabKey));
                     Tab titleTab = new Tab(String.valueOf(CustomerTagMap.get(TabKey)));
                     tabslistObj.titleTabs.add(titleTab);
                 }
                 
                 
                 if(TabKey.containsIgnoreCase(SIGNTAB)){
                     system.debug('PrimaryCustomerMap.get(Sign Tab)' +  CustomerTagMap.get(TabKey));
                     Tab signHereTab = new Tab(String.valueOf(CustomerTagMap.get(TabKey)));
                     tabslistObj.signHereTabs.add(signHereTab);
                     
                 }
                 if(TabKey.containsIgnoreCase(FNAMETAB)){
                     system.debug('PrimaryCustomerMap.get(Sign Tab)' +  CustomerTagMap.get(TabKey));
                     Tab fullNameTab = new Tab(String.valueOf(CustomerTagMap.get(TabKey)));
                     tabslistObj.fullNameTabs.add(fullNameTab);
                 }
                 if(TabKey.containsIgnoreCase(DATESIGNEDTAB)){
                     system.debug('PrimaryCustomerMap.get(Date Signed Tab)' +  CustomerTagMap.get(TabKey));
                     Tab DateTab = new Tab(String.valueOf(CustomerTagMap.get(TabKey)));
                     tabslistObj.dateSignedTabs.add(DateTab);
                 }
                 
                 
                 if(TabKey.containsIgnoreCase(PHONESTAB)){
                     //system.debug('PrimaryCustomerMap.get(Sign Tab)' +  CustomerTagMap.get('Phone Tab'));
                     PhoneTab phoneTab = new PhoneTab('Enter Phone Number', String.valueOf(CustomerTagMap.get(TabKey)));
                     phoneTab.value =  '';
                     phoneTab.tabLabel =  String.valueOf(CustomerTagMap.get(TabKey));
                     phoneTab.width = '15';
                     tabslistObj.textTabs.add(phoneTab);
                 }
                 
                 if(TabKey.containsIgnoreCase(DATESTAB)){
                     Datetab dateTab = new Datetab('Enter Date', String.valueOf(CustomerTagMap.get(TabKey)));
                     dateTab.recipientId = '' + recipientId;
                     tabslistObj.DateTabs.add(dateTab);
                 }
                 
             }
             
             // }
             
         }
    
    
    
    public static void initializeDocusignTagsCustomerAndPartner
        (Boolean includeTabs, Integer recipientId  , Integer routingOrder
         , String eSignType, String hostName, String hostEmail,
         SR_Attachment__c srAttachment, Contact contactObj,
         CustomerAgreementEnvelop envelopObj, In_Person_Recipient__c inpersonRecipient,
         String UtilityName,String CustomerType){
             system.debug('initializeDocusignTagsCustomerAndPartner');
             
             TabList tabslistObj = new TabList();
             if(eSignType == DocuSignUtil.ESIGN_IN_PERSON){
                 InpersonSigner contactSigner = new InpersonSigner();
                 envelopObj.recipients.inPersonSigners.add(contactSigner);
                 contactSigner.tabs = tabslistObj;	
                 contactSigner.recipientId = recipientId;
                 contactSigner.routingOrder = routingOrder;
                 contactSigner.hostEmail = hostEmail;
                 contactSigner.hostName = hostName;
                 String name = (String.isEmpty(contactObj.name)) ? contactObj.firstname + ' ' + contactObj.lastname : contactObj.name;
                 contactSigner.signerName = name;
                 contactSigner.clientUserId = name.deleteWhitespace();
                 initializeInPersonRecipient(contactSigner, inpersonRecipient);
                 inpersonRecipient.In_Person_Contact__c = contactObj.Id;
                 if(CustomerType!='Partner'){
                     contactSigner.emailNotification = new EmailNotification();
                     setCustomerEmailBody(contactObj,  envelopObj, contactSigner);
                 }
                 
             }else{
                 Signer contactSigner = new Signer();
                 envelopObj.recipients.signers.add(contactSigner);
                 contactSigner.email = contactObj.email;
                 contactSigner.name = contactObj.name;
                 contactSigner.recipientId = recipientId;
                 contactSigner.routingOrder = routingOrder;
                 contactSigner.tabs = tabslistObj;
                 contactSigner.emailNotification = new EmailNotification();
                 setCustomerEmailBody(contactObj,  envelopObj, contactSigner);
                 if(CustomerType=='Partner'){
                     String forStr = ' for ';
                     contactSigner.emailNotification.emailSubject = envelopObj.emailSubject.replace('REPLACE_FOR', forStr);
                     contactSigner.emailNotification.supportedLanguage =  'en';	
                     contactSigner.emailNotification.emailBody = '\t Please review & sign your document sent on behalf of Sunrun Inc.';
                     contactSigner.emailNotification.emailBody += ' Thank you for going solar with Sunrun! You can click on the link below to sign your Sunrun agreement.';
                     contactSigner.emailNotification.emailBody += ' If you have any questions, please contact your solar sales consultant.';
                 }
             }	
             
             System.debug('includeTabs : ' + includeTabs);
             // if(includeTabs == true){
             Map<String,Map<String,String>> CompleteDocuSignMap =  getDocuSignTagInformation(srAttachment.Document_Type_Name__c, UtilityName,srAttachment.proposal__r.Agreement_Type__c,srAttachment.proposal__r.state__c);
             Map<String,string> CustomerTagMap = new Map<String,string>();
             if(CompleteDocuSignMap.containsKey(CustomerType)){
                 CustomerTagMap=  CompleteDocuSignMap.get(CustomerType);
             }
             system.debug('CompleteDocuSignMap' +  CompleteDocuSignMap);
             system.debug('CustomerType' +  CustomerType);
             system.debug('PrimaryCustomerMap>' +  CustomerTagMap);
             
             for(string TabKey :CustomerTagMap.keySet()){
                 system.debug('key>>'  + TabKey);
                 system.debug(' CustomerTagMap.get(key)>>'  +  CustomerTagMap.get(TabKey));
                 
                 if(TabKey.containsIgnoreCase(INITIALSTAB)){
                     Tab initialTab = new Tab(String.valueOf(CustomerTagMap.get(TabKey)));
                     tabslistObj.initialHereTabs.add(initialTab);
                 }
                 
                 if(TabKey.containsIgnoreCase(TITLESTAB)){
                     system.debug('PrimaryCustomerMap.get(Title Tab)' +  CustomerTagMap.get(TabKey));
                     Tab titleTab = new Tab(String.valueOf(CustomerTagMap.get(TabKey)));
                     tabslistObj.titleTabs.add(titleTab);
                 }
                 
                 
                 if(TabKey.containsIgnoreCase(SIGNTAB)){
                     system.debug('PrimaryCustomerMap.get(Sign Tab)' +  CustomerTagMap.get(TabKey));
                     Tab signHereTab = new Tab(String.valueOf(CustomerTagMap.get(TabKey)));
                     tabslistObj.signHereTabs.add(signHereTab);
                     
                 }
                 if(TabKey.containsIgnoreCase(FNAMETAB)){
                     system.debug('PrimaryCustomerMap.get(Sign Tab)' +  CustomerTagMap.get(TabKey));
                     Tab fullNameTab = new Tab(String.valueOf(CustomerTagMap.get(TabKey)));
                     tabslistObj.fullNameTabs.add(fullNameTab);
                 }
                 if(TabKey.containsIgnoreCase(DATESIGNEDTAB)){
                     system.debug('PrimaryCustomerMap.get(Date Signed Tab)' +  CustomerTagMap.get(TabKey));
                     Tab DateTab = new Tab(String.valueOf(CustomerTagMap.get(TabKey)));
                     tabslistObj.dateSignedTabs.add(DateTab);
                 }
                 
                 
                 if(TabKey.containsIgnoreCase(PHONESTAB)){
                     //system.debug('PrimaryCustomerMap.get(Sign Tab)' +  CustomerTagMap.get('Phone Tab'));
                     PhoneTab phoneTab = new PhoneTab('Enter Phone Number', String.valueOf(CustomerTagMap.get(TabKey)));
                     phoneTab.value =  '';
                     phoneTab.tabLabel =  String.valueOf(CustomerTagMap.get(TabKey));
                     phoneTab.width = '15';
                     tabslistObj.textTabs.add(phoneTab);
                 }
                 
                 if(TabKey.containsIgnoreCase(DATESTAB)){
                     Datetab dateTab = new Datetab('Enter Date', String.valueOf(CustomerTagMap.get(TabKey)));
                     dateTab.recipientId = '' + recipientId;
                     tabslistObj.DateTabs.add(dateTab);
                 }
                 if(TabKey.containsIgnoreCase(MAILTAB)){
                     EmailTab emailTab = new EmailTab('Enter Email Id', String.valueOf(CustomerTagMap.get(TabKey)));
                     emailTab.value = (contactObj.email != null) ? contactObj.email : '';
                     emailTab.width = '42';
                     tabslistObj.emailTabs.add(emailTab);
                 }
                 if(TabKey.containsIgnoreCase(NUMBERSTAB)){
                     Tab NumberTab = new Tab( String.valueOf(CustomerTagMap.get(TabKey)));
                     NumberTab.value = (contactObj.Contact_Number__c != null) ? contactObj.Contact_Number__c : '' ;
                     tabslistObj.numberTabs.add(NumberTab);
                 }
                 
             }
             
             //}
             
         }
    
    
    public static Map<String,Map<String,String>> getDocuSignTagInformation(String documentType, String UtilityName,String agreementType, String  State){
        
       system.debug('UtilityName' +  UtilityName);
               system.debug('documentType' +  documentType);
        system.debug('State' + State);
        String soslStr ='SELECT ID,  Utility_Name__c,End_Date__c,Start_Date__c,';
        soslStr += ' Document_Type__c, (select Id,DocuSign_Tag__c,Customer_Type__c, tab_Category__c from DocuSign_Tab_Managements__r) FROM DocuSign_Template__c';
        soslStr +=  ' where  Document_Type__c =:documentType and 	Utility_Name__c=: UtilityName and  (Start_Date__c<= Today and end_date__c >=today)' ;
         soslStr += ' and  State__c=:State';
        system.debug('soslStr' +  soslStr);
        List<DocuSign_Template__c> docSignTemplate = Database.query(soslStr);
        Map<id,DocuSign_Tab_Management__c> DocuSignTabMap = new Map<id,DocuSign_Tab_Management__c>();
        for(DocuSign_Tab_Management__c docuSignTab : docSignTemplate[0].DocuSign_Tab_Managements__r){
            DocuSignTabMap.put(docuSignTab.id, docuSignTab);
        }
        Map<String,string> PrimaryCustomerMap =  new Map<String,string>();
        Map<String,string> SecondaryCustomerMap =  new Map<String,string>();
        Map<String,string> PartnerMap =  new Map<String,string>();
        Map<String,string> SROpsMap =  new Map<String,string>();
        Map<String,Map<String,String>> DocuSignContainerMap = new  Map<String,Map<String,String>>(); 
        
        system.debug('DocuSignTabMap' +  DocuSignTabMap);
        for(ID key : DocuSignTabMap.keySet()){
            if(DocuSignTabMap.get(key).Customer_Type__c ==PRIMARY){
                PrimaryCustomerMap.put(DocuSignTabMap.get(key).Tab_Category__c, DocuSignTabMap.get(key).DocuSign_Tag__c);
            }
            if(DocuSignTabMap.get(key).Customer_Type__c ==SECONDARY){
                SecondaryCustomerMap.put(DocuSignTabMap.get(key).Tab_Category__c, DocuSignTabMap.get(key).DocuSign_Tag__c);
            }
            if(DocuSignTabMap.get(key).Customer_Type__c =='SROps'){
                SROpsMap.put(DocuSignTabMap.get(key).Tab_Category__c, DocuSignTabMap.get(key).DocuSign_Tag__c);
            }
            system.debug('DocuSignTabMap.get(key).Customer_Type__c' +  DocuSignTabMap.get(key).Customer_Type__c);
            if(DocuSignTabMap.get(key).Customer_Type__c =='Partner'){
                PartnerMap.put(DocuSignTabMap.get(key).Tab_Category__c, DocuSignTabMap.get(key).DocuSign_Tag__c);
            }
        }
        if(!PrimaryCustomerMap.isEmpty())
            DocuSignContainerMap.put(PRIMARY, PrimaryCustomerMap);
        if(!SecondaryCustomerMap.isEmpty())
            DocuSignContainerMap.put(SECONDARY, SecondaryCustomerMap);
        if(!SROpsMap.isEmpty())
            DocuSignContainerMap.put('SROps', SROpsMap);
        if(!PartnerMap.isEmpty())
            DocuSignContainerMap.put('Partner', PartnerMap);
        return DocuSignContainerMap;
        
    }
    
    
    
    
    /*---------------------*/
    
    
    class CustomerAgreementEnvelop {
        public String status {get;set;}
        public String emailBlurb{get;set;}
        public String emailSubject{get;set;}
        public List<Document> documents{get;set;}
        public RecipientList recipients{get;set;}
        
    }
    
    class Document {
        public Integer documentId{get;set;} 
        public String name{get;set;}
    }
    
    class RecipientList {
        public List<Signer> signers{get;set;}
        public List<InpersonSigner> inPersonSigners{get;set;}
        public RecipientList(){
            signers = new List<Signer>();
            inPersonSigners = new List<InpersonSigner>();
        }
    }
    
    class  Signer{
        public String email{get;set;}
        public String name{get;set;}	
        public TabList tabs{get;set;}
        public Integer recipientId{get;set;}
        public Integer routingOrder{get;set;}
        public EmailNotification emailNotification{get;set;}
        public Signer(){
            email = '';
            name = '';
            //emailNotification = new  EmailNotification();
        }
    }
    
    class InpersonSigner{
        public String hostEmail{get;set;}
        public String hostName{get;set;}
        public String signerName{get;set;}
        public String clientUserId{get;set;}
        public TabList tabs{get;set;}
        public Integer recipientId{get;set;}
        public Integer routingOrder{get;set;}
        public EmailNotification emailNotification{get;set;}
        
        public InpersonSigner(){
            hostEmail = '';
            hostName = '';
            clientUserId = '';
            signerName = '';
        }
    }
    
    class TabList{
        public List<Tab>  signHereTabs;
        public List<Tab>  dateSignedTabs;
        public List<Tab>  titleTabs;
        public List<Tab>  initialHereTabs;
        public List<Tab>  fullNameTabs;
        public List<EmailTab>  emailTabs;
        public List<PhoneTab>  textTabs;
        public List<Tab>  numberTabs;
        public List<RadioGroupTab>  radioGroupTabs;
        public List<DateTab>  dateTabs;
        
        public TabList(){
            signHereTabs = new List<Tab>();
            dateSignedTabs = new List<Tab>();
            titleTabs = new List<Tab>();
            initialHereTabs = new List<Tab>();
            fullNameTabs = new List<Tab>();
            emailTabs = new List<EmailTab>();
            numberTabs = new List<Tab>();
            textTabs = new List<PhoneTab>();
            radioGroupTabs = new List<RadioGroupTab>();
            dateTabs = new List<DateTab>();
        }
        
    }
    
    public class RadioTab{
        public Boolean selected {
            get;set;
        }
        public String value{get;set;}
        public String anchorString{get;set;}
        public RadioTab(String anchorString){
            this.anchorString = anchorString;
            selected = false;
        }
        
    }
    
    public class RadioGroupTab{
        String documentId {get;set;}
        String groupName {get;set;}
        String recipientId {get;set;}
        public List<RadioTab>  radios{get;set;}
        public RadioGroupTab(String groupName){
            this.groupName = groupName;
            radios = new List<RadioTab>();
        }
    }
    
    public class EmailNotification{
        String emailBody{get;set;}
        String emailSubject {get;set;}
        String supportedLanguage{get;set;}
    }
    
    public class EmailTab{
        public String name{get;set;}
        public String value{get;set;}
        public String anchorString{get;set;}
        public String width{get;set;}
        public EmailTab(String n, String anchorName){
            value = '';
            name =n;
            anchorString = anchorName;
        }
    }
    
    public class PhoneTab{
        public String tabLabel{get;set;}
        public String name{get;set;}
        public String value{get;set;}
        public String anchorString{get;set;}
        public String width{get;set;}
        public boolean required {get;set;}
        public PhoneTab(String n, String anchorName){
            name =n;
            value = '';
            anchorString = anchorName;
            required = true;
            tabLabel = '';
        }
    }
    
    public class DateTab{
        public String name{get;set;}
        String anchorString {get;set;}
        String recipientId {get;set;}
        public DateTab(String n, String anchorName){
            name = n;
            anchorString = anchorName;
        }
    }
    
    public class Tab{
        String name;
        String value;
        Boolean optional {get;set;}
        String anchorString;
        public Tab(String n){
            name =n;
            value = '';
            anchorString = n;
            optional = false;
        }
        
        public Tab(String n, String anchorName){
            name =n;
            value = '';
            anchorString = anchorName;
            optional = false;
        }
        
    }
    
    class ResendSigner{
        public String email{get;set;}
        public String name{get;set;}
        public Integer recipientId{get;set;}
    }	
    
    class ResendEnvelop {
        public List<ResendSigner> signers{get;set;}
    }
    
    private static void addResendSigner(Integer recipientId, Integer routingOrder, String recipientName, 
                                        String recipientEmail, ResendEnvelop envelopObj){
                                            ResendSigner contactSigner = new ResendSigner();
                                            envelopObj.signers.add(contactSigner);
                                            contactSigner.email = recipientEmail;
                                            contactSigner.name = recipientName;
                                            contactSigner.recipientId = recipientId;
                                        }
    
    class VoidEnvelop{
        String status;
        String voidedReason;
    }
    
    public class EmbeddedSigningRequest{
        public String authenticationMethod{get;set;}
        public String clientUserId{get;set;}
        public String email{get;set;}
        public String returnUrl{get;set;}
        public String userName{get;set;}
        public EmbeddedSigningRequest(){
            authenticationMethod = 'email';
            clientUserId = '';
            email = '';
            returnUrl = '';
        }
    }	
    
}