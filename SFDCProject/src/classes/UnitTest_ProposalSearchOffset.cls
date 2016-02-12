@ isTest
public class UnitTest_ProposalSearchOffset {
	public static void insertSettings() {
    	insert new Settings__c(Name='ProposalsDisplayed', Value1__c='1000');
	}
	
	public static void insertContact(Id userId) {	    	
    	Date edpGoLiveDate = Date.today().adddays(-500);
		Account testPartner = new Account(name='TestPartner', EDP_Go_Live_Date__c=edpGoLiveDate, partner_type__c='Full Service');
		insert testPartner;
		
		userId = (userId == null) ? UserInfo.getUserId() : userId;
		RecordType empRecordTypeObj = PRMLibrary.getEmployeeContactRecordType();
		Contact contactObj = new Contact(AccountId=testPartner.Id,Sunrun_User__c=userId, 	Contact_Type__c='Partner',
										RecordTypeId=empRecordTypeObj.Id, Division__c = 'Inside Sales',
										LastName='LSunrun', Firstname='FSunrun', email='testemail1@partnersunrun.com',
										Ultimate_Parent_Account__c=testPartner.Id);
		insert contactObj;
	}

	public static void insertProposals() {

 		Account customerAccount;
        Contact primaryContact;
        Contact secondaryContact;
        Opportunity opprtunityObj;
        
		String salesRepEmail = 'testemail1@partnersunrun.com';
		Opportunity optyObj1 = TestPRMLibrary.insertOpportunity('ResidentialAccount-02', 'Residential',
                                                                'ResOpty-02', 'Platinum');  
        List<Proposal__C> proposalList = new List<Proposal__C>();
        Proposal__C proposalObj1 = UnitTest_ProposalUtil.createProposal('1524 Fremont St CA', 'PFirstName12', 'PLastName12', 
                                            'PrimaryCustomer1@gmail.com', '1524 Fremont St CA','P224123423-I', 
                                            23532, 10, 'Mode-1', salesRepEmail, null, null,
                                            customerAccount, primaryContact, secondaryContact, opprtunityObj);
		proposalObj1.stage__c = 'Created';
		proposalList.add(proposalObj1);

        Proposal__C proposalObj2 = UnitTest_ProposalUtil.createProposal('1525 Fremont St CA', 'PFirstName2', 'PLastName2', 
                                            'PrimaryCustomer2@gmail.com', '1525 Fremont St CA','P224123426-I', 
                                            33532, 10, 'Mode-1', salesRepEmail, null, null,
                                            customerAccount, primaryContact, secondaryContact, opprtunityObj);
		proposalObj2.stage__c = EDPUtil.SR_OPS_APPROVED;
		proposalList.add(proposalObj2);

        Proposal__C proposalObj3 = UnitTest_ProposalUtil.createProposal('1526 Fremont St CA', 'PFirstName3', 'PLastName3', 
                                            'PrimaryCustomer2@gmail.com', '1526 Fremont St CA','P224124127-I', 
                                            43532, 10, 'Mode-1', salesRepEmail, null, null,
                                            customerAccount, primaryContact, secondaryContact, opprtunityObj);
		proposalObj3.stage__c = EDPUtil.SR_OPS_RECEIVED;
		proposalList.add(proposalObj3);		
		
		
		insert proposalList;
		System.debug('Inserted Proposals: ' + proposalList);
	}                                         

	public static testmethod void testContactExceptions(){
		insertSettings();
        List<Proposal__c> propList = [select Id,Proposal_Name__c,Original_Proposal_ID__c,Agreement_Type__c,LastModifiedDate,Homeowner_Name__c,Customer_Address__c from Proposal__c order by lastmodifieddate desc limit 10];      
        ApexPages.StandardSetController con = new ApexPages.standardSetController(propList);
        ApexPages.Message[] msgrep = ApexPages.getMessages();
        ProposalSearchOffset propsearch  = new ProposalSearchOffset();
        Test.startTest();
        	propsearch.getProposalsForSelectedView();
        	propsearch.searchValue ='1';
			propsearch.doSearch();
        Test.stoptest();
	}    
	
	public static testmethod void ProposalSearchOffset_Test(){
		insertSettings();
		insertContact(null);
		insertProposals();
		
		List<Proposal__c> propList = [select Id,Proposal_Name__c,Original_Proposal_ID__c,Agreement_Type__c,LastModifiedDate,Homeowner_Name__c,Customer_Address__c from Proposal__c order by lastmodifieddate desc limit 10];      
        System.debug('Selected Proposals: ' + propList);
        ApexPages.StandardSetController con = new ApexPages.standardSetController(propList);
        ApexPages.Message[] msgrep = ApexPages.getMessages();
        ProposalSearchOffset propsearch  = new ProposalSearchOffset();
        Test.startTest();
        propsearch.getProposalsForSelectedView();
        propsearch.searchColumnName = 'propsId';
        propsearch.searchValue ='namevalue';
        propsearch.doSearch();
        
        propsearch.searchColumnName = 'name';
        propsearch.searchValue = 'namevalue';
        propsearch.doSearch();
        
        propsearch.searchColumnName = 'addr';
        propsearch.searchValue = 'namevalue';
        propsearch.doSearch();
        
        propsearch.searchColumnName = 'stage';
        propsearch.searchValue ='namevalue';
        propsearch.doSearch();
        
        propsearch.searchColumnName = 'SalesRep';
        propsearch.searchValue = 'namevalue';
        propsearch.doSearch();
        
        propsearch.searchValue = null;
        propsearch.doSearch();
        
        propsearch.viewName = 'myprops';
        propsearch.searchValue = 'viewvalue';
        propsearch.getViews();
        
        propsearch.viewName = 'CreadBySprops';
        propsearch.getViews();
        propsearch.getProposalsForSelectedView();
        
        propsearch.getProposalsForSelectedView();
        propsearch.viewName = 'Props1Month';
        propsearch.getViews();
        
        propsearch.getProposalsForSelectedView();
        propsearch.viewName ='Props7days';
        propsearch.getViews();
        
        propsearch.viewName ='Props14days';
        propsearch.getViews();
        propsearch.getProposalsForSelectedView();
        
        propsearch.getSearchBy();
        propsearch.clearSearchValue();
        propsearch.userActions();
        propsearch.first();
        propsearch.Next();
        propsearch.previous();
        propsearch.last();
        propsearch.getHasNext();
        propsearch.getHasPrevious();
        propsearch.getTotal_size();
        propsearch.getPageNumber();
        propsearch.getTotalPages();
        propsearch.getProposals();
        Test.stopTest();
    }

	public static testmethod void ProposalSearchPropslMonth_Test(){
		insertSettings();
		insertContact(null);
		insertProposals();
		
		List<Proposal__c> propList = [select Id,Proposal_Name__c,Original_Proposal_ID__c,Agreement_Type__c,LastModifiedDate,Homeowner_Name__c,Customer_Address__c from Proposal__c order by lastmodifieddate desc limit 10];      
        ApexPages.StandardSetController con = new ApexPages.standardSetController(propList);
        ApexPages.Message[] msgrep = ApexPages.getMessages();
        ProposalSearchOffset propsearch  = new ProposalSearchOffset();
        Test.startTest();
        	propsearch.viewName = 'Props1Month';
	        propsearch.getProposalsForSelectedView();
	        propsearch.searchColumnName = 'propsId';
	        propsearch.searchValue ='viewvalue';
	        propsearch.doSearch();
        Test.stopTest();
    }


	public static testmethod void ProposalSearchProps7days_Test(){
		insertSettings();
		insertContact(null);
		insertProposals();
		
		List<Proposal__c> propList = [select Id,Proposal_Name__c,Original_Proposal_ID__c,Agreement_Type__c,LastModifiedDate,Homeowner_Name__c,Customer_Address__c from Proposal__c order by lastmodifieddate desc limit 10];      
        ApexPages.StandardSetController con = new ApexPages.standardSetController(propList);
        ApexPages.Message[] msgrep = ApexPages.getMessages();
        ProposalSearchOffset propsearch  = new ProposalSearchOffset();
		Test.startTest();
			propsearch.viewName = 'Props7days';
	        propsearch.getProposalsForSelectedView();
	        propsearch.searchColumnName = 'propsId';
	        propsearch.searchValue ='viewvalue';
	        propsearch.doSearch();
	        
	        propsearch.viewName = '';
	        ApexPages.StandardSetController con2 = propsearch.createSQOLConnection();
		Test.stopTest();
    }
}