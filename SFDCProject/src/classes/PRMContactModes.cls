/**
**
**
**
*/

public class PRMContactModes {
	String errorMessage = '';
	public List<Contact_Mode_Rel__c> contactModeList{get;set;}
	public Contact contactObj{get;set;}
	public PRMContactModes(){
		contactModeList = new List<Contact_Mode_Rel__c>();
		contactObj = new Contact();
	}
	
	public void sendContactModesToProposalTool(Id contactId, boolean resubmitRequest){
		contactModeList = new List<Contact_Mode_Rel__c>();
	    /*
	    if(resubmitRequest == true){
	    	//This will be invoked from PRMContactViewController
			contactModeList = [Select Id, Mode_Id__c, Mode_Name__c, status_message__C,
								Ultimate_Parent_Account__c,
								Contact__c, Contact_Number__c,Isactive__c from Contact_Mode_Rel__c 
								where Contact__c =:contactId and Status_Code__c != 'SUCCESS'];					
	    }
	    */
	    //If there are any unprocessed Contact Modes, then invoke the SOAP 
	    //call while displaying the Partner Contact Page.
	    //if(resubmitRequest == false 
	   // 	|| (contactModeList != null && contactModeList.size() > 0))
	   // {
			
			contactObj = [Select Id, firstname, lastname, accountId, email,
									Ultimate_Parent_Account__c,
									title from Contact where Id =:contactId];


			contactModeList = [Select Id, Mode_Id__c, Mode_Name__c, Contact__c, Contact_Number__c,
									Ultimate_Parent_Account__c, Isactive__c,
									status_message__C
									from Contact_Mode_Rel__c 
									where Contact__c =:contactId];
			processContactModes();
		//}
		
	}


	//Send the SOAP request to the Proposal tool, process the SOAP response and update
	//Contact Mode Relationship records.
	public void processContactModes(){
      	String strAction = 'updateContactModesFromSalesforce';
		String strRequest = '';
		strRequest += '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:prot="http://protocol010000.contract.sunrungeneration.com" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">';
		strRequest += '<soapenv:Header/>';
		strRequest += '<soapenv:Body>';
      	strRequest += '<prot:updateContactModesFromSalesforce soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">';
        strRequest += '<requests xsi:type="con:ArrayOf_tns1_contactModeRelationshipRequest010000" soapenc:arrayType="srg:contactModeRelationshipRequest010000[]" xmlns:con="http://api:8080/contract/services/Contract010000" xmlns:srg="srg">'; 
		
		//Serialize Contact Mode Relationship objects into XMl
		String requestObjectsXML = getContactModesSOAPBody();
		strRequest += ' ' + requestObjectsXML;		
		strRequest += '</requests>';
		strRequest += '</prot:updateContactModesFromSalesforce>';
		strRequest += '</soapenv:Body>'; 
		strRequest += '</soapenv:Envelope>';
 		System.debug('strRequest: ' + strRequest);
     	
		PRMContactModes contactModes = new PRMContactModes();
     	Httpresponse response = contactModes.SendSOAPRequest(Label.ProposalToolEndpoint, strAction, strRequest);
		System.debug('HTTP Response:' + response);
		processHTTPResponse(response);
	}

	public void processHTTPResponse(Httpresponse response){
		
		if(response != null){
			System.debug('response.getStatus():' + response.getStatus());
			System.debug('response.getBody():' + response.getBody());
		}else{
			System.debug('Null Response');
		}
      	if(response != null && response.getStatus() == 'OK'){
	     	Map<String, Map<String, ContactModeResponse>> contactModeRelMap = getContactModesFromSOAPResponse(response.getBody());
	     	System.debug('contactModeRelMap: ' + contactModeRelMap);
	     	updateContactModesStatus(contactModeRelMap);      		
      	}else if(response != null && response.getStatus() != 'OK'){
      		errorMessage = response.getStatus() + ' ' + response.getStatusCode(); 
      		updateContactModes('SYSTEM ERROR',errorMessage);
      		
      	}else if(response == null){
      		updateContactModes('SYSTEM ERROR',errorMessage);
     	}		
	}

	//Serialize the Contact Mode Relationship objects into XML
	public  String getContactModesSOAPBody(){
		String soapBody = '';
		
		if(contactModeList == null || contactModeList.size() == 0){
			return soapBody;
		}

		soapBody += '<contactModeRelationshipRequest010000>';
		soapBody += ' <firstName xsi:type="xsd:string">'+  contactObj.firstname +'</firstName>';
		soapBody += ' <lastName xsi:type="xsd:string">'+ contactObj.lastname  +'</lastName>';
		soapBody += ' <email xsi:type="xsd:string">'+ contactObj.email  +'</email>';
		soapBody += ' <title xsi:type="xsd:string">'+  contactObj.title +'</title>';
		soapBody += ' <salesforceAccountId xsi:type="xsd:string">'+ contactModeList[0].Ultimate_Parent_Account__c  +'</salesforceAccountId>';
		soapBody += ' <salesforceContactId xsi:type="xsd:string">'+  contactModeList[0].Contact_Number__c +'</salesforceContactId>';
		soapBody += ' <contactModes xsi:type="con:ArrayOf_tns1_contactMode010000" soapenc:arrayType="srg:contactMode010000[]"> ';
		for(Contact_Mode_Rel__c contactMode : contactModeList){
    		soapBody += '<contactMode010000>';
			String activeValue = 'false';
			if(contactMode.Isactive__c == true){
				activeValue = 'true';
			}
			soapBody += '<modeId xsi:type="xsd:int">'+ contactMode.Mode_Id__c +'</modeId>'; 
			soapBody += '<modeName xsi:type="xsd:string">'+ contactMode.Mode_Name__c + '</modeName>';        
			soapBody += '<isActive xsi:type="xsd:boolean">' + activeValue + '</isActive>'; 
			soapBody += '</contactMode010000>';	
		}
		soapBody += ' </contactModes> ';
		soapBody += ' </contactModeRelationshipRequest010000> ';
		System.debug('soapBody: ' + soapBody);
		
		return soapBody; 
	}

	//Send the SOAP request to Proposal tool
	public  Httpresponse SendSOAPRequest(string strEndPoint, string strAction, string strXML)
	{
		http soap = new http();
		Httprequest soap_request = new Httprequest();
		Httpresponse soap_response = new Httpresponse();
		Integer iTimeout = 0;
		if(Label.HTTP_Timeout != null &&  Label.HTTP_Timeout != ''){
			iTimeout = Integer.valueOf(Label.HTTP_Timeout);
		}else{
			iTimeout = 60000;  
		}
		soap_request.setEndpoint(strEndPoint);
		soap_request.setMethod('POST');
		soap_request.setHeader('Content-type', 'text/xml;charset=utf-8');
		soap_request.setHeader('SOAPAction', strAction);

		String userName = Label.ProposalToolUsername;
		String password = Label.ProposalToolPassword;
  
		Blob headerValue = Blob.valueOf(userName + ':' + password);
		String authorizationHeader = 'BASIC ' +
		EncodingUtil.base64Encode(headerValue);

		soap_request.setHeader('Authorization', authorizationHeader);
 		soap_request.setTimeout(iTimeout);
		soap_request.setBody(strXML);
           
		try
		{
			//Invoke the SOAP call
			soap_response = soap.send(soap_request);
			System.debug('getBody: ' + soap_response.getBody());
			System.debug('getStatusCode: ' + soap_response.getStatusCode());
			System.debug('getStatus: ' + soap_response.getStatus());
			return soap_response;
		}
		catch (Exception e)
		{
			System.Debug('Unable to process the modes information in SFDC ' + e.getMessage());
			errorMessage = e.getMessage();
		}
		return null;
	}


	//Deserialize the SOAP response to ContactModeResponse
	public Map<String, Map<String, ContactModeResponse>> getContactModesFromSOAPResponse(String responseXml){
		Map<String, Map<String, ContactModeResponse>> contactModeResponseMap = new Map<String, Map<String, ContactModeResponse>>();
		Dom.Document doc = new Dom.Document();
        doc.load(responseXml);    

        //Retrieve the root element for this document.
        Dom.XMLNode Envelope = doc.getRootElement();        
        Dom.XMLNode Body= Envelope.getChildElements()[0];        
        Dom.XMLNode contactModesResponses = Body.getChildElements()[0];        
        Dom.XMLNode contactModesResponse = contactModesResponses.getChildElements()[0];  	
        
        System.debug('#### contactModesResponse : ' + contactModesResponse);
        String userId = '';
        String passwd = '';
        Integer i = 0;
        String modeId;
        String statusCode;
		String statusDescription;
        ContactModeResponse contactModeResponseObj;
		String fieldName = '';
		String fieldValue = '';

		String fieldName1 = '';
		String fieldValue1 = '';
        
        List<ContactModeResponse> contactModeResponseList = null;
        for(Dom.XMLNode child : contactModesResponse.getChildElements()) 
        {
        	contactModeResponseList = new List<ContactModeResponse>();
        	String contactNumber;
        	String contactErrorCode;
        	String contactErrorDescription;
        	        	
        	String errorCode;
        	String errorDescription;
        	for(Dom.XMLNode child1 : child.getChildElements()) 
        	{
				fieldName1 = child1.getName();
				fieldValue1 = child1.getText();
        			
 				if('salesforceContactId' == fieldName1){
 					contactNumber = fieldValue1;
 				}else if('statusCode' == fieldName1){
 					contactErrorCode = fieldValue1;
 				}else if('errorDescription' == fieldName1){
					contactErrorDescription = fieldValue1;
 				}

				for(Dom.XMLNode child2 : child1.getChildElements()) 
        		{
		        	contactModeResponseObj = new ContactModeResponse();
					for(Dom.XMLNode child3 : child2.getChildElements()) 
					{
	        			fieldName = child3.getName();
	        			fieldValue = child3.getText();
		 				if('errorDescription' == fieldName){
		 					contactModeResponseObj.errorDescription = fieldValue;
		 				}else if('statusCode' == fieldName){
		 					contactModeResponseObj.status = fieldValue;
		 				}else if('modeId' == fieldName){
							contactModeResponseObj.modeId = fieldValue;
		 				}else if('modeName' == fieldName){
		 					contactModeResponseObj.modeName = fieldValue;
		 				}
					}//End of for(Dom.XMLNode child3 : child2.getChildElements())
					contactModeResponseList.add(contactModeResponseObj);
					
        		} //for(Dom.XMLNode child2 : child1.getChildElements()) 
        		
        	} //for(Dom.XMLNode child1 : child.getChildElements()) 

			
			for(ContactModeResponse tempContactModeRespObj : contactModeResponseList){
				tempContactModeRespObj.contactNumber = contactNumber;
				if(contactErrorCode != null && contactErrorCode != '' && 
					(tempContactModeRespObj.status == null || tempContactModeRespObj.status == '')){
					tempContactModeRespObj.status = contactErrorCode;
				}
				if(contactErrorDescription != null && contactErrorDescription != '' && 
					(tempContactModeRespObj.errorDescription == null || tempContactModeRespObj.errorDescription == '')){
					tempContactModeRespObj.errorDescription = contactErrorDescription;
				}

				if(tempContactModeRespObj.modeId != null
					&& tempContactModeRespObj.modeId != ''
					&& tempContactModeRespObj.contactNumber != null 
					&& tempContactModeRespObj.contactNumber != ''){
					Map<String, ContactModeResponse> contactModeResponses = contactModeResponseMap.containsKey(tempContactModeRespObj.contactNumber) ? 
																	contactModeResponseMap.get(tempContactModeRespObj.contactNumber) 
																	: new Map<String, ContactModeResponse>();
					contactModeResponses.put(tempContactModeRespObj.modeId, tempContactModeRespObj);
					contactModeResponseMap.put(tempContactModeRespObj.contactNumber, contactModeResponses); 
				}
			}
        }
        return contactModeResponseMap;
	}


	//Update the Contact Modes based on the response received from Proposal tool in SOAP response
	public  void updateContactModesStatus(Map<String, Map<String, ContactModeResponse>> contactModeRelationshipMap){
		Set<String> modeIds = new Set<String>();
		Set<String> contactNumbers = new Set<String>();
		if(contactModeRelationshipMap.size() > 0){
			contactNumbers = contactModeRelationshipMap.keySet();
		}
		
		for(String contactNumber : contactModeRelationshipMap.keySet()){
			Map<String, ContactModeResponse> contactModeResponses = contactModeRelationshipMap.get(contactNumber);
			if(contactModeResponses != null && contactModeResponses.size() > 0){
				modeIds.addAll(contactModeResponses.keySet());
			}
		}
		System.debug('contactNumbers: ' + contactNumbers);
		System.debug('modeIds: ' + modeIds);
		
		List<Contact_Mode_Rel__C> contactModesRelationships = new List<Contact_Mode_Rel__C>();
		List<Contact_Mode_Rel__C> deleteModes = new List<Contact_Mode_Rel__C>();
		for(Contact_Mode_Rel__C contactModeRelObj : [Select Id, Mode_Id__c, Isactive__c, Contact_Number__c, Status_Code__c,
														status_message__C,
														Status_Description__c from Contact_Mode_Rel__C where 
														Mode_Id__c in :modeIds and Contact_Number__c in :contactNumbers]){
			Map<String, ContactModeResponse> contactModeResponses = contactModeRelationshipMap.get(contactModeRelObj.Contact_Number__c);
			if(contactModeResponses != null && contactModeResponses.size() > 0){
				ContactModeResponse contactModesResponseObj = contactModeResponses.get(contactModeRelObj.Mode_Id__c);
				if(contactModesResponseObj != null){
					contactModeRelObj.Status_Code__c = contactModesResponseObj.status;
					String errorMessage = contactModesResponseObj.errorDescription;
					Integer len = (errorMessage.length() > 254) ? 254 : errorMessage.length();
					errorMessage = errorMessage.substring(0, len);
					contactModeRelObj.Status_Description__c = errorMessage;
					if('SUCCESS' == contactModeRelObj.Status_Code__c && contactModeRelObj.Isactive__c == false){
						deleteModes.add(contactModeRelObj);
					}else{
						contactModesRelationships.add(contactModeRelObj);
					}
					
					
				}
			}		
		}
		if(contactModesRelationships.size() > 0 ){
			update contactModesRelationships;
		}

		if(deleteModes.size() > 0 ){
			delete deleteModes;
		}
		
	}

	public void updateContactModes(String statusCode,
									String statusDescription){
		for(Contact_Mode_Rel__c contactModeRelObj : contactModeList){
			contactModeRelObj.Status_Code__c = statusCode;
			
			Integer len = (statusDescription.length() > 254) ? 254 : statusDescription.length();
			statusDescription = statusDescription.substring(0, len);
			contactModeRelObj.Status_Description__c = statusDescription;
		}
		
		if(contactModeList != null && contactModeList.size() > 0){
			update contactModeList;
		}
	}

	public class ContactModeResponse{
	 	public String modeId {get;set;}
	 	public String contactNumber {get;set;}
	 	public String status {get;set;}
	 	public String errorDescription {get;set;}
	 	public Boolean isActive {get;set;}
	 	public String AccountNumber{get;set;}
	 	public String modeName{get;set;}
	 	public ContactModeResponse(){
	 		modeId = '';
	 		contactNumber = '';
	 		status = '';
	 		errorDescription = '';
	 		AccountNumber = '';
	 		isActive = false;
	 	}
	}


	/*
     public static void testSendSOAPRequest(){
     	
     	String strAction = 'updateContactModesFromSalesforce';
		String strRequest = '';
		strRequest += '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:prot="http://protocol010000.contract.sunrungeneration.com" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">';
		strRequest += '<soapenv:Header/>';
		strRequest += '<soapenv:Body>';
      	strRequest += '<prot:updateContactModesFromSalesforce soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">';
        strRequest += '<requests xsi:type="con:ArrayOf_tns1_contactModeRelationshipRequest010000" soapenc:arrayType="srg:contactModeRelationshipRequest010000[]" xmlns:con="http://api:8080/contract/services/Contract010000" xmlns:srg="srg">'; 
		strRequest += '<contactModeRelationshipRequest010000>';
		strRequest += ' <salesforceAccountId xsi:type="xsd:string">'+   '1205619577' +'</salesforceAccountId>';
			strRequest += ' <salesforceContactId xsi:type="xsd:string">'+   '2033966804' +'</salesforceContactId>';
 			strRequest += ' <contactModes xsi:type="con:ArrayOf_tns1_contactMode010000" soapenc:arrayType="srg:contactMode010000[]"> ';
                strRequest += ' <contactMode010000> ';
				//strRequest += '<modeId xsi:type="xsd:int">81008</modeId>'; 1735010355
				strRequest += '<modeId xsi:type="xsd:int">1735010355</modeId>'; 
				strRequest += '<modeName xsi:type="xsd:string">PetersenDean - LADWP</modeName>';        
				strRequest += '<isActive xsi:type="xsd:boolean">true</isActive>';   
                strRequest += ' </contactMode010000> ';
               strRequest += ' </contactModes> ';
            strRequest += ' </contactModeRelationshipRequest010000> ';
		strRequest += '</requests>';
		strRequest += '</prot:updateContactModesFromSalesforce>';
		strRequest += '</soapenv:Body>'; 
		strRequest += '</soapenv:Envelope>';
		System.debug('strRequest: ' + strRequest);
		
		PRMContactModes contactModes = new PRMContactModes();
     	Httpresponse response = contactModes.SendSOAPRequest(Label.ProposalToolEndpoint, strAction, strRequest);
     	Map<String, Map<String, ContactModeResponse>> contactModeRelMap = contactModes.getContactModesFromSOAPResponse(response.getBody());
     	contactModes.updateContactModesStatus(contactModeRelMap);
     }
 
 	public static void testMethod1(){
		String response = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
   			response += '<soapenv:Body>';
				response += '<ns1:updateContactModesFromSalesforceResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="http://protocol010000.contract.sunrungeneration.com">';
		         response += '<updateContactModesFromSalesforceReturn soapenc:arrayType="ns2:contactModeRelationshipResponse010000[2]" xsi:type="soapenc:Array" xmlns:ns2="srg" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">';
		            response += '<updateContactModesFromSalesforceReturn xsi:type="ns2:contactModeRelationshipResponse010000">';
		               response += '<errorDescription xsi:type="xsd:string"/>';
		               response += '<isActive xsi:type="xsd:boolean">true</isActive>';
		               response += '<modeId xsi:type="xsd:int">2015848788</modeId>';
		               response += '<modeName xsi:type="xsd:string">"Verengo"</modeName>';
		               response += '<salesforceAccountId xsi:type="xsd:string" xsi:nil="true"/>';
		               response += '<salesforceContactId xsi:type="xsd:string">2002503282</salesforceContactId>';
		               response += '<statusCode xsi:type="xsd:string">SUCCESS</statusCode>';
		            response += '</updateContactModesFromSalesforceReturn>';
		            response += '<updateContactModesFromSalesforceReturn xsi:type="ns2:contactModeRelationshipResponse010000">';
		               response += '<errorDescription xsi:type="xsd:string">The contact 0002002503282 does not exist in the Sunrun database.</errorDescription>';
		               response += '<isActive xsi:type="xsd:boolean" xsi:nil="true"/>';
		               response += '<modeId xsi:type="xsd:int">-654714796</modeId>';
		               response += '<modeName xsi:type="xsd:string">"Verengo - S"</modeName>';
		               response += '<salesforceAccountId xsi:type="xsd:string" xsi:nil="true"/>';
		               response += '<salesforceContactId xsi:type="xsd:string">0002002503282</salesforceContactId>';
		               response += '<statusCode xsi:type="xsd:string">PROCESS_ERROR</statusCode>';
		            response += '</updateContactModesFromSalesforceReturn>';
		         response += '</updateContactModesFromSalesforceReturn>';
		      response += '</ns1:updateContactModesFromSalesforceResponse>';
		   response += '</soapenv:Body>';
		response += '</soapenv:Envelope>' ;
		PRMContactModes contactModes = new PRMContactModes();
		contactModes.getContactModesFromSOAPResponse(response);
	}
	*/
}