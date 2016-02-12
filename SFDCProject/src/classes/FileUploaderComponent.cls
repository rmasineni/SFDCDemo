global class FileUploaderComponent {
 	public Set<String> documentTypes;
	public String docSignStatus {get;set;}
  	public List<SelectOption> Status {get;set;}
	public String salesPartnerId {get;set;}
	public String installPartnerId {get;set;}	
	public String opportunityId {get;set;}  	
	public Map<String, SR_Attachment__c> existingSRAttachments = new Map<String, SR_Attachment__c>();
	public Map<String, SR_Attachment__c> getExistingSRAttachments(){ return existingSRAttachments; }  
	public Map<String, Document_Classification__c> documentClasification = new Map<String, Document_Classification__c>();
	public Map<String, Document_Classification__c> getDocumentClasification() { return documentClasification; }
	public boolean isSunrunUser {get;set;}
	public String uploadType {get;set;}
    public String proposalprefix  {get;set;}
    public String scprefix  {get;set;}
	public String proposalName {get;set;}
	public String sObjectType {get;set;}
	    	
	public FileUploaderComponent(){
		User userObj = PRMContactUtil.getLoginUser();
		Contact contactObj = PRMContactUtil.getLoginUserAccountAndContact();
		isSunrunUser = false;
		if(userObj != null && !PRMContactUtil.isPartnerContact(contactObj)){
			isSunrunUser = true;
		}	
		proposalprefix = Schema.SObjectType.Proposal__c.getKeyPrefix();
		scprefix = Schema.SObjectType.ServiceContract.getKeyPrefix();  

	}

	Proposal__c proposalObj;
	ServiceContract scObj;
	public String relatedObject{
    	get;
    	set{
			relatedObject = value;
			if(relatedObject != null && relatedObject != ''){
				String relatedObjectIdStr = relatedObject + ''; 
        		if(relatedObjectIdStr.startsWith(proposalprefix)){				
					proposalObj = [Select Id, Name, Opportunity__c, Install_Partner__c, Sales_Partner__c, stage__c from Proposal__C where Id =:relatedObject];
					proposalName = proposalObj.Name;
					opportunityId = proposalObj.Opportunity__c;
					sObjectType = 'Proposal';   
					documentClasification = getDocumentClassificationByCategroy(relatedObject);
        		}else if(relatedObjectIdStr.startsWith(scprefix)){		
					scObj = [Select Id, Name, Opportunity__c from ServiceContract where Id =:relatedObject];
					proposalName = scObj.Name;
					opportunityId = scObj.Opportunity__c;    
					sObjectType = 'ServiceContract';    			
					getGeneralDocuments(relatedObject);
        		}
				existingSRAttachments = SRAttachmentManager.getSRAttachmentsInfo(relatedObject);
			}
		}
    }
	
	public Set<String> getDocumentTypes(){
    	init();
    	return documentTypes;
    }
	
	public void init(){
		if(documentTypes == null){
			documentTypes = new Set<String>();      
    	}
		String relatedObjectIdStr = relatedObject + ''; 
    	if(documentTypes.size() == 0 && (relatedObjectIdStr.startsWith(proposalprefix))){
			System.debug('relatedObject: ' + relatedObject);
			installPartnerId = proposalObj.Install_Partner__c;
			salesPartnerId = proposalObj.Sales_Partner__c;
			proposalName = proposalObj.Name;
			Set<String> modes = new Set<String>();
			modes.add('Edit');
			documentTypes = EDPDocumentSettings.getVisibleDocumentTypesByCategroy('All', modes, 
																				proposalObj.Sales_Partner__c, 
																				proposalObj.Install_Partner__c);
		}
	}
	public String getBaseURL() {
    	String baseURL = EDPUtil.getBaseURL();
    	return baseURL;
	} 

	@RemoteAction
	global static Map<String, Document_Classification__c> getGeneralDocuments(String proposalId){
		//Proposal__c proposalObj = [Select Id, Install_Partner__c, Sales_Partner__c from Proposal__c where Id =:proposalId];
		String categoryType = EDPDocumentSettings.GENERAL_UPLOAD;
		Set<String> modes = new Set<String>();
		modes.add(EDPUtil.EDIT);
		Map<String, Document_Classification__c> docClassificationMap = EDPDocumentSettings.getGeneralDocuments(categoryType);
    	return docClassificationMap;
	}

	
	@RemoteAction
	global static Map<String, Document_Classification__c> getDocumentClassificationByCategroy(String proposalId){
		System.debug('proposalId: ' + proposalId);
		Proposal__c proposalObj = [Select Id, Install_Partner__c, Sales_Partner__c from Proposal__c where Id =:proposalId];
		String categoryType = EDPDocumentSettings.MANUAL_UPLOAD;
		Set<String> modes = new Set<String>();
		modes.add(EDPUtil.EDIT);
		Map<String, Document_Classification__c> docClassificationMap = EDPDocumentSettings.getDocumentClassificationByCategroy(
		                                            categoryType, null, modes, 
		                                            proposalObj.Sales_Partner__c,
		                                            proposalObj.Install_Partner__c);
    	return docClassificationMap;
	}
	
	@RemoteAction
	global static ExistingAttachmentsResponse checkexistingSRAttachments(String relatedObjectId, Map<String, String> newAttachments){ 

		User userObj = PRMContactUtil.getLoginUser();
		Boolean isSunrunUser = false;
		if(userObj != null && userObj.ContactId == null){
			isSunrunUser = true;
		}

		ExistingAttachmentsResponse responseObj = new ExistingAttachmentsResponse();
		system.debug('relatedObjectId'+relatedObjectId);
	    String result = '';
		String overwriteExistingDocs = '';
	    String errMsg = '';
	    
	    Set<String> proposalStagesAllowedForUplaod = new Set<String>();
		
		proposalStagesAllowedForUplaod.add(EDPUtil.CREATED);
		proposalStagesAllowedForUplaod.add(EDPUtil.ON_HOLD);
		proposalStagesAllowedForUplaod.add(EDPUtil.PENDING);
		proposalStagesAllowedForUplaod.add(EDPUtil.SR_DECLINED);
			
		Set<String> proposalStagesCondAllowedForUplaod = new Set<String>();
		
		proposalStagesCondAllowedForUplaod.add(EDPUtil.SUBMITTED);
		proposalStagesCondAllowedForUplaod.add(EDPUtil.CREDIT_APPROVED);
		proposalStagesCondAllowedForUplaod.add(EDPUtil.SR_SIGNOFF_REVIEW);
		proposalStagesCondAllowedForUplaod.add(EDPUtil.CREDIT_REVIEW);
		proposalStagesCondAllowedForUplaod.add(EDPUtil.SR_OPS_RECEIVED);
		proposalStagesCondAllowedForUplaod.add(EDPUtil.SR_OPS_REVIEWED);
		proposalStagesCondAllowedForUplaod.add(EDPUtil.SR_OPS_APPROVED);
		proposalStagesCondAllowedForUplaod.add(EDPUtil.PENDING_TASK_COMPLETED);
			
		Set<String> eSignStatusNotInProgress = new Set<String>();
			
		eSignStatusNotInProgress.add(EDPUtil.VOIDED);
		eSignStatusNotInProgress.add(EDPUtil.NOT_SENT);
	    
	    Map<String, SR_Attachment__c> tempExistingSRAttachments = SRAttachmentManager.getSRAttachmentsInfo(relatedObjectId);
	    System.debug('tempExistingSRAttachments'+ tempExistingSRAttachments);
	    
	    Map<String, Document_Classification__c> documentClasification = new Map<String, Document_Classification__c>();
	    documentClasification = getDocumentClassificationByCategroy(relatedObjectId);
	    System.debug('documentClasification'+ documentClasification);
	    
	    Proposal__c proposalObj = [Select Stage__c from Proposal__c where Id =:relatedObjectId];
	    System.debug('Proposal Object: '+proposalObj);
	    
	    Map<Id, String> docTypeIdToName = new Map<Id, String>();
	    for(Document_Classification__c docTypeAndId:[select Id, name from Document_Classification__c]){
	    	docTypeIdToName.put(docTypeAndId.Id, docTypeAndId.name);
	    }
	    
	    System.debug('docTypeIdToName'+docTypeIdToName);
	    
	    
	    if(tempExistingSRAttachments == null || tempExistingSRAttachments.size() == 0) {
	    	System.debug('inside tempExistingSRAttachments');
			return responseObj;
	    }
	    
	    Set<String> existingSignedDocs = new Set<String>();
	    for(SR_Attachment__c srAttachmentObj : tempExistingSRAttachments.values()){
	    	Document_Classification__c classificationObj = documentClasification.get(srAttachmentObj.Document_Type_Name__c);
	    	if(classificationObj != null && classificationObj.ESignature_allowed__c == true){
	    		existingSignedDocs.add(srAttachmentObj.Document_Type_Name__c);
	    	}
	    }

	    for(String newDocumentType : newAttachments.keySet()){
	    	System.debug('newDocumentType'+ newDocumentType);
			String newFileName = newAttachments.get(newDocumentType);
			String newDocuTypeName = docTypeIdToName.get(newDocumentType);
			
			if(existingSignedDocs.contains(newDocuTypeName)){
				overwriteExistingDocs +=  newDocuTypeName + '\n';
			}

			SR_Attachment__c attchInfo = tempExistingSRAttachments.get(newDocuTypeName);
			
			system.debug('Attach Info= '+attchInfo);
			boolean allowToOverWrite = false;
			boolean isInFlight = false;
			String docuSignStatus = '';
			String proposalStage = '';
			if(attchInfo != null && proposalObj != null) {
				System.debug('newDocumentType'+ newDocumentType);
				if(newDocumentType != EDPUtil.OTHER){
						docuSignStatus = attchInfo.DocuSign_Status__c;
						proposalStage = proposalObj.Stage__c;
						
						System.debug('docuSignStatus: ' + docuSignStatus);
						if(docuSignStatus != null && docuSignStatus != '' && !eSignStatusNotInProgress.contains(docuSignStatus)) {
							isInFlight = true;
						}
						if(documentClasification != null && documentClasification.get(newDocuTypeName) != null) {
							
			      	   	  	allowToOverWrite = documentClasification.get(newDocuTypeName).Allow_To_Over_Write__c;
			      	   	  	System.debug('allowToOverWrite INSIDE If'+allowToOverWrite);
			      	   	}

			      	   	//Checking Whether Document eSign In in Progress or Completed
			      	   	if(isInFlight == true && 
			      	   		(isSunrunUser == false || 
			      	   			(isSunrunUser == true && (proposalStage == EDPUtil.SR_OPS_APPROVED || docuSignStatus != EDPUtil.WET_SIGNED))
			      	   		)
			      	   	){
							errMsg = CustomErrorMessages.eSignature_ERROR(newDocuTypeName);
			      	    	result += (result == '' ) ? errMsg : ' \n ' + errMsg ;
			      	   		continue;
						}

						if(proposalStagesAllowedForUplaod.contains(proposalStage)){
							if( !isInFlight ){
								system.debug('if not in flight');
								continue;
							}
						}
						System.debug('isSunrunUser: ' + isSunrunUser);
						System.debug('proposalStage: ' + proposalStage);
						if((isSunrunUser == false && proposalStagesCondAllowedForUplaod.contains(proposalStage))
							|| (isSunrunUser == true && proposalStage == EDPUtil.SR_OPS_APPROVED)){

							Partner_Document_Relationship__c ptrDocRelObj;
							if(documentClasification != null && documentClasification.get(newDocuTypeName).Partner_Document_Relationships__r != null 
								&& documentClasification.get(newDocuTypeName).Partner_Document_Relationships__r.size() > 0){
								ptrDocRelObj = documentClasification.get(newDocuTypeName).Partner_Document_Relationships__r[0];
								
								system.debug('ptrDocRelObj:....'+ptrDocRelObj);
							}
							
							system.debug('ptrDocRelObj.Mandatory_Document__c:....'+ptrDocRelObj.Mandatory_Document__c);
							// When Doc is Mandatory
							if(ptrDocRelObj != null && ptrDocRelObj.Mandatory_Document__c == true ){
								system.debug('Err Msg: '+ CustomErrorMessages.MANDATORY_ERROR);
			      	     		errMsg =  newDocuTypeName + ' - ' + CustomErrorMessages.MANDATORY_ERROR ;
			      	   			result += (result == '' ) ? errMsg : ' \n ' + errMsg;	
			      	   			continue;					
							}
							
							//When Not Mandatory, is not in flight and is not overwritten
							if(!isInFlight && ptrDocRelObj != null && ptrDocRelObj.Mandatory_Document__c == false ){
								
								system.debug('Inside Not Mandatory...');
								if(!allowToOverWrite){
									system.debug('Err Msg: '+ CustomErrorMessages.EXISTING_ERROR);
			      	     			errMsg =  newDocuTypeName + ' - ' + CustomErrorMessages.EXISTING_ERROR ;
			      	   				result += (result == '' ) ? errMsg : ' \n ' + errMsg;	
			      	   				continue;	
								}
								else if(allowToOverWrite) {
									system.debug('if overwrite is true');
									continue;
								}
							}
							
							
						}
				}
			}   
		} 
		
		if(result != ''){
			responseObj.errorMessage = result;
			responseObj.status = 'Error';
		}else if(overwriteExistingDocs != ''){
			overwriteExistingDocs = 'Would you like to replace the following document(s) ? \n ' + overwriteExistingDocs;
			responseObj.errorMessage = overwriteExistingDocs;
			responseObj.status = 'Confirm';
		}

		system.debug('RESULT...:'+result);
		return responseObj; 
	}  

	@RemoteAction
	global static SunRunProxyRequestInfo getS3ProxyInfoForPut(String sObjectType, String proposalName, String objectName, String mimeType){
    	String restConnection = (sObjectType == 'ServiceContract') ? SunRunS3RestConnection.SERVICE_CONTRACT_DOCS_SETTINGS_NAME : SunRunS3RestConnection.UPLOADED_DOCS_SETTINGS_NAME;
    	SunRunProxyRequestInfo requestInfo;
		System.debug('restConnection: ' + restConnection);
		requestInfo = SunRunS3RestConnection.getSignedURL('PUT', restConnection, proposalName, objectName, mimeType);
		System.debug('requestInfo: ' + requestInfo);
		return requestInfo;
	}
	
	//@RemoteAction
	//global static String getSignedURL(String actionType, String objectName, String mimeType){
    //	String url;
    //	if(actionType != null && actionType != '' && actionType == 'PUT'){
    //  		url = S3GateKeeper.getSignedUrlForPut(objectName, mimeType);
    //  		return url;
	//	}else if(actionType != null && actionType != '' && actionType == 'GET'){
	///		url = S3GateKeeper.getSignedUrlForGET(objectName);
	//		return url;      
	//	}
	//	return '';
	//}

	@RemoteAction
	global static SRUpsertResponse upsertSRAttachment(String parentObjectId, String fileName, String amazonS3FileName, 
													String contactDocumentType, String contactDocumentTypeName, 
													String fileSize, String contactDocumentWetSign){
		
		UpsertRequest requestObj = new UpsertRequest();
		requestObj.relatedObjectId = parentObjectId;
		requestObj.fileName = fileName;
		requestObj.amazonS3FileName = amazonS3FileName;
		requestObj.documentType = contactDocumentType;
		requestObj.documentTypeName = contactDocumentTypeName; 
		requestObj.size = fileSize;
		requestObj.wetSign = contactDocumentWetSign;
		
		System.debug('requestObj: ' + requestObj);
		Boolean result = SRAttachmentManager.upsertSRAttachment(requestObj);
	    SRUpsertResponse responseObj = new SRUpsertResponse();
	    responseObj.fileName = requestObj.fileName;
	    if(result == true){
	      responseObj.status = 'Success';
	
	    }else{
	      responseObj.status = 'Failure';
	    }
	    return responseObj;
	}

	global class UpsertRequest{
		public String relatedObjectId{get;set;} 
		public String fileName{get;set;}
		public String amazonS3FileName{get;set;}
		public String documentType{get;set;}
		public String documentTypeName{get;set;}
		public String size{get;set;}
		public String wetSign{get;set;}
		public String conentType{get;set;}
	}
	
	global class SRUpsertResponse{
		public String status{get;set;}
		public String fileName{get;set;}
	}
	
	global class ExistingAttachmentsResponse{
		public ExistingAttachmentsResponse(){
			errorMessage = '';
			status = '';
		}
		public String status {get;set;}
		public String errorMessage {get;set;}
	}	
	
	@RemoteAction
	global static String DocSignStatus(String strDocType){
		system.debug('In DocSignStatus :: '+ strDocType);
		Map<String, Document_Classification__c> mapDocDetails = EDPDocumentSettings.getDocumentSettingsInformation();
		system.debug('In DocSignStatus 1:: '+ mapDocDetails);
		if(strDocType == null || strDocType == '')
			return 'Document Type is not selected.';
		
		Document_Classification__c documentClassificationObj = mapDocDetails.get(strDocType);
		system.debug('In DocSignStatus 2:: '+ documentClassificationObj);
		if(documentClassificationObj != null){
			List<Partner_Document_Relationship__c> partnerDocumentRelationships =  documentClassificationObj.Partner_Document_Relationships__r;		
			if(partnerDocumentRelationships != null && partnerDocumentRelationships.size() > 0){
				Partner_Document_Relationship__c ptrRelationshipObj = partnerDocumentRelationships[0];
				if(ptrRelationshipObj.Customer_signature_required__c || 
					ptrRelationshipObj.Partner_signature_required__c || 
					ptrRelationshipObj.SR_Ops_signature_required__c){
					if(documentClassificationObj.Source_System__c == EDPUtil.PROPOSAL_TOOL_SOURCE){
		       			return EDPUtil.SIGNED;
					}else{
						return EDPUtil.SIGNED + ',' + EDPUtil.UNSIGNED;
					}
				}else{
					return EDPUtil.NA;
				}				
			}		
		}
		return EDPUtil.NA;

	}

	//static String awsFolderName =  'incompleteSignedDoc';
	//static String SunRunProxyAccessKey = 'AKIAI6QXLSPZQUZUDNOQ';
	//static String SunRunProxySecretAccessKey = 'DealDocManager-secretAccessKey-client';	 
	
	//@RemoteAction
	//global static Map<String, String> getSunRunProxyDetails(String objectName, String mimeType){
	//	Map<String, String> resultMap = new Map<String, String>(); 
		/*
		String fileName = objectName ;
		DateTime d = System.now();
		String timeFormat = d.formatGmt('EEE, dd MMM yyyy HH:mm:ss') + ' GMT';
		resultMap.put('Timestamp', timeFormat);

		System.debug('timeFormat: ' + timeFormat);
		string serviceEndPoint = 'http://ec2-54-235-57-215.compute-1.amazonaws.com:8080/' + awsFolderName + '/' + fileName;
		resultMap.put('Endpoint', serviceEndPoint);
		String encodedPath = 'sparrowproxytest-dest-sunrun/' + awsFolderName + '/'+ fileName ;

		String buf = 'PUT' + '\n\n' + 'application/pdf' + '\n' + timeFormat + '\n' + '/' + encodedPath;
		System.debug('buf : ' + buf);
		string signature  = S3GateKeeper.make_sig2(buf);		
		resultMap.put('Authorization', signature);
		*/
				
	//	return resultMap;
	//}
}