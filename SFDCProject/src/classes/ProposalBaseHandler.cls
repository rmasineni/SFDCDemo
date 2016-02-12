public abstract class ProposalBaseHandler extends RestService implements RestRequestHandler {
    public static String HOMEOWNER_PRIMARY = 'Homeowner_Primary';
    public String getDocuSignInpersonSigningURL(String envelopId, Integer recipientId, String envelopString){
        String signingURL = '';
        eSignServiceNew.EnvResponse response = eSignServiceNew.getEmbeddedSigningURL(envelopId, recipientId, envelopString);
        if(response.errorCode != null && response.errorCode != ''){
            System.debug(response.errorCode + ': ' + response.message);
            throw createBusinessException(RestServiceDto.Unable_To_Process_Request, 'Unable to get the DocuSign inperson URL for the envelop [' + envelopId + '].');
        }       
        if(response.url != null && response.url != ''){
            signingURL = response.url;
        }
		return signingURL;
    }
    
    public Proposal__c getProposalByName(String proposalName){
        Set<String> proposalNames = new Set<String>();
        proposalNames.add(proposalName); 
        Map<String, Proposal__C> proposalMap = new Map<String, Proposal__C>();
        //ProposalUtil.getProposalMapByName(proposalNames);
        if(proposalNames.size() > 0 ){
			for(Proposal__c propObj : [Select Id, Opportunity__c, name, Stage__C, cost_stack__c, Total_Solar_Prepay_Required__c, Conditional_Approval__c, ACH_Required__c, Sunrun_Credit_Status__c,Agreement_Type__c,Sales_Partner__c,Finance_Type__c,
                                            Primary_Customer__c,Credit_Status__c, Credit_team_notes__c,  Current_Customer_Credit_Report__c, home_type__c, Customer_Signoff_Date__c,
                                            Conditional_Approval_Amount__c, Original_Proposal_ID__c, Partner_Financed__c, Original_Proposal_ID__r.Id, Install_Partner__c,
                                            Original_Proposal_ID__r.Conditional_Approval__c, Original_Proposal_ID__r.ACH_Required__c, Name_on_Credit_Verified__c, Date_Time_Ops_Received_Proposal_back__c,
                                            Original_Proposal_ID__r.Primary_Customer__c, Original_Proposal_ID__r.Credit_Status__c, Original_Proposal_ID__r.Name_on_Credit_Verified__c,
                                            Original_Proposal_ID__r.Credit_team_notes__c,Original_Proposal_ID__r.Current_Customer_Credit_Report__c, Original_Proposal_ID__r.Date_Time_Ops_Received_Proposal_back__c,
                                            Original_Proposal_ID__r.Conditional_Approval_Amount__c, Original_Proposal_ID__r.Partner_Financed__c, Original_Proposal_ID__r.Customer_Signoff_Date__c,
                                            Original_Proposal_ID__r.Sunrun_Credit_Status__c, Original_Proposal_ID__r.Total_Solar_Prepay_Required__c 
                                            from Proposal__c where name in :proposalNames]){
                proposalMap.put(propObj.Name, propObj);
            }           
        }
		return proposalMap.get(proposalName);
    }
    
    public Opportunity getOpportunity(String prospectId){
        Opportunity resultOpty;
        List<Opportunity> optyList = [Select Id, name from Opportunity where Prospect_Id__c =:prospectId];
        if(optyList != null && !optyList.isEmpty()){
            resultOpty = optyList[0];
        }
        return resultOpty;
    }
    
    public Map<String, Contact> getOptyContacts(Id optyId){
        Map<String, Contact> contactMap = new Map<String, Contact>();
        for(OpportunityContactRole roleObj : [Select Id, OpportunityId, contactId, role, isPrimary, contact.Id, contact.Name, contact.Email,
                                              contact.account.DocuSign_Host_Name__c, contact.account.DocuSign_Host_Email__c,
                                              contact.Preferred_Language__c, contact.Contact_Number__c, contact.Sales_Registration_Number__c, 
                                              contact.phone from OpportunityContactRole where OpportunityId = :optyId order by contact.Name asc]){
                                                  if(roleObj.role == 'Homeowner' && roleObj.isprimary == true){
                                                      contactMap.put(HOMEOWNER_PRIMARY, roleObj.contact);
                                                  }else if(!String.isEmpty(roleObj.role)){
                                                      contactMap.put(roleObj.role, roleObj.contact);                        
                                                  } 
                                              }
        return contactMap;  
    }
    
    public SR_Attachment__c getSRAttachmentWithEnvelopId(Id proposalId, Id documentTypeId){
        SR_Attachment__c result;
        String blackBirdStr = ProposalUtil.BLACK_BIRD;
        String soqlStr = SRAttachmentManager.getSRAttachmentSOQL();
        soqlStr += '  WHERE Proposal__c =:proposalId ' ;
        soqlStr += '  AND active__c = true ' ;
        //soqlStr += '  AND proposal_source__c =:blackBirdStr ' ;
        soqlStr += '  AND Document_Classification__c = :documentTypeId ';
        soqlStr += '  AND   Envelop_Id__c != null and Envelop_Id__c != \'\' ';
        
        System.debug('documentTypeId: ' + documentTypeId);
        System.debug('proposalId: ' + proposalId);
        System.debug('soqlStr: ' + soqlStr);
        
        List<SR_Attachment__c> srAttachmentList = Database.query(soqlStr);
        if(!srAttachmentList.isEmpty()){
            result = srAttachmentList[0];
        }
        System.debug('SR Attachment: ' + result);
        return result;
    }
    
    public String getS3FolderNameByDocumentType(String parentId, String documentType){
    	return 'QUALIFICATION_PHOTO';
    }

	public List<SR_Attachment__c> getSRAttachments(String proposalName, String documentType, Set<String> srIds) {
		String proposalsoql = createSoqlWithAuditFields(getProposalFieldMapping().values(), 'Proposal__c', 'Name = :proposalName');
       	List<SObject> proposalSObjects = Database.query(proposalsoql);
        if (proposalSObjects.isEmpty()) {
            throw createBusinessException(RestServiceDto.Error_NotFound, 'Proposal with specified Proposal Number [' + proposalName + '] is not found');
        }
        Proposal__c proposalObj = (Proposal__c) proposalSObjects.get(0);
		
		Id proposalId = proposalObj.Id;
		String documentSource = EDPUtil.PROPOSAL_TOOL_SOURCE;

		String soql = '';
		soql = SRAttachmentManager.getSRAttachmentSOQL();
		soql += ' where proposal__c =:proposalId and active__c = true and document_source__c != :documentSource  ' ;
		if(!String.isEmpty(documentType)){
			documentType = EncodingUtil.urlDecode(documentType, 'UTF-8');
			soql += ' and Document_Type_Name__c =:documentType ';
		}
		if(srIds != null && !srIds.isEmpty()){
			soql += ' and Id in :srIds ';
		}
		List<SObject> sobjs = Database.query(soql);
		return sobjs;
    }

	public void prepareSRAttachmentResponse(List<SR_Attachment__c> srAttachments, RestServiceDto.Request req, RestServiceDto.Response resp) {
		Map<String, String> fieldMappings = getSRAttachmentFieldMapping();
		resp.jsonWriter = new JsonWriter(true);
		Integer i = 0;
		for(SR_Attachment__c srAttachmentObj : srAttachments){
			resp.jsonWriter.with(i);
			if(srAttachmentObj.active__c == true){
				SRAttachmentWrapper srAttachmentWrapperObj = new SRAttachmentWrapper(srAttachmentObj);
				resp.jsonWriter.write('url', srAttachmentWrapperObj.signedURL);
			}
		    for (String restField : fieldMappings.keySet()) {
		    	resp.jsonWriter.writeIfNotNull(restField, getValue(srAttachmentObj, fieldMappings.get(restField)));
		    }
			resp.jsonWriter.write('createdDate', srAttachmentObj.CreatedDate);
		    resp.jsonWriter.write('lastModifiedDate', srAttachmentObj.LastModifiedDate);
			resp.jsonWriter.endWith();
			i++;   	
		}
	}


    public Map<String, String> getSRAttachmentFieldMapping() {
		return RestServiceDto.getFieldMapping('Proposal Api', 'SR_Attachment__c');        
    }    
    
    public Map<String, String> getProposalFieldMapping() {
		return RestServiceDto.getFieldMapping('Proposal Api', 'Proposal__c');        
    }
	
	public Partner_Document_Relationship__c getPartnerDocumentRelationship(List<Partner_Document_Relationship__c> partnerDocumentRelationships, String partnerType){
		Partner_Document_Relationship__c result;
		if(partnerDocumentRelationships != null){
			for(Partner_Document_Relationship__c tempObj : partnerDocumentRelationships){
				if(tempObj.partner_type__c == partnerType){
					result = tempObj;
					break;
				}
				if(tempObj.partner_type__c == EDPUtil.FULL_SERVICE){
					result = tempObj;
				}
			}
		}
		return result;
	} 
}