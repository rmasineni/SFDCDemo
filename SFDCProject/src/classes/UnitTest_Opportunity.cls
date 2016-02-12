@isTest(SeeAllData=true)
public class UnitTest_Opportunity {
	
	/*
	static  testmethod void testContacts(){
		//Account accountObj1 = TestPRMLibrary.insertAccount('ResidentialAccount-1', 'Residential');
		//Platinum
		List<String> sObjectTypes = new List<String>();
		sObjectTypes.add('Account');
		Map<Id, RecordType> recordTypesMap = EDPUtil.getRecordTypes(sObjectTypes);
		
		Opportunity optyObj1 = TestPRMLibrary.insertOpportunity('ResidentialAccount-1', 'Residential',
																'ResOpty-1', 'Platinum');
		Account account = new Account();
		account.Name = 'ResidentialAccount-2';
		Id recordTypeId = TestPRMLibrary.getRecordTypeId('Residential', 'Account');
		account.RecordTypeId = recordTypeId;
		insert account;
		
		Opportunity oppotyObj = new Opportunity();
		oppotyObj.AccountId = account.Id;
		oppotyObj.name = 'ResOpty-2';
		oppotyObj.CloseDate = date.today().addDays(3);
		oppotyObj.StageName = 'Closed/Won';
		Id optyRecordTypeId = TestPRMLibrary.getRecordTypeId('Platinum', 'Opportunity');
		
		try{
			insert oppotyObj;
		}catch(Exception e){
			System.debug(e.getmessage());
		}
		
		optyObj1.StageName = 'Closed/Won';
		try{
			update optyObj1;
		}catch(Exception e){
			System.debug(e.getmessage());
		}
		
		optyObj1.StageName = 'Assigned';
		optyObj1.Credit_Status__c = 'Approved';
		optyObj1.CloseDate = date.today().addDays(10);
		update optyObj1;

		Proposal__C proposalObj = new Proposal__C();
		proposalObj.Name = 'Proposal-1';
		proposalObj.Opportunity__c = optyObj1.Id;
		proposalObj.Upfront_Payment__c = 1000;
		proposalObj.Proposal_ID__c = 2441242;
		proposalObj.System_Size_STC_DC__c = 1;
		proposalObj.Mode_Name__c = 'Mode-1';
		proposalObj.Date_Issued__c =  date.today();
		proposalObj.Sales_Rep_Email__c = 'test@gmail.com';		
		insert proposalObj;
		
		proposalObj.Stage__c = EDPUtil.SR_OPS_APPROVED;
		update proposalObj;

		optyObj1.StageName = 'Closed/Won';
		optyObj1.CloseDate = date.today();
		try{
			update optyObj1;
		}catch(Exception e){
			
		}

		optyObj1.StageName = 'Closed/Lost';
		optyObj1.CloseDate = date.today();
		update optyObj1;		

		proposalObj.Stage__c = EDPUtil.SR_OPS_REVIEWED;
		update proposalObj;		

		proposalObj.Stage__c = EDPUtil.CREDIT_APPROVED;
		update proposalObj;		

		proposalObj.Stage__c = EDPUtil.SR_OPS_APPROVED;
		proposalObj.Partner_Guaranteed_Rebate__c = true;
		
		try{
			update proposalObj;	
		}catch(Exception e){
			
		}

		proposalObj.Stage__c = EDPUtil.SR_OPS_REVIEWED;
		proposalObj.Partner_Guaranteed_Rebate__c = true;
		
		try{
			update proposalObj;	
		}catch(Exception e){
			
		}

		Proposal__C proposalObj2 = new Proposal__C();
		proposalObj2.Name = 'Proposal-2';
		proposalObj2.Opportunity__c = optyObj1.Id;
		proposalObj2.Upfront_Payment__c = 1000;
		proposalObj2.Proposal_ID__c = 2441242;
		proposalObj2.System_Size_STC_DC__c = 1;
		proposalObj2.Mode_Name__c = 'Mode-1';
		proposalObj2.Date_Issued__c =  date.today();
		proposalObj2.Sales_Rep_Email__c = 'test@gmail.com';	
		proposalObj2.Stage__c = 'Created';	
		insert proposalObj2;
		
		proposalObj2.Stage__c = EDPUtil.SUBMITTED;
		proposalObj2.Partner_Guaranteed_Rebate__c = false;
		proposalObj2.Change_Order__c = true;
		proposalObj2.Original_Proposal_ID__c  = proposalObj.Id;
		proposalObj2.Electronically_Signed_Document__c  = false;
		update proposalObj2;

		proposalObj2.Electronically_Signed_Document__c  = true;
		proposalObj2.Change_Order_Type__c = EDPUtil.FINAL_INPUTS_HYBRID_ID;
		proposalObj2.Change_Order_ID__c = null;
		
		try{
			update proposalObj2;	
		}catch(Exception e){
			
		}

		proposalObj2.Electronically_Signed_Document__c  = true;
		proposalObj2.Change_Order_Type__c = EDPUtil.FINAL_INPUTS_HYBRID_ID;
		proposalObj2.Change_Order_ID__c = proposalObj.Id;	
		update proposalObj2;	

		proposalObj2.Product_ID__c = 'F';
		update proposalObj2;	
		
		proposalObj2.Stage__c = 'Created';
		update proposalObj2;	

		
		proposalObj2.Stage__c = EDPUtil.SUBMITTED;
		try{
			update proposalObj2;	
		}catch(Exception e){
			
		}
		
		proposalObj.Stage__c = 'Pending';
		proposalObj.Pending_Proposal_Reason__c = null;
		try{
			update proposalObj;	
		}catch(Exception e){
			
		}

		proposalObj.Stage__c = 'Pending';
		proposalObj.Pending_Proposal_Reason__c = 'Missing Pages';
		update proposalObj;	

		proposalObj.Stage__c = 'Submitted';
		proposalObj.Pending_Proposal_Reason__c = 'Missing Pages';
		update proposalObj;	

	}
	*/

	static  testmethod void testProposalRelatedList(){
		Opportunity optyObj1 = TestPRMLibrary.insertOpportunity('ResidentialAccount-3', 'Residential',
																'ResOpty-3', 'Platinum');	
		List<Proposal__C> proposalList = new List<Proposal__C>();
		Proposal__C proposalObj1 = new Proposal__C();
		proposalObj1.Name = 'Proposal-1';
		proposalObj1.Opportunity__c = optyObj1.Id;
		proposalObj1.Upfront_Payment__c = 1000;
		proposalObj1.Proposal_ID__c = 2441242;
		proposalObj1.System_Size_STC_DC__c = 1;
		proposalObj1.Mode_Name__c = 'Mode-1';
		proposalObj1.Date_Issued__c =  date.today();
		proposalObj1.Sales_Rep_Email__c = 'test@gmail.com';
		proposalList.add(proposalObj1);

		Proposal__C proposalObj2 = new Proposal__C();
		proposalObj2.Name = 'Proposal-2';
		proposalObj2.Opportunity__c = optyObj1.Id;
		proposalObj2.Upfront_Payment__c = 1000;
		proposalObj2.Proposal_ID__c = 2441232;
		proposalObj2.System_Size_STC_DC__c = 1;
		proposalObj2.Mode_Name__c = 'Mode-2';
		proposalObj2.Date_Issued__c =  date.today();
		proposalObj2.Sales_Rep_Email__c = 'test2@gmail.com';
		proposalObj2.Change_Order_With_New_Proposal__c = true;
		proposalList.add(proposalObj2);		
		insert proposalList;

		Set<String> proposalNmaes = new Set<String>();
		proposalNmaes.add('Proposal-1');
		proposalNmaes.add('Proposal-2');
		Map<String, Proposal__C> proposalMap = ProposalUtil.getProposalMapByName(proposalNmaes);

		System.currentPagereference().getParameters().put('PageSize', '3');
		ProposalRelatedListController proposalRelController = new ProposalRelatedListController();
		
		proposalRelController.ssc = null;
		proposalRelController.opprotunityObj = optyObj1;
		proposalRelController.initializeOpportunityInfo();
		proposalRelController.initializeProposalList();

		List<ProposalRelatedListController.ProposalWrapper> proposalwrapperlist = proposalRelController.getProposalsWrapperList();
		proposalRelController.getIsPortalUser();

		proposalRelController.opprotunityObj = null;
		proposalRelController.oppotunityId = null;
		proposalRelController.ssc = null;
		
		/*
		//String userName = label.SR_Operations_User;
		String userName = label.SR_Operations_User;
		User userObj = [Select Id, name from User where name =:userName];
		System.runas(userObj){
			proposalRelController.initializeOpportunityInfo();
			proposalRelController.initializeProposalList();
		}

		proposalRelController.opprotunityObj = null;
		proposalRelController.oppotunityId = null;
		proposalRelController.ssc = null;
		
		userName = label.SR_Finance_User;
		userObj = [Select Id, name from User where name =:userName];
		System.runas(userObj){
			proposalRelController.initializeOpportunityInfo();
			proposalRelController.initializeProposalList();
		}
		*/
		
	}

	static  testmethod void testSearchCreditReports(){

		Contact contactObj1 = TestPRMLibrary.insertContact('PRMTestAccount1', 
											PRMLibrary.PARTNER, 
											'PRMTestLastName1',
											'prmcontact1@sunrun.com');

		Contact contactObj2 = TestPRMLibrary.insertContact('PRMTestAccount2', 
											PRMLibrary.PARTNER, 
											'PRMTestLastName2',
											'prmcontact2@sunrun.com');

											
		Partner_Location__c partnerLocation = new Partner_Location__c();	
		partnerLocation.Account__c = contactObj1.AccountId;
		partnerLocation.Headquarters__c = true;
		insert partnerLocation;
		
		contactObj1.Location__c = partnerLocation.Id;
		update contactObj1;

		List<Profile> profiles = [Select Id , name from Profile where name like '%Gold Partner User%'];
		
		User newUserObj = new User();
		newUserObj.ProfileId = profiles[0].Id;
		newUserObj.FirstName = contactObj1.firstname;
		newUserObj.LastName = contactObj1.lastname;
		newUserObj.Email = contactObj1.email;
		newUserObj.title = 'title1';
		newUserObj.Username = contactObj1.email;
		newUserObj.contactId = contactObj1.id;
		newUserObj.TimeZoneSidKey = 'America/Los_Angeles';
		newUserObj.EmailEncodingKey = 'ISO-8859-1';
		newUserObj.LocaleSidkey = 'en_US';
		newUserObj.LanguageLocaleKey = 'en_US';
		newUserObj.alias = 'abxz';
		newUserObj.CommunityNickname = 'prmtest1';
		insert 	newUserObj;

		Opportunity optyObj1 = TestPRMLibrary.insertOpportunity('ResidentialAccount-4', 'Residential',
																'ResOpty-4', 'Platinum');
		
		List<OpportunityContactRole> contactRolelist = new List<OpportunityContactRole>();
		OpportunityContactRole contactRoleObj = new OpportunityContactRole();
		contactRoleObj.ContactId = contactObj2.Id;
		contactRoleObj.OpportunityId = optyObj1.Id;
		contactRoleObj.Role = 'Other';
		contactRoleObj.IsPrimary = true;
		contactRolelist.add(contactRoleObj);	  

		contactRoleObj = new OpportunityContactRole();
		contactRoleObj.ContactId = contactObj1.Id;
		contactRoleObj.OpportunityId = optyObj1.Id;
		contactRoleObj.Role = 'Other';
		contactRoleObj.IsPrimary = true;
		contactRolelist.add(contactRoleObj);
		insert 	contactRolelist;			
																
        Id contactRecordTypeId = TestPRMLibrary.getRecordTypeId('Residential', 'Contact');
        Contact contact = new Contact();
        contact.FirstName = 'FirstName-1';
        contact.LastName = 'LastName-1';
        contact.AccountId = optyObj1.AccountId;
        contact.RecordTypeId = contactRecordTypeId;
        contact.email = 'test4@gmail.com';
        insert contact; 

		List<Proposal__C> proposalList = new List<Proposal__C>();
		Proposal__C proposalObj1 = new Proposal__C();
		proposalObj1.Name = 'Proposal-1';
		proposalObj1.Opportunity__c = optyObj1.Id;
		proposalObj1.Upfront_Payment__c = 1000;
		proposalObj1.Proposal_ID__c = 2441242;
		proposalObj1.System_Size_STC_DC__c = 1;
		proposalObj1.Mode_Name__c = 'Mode-1';
		proposalObj1.Date_Issued__c =  date.today();
		proposalObj1.Sales_Partner__c = contactObj1.AccountId;
		proposalObj1.Install_Partner__c = contactObj1.AccountId;
		proposalObj1.Sales_Rep_Email__c = 'prmcontact1@sunrun.com';
		//proposalList.add(proposalObj1);
		insert proposalObj1;
		
		Set<Id> opportunityIds = new Set<Id>();
		opportunityIds.add(optyObj1.id);
		Map<Id, Opportunity> optyMap = EDPUtil.getOppsWithProposals(opportunityIds);
		
		Customer_Credit__c customerCreditObj = new Customer_Credit__c();
		customerCreditObj.Contact__c = contact.Id;
		customerCreditObj.First_Name__c = 'FirstName1';
		customerCreditObj.Last_Name__c = 'Lastname1';
		customerCreditObj.City__c = 'TestCity';
		customerCreditObj.Street__c = 'TestStreet';
		customerCreditObj.state__c = 'CA';
		customerCreditObj.Country__c = 'USA';
		customerCreditObj.Zip__c = '93456';
		customerCreditObj.Customer_Email__c = 'testCustomer1@gmail.com';	
		customerCreditObj.Pending_Reason__c	 = 'Test Pending Reason';
		insert customerCreditObj;
		
		Set<Id> customerCreditIds = new Set<Id>();
		customerCreditIds.add(customerCreditObj.Id);
		ProposalUtil.resetCustomerCreditPendingComments(customerCreditIds);
		
		SearchCreditReports searchCreditReportsObj = new SearchCreditReports();
		searchCreditReportsObj.proposalObj = proposalObj1;
		searchCreditReportsObj.creditReportObj = customerCreditObj;
		searchCreditReportsObj.initializeProposal();
		searchCreditReportsObj.getCreditReportList();
		searchCreditReportsObj.NewCreditReport();
	
		Boolean hasPrevious = searchCreditReportsObj.hasPrevious;
		Integer pageNumber = searchCreditReportsObj.pageNumber;
		searchCreditReportsObj.first();
		searchCreditReportsObj.last();
		searchCreditReportsObj.previous();
		searchCreditReportsObj.next();
		Boolean hasNext = searchCreditReportsObj.hasNext;

		searchCreditReportsObj.CancelSearch();
		searchCreditReportsObj.applySearchFilter();
		
		searchCreditReportsObj.con = null;
		customerCreditObj.State__c = 'VA';
		searchCreditReportsObj.creditReportObj = customerCreditObj;
		searchCreditReportsObj.getCreditReportList();
		
		searchCreditReportsObj.getProposalObj();
		searchCreditReportsObj.getCreditReportObj();
	}

}