public class ContactObservingExtension {

private Contact conObj;

public Integer iUpdateErrorCount{get;set;}

public List<ObservingContact> listPartnerCons{get;set;}

public List<ObservingContact> listAdditionalPartnerCons{get;set;}

public ContactObservingExtension(ApexPages.StandardController stdController){	
	this.conObj = (Contact)stdController.getRecord();	
	iUpdateErrorCount = 0;
}

public PageReference Cancel(){
	PageReference pr = new PageReference('/apex/PRMViewContact?contactId=' + this.conObj.Id);
	pr.setRedirect(true);
	return pr;
}
	
public static Map<Id,Set<Id>> getObservedContacts(String Observer, Id ObserverId)
{
   String retval = '';
   Map<Id, Set<Id>> mapObserverToObservees = new Map<Id, Set<Id>>();
   //
   HttpRequest req = new HttpRequest();
   HttpResponse res = new HttpResponse();
   Http http = new Http();
   req.setEndpoint(Label.ProposalToolEndpoint);
   req.setMethod('POST');
   req.setBody('getObservedSalesForceContactIds');
   //
   String strAction = 'getObservedSalesForceContactIds';
   String strRequest = '';
  
  		strRequest += '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:prot="http://protocol010000.contract.sunrungeneration.com">';
		strRequest += '<soapenv:Header/>';
		strRequest += '<soapenv:Body>';
      	strRequest += '<prot:getObservedSalesForceContactIds soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">';
		strRequest += '<salesforceContactIdObserver xsi:type="xsd:string">' + Observer + '</salesforceContactIdObserver>';
		strRequest += '</prot:getObservedSalesForceContactIds>';
		strRequest += '</soapenv:Body>';
		strRequest += '</soapenv:Envelope>';		
				
		System.Debug('REQUEST For Get from Proposal Tool: ' + strRequest);
		//
		try{
		Httpresponse response = SendSOAPRequest(Label.ProposalToolEndpoint, strAction, strRequest);
      	if(response == null)
      	{
      		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'A null response was returned from the Proposal Tool.  Please contact the Proposal Tool Admin for assistance.'));
      		return mapObserverToObservees;
      	}
        //
      	System.Debug('RESPONSE from Get call to proposal tool: ' + response);
      	System.Debug('RESPONSE BODY: ' + response.getBody());
        //
      	Set<String> setIds = getObservedIdsFromSOAPResponse(response.getBody());
      	if(setIds.isEmpty())
      	{
      		if(Observer == null || Observer == '')
      		{
      		   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This contact does not have a Contact Number and therefore cannot be queried in the Proposal Tool.'));
      		}
      		else
      		{
    		   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'There are no observed contacts in the Proposal Tool for Contact Number: ' + Observer));    		   
      		}      		
      	}
      	      	
      	mapObserverToObservees.put(ObserverId, new Set<Id>());
      	
      	for(Contact c:[select id, Contact_Number__c, LastName from Contact where Contact_Number__c in :setIds and Contact_Number__c != '' order by LastName])
      	{
      		System.Debug('ADDING TO MAP: ' + c.Contact_Number__c);
      		mapObserverToObservees.get(ObserverId).add(c.Id);
      	}    	      
        }
		catch(Exception e)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}	
      	//
        return mapObserverToObservees;	
}

//Send the SOAP request to Proposal tool
public static Httpresponse SendSOAPRequest(String strEndPoint, String strAction, String strXML)
{
	    String errorMessage = '';
		http soap = new http();
		Httprequest soap_request = new Httprequest();
		Httpresponse soap_response = new Httpresponse();

		integer iTimeout = 60000;  
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
			System.debug('soap_request: ' + soap_request);
			//Invoke the SOAP call
			soap_response = soap.send(soap_request);
			
			System.Debug(soap_response.getBody());
			System.Debug(soap_response.getStatusCode());
			System.Debug(soap_response.getStatus());
			return soap_response;
		}
		catch (Exception e)
		{
			System.Debug('Unable to process the observer information in SFDC ' + e.getMessage());
			errorMessage = e.getMessage();
		}
		return null;
}

	//Deserialize the SOAP response to ContactModeResponse
	public static Set<String> getObservedIdsFromSOAPResponse(String responseXml)
	{
		Set<String> setContactSunRunIds = new Set<String>();		
		Dom.Document doc = new Dom.Document();
        doc.load(responseXml);    
        
        //Retrieve the root element for this document.
        Dom.XMLNode Envelope = doc.getRootElement();        
        Dom.XMLNode Body= Envelope.getChildElements()[0];        
        Dom.XMLNode observedResponses = Body.getChildElements()[0];        
        Dom.XMLNode observedResponse = observedResponses.getChildElements()[0];  	
                
        String userId = '';
        String passwd = '';
        Integer i = 0;
        String modeId;
        String contactNumber;
        String statusCode;
		String statusDescription;
		String fieldName = '';
		String fieldValue = '';
        for(Dom.XMLNode child : observedResponses.getChildElements()) 
        {
        	System.debug('child.name: ' + child.getName());
        	System.debug('child.text: ' + child.getText());
        	for(Dom.XMLNode child1 : child.getChildElements()) 
        	{
        		fieldName = child1.getName();
        		fieldValue = child1.getText();
        		
 				if('getObservedSalesForceContactIdsReturn' == fieldName && fieldValue != ''){
 					setContactSunRunIds.add(fieldValue);
 				}
        	}
        }
        System.Debug('Set Values are: ' + setContactSunRunIds);
        return setContactSunRunIds;
	}

//Deserialize the SOAP response to ContactModeResponse
public Boolean getInvalidObservedIdsFromSOAPResponse(String responseXml)
{
	Boolean bAllGood = true;		
	Dom.Document doc = new Dom.Document();
        doc.load(responseXml);    
        
        //Retrieve the root element for this document.
        Dom.XMLNode Envelope = doc.getRootElement();        
        Dom.XMLNode Body= Envelope.getChildElements()[0];        
        Dom.XMLNode observedResponses = Body.getChildElements()[0];        
        Dom.XMLNode observedResponse = observedResponses.getChildElements()[0];  	
                
        String userId = '';
        String passwd = '';
        Integer i = 0;
        String modeId;
        String contactNumber;
        String statusCode;
		String statusDescription;
		String fieldName = '';
		String fieldValue = '';
		iUpdateErrorCount = 0;
        for(Dom.XMLNode child : observedResponses.getChildElements()) 
        {
        	System.debug('child.name: ' + child.getName());
        	System.debug('child.text: ' + child.getText());
        	for(Dom.XMLNode child1 : child.getChildElements()) 
        	{        	    
        		System.debug('child1.name: ' + child1.getName());
        	    System.debug('child1.text: ' + child1.getText());
        	
        	for(Dom.XMLNode child2 : child1.getChildElements()) 
        	{
        		System.debug('child2.name: ' + child2.getName());
        	    System.debug('child2.text: ' + child2.getText());
        	    for(Dom.XMLNode child3 : child2.getChildElements()) 
        	    {
        		   System.debug('child3.name: ' + child3.getName());
        	       System.debug('child3.text: ' + child3.getText());
        	       if('errorDescription' == child3.getName() && child3.getText() != ''){
 					System.Debug('ERROR VALUE FOR REAL: ' + child3.getText());
 					bAllGood = false;
 					iUpdateErrorCount++;
 					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, child3.getText()));
 				}
        	    }
        	    
        	}        	
        		fieldName = child1.getName();
        		fieldValue = child1.getText();
        	}
        }
        return bAllGood;
}

public PageReference AddToList(){
   Set<Id> setAlreadyAddedIds = new Set<Id>();
   for(ObservingContact oc:listAdditionalPartnerCons)
   {
   	  for(ObservingContact ocMain:listPartnerCons)
   	  {
   	  	setAlreadyAddedIds.add(ocMain.ConId);
   	  }
   }	
	
	
   for(ObservingContact oc:listAdditionalPartnerCons)
   {
   	  if(!setAlreadyAddedIds.Contains(oc.ConId))
   	  {
   	     listPartnerCons.add(oc);
   	  }
   }
   return null;	
}

/*
public PageReference Search(){
   listAdditionalPartnerCons = new List<ObservingContact>();
   //
   for(Contact c:[select id, Salutation, FirstName, LastName, Email, 
	                      Title, Phone, Contact_Number__c, AccountId, Proposal_Tool_Access__c
	                 from Contact 
	                where (Job_Function__c = :this.conObj.Job_Function__c
	                       or Role__c = :this.conObj.Role__c) 
	                  and AccountId = :this.conObj.AccountId 
	                  and Proposal_Tool_Access__c in ('Granted','Requested','Not Needed', 'Revoked')
	                  and Id != :this.conObj.Id
	             order by LastName])
   {
   	   listAdditionalPartnerCons.add(new ObservingContact(c, true));
   }
   return null;	
}
*/

public PageReference addOne(){
	try{
	System.Debug('Selected ID: ' + this.conObj.ObservingContact__c);
	if(this.conObj.ObservingContact__c != null)
	{
	   listPartnerCons.add(new ObservingContact((Contact)[select id, Salutation, FirstName, LastName, Email, Title, Phone, Contact_Number__c, AccountId, Proposal_Tool_Access__c from Contact where id = :this.conObj.ObservingContact__c and Contact_Number__c != null and Proposal_Tool_Access__c in ('Granted','Requested','Not Needed', 'Revoked') and AccountId = :this.conObj.AccountId],true));
	}
	this.conObj.ObservingContact__c = null;
	}
	catch(Exception e)
	{
		System.Debug('Error selecting single contact to observe: ' + e.getMessage());
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please invoke the lookup icon to properly filter your search.'));
	}	
	return null;
}

public Set<String> getProposalToolAccessList(){
	Set<String> accessList = new Set<String>();
	accessList.add('Granted');
	accessList.add('Requested');
	accessList.add('Not Needed');
	accessList.add('Revoked');
	return 	accessList;
}

public List<ObservingContact> getProposalToolData(){
	listPartnerCons = new List<ObservingContact>();
	//
	// Call ProposalTool to get the Current List of Observees for this Observer (this.conObj.Id)
	// [assumes a one-time "true-up" was done so that PT does not serve up invalid contacts (unobservables).]
	System.Debug('ConNumber: '+this.conObj.Contact_Number__c);
	Map<Id,Set<Id>> mapObserve = getObservedContacts(this.conObj.Contact_Number__c, this.conObj.Id);
	for(Contact c:[select id, Name, Salutation, FirstName, LastName, Email, Title, Phone, Contact_Number__c, AccountId, Proposal_Tool_Access__c 
	                 from Contact 
	                where id in :mapObserve.get(this.conObj.Id)
	             order by LastName])
	{
		listPartnerCons.add(new ObservingContact(c, true));
		System.Debug('ADDDING CONTACT: ' + c.Name);
	}
	//New Code (06-Nov-2012) to consider business model: Franchise or Chain
	String strBusinessModel = '';
	Id siteAccountId = null;
	Set<Id> setObservableFranchiseContacts = new Set<Id>();
	//Get Business Model
	for(Account a:[select id, Business_Model__c from Account where id = :this.conObj.AccountId])
	{
		strBusinessModel = a.Business_Model__c;
	}
	Boolean bHQContact = true;
	//
	// If Franchise, check to see if the contact is really a site-level contact (has accountcontactrole). 
	// If so, then they may only observe at that level, so set the account as the subaccount(site).
	// else, they may observe everyone on that account so set the account as the main account.
	//
	if(strBusinessModel == 'Franchise')
	{
  	    for(AccountContactRole acr:[select id, ContactId, AccountId from AccountContactRole where ContactId = :this.conObj.Id])
	    {
	       bHQContact = false;	
	       siteAccountId = acr.AccountId;           
	    }
	    // Add the child accounts too for observation, if the Contact is an HQ Contact.
		if(!bHQContact)
		{
			for(AccountContactRole acr:[select id, ContactId, AccountId from AccountContactRole where AccountId = :siteAccountId])
			{
				setObservableFranchiseContacts.add(acr.ContactId);
			}
		}
	}
	System.Debug('Account Business Model: ' + strBusinessModel);	
	// End of New Code (06-Nov-2012) to consider business model: Franchise or Chain
	// 
	// Code assumes a one-time "true-up" was done so that PT does not serve up invalid contacts (unobservables).
	// use setObservableFranchiseContacts to determine the set of observables instead of just assuming the 
	// contact's parent account id is the sole controlling field for determining which contacts may be observed.	
	String accountIdStr = this.conObj.AccountId + '';
	Id accountId = this.conObj.AccountId;
	Set<Id> contactIds = mapObserve.get(this.conObj.Id);
	Set<String> accessList = getProposalToolAccessList();
	Set<String> divisionList = new Set<String>();
	divisionList.add('Field Sales');
	divisionList.add('Inside Sales');
	
	String contactSelectionStr = 'select id, Name, Salutation, FirstName, LastName, Email, Title, Phone, Contact_Number__c, AccountId, Proposal_Tool_Access__c from Contact ';
	contactSelectionStr  += ' where AccountId =:accountId ';
	if(contactIds != null ){
		contactSelectionStr  += ' and id not in :contactIds ';
	}
	contactSelectionStr  += ' and Proposal_Tool_Access__c in :accessList ';
	if(accountIdStr != null && accountIdStr.contains(Label.Sunrun_Inc_Id)){
		contactSelectionStr  += ' and Division__c in :divisionList ';
	}
	contactSelectionStr  += ' order by LastName, FirstName ';
	System.debug('contactIds: ' + contactIds);
	System.debug('accountId: ' + accountId);
	System.debug('divisionList: ' + divisionList);
	System.debug('accessList: ' + accessList);
	System.debug('contactSelectionStr: ' + contactSelectionStr);
	
	for(Contact c:  Database.query(contactSelectionStr))
	{
		if(setObservableFranchiseContacts != null && !setObservableFranchiseContacts.isEmpty())
		{
			//If Franchise Contaccts are set then only add those, else add all for that account.
			if(setObservableFranchiseContacts.Contains(c.Id))
			{
				listPartnerCons.add(new ObservingContact(c, false));
				System.Debug('Adding Franchise site-level contact: ' + c.Name);
			}
		}
		else
		{
		   listPartnerCons.add(new ObservingContact(c, false));		   
		   System.Debug('Adding top-level contact: ' + c.Name);
		}		
	}
	return listPartnerCons;
}

public PageReference UpdateProposalTool(){
	//
	// Call PR to delete and re-create observing contacts.
	//
   HttpRequest req = new HttpRequest();
   HttpResponse res = new HttpResponse();
   Http http = new Http();
   req.setEndpoint(Label.ProposalToolEndpoint);
   req.setMethod('POST');
   req.setBody('updateObservationRelationships');
   //
   String strAction = 'updateObservationRelationships';
   String strRequest = '';
    	  strRequest += '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:prot="http://protocol010000.contract.sunrungeneration.com" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">';
		  strRequest += '<soapenv:Header/>';
		  strRequest += '<soapenv:Body>';
      	  strRequest += '<prot:updateObservationRelationships soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">';
		  strRequest += '<salesforceContactIdObserver xsi:type="xsd:string">' + this.conObj.Contact_Number__c + '</salesforceContactIdObserver>';
		  strRequest += '<salesforceContactIdsObserved xsi:type="con:ArrayOf_xsd_string" soapenc:arrayType="xsd:string[]" xmlns:con="http://api:8080/contract/services/Contract010000">'; 
		  
          for(ObservingContact oc:listPartnerCons)
          {
          	  if(oc.Selected)
          	  {
			     strRequest += '<salesforceContactIdObserved xsi:type="xsd:string">' + oc.ConNumber + '</salesforceContactIdObserved>';
          	  }	
          }
	      strRequest += '</salesforceContactIdsObserved>';
		  strRequest += '</prot:updateObservationRelationships>';
		  strRequest += '</soapenv:Body>';
		  strRequest += '</soapenv:Envelope>';
		  
	      System.Debug('REQUEST to update the proposal tool: ' + strRequest);	      
		
   Httpresponse response_to_update = SendSOAPRequest(Label.ProposalToolEndpoint, strAction, strRequest);
   if(response_to_update == null)
   {
   	  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'A null response was returned from the Proposal Tool.  Please contact the Proposal Tool Admin for assistance.'));
   	  return null;
   }
   //
   System.Debug('RESPONSE = ' + response_to_update);
   System.Debug('RESPONSE BODY = ' + response_to_update.getBody());	
   //
   if(getInvalidObservedIdsFromSOAPResponse(response_to_update.getBody()))
   {
   	   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Succesfully updated Observed Contacts for ' + this.conObj.Name));
   }  
   System.Debug('Error Count: ' + iUpdateErrorCount);
   System.Debug('List of Partners Size: ' + listPartnerCons.size());
   if(iUpdateErrorCount < listPartnerCons.size() && iUpdateErrorCount > 0)
   {
   	   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Succesfully updated all other Observed Contacts for ' + this.conObj.Name));
   }
   //
   return null;
}

public PageReference AddAll(){
	Set<Id> existingCons = new Set<Id>();
	List<ObservingContact> listAllCons = new List<ObservingContact>();

	String accountIdStr = this.conObj.AccountId + '';
	Id accountId = this.conObj.AccountId;
	Id contactId = this.conObj.Id;
	Set<String> accessList = getProposalToolAccessList();
	Set<String> divisionList = new Set<String>();
	divisionList.add('Field Sales');
	divisionList.add('Inside Sales');
	
	String contactSelectionStr = 'select id, Salutation, FirstName, LastName, Email, Title, Phone, Contact_Number__c, AccountId, Proposal_Tool_Access__c from Contact ';
	contactSelectionStr  += ' where AccountId =:accountId ';
	contactSelectionStr  += ' and Id != :contactId and Proposal_Tool_Access__c in :accessList ';
	if(accountIdStr != null && accountIdStr.contains(Label.Sunrun_Inc_Id)){
		contactSelectionStr  += ' and Division__c in :divisionList ';
	}
	contactSelectionStr  += ' order by LastName ';
	System.debug('contactSelectionStr: ' + contactSelectionStr);
	for(Contact c:  Database.query(contactSelectionStr))
	{
		listAllCons.add(new ObservingContact(c, true));
	}
	listPartnerCons = listAllCons;
    return null;	
}

public PageReference RemoveContacts(){
	List<ObservingContact> newListOC = new List<ObservingContact>();
	for(ObservingContact oc:listPartnerCons)
	{
		if(!oc.Selected)
		{
		   newListOC.add(oc);
		}
	}
	listPartnerCons = newListOC;
    return null;
}

public void init()
{
	listPartnerCons = new List<ObservingContact>();
	listPartnerCons = getProposalToolData();
}

public class ObservingContact{
	public Id ConId{get;set;}
	public String FirstName{get;set;} 
	public String LastName{get;set;}
	public String Email{get;set;}
	public String Phone{get;set;}
	public String Salutation{get;set;}
	public String ConNumber{get;set;}
	public String Title{get;set;}
	public String ProposalToolAccess{get;set;}
	public Boolean Selected{get;set;}
	public ObservingContact(Contact c, Boolean bSel)
	{
		this.ConId = c.Id;
		this.FirstName = c.FirstName;
		this.LastName = c.LastName;
		this.Email = c.Email;
		this.Phone = c.Phone;
		this.Salutation = c.Salutation;
		this.ConNumber = c.Contact_Number__c;
		this.Title = c.Title;
		this.ProposalToolAccess = c.Proposal_Tool_Access__c;
		this.Selected = bSel; //true;
	}
}

}