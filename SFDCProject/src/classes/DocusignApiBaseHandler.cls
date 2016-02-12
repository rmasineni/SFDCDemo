public abstract class DocusignApiBaseHandler extends RestService{
	public static String HOMEOWNER_PRIMARY = 'Homeowner_Primary';
	public String getDocuSignInpersonSigningURL(String envelopId, Integer recipientId, String envelopString){
		String signingURL = '';
		eSignServiceNew.EnvResponse response = eSignServiceNew.getEmbeddedSigningURL(envelopId, recipientId, envelopString);
		if(response.errorCode != null && response.errorCode != ''){
			//TODO:
			//Exception expObj = new BaseException();
			System.debug(response.errorCode + ': ' + response.message);
			//expObj.setMessage(CustomErrorMessages.UNABLE_TO_PROCESS_E_SIGN_REQUEST);
			//ApexPages.addMessages(expObj);
			return null;			
		}		
		if(response.url != null && response.url != ''){
			signingURL = response.url;
		}
		System.debug('signingURL: ' + signingURL);				
		
		return signingURL;
	}
	
	public Proposal__c getProposalByName(String proposalName){
		Set<String> proposalNames = new Set<String>();
		proposalNames.add(proposalName); 
		Map<String, Proposal__C> proposalMap = ProposalUtil.getProposalMapByName(proposalNames);
		return proposalMap.get(proposalName);
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
        soqlStr += '  AND proposal_source__c =:blackBirdStr ' ;
        soqlStr += '  AND Document_Classification__c = :documentTypeId ';
        soqlStr += '  AND 	Envelop_Id__c != null and Envelop_Id__c != \'\' ';
        
        System.debug('documentTypeId: ' + documentTypeId);
        System.debug('proposalId: ' + proposalId);
        
		List<SR_Attachment__c> srAttachmentList = Database.query(soqlStr);
		if(!srAttachmentList.isEmpty()){
			result = srAttachmentList[0];
		}
		System.debug('SR Attachment: ' + result);
		return result;
	}
}