/************************************************************************************************************
Name    : SRAttachmentDocuSignSubmitController
Author  : ZCloud Team
Date    : Mar, 2013
Description: 
************************************************************************************************************/
public class SRAttachmentESignController {
  public static String InpersonStr = 'InPerson';
  public boolean allowPartnerContactSelection{get;set;}
  SRAttchmentUtil srAttachmentUtilObj;
  public string eSignOption{get;set;}
  public Id primaryContactId {get;set;}
  public Id secondaryContactId {get;set;}
  public String parentURL{get;set;}
  public String proposalId {get;set;}
  public CustomLookup__c partnerContactObj {get;set;}
  private map<Id, Contact> contactMap = new map<Id, Contact>();
  public String baseURL{get;set;}
  public boolean eSignInProgress {get;set;}
  public boolean displayPartnerSelection {get;set;}
  public boolean displayCustomerSelection {get;set;}
  public boolean displaySecondaryCustomerSelection {get;set;}
  public string inpersonSigningRedirectURL {get;set;}
  public boolean isDocuSignRecipient {get;set;}
  public boolean isInPersonSigning {get;set;}
  public String opportunityId {get;set;}

  public boolean enableEsinature {get;set;}
  public boolean isUtilityAgreement {get;set;}
  public boolean sunrunOpsSignature {get;set;}
  public Boolean confirmMode {get;set;}
  public List<SelectOption> esignOptions {get;set;}
  public List<SelectOption> contacts {get;set;}
  public List<SelectOption> secondarContacts {get;set;}
  public List<SelectOption> documentTypes {get;set;}
  private Map<String, Document_Classification__c> documentTypesRequireSignature;
  public String getDocumentType(){return documentType;}
  private Id loginUserContactId;
  private Contact loginContact;
  private Id primaryContactId1{get;set;}
  Set<String> docuSignStatus = new Set<String>();
  public string documentType{get;set;}
  public String voidReason {get;set;}
  public boolean wetSignature {get;set;}
  public String propAgreementType {get;set;}
 
      

  public String primaryContactEmail {get;set;}
  public void setPrimaryContactEmail(){
    primaryContactEmail = '';
    if(primaryContactId != null){
      primaryContactEmail =  contactMap.get(primaryContactId).email;
      primaryContactName = contactMap.get(primaryContactId).Name;
    }
  }
  
  public String partnerEmail {get;set;}
  public String partnerName {get;set;}
  public String primaryContactName {get;set;}
  public void setPartnerEmail(){
    System.debug('partnerContactObj: ' + partnerContactObj);
    System.debug('partnerContactObj.Partner_Contact__c3: ' + partnerContactObj.Partner_Contact__c);
    if(partnerContactObj != null && 
      partnerContactObj.Partner_Contact__c != null){
      Contact contactObj = [sELECT Id, name, email from Contact where Id = :partnerContactObj.Partner_Contact__c];
      partnerEmail = contactObj.email;
      partnerName = contactObj.Name;
    }
  }

  public Pagereference setESigningType(){
    
    allowPartnerContactSelection = true; 
    //if(loginContact != null){
    //  allowPartnerContactSelection = false; 
    //}
    if(eSignOption != NULL && eSignOption == DocuSignUtil.ESIGN_IN_PERSON && loginContact != null){
      partnerContactObj.Partner_Contact__c = loginContact.Id;
      partnerEmail = loginContact.email;
      partnerName = loginContact.Name;
      allowPartnerContactSelection = false;
      isInPersonSigning = true;
    }    
    return null;
  }
  
  public Pagereference verifyWetSignature(){
    intializeValues();
    if(wetSignature){
      Exception expObj = new BaseException();
      expObj.setMessage(wetsignatureInfo);
      ApexPages.addMessages(expObj);  
    }
    return null;
  }
  
  public integer numberofColumns {get;set;}
  
  public String secondaryContactEmail {get;set;}
  public void setSecondaryContactEmail(){
    System.debug('secondaryContactId: ' +secondaryContactId);
    //esignOptions = new List<SelectOption>();
    //esignOptions.add(new SelectOption(DocuSignUtil.ESIGN_EMAIL, 'Email'));
    secondaryContactEmail = '';
    if(secondaryContactId != null){
      secondaryContactEmail =  contactMap.get(secondaryContactId).email;
    }
    System.debug('secondaryContactEmail: ' +secondaryContactEmail);
  }
  public string wetsignatureInfo {set;get;}
  public void intializeValues(){
    isUtilityAgreement = false;
    sunrunOpsSignature = false;
    wetSignature = false;
    numberofColumns = 2;
    partnerContactObj.Partner_Contact__c = null;
    primaryContactId = null;
    partnerEmail = '';
    secondaryContactEmail = '';
        
    secondaryContactId = null;
    displayPartnerSelection = false;
    displayCustomerSelection = false;
    displaySecondaryCustomerSelection = false;
    enableEsinature = true;
    isUtilityAgreement = false;
    
    if(documentType != null && documentType != '' && documentTypesRequireSignature != null){
      Document_Classification__c docSettingsObj = documentTypesRequireSignature.get(documentType);
      if(docSettingsObj != null){
        if(srAttachmentUtilObj.srAttachmentsMap != null){
          List<SR_Attachment__c> tempSRAttachmentsList = srAttachmentUtilObj.srAttachmentsMap.get(documentType);
          if(tempSRAttachmentsList != null ){
            for(SR_Attachment__c srAttachmentObj : tempSRAttachmentsList){
              if(srAttachmentObj != null && srAttachmentObj.Wet_Sign_Status__c == EDPUtil.SIGNED){
                wetSignature = true;
                numberofColumns = 1;
                System.debug('wetSignature: ' + wetSignature);
              }
            }            
          }
        }
      
        System.debug('primaryContactId-0: ' + primaryContactId);
        List<Partner_Document_Relationship__c> partnerDocumentRelationships =   docSettingsObj.Partner_Document_Relationships__r;
        if(partnerDocumentRelationships != null && partnerDocumentRelationships.size() > 0){
          Partner_Document_Relationship__c ptrRelationshipObj = partnerDocumentRelationships[0];
          
          System.debug('ptrRelationshipObj.Partner_signature_required__c: ' + ptrRelationshipObj.Partner_signature_required__c);
          System.debug('primaryContactId-1: ' + primaryContactId);
          if(docSettingsObj.Document_Name__c == 'Utility Agreement'){
            isUtilityAgreement = true;
            primaryContactId = null;
          }else{
            isUtilityAgreement = false;
            sunrunOpsSignature = false;
            esignOptions = new List<SelectOption>();
            esignOptions.add(new SelectOption(DocuSignUtil.ESIGN_EMAIL, 'Email'));
            //esignOptions.add(new SelectOption(DocuSignUtil.ESIGN_IN_PERSON, 'In Person'));
            System.debug('partnerContactObj.Partner_Contact__c1: ' + partnerContactObj.Partner_Contact__c);
            System.debug('ptrRelationshipObj: ' + ptrRelationshipObj);
            Boolean requiredPartner = enablePartnerSelection(docSettingsObj.Document_Name__c, propAgreementType);
            if((ptrRelationshipObj.Partner_signature_required__c == true && wetSignature == false) 
              || requiredPartner){
              displayPartnerSelection = true;
              partnerContactObj.Partner_Contact__c = loginUserContactId;
              setPartnerEmail();
            }
            System.debug('partnerContactObj.Partner_Contact__c2: ' + partnerContactObj.Partner_Contact__c);
            
            if(ptrRelationshipObj.Customer_signature_required__c == true && wetSignature == false){
              displayCustomerSelection = true;
              primaryContactId = primaryContactId1;
              primaryContactEmail = contactMap.get(primaryContactId1).email;
              primaryContactName = contactMap.get(primaryContactId1).Name;
            }
  
            if(ptrRelationshipObj.Customer_signature_required__c == true && wetSignature == false){
              //&& docSettingsObj.Document_Name__c != 'Customer Change Order Cover Sheet'){
              displaySecondaryCustomerSelection = true;
            }
            
            if((displayCustomerSelection == true || displaySecondaryCustomerSelection == true)
              && (docSettingsObj.Document_Name__c == 'Customer Agreement') 
              && isDocuSignRecipient == true && loginContact != null){
              esignOptions.add(new SelectOption(DocuSignUtil.ESIGN_IN_PERSON, 'In Person'));              
            }
  
            if(displayPartnerSelection == false && displayCustomerSelection == false 
              && ptrRelationshipObj.SR_Ops_signature_required__c == false){
              enableEsinature = false;
            }
          }

          if(wetSignature && ptrRelationshipObj.SR_Ops_signature_required__c == true){
            wetsignatureInfo = 'This is a wet signed document and it requires only Sunrun Operations signature';
            //if(isDocuSignRecipient == true && loginContact == null){
            //  esignOptions.add(new SelectOption(DocuSignUtil.ESIGN_IN_PERSON, 'In Person'));              
            //}
          }

        }      
      }
    }
    System.debug('primaryContactId-2: ' + primaryContactId);    
  }
  public boolean getDisplayCustomerSigner(){
    Boolean result = false;
    if(documentType != null && documentType != '' && documentType == 'Customer Agreement - Unsigned'){
      result = true;
    }
    return result;
  }

  public Boolean enablePartnerSelection(String documentType, String agreementType){
    Boolean result = false;
    //if(!String.isEmpty(documentType) && (documentType == EDPUtil.CUSTOMER_CHANGEORDER_COVER_SHEET) && (agreementType  == 'Customer Owned - Bank Financed')){
    //  result = true;
    //}
    return result;
  }
  
  
  public void getRecipientInformation(String emailId){
    if(emailId != null && emailId != ''){
      eSignServiceNew.RecipientResponse responseObj = eSignServiceNew.getDocuSignRecipient(emailId);
      if(responseObj != null && responseObj.recipientNames != null && responseObj.recipientNames.size() > 0){
        System.debug('responseObj.recipientNames: ' + responseObj.recipientNames);
        isDocuSignRecipient = true;
        System.debug('isDocuSignRecipient: ' + isDocuSignRecipient);
      }      
    }
  }
  /*-- Adding code for Smart Contract Package---*/
    @future(callout=true)
    public static void asyncDocusignProcess( string proposalId,string documentType, boolean isUtilityAgreement, Id primaryContactId, Id secondaryContactId, string esign, string hostName, string hostEmail,string sunrunRecipientName, string sunrunRecipientEmail){
        Set<Id> contactIds = new Set<Id>();
        if(primaryContactId != null){
            contactIds.add(primaryContactId);
        }
        if(secondaryContactId != null){
            contactIds.add(secondaryContactId);
        }
        Map<Id, Contact> selectedContactMap = new Map<Id, Contact>([Select Id, email, name, Preferred_Language__c, Contact_Number__c, Sales_Registration_Number__c, phone from Contact where Id in :contactIds and email != null and email != '']);
        contact partnerContact  =null;
        contact primaryContact =null;
        contact secondaryContact =null;
        primaryContact = selectedContactMap.get(primaryContactId);
        eSignServiceNew.EnvResponse response = eSignServiceNew.sendDocumentsToDocusign(proposalId, documentType, esign, hostName, hostEmail,
                                                                                       primaryContact, secondaryContact, partnerContact, sunrunRecipientName, sunrunRecipientEmail);
    }
    
   /* Get the contact details based on utility contact type if exists */
    public ID primaryContactID(){
        Id primaryconID=null;
        Proposal__c proposalObj = [Select Id, Sales_Partner__c, Install_Partner__c, Opportunity__r.Id, Opportunity__r.AccountId,
                                   Agreement_Type__c from Proposal__c where Id =: proposalId];
        if(proposalObj.Opportunity__r != null && proposalObj.Opportunity__r.AccountId != null){
            opportunityId = proposalObj.Opportunity__r.Id;
            for(OpportunityContactRole roleObj : [Select Id, OpportunityId, contactId, role, isPrimary,
                                                  contact.Id, contact.Name, contact.Email from OpportunityContactRole
                                                  where OpportunityId = :proposalObj.Opportunity__r.Id order by contact.Name asc]){
                                                      if(roleObj.Role=='UtilityBillContact'){
                                                            primaryconID = roleObj.contact.Id;   
                                                      }
                                                     else if(roleObj.role == 'Homeowner' && roleObj.isprimary == true){
                                                          primaryconID = roleObj.contact.Id;           
                                                      }
                                                  }
        }
        return primaryconID;
    }
    
    public List<eSignServiceNew.DocumentTypeToProcess> getListOfDocumentsToProcess(){
        
        List<eSignServiceNew.DocumentTypeToProcess> docList= new List<eSignServiceNew.DocumentTypeToProcess>();
        Map<string,ESignDocumentTypes__c>  signMap =  ESignDocumentTypes__c.getall();
        Map<string,ESignDocumentPartnerList__c>  PartnerListForESign =  ESignDocumentPartnerList__c.getall();
        system.debug('PartnerListForESign>>' +  PartnerListForESign);
        //assign  manual upload/proposal tool 
        //String documentSource = EDPUtil.PROPOSAL_TOOL_SOURCE;
        String documentSource = EDPUtil.MANUAL_UPLOAD_SOURCE;
        if(signMap.containsKey(EDPUtil.REBATE_FORM)){
            SR_Attachment__c srAttachment = DocuSignUtil.getSRAttachmentForDocument(proposalId, signMap.get(EDPUtil.REBATE_FORM).Name);
        if(srAttachment != null ){
            system.debug('srAttachment.Proposal__r.Sales_Partner__c>>' +  srAttachment.proposal__r.Sales_Partner_Name__c);
            //find the partner to process the documents
           if(PartnerListForESign.containsKey(srAttachment.proposal__r.Sales_Partner_Name__c)){
                eSignServiceNew.DocumentTypeToProcess docToProcess = new eSignServiceNew.DocumentTypeToProcess();
                if(srAttachment.Document_Source__c!=documentSource && srAttachment.Envelop_Id__c != null 
                   && srAttachment.Envelop_Id__c != '' && docuSignStatus.contains(srAttachment.DocuSign_Status__c)){
                     docToProcess.documentName = signMap.get(EDPUtil.REBATE_FORM).Name;
                   }
                else if(srAttachment.Document_Source__c==documentSource ) {
                      docToProcess.documentName = signMap.get(EDPUtil.REBATE_FORM).Name;
                }
                
                system.debug('srAttachment>.'+ srAttachment);
                  system.debug('docToProcess>.'+ docToProcess);
                if(loginContact != null){
                    docToProcess.hostName = (loginContact.account.DocuSign_Host_Name__c != null) ? loginContact.account.DocuSign_Host_Name__c : '';
                    docToProcess.hostEmail = (loginContact.account.DocuSign_Host_Email__c != null) ? loginContact.account.DocuSign_Host_Email__c : '' ;
                }
                docToProcess.proposalId= proposalId;
                docToProcess.primaryContact =  primaryContactID();
                docToProcess.secondaryContact =  secondaryContactId;
                docToProcess.esignOption = 'Email';
                docToProcess.utilityAgreement= isUtilityAgreement;
                docToProcess.sunrunRecipientName = Label.SunRun_DocuSign_User;
                docToProcess.sunrunRecipientEmail = Label.SunRun_DocuSign_Email;
                if( docToProcess.documentName!=null &&  docToProcess.documentName!='' )
                	docList.add(docToProcess);
            }
            }
        }
        
       if(signMap.containsKey(EDPUtil.NEM_FORM)){
             eSignServiceNew.DocumentTypeToProcess docToProcess = new eSignServiceNew.DocumentTypeToProcess();
           
            SR_Attachment__c srAttachment = DocuSignUtil.getSRAttachmentForDocument(proposalId, signMap.get(EDPUtil.NEM_FORM).Name);
           system.debug('srAttachment' + srAttachment);
           if(srAttachment != null ){
                 //find the partner to process the documents
                if(PartnerListForESign.containsKey(srAttachment.proposal__r.Sales_Partner_Name__c)){
                if(srAttachment.Document_Source__c!=documentSource && srAttachment.Envelop_Id__c != null 
                   && srAttachment.Envelop_Id__c != '' && docuSignStatus.contains(srAttachment.DocuSign_Status__c)){
                    
                       docToProcess.documentName = signMap.get(EDPUtil.NEM_FORM).Name;
                    
                   }
                else if(srAttachment.Document_Source__c==documentSource) {
                    
                    docToProcess.documentName = signMap.get(EDPUtil.NEM_FORM).Name;
                }
                
                 if(loginContact != null){
                    docToProcess.hostName = (loginContact.account.DocuSign_Host_Name__c != null) ? loginContact.account.DocuSign_Host_Name__c : '';
                    docToProcess.hostEmail = (loginContact.account.DocuSign_Host_Email__c != null) ? loginContact.account.DocuSign_Host_Email__c : '' ;
                }
                //docToProcess.documentName = 'EPC';
                docToProcess.primaryContact =  primaryContactID();
                docToProcess.secondaryContact =  secondaryContactId;
                docToProcess.esignOption = 'Email';
                docToProcess.proposalId= proposalId;
                docToProcess.utilityAgreement= isUtilityAgreement;
                docToProcess.sunrunRecipientName = Label.SunRun_DocuSign_User;
                docToProcess.sunrunRecipientEmail = Label.SunRun_DocuSign_Email;
                if( docToProcess.documentName!=null &&  docToProcess.documentName!='')
                docList.add(docToProcess);
            }
           }
        }
        system.debug('docListdocList>' +  docList);
         return docList;
    }
    
    /*-- Adding code for Smart Contract Package---*/
    
  public SRAttachmentESignController(){
    isInPersonSigning = false;
    allowPartnerContactSelection = true;
    isDocuSignRecipient = false;
    docuSignStatus.add(EDPUtil.VOIDED);
    docuSignStatus.add(EDPUtil.NOT_SENT);

    confirmMode = false;
    partnerContactObj = new CustomLookup__c();
    User userObj = PRMContactUtil.getLoginUser();
    Id userId = userObj.Id;
    Id tempId = (userObj.contactId != null) ? userObj.contactId : userObj.Id;
    loginContact = PRMContactUtil.getLoginUserAccountAndContact();
    if(PRMContactUtil.isPartnerContact(loginContact)){
      loginUserContactId = loginContact.Id;
      getRecipientInformation(loginContact.account.DocuSign_Host_Email__c);
    }
    //else{
    //  getRecipientInformation(Label.SunRun_DocuSign_Email);
    //}

    System.debug('isDocuSignRecipient: ' + isDocuSignRecipient);
    contacts = new List<SelectOption>();
    secondarContacts = new List<SelectOption>();
    secondarContacts.add(new SelectOption('', ''));
    proposalId = ApexPages.currentPage().getParameters().get('id');
    Proposal__c proposalObj = [Select Id, Sales_Partner__c, Install_Partner__c, Opportunity__r.Id, Opportunity__r.AccountId, Agreement_Type__c from Proposal__c where Id =: proposalId];
    if(proposalObj.Opportunity__r != null && proposalObj.Opportunity__r.AccountId != null){  
      opportunityId = proposalObj.Opportunity__r.Id;
      propAgreementType = proposalObj.Agreement_Type__c;
      Integer counter = 0;
      Set<Id> contactIds = new Set<Id>();
      Map<Id, OpportunityContactRole> optyContactMap = new Map<Id, OpportunityContactRole>();
      
      primaryContactId = null;
      primaryContactId1 = null;
      for(OpportunityContactRole roleObj : [Select Id, OpportunityId, contactId, role, isPrimary,
                          contact.Id, contact.Name, contact.Email from OpportunityContactRole 
                          where OpportunityId = :proposalObj.Opportunity__r.Id order by contact.Name asc]){
        //contactIds.add(roleObj.contactId);
        //optyContactMap.put(roleObj.contactId, roleObj);
        
        if(!contactIds.contains(roleObj.contactId)){
          contactIds.add(roleObj.contactId);
          contacts.add(new SelectOption(roleObj.contact.Id, roleObj.contact.name));
          secondarContacts.add(new SelectOption(roleObj.contact.Id, roleObj.contact.name));
          contactMap.put(roleObj.contact.Id, roleObj.contact);  
          if(roleObj.role == 'Homeowner' && roleObj.isprimary == true){
            primaryContactId = roleObj.contact.Id;
            primaryContactId1 = roleObj.contact.Id;  
            primaryContactName = roleObj.contact.Name;        
          }else if(primaryContactId == null){
            primaryContactId = roleObj.contact.Id;
            primaryContactId1 = roleObj.contact.Id;              
          }    
        }
      }
      
      //for(Contact contactObj: [Select Id, name, email from Contact where accountId =:proposalObj.Opportunity__r.AccountId 
      //            order by name asc]){
      /*
      for(Contact contactObj: [Select Id, name, email from Contact where Id in :contactIds order by name asc]){      
        if(counter == 0){
          primaryContactId = contactObj.Id;
          primaryContactId1 = contactObj.Id;
        }
        counter ++;
        contacts.add(new SelectOption(contactObj.Id, contactObj.name));
        secondarContacts.add(new SelectOption(contactObj.Id, contactObj.name));
        contactMap.put(contactObj.Id, contactObj);
      }*/
    }
    srAttachmentUtilObj = new SRAttchmentUtil();
    srAttachmentUtilObj.userObj = userObj;
    documentTypes = new List<SelectOption> ();
    
    esignOptions = new List<SelectOption> ();
    //esignOptions.add(new SelectOption(DocuSignUtil.ESIGN_EMAIL, 'Email'));
    //esignOptions.add(new SelectOption(DocuSignUtil.ESIGN_IN_PERSON, 'In Person'));
    
    srAttachmentUtilObj.proposalId = proposalId;
    srAttachmentUtilObj.initDocumentTypes(proposalObj.Sales_Partner__c, proposalObj.Install_Partner__c);
    documentTypes = srAttachmentUtilObj.documentOptions;
    documentTypesRequireSignature = srAttachmentUtilObj.documentTypesRequireSignature;
    System.debug('documentTypesRequireSignature: ' + documentTypesRequireSignature);
    baseURL = EDPUtil.getBaseURL();
    parentURL = baseURL + '/' + proposalId;
    intializeValues();
    
    System.debug('displayPartnerSelection: ' + displayPartnerSelection);
    System.debug('isUtilityAgreement: ' + isUtilityAgreement);
    System.debug('allowPartnerContactSelection: ' + allowPartnerContactSelection);
  }
  
  public PageReference sendToDocuSign1(){ 
    inpersonSigningRedirectURL = '';
    //if(response.url != null && response.url != ''){
    //  inpersonSigningRedirectURL = response.url;
    //}
    confirmMode = true;
    eSignOption = InpersonStr;
    inpersonSigningRedirectURL = '/apex/InPersonSigningRedirect?event=test&envelopId=555CEEA3-09AC-4EE4-B638-C9A2041485F7&recipientId=1';
    //PageReference ref = new PageReference(inpersonSigningRedirectURL);
    //ref.setRedirect(true);  
    return null;
  
  }

  public PageReference sendToDocuSign(){ 
    String maximSizeError = 'Exceeded max size limit of';
    inpersonSigningRedirectURL = '';
    try{
      confirmMode = false;
      if(documentType == null || documentType == ''){
        Exception expObj = new BaseException();
        expObj.setMessage('Please select the document type');
        ApexPages.addMessages(expObj);
        return null;
      }
  
      SR_Attachment__c srAttachment = DocuSignUtil.getSRAttachment(proposalId, documentType);
      if(srAttachment != null && srAttachment.Envelop_Id__c != null 
        && srAttachment.Envelop_Id__c != '' && !docuSignStatus.contains(srAttachment.DocuSign_Status__c)){
        Exception expObj = new BaseException();
        expObj.setMessage('eSignature request is in progress. Please Void the current request to proceed further.');
        ApexPages.addMessages(expObj);
        return null;
      }
  
      Document_Classification__c docSettingsObj = documentTypesRequireSignature.get(documentType);
      List<Partner_Document_Relationship__c> partnerDocumentRelationships =  docSettingsObj.Partner_Document_Relationships__r;
      Partner_Document_Relationship__c ptrRelationshipObj;
      if(partnerDocumentRelationships != null && partnerDocumentRelationships.size() > 0){
        ptrRelationshipObj = partnerDocumentRelationships[0];
      }
        
      if(isUtilityAgreement == true && partnerContactObj.Partner_Contact__c == null && sunrunOpsSignature == false &&
        primaryContactId == null && secondaryContactId == null){
        Exception expObj = new BaseException();
        expObj.setMessage('Select a recipient to initiate the eSignature');
        ApexPages.addMessages(expObj);
        return null;  
      }      
      
      if(displayPartnerSelection == true && ptrRelationshipObj != null 
        && ptrRelationshipObj.Partner_signature_required__c == true 
        && partnerContactObj.Partner_Contact__c == null){
        Exception expObj = new BaseException();
        expObj.setMessage(CustomErrorMessages.SELECT_PARTNER_CONTACT);
        ApexPages.addMessages(expObj);
        return null;        
      }
      
      if(displayCustomerSelection == true && ptrRelationshipObj != null 
        && ptrRelationshipObj.Customer_signature_required__c == true 
        && primaryContactId == null){
        Exception expObj = new BaseException();
        expObj.setMessage(CustomErrorMessages.SELECT_PRIMARY_CONTACT);
        ApexPages.addMessages(expObj);
        return null;  
      }    

      if(displayCustomerSelection == true && ptrRelationshipObj != null 
        && ptrRelationshipObj.Customer_signature_required__c == true 
        && (primaryContactId != null && String.isEmpty(primaryContactEmail))
          || (secondaryContactId != null && String.isEmpty(secondaryContactEmail))
        ) {
        Exception expObj = new BaseException();
        expObj.setMessage(CustomErrorMessages.NULL_EMAIL);
        ApexPages.addMessages(expObj);
        return null;  
      }

      Id tempPrimaryContactId = primaryContactId;
      Id tempSecondaryContactId = secondaryContactId;
      if(enableEsinature == false){
        return null;
      }
  
      Set<Id> contactIds = new Set<Id>();
      if(partnerContactObj.Partner_Contact__c != null){
        contactIds.add(partnerContactObj.Partner_Contact__c);
      }
      
      if(primaryContactId != null){
        contactIds.add(primaryContactId);
      }

      if(secondaryContactId != null){
        contactIds.add(secondaryContactId);
      }
      Contact primaryContact;
      Contact secondaryContact;
      Contact partnerContact;
      String sunrunRecipientName = '';
      String sunrunRecipientEmail = '';
      String hostName = '';
      String hostEmail = '';
      //if(eSignOption != NULL && eSignOption == DocuSignUtil.ESIGN_IN_PERSON && loginContact == null){
      //  Exception expObj = new BaseException();
      //  expObj.setMessage(CustomErrorMessages.IN_PERSON_ERROR);
      //  ApexPages.addMessages(expObj);
      //  return null;      
      //}
      
      if(loginContact != null){
        hostName = (loginContact.account.DocuSign_Host_Name__c != null) ? loginContact.account.DocuSign_Host_Name__c : '';
        hostEmail = (loginContact.account.DocuSign_Host_Email__c != null) ? loginContact.account.DocuSign_Host_Email__c : '' ;
      }
      System.debug('hostName: ' + hostName);
      System.debug('hostEmail: ' + hostEmail);
      System.debug('eSignOption: ' + eSignOption);
      
      if(ptrRelationshipObj != null && (ptrRelationshipObj.SR_Ops_signature_required__c == true 
        || (isUtilityAgreement == true && sunrunOpsSignature == true))){
        sunrunRecipientName = Label.SunRun_DocuSign_User;
        sunrunRecipientEmail = Label.SunRun_DocuSign_Email;
      }
      
      Map<Id, Contact> selectedContactMap = new Map<Id, Contact>([Select Id, email, name, Preferred_Language__c, Contact_Number__c, Sales_Registration_Number__c, phone from Contact where Id in :contactIds and email != null and email != '']);
      partnerContact = selectedContactMap.get(partnerContactObj.Partner_Contact__c);
      if(displayPartnerSelection && (partnerContact == null || partnerContact.email == null || partnerContact.email == '')){
        Exception expObj = new BaseException();
        expObj.setMessage(CustomErrorMessages.INVALID_PARTNER_DATA);
        ApexPages.addMessages(expObj);
        return null;      
      }
  
      primaryContact = selectedContactMap.get(primaryContactId);
      if(secondaryContactId != null){
        secondaryContact = selectedContactMap.get(secondaryContactId);
        if(secondaryContact != null && secondaryContact.Id == primaryContact.Id){
          Exception expObj = new BaseException();
          expObj.setMessage('Secondary Contact should be different from the Primary Contact');
          ApexPages.addMessages(expObj);
          return null;      
        }
        if(secondaryContact == null || secondaryContact.email == null || secondaryContact.email == ''){
          Exception expObj = new BaseException();
          expObj.setMessage(CustomErrorMessages.INVALID_CUSTOMER_DATA);
          ApexPages.addMessages(expObj);
          return null;      
        }    
      }
      primaryContact = selectedContactMap.get(primaryContactId);
      if(displayCustomerSelection && (primaryContact == null | primaryContact.email == null || primaryContact.email == '')){
        Exception expObj = new BaseException();
        expObj.setMessage(CustomErrorMessages.INVALID_CUSTOMER_DATA);
        ApexPages.addMessages(expObj);
        return null;      
      }

      eSignServiceNew.EnvResponse response = eSignServiceNew.sendDocumentsToDocusign(proposalId, documentType, eSignOption, hostName, hostEmail,
                                          primaryContact, secondaryContact, partnerContact, sunrunRecipientName, 
                                          sunrunRecipientEmail);
      
      if(response.errorCode != null && response.errorCode != ''){
        Exception expObj = new BaseException();
        System.debug(response.errorCode + ': ' + response.message);
        if(response.errorCode != null &&  response.errorCode.contains(CustomErrorMessages.DOCUSIGN_MISSING_TAB_ERROR)){
          expObj.setMessage(CustomErrorMessages.MISSING_REQUIRED_TABS);
        }else if(response.message != null && response.message.contains(maximSizeError)){
          expObj.setMessage(CustomErrorMessages.MAXIMUM_REQUEST_SIZE);
        }else{
          expObj.setMessage(CustomErrorMessages.UNABLE_TO_PROCESS_E_SIGN_REQUEST);
        }
        ApexPages.addMessages(expObj);
        return null;      
      }
      confirmMode = true;
      if(response.url != null && response.url != ''){
        inpersonSigningRedirectURL = response.url;
        //PageReference ref = new PageReference(inpersonSigningRedirectURL);
        //ref.setRedirect(true);  
      //  return ref;
      }
      
    }catch(Exception expObj){
      String errorMessage = expObj.getMessage();
      if(errorMessage != null && (errorMessage.contains(CustomErrorMessages.MAXIMUM_REQUEST_SIZE) || errorMessage.contains(maximSizeError))){
        expObj.setMessage(CustomErrorMessages.MAXIMUM_REQUEST_SIZE);
      }else{
        expObj.setMessage(CustomErrorMessages.UNABLE_TO_PROCESS_E_SIGN_REQUEST);
      }
      ApexPages.addMessages(expObj);  
      confirmMode = false;
    }
    return null;
  }

  public with sharing class SRAttchmentUtil{
    public User userObj {get;set;}
    public String proposalId {get;set;} 
    public Map<String, Document_Classification__c> documentTypesRequireSignature {get;set;}
    public Map<String, List<SR_Attachment__c>> srAttachmentsMap {get;set;}
    public List<SelectOption> documentOptions;    
    public SRAttchmentUtil(){
      documentTypesRequireSignature = new Map<String, Document_Classification__c>();
      srAttachmentsMap = new Map<String, List<SR_Attachment__c>>();
      documentOptions = new List<SelectOption>();
    }

    public void initDocumentTypes(string salesPartnerId, string installPartnerId){
      Set<String> modes = new Set<String>();
      String categoryType = EDPDocumentSettings.REQUIRES_SIGNATURE;
      //modes.add('Read');
      modes.add(EDPUtil.EDIT);
      documentTypesRequireSignature = EDPDocumentSettings.getDocumentClassificationByCategroy(categoryType, null, modes, salesPartnerId, installPartnerId);
      documentOptions.add(new SelectOption('', '--None--'));
      Set<String> unsignedDocumentTypes = new Set<String>();
      Set<String> signedDocumentTypes = new Set<String>();
      Set<String> wetSignedDocuments = new Set<String>();
      Set<String> docsRequireSunRunOpsSignature = new Set<String>();
      Set<String> documentTypesSet = documentTypesRequireSignature.keySet();
      
      String soqlStr = SRAttachmentManager.getSRAttachmentSOQL();
      soqlStr += '  where Proposal__c =:proposalId AND active__c = true ' ;
      soqlStr += '  AND Document_Type_Name__c in :documentTypesSet ' ;
      for(SR_Attachment__c srAttachmentObj : Database.query(soqlStr)){
        unsignedDocumentTypes.add(srAttachmentObj.Document_Type_Name__c);
        if(srAttachmentObj.DocuSign_Status__c == null || srAttachmentObj.DocuSign_Status__c == '' 
          || srAttachmentObj.DocuSign_Status__c == EDPUtil.VOIDED
          || srAttachmentObj.DocuSign_Status__c == EDPUtil.NOT_SENT){
          unsignedDocumentTypes.add(srAttachmentObj.Document_Type_Name__c);
          List<SR_Attachment__c> tempSRAttachmentsList = srAttachmentsMap.containsKey(srAttachmentObj.Document_Type_Name__c) ? 
                                            srAttachmentsMap.get(srAttachmentObj.Document_Type_Name__c) : 
                                            new List<SR_Attachment__c>();
          tempSRAttachmentsList.add(srAttachmentObj);
          srAttachmentsMap.put(srAttachmentObj.Document_Type_Name__c, tempSRAttachmentsList);
          
          if(srAttachmentObj.Wet_Sign_Status__c == EDPUtil.SIGNED && 
            srAttachmentObj.Document_Type_Name__c != null 
            && srAttachmentObj.Document_Type_Name__c != ''){
            Document_Classification__c docClassificationObj = documentTypesRequireSignature.get(srAttachmentObj.Document_Type_Name__c);
            
            wetSignedDocuments.add(srAttachmentObj.Document_Type_Name__c);
            List<Partner_Document_Relationship__c> partnerDocumentRelationships =  docClassificationObj.Partner_Document_Relationships__r;
            if(partnerDocumentRelationships != null && partnerDocumentRelationships.size() > 0){
              Partner_Document_Relationship__c ptrRelationshipObj = partnerDocumentRelationships[0];
              if(ptrRelationshipObj != null && ptrRelationshipObj.SR_Ops_signature_required__c == true){
                docsRequireSunRunOpsSignature.add(srAttachmentObj.Document_Type_Name__c);  
              }
            }
          }
        }else{
          signedDocumentTypes.add(srAttachmentObj.Document_Type_Name__c);
        }
      }
      
      for(String signedSocumentTypeStr : signedDocumentTypes){
        unsignedDocumentTypes.remove(signedSocumentTypeStr);
      }

      for(String wetSignedSocumentTypeStr : wetSignedDocuments){
        unsignedDocumentTypes.remove(wetSignedSocumentTypeStr);
      }
      
      //if(userObj != null && userObj.ContactId == null){
        for(String docsRequireSignatureStr : docsRequireSunRunOpsSignature){
          unsignedDocumentTypes.add(docsRequireSignatureStr);
        }        
      //}
      
      for(String unSignedSocumentTypeStr : unsignedDocumentTypes){
        documentOptions.add(new SelectOption(unSignedSocumentTypeStr, unSignedSocumentTypeStr));          
      }
    }
  }
  public class BaseException extends Exception {}
}