public without sharing class LeaseDimensions {	
	
public void LeaseDimensions(){
	dealId = '';
}

public string dealId {get;set;}

public void ProcessReturnValue(String retval, String successMessage, Contact c)
{
	if(retval == 'SUCCESS')
    {
       if(c != null)
       {
       	  createCreditRecord(c);
       }
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO , successMessage));
    }
    else
    {
		String[] retvals = retval.split(';');
		if(retvals != null && retvals.size() > 0){
			String tempString = retvals[retvals.size() - 1].capitalize(); 
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, '<font color="red" weight="bold">'+ tempString + '</font>'));	 	          	
		}
       //for(String s:retvals)
       //{
       //   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, '<font color="red" weight="bold">'+ s + '</font>'));
       //}                   
    }
}


public static Set<Id> createCreditRecord(Map<Id,Proposal__C> proposals, Map<Id, Proposal__C> triggerMap){
	   //CREATE Credit Report that can be later updated via LeaseDimensions
	   List<Customer_Credit__c> ccList = new List<Customer_Credit__c>();
	   Set<Id> ccIds = new Set<Id>();
	   for(Proposal__C proposalObj : proposals.values()){
		   
		   if(proposalObj.Current_Customer_Credit_Report__c == null || proposalObj.Current_Customer_Credit_Report__r.type__c != 'Sunrun'){
			   Customer_Credit__c cc = new Customer_Credit__c();
			   cc.type__c = 'Sunrun';
			   cc.First_Name__c = proposalObj.Primary_Customer__r.firstname;
			   cc.Last_Name__c = proposalObj.Primary_Customer__r.LastName;
			   cc.Customer_Email__c = proposalObj.Primary_Customer__r.email;
			   cc.Contact__c = proposalObj.Primary_Customer__r.Id;
			   cc.Customer_Number__c = proposalObj.Primary_Customer__r.Id;
			   //cc.FICO1__c = proposalObj.Install_Partner_Name__c;
			   cc.Installer__c = proposalObj.Install_Partner_Name__c;
			   cc.Status__c = 'PASS';
			   if(proposalObj.Agreement_Type__c == ProposalUtil.CUST_OWNED_FULL_UPFRONT || proposalObj.Agreement_Type__c == ProposalUtil.CUST_OWNED_BANK_FINANCE){
			   		cc.FICO__c = 'Cash';
			   		cc.FICO1__c = 'Cash';
			   		cc.Approved__c = CustomerCreditUtil.CUSTOMER_OWNED;
					cc.Sunrun_Credit_Status__c = CustomerCreditUtil.CUSTOMER_OWNED;
			   }else{
			   		cc.FICO__c = 'CA-' + proposalObj.Install_Partner_Name__c;
			   		cc.FICO1__c = 'CA-' + proposalObj.Install_Partner_Name__c;
			   		cc.Approved__c = CustomerCreditUtil.Conditional_Approval_From_Partner;
			   		cc.Sunrun_Credit_Status__c = CustomerCreditUtil.PARTNER_GUARANTEE;
			   }
			   cc.Credit_Email_Sent__c = true;
			   cc.date_submitted__c = Datetime.now();
			   cc.Date_Run1__c = Datetime.now();
			   cc.Date_Pulled__c = Datetime.now();
			   
			   cc.Deal_Id__c = proposalObj.Opportunity__r.Deal_Id__c;
			   cc.Home_Phone__c = proposalObj.Primary_Customer__r.Phone;
		
			   cc.Account__c = proposalObj.Opportunity__r.AccountId;
			   
			   cc.Customer_Email__c = proposalObj.Primary_Customer__r.Email;
			   
			   cc.DateOfBirth__c = proposalObj.Primary_Customer__r.Birthdate;
			   cc.Street__c = proposalObj.Primary_Customer__r.MailingStreet;
			   cc.City__c = proposalObj.Primary_Customer__r.MailingCity;
			   cc.State__c = proposalObj.Primary_Customer__r.MailingState;
			   cc.Zip__c = proposalObj.Primary_Customer__r.MailingPostalCode;
			   cc.Country__c = proposalObj.Primary_Customer__r.MailingCountry;
			   
			   ccList.add(cc);
			   ProposalUtil.cusomerCreditProposalIds.add(proposalObj.Id);
		   }else if(proposalObj.Current_Customer_Credit_Report__c != null && proposalObj.Current_Customer_Credit_Report__r.type__c == 'Sunrun'){
		   	 ccIds.add(proposalObj.Current_Customer_Credit_Report__c);
		   }

	   }
	   if(ccList != null && !ccList.isEmpty()){
			insert ccList;   
	   }
	   
	   for(Proposal__C proposalObj : triggerMap.values()){
			for(Customer_Credit__c cc :ccList){
				if(cc.Contact__c == proposalObj.Primary_Customer__c){
					proposalObj.Current_Customer_Credit_Report__c = cc.Id;
					proposalObj.Credit_team_notes__c = 'Automatic Approval, Credit Record Created';
					ccIds.add(cc.Id);
					break;
				}
			}
	   }
	   
	   return ccIds;
}


public void createCreditRecord(Contact c){
               //CREATE Credit Report that can be later updated via LeaseDimensions
               Customer_Credit__c cc = new Customer_Credit__c();
               cc.date_submitted__c = System.today();
               cc.Contact__c = c.Id;
               cc.Account__c = c.AccountId;
               cc.First_Name__c = c.FirstName;
               cc.Last_Name__c = c.LastName;
               cc.Customer_Email__c = c.Email;
               cc.Customer_Number__c = c.Id;
               cc.DateOfBirth__c = c.Birthdate;
               cc.Street__c = c.MailingStreet;
               cc.City__c = c.MailingCity;
               cc.State__c = c.MailingState;
               cc.Zip__c = c.MailingPostalCode;
               cc.Country__c = c.MailingCountry;
               cc.Home_Phone__c = c.Phone;
               cc.Deal_Id__c = dealId;
               insert cc;   
}

public void CreditCheckRefresh(Contact c){
	String retval = '';
    String msg = '<font weight="bold">SUCCESS!  Customer ' + c.Name + ' has been re-invited to complete their credit profile and authorize a credit check via Lease Dimensions.</font>';
    retval = refreshHomeownerCredit(String.ValueOf(c.Id));
    System.Debug('RETVAL: ' + retval);
    ProcessReturnValue(retval, msg, c);
}

public void CallCreateAndInvite(Customer_Credit__c crdt){
	String retval = '';
	String msg = '<font weight="bold">SUCCESS!  Customer ' + crdt.First_Name__c + ' ' + crdt.Last_Name__c + ' has been invited to complete their credit profile and authorize a credit check via Lease Dimensions.</font>';
	User u = [select id, email from user where id = :UserInfo.getUserId()];
	retval = createAndInviteHomeowner(crdt.First_Name__c, crdt.Last_Name__c.Replace('&','%26'), crdt.Customer_Email__c, crdt.Id, UserInfo.getFirstName(), UserInfo.getLastName(), u.Email, crdt.deal_Id__c);
    System.Debug('RETVAL: ' + retval);        
    ProcessReturnValue(retval, msg, null);
}

public void CallCreateAndInvite(Contact c){
	String retval = '';
	String msg = '<font weight="bold">Customer ' + c.Name + ' has been invited to complete their credit profile and authorize a credit check via Lease Dimensions.</font>';
	User u = [select id, email from user where id = :UserInfo.getUserId()];
	retval = createAndInviteHomeowner(c.FirstName, c.LastName.Replace('&','%26'), c.Email, c.Id, UserInfo.getFirstName(), UserInfo.getLastName(), u.Email, dealId);    
    System.Debug('RETVAL: ' + retval);
    ProcessReturnValue(retval, msg, c);
}

public void CallResend(String conId, String conName,string language){
	String retval = '';
	Id tempContactId = getCustomerCreditContactId(conId);
	String msg = '<font weight="bold">Customer ' + conName + ' has been sent a re-invitation email to complete their credit profile and authorize a credit check via Lease Dimensions.</font>';
    retval = resendToHomeowner(tempContactId,language);
    System.Debug('RETVAL: ' + retval);    
    ProcessReturnValue(retval, msg, null);
}

public Id getCustomerCreditContactId(String contactId){
	String sunrunCreditStr = ProposalUtil.SUNRUN_CUSTOMER_CREDIT;
	String email = '';
	List<Contact> contactList = [Select Id, name, email from Contact where Id =:contactId];
	email = contactList[0].email;
	List<Customer_Credit__c> customerCreditList = [Select Id, type__C, Contact__c, Customer_Email__c from Customer_Credit__c 
														where type__c != :sunrunCreditStr and (Contact__c=:contactId OR Customer_Email__c =:email)
														order by Date_Submitted__c desc limit 1];
	Id creditContactId = contactId;
	if(customerCreditList.size() > 0 ){
		creditContactId = 	customerCreditList[0].Contact__c;
	}
	return 	creditContactId;
}

public HttpResponse invokeWebService(Http h, HttpRequest req){     
     //Invoke Web Service
     HttpResponse res = h.send(req);
     return res;
}

public String handleWebServiceResponse(HttpResponse res){
  //Parse and apply logic to the res message
  String request_errors = '';
  String retval = 'SUCCESS';
  try {        	
        XmlStreamReader reader = res.getXmlStreamReader();
        // Read through the XML 
        while(reader.hasNext()) {
          System.debug('Event Type:' + reader.getEventType());
          if (reader.getEventType() == XmlTag.START_ELEMENT) 
          {
            // ERROR CODE, per LD API DOC: 
            // If a request_errors tag is NOT detected in the XML response, 
            // then this can be considered a successful transaction.          
            if(reader.getLocalName() == 'request_errors')
            {
             while(reader.hasNext()) {
             	System.debug('Event Type Now:' + reader.getEventType());      
                if (reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == 'request_errors') {
                  break;
                }
                
                if(reader.getEventType() == XmlTag.CHARACTERS)
                {
               	   if(reader.getText().trim().length() > 0)
               	   {
                      //if(reader.getLocalName() != null && reader.getLocalName() == 'error_description'){
                      	request_errors = request_errors + reader.getText() + ';';
                      //}
               	   }
                 }
                 reader.next();
              }
            } 
          }
          reader.next();
        }              
        if(request_errors != '')
        {
           retval = request_errors;	
        } 
        }
        catch(Exception e)
        {
        	retval = CustomErrorMessages.UNABLE_TO_PROCESS_YOUR_REQUEST;
        	System.debug('Error Message: ' + e.getMessage());
        	System.debug('res.getBody(): ' + res.getBody());
        	//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, res.getBody()));
        }    
        System.debug('retval: ' + retval);
        return retval;            
}

public String refreshHomeownerCredit(String custno)
{
	    String hCustomerNumber = custno;        
        //
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http h = new Http();        
        req.setEndpoint(Label.LeaseDimensions + Label.LeaseDimensions_RefreshHomeownerCredit);
        req.setMethod('POST');
        req.setBody('&apikey='+Label.LeaseDimensions_APIKey+'&username='+Label.LeaseDimensions_APIUsername+'&password='+Label.LeaseDimensions_APIPassword+'&customer_number='+hCustomerNumber);
        System.Debug('BODY: '+req.getBody());      
 
        try {
        	res = invokeWebService(h, req);
        	System.Debug('RESPONSE XML: ' + res.getBody());
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
        }                               
        return handleWebServiceResponse(res);
}

public String resendToHomeowner(String custno, string language)
{
		String langCode = 'en';
    	if(language == 'Spanish'){
    	langCode = 'es_MX';
    	}	    
    	String hCustomerNumber = custno;
    	String retval = '';
        String request_errors = '';
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setEndpoint(Label.LeaseDimensions + Label.LeaseDimensions_ResendHomeownerInvite);
        req.setMethod('POST');
        req.setBody('&apikey='+Label.LeaseDimensions_APIKey+'&username='+Label.LeaseDimensions_APIUsername+'&password='+Label.LeaseDimensions_APIPassword+'&customer_number='+hCustomerNumber+'&langcode='+langCode);
        System.Debug('BODY: '+req.getBody());      
 
        try {
            res = invokeWebService(http, req); //http.send(req);
            System.Debug('RESPONSE XML: ' + res.getBody());
            retval = 'SUCCESS';
            System.Debug('STATUS = ' + retval);
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
            retval = res.getStatus();
        }                
        return handleWebServiceResponse(res);
}

	public String createInpersonCreditURL(String c_fname, String c_lname, String c_email, String custno, 
    									String homePhone, String street, String city, String state, String zip, 
    									String s_fname, String s_lname, String s_email, String o_deal_Id){
    	//return createInpersonCreditURL(c_fname, c_lname, c_email, custno, '', homePhone, street, city, state, zip, s_fname, s_lname, s_email, o_deal_Id, '');
    	return createInpersonCreditURL(c_fname, c_lname, c_email, custno, homePhone, street, city, state, zip, s_fname, s_lname, s_email, o_deal_Id, '');							
	}

	public String createInpersonCreditURL(String c_fname, String c_lname, String c_email, String custno, //String language,
    									String homePhone, String street, String city, String state, String zip, 
    									String s_fname, String s_lname, String s_email, String o_deal_Id, String Installer) {
    	//String langCode = 'en';
    	//if(language == 'Spanish'){
    	//	langCode = 'es_MX';
    	//}
        String hFName = c_fname;
        String hLName = c_lname;
        String hEmail = c_email;
        String hdealId = (o_deal_Id == null) ? '' : o_deal_Id;
        String hCustomerNumber = custno;
		
		String hhomePhone = '';
		System.debug('homePhone: ' + homePhone);
		if(homePhone != null){
			homePhone = homePhone.remove('(').remove(')').remove('-').remove(' ');
			if(homePhone.length() == 10){
				hhomePhone = homePhone.substring(0,3) + '-' + homePhone.substring(3,6) + '-' + homePhone.substring(6); 
			}
		}
		
		String hstreet = (street == null) ? '' : street;
		String hcity = (city == null) ? '' : city;
		String hstate = (state == null) ? '' : state;
		String hzip = (zip == null) ? '' : zip.split('-')[0];

        String sFName = s_fname;
        String sLName = s_lname;       
        String sEmail = 'bogus@bogus.com'; //s_email;
        String sGroupID = Label.LeaseDimensions_DefaultInstaller;  //'0123456789QyY2'; //valid sunrunuat.leasedimensions.com/apirest value
        ///String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm();
        String fullFileURL =  EDPUtil.getBaseURL();
		
		String inpersonURL = Label.LeaseDimensions_Inperson + '?apikey=' + Label.LeaseDimension_InpersonAPIKey;
		inpersonURL += '&FirstName=' +  EncodingUtil.urlEncode(hFName, 'UTF-8');
		inpersonURL += '&LastName=' +  EncodingUtil.urlEncode(hLName, 'UTF-8');
		inpersonURL += '&CustomerEmail=' +  EncodingUtil.urlEncode(hEmail, 'UTF-8');

		inpersonURL += '&HomePhone=' +  EncodingUtil.urlEncode(hhomePhone, 'UTF-8');
		inpersonURL += '&Street=' +  EncodingUtil.urlEncode(hstreet, 'UTF-8');
		inpersonURL += '&City=' +  EncodingUtil.urlEncode(hcity, 'UTF-8');
		inpersonURL += '&State=' +  EncodingUtil.urlEncode(hstate, 'UTF-8');
		inpersonURL += '&Zip=' +  EncodingUtil.urlEncode(hzip, 'UTF-8');
		
		inpersonURL += '&years_at_address=';
		inpersonURL += '&borrower_income=';
		inpersonURL += '&employment_status=';
		inpersonURL += '&size_of_household=';
		
		inpersonURL += '&ContactNumber=' +  EncodingUtil.urlEncode(hCustomerNumber, 'UTF-8');
		inpersonURL += '&deal_id=' + o_deal_Id;
		inpersonURL += '&Installer=' + Installer;
		//inpersonURL += '&langCode=' + langCode;
		//inpersonURL += '&Installer_id=' + ( (Installer == 'Sungevity') ? 'NA7' : '');
		inpersonURL += '&proposal_id=' ;
		inpersonURL += '&SalesRepEmail=' +  EncodingUtil.urlEncode(sEmail, 'UTF-8');
		inpersonURL += '&SalesRepFirstName=' +  EncodingUtil.urlEncode(sFName, 'UTF-8');
		inpersonURL += '&SalesRepLastName=' +  EncodingUtil.urlEncode(sLName, 'UTF-8');
		//inpersonURL += '&returnurl=';
		inpersonURL += '&returnurl=' +  fullFileURL + '/apex/InPersonCreditResponse';
		return inpersonURL;	  
	} 

    public String createAndInviteHomeowner(String c_fname, String c_lname, String c_email, String custno, String s_fname, String s_lname, String s_email, String o_deal_Id) {
    	return createAndInviteHomeowner(c_fname,c_lname,c_email, custno, '', s_fname, s_lname, s_email, o_deal_Id, '');
    	//return createAndInviteHomeowner(c_fname,c_lname,c_email, custno, s_fname, s_lname, s_email, o_deal_Id, '');
    }

    public String createAndInviteHomeowner(String c_fname, String c_lname, String c_email, String custno, String language,  
    													String s_fname, String s_lname, String s_email, String o_deal_Id, String installer) {
    	String langCode = 'en';
    	if(language == 'Spanish'){
    	langCode = 'es_MX';
    	}	
        system.debug('langCode>>' +  langCode);
        String hFName = c_fname;
        String hLName = c_lname;
        String hEmail = c_email;
        String hdealId = (o_deal_Id == null) ? '' : o_deal_Id;
        String hCustomerNumber = custno;
        //
        // We are currently asking for a default and constant value here
        // since we no longer want the partners to have a login to lease dimensions
        // These will become custom labels or be put into a custom setting once finalized.
        //
        String sFName = s_fname;
        String sLName = s_lname;       
        String sEmail = 'bogus@bogus.com'; //s_email;
        String sGroupID = Label.LeaseDimensions_DefaultInstaller;  //'0123456789QyY2'; //valid sunrunuat.leasedimensions.com/apirest value
        //
        //
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
		sGroupID = (Installer == 'Sungevity') ? 'NA7' : sGroupID;
		sEmail = (Installer == 'Sungevity') ? Label.LeaseDimensions_Sungevity_Email : sEmail;
        String retval = '';
        String request_errors = '';
        req.setEndpoint(Label.LeaseDimensions + Label.LeaseDimensions_CreateAndInviteHomeowner);
        req.setMethod('POST');
                                              
        //req.setBody('&apikey='+Label.LeaseDimensions_APIKey+'&username='+Label.LeaseDimensions_APIUsername+'&password='+Label.LeaseDimensions_APIPassword+'&homeowner_first_name='+hFName+'&homeowner_last_name='+hLName+'&homeowner_email='+hEmail+'&installer_id='+sGroupID+'&salesperson_first_name='+sFName+'&salesperson_last_name='+sLName+'&salesperson_email='+sEmail+'&customer_number='+hCustomerNumber+'&deal_id='+o_deal_Id +'&Installer='+installer +'&langCode='+langCode);
		req.setBody('&apikey='+Label.LeaseDimensions_APIKey+'&username='+Label.LeaseDimensions_APIUsername+'&password='+Label.LeaseDimensions_APIPassword+'&homeowner_first_name='+hFName+'&homeowner_last_name='+hLName+'&homeowner_email='+hEmail+'&installer_id='+sGroupID+'&salesperson_first_name='+sFName+'&salesperson_last_name='+sLName+'&salesperson_email='+sEmail+'&customer_number='+hCustomerNumber+'&deal_id='+o_deal_Id +'&langcode='+langCode +'&installer='+installer );
        System.Debug('BODY: '+req.getBody());      
 
        try {
            res = invokeWebService(http, req); //http.send(req);
            System.Debug('RESPONSE XML: ' + res.getBody());
            retval = 'SUCCESS';
            System.Debug('STATUS = ' + retval);
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
            retval = res.getStatus();
            System.Debug('ERROR STATUS = ' + retval);
        }                
        return handleWebServiceResponse(res);
    } 
}