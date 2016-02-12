global without sharing class CreditCheckController { 
    
public List<OpportunityContactRole> listOCR{get;set;}
public List<Contact> listCon{get;set;}
public List<CreditCheckContacts> listCCC{get;set;}
public Boolean bAddCon{get;set;}
public Boolean bShowConMsgs{get;set;}
private String OCR_ROLE_CREDIT = 'Credit Contact';
public Opportunity opp{get;set;}
public Account acct{get;set;}
public Contact addCon{get;set;}
public String oppId{get;set;}
public Set<Id> conIdsWithActiveCC{get;set;}
public List<String> listActiveCCCons{get;set;}
public List<String> listSubmittedCCCons{get;set;}
public Map<Id, Customer_Credit__c> mapContactToCustomerCredit{get;set;}
public String selCC {get;set;}
LeaseDimensions LD{get;set;}

public void CreditCheckController(){}

public PageReference setbAddCon(){
	bAddCon = true;
	PageReference pref = new PageReference('/apex/CreditCheckSubmittal?OppId=' + oppId + '&AddNewCon=Y#newcon');
	pref.setRedirect(true);
    return pref;
}
     
public PageReference setSelCon()
{
	return null;
}    
public PageReference CreateContact()
{
	//Boolean bError = false;
	bShowConMsgs = true;
	if(addCon.email == null || addCon.FirstName == null || addCon.LastName == null)
	{
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'You must provide a first name, last name, and email address for a credit check request.'));
		return null;
	}
    for(Contact c:[select id from Contact where email = :addCon.email])
	{
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'A contact with email address: ' + addCon.email + ' already exists.'));       
       return null;
	}	
	//		
	insert addCon;
	//
	OpportunityContactRole newOCR = new OpportunityContactRole();
	newOCR.ContactId = addCon.Id;
	newOCR.OpportunityId = oppId;
	newOCR.Role = OCR_ROLE_CREDIT;
	insert newOCR;
	//
	bAddCon = false;
	//
	PageReference pr = new PageReference('/apex/CreditCheckSubmittal?OppId=' + oppId + '&DefaultConId=' + addCon.Id);
	pr.setRedirect(true);
	return pr;	
}

public PageReference Cancel()
{
	bAddCon = false;
	return null;
}

public PageReference CancelCreditCheck()
{
	bAddCon = false;
	PageReference pr = new PageReference('/' + oppId);
	pr.setRedirect(true);
	return pr;
}

public PageReference init()
{
   //
   oppId =  ApexPages.CurrentPage().getParameters().get('OppId');
   String defconId =  ApexPages.CurrentPage().getParameters().get('DefaultConId');
   String strAddNewCon = ApexPages.CurrentPage().getParameters().get('AddNewCon');
   selCC = defconId;
   bShowConMsgs = false;
   System.Debug('Opp Id: ' + oppId);
try{
   Opportunity opp = [select Id, Name, AccountId from Opportunity where Id = :oppId LIMIT 1];
   Account acct = [Select Id, Name, BillingStreet, BillingState, BillingPostalCode, BillingCountry, BillingCity From Account where id = :opp.AccountId];
   bAddCon = false;
   if(strAddNewCon == 'Y')
   {
      bAddCon = true;	
   }
   addCon = new Contact();
   System.Debug('Account Id: ' + opp.AccountId);
   addCon.AccountId = opp.AccountId;
   addCon.Contact_Type__c = 'Residential';
   addCon.MailingStreet = acct.BillingStreet;
   addCon.MailingState = acct.BillingState; 
   addCon.MailingCountry = acct.BillingCountry; 
   addCon.MailingCity = acct.BillingCity;
   addCon.MailingPostalCode = acct.BillingPostalCode;
   //	
   listOCR = new List<OpportunityContactRole>(); 
   listCon = new List<Contact>();
   mapContactToCustomerCredit = new Map<Id, Customer_Credit__c>();
   listCCC = new List<CreditCheckContacts>();
   conIdsWithActiveCC = new Set<Id>();
   listActiveCCCons = new List<String>();
   listSubmittedCCCons = new List<String>();
   //
    for(OpportunityContactRole ocr:[select id, IsPrimary, ContactId, Contact.Name, Contact.FirstName, Contact.LastName, Contact.Email, Role, opportunity.deal_Id__c 
                                     from OpportunityContactRole 
                                    where OpportunityId = :oppId])
    {
      listOCR.add(ocr);	
    }
   //
     for(Customer_Credit__c cc:[select id, Contact__c, Date_Pulled__c, Date_Submitted__c from Customer_Credit__c where Contact__r.AccountId = :opp.AccountId])
     {
   	  if(cc.Contact__c != null && (cc.Date_Pulled__c != null && Date.Today() <= cc.Date_Pulled__c.addDays(60)))
   	  {
         conIdsWithActiveCC.add(cc.Contact__c);
   	  }
   	  if(cc.Contact__c != null && (cc.Date_Submitted__c != null || (cc.Date_Pulled__c != null && Date.Today() <= cc.Date_Pulled__c.addDays(60))))
   	  {
   	  	listActiveCCCons.add(String.ValueOf(cc.Contact__c));
   	  }
   	  //Create Submitted list
      if(cc.Date_Submitted__c != null && (cc.Date_Pulled__c == null || cc.Date_Submitted__c > cc.Date_Pulled__c))
      {
	     listSubmittedCCCons.add(String.ValueOf(cc.Contact__c));
      }
   	  mapContactToCustomerCredit.put(cc.Contact__c, cc);
     }
     for(Contact c:[select id, Name, FirstName, LastName, Email, Phone, Contact_Number__c, 
                         MailingStreet, MailingState, MailingCountry, MailingCity, MailingPostalCode,
                         Birthdate, AccountId
                    from Contact where AccountId = :opp.AccountId order by createddate desc])
     {
   	  listCon.add(c);
   	  listCCC.add(new CreditCheckContacts(c, mapContactToCustomerCredit, defconId, listOCR, conIdsWithActiveCC));
     }	
   }
   catch(Exception e){
   	  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Opportunity not found!'));
   }            
   return null;
}

public PageReference createData(){
	//if LeaseDimensions call is successful...
	date dtSubmitted = Date.Today();
	Opportunity oppUpdate = [select id, Name, Date_Credit_Pulled__c from Opportunity where id = :oppid];
	oppUpdate.Date_Credit_Pulled__c = dtSubmitted;
	update oppUpdate;
	//
 	List<Customer_Credit__c> listCCForUpdate = new List<Customer_Credit__c>();
	for(CreditCheckContacts ccc:listCCC)
	{
		System.Debug('Comparing: '+String.ValueOf(ccc.ContactId)+ ' with ' + selCC + ' having Crdt id: ' + ccc.Id);
		
		if(String.ValueOf(ccc.ContactId) == selCC && ccc.Id != null && ccc.Id != '')
		{
		   for(Customer_Credit__c cc:[select Id, Date_submitted__c from Customer_Credit__c where id = :ccc.Id])
		   {
		   	  System.Debug('updating CCC');
		   	  cc.date_submitted__c = dtSubmitted;
		   	  
		   	  listCCForUpdate.add(cc);		   	  
		   }
		}		
	}
	if(!listCCForUpdate.isEmpty())
	{
		update listCCForUpdate;
	}
	else
	{
		for(CreditCheckContacts ccc:listCCC)
	    {
		   if(String.valueOf(ccc.ContactId) == selCC)
		   {
		       //CREATE Credit Report that can be later updated via LeaseDimensions
		       Customer_Credit__c cc = new Customer_Credit__c();
		       cc.date_submitted__c = dtSubmitted;
		       cc.Contact__c = selCC;
		       cc.Account__c = ccc.thecon.AccountId;
		       cc.First_Name__c = ccc.thecon.FirstName;
		       cc.Last_Name__c = ccc.thecon.LastName;
		       cc.Customer_Email__c = ccc.thecon.Email;
		       cc.Customer_Number__c = ccc.thecon.Contact_Number__c;
		       cc.DateOfBirth__c = ccc.thecon.Birthdate;
		       cc.Street__c = ccc.thecon.MailingStreet;
		       cc.City__c = ccc.thecon.MailingCity;
		       cc.State__c = ccc.thecon.MailingState;
		       cc.Zip__c = ccc.thecon.MailingPostalCode;
		       cc.Country__c = ccc.thecon.MailingCountry;
		       cc.Home_Phone__c = ccc.thecon.Phone;
				cc.deal_Id__c = ccc.dealId;
		       insert cc;
		   }
	    }
	}
	return null;
}

public PageReference SubmitCreditCheck(){
	LeaseDimensions LD = new LeaseDimensions();
	String retval = '';
	bAddCon = false;
	for(CreditCheckContacts ccc:listCCC)
	{
		   if(String.valueOf(ccc.ContactId) == selCC)
		   {
		   	   if(ccc.thecon.Email == null || ccc.thecon.Email == '')
		   	   {
		   	   	   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'You must assign an email address to this contact prior to submitting a credit check.'));
		   	   	   return null;
		   	   }
		   	   System.Debug('Calling LeaseDimensions and our buddy Rob Hingst!');
		   	   User u = [select id, email from user where id = :UserInfo.getUserId()];
		       LD.dealId = ccc.dealId;
			   retval = LD.createAndInviteHomeowner(ccc.thecon.FirstName, ccc.thecon.LastName, ccc.thecon.Email, ccc.thecon.Id, UserInfo.getFirstName(), UserInfo.getLastName(), u.Email, LD.dealId);
          	   System.Debug('RETVAL: ' + retval);
          	   if(retval == 'SUCCESS')
	           {
	           	  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO , 'Customer ' + ccc.ContactName + ' has been invited to complete their credit profile and authorize credit check via Lease Dimensions.'));
	              return createData();
	           }
	           else
	           {
	 	          String[] retvals = retval.split(';');
	 	          for(String s:retvals)
	 	          {
	 	             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, s));
	 	          }	 	          	 	
	 	          return null;
	           }
             }
           }
	return null; 
}

public class CreditCheckContacts{	
	public string Id{get;set;}
	public string ContactId{get;set;}
	public string ContactName{get;set;}
	public string ContactEmail{get;set;}
	public string ContactRole{get;set;}
	public string ContactPhone{get;set;}
	public Boolean selected{get;set;}
	public Contact thecon{get;set;}
	public Boolean bActiveCCExists{get;set;}  
    public Boolean bRecentlySubmittedCCExists{get;set;}
    public String dealId{get;set;}
	public CreditCheckContacts(Contact c, Map<Id, Customer_Credit__c> mapCCC, String DefCon, List<OpportunityContactRole> lstOCR, Set<Id> expActiveCCConIds){
		this.ContactId = c.Id;
		this.ContactName = c.Name;
		this.ContactEmail = c.Email;
		this.ContactPhone = c.Phone;
		this.ContactRole = 'Not Associated to Oppty';
		this.thecon = c; 
		if(expActiveCCConIds.Contains(c.Id))
		{
			this.bActiveCCExists = true;
		}
		else
		{
			this.bActiveCCExists = false;
		}
		//
		if(mapCCC.get(c.Id) != null)
		{
		   this.Id = mapCCC.get(c.Id).Id;
		   if(mapCCC.get(c.Id).Date_Submitted__c != null && (mapCCC.get(c.Id).Date_Pulled__c == null || mapCCC.get(c.Id).Date_Submitted__c > mapCCC.get(c.Id).Date_Pulled__c))
		   {
		      this.bRecentlySubmittedCCExists = true;
		   }
		}
		//
		for(OpportunityContactRole ocr:lstOCR)
		{
			if(ocr.ContactId == c.Id)
			{
			   if(ocr.Role == '' || ocr.Role == null)
			   {
			   	  this.ContactRole = 'Contact Role Not Set';
			   }
			   else
			   {
		          this.ContactRole = ocr.Role;
			   }
			}
			dealId = ocr.opportunity.deal_Id__c;
		}
		if(DefCon == String.ValueOf(c.Id))
		{
			this.selected = true;
		}
		else
		{
		   this.selected = false;
	    }
	}
	/*public CreditCheckContacts(OpportunityContactRole ocr){
		this.ContactId = ocr.ContactId;
		this.ContactName = ocr.Contact.Name;
		this.ContactEmail = ocr.Contact.Email;
		this.ContactRole = ocr.Role;
		this.selected = false; 
		this.Id = ocr.Id;
	}*/
}

}