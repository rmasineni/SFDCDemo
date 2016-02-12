public class InPersonStatus {

	public string proposalId {get;set;}
	public String baseURL{get;set;}
	public Boolean continueSigning {get;set;}
	public Boolean backToProposal {get;set;}
	public String event {get;set;}
	public String envelopId {get;set;}
	public String recipientIdStr {get;set;}
	public Integer recipientId {get;set;}
	public String buttonTitle1 {get;set;}
	public String buttonTitle2 {get;set;}
	public Integer nextRecipientId {get;set;}
	public Boolean signingComplete {get;set;}
	public Boolean signingCancel {get;set;}
	
	public string inpersonSigningRedirectURL {get;set;}
	public boolean initiateInpersonSignature {get;set;}
	public InPersonStatus(){
		proposalId = '';
		baseURL = ApexPages.currentPage().getParameters().get('baseUrl');
		continueSigning = false;
		backToProposal = true;
		buttonTitle1 = 'Continue Signing';
		buttonTitle2 = 'Close';
		//initialize();
	}

	public void initialize(){
		initiateInpersonSignature = false;
		buttonTitle1 = '';
		event = ApexPages.currentPage().getParameters().get('event');
		envelopId = ApexPages.currentPage().getParameters().get('envelopId');
		recipientIdStr = ApexPages.currentPage().getParameters().get('recipientId');
		nextRecipientId = 0;
		recipientId = 0;
		if(recipientIdStr != null && recipientIdStr != ''){
			recipientId = integer.valueOf(recipientIdStr);
		}
		signingComplete = false;
		signingCancel = false;
		if(event != null && event == 'signing_complete'){
			signingComplete = true;
			nextRecipientId = recipientId + 1;
		}else{
			nextRecipientId = recipientId;
		}
		
		if(event != null && event == 'cancel'){
			signingCancel = true;
		}

		if(envelopId != null && envelopId != '' && nextRecipientId > 0 ){
			proposalId = '';
			List<SR_Attachment__c> srAttachmentList = [Select Id, proposal__c from SR_Attachment__c where Envelop_Id__c =:envelopId];
			if(srAttachmentList.size() > 0 ){
				proposalId = srAttachmentList[0].proposal__c;
			}
			//proposalId = 'a08g0000000SCqVAAW';
			List<In_Person_Recipient__c> inpersonList = [Select Id, Client_User_Id__c, Envelop_Id__c, Host_Email__c, Host_Name__c, In_Person_Contact__c, 
														Recipient_Id__c, Routing_Order__c, Signer_Email__c, Signer_Name__c from In_Person_Recipient__c 
														where Envelop_Id__c =:envelopId and Routing_Order__c =:nextRecipientId limit 1];
			String JSONString = '';
			if(inpersonList.size() > 0 && event != null && event == DocuSignUtil.ESIGN_INITIATE){
				initiateInpersonSignature = true;
				continueSigning = true;
			}else if(inpersonList.size() > 0){
				continueSigning = true;
				backToProposal = false;
				buttonTitle1 = 'Continue Signing';
			}else{
				backToProposal = true;
				continueSigning = false;		
				buttonTitle2 = 'Close';		
			}			
		}
		
	}
	
	public String getInpersonSigningURL(){
		String envelopString = '';
		String signingURL = '';
		eSignServiceNew.EnvResponse response = eSignServiceNew.getEmbeddedSigningURL(envelopId, nextRecipientId, envelopString);
		if(response.errorCode != null && response.errorCode != ''){
			Exception expObj = new BaseException();
			System.debug(response.errorCode + ': ' + response.message);
			expObj.setMessage(CustomErrorMessages.UNABLE_TO_PROCESS_E_SIGN_REQUEST);
			ApexPages.addMessages(expObj);
			return null;			
		}		
		if(response.url != null && response.url != ''){
			signingURL = response.url;
		}
		System.debug('signingURL: ' + signingURL);		
		return signingURL;
	}
	
	public PageReference continueInPersonSigningRequest(){
		PageReference ref;
		if(continueSigning == true){
			String signingURL = getInpersonSigningURL();
			ref = new PageReference(signingURL);	
			ref.setRedirect(true); 			
		}
		return ref;	
	}

	
	public PageReference processInPersonSigningRequest(){
		initialize();
		PageReference ref;
		if(event != null && event == DocuSignUtil.ESIGN_INITIATE){
			String signingURL = getInpersonSigningURL();
			ref = new PageReference(signingURL);			
		}else{
			String newBaseUrl = Label.PartnerPortalSiteUrl;
			String tempURL = newBaseUrl + '/apex/InPersonStatus?envelopId=' + envelopId + '&recipientId=' + recipientIdStr + '&event=' + event + '&baseUrl=' + baseUrl;
			ref = new PageReference(tempURL);	
		}
		ref.setRedirect(true); 
		return ref;
	}
	public class BaseException extends Exception {}
}