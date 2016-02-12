/****************************************************************************
Author  : Peter Alexander Mandy (pmandy@sunrunhome.com)
Date    : August 07, 2012
Description: This code is used by the VF Page called CreditCheck
             It is passed two QueryString Parameters for the stdController id
             and for the proposal from which you initiated the search and drilldown 
             i.e. "/apex/CreditCheck?id={!CreditId}&ProposalId={!ProposalId}"
*****************************************************************************/
public without sharing class CreditCheckExtension {

	public Customer_Credit__c CCObj{get;set;}
	private String ApprovedStatus{get;set;}
	public String PendingReason{get;set;}
	public String PendingNotes{get;set;}
	public String ProposalID{get;set;}
	public String originalProposalId{get;set;}
	public Proposal__c parentProposalObj;
	
	private String OpptyId{get;set;}
	private String AcctId{get;set;}
	public Boolean bExpired{get;set;}
	public Id StartingContact{get;set;}
	public Id StartingAccount{get;set;}
	LeaseDimensions LD{get;set;}

	public Integer getRowHeight(){
		return 3;
	}
	public Integer getColumnWidth(){
		return 104;
	}
	
	public PageReference returnToCreditRecord(){
		PageReference pr = new PageReference('/' + this.CCObj.Id);
		pr.setRedirect(true);
		return pr;
	} 
	
	public PageReference CreditCheckRefresh(){	
	   LeaseDimensions LD = new LeaseDimensions();
	   String retval_usingConId = '';
	   String retval_usingCCId = '';
	   if(!Test.isRunningTest()){
	   	retval_usingConId = LD.refreshHomeownerCredit(this.CCObj.Contact__c);
	   }
	   System.Debug('refresh result value: ' + retval_usingConId);
	   if(retval_usingConId == 'SUCCESS')
	   {
	       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The credit report for ' + this.CCObj.Contact__r.Name + ' has been requested to be refreshed.'));
	   }   
	   else if(retval_usingConId != null && retval_usingConId.length() > 2 && retval_usingConId.Substring(0,3)=='306')
	   {
	   	   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, retval_usingConId + ' - for Customer: ' + this.CCObj.Contact__r.Name));
	   }
	   else
	   {
			if(!Test.isRunningTest()){
				retval_usingCCId = LD.refreshHomeownerCredit(this.CCObj.Id);
   			}
	   	   if(retval_usingCCId == 'SUCCESS')
	   	   {
	   	   	   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The credit report for ' + this.CCObj.First_Name__c + ' ' + this.CCObj.Last_Name__c + ' has been requested to be refreshed.'));
	   	   }
	   	   else
	   	   {
	   	   	  String customernumber = this.CCObj.Contact__c;
	   	   	  if(this.CCObj.Contact__c == null)
	   	   	  {
	   	   	  	customernumber = this.CCObj.Id;
	   	   	  }
	   	      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, retval_usingCCId + 'Customer Number: ' + customernumber));
	   	   }
	   }
	   return null;
	}
	
	public CreditCheckExtension(){
		
	}
	
	public CreditCheckExtension(ApexPages.StandardController stdController){
	  this.CCObj = (Customer_Credit__c)stdController.getRecord();
	  initialize();
	}
	
	public void initialize(){
	  ApprovedStatus = this.CCObj.Approved__c;
	  PendingReason = this.CCObj.Pending_Reason__c;
	  PendingNotes =  this.CCObj.Pending_Notes__c;
	  ProposalID = ApexPages.CurrentPage().getparameters().get('ProposalId'); 
	  bExpired = false;
	  StartingContact = this.CCObj.Contact__c;
	  StartingAccount = this.CCObj.Account__c;
	  if(this.CCObj.Date_Pulled__c != null && Date.Today() > this.CCObj.Date_Pulled__c.addDays(CustomerCreditUtil.getCreditExpirationDays()))
	  {
	  	 bExpired = true;
	  }  
	  
	  for(Proposal__c p:[select id, Stage__c, Opportunity__c, Revised_Proposal__c, Original_Proposal_ID__c, Opportunity__r.AccountId, Conditional_Approval_Amount__c, Conditional_Approval__c from Proposal__c where id = :ProposalID])
	  {	
	  		this.CCObj.Account__c = p.Opportunity__r.AccountId;
			OpptyId = p.Opportunity__c;
			AcctId = p.Opportunity__r.AccountId;
			originalProposalId = (p.Original_Proposal_ID__c == null) ? p.Id : p.Original_Proposal_ID__c;
			parentProposalObj = p;
	  }
	  
	  System.Debug('Account Set for Reference: ' + this.CCObj.Account__c);
	}
	
	public PageReference submitNewCreditCheck(){
		LeaseDimensions LD = new LeaseDimensions();
		//validate email not exists
		for(Customer_Credit__c cc:[select id, Contact__c from Customer_Credit__c where Customer_Email__c = :this.CCObj.Customer_Email__c])
		{
	  	   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'A Credit Check was already ran for: ' + this.CCObj.Customer_Email__c + ' Please click on the link to see the results: <a href="/' + cc.Id + '">Existing Credit Report</a>'));	   
		   return null;	
		}	
		//create Credit Report Record
		this.CCObj.Date_Submitted__c = System.Now();
		insert this.CCObj;	
		//call LD
		if(!Test.isRunningTest()){
			LD.CallCreateAndInvite(this.CCObj);
		}
		return null;
	}

	public PageReference resendInvitation(){
		LeaseDimensions LD = new LeaseDimensions();
		if(!Test.isRunningTest()){
			LD.resendToHomeowner(this.CCObj.Contact__c, this.CCObj.Contact__r.Preferred_Language__c);
		}
		return null;
	}
	
	public PageReference CancelCCEdit(){
		//If CC is tied to proposal then go back to that screen
		for(Proposal__c p:[select id from Proposal__c 
		                    where Id = :ProposalID 
		                      and (Current_Customer_Credit_Report__c = :this.CCObj.Id 
		                      		//OR Secondary_Customer_Credit_Report__c = :this.CCObj.Id 
		                      		//OR Additional_Customer_Credit__c = :this.CCObj.Id 
		                      	) LIMIT 1])
		{
		   PageReference prProposal = new PageReference('/' + ProposalID);
		   prProposal.setRedirect(true);
		   return prProposal;
		}
		PageReference prSearch = new PageReference('/apex/SearchCreditReports?id=' + ProposalID);
		prSearch.setRedirect(true);
		return prSearch;
	}
	
	public PageReference SaveAndUpdateProposal(){
		List<Proposal__c> pList = new List<Proposal__c>();
		if(this.CCObj.Contact__c == null)
		{
			this.CCObj.Account__c = null;
		}
		if(this.CCObj.id == null)
		{
			insert this.CCObj;
		}
		else
		{
				Set<Id> proposalIds = new Set<Id>();
				proposalIds.add(ProposalID);
				//proposalIds.add(originalProposalId);

				//
				//Check to see if Approved is not null and was null
				//UPDATE PROPOSAL DATA
				System.debug('originalProposalId: ' + originalProposalId);
				System.debug('ProposalID: ' + ProposalID);
				for(Proposal__c p:[select id, Stage__c, Opportunity__c, Revised_Proposal__c, Original_Proposal_ID__c, Conditional_Approval_Amount__c, Conditional_Approval__c, 
			   						Current_Customer_Credit_Report__c, Primary_Customer__r.email, Credit_Status__c,
			   						Generation_Asset__r.Name from Proposal__c where (id in :proposalIds)])
			   	{
			
					
					//if((parentProposalObj != null) && (p.ID != ProposalID)
					//	&& ((parentProposalObj.Revised_Proposal__c == true && parentProposalObj.Original_Proposal_ID__c == p.id)
					//		|| (p.Original_Proposal_ID__c == parentProposalObj.Id && p.Revised_Proposal__c == true) 
					//		|| (p.Original_Proposal_ID__c == parentProposalObj.Original_Proposal_ID__c && p.Revised_Proposal__c == true))){
					//	continue;	
					//}
					
					if(p.ID == ProposalID || p.Current_Customer_Credit_Report__c == null 
						|| p.Current_Customer_Credit_Report__c == this.CCObj.Id){
						p.Current_Customer_Credit_Report__c = this.CCObj.Id;
						p.Primary_Customer__c = this.CCObj.Contact__c;
						p.Credit_Status__c = this.CCObj.Approved__c;
			   		}

					if(p.Generation_Asset__r.Name != null && p.Generation_Asset__r.Name != '' && p.ID == ProposalID)
					{
						if(this.CCObj.SRH_Customer_Number__c == null || this.CCObj.SRH_Customer_Number__c == ''){
							this.CCObj.SRH_Customer_Number__c = p.Generation_Asset__r.Name;	
						}
					}
					pList.add(p);
			   }	
			   System.debug('pList: ' + pList);	   	

				System.Debug('Checking Pending Reason');
				//Check to see if PendingReason is not null or changed
				if ((PendingReason == '' && this.CCObj.Pending_Reason__c != '') || (this.CCObj.Pending_Reason__c != null && this.CCObj.Pending_Reason__c != PendingReason))
				{
			   		if(!pList.isEmpty())	
			   		{
			   	  		for(Proposal__c p: pList)
			      		{

							//if((parentProposalObj != null) && (p.ID != ProposalID)
							//	&& ((parentProposalObj.Revised_Proposal__c == true && parentProposalObj.Original_Proposal_ID__c == p.id)
							//		|| (p.Original_Proposal_ID__c == parentProposalObj.Id && p.Revised_Proposal__c == true) 
							//		|| (p.Original_Proposal_ID__c == parentProposalObj.Original_Proposal_ID__c && p.Revised_Proposal__c == true))){
							//	continue;	
							//}
							
							if(p.ID == ProposalID){
								p.Stage__c = 'Pending'; 
								p.Pending_Proposal_Reason__c = this.CCObj.Pending_Reason__c;
								p.Pending_Comments__c = this.CCObj.Pending_Comments__c;
								p.Pending_Notes__c = this.CCObj.Pending_Notes__c;
			      			}
			      		
			      			if(p.ID == ProposalID || p.Current_Customer_Credit_Report__c == null 
							|| p.Current_Customer_Credit_Report__c == this.CCObj.Id){
								p.Current_Customer_Credit_Report__c = this.CCObj.Id;
								p.Primary_Customer__c = this.CCObj.Contact__c;
								p.Credit_Status__c = this.CCObj.Approved__c;
							}
			      		}
			   		}

				}		
			
			//Update the Oppty Credit_Status__c too
			Set<Id> OppId = new Set<Id>();
			List<Opportunity> listOppty = new List<Opportunity>();
			if(!pList.isEmpty())
			{
				System.Debug('Pending Reason updated on Prop' + ProposalID);
				update pList;
				for(Proposal__c p:pList)
				{
					OppId.add(p.Opportunity__c);
				}
				if(!OppId.isEmpty())
				{
					for(Opportunity o:[select id, Credit_Status__c from Opportunity where id in :OppId])
					{
						o.Credit_Status__c = 'Approved';
						listOppty.add(o);
					}
				}			
			}
			if(!listOppty.isEmpty())
			{
				update listOppty;
			}
			//
			// Check if Contact exists, if yes, and not attached as OCR to Oppty, create. 
			// if contact not exists, create and add to OCR on Oppty to which Proposal belongs.

				try{
					String contactRoleStr = EDPUtil.OCR_ROLE_CREDIT;
					Id contactId;
					Boolean bOCRExists = false;	
					Boolean contactExistis = false;		
					OpportunityContactRole existingOptyRole;
					Id proposalContactId;
					for(Contact existingContact : [Select Id, accountId, name , firstname, lastName, email,
													(Select Id, role, opportunityId, contactId, contact.name, contact.email 
														from OpportunityContactRoles where opportunityId =:OpptyId)  from Contact 
													where accountId =:AcctId and email =:this.CCObj.Customer_Email__c ]){
						
						if(existingContact.OpportunityContactRoles != null && existingContact.OpportunityContactRoles.size() > 0){
							existingOptyRole = null;
							for(OpportunityContactRole optyContactRoleObj : existingContact.OpportunityContactRoles){
								if(optyContactRoleObj.role == EDPUtil.HOME_OWNER){
									proposalContactId = optyContactRoleObj.contactId;
									System.debug('optyContactRoleObj: ' + optyContactRoleObj);
								}
								if(optyContactRoleObj.role == contactRoleStr || optyContactRoleObj.role == EDPUtil.OTHER){
									existingOptyRole = optyContactRoleObj;
									proposalContactId = optyContactRoleObj.contactId;
									bOCRExists = true;
									if(optyContactRoleObj.role == EDPUtil.OTHER){
										optyContactRoleObj.role = contactRoleStr;
										update optyContactRoleObj;
									}
									break;
								}
							}			
						}
						contactExistis = true;
						contactId = existingContact.Id;
						if(proposalContactId != null){
							break;
						}
					}
					
					System.debug('contactExistis: ' + contactExistis);
					if(contactExistis == false){
						
						Contact c = createContact(AcctId, this.CCObj);
						insert c;	
						contactId = c.Id;							
						String proposalSOQLStr = ProposalUtil.getProposalSQLStr();
						proposalSOQLStr += ' where Id =:proposalId ' ;
						List<Proposal__c> proposalsList = Database.query(proposalSOQLStr);
						if(proposalsList.size() > 0){
							Proposal__C tempProposalObj = proposalsList[0];
							Map<Id, Proposal__c> proposalMap = new Map<Id, Proposal__c>();
							proposalMap.put(tempProposalObj.Id, tempProposalObj);
							ProposalUtil.optyAndContactSharingForProposals(proposalMap.values());
						}
					}

					if(!bOCRExists)
					{
						Id tempContactId = (proposalContactId != null) ? proposalContactId : contactId;
						insertOptyContactRole(OpptyId, tempContactId);
					}
										
					if(this.CCObj.Contact__c == null){
						Id tempContactId = (proposalContactId != null) ? proposalContactId : contactId;
						this.CCObj.Contact__c = contactId;
					}

				}catch(Exception e)
			    {
			       System.Debug('Error Message: ' + e.getMessage());
			       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));  
			    }
			    	
			}
			System.debug('Before update ...');
			update this.CCObj;
			
			PageReference pr = new PageReference('/' + ProposalID);
			pr.setRedirect(true);
			return pr;
	}

	public static void insertOptyContactRole(Id OpptyId, Id contactId){
		OpportunityContactRole ocrNew = new OpportunityContactRole();
		ocrNew.OpportunityId = OpptyId;
		ocrNew.ContactId = contactId;
		ocrNew.Role = EDPUtil.OCR_ROLE_CREDIT;
		upsert ocrNew;
	}
	
	public static Contact createContact(Id AcctId, Customer_Credit__c CCObj){
		
		Contact c = new Contact();
		c.AccountId = AcctId;
		c.LastName =	CCObj.Last_Name__c;
		c.FirstName = CCObj.First_Name__c;
		c.Email = CCObj.Customer_Email__c;
		Account aForAddr;
		for(Account acct:[select id, BillingStreet, BillingState, BillingPostalCode, BillingCountry, BillingCity, Phone 
									From Account where Id = :c.AccountId])
		{
			aForAddr = acct;
		}
		
		System.Debug('Account for ADDR: ' + aForAddr);
		if(CCObj.Street__c == null || CCObj.Street__c == '')
		{
			c.MailingStreet = aForAddr.BillingStreet;
		}
		  else
		  {
		  	 c.MailingStreet = CCObj.Street__c;
		  }
		  if(CCObj.State__c == null || CCObj.State__c == '')
		  {
		     c.MailingState = aForAddr.BillingState;
		  }
		  else
		  {
		  	 c.MailingState = CCObj.State__c;
		  }
		  if(CCObj.Zip__c == null || CCObj.Zip__c == '')
		  {
		     c.MailingPostalCode = aForAddr.BillingPostalCode;
		  }
		  else
		  {
		  	 c.MailingPostalCode = CCObj.Zip__c;
		  }
		  if(CCObj.Country__c == null || CCObj.Country__c == '')
		  {
		     c.MailingCountry = aForAddr.BillingCountry;
		  }
		  else
		  {
		  	 c.MailingCountry = CCObj.Country__c;
		  }
		  if(CCObj.City__c == null || CCObj.City__c == '')
		  {
		     c.MailingCity = aForAddr.BillingCity;
		  }
		  else
		  {
		  	 c.MailingCity = CCObj.City__c;
		  }
		  if(CCObj.Home_Phone__c == null || CCObj.Home_Phone__c == '')
		  {
		     c.Phone = aForAddr.Phone;
		  }
		  else
		  {
		  	 c.Phone = CCObj.Home_Phone__c;
		  }
		  c.OtherPhone = CCObj.Other_Phone__c;
		  c.Birthdate = CCObj.DateOfBirth__c;
		  return c;
	}

}