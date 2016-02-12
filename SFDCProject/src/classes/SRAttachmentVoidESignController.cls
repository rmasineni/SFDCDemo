/************************************************************************************************************
Name    : SRAttachmentVoidESignController
Author  : ZCloud Team
Date    : Mar, 2013
Description: eSign controller used to void the envelopId.
************************************************************************************************************/
public class SRAttachmentVoidESignController {
	public String parentURL{get;set;}
	public String proposalId {get;set;}
	public String baseURL{get;set;}
	public boolean eSignInProgress {get;set;}
	public Boolean confirmVoidResponse {get;set;}
	public List<SelectOption> signedDocumentTypes {get;set;}
	public String voidReason {get;set;}
	public String documentType {get;set;}
	public String getDocumentType(){return documentType;}
	public Boolean voidESignRequest {get;set;}
	public Boolean foundNoDocumentTypes {get;set;}
	private Id loginUserContactId;

	public SRAttachmentVoidESignController(){
		confirmVoidResponse = false;
		foundNoDocumentTypes = false;
		proposalId = ApexPages.currentPage().getParameters().get('id');
		Proposal__c proposalObj = [Select Id, Install_Partner__c, Sales_Partner__c from Proposal__c where Id =:proposalId];
		signedDocumentTypes = EDPDocumentSettings.getDocumentsTypesToVoidESignRequests(proposalId, 
																						proposalObj.Sales_Partner__c,
																						proposalObj.Install_Partner__c);
		if(signedDocumentTypes == null || signedDocumentTypes != null && signedDocumentTypes.size() < 2){
			foundNoDocumentTypes = true;
		}
		baseURL = EDPUtil.getBaseURL();
		parentURL = baseURL + '/' + proposalId;
	}
	public Pagereference voidDocuSignRequest(){
		confirmVoidResponse = false;
		if(documentType == null || documentType == ''){
			Exception expObj = new BaseException();
			expObj.setMessage('Please select the Document Type');
			ApexPages.addMessages(expObj);
			return null;
		}
		if(voidReason == null || voidReason == ''){
			Exception expObj = new BaseException();
			expObj.setMessage('Please select the Void Reason');
			ApexPages.addMessages(expObj);
			return null;
		}		
		SR_Attachment__c srAttachment = DocuSignUtil.getSRAttachmentsForVoid(proposalId, documentType);
		if(srAttachment != null && srAttachment.Envelop_Id__c != null && srAttachment.Envelop_Id__c != ''){
			String result = eSignServiceNew.voidEnvelopId(srAttachment);
			if(result != 'SUCCESS'){
				Exception expObj = new BaseException();
				expObj.setMessage(result);
				ApexPages.addMessages(expObj);
				return null;				
			}
			
			srAttachment.Envelop_Id__c = '';
			srAttachment.DocuSign_Status__c = 'Voided';
			//srAttachment.Customer_Signed__c = (srAttachment.Customer_Signed__c == 'N/A') ? srAttachment.Customer_Signed__c : '';
			//srAttachment.Partner_Signed__c = (srAttachment.Partner_Signed__c == 'N/A') ? srAttachment.Partner_Signed__c : '';
			//srAttachment.SunRun_Signed__c = (srAttachment.SunRun_Signed__c == 'N/A') ? srAttachment.SunRun_Signed__c : '';
			srAttachment.DocuSign_Error_Code__c  = '';
			srAttachment.DocuSign_Error_Message__c = '';
        	update srAttachment;
        	
		}	
		confirmVoidResponse = true;
		return null;	
	}
	public class BaseException extends Exception {}
}