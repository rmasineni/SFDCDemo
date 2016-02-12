trigger trg_srattachment_after_ins on SR_Attachment__c (after insert, after update) {
  
  try{
    
    Set<Id> srAttachmentIdsForInperson = new Set<Id>();
    Map<Id, SR_Attachment__c> srAttachments = new Map<Id, SR_Attachment__c>();
    Set<Id> proposalIds = new Set<Id>();
    Set<Id> validProposalIds = new Set<Id>();
    Set<Id> bbSignedProposalIds = new Set<Id>();
    Set<Id> srAttachmentIds = new Set<Id>();
    Set<Id> proposalToolInsertedIds = new Set<Id>();
    
    for (SR_Attachment__c srAttachment : Trigger.new) {
      if (Trigger.isInsert && srAttachment.Document_Source__c == EDPUtil.PROPOSAL_TOOL_SOURCE
        && srAttachment.Document_Type_Name__c == EDPDocumentSettings.CUSTOMER_AGREEMENT 
        && srAttachment.proposal__c != null) {
        proposalIds.add(srAttachment.proposal__c);
        validProposalIds.add(srAttachment.Proposal__c);
      }
      if (Trigger.isInsert && srAttachment.Document_Source__c == EDPUtil.PROPOSAL_TOOL_SOURCE){
        proposalIds.add(srAttachment.proposal__c);
        proposalToolInsertedIds.add(srAttachment.Id);
      }
      
      SR_Attachment__c oldSRAttachment;
      if(Trigger.isUpdate){
        oldSRAttachment = Trigger.oldMap.get(srAttachment.Id);
      }
      
      System.debug('srAttachment: ' + srAttachment);
      if(srAttachment.Document_Source__c != null
        //&& srAttachment.Document_Type_Name__c == EDPUtil.CUSTOMER_AGREEMENT 
        && srAttachment.Document_Source__c == EDPUtil.MANUAL_UPLOAD_SOURCE 
        && (srAttachment.Customer_Signed__c == EDPUtil.WET_SIGNED || srAttachment.Partner_Signed__c == EDPUtil.WET_SIGNED)
        && srAttachment.Wet_Sign_Status__c == EDPUtil.SIGNED
        && srAttachment.Parent_SR_Attachment__c == null
        //&& (srAttachment.Parent_Proposal_Name__c == null || srAttachment.Parent_Proposal_Name__c == '')
        && ((Trigger.isInsert) || (oldSRAttachment != null 
          && (srAttachment.Document_Source__c  != oldSRAttachment.Document_Source__c 
            || srAttachment.Customer_Signed__c  != oldSRAttachment.Customer_Signed__c 
            || srAttachment.Partner_Signed__c  != oldSRAttachment.Partner_Signed__c 
            || srAttachment.Document_Type_Name__c  != oldSRAttachment.Document_Type_Name__c
            || srAttachment.Wet_Sign_Status__c  != oldSRAttachment.Wet_Sign_Status__c)))){
        if(srAttachment.Proposal__c != null){
          //bbSignedProposalIds.add(srAttachment.Proposal__c);
          srAttachmentIds.add(srAttachment.Id);
          proposalIds.add(srAttachment.proposal__c);
        }  
      }
      
      if((Trigger.isInsert || (Trigger.isUpdate && oldSRAttachment.DocuSign_Status__c != srAttachment.DocuSign_Status__c))
        && (srAttachment.DocuSign_Status__c != null && (srAttachment.DocuSign_Status__c == EDPUtil.VOIDED))) {
        srAttachmentIdsForInperson.add(srAttachment.Id);
      }
    }
    
    if(srAttachmentIdsForInperson.size() > 0){
      list<In_Person_Recipient__c> inpersonList = [Select Id from In_Person_Recipient__c where SR_Attachment__c IN :srAttachmentIdsForInperson];
      if(inpersonList.size() > 0){
        delete inpersonList;
      }
    }
    
    System.debug('srAttachmentIds: ' + srAttachmentIds);
    Set<Id> bbSignedSRAttachment = new Set<Id>();
    if(srAttachmentIds.size() > 0){
      Set<String> documentNames = new  Set<String>();
      documentNames.add(EDPUtil.CUSTOMER_AGREEMENT);
      documentNames.add(EDPUtil.CHANGE_ORDER_COVER_SHEET);
      documentNames.add(EDPUtil.EPC);
      for(SR_Attachment__c srAttachmentObj : [Select Id, Document_Type_Name__c, Parent_Proposal_Name__c, Proposal__c, proposal__r.name,  
                          proposal__r.Change_Order_Information__c, proposal__r.Proposal_Source__c,  proposal__r.signed__c  
                          from SR_Attachment__c where Id in :srAttachmentIds 
                          and Document_Type_Name__c in :documentNames]){
        
        if(srAttachmentObj.Parent_Proposal_Name__c != null && srAttachmentObj.Parent_Proposal_Name__c != '' && 
          srAttachmentObj.Parent_Proposal_Name__c == srAttachmentObj.proposal__r.name){
          
          if(ProposalUtil.canUpdateProposalSignedStatus(srAttachmentObj.proposal__r, srAttachmentObj.Document_Type_Name__c) == true){
            bbSignedProposalIds.add(srAttachmentObj.Proposal__c);
          }
          proposalIds.add(srAttachmentObj.proposal__c);
        }
      }
    }
    
    Map<Id, Proposal__c> proposalsMap = new Map<Id, Proposal__c>();
    if(!proposalIds.isEmpty()){
      proposalsMap= ProposalUtil.getProposalsMap(proposalIds);
    }
    List<Proposal__c> modifiedProposals = new List<Proposal__c>();
    if(proposalsMap.size() > 0){
      for(Proposal__c proposalObj : proposalsMap.values()){
        Boolean modified = false;
        if(proposalObj.Proposal_Source__c != null && proposalObj.Proposal_Source__c == ProposalUtil.BLACK_BIRD 
          && bbSignedProposalIds.contains(proposalObj.Id)){
          proposalObj.signed__c = true;
          modified = true;
        }
        
        if(validProposalIds.contains(proposalObj.Id)){
          proposalObj.status__c = 'Valid';
          modified = true;
        }
        if(modified == true){
          modifiedProposals.add(proposalObj);
        }
      }
      
      if(modifiedProposals.size() > 0){
        update modifiedProposals;
      }
    }
    
    Set<Id> documentTypeIds = new Set<Id>();
    Map<Id, Set<Id>> documentTypesByProposal = new Map<Id, Set<Id>>();
    System.debug('proposalToolInsertedIds: ' + proposalToolInsertedIds);
    for(Id srAttachmentId : proposalToolInsertedIds) {
      SR_Attachment__c srAttachmentobj = Trigger.newMap.get(srAttachmentId);
      Proposal__c proposalObj = proposalsMap.get(srAttachmentobj.proposal__c);
      System.debug('proposalToolInsertedIds: ' + srAttachmentobj.parent_proposal_name__c);
      System.debug('parent_proposal_name__c: ' + srAttachmentobj.parent_proposal_name__c);
      System.debug('proposalObj.name: ' + proposalObj.name);
      if(proposalObj != null && srAttachmentobj.parent_proposal_name__c != null && 
        proposalObj.name == srAttachmentobj.parent_proposal_name__c){
        documentTypeIds.add(srAttachmentobj.Document_Classification__c);
        Set<Id> tempDocumentTypeIds = documentTypesByProposal.containsKey(srAttachmentobj.proposal__c) ? documentTypesByProposal.get(srAttachmentobj.proposal__c) : new Set<Id>();
        tempDocumentTypeIds.add(srAttachmentobj.Document_Classification__c);
        documentTypesByProposal.put(srAttachmentobj.proposal__c, tempDocumentTypeIds);
      }
    }
    
    String proposalSource = ProposalUtil.BLACK_BIRD;
    List<SR_Attachment__c> modifiedSRAttachmentList = new List<SR_Attachment__c>();
    if(!documentTypesByProposal.isEmpty()){
      Set<Id> srProposalIds = documentTypesByProposal.keySet();
      for(SR_Attachment__c srAttachmentobj : [Select Id, Active__c, Document_Classification__c, Proposal__r.Id, Proposal__r.Name, Parent_Proposal_Name__c from SR_Attachment__c 
                          WHERE Proposal__c in :srProposalIds and Document_Classification__c in :documentTypeIds and Active__c = true
                          and Proposal_Source__c =:proposalSource]){
        System.debug('srAttachmentobj.Parent_Proposal_Name__c: ' + srAttachmentobj.Parent_Proposal_Name__c);
        System.debug('srAttachmentobj.Proposal__r.Name: ' + srAttachmentobj.Proposal__r.Name);
        System.debug('srAttachmentobj.Document_Classification__c: ' + srAttachmentobj.Document_Classification__c);
        System.debug('tempDocumentTypeIds: ' + documentTypesByProposal.get(srAttachmentobj.Document_Classification__c));
        if(srAttachmentobj.Parent_Proposal_Name__c != null && srAttachmentobj.Parent_Proposal_Name__c != srAttachmentobj.Proposal__r.Name){
          Set<Id> tempDocumentTypeIds  = documentTypesByProposal.get(srAttachmentobj.Proposal__r.Id);
          if(tempDocumentTypeIds != null && !tempDocumentTypeIds.isEmpty() && tempDocumentTypeIds.contains(srAttachmentobj.Document_Classification__c)){
            srAttachmentobj.active__c = false;
            modifiedSRAttachmentList.add(srAttachmentobj);
             
          }
        }
      }
      
      if(!modifiedSRAttachmentList.isEmpty()){
        update modifiedSRAttachmentList;
               }    
    }
	
      //calling async process for invoking docusign documents once customer agreement is processed
   List<eSignServiceNew.DocumentTypeToProcess> dtplist = new List<eSignServiceNew.DocumentTypeToProcess>();
        for (SR_Attachment__c srAttachment : Trigger.new) {
            if(trigger.isInsert){
                 if(srAttachment.Document_Type_Name__c == EDPUtil.CUSTOMER_AGREEMENT && srAttachment.Document_Source__c!=EDPUtil.PROPOSAL_TOOL_SOURCE 
                   && srAttachment.Envelop_Id__c!=''){
                    SRAttachmentESignController srController = new SRAttachmentESignController();
                    dtplist= srController.getListOfDocumentsToProcess();
                       system.debug('dtplist' +  dtplist);
                    
                } 
            }			
        }
      	system.debug('doclistdoclist>' +  dtplist);
        if(!dtplist.isEmpty()){
            for (eSignServiceNew.DocumentTypeToProcess dtpObj:dtplist){
                SRAttachmentESignController.asyncDocusignProcess(dtpObj.proposalId,dtpObj.documentName,dtpObj.utilityAgreement, 
                                                       dtpObj.primaryContact, dtpObj.secondaryContact, dtpObj.esignOption,dtpObj.hostName,dtpObj.hostEmail,dtpObj.sunrunRecipientName,dtpObj.sunrunRecipientEmail);
            }
        }
      
  
    
  }catch(Exception exceptionObj){
    System.debug('After: SR Attachment: ' + exceptionObj);
    for (SR_Attachment__c srAttachment : Trigger.new){
      srAttachment.adderror(exceptionObj.getMessage());
    }
  }
  
}