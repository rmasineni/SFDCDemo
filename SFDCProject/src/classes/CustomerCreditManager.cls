public class CustomerCreditManager {
        public CustomLookup__c customLookupObj {get;set;}
        public OpportunityContactRole optyContactRole {get;set;}
        public Id opportunityId {get;set;}
        public Id accountId {get;set;}
        public Id contactId {get;set;}
        public List<OpportunityContactRole> listOCR{get;set;}
        public List<Contact> listContacts{get;set;}
        public List<Contact> listCon{get;set;}
        public List<CreditCheckContacts> listCCC {get;set;}
        public Boolean bAddCon{get;set;}
        public Boolean bShowConMsgs{get;set;}
        private String OCR_ROLE_CREDIT = 'Credit Contact';
        private Opportunity opp{get;set;}
        public Account acct{get;set;}
        public Contact addCon{get;set;}
        public String oppId{get;set;}
        public Set<Id> conIdsWithActiveCC{get;set;}
        public List<String> listActiveCCCons{get;set;}
        public List<String> listSubmittedCCCons{get;set;}

        public Set<String> conEmailsWithActiveCC{get;set;}
        public List<String> listActiveCCConEmails{get;set;}
        public List<String> listSubmittedCCConEmails{get;set;}
        public Map<String, List<String>> emailContactIdMap{get;set;} 

        public Map<Id, Customer_Credit__c> mapContactToCustomerCredit{get;set;}
        public Map<String, Customer_Credit__c> mapContactEmailToCustomerCredit{get;set;}
        public String selCC {get;set;}
        private Set<Id> contactIds = new Set<Id>();
        private Set<String> contactEmails = new Set<String>();
        private Map<Id, OpportunityContactRole> optyContactRolesMap = new Map<Id, OpportunityContactRole>();
        public String searchConString {get;set;}
        LeaseDimensions LD{get;set;}
        public String searchLike {get;set;}
        public Id contactRecordTypeId{get;set;}
        public Id tempCCId;
		public String partnerPortalStr {get;set;}

		public String getSiteURL() {
	    	String baseURL = EDPUtil.getBaseURL();
	    	return baseURL;
		}
		
		public boolean getShowButtons(){
			Boolean result = true;
			if(listCCC == null || listCCC.isEmpty()){
				result = false;
			}
			return result;
		}
		
        public String inputValue {
			get;
			set{
				inputValue = customLookupObj.Proposal__c;
			}
        }
        public void updateInputValue(){
            customLookupObj.Contact__c = null;
            inputValue = customLookupObj.Proposal__c;
        }
        
        public boolean isValidDomain(String emailId){
	        String[] emailIdList = new List<String>();
	        emailIdList = emailId.split('@');
	        if(emailIdList == null || emailIdList.size() != 2)
	            return false;
			
			String validDomainList = Label.Customer_Credit_Domains;
	        String[] domainList = validDomainList.split(';');
	        System.debug('domainList: ' + domainList);          
	        for(String tempDomain : domainList){
	        	System.debug('tempDomain: ' + tempDomain);
	            if(tempDomain == emailIdList[1]){
	                return false;
	            }
	        }
	        return true;			
			        	
        }
        
        public ApexPages.StandardSetController con {
            get {
				if(con != null)
				{
				    return con;
				}
				con = createSQOLConnection();
				if(con != null){
				        con.setPageSize(25);
				}
				return con;
            }
            set;
        }

    private ApexPages.StandardSetController createSQOLConnection(){
        ApexPages.StandardSetController tempConnection;
        String soqlQuery = getSelectionQuery();
        soqlQuery += ' order by FirstName, LastName ' ;
        if(soqlQuery != null && soqlQuery != ''){
                tempConnection = new ApexPages.StandardSetController(Database.getQueryLocator(soqlQuery));
        }
        return tempConnection;          
    }

    private String getSelectionQuery(){
		
		String searchCondition = ' AND ';               
                
        if(customLookupObj.Contact__c != null){
                searchCondition += ' (Id =:contactId) ';
        }else if(customLookupObj.Proposal__c != null){
                searchCondition += ' (accountId =:accountId) ';
        }else{
        	searchCondition = ' ';
        }
		
		if(searchConString != null && searchConString != ''){
			searchLike = '%' + searchConString + '%';
			if(searchCondition != null && searchCondition != '')
				searchCondition +=  ' AND ';

			searchCondition += ' ((FirstName like :searchLike) ';
			searchCondition += ' OR (LastName like :searchLike) ';
			searchCondition += ' OR (Email like :searchLike)) ';
		}

		String soqlQuery = 'Select id, Name, FirstName, LastName, Email, Phone, Contact_Number__c, accountId, ';
		soqlQuery += ' MailingStreet, MailingState, MailingCountry, MailingCity, MailingPostalCode, ';
		soqlQuery += ' Credit_Received__c, Credit_Submitted__c,  Preferred_Language__c,';
		soqlQuery += ' Birthdate, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode ' ; 
		soqlQuery += ' from Contact where RecordTypeId =:contactRecordTypeId and email != null and email != \'\' '; 
		if(searchCondition != null && searchCondition != ''){
			soqlQuery += searchCondition;
		}
		System.Debug('SOQL QUERY: ' + soqlQuery);
		return soqlQuery;
    }

        Private void intializeAccountIds(String optyId){
			if(optyId != null && optyId != ''){
				opportunityId = optyId;
				System.debug('opportunityId: ' + opportunityId);
				List<Opportunity> optyObjList = [Select Id, accountId from Opportunity where Id =:opportunityId];
				if(optyObjList.size() > 0 && optyObjList[0].AccountId != null){
				        accountId = optyObjList[0].AccountId;
				}
			}
        }

        Private void intializeOptyAndAccountIds(String proposalId){
	        if(proposalId != null && proposalId != ''){
	                List<Proposal__c> proposalList = [Select Id, Opportunity__c from Proposal__c where Id =:proposalId];
	                if(proposalList.size() > 0 ){
	                        opportunityId = proposalList[0].Opportunity__c;
	                        System.debug('opportunityId: ' + opportunityId);
	                        List<Opportunity> optyObjList = [Select Id, accountId from Opportunity where Id =:opportunityId];
	                        if(optyObjList.size() > 0 && optyObjList[0].AccountId != null){
	                                accountId = optyObjList[0].AccountId;
	                        }
	                }
	        }
        }
		
		private boolean isEmptyString(String stringValue){
			Boolean result = false;
			if(stringValue == null || stringValue == ''){
				result = true;
			}
			return result;
		}
        public CustomerCreditManager(){
				partnerPortalStr = '';
				setLoginUserInfo();                
                String optyId;
				oppId = System.currentPageReference().getParameters().get('id');
				if(oppId == null){
					oppId = '';
				}
				optyId = oppId;
				System.debug('optyId: ' + optyId);
				String proposalId = System.currentPageReference().getParameters().get('proposalId');
                String tempContactId = System.currentPageReference().getParameters().get('contactId');
                listCCC = new List<CreditCheckContacts>();
                customLookupObj = new CustomLookup__c();
                
                if(oppId != null && oppId != ''){
                	intializeAccountIds(oppId);
                }else{  
	                if(proposalId != null && proposalId != ''){
	                        customLookupObj.Proposal__c = proposalId;
	                        inputValue = customLookupObj.Proposal__c;
	                        intializeOptyAndAccountIds(proposalId);
	                }if(tempContactId != null && tempContactId != ''){
	                        customLookupObj.Contact__c = tempContactId;
	                        contactId = tempContactId;
	                }
                }
                System.debug('Before ..');
				init(proposalId);
				System.debug('After ..');
        }
        public Void applySearchFilter(){
                contactId = customLookupObj.Contact__c;
                if(customLookupObj.Contact__c == null && customLookupObj.Proposal__c == null){
                        listCCC = new List<CreditCheckContacts>(); 
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Select a Proposal OR Contact'));
                        return ;
                }
                if(customLookupObj.Proposal__c != null){
                        intializeOptyAndAccountIds(customLookupObj.Proposal__c);
                }
                init(null);
        }
     
        public PageReference setSelCon()
        {
                return null;
        }    

        public PageReference Cancel()
        {
                bAddCon = false;
                return null;
        }

        public void intializeResidentialRecordTypeId(){
                if(contactRecordTypeId == null){
                        List<RecordType> recordTypeObjs = [select Id, Name, SobjectType from RecordType where SObjectType = 'Contact' and name = 'Residential' limit 1 ];
                        if(recordTypeObjs != null && recordTypeObjs.size() > 0){
                                contactRecordTypeId = recordTypeObjs[0].Id;
                        }                       
                }
        }

        public void init(){
                init(null);
        }

		public void setLoginUserInfo(){
			partnerPortalStr = '';
			User u = [select id, contactId, email from user where id = :UserInfo.getUserId()];
			if(u != null && u.contactId != null){
				partnerPortalStr = '/partner';
			}
			System.debug('partnerPortalStr: ' + partnerPortalStr);
		}
	        
        public void init(Id proposalId)
        {
                bShowConMsgs = false;
                contactIds = new Set<Id>();
                contactEmails = new Set<String>();
                String defconId =  '';

                if(customLookupObj.Contact__c != null){
                        contactIds.add(customLookupObj.Contact__c);
                }else if(customLookupObj.Proposal__c != null){
                        intializeOptyAndAccountIds(customLookupObj.Proposal__c);                
                }

                if(customLookupObj.Contact__c == null && customLookupObj.Proposal__c == null && oppId == null)
                        return;
				
				intializeResidentialRecordTypeId();

                bAddCon = false;
                listContacts = new List<Contact>(); 
                listOCR = new List<OpportunityContactRole>();                
                listCon = new List<Contact>();
                mapContactToCustomerCredit = new Map<Id, Customer_Credit__c>();
                mapContactEmailToCustomerCredit = new Map<String, Customer_Credit__c>();
                listCCC = new List<CreditCheckContacts>();
                
                conIdsWithActiveCC = new Set<Id>();
                listActiveCCCons = new List<String>();
                listSubmittedCCCons = new List<String>();

                conEmailsWithActiveCC = new Set<String>();
                listActiveCCConEmails = new List<String>();
                listSubmittedCCConEmails = new List<String>();
                emailContactIdMap = new Map<String, List<String>>(); 

                Set<Id> optyContacts = new Set<Id>(); 
                //if(proposalId == null){
				//	opportunityId = null;
                //}
                if(opportunityId != null){
                    System.debug('opportunityId: ' + opportunityId);
                    for(OpportunityContactRole opptyContactRole : [Select id, opportunity.Deal_Id__c, opportunity.Install_Partner__r.Name, IsPrimary, 
                    												opportunity.Sales_Partner__r.Name, ContactId,OpportunityId, Role from OpportunityContactRole 
																	where opportunityId =:opportunityId]){
                        if(optyContacts.contains(opptyContactRole.ContactId))
                                continue;
                        
                        optyContacts.add(opptyContactRole.ContactId);
                        listOCR.add(opptyContactRole);
                    }                               
                }

				if(opportunityId == null || listOCR == null || listOCR.isEmpty()){
                 	return;
				}

                String sqlQuery = getSelectionQuery();
                if(optyContacts != null && !optyContacts.isEmpty()){
                	sqlQuery += ' and Id in :optyContacts ';
                }
				sqlQuery += ' order by FirstName, LastName ' ;
				System.debug('sqlQuery: ' + sqlQuery);
				
                for(Contact contactObj: Database.query(sqlQuery)){
                    listContacts.add(contactObj);
                    listCon.add(contactObj);
                    contactIds.add(contactObj.Id);
                    if(contactObj.email != null && contactObj.email != ''){
                            contactEmails.add(contactObj.email);
                            List<String> contactIds = emailContactIdMap.containsKey(contactObj.email) ? emailContactIdMap.get(contactObj.email) : new List<String>();
                            contactIds.add(contactObj.Id);
                            emailContactIdMap.put(contactObj.Id, contactIds);
                    }
                }
				
				System.debug('optyContacts1: ' + optyContacts);
				String sunrunCreditStr = ProposalUtil.SUNRUN_CUSTOMER_CREDIT;
                Integer counter = 0;
                for(Customer_Credit__c cc:[select id, Contact__c, Type__c, Customer_Email__c, status__c, Date_Pulled__c, Date_Submitted__c, Sunrun_Credit_Status__c, Credit_Decision_on_Portal__c from 
                                                                        Customer_Credit__c where type__C != :sunrunCreditStr and Customer_Email__c in :contactEmails order by Date_Pulled__c desc, 
                                                                        Date_Submitted__c desc ])
                {
                        counter++;
                        
                        System.debug('cc: ' + counter + ' ' + cc);
                        if(cc.Contact__c != null && (cc.Date_Pulled__c != null && Date.Today() <= cc.Date_Pulled__c.addDays(60)))
                        {
                                conIdsWithActiveCC.add(cc.Contact__c);
                                if(cc.Customer_Email__c != null && cc.Customer_Email__c != ''){
                                        conEmailsWithActiveCC.add(cc.Customer_Email__c);
                                }
                        }
                        if(cc.Contact__c != null && (cc.Date_Submitted__c != null || (cc.Date_Pulled__c != null && Date.Today() <= cc.Date_Pulled__c.addDays(60))))
                        {
                                if(cc.Customer_Email__c != null && cc.Customer_Email__c != ''){
                                        List<String> contactIds = emailContactIdMap.get(cc.Customer_Email__c);
                                        if(contactIds != null && contactIds.size() > 0){
                                                listActiveCCCons.addAll(contactIds);                                    
                                        }
                                        listActiveCCConEmails.add(cc.Customer_Email__c);
                                }
                        }

                        //Create Submitted list
                        if(cc.Date_Submitted__c != null && (cc.Date_Pulled__c == null || cc.Date_Submitted__c > cc.Date_Pulled__c))
                        {
                                if(cc.Customer_Email__c != null && cc.Customer_Email__c != ''){
                                        List<String> contactIds = emailContactIdMap.get(cc.Customer_Email__c);
                                        if(contactIds != null && contactIds.size() > 0){
                                                listSubmittedCCCons.addAll(contactIds);                                 
                                        }                                       
                                        listSubmittedCCConEmails.add(cc.Customer_Email__c);
                                }
                        }
                        
                        if(!mapContactEmailToCustomerCredit.containsKey(cc.Customer_Email__c)){
                                mapContactToCustomerCredit.put(cc.Contact__c, cc);
                                mapContactEmailToCustomerCredit.put(cc.Customer_Email__c, cc);
                        }
                        
                }
                Set<Id> tempContactIds2 = new Set<Id>(); 
                for(Contact c:listCon){
                        if(tempContactIds2.contains(c.Id))
                                continue;
                        if(proposalId == null || (proposalId != null && optyContacts.contains(c.Id))){
                                tempContactIds2.add(c.Id);      
                                listCCC.add(new CreditCheckContacts(c, mapContactEmailToCustomerCredit, defconId, conEmailsWithActiveCC, listOCR, opportunityId));                              
                        }
                }       
        }

        public PageReference createData(Id selectedOptyId){
                //if LeaseDimensions call is successful...
                Datetime dtSubmitted = Datetime.now();
                if(selectedOptyId != null){
                        Opportunity oppUpdate = [select id, Name, Date_Credit_Pulled__c from Opportunity where id = :selectedOptyId];
                        oppUpdate.Date_Credit_Pulled__c = dtSubmitted;
                        update oppUpdate;
                }

                for(CreditCheckContacts ccc:listCCC){
                   if(String.valueOf(ccc.ContactId) == selCC){
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
					   System.debug('1: cc.deal_Id__c: ' + cc.deal_Id__c);
                       insert cc;
                       tempCCId = cc.Id;
                       System.debug('tempCCId: ' + tempCCId);
                   }
            }

                init(null);
                System.debug('listCCC: ' + listCCC);
                return null;
        }
        
        public PageReference SubmitResendEmail(){
                LeaseDimensions LD = new LeaseDimensions();
                String retval = '';
                bAddCon = false;
                for(CreditCheckContacts ccc:listCCC)
                {
                   if(String.valueOf(ccc.ContactId) == selCC)
                   {
                                if(ccc.thecon.Email == null || ccc.thecon.Email == '')
                                {
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'You must assign an email address to this contact prior to submitting the request.'));
                                        return null;
                                }
			                    
			                    if(isValidDomain(ccc.thecon.Email) == false){
									ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, SunrunErrorMessage.getErrorMessage('ERROR_000030').error_message__c));
			                       return null;
			                    }
                                                    
                                LD.dealId = ccc.DealId;
                                LD.CallResend(ccc.thecon.Id, ccc.thecon.name,ccc.thecon.Preferred_Language__c);
                                return null;
             }
                }
                return null; 
        }

        private boolean inPersonCreditCheck = false;
        public string inpersonURL {get;set;}
		
		public void validateContactInfo(Contact contactObj, Boolean inperson){
			ApexPages.getMessages().clear();
			if(contactObj == null)
				return; 
			
			Integer expirationDays = Integer.valueOf(CustomerCreditUtil.getCreditExpirationDays()) * -1;
			if(contactObj.Email == null || contactObj.Email == ''){
			   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'You must assign an email address to this contact prior to submitting a credit check.'));
			   return;
			}

            if(inperson && (isEmptyString(contactObj.MailingStreet) || isEmptyString(contactObj.MailingState) ||
            	isEmptyString(contactObj.MailingCity) || isEmptyString(contactObj.MailingPostalCode) )){
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'One or more of the contact\'s mailing address fields are empty. Please update the contact\'s mailing address prior to submitting a credit check.'));
               return;
            }


            if(isValidDomain(contactObj.Email) == false){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, SunrunErrorMessage.getErrorMessage('ERROR_000030').error_message__c));
               return;
            }                    

           if(contactObj.Credit_Received__c != null && system.today().addDays(expirationDays) < contactObj.Credit_Received__c) // still has active credit report
           {
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING , '<font color="red" weight="bold">Customer ' + contactObj.Name + ' still has an active credit report.  You may not request a new one at this time.</font>'));
               return;
           }
           if(contactObj.Credit_Submitted__c != null && contactObj.Credit_Received__c == null)
           {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING , '<font color="red" weight="bold">A Credit Report request has previously been submitted for ' + contactObj.Name + '. To resend the invitation email, please click "Resend Credit Email"</font>'));
				return;
           }   
		}
		
		
		
		public PageReference inPersonSubmitCreditCheck(){
        	inPersonCreditCheck = true;
        	PageReference pageRef = null;
    		String sunrunCreditStr = ProposalUtil.SUNRUN_CUSTOMER_CREDIT;
			
            LeaseDimensions LD = new LeaseDimensions();
            String retval = '';
            bAddCon = false;
            System.debug('opportunityId: ' + opportunityId);
            for(CreditCheckContacts ccc:listCCC)
            {
	           if(String.valueOf(ccc.ContactId) == selCC)
	           {
					validateContactInfo(ccc.thecon, true);
			        if(ApexPages.getMessages().size() > 0){
			            return null;
			        }	
			        				
					User u = [select id, email from user where id = :UserInfo.getUserId()];
					LD.dealId = ccc.DealId;
					System.debug('LD.dealId: ' + LD.dealId);
	                //createData(ccc.OpportunityId);    
	                System.debug('ccc.thecon.Account.Id: ' + ccc.thecon.Account.Id);      
	                System.debug('ccc.thecon.Id: ' + ccc.thecon.Id);            
					retval = LD.createInpersonCreditURL(ccc.thecon.FirstName, ccc.thecon.LastName, ccc.thecon.Email, ccc.thecon.Id +'', //ccc.thecon.Preferred_Language__c,
    									ccc.thecon.Phone, ccc.thecon.MailingStreet,  ccc.thecon.MailingCity,  ccc.thecon.MailingState, ccc.thecon.MailingPostalCode, 
    									 UserInfo.getFirstName(),  UserInfo.getLastName(),  ccc.thecon.Email,  LD.dealId, ccc.Installer);
	                
	                pageRef = new PageReference(retval);      
				}
			}
			
			return pageRef;
        }
        
        public PageReference SubmitCreditCheck(){
        		String sunrunCreditStr = ProposalUtil.SUNRUN_CUSTOMER_CREDIT;
				Integer expirationDays = Integer.valueOf(CustomerCreditUtil.getCreditExpirationDays()) * -1;
                LeaseDimensions LD = new LeaseDimensions();
                String retval = '';
                bAddCon = false;
                System.debug('opportunityId: ' + opportunityId);
                for(CreditCheckContacts ccc:listCCC)
                {
                   if(String.valueOf(ccc.ContactId) == selCC)
                   {
						validateContactInfo(ccc.thecon, false);
					    if(ApexPages.getMessages().size() > 0){
					        return null;
					    }   
						
					   System.Debug('Calling LeaseDimensions and our buddy Rob Hingst!');
					   User u = [select id, email from user where id = :UserInfo.getUserId()];
					   LD.dealId = ccc.DealId;
					   System.debug('LD.dealId: ' + LD.dealId);
					   retval = LD.createAndInviteHomeowner(ccc.thecon.FirstName, ccc.thecon.LastName, ccc.thecon.Email, ccc.thecon.Id, ccc.thecon.Preferred_Language__c, UserInfo.getFirstName(), UserInfo.getLastName(), u.Email, LD.dealId, ccc.Installer);
						//retval = LD.createAndInviteHomeowner(ccc.thecon.FirstName, ccc.thecon.LastName, ccc.thecon.Email, ccc.thecon.Id, UserInfo.getFirstName(), UserInfo.getLastName(), u.Email, LD.dealId, ccc.Installer);
						System.Debug('RETVAL: ' + retval);
					   if(retval == 'SUCCESS')
					   {
								ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO , 'Customer ' + ccc.ContactName + ' has been invited to complete their credit profile and authorize credit check via Lease Dimensions.'));
								return createData(ccc.OpportunityId);
					   }
					   else
					   {
					          String[] retvals = retval.split(';');
					          if(retvals != null && retvals.size() > 0){
					                String tempString = retvals[retvals.size() - 1].capitalize(); 
					                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, tempString));                              
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
                public string OpportunityId{get;set;}
                public string ContactName{get;set;}
                public string FirstName{get;set;}
                public string LastName{get;set;}
                public string ContactEmail{get;set;}
                public string ContactRole{get;set;}
                public string ContactPhone{get;set;}
                public Boolean selected{get;set;}
                public String status{get;set;}
                public DateTime DateSubmitted{get;set;}
                public DateTime DateReceived{get;set;}
                public String DealId {get;set;}
                public String Installer {get;set;}
                public String PreferredLanguage{get;set;}

                public String Street{get;set;}
                public String City{get;set;}
                public String State{get;set;}
                public String Zip{get;set;}
				
				public String DateSubmitted2{get;set;}
                public String DateReceived2{get;set;}
                
                public Contact thecon{get;set;}
                public Boolean bActiveCCExists{get;set;}  
            public Boolean bRecentlySubmittedCCExists{get;set;}
                public CreditCheckContacts(Contact c, Map<String, Customer_Credit__c> mapContactEmailToCustomerCredit,
                                                                        String DefCon, Set<String> conEmailsWithActiveCC,
                                                                        List<OpportunityContactRole> lstOCR, Id opportunityId){
                        this.ContactId = c.Id;
                        this.ContactName = c.Name;
                        this.FirstName = c.FirstName;
                        this.LastName = c.LastName;
                        this.ContactEmail = c.Email;
                        this.ContactPhone = c.Phone;
                        this.PreferredLanguage = c.Preferred_Language__c;
                        
                        this.Street = c.Account.BillingStreet;
                        this.City = c.Account.BillingCity;
                        this.State = c.Account.BillingState;
                        this.Zip = c.Account.BillingPostalCode;
                        
                        this.ContactRole = 'Not Associated to Oppty';
                        this.thecon = c; 
                        if(conEmailsWithActiveCC.Contains(c.email))
                        {
                                this.bActiveCCExists = true;
                        }
                        else
                        {
                                this.bActiveCCExists = false;
                        }
                        //
                        if(mapContactEmailToCustomerCredit.containsKey(c.email))
                        {
                                Customer_Credit__c ccObj = mapContactEmailToCustomerCredit.get(c.email);
                                if(ccObj != null && (ccObj.type__c != 'Sunrun' || (ccObj.type__c == 'Sunrun' && ccObj.Contact__c == c.Id))){
                                
	                                this.Id = ccObj.Id;
	                                if(ccObj.Date_Submitted__c != null && (ccObj.Date_Pulled__c == null || ccObj.Date_Submitted__c > ccObj.Date_Pulled__c))
	                                {
	                                        this.bRecentlySubmittedCCExists = true;
	                                }
	                                
	                                if(ccObj.Date_Submitted__c != null){
	                                        this.DateSubmitted = ccObj.Date_Submitted__c;
	                                        if(ccObj.Date_Submitted__c != null){
	                                                this.DateSubmitted2 = ccObj.Date_Submitted__c.month() + '/' + ccObj.Date_Submitted__c.day() + '/' + ccObj.Date_Submitted__c.year();
	                                        }
	                                        
	                                }
									if(ccObj.Date_Pulled__c != null){
	                                        this.DateReceived = ccObj.Date_Pulled__c;
	                                        if(ccObj.Date_Pulled__c != null){
	                                                this.DateReceived2 = ccObj.Date_Pulled__c.month() + '/' + ccObj.Date_Pulled__c.day() + '/' + ccObj.Date_Pulled__c.year();
	                                        }
									}
									this.status = ccObj.Credit_Decision_on_Portal__c;

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
                                   this.OpportunityId = ocr.OpportunityId;
                                   this.DealId = ocr.opportunity.Deal_Id__c;
                                   if(ocr.opportunity.Sales_Partner__r.Name == 'Sungevity' || ocr.opportunity.Install_Partner__r.Name == 'Sungevity'){
										this.Installer = 'Sungevity';
                                   }else{
                                   		this.Installer = '';
                                   }
                                   System.debug('this.DealId: ' + this.DealId);
                                }
                        }
                        
                        if(opportunityId != null)
                        {
							this.OpportunityId = opportunityId;
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
        }

}