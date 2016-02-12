public class NewCustomerContact {
	Opportunity opty;
	Account account;
	Proposal__C proposalObj;
	public String lastName{get;set;}
	public Contact addCon {get;set;}
	public String optyId {get;set;}
	public String proposalId {get;set;}
	public String contactId {get;set;}
	//private String OCR_ROLE_CREDIT = 'Credit Contact';
	public Boolean confirmMode {get;set;}
	public String errorMessage{get;set;}
	public String parentURL{get;set;}
	public Id accountRecordTypeId {get;set;}
	public Id contactRecordTypeId {get;set;}
	public String partnername {get;set;}
	public boolean showEditSec {get; set;}
    public boolean showReadSec {get; set;}
    public boolean showSaveContact {get; set;}
    public boolean editContact {get; set;}
    public String title {get;set;}

	public NewCustomerContact(ApexPages.StandardController stdController){
		title = 'New Contact';
		intializeContactRecordTypeId();
		intializeAccountRecordTypeId();
		initializePartnerName();
		errorMessage = '';
		if(addCon == null){
			addCon = new Contact();
		}
		account = new Account();
		opty = new Opportunity();
		proposalId = System.currentPageReference().getParameters().get('proposalId');
		contactId = System.currentPageReference().getParameters().get('contactId');
		System.debug('contactId: ' + contactId);
		confirmMode = false;
		showEditSec = true;
        showReadSec = false;
		init();
	}
	
	public void updateProposalDetails(){
		
		if(addCon.Proposal__c == null){
			proposalId = '';
		}else{
			proposalId = addCon.Proposal__c;
		} 	
		initializeProposal();
	}

	public NewCustomerContact(){
		addCon = new Contact();
		account = new Account();
		opty = new Opportunity();
		proposalId = System.currentPageReference().getParameters().get('proposalId');
		confirmMode = false;
		init();
		System.debug('End Init ...');
	}	

	public Pagereference saveContact(){
		confirmMode = false;
		errorMessage = '';
		if(addCon.email == null || addCon.FirstName == null || lastName == null 
			|| addCon.MailingStreet == null || addCon.MailingCity == null || addCon.Mailingstate == null
			|| addCon.MailingPostalCode == null){
			errorMessage = 'Please enter values for the required fields';
			Exception expObj = new BaseException(errorMessage);
			expObj.setMessage(errorMessage);
			ApexPages.addMessages(expObj);
			return null;
		}
		
		addCon.LastName = lastName;		
		if(proposalId == null || proposalId == ''){
			account.RecordTypeId = accountRecordTypeId;
			if(addCon.MailingStreet != null && addCon.MailingStreet != ''){
				account.Name = addCon.MailingStreet;
			}else{
				account.Name = addCon.FirstName + ' ' + addCon.LastName;
			}
			account.BillingStreet = addCon.MailingStreet;
			account.BillingState = addCon.MailingState ; 
			account.BillingCity = addCon.MailingCity;
			account.BillingPostalCode = addCon.MailingPostalCode;
			String sunrunDevelopmentAccount = Label.Sunrun_Development_Account;
			User dacoAccount = [Select Id, Username from User where Username = :sunrunDevelopmentAccount and firstname = 'Developer' and lastname = 'Account' limit 1	];
			account.OwnerId = dacoAccount.Id;
			insert account;
		}
		addCon.AccountId = account.Id;
		addCon.RecordTypeId = contactRecordTypeId;
		addCon.Partner_Name__c = partnername;
		upsert addCon;		
		contactId = addCon.Id;

		if(optyId != null && optyId != ''){
			List<OpportunityContactRole> contactRoleList = [Select Id, ContactId, OpportunityId from OpportunityContactRole 
															WHERE ContactId =:addCon.Id AND OpportunityId =:optyId];
															//WHERE ContactId =:addCon.Id AND OpportunityId =:optyId AND Role = 'Other'];
			if(contactRoleList == null || contactRoleList.size() == 0){
				OpportunityContactRole newOCR = new OpportunityContactRole();
				newOCR.ContactId = addCon.Id;
				newOCR.OpportunityId = optyId;
				newOCR.Role = EDPUtil.OTHER;
				insert newOCR;
			}
		}
		if(proposalObj != null){
			Map<Id, Proposal__c> proposalMap = new Map<Id, Proposal__c>();
			proposalMap.put(proposalObj.Id, proposalObj);
			ProposalUtil.optyAndContactSharingForProposals(proposalMap.values());
		}

		if(ApexPages.getMessages().size() == 0){
			confirmMode = true;
		}
		
		showEditSec = false;
        showReadSec = true;
        if(confirmMode == true && editContact == true){
			Pagereference ref = new PageReference('/partner/' + contactId);
            ref.setRedirect(true);  
        	return ref;
        }
		return null;
	}

	private void initializeProposal(){
		if(proposalId != null && proposalId != ''){
			String proposalSOQLStr = ProposalUtil.getProposalSQLStr();
			proposalSOQLStr += ' where Id =:proposalId ' ;
			List<Proposal__c> proposalsList = Database.query(proposalSOQLStr);
			proposalObj = proposalsList[0];
			addCon.Proposal__c = proposalObj.Id;
			optyId = proposalObj.Opportunity__c;
			opty = [select Id, Name, AccountId from Opportunity where Id = :optyId LIMIT 1];
			if(opty.AccountId != null){
				account = [Select Id, Name, BillingStreet, BillingState, BillingPostalCode, 
							BillingCountry, BillingCity From Account where id = :opty.AccountId];
				addCon.AccountId = account.Id;
				addCon.Contact_Type__c = 'Residential';
				addCon.MailingStreet = account.BillingStreet;
				addCon.MailingState = account.BillingState; 
				addCon.MailingCity = account.BillingCity;
				addCon.MailingPostalCode = account.BillingPostalCode;
			}
		}else{
			addCon.AccountId = null;
			addCon.Contact_Type__c = 'Residential';
			addCon.MailingStreet = '';
			addCon.MailingState = ''; 
			addCon.MailingCity = ''; 
			addCon.MailingPostalCode = ''; 		
		}	
	}

	private void init(){
		initializeProposal();
		System.debug('contactId: ' + contactId);
		editContact = false;
		if(contactId != null && contactId != ''){
			title = 'Edit Contact';
			Set<String> contactIds = new Set<String>();
			contactIds.add(contactId);
			List<Contact> contactList = PRMContactUtil.getContacts(contactIds);
			if(contactList != null && contactList.size() > 0){
				addCon = contactList[0];
				lastName = addCon.LastName;
				System.debug('addCon 1 : ' + addCon);
				editContact = true;
			}
		}
		System.debug('addCon 2 : ' + addCon);
	}	

	public String getBaseURL() {
		String baseURL = EDPUtil.getBaseURL();
		return baseURL;
	}

	public Boolean getEditAdditionalInfo(){
		if((proposalId == null || proposalId == '') && addCon.Proposal__c == null){
			return true;
		}else{
			return false;
		}
	}

	private void intializeAccountRecordTypeId(){
		if(accountRecordTypeId == null){
			List<RecordType> recordTypeObjs = [select Id, Name, SobjectType from RecordType where SObjectType = 'Account' and name = 'Residential' limit 1 ];
			if(recordTypeObjs != null && recordTypeObjs.size() > 0){
				accountRecordTypeId = recordTypeObjs[0].Id;
			}			
		}
	}

	private void intializeContactRecordTypeId(){
		if(contactRecordTypeId == null){
			List<RecordType> recordTypeObjs = [select Id, Name, SobjectType from RecordType where SObjectType = 'Contact' and name = 'Residential' limit 1 ];
			if(recordTypeObjs != null && recordTypeObjs.size() > 0){
				contactRecordTypeId = recordTypeObjs[0].Id;
			}			
		}
	}
	
	private void initializePartnerName(){
		if(partnername == null || partnername == ''){
			Id userId = UserInfo.getUserId();
			User userObj = [Select Id, contactId, companyname from User where Id =:userId ];
			if(userObj.contactId != null){
				Contact contactObj = [Select Id, Ultimate_Parent_Account__c, Ultimate_Parent_Account__r.name from Contact where Id =:userObj.contactId];
				partnername = contactObj.Ultimate_Parent_Account__r.name;
			}
		}
	}
	
	
	public class BaseException extends Exception {}

}