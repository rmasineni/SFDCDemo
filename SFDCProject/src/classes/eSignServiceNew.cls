/****************************************************************************
Author  : ZCloudInc.net
Date    : March 2013
Description: This class contains all the methods to interact with DocuSign.
*****************************************************************************/
public class eSignServiceNew {
	public static boolean isApexTesting = false;
	public static Set<String> processedEnvelopIds = new Set<String>();
    public static EnvResponse EnvRes {get;set;}
     public static contact primarycon {get;set;}
     public static contact secondarycon {get;set;}
     public static contact  partnercon {get;set;}
	private static String geteSignAccountId(){ return eSign_Settings__c.getValues('accountId').value__c; }
	//Get Authenticaion Header, Used for all request
	public static String authHeader(){
	    //Get Paramter from Custom Setting (sfdc cache) and construct auth header
	    return '<DocuSignCredentials>'+
	                '<Username>'+eSign_Settings__c.getValues('Username').value__c+'</Username>'+
	                '<Password>'+eSign_Settings__c.getValues('Password').value__c+'</Password>'+
	                '<IntegratorKey>'+eSign_Settings__c.getValues('IntegratorKey').value__c+'</IntegratorKey>'+
	            '</DocuSignCredentials>';
	}

	//Create And Send Envelope 
	//Get the documents from S3
	//Create Recipient, Tabs and Sends for singature in one step
	public static EnvResponse getEmbeddedSigningURL(String envelopId, Integer recipientId, String envelopString){
		EnvResponse envstat;
		String requestBody = '';
		String requestStr = '';
		String responseStr = '';
		String responseBody = ''; 
		if(envelopString == null || envelopString == ''){
			envelopString = DocuSignUtil.createEmbeddedSigningJSONEnvelopString(envelopId, recipientId);
		}

		String accKey = eSign_Settings__c.getValues('accountId').value__c;
		String result = '';
		String passString = authHeader();  
		Http httpProtocol = new Http();
		HttpRequest request = new HttpRequest();
		String endpoint = Label.eSignEndPointURL + accKey +'/envelopes/'+  envelopId + '/views/recipient';
		System.debug('endpoint: ' + endpoint);
		request.setEndPoint(endpoint);
		request.setMethod('POST');

		request.setHeader('Accept', 'application/json');
		request.setHeader('X-DocuSign-Authentication', passString);
		request.setHeader('content-Type', 'application/json'); 
		request.setBody(envelopString);
		requestStr = '' + request;
		
		System.debug('Request String: ' + request.toString());
		System.debug('Request Endpoint: ' + request.getEndpoint());
		System.debug('Request Method: ' + request.getMethod());
		System.debug('Accept: ' + request.getHeader('Accept'));
		System.debug('X-DocuSign-Authentication: ' + request.getHeader('X-DocuSign-Authentication'));
		System.debug('Content-Type: ' + request.getHeader('content-Type'));
		System.debug('Request Body1: ' + request.getBody());

		requestBody = request.getBody();
		Http DataHttp = new Http();
		HttpResponse response;
		if(!Test.isRunningTest()){
			response = DataHttp.send(Request);
		}else{
			response = new HttpResponse();
			response.setStatus('OK');
			response.setStatusCode(200);
			String testBody = '{\"url\": \"https://demo.docusign.net/Member/StartInSession.aspx?t=91724afd-0f98-4dd0-8d15-659637ef8336\"}';
			response.setBody(testBody);
		}

		System.debug('Response1: ' + response);
        System.debug('Response body1: ' + response.getBody());
		responseStr = '' + response;
		responseBody = response.getBody();

        JSONParser parse = JSON.createParser(response.getBody());
        envstat = (EnvResponse)parse.readValueAs(EnvResponse.class);
        System.debug('De-Serialized class is envstats => '+envstat);
		return envstat;
    }
  
    public static EnvResponse sendDocumentsToDocusign(String proposalId, String documentType, 
                        String eSigningType, String hostName,string hostEmail, Contact primaryContact,
                         Contact secondaryContact, Contact partnerContact, String sunrunRecipientName, String sunrunRecipientEmail){
                         EnvResponse envstat;
              			envstat = sendDocumentsToDocusigns(proposalId,documentType,
                        eSigningType,hostName,hostEmail, primaryContact,
                        secondaryContact,partnerContact,sunrunRecipientName,sunrunRecipientEmail);
             system.debug('envstatenvstatenvstatenvstat>' + envstat);
               return envstat;
      }                                                                                                                                                                                                                                                                 

   
	public static EnvResponse sendDocumentsToDocusigns(String proposalId, String documentType, String eSigningType, String hostName, string hostEmail, 
													Contact primaryContact, Contact secondaryContact,Contact partnerContact, String sunrunRecipientName, 
													String sunrunRecipientEmail){
		List<In_Person_Recipient__c> inpersonRecipientList = new List<In_Person_Recipient__c>();
		EnvResponse envstat;
		String accountId = geteSignAccountId();
		//Integer documentId = Integer.valueOf(String.valueOf(Math.abs(Crypto.getRandomInteger())));
		//Integer documentId = 100; //This code is commented due to a bug in the DocuSign REST API.
		Integer documentId = 1;
		SR_Attachment__c srAttachment = DocuSignUtil.getSRAttachmentsForESignature(proposalId, documentType);
                                                       
		SR_Attachment__c modifiedSRAttachment = null;
		if(srAttachment.Document_Source__c == EDPUtil.PROPOSAL_TOOL_SOURCE){
			modifiedSRAttachment = EDPUtil.cloneSRAttachmentOnSFDC(srAttachment, null);
		}else{
			modifiedSRAttachment = srAttachment;
		}

    	system.debug('srAttachmentsrAttachment>' +  srAttachment);                                                    
                                                        
		Boolean includeTabs = true;
		String requestBody = '';
		String requestStr = '';
		String responseStr = '';
		String responseBody = ''; 
		envstat = new EnvResponse();
      	if(srAttachment.Wet_Sign_Status__c != null && srAttachment.Wet_Sign_Status__c != ''){
			includeTabs = false;
		}

		//Get the document from S3
		SunRunS3RestConnection connectionObj;
	      
		try{
		    connectionObj = SRAttachmentManager.getDocumentFromS3(srAttachment, true);
            system.debug('connectionObjconnectionObj>>'+connectionObj);
		    if(connectionObj.getResponse() == null){
				envstat.errorCode = '400';
				envstat.message = connectionObj.errorMessage;
				return envstat;          	
		    }
		    if(connectionObj.getResponse().getStatusCode() != 200){
				envstat.errorCode = String.valueOf(connectionObj.getResponse().getStatusCode());
				envstat.message = connectionObj.getResponse().getStatus() + ' -- Unable to download the file from server';
				return envstat;        	
		    }
			
		}catch(Exception expObj){
			processException(expObj);
			throw expObj;
		}
                                                        
                   
		Blob responseBlob = connectionObj.documentBlob;
		system.debug('responseBlob>>>' +  responseBlob);
		//Copy the document to /incompleteSignedDoc folder
		if(responseBlob != null){
			HTTPResponse response;
			UploadResponse responseObj = uploadDocumentsToS3(responseBlob, SunRunS3RestConnection.INCOMPLETE_DOCS_SETTINGS_NAME, 
												srAttachment.Parent_Proposal_Name__c, modifiedSRAttachment.Document_Name_On_File_Server__c);
           response = responseObj.response;
          if(response == null || response.getStatusCode() != 200){
				envstat.errorCode = String.valueOf(response.getStatusCode());
				envstat.message = response.getStatus() + ' -- Unable to upload the file to server';
				return envstat;
			}
		}
	
		//Send the document to DocuSign
		String passString = authHeader();                   
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = Label.eSignEndPointURL + accountId + '/envelopes';
        request.setEndPoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Accept', 'application/json');
        request.setHeader('X-DocuSign-Authentication', passString);
        request.setHeader('content-type', 'multipart/form-data;boundary=sunrunBoundary'); 
	
		//sunrunBoundary - used to indicate benging/end of document in multi-part request
		String contentType = '\r\n--sunrunBoundary'+'\r\n'+'Content-Type:application/octet-stream'+ '\r\n'+
	                                'Content-Transfer-Encoding: base64'+'\r\n'+'Content-Disposition:attachment; '+'filename=\"'+srAttachment.Document_Name__c +'\";'+
	                                'documentid=' + String.valueof(documentId) +' \r\n\r\n\r\n';
		String cheader = '\r\n--sunrunBoundary'+'\r\n'+' Content-Type: application/json'+ '\r\n'+' Content-Disposition: form-data'+ '\r\n'+'\r\n';

		String envelop = DocuSignUtil.createJSONEnvelopString(includeTabs, documentId, eSigningType, hostName, hostEmail, srAttachment,
																primaryContact, secondaryContact,partnerContact, sunrunRecipientName, 
																sunrunRecipientEmail, inpersonRecipientList);
                                                        
                                                        
                                                        system.debug('envelopenvelop>>' +  envelop);
                                                        system.debug('primaryContact>>' +  primaryContact);
                                                         system.debug('secondaryContact>>' +  secondaryContact);
                                                         system.debug('partnerContact>>' +  partnerContact);
                                                          system.debug('sunrunRecipientName>>' +  sunrunRecipientName);
                                                         system.debug('inpersonRecipientList>>' +  inpersonRecipientList);
                                                         system.debug('sunrunRecipientEmail>>' +  sunrunRecipientEmail);
		String envEOF = '\r\n'+'--sunrunBoundary--';                    
        String bcontent = EncodingUtil.base64Encode(responseBlob);
        request.setHeader('content-length', String.valueOf(bcontent.length()));
		requestBody = cheader+''+envelop+'\r\n'+contentType+'\r\n'+ '....... '+'\r\n'+envEOF;
	        
		//Body
        request.setBody(cheader+''+envelop+'\r\n'+contentType+'\r\n'+bcontent+'\r\n'+envEOF);
		System.debug('Request String: ' + request.toString());
		System.debug('Request Endpoint: ' + request.getEndpoint());
		System.debug('Request Method: ' + request.getMethod());
		System.debug('Accept: ' + request.getHeader('Accept'));
		System.debug('X-DocuSign-Authentication: ' + request.getHeader('X-DocuSign-Authentication'));
		System.debug('content-type: ' + request.getHeader('content-type'));
		System.debug('Request Body: ' + request.getBody());

		requestStr = '' + + request;
		
		if(request.getBody().length() > 3000000){
			Exception expObj = new SRAttachmentESignController.BaseException();
			expObj.setMessage(CustomErrorMessages.MAXIMUM_REQUEST_SIZE);
			throw expObj;
		}

        HttpResponse response;
        if(!Test.isRunningTest()){
			response = httpProtocol.send(request);
        }else{
        	response = new HttpResponse();
        	String testResponse = '{\"envelopeId\": \"dbb543e0-9793-4b2c-8eb0-80e0aded24ba\", \"uri\": \"/envelopes/dbb543e0-9793-4b2c-8eb0-80e0aded24ba\", \"statusDateTime\": \"2013-07-29T18:11:53.1138580Z\", \"status\": \"sent\"}';
        	response.setBody(testResponse);
        }
		responseStr = '' + response;
		responseBody = '' + response.getBody();
		System.debug('Response: ' + response);
        System.debug('Response body: ' + response.getBody());

        JSONParser parse = JSON.createParser(response.getBody());
        envstat = (EnvResponse)parse.readValueAs(EnvResponse.class);
        System.debug('De-Serialized class is envstats => '+envstat);
        
        if(Test.isRunningTest()){
        	envstat = new EnvResponse();
        	modifiedSRAttachment.Wet_Sign_Status__c = '';
        	envstat.envelopeId = '12421421-ASFRRWQ2421';
        }

        if(modifiedSRAttachment.Wet_Sign_Status__c != EDPUtil.SIGNED){
			modifiedSRAttachment.Customer_Signed__c = (modifiedSRAttachment.Customer_Signed__c != 'N/A') ? 'No' : modifiedSRAttachment.Customer_Signed__c;
			modifiedSRAttachment.Partner_Signed__c = (modifiedSRAttachment.Partner_Signed__c != 'N/A') ? 'No' : modifiedSRAttachment.Partner_Signed__c;
			modifiedSRAttachment.SunRun_Signed__c = (modifiedSRAttachment.SunRun_Signed__c != 'N/A') ? 'No' : modifiedSRAttachment.SunRun_Signed__c;
        }
	     
        if(envstat.envelopeId != null && envstat.envelopeId != ''){
        	modifiedSRAttachment.Envelop_Id__c = envstat.envelopeId.toUpperCase();
			modifiedSRAttachment.Document_Id__c = documentId;
			modifiedSRAttachment.DocuSign_Status__c = EDPUtil.SENT;
			modifiedSRAttachment.DocuSign_Error_Code__c  = '';
			modifiedSRAttachment.DocuSign_Error_Message__c = '';
			envstat.url = '';
			String baseURL = EDPUtil.getBaseURL();
			if(eSigningType != null && eSigningType == DocuSignUtil.ESIGN_IN_PERSON && inpersonRecipientList.size() > 0 ){
				envstat.url = Label.PartnerPortalSiteUrl + '/apex/InPersonSigningRedirect?event=' + DocuSignUtil.ESIGN_INITIATE + '&envelopId=' + envstat.envelopeId + '&recipientId=1' + '&baseUrl=' + baseURL;
			}

			//if(eSigningType != null && eSigningType == DocuSignUtil.ESIGN_IN_PERSON && inpersonRecipientList.size() > 0 ){
			//	String envelopString = DocuSignUtil.createEmbeddedSigningJSONEnvelopString(inpersonRecipientList[0], envstat.envelopeId, 1);
			//	EnvResponse inpersonResponse = getEmbeddedSigningURL(envstat.envelopeId, 1, envelopString);		
			//	if(inpersonResponse.errorCode != null && inpersonResponse.errorCode != ''){
		    //     	modifiedSRAttachment.DocuSign_Error_Code__c = envstat.errorCode;
		    //		modifiedSRAttachment.DocuSign_Error_Message__c = envstat.message;
		    //		modifiedSRAttachment.DocuSign_Status__c = EDPUtil.NOT_SENT;
		    //     }
		    //   if(inpersonResponse.url != null && inpersonResponse.url != ''){
		    //  	envstat.url = inpersonResponse.url;
		    //	}
			//}
			
            system.debug('envstatenvstatenvstat>>' +  envstat);
        }
        
		if(envstat.errorCode != null && envstat.errorCode != ''){
        	modifiedSRAttachment.DocuSign_Error_Code__c = envstat.errorCode;
			modifiedSRAttachment.DocuSign_Error_Message__c = envstat.message;
			modifiedSRAttachment.DocuSign_Status__c = EDPUtil.NOT_SENT;
			envstat.url = '';
        }
                                                     
        modifiedSRAttachment.Document_Source__c = EDPUtil.E_SIGN;
        System.debug('modifiedSRAttachment Active1 : ' + modifiedSRAttachment.Active__c);
		if(srAttachment.Document_Source__c == EDPUtil.PROPOSAL_TOOL_SOURCE){
			insert modifiedSRAttachment;
			System.debug('modifiedSRAttachment 1 : ' + modifiedSRAttachment.Id);
		}else{
			update modifiedSRAttachment;
			System.debug('modifiedSRAttachment 2 : ' + modifiedSRAttachment.Id);
		}
		System.debug('modifiedSRAttachment Active2 : ' + modifiedSRAttachment.Active__c);
		
		String tempEnvelopId = (envstat != null) ? envstat.envelopeId : '';
		DocuSign_Log__c docuSignLogObj = insertDocuSignRequestResponse(tempEnvelopId, requestStr, requestBody, responseStr, responseBody);
		insert docuSignLogObj;
		if(inpersonRecipientList.size() > 0 && envstat.envelopeId != null && envstat.envelopeId != ''){
			for(In_Person_Recipient__c inpersonRecipientObj : inpersonRecipientList){
				inpersonRecipientObj.SR_Attachment__c = modifiedSRAttachment.Id;
			}
			insert inpersonRecipientList;
		}
                                                        
                                                            
		//getEmbeddedSigningURL(envstat.envelopeId, 1);
		return envstat;
	}	

	public static void processException(Exception expObj){
		String maximSizeError = CustomErrorMessages.S3_MaximumSizeError;
		if(expObj != null){
			String errorMessage = expObj.getMessage();
			if(errorMessage != null && (errorMessage.contains(CustomErrorMessages.MAXIMUM_REQUEST_SIZE) || errorMessage.contains(maximSizeError))){
				expObj.setMessage(CustomErrorMessages.MAXIMUM_REQUEST_SIZE);
			}else{
				System.debug('Null error message');
				expObj.setMessage(CustomErrorMessages.UNABLE_TO_PROCESS_E_SIGN_REQUEST);
			}
		}
	}   

	public static String resendDocumentsToDocusign(SR_Attachment__c srAttachment){

		String requestBody = '';
		String requestStr = '';
		String responseStr = '';
		String responseBody = ''; 

		String accKey = eSign_Settings__c.getValues('accountId').value__c;
		String result = '';
		String passString = authHeader();  
		Http httpProtocol = new Http();
		HttpRequest request = new HttpRequest();
		String endpoint = Label.eSignEndPointURL + accKey +'/envelopes/'+  srAttachment.Envelop_Id__c + '/recipients?resend_envelope=true';
		request.setEndPoint(endpoint);
		request.setMethod('PUT');
		request.setHeader('Accept', 'application/json');
		request.setHeader('X-DocuSign-Authentication', passString);			
		String  envelop = DocuSignUtil.createResendJSONEnvelopString(srAttachment.Envelop_Id__c);
		request.setBody(envelop);
		requestStr = '' + request;

		System.debug('Request String: ' + request.toString());
		System.debug('Request Endpoint: ' + request.getEndpoint());
		System.debug('Request Method: ' + request.getMethod());
		System.debug('Accept: ' + request.getHeader('Accept'));
		System.debug('X-DocuSign-Authentication: ' + request.getHeader('X-DocuSign-Authentication'));
		System.debug('Request Body: ' + request.getBody());

		requestBody = request.getBody();
		Http DataHttp = new Http();
		HttpResponse DataResponse;
		if(!Test.isRunningTest()){
			DataResponse = DataHttp.send(Request);
		}else{
			DataResponse = new HttpResponse();
			DataResponse.setStatus('OK');
			DataResponse.setStatusCode(200);
			DataResponse.setBody('Test Body');
		}

		System.debug('Response: ' + DataResponse);
        System.debug('Response body: ' + DataResponse.getBody());
	        
		System.debug('Response: ' + DataResponse);
		responseStr = '' + DataResponse;
		responseBody = DataResponse.getBody();
		
		if(DataResponse != null && DataResponse.getStatus() == 'OK' && DataResponse.getStatusCode() == 200 ){
			result = EDPUtil.SUCCESS;
		}else{
			result = CustomErrorMessages.UNABLE_TO_RESEND_ENVELOP;
		}
		DocuSign_Log__c docuSignLogObj = insertDocuSignRequestResponse(srAttachment.Envelop_Id__c, requestStr, requestBody, responseStr, responseBody);
		insert docuSignLogObj;
		return result;
	}

	@Future(callout=true)
    public static void updateESignDocuments(Set<String> envelopIds){
    	if(isApexTesting == false){
			Map<Id, SR_Attachment__c> srAttachmentMap = SRAttachmentManager.getSRAttachments(envelopIds);
			Map<Id, dsfs__DocuSign_Recipient_Status__c> recipientStatusMap = DocuSignUtil.getDocuSignRecipients(envelopIds, true);
			Set<String> procesedEnvelopIds = new Set<String>();
			String result = uploadDocumentsFromDocuSignToS3(srAttachmentMap, procesedEnvelopIds);
			List<dsfs__DocuSign_Recipient_Status__c> modifiedRecipientObjects = new List<dsfs__DocuSign_Recipient_Status__c>();
			for(dsfs__DocuSign_Recipient_Status__c recipientStatusObj : recipientStatusMap.values()){
				if(procesedEnvelopIds.contains(recipientStatusObj.dsfs__Envelope_Id__c)){
					recipientStatusObj.Update_Document__c = false;
					modifiedRecipientObjects.add(recipientStatusObj);
				}
			}
			System.debug('result: ' + result);  
			System.debug('modifiedRecipientObjects: ' + modifiedRecipientObjects);  
			if(modifiedRecipientObjects.size() > 0){
				update modifiedRecipientObjects;
			}  		
    	}
    }

	public static RecipientResponse getDocuSignRecipient(String emailId){ 
		String errorMessage = '';
		String accKey = eSign_Settings__c.getValues('accountId').value__c;
		String envelopId = '';
		String fileName = '';	

		Boolean status = false;
		String statusCode = '';
		RecipientResponse recipientResponseObj = new RecipientResponse();
		try{
			String passString = authHeader();  
			Http httpProtocol = new Http();
			HttpRequest request = new HttpRequest();
			String endpoint = Label.eSignEndPointURL +accKey + '/recipient_names?email=' + emailId;
			request.setEndPoint(endpoint);
			request.setMethod('GET');
			request.setHeader('X-DocuSign-Authentication', passString);

			Http DataHttp = new Http();
			HttpResponse DataResponse;
			if(!Test.isRunningTest()){
				DataResponse = DataHttp.send(Request);
			}else{
				DataResponse = new HttpResponse();
				String myString = 'StringToBlob';
				DataResponse.setBody(myString); 			
				DataResponse.setStatusCode(200);
			}
			System.debug('Body: ' + DataResponse.getBody());
			JSONParser parser = JSON.createParser(DataResponse.getBody());
			System.debug('parser: ' + parser);
			recipientResponseObj = (RecipientResponse)parser.readValueAs(RecipientResponse.class);

		}catch(Exception expObj){
			errormessage = 'Unable to get recipient details';
			recipientResponseObj.errorCode = '0000';
			recipientResponseObj.message = errormessage;
			if(expObj != null){
				recipientResponseObj.errorCode = '0000';
				recipientResponseObj.message = expObj.getMessage();
				System.debug('Error: ' + errormessage);
			}
		}		
		return recipientResponseObj;
	}

	private static String uploadDocumentsFromDocuSignToS3(Map<Id, SR_Attachment__c> srAttachmentMap, Set<String> procesedEnvelopIds){ 
		String uploadObjectErrorMsg = 'Found no documents for update';
		String accKey = eSign_Settings__c.getValues('accountId').value__c;
		String envelopId = '';
		String fileName = '';	

		List<SR_Attachment__c>	modifiedSRAttachments = new List<SR_Attachment__c>();	
		for(SR_Attachment__c srAttachment: srAttachmentMap.values()){
			
			Integer counter = 0;
			Boolean status = false;
			String errormessage = '';
			String statusCode = '';
			do{
				counter += 1;
				status = false;
				
				try{
					fileName = srAttachment.Document_Name_On_File_Server__c;
					envelopId = srAttachment.Envelop_Id__c;
					String sunrunS3ProxySettingName = SunRunS3RestConnection.INCOMPLETE_DOCS_SETTINGS_NAME; 
					if(srAttachment.DocuSign_Status__c == EDPUtil.COMPLETED){
						sunrunS3ProxySettingName = SunRunS3RestConnection.COMPLETED_SIGNED_DOCS_SETTINGS_NAME; 
					}
					String proposalName = srAttachment.Parent_Proposal_Name__c;
					
					Integer documentId = Integer.valueOf(srAttachment.Document_Id__c);
					String passString = authHeader();  
					
					Http httpProtocol = new Http();
					HttpRequest request = new HttpRequest();
					String endpoint = Label.eSignEndPointURL +accKey+'/envelopes/' + envelopId + '/documents/' + documentId;
					request.setEndPoint(endpoint);
					request.setMethod('GET');
					request.setHeader('X-DocuSign-Authentication', passString);
					
					Http DataHttp = new Http();
					HttpResponse DataResponse;
					if(!Test.isRunningTest()){
						DataResponse = DataHttp.send(Request);
					}else{
						DataResponse = new HttpResponse();
						String myString = 'StringToBlob';
						Blob tempDocumentBlob = Blob.valueof(myString);
						DataResponse.setBodyAsBlob(tempDocumentBlob); 			
						DataResponse.setStatusCode(200);
					}
					System.debug('DocuSign Stauts: ' + DataResponse.getStatusCode() );
					statusCode = '' + DataResponse.getStatusCode();
					errormessage = DataResponse.getBody();
					if(DataResponse.getStatusCode() == 200){
						Blob responseBlob = DataResponse.getBodyAsBlob();
						if(responseBlob != null){
							HTTPResponse response;
							UploadResponse responseObj = uploadDocumentsToS3(responseBlob, sunrunS3ProxySettingName,proposalName, fileName);
							response = responseObj.response;
							errormessage = responseObj.errormessage;
							if(response != null){
								System.debug('S3 Stauts: ' + response.getStatusCode() );
								statusCode = '' +  response.getStatusCode();
								errormessage = response.getBody();							
								if(response.getStatusCode() == 200){
									procesedEnvelopIds.add(envelopId);
									status = true;										
								}
							}
						}			
					}
				}catch(Exception expObj){
					errormessage = 'Unable to update eSignedDocument';
					if(expObj != null){
						statusCode = '';
						errormessage = '' + expObj.getMessage() + ' Line Number:: ' + expObj.getLineNumber() + ' Stack: ' + expObj.getStackTraceString() ;
						System.debug('Error: ' + errormessage);
					}
				}
			}while(counter < 3 && status == false);
			
			if(status == false){
				System.debug('Email the error message.');
				notifyDocumentRefreshError(srAttachment, statusCode, errormessage);
			}			
		}
		return uploadObjectErrorMsg;
	}

	public static void notifyDocumentRefreshError(SR_Attachment__c srAttachment, String statusCode, String errorDescription){
		
		if(errorDescription == null || (errorDescription != null && errorDescription.contains('Object already exists')))
			return;
		
		List<String> toAddresses = new List<String>();
		toAddresses.add(Label.Sunrun_SFDC_Admin);
				
		String subject = 'Unable to update ';
		String emailBody = '';		
		
		subject += srAttachment.Id + ' : ' + srAttachment.Document_Name__c ;

		String htmlBody = '<html>';
		htmlBody += EmailService.getHTMLHeader();
		htmlBody += '<p></p>';
		htmlBody += 'Salesforce is unable to update the following SR attachment. Please refresh this document manually. <br/>';
		htmlBody += '<p></p>';
		emailBody += 'SR Attachment Id: ' + srAttachment.Id + '<br/>';
		emailBody += 'Proposal Id: ' + srAttachment.Proposal__c + '<br/>';
		htmlBody += emailBody;		
		
		htmlBody += '<p/>';
		htmlBody += 'Error: <br/> ';
		htmlBody += 'Status Code: ' + statusCode + '<br/>';
		htmlBody += 'Description: ' + errorDescription + '<br/>';
		htmlBody += EmailService.getHTMLFooter();
		htmlBody += '</html>';
		PRMEmailManager.sendEmail(toAddresses, subject, htmlBody);
	}

	class UploadResponse{
		public HTTPResponse response{get;set;}
		public String errorMessage{get;set;}
	}

	private static UploadResponse uploadDocumentsToS3(Blob responseBlob, String sunrunS3ProxySettingName, 
											String proposalName, String fileName){
		UploadResponse responseObj = new UploadResponse();
		System.debug('/ ' + proposalName);
		HTTPResponse response;
		responseObj.response = response;
		if(responseBlob != null){
			SunRunS3RestConnection conn = new SunRunS3RestConnection(sunrunS3ProxySettingName);
			conn.makeRequest('PUT', proposalName, fileName, responseBlob, 
							new Map<String, String>{'content-type'=>'application/pdf'});
			response = conn.getResponse();
			responseObj.response = conn.getResponse();
			responseObj.errorMessage = conn.errorMessage;
			System.debug('response: ' + response);
		}	
		return responseObj;	
	}
	
	public class VoidResponseWithDocuSignLog{
		public DocuSign_Log__c docuSignLogObj;
		public String response;					
	}
	
	public static VoidResponseWithDocuSignLog voidDocuSignEnvelopId(SR_Attachment__c srAttachment){
		VoidResponseWithDocuSignLog voidResponseObj = new VoidResponseWithDocuSignLog();
		String requestBody = '';
		String requestStr = '';
		String responseStr = '';
		String responseBody = '';

		String accKey = eSign_Settings__c.getValues('accountId').value__c;
		if(srAttachment != null && srAttachment.Envelop_Id__c != null && srAttachment.Envelop_Id__c != ''){
			String envelopId = srAttachment.Envelop_Id__c;
			dsfs__DocuSign_Status__c statusObj = DocuSignUtil.getDocuSignStatus(envelopId);
			if(statusObj == null){
				voidResponseObj.response = 'No eSign requests are in pending for this record';
				return voidResponseObj;
			}else if(statusObj != null && statusObj.dsfs__Envelope_Status__c == 'Voided'){
				voidResponseObj.response = 'Selected document is not associated with active eSignature';
				return voidResponseObj;
			}else{
				String passString = authHeader();  
				Http httpProtocol = new Http();
				HttpRequest request = new HttpRequest();
				String endpoint = Label.eSignEndPointURL + accKey +'/envelopes/'+  envelopId;
				request.setEndPoint(endpoint);
				request.setMethod('PUT');
				request.setHeader('Accept', 'application/json');
				request.setHeader('X-DocuSign-Authentication', passString);			
				
				String  envelop = DocuSignUtil.createVoidJSONEnvelopString();
				request.setBody(envelop);
				
				requestBody = '' + request.getBody();
				requestStr = '' + request;

				System.debug('Request String: ' + request.toString());
				System.debug('Request Endpoint: ' + request.getEndpoint());
				System.debug('Request Method: ' + request.getMethod());
				System.debug('Accept: ' + request.getHeader('Accept'));
				System.debug('X-DocuSign-Authentication: ' + request.getHeader('X-DocuSign-Authentication'));
				System.debug('Request Body: ' + request.getBody());
		
				Http DataHttp = new Http();
				HttpResponse DataResponse;
				if(!Test.isRunningTest()){
					DataResponse = DataHttp.send(Request);
				}else{
					DataResponse = new HttpResponse();
					DataResponse.setStatus('OK');
					DataResponse.setStatusCode(200);
					DataResponse.setBody('Test Body');
				}

				responseStr = '' + DataResponse;
				responseBody = '' + DataResponse.getBody();

				System.debug('Response: ' + DataResponse);
		        System.debug('Response body: ' + DataResponse.getBody());

				DocuSign_Log__c docuSignLogObj =  insertDocuSignRequestResponse(envelopId, requestStr, requestBody, responseStr, responseBody);
				voidResponseObj.docuSignLogObj = docuSignLogObj;
				if(DataResponse != null && DataResponse.getStatus() == 'OK' && DataResponse.getStatusCode() == 200 ){
					System.debug('DocuSign Response: ' + DataResponse.getStatus());		
				}else{
					JSONParser parser = JSON.createParser(DataResponse.getBody());
					System.debug('parser: ' + parser);
			        VoidResponse envstat = (VoidResponse)parser.readValueAs(VoidResponse.class);
			        System.debug('envstat: ' + envstat);
					if(envstat.errorCode != null && envstat.errorCode != ''){
			        	System.debug(envstat.message);
			        	voidResponseObj.response = CustomErrorMessages.UNABLE_TO_PROCESS_E_SIGN_REQUEST;
			        	return voidResponseObj;
			        }				
				}
			}
		}
		voidResponseObj.response =  'SUCCESS';
		return voidResponseObj;		
	}	

	public static String voidEnvelopId(SR_Attachment__c srAttachment){
		VoidResponseWithDocuSignLog VoidResponseWithDocuSignLogObj = voidDocuSignEnvelopId(srAttachment);
		if(VoidResponseWithDocuSignLogObj.docuSignLogObj != null){
			insert VoidResponseWithDocuSignLogObj.docuSignLogObj;
		}
		return VoidResponseWithDocuSignLogObj.response;
	}

	//Envelope Data Class
	public class VoidResponse{
		public String Status;
		public String StatusCode;
		public String errorCode;
		public String message;
	}	
	
	public class RecipientResponse{
		public List<String> recipientNames;
		public string reservedRecipientEmail;
		public string multipleUsers;
		public String errorCode;
		public String message;
		public RecipientResponse(){
			recipientNames = new List<String>();
		}
	}

     public class DocumentTypeToProcess {
        public string documentName;
        public Id primaryContact;
        public Id secondaryContact;
        public string hostName;
        public string hostEmail;
        public string esignOption;
        public string proposalId;
         public boolean utilityAgreement;
    }
    
    
    
    
	//Envelope Data Class
	public class EnvResponse{
	    public String envelopeId;
	    public String status;
	    public String StatusCode;
	    public String statusDateTime;
	    public String uri;
	    public String url;
	    
	    public String errorCode;
	    public String message;
	}
	
	public static DocuSign_Log__c insertDocuSignRequestResponse(String envelopId, String request, 
													String requestBody, String response, String responsebody){
		DocuSign_Log__c docuSignLogObj = new DocuSign_Log__c();
		docuSignLogObj.Envelop_Id__c = envelopId;
		docuSignLogObj.Request__c = request;
		docuSignLogObj.Response__c = response;
		docuSignLogObj.Request_Body__c = requestBody;
		docuSignLogObj.Response_Body__c = responsebody;	
		
		return 	docuSignLogObj;
		//upsert docuSignLogObj;
	}

}