@isTest(SeeAllData=true)
public class UnitTest_SCMilestoneProof {

 	public static testMethod void milestoneProofTestCaseTrigger2()
    {
        Test.startTest();
        ServiceContractMilestoneProof testMileStoneProof = new ServiceContractMilestoneProof();
 
        Account accountRec = new Account();
        accountRec.Name = 'Test Class';
        insert accountRec;
 
        Contact contactRec = new Contact();
        contactRec.FirstName = 'DSG';
        contactRec.LastName = 'Test';
        contactRec.AccountId = accountRec.Id;
        insert contactRec;

        ServiceContract scAssetRec = new ServiceContract();
        scAssetRec.accountId = accountRec.Id;
        scAssetRec.contactId = contactRec.Id;
        //scAssetRec.Home_Address__c = 'Test Class';
        //scAssetRec.City__c = 'Los Gatos';
       // scAssetRec.Zip__c = '95032';
       // scAssetRec.Asset_Status__c = 'Plans Approved, Awaiting NTP';
       // scAssetRec.Facility_Design_Approved__c = date.today();
      //  scAssetRec.NTP_Granted__c = date.today();
       // scAssetRec.Rebate_Conf_Num__c = '12345';
		
		//scAssetRec.SR_Signoff__c = date.today();
       // scAssetRec.Facility_Design_Approved__c = date.today();
      //  scAssetRec.Complete_Deal_Received__c = date.today();
      //  scAssetRec.Initial_Deposit_Processed__c = date.today();
       // scAssetRec.Initial_Deposit_Amount_Received__c = 10000;
       // scAssetRec.Initial_Deposit_Amount__c = 10000;
      //  scAssetRec.Rebate_Conf_Rec_d__c  = date.today();
       // scAssetRec.Final_Rebate_Amount__c = 100.00;
        
        insert scAssetRec;

        RecordType mileStoneRecType = testMileStoneProof.mileStoneRecType;

        Case currentCaseRec3 = new Case();
        currentCaseRec3.RecordTypeId = mileStoneRecType.Id;
        currentCaseRec3.AccountId = accountRec.Id;
        currentCaseRec3.ContactId = contactRec.Id;
        currentCaseRec3.Milestone_Proof_Type__c = 'M3 Proof';
        currentCaseRec3.Status = 'Request Approval';
        currentCaseRec3.Origin = 'Install Partner'; 
        currentCaseRec3.Reason = 'Documentation';
        currentCaseRec3.Description = 'Milestone Proof Submitted';
        currentCaseRec3.Subject = 'Milestone Proof Submitted';
        currentCaseRec3.Service_Contract__c = scAssetRec.Id;
        insert currentCaseRec3;

        currentCaseRec3.Status = 'M3 PTO Denied';
        currentCaseRec3.Denied_Comment__c = 'Test';
        update currentCaseRec3;
        
        currentCaseRec3.Status = 'M3 PTO Approved';
        //update currentCaseRec3;
 
        delete currentCaseRec3;
        Test.stopTest();
        
    }
	
	public static testMethod void serviceContractMilestoneProofTest(){
		
		Test_Partner_User__c testPartnerUserObj = UnitTest_ServiceContractUtil.getBlackBirdSalesRep();
		User u = [Select Id from User where ContactID != NULL and IsActive = true and Id =:testPartnerUserObj.User_Id__c  limit 1];
		ServiceContract scObj;
		Service_Contract_Event__c scEventObj;
		String custRefNum = '';
		String acctName = '';
		String custMailAddress = '';
		System.runAs(u) {  
			Test.startTest();
        		UnitTest_ServiceContractUtil.createServiceContractData();
        		scObj = UnitTest_ServiceContractUtil.scObj;
				scEventObj = UnitTest_ServiceContractUtil.scEventObj;
				System.currentPagereference().getParameters().put('id', scEventObj.Id);
				custRefNum = scObj.Cust_Ref_Num__c;
				acctName = scObj.Customer_Name__c;
				custMailAddress = scObj.Customer_Mailing_Address__c;
         	Test.stopTest();
         	System.debug('custMailAddress: ' + custMailAddress);
         	
			ServiceContractMilestoneProof scMileStoneProof = new ServiceContractMilestoneProof();
			scMileStoneProof.srchOptionFilter = 'Show Service Contracts Needing M1';
			scMileStoneProof.doSearch();
			String m1 = scMileStoneProof.proofTypeM1;
			String caseStatusM1Approved = scMileStoneProof.caseStatusM1Approved;
			String  deniedStatusValue = scMileStoneProof.deniedStatusValue;
			String  pendingStatusValue = scMileStoneProof.pendingStatusValue;
			scMileStoneProof.approvedStatusValue = 'Aproved';
			String approvedValue = scMileStoneProof.approvedStatusValue;
			scMileStoneProof.isPTOSaved = false;
			
			PageReference prCG = scMileStoneProof.validateConfigurationFromProofType();
			
			Attachment attachmentFile = scMileStoneProof.attachmentFile;
			
			scMileStoneProof.srchOptionFilter = 'Show Service Contracts Needing M2';
			String caseStatusM2Approved = scMileStoneProof.caseStatusM2Approved;
			String proofTypeM2 = scMileStoneProof.proofTypeM2;
			Boolean isM2Proof = scMileStoneProof.isM2Proof;

			scMileStoneProof.doSearch();
			scMileStoneProof.srchOptionFilter = 'Show Service Contracts Needing M3';
			scMileStoneProof.doSearch();
			Boolean isM3Proof = scMileStoneProof.isM3Proof;
			String caseStatusM3Approved = scMileStoneProof.caseStatusM3Approved;
			String  proofTypeM3 = scMileStoneProof.proofTypeM3;

			scMileStoneProof.srchOptionFilter = 'Show Service Contracts with ANY Proofs';
			scMileStoneProof.doSearch();

			scMileStoneProof.srchOptionFilter = 'Show Service Contracts with ALL Proofs Submitted';
			scMileStoneProof.doSearch();

			scMileStoneProof.srchOptionFilter =  'Show All Denied Proofs';
			scMileStoneProof.doSearch();
		
			scMileStoneProof.srchOptionFilter = '';
			scMileStoneProof.custRefNum = custRefNum;
			scMileStoneProof.acctName = acctName;
			scMileStoneProof.custMailAddress = custMailAddress;
			scMileStoneProof.doSearch();
			
			scMileStoneProof.backToSearch();
			List<ServiceContractMilestoneProof.ServiceContractWrapper> searchAssets = scMileStoneProof.getSearchedAssetsList();
			if(searchAssets != null && !searchAssets.isEmpty()){
				searchAssets[0].recSelected = true;
			}
			
			//GetSelectedAsset();
			scMileStoneProof.initializeServiceContractInfo(scObj.Id);

			Set<Id> proposalIds = NEW Set<Id>();
			proposalIds.add(scObj.proposal__c);
			List<Proposal__c> proposals = ServiceContractMilestoneProof.getServiceContract(proposalIds);
			scMileStoneProof.userActions();
			scMileStoneProof.getIsPartnerUser();
			scMileStoneProof.enableAttachFile = true;
			scMileStoneProof.enableSlNoUpload = true;
			scMileStoneProof.backToUpload();
			scMileStoneProof.assetNextBtnClick();
			scMileStoneProof.assetPreviousBtnClick();
			scMileStoneProof.getpagedAssetList();
			scMileStoneProof.getassetTotalPageNumber();
			scMileStoneProof.getAssetNextButtonDisabled();
			scMileStoneProof.getAssetPreviousButtonEnabled();
			scMileStoneProof.getAssetPageNumber();
			scMileStoneProof.doAssetSort();
			scMileStoneProof.getAttachments();
			scMileStoneProof.GetSelectedAsset();
			scMileStoneProof.updateAssetRec();
			scMileStoneProof.milestoneProofType = 'M1 Proof';
			scMileStoneProof.savePTO();
			
			scMileStoneProof.milestoneProofType = 'M1 Proof';
			scMileStoneProof.attachFile();
			scMileStoneProof.uploadPhotos();

			scMileStoneProof.custRefNum = custRefNum;
			scMileStoneProof.acctName = acctName;
			scMileStoneProof.custMailAddress = custMailAddress;
			scMileStoneProof.doSearch();

			String currentAssetId = '';
			if(searchAssets != null && !searchAssets.isEmpty()){
				searchAssets[0].recSelected = true;
			}
			scMileStoneProof.uploadPhotos();			

			System.debug('searchAssets: ' + searchAssets);
			if(searchAssets != null && !searchAssets.isEmpty()){
				searchAssets[0].recSelected = true;
			}
			scMileStoneProof.showAlbum();
			
			scMileStoneProof.getGenAssetId();
			scMileStoneProof.uploadDocument();
			scMileStoneProof.getCaseList();
			
			
			scMileStoneProof.doSearchCase();
			scMileStoneProof.getproofType();
			scMileStoneProof.getSearchOption();
			scMileStoneProof.getselServiceContractRec();
			scMileStoneProof.getSCEventObj();
			scMileStoneProof.getMeterAssetObj();
			scMileStoneProof.getSrchServiceContractRec();
			scMileStoneProof.submitSerialNumber();
			
			ServiceContractMilestoneProof newSCMilestoneProofObj = new ServiceContractMilestoneProof(scObj.Id);	
			
			
			String urlStr = scMileStoneProof.serverURL;
			scMileStoneProof.UpdateNumberOfPreBoughtPanels();
			scMileStoneProof.OnlyUpdatePanelCount();
			Boolean verango = scMileStoneProof.isPartnerVerengo;
			scMileStoneProof.isM2Proof = true;
			Boolean enableAttach = scMileStoneProof.enableAttachFile;
			
			String proofTypeM1 = scMileStoneProof.proofTypeM1;
			scMileStoneProof.milestoneProofType = proofTypeM1;
			scMileStoneProof.updateAssetRec();
		}
    }
    
    /*
    public static testMethod void serviceContractMilestoneProofTest()
    {
		
		Test_Partner_User__c testPartnerUserObj = UnitTest_ServiceContractUtil.getBlackBirdSalesRep();
		System.debug('testPartnerUserObj : ' + testPartnerUserObj);
		User u = [Select Id from User where ContactID != NULL and IsActive = true and Id =:testPartnerUserObj.User_Id__c  limit 1];
		ServiceContract scObj;
		Service_Contract_Event__c scEventObj;
		System.runAs(u) {  
			Test.startTest();
        		UnitTest_ServiceContractUtil.createServiceContractData();
        		scObj = UnitTest_ServiceContractUtil.scObj;
				scEventObj = UnitTest_ServiceContractUtil.scEventObj;
         	Test.stopTest();
 
	        ServiceContractMilestoneProof testMileStoneProof = new ServiceContractMilestoneProof();
	        Boolean isPTOSaved = testMileStoneProof.isPTOSaved;
	        String approvedStatusValue  = testMileStoneProof.approvedStatusValue;
	        String pendingStatusValue = testMileStoneProof.pendingStatusValue;
	        String deniedStatusValue = testMileStoneProof.deniedStatusValue;
	        String proofTypeM1 = testMileStoneProof.proofTypeM1;
	        String proofTypeM2 = testMileStoneProof.proofTypeM2;
	        String proofTypeM3 = testMileStoneProof.proofTypeM3;
	        String caseStatusM1Approved = testMileStoneProof.caseStatusM1Approved;
	        String caseStatusM2Approved = testMileStoneProof.caseStatusM2Approved;
	        String caseStatusM3Approved = testMileStoneProof.caseStatusM3Approved;
			testMileStoneProof.getproofType();
 
	        ServiceContract srchServiceContractRec = testMileStoneProof.getSrchServiceContractRec();
	        ServiceContract selServiceContractRec = testMileStoneProof.getselServiceContractRec();                                        
        
        	testMileStoneProof.getSearchOption();
        
	        srchServiceContractRec = [Select Id, Name, AccountId, Cust_Ref_Num__c, Home_Address__c, City__c, State__c, Zip__c,
		 								(Select Id,M1_Status__c, M2_Status__c, M3_Status__c, name from Service_Contract_Events__r) From ServiceContract 
		 								where Id = :scObj.Id Limit 1];

	        testMileStoneProof.srchServiceContractRec = srchServiceContractRec;
	                
	        testMileStoneProof.srchOptionFilter = 'Show Gen Assets Needing M1';
	        testMileStoneProof.acctName = srchServiceContractRec.contact.name;
	        testMileStoneProof.custRefNum = srchServiceContractRec.Cust_Ref_Num__c;
	        testMileStoneProof.custMailAddress = srchServiceContractRec.Customer_Mailing_Address__c;


	        testMileStoneProof.doSearch();
	        testMileStoneProof.sortField = 'Customer_Name_Formula__c';
	        testMileStoneProof.doAssetSort();
	        testMileStoneProof.sortField = 'Customer_Name_Formula__c';
	        testMileStoneProof.doAssetSort();
        
	        Integer assetPageNumber = testMileStoneProof.getAssetPageNumber();
	        Boolean previousButtonEnabled = testMileStoneProof.getAssetPreviousButtonEnabled();
	        Boolean nextButtonEnabled = testMileStoneProof.getAssetNextButtonDisabled();
	        Integer assetTotalPageNumber = testMileStoneProof.getAssetTotalPageNumber();
	        List<ServiceContractWrapper> pagedAssetList = testMileStoneProof.getpagedAssetList();
	        testMileStoneProof.buildPagedAssetList(1);
	        testMileStoneProof.assetNextBtnClick();
	        testMileStoneProof.assetPreviousBtnClick();
	        testMileStoneProof.getAssetPreviousButtonEnabled();
        
	        List<ServiceContractWrapper> searchedAssetsList = testMileStoneProof.searchedAssetsList;
	        searchedAssetsList = testMileStoneProof.getSearchedAssetsList();
	        
	        for(ServiceContractWrapper assetWrapperRec : searchedAssetsList)
	        {
	            assetWrapperRec.recSelected = true;
	            break;
	        }
	        testMileStoneProof.searchedAssetsList = searchedAssetsList;
	        testMileStoneProof.GetSelectedAsset();   
        
	        if(searchedAssetsList.size() == 0)
	        {
	            //searchedAssetsList.add(new ServiceContractMilestoneProof.ServiceContractWrapper(null, scEventObj, null));            
	        }     
	        if(testMileStoneProof.selectedAssetsList.size() == 0)
	        {
	            //testMileStoneProof.selectedAssetsList.add(new ServiceContractMilestoneProof.ServiceContractWrapper(null, scEventObj, null));
	        }        
	        //
	        selServiceContractRec = srchServiceContractRec;
	        //
	        testMileStoneProof.currentAssetId = searchedAssetsList[0].scAssetRec.Id;
	        testMileStoneProof.doSearchCase();
	        testMileStoneProof.uploadDocument();
	
	        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
	        testMileStoneProof.fileBody = bodyBlob;
	        testMileStoneProof.fullPathFileName = 'temp.txt';
        
	        Attachment attachmentFile = testMileStoneProof.attachmentFile;
	        
	        testMileStoneProof.milestoneProofType = 'M1 Proof';
	        //
	        
	        if(testMileStoneProof.selectedAssetsList.size() == 0)
	        {
	            //testMileStoneProof.selectedAssetsList.add(new ServiceContractMilestoneProof.ServiceContractWrapper(null, scEventObj, null));
	        }
	        
	        //
	        if(testMileStoneProof.partnerPreferenceList == null || testMileStoneProof.partnerPreferenceList.size() == 0)
	        {
	            //testMileStoneProof.partnerPreferenceList.add(new Milestone_Proof_Partner_Preference__c(Emails_To_Notify_Milestone_Proof_Upload__c = 'pmandy@sunrun.com', Notify_Milestone_Proof_Upload__c = false, Partner_Account__c = selServiceContractRec.Account_Name__c));
	        }
	
	        testMileStoneProof.attachFile();      //was failing here in INTDEV so added the above conditional statement.   
	        testMileStoneProof.m1Count = 0;   
	        testMileStoneProof.m2Count = 0;
	        testMileStoneProof.m3Count = 0;
	        testMileStoneProof.selServiceContractRec = srchServiceContractRec;        
	
	        testMileStoneProof.scEventObj.SR_Signoff__c = date.today();
	        testMileStoneProof.scEventObj.Facility_Design_Approved__c = date.today();
	        testMileStoneProof.scEventObj.Complete_Deal_Received__c = date.today();
	        testMileStoneProof.scEventObj.Initial_Deposit_Processed__c = date.today();
	        testMileStoneProof.scEventObj.Initial_Deposit_Amount_Received__c = 10000;
	        testMileStoneProof.scEventObj.Initial_Deposit_Amount__c = 10000;
	        testMileStoneProof.scEventObj.Rebate_Conf_Rec_d__c  = date.today();
	        testMileStoneProof.scEventObj.Final_Rebate_Amount__c = 100.00;
	        testMileStoneProof.scEventObj.Rebate_Conf_Num__c = '12345';
	
	        testMileStoneProof.updateAssetRec();  //NOW failing here in INTDEV // was commented out to stop SOQL 101
	        testMileStoneProof.getAttachments();  // was commented out to stop SOQL 101
	        testMileStoneProof.backToSearch();
	                
	        //For Cash Grant stuff
	        PageReference prCG;        
	        //
	        Facility_Configuration__c fc = new Facility_Configuration__c();
	        fc.Panel_Type__c = 'LG255S1C-G2';
	        fc.Number_of_Panels__c = 10;
	        fc.Service_Contract__c = selServiceContractRec.Id;
	        insert fc;
	        //
	        selServiceContractRec.Install_Partner__c = 'Verengo';
	        //selServiceContractRec.Number_of_Sunrun_owned_Modules__c = 5;
	        //testMileStoneProof.iNumSunRunOwnedModulesUsed = 5;
	        prCG = testMileStoneProof.validateConfiguration();
	        selServiceContractRec.Cash_Grant_Eligible__c = false;
	        //selServiceContractRec.Number_of_Sunrun_owned_Modules__c = 10;
	        testMileStoneProof.iNumSunRunOwnedModulesUsed = 10;                
	        prCG = testMileStoneProof.validateConfigurationFromProofType();
	        //selServiceContractRec.SmartTurn_M1_StatusCode__c = 'SUCCESS';
	        prCG = testMileStoneProof.validateConfigurationFromProofType();
	                        
	        testMileStoneProof.srchServiceContractRec = new ServiceContract();
	        testMileStoneProof.srchOptionFilter = 'Show Gen Assets Needing M2';
	        testMileStoneProof.acctName = '';
	        testMileStoneProof.doSearch();
	        
	        searchedAssetsList = testMileStoneProof.searchedAssetsList;
	        searchedAssetsList = testMileStoneProof.getSearchedAssetsList();
	        
	        for(ServiceContractWrapper assetWrapperRec : searchedAssetsList)
	        {
	            assetWrapperRec.recSelected = true;
	            break;
	        }
	        testMileStoneProof.searchedAssetsList = searchedAssetsList;
	        testMileStoneProof.GetSelectedAsset();
	        testMileStoneProof.uploadDocument();
	        
	        testMileStoneProof.fileBody = bodyBlob;
	        testMileStoneProof.fullPathFileName = 'temp.txt';
	        testMileStoneProof.fileName = 'temp.txt';
	        
	        attachmentFile = testMileStoneProof.attachmentFile;
	        
	        testMileStoneProof.milestoneProofType = 'M2 Proof';
	        selServiceContractRec = testMileStoneProof.getselServiceContractRec();
	        testMileStoneProof.selServiceContractRec = selServiceContractRec;
	        Boolean isM2Proof = testMileStoneProof.isM2Proof;
	        testMileStoneProof.isM2Proof = true;
	        Boolean enableSlNoUpload = testMileStoneProof.enableSlNoUpload;
	        testMileStoneProof.enableSlNoUpload = enableSlNoUpload;

	        //selServiceContractRec.Panel_Serial_Number__c = 'tryme1';
	        //selServiceContractRec.Number_of_Sunrun_owned_Modules__c = 1;

	        
	        //selServiceContractRec.Panel_Serial_Number__c = 'K21117290391';
	        testMileStoneProof.selServiceContractRec = selServiceContractRec;

	        
	        selServiceContractRec.Cash_Grant_Eligible__c = true;
	        testMileStoneProof.selServiceContractRec = selServiceContractRec;

	        
	        Facility_Configuration__c panelRec = new Facility_Configuration__c();
	        panelRec.Service_Contract__c = selServiceContractRec.Id;
	        panelRec.Number_of_Panels__c = 10;
	        panelRec.Panel_Type__c = 'LG245S1C-G2';
	        
	        insert panelRec;
	        
	        selServiceContractRec = [Select Id, Name, AccountId, Cust_Ref_Num__c, Home_Address__c, City__c, State__c, Zip__c,
		 								(Select Id,M1_Status__c, M2_Status__c, M3_Status__c, name from Service_Contract_Events__r)
	                                    From ServiceContract Where Id = :selServiceContractRec.Id];
	        
	       // selServiceContractRec.Panel_Serial_Number__c = 'K21117290391';
	        selServiceContractRec.Cash_Grant_Eligible__c = true;
	        testMileStoneProof.selServiceContractRec = selServiceContractRec;

	        testMileStoneProof.backToUpload();
	        //selServiceContractRec.SmartTurn_M2_StatusCode__c = 'SUCCESS';
	        selServiceContractRec.Install_Partner__c = 'Verengo';
	        testMileStoneProof.selServiceContractRec = selServiceContractRec;
	        Boolean enableAttachFile = testMileStoneProof.enableAttachFile;
	        
	        if(testMileStoneProof.selectedAssetsList.size() == 0)
	        {
	            //testMileStoneProof.selectedAssetsList.add(new ServiceContractMilestoneProof.ServiceContractWrapper(selServiceContractRec));
	        }        
	        testMileStoneProof.selServiceContractRec = selServiceContractRec;  
	         
	        testMileStoneProof.attachFile();
	        testMileStoneProof.updateAssetRec();
	        testMileStoneProof.getAttachments(); // was commented out to stop SOQL 101
	        testMileStoneProof.backToSearch();
	        
	        testMileStoneProof.srchOptionFilter = 'Show Gen Assets Needing M3';
	        testMileStoneProof.doSearch();
	        
	        searchedAssetsList = testMileStoneProof.searchedAssetsList;
	        searchedAssetsList = testMileStoneProof.getSearchedAssetsList();
	        
	        for(ServiceContractWrapper assetWrapperRec : searchedAssetsList)
	        {
	            assetWrapperRec.recSelected = true;
	            break;
	        }
	        testMileStoneProof.searchedAssetsList = searchedAssetsList;
	        testMileStoneProof.GetSelectedAsset();
	        testMileStoneProof.uploadDocument();
	
	        testMileStoneProof.fileBody = bodyBlob;
	        testMileStoneProof.fullPathFileName = 'temp.txt';
	        testMileStoneProof.fileName = 'temp';
	                
	        attachmentFile = testMileStoneProof.attachmentFile;
	        testMileStoneProof.milestoneProofType = 'M3 Proof';
	        Boolean isM3Proof = testMileStoneProof.isM3Proof; 
	        testMileStoneProof.isM3Proof = true;        
	        //
	        if(testMileStoneProof.selectedAssetsList.size() == 0)
	        {
	            //testMileStoneProof.selectedAssetsList.add(new ServiceContractMilestoneProof.ServiceContractWrapper(selServiceContractRec));
	        }        
	        testMileStoneProof.selServiceContractRec = selServiceContractRec;  
	        //
	        testMileStoneProof.attachFile();
	        testMileStoneProof.updateAssetRec();
	        testMileStoneProof.getAttachments();   // was commented out to stop SOQL 101
	        testMileStoneProof.backToSearch();
	
	        testMileStoneProof.srchOptionFilter = 'Show Gen Assets with ANY Proofs';
	        testMileStoneProof.doSearch();
	        
	        searchedAssetsList = testMileStoneProof.searchedAssetsList;
	        searchedAssetsList = testMileStoneProof.getSearchedAssetsList();
	        if (searchedAssetsList != null && searchedAssetsList.size() > 0)
	        {
	            
	            for(ServiceContractWrapper assetWrapperRec : searchedAssetsList)
	            {
	                assetWrapperRec.recSelected = true;
	                break;
	            }
	            testMileStoneProof.searchedAssetsList = searchedAssetsList;
	            testMileStoneProof.GetSelectedAsset();
	            testMileStoneProof.uploadDocument();
	    
	            testMileStoneProof.fileBody = bodyBlob;
	            testMileStoneProof.fullPathFileName = 'temp.txt';
	            
	            attachmentFile = testMileStoneProof.attachmentFile;
	            
	            testMileStoneProof.attachFile();
	            testMileStoneProof.updateAssetRec();
	            testMileStoneProof.getAttachments();  // was commented out to stop SOQL 101
	            testMileStoneProof.backToSearch();
	        }
	        
	        testMileStoneProof.srchOptionFilter = 'Show Gen Assets with ALL Proofs Submitted';
	        testMileStoneProof.doSearch();
	        
	        searchedAssetsList = testMileStoneProof.searchedAssetsList;
	        searchedAssetsList = testMileStoneProof.getSearchedAssetsList();
	        if (searchedAssetsList != null && searchedAssetsList.size() > 0)
	        {
	            
	            for(ServiceContractWrapper assetWrapperRec : searchedAssetsList)
	            {
	                assetWrapperRec.recSelected = true;
	                break;
	            }
	            testMileStoneProof.searchedAssetsList = searchedAssetsList;
	            testMileStoneProof.GetSelectedAsset();
	            testMileStoneProof.uploadDocument();
	    
	            testMileStoneProof.fileBody = bodyBlob;
	            testMileStoneProof.fullPathFileName = 'temp.txt';
	            
	            attachmentFile = testMileStoneProof.attachmentFile;
	            
	            testMileStoneProof.attachFile();
	            testMileStoneProof.updateAssetRec();
	            testMileStoneProof.getAttachments();  // was commented out to stop SOQL 101
	            testMileStoneProof.backToSearch();
	        }
	
	        testMileStoneProof.srchOptionFilter = 'Show All Denied Proofs';
	        testMileStoneProof.doSearch();
	
	        SmartTurn_OccamTypes.UploadResponse testUploadResponse = new SmartTurn_OccamTypes.UploadResponse();
	        SmartTurn_OccamTypes.Warehouse testWarehouse = new SmartTurn_OccamTypes.Warehouse();
	        SmartTurn_OccamTypes.Affiliate testAffiliate = new SmartTurn_OccamTypes.Affiliate();
	        SmartTurn_OccamTypes.LastModifiedRecord testLastMod = new SmartTurn_OccamTypes.LastModifiedRecord();
	        SmartTurn_OccamTypes.LocationName testLocName = new SmartTurn_OccamTypes.LocationName();
	        SmartTurn_OccamTypes.LogisticsOperator testLogisticsOp = new SmartTurn_OccamTypes.LogisticsOperator();
	        SmartTurn_OccamTypes.Currency_x testCurr = new SmartTurn_OccamTypes.Currency_x();
	        SmartTurn_OccamTypes.CreateRecord testCR = new SmartTurn_OccamTypes.CreateRecord();
	        SmartTurn_OccamTypes.WSDocumentIdentification testDocId = new SmartTurn_OccamTypes.WSDocumentIdentification();
	        SmartTurn_OccamTypes.WSDocumentIdentificationWithType testDocId2 = new SmartTurn_OccamTypes.WSDocumentIdentificationWithType();
	        
	        
	        SmartTurn_LookupTypes.InventoryLookupResult testInvLookup = new SmartTurn_LookupTypes.InventoryLookupResult();
	        SmartTurn_LookupTypes.LookUpManager testLookupManager = new SmartTurn_LookupTypes.LookUpManager();
	        SmartTurn_LookupTypes.PaginationInfo testPI = new SmartTurn_LookupTypes.PaginationInfo();
	        SmartTurn_LookupTypes.ResultMetadata testResult = new SmartTurn_LookupTypes.ResultMetadata();
	        SmartTurn_LookupTypes.SortingInfo testSI = new SmartTurn_LookupTypes.SortingInfo();
	         
	        SmartTurn_SalesOrder.overwriteSalesOrder_element testOverwriteSOE = new SmartTurn_SalesOrder.overwriteSalesOrder_element();
	        SmartTurn_SalesOrder.overwriteSalesOrderResponse_element testOverwriteSOResponseE = new SmartTurn_SalesOrder.overwriteSalesOrderResponse_element();
	        SmartTurn_SalesOrder.saveSalesOrder_element testSaveSOE = new SmartTurn_SalesOrder.saveSalesOrder_element();
	        SmartTurn_SalesOrder.saveSalesOrderResponse_element testSaveSOResponseE = new SmartTurn_SalesOrder.saveSalesOrderResponse_element();
	        
	        SmartTurn_InventoryItem.lookUpInventory_element testInvLookupE = new SmartTurn_InventoryItem.lookUpInventory_element();
	        SmartTurn_InventoryItem.lookUpInventoryResponse_element testInvLookupResponseE = new SmartTurn_InventoryItem.lookUpInventoryResponse_element();
	        
	        SmartTurn_InventoryItemTypes.InventoryItem testInvItem = new SmartTurn_InventoryItemTypes.InventoryItem();
	        SmartTurn_InventoryItemTypes.WSLicense testWSLicense = new SmartTurn_InventoryItemTypes.WSLicense();   
			
			if (searchedAssetsList != null && searchedAssetsList.size() > 0)
	        {            
	            for(ServiceContractWrapper assetWrapperRec : searchedAssetsList)
	            {
	                assetWrapperRec.recSelected = true;
	                break;
	            }
	            if(testMileStoneProof.selectedAssetsList.size() == 0)
	            {
	                //testMileStoneProof.selectedAssetsList.add(new ServiceContractMilestoneProof.ServiceContractWrapper(selServiceContractRec));
	            }        
	            testMileStoneProof.selServiceContractRec = selServiceContractRec;
	        
	            PageReference prShowAlbum = testMileStoneProof.showAlbum();
	            PageReference prUploadPhotos = testMileStoneProof.uploadPhotos();            
	        }
	       
		}
    }
	*/
	
	/*
     public static testMethod void milestoneProofTestCaseTrigger()
    {
        
        ServiceContractMilestoneProof testMileStoneProof = new ServiceContractMilestoneProof();
 
        String serverURL = testMileStoneProof.serverURL;
 
        Account accountRec = new Account();
        accountRec.Name = 'Test Class';
        insert accountRec;
 
        Contact contactRec = new Contact();
        contactRec.FirstName = 'DSG';
        contactRec.LastName = 'Test';
        contactRec.AccountId = accountRec.Id;
        insert contactRec;

        ServiceContract scAssetRec = new ServiceContract();
        scAssetRec.accountId = accountRec.Id;
        scAssetRec.contactId = contactRec.Id;
        //scAssetRec.Home_Address__c = 'Test Class';
       // scAssetRec.City__c = 'Los Gatos';
        //scAssetRec.Zip__c = '95032';
        //scAssetRec.Asset_Status__c = 'Plans Approved, Awaiting NTP';
       // scAssetRec.Facility_Design_Approved__c = date.today();
       // scAssetRec.NTP_Granted__c = date.today();
		//scAssetRec.Rebate_Conf_Num__c = '12345';

        //scAssetRec.SR_Signoff__c = date.today();
        //scAssetRec.Facility_Design_Approved__c = date.today();
        //scAssetRec.Complete_Deal_Received__c = date.today();
        //scAssetRec.Initial_Deposit_Processed__c = date.today();
        //scAssetRec.Initial_Deposit_Amount_Received__c = 10000;
        //scAssetRec.Initial_Deposit_Amount__c = 10000;
        //scAssetRec.Rebate_Conf_Rec_d__c  = date.today();
        //scAssetRec.Final_Rebate_Amount__c = 100.00;
        
        insert scAssetRec;

        RecordType mileStoneRecType = testMileStoneProof.mileStoneRecType;
        
        Case currentCaseRec = new Case();
        currentCaseRec.RecordTypeId = mileStoneRecType.Id;
        currentCaseRec.AccountId = accountRec.Id;
        currentCaseRec.ContactId = contactRec.Id;
        currentCaseRec.Milestone_Proof_Type__c = 'M1 Proof';
        currentCaseRec.Status = 'Request Approval';
        currentCaseRec.Origin = 'Install Partner'; 
        currentCaseRec.Reason = 'Documentation';
        currentCaseRec.Description = 'Milestone Proof Submitted';
        currentCaseRec.Subject = 'Milestone Proof Submitted';
        currentCaseRec.Service_Contract__c = scAssetRec.Id;
        insert currentCaseRec;
         
        currentCaseRec.Status = 'M1 Proof Denied';
        currentCaseRec.Denied_Comment__c = 'Test';
        update currentCaseRec;

		Test.startTest();
		
        ApexPages.StandardController stdCont = new ApexPages.StandardController(new Case(Id = currentCaseRec.Id));
        CallOut2SmartTurn_M1Submit testM1Submit = new CallOut2SmartTurn_M1Submit(stdCont);
        testM1Submit.submitM1();

        currentCaseRec.Status = 'M1 Proof Approved';
        update currentCaseRec;
        
        CallOut2SmartTurn_M1Submit testM1Submit2 = new CallOut2SmartTurn_M1Submit(stdCont);
        testM1Submit2.submitM1();

        scAssetRec.Cash_Grant_Eligible__c = true;
        update scAssetRec;    // was commented out to stop SOQL 101

        CallOut2SmartTurn_M1Submit testM1Submit3 = new CallOut2SmartTurn_M1Submit(stdCont);
        testM1Submit3.submitM1();
                
        Facility_Configuration__c panelRec = new Facility_Configuration__c();
        panelRec.Service_Contract__c = scAssetRec.Id;
        panelRec.Number_of_Panels__c = 1;
        panelRec.Panel_Type__c = 'LG245S1C-G2';
        insert panelRec;

        CallOut2SmartTurn_M1Submit testM1Submit4 = new CallOut2SmartTurn_M1Submit(stdCont);
        testM1Submit4.submitM1();

        currentCaseRec.SmartTurn_M1_StatusCode__c = 'SUCCESS';
        update currentCaseRec;

        CallOut2SmartTurn_M1Submit testM1Submit5 = new CallOut2SmartTurn_M1Submit(stdCont);
        testM1Submit5.submitM1();

        currentCaseRec.Milestone_Proof_Type__c = 'M2 Proof';
        update currentCaseRec;

        CallOut2SmartTurn_M1Submit testM1Submit6 = new CallOut2SmartTurn_M1Submit(stdCont);
        testM1Submit6.submitM1();

// above 4 lines were commented out to stop SOQL 101
        delete currentCaseRec;
        
        Case currentCaseRec2 = new Case();
        currentCaseRec2.RecordTypeId = mileStoneRecType.Id;
        currentCaseRec2.AccountId = accountRec.Id;
        currentCaseRec2.ContactId = contactRec.Id;
        currentCaseRec2.Milestone_Proof_Type__c = 'M2 Proof';
        currentCaseRec2.Status = 'Request Approval';
        currentCaseRec2.Origin = 'Install Partner'; 
        currentCaseRec2.Reason = 'Documentation';
        currentCaseRec2.Description = 'Milestone Proof Submitted';
        currentCaseRec2.Subject = 'Milestone Proof Submitted';
        currentCaseRec2.Service_Contract__c = scAssetRec.Id;
        insert currentCaseRec2;

        currentCaseRec2.Status = 'M2 Proof Denied';
        currentCaseRec2.Denied_Comment__c = 'Test';
        update currentCaseRec2;

       // scAssetRec.SmartTurn_M2_StatusCode__c = 'SUCCESS';
        //update scAssetRec;

        currentCaseRec2.Status = 'M2 Proof Approved (non meter test)';
        update currentCaseRec2;

        delete currentCaseRec2;

//To get more coverage:
        testMilestoneProof.selServiceContractRec = scAssetRec;
       // testMilestoneProof.selServiceContractRec.Panel_Serial_Number__c = 'tryme1';
       // testMilestoneProof.selServiceContractRec.Number_of_Sunrun_owned_Modules__c = 1;
        List<String> listSN = new List<String>();
        listSN.add('tryme1');
       // Integer inv = testMilestoneProof.lookupInventory(listSN);
        //
        List<Case> listCase = testMilestoneProof.getCaseList();
        //
        //Boolean bisVerengo = testMilestoneProof.isInstallPartnerVerengo;
//public Integer lookupInventory(List<String> listSerialNumbers)
// end of code to get more coverage

        Test.stopTest();
      
    }
	*/
	
	/*
     public static testMethod void milestoneProofTestCaseTrigger2()
    {
        Test.startTest();
        ServiceContractMilestoneProof testMileStoneProof = new ServiceContractMilestoneProof();
 
        Account accountRec = new Account();
        accountRec.Name = 'Test Class';
        insert accountRec;
 
        Contact contactRec = new Contact();
        contactRec.FirstName = 'DSG';
        contactRec.LastName = 'Test';
        contactRec.AccountId = accountRec.Id;
        insert contactRec;

        ServiceContract scAssetRec = new ServiceContract();
        scAssetRec.accountId = accountRec.Id;
        scAssetRec.contactId = contactRec.Id;
        //scAssetRec.Home_Address__c = 'Test Class';
        //scAssetRec.City__c = 'Los Gatos';
       // scAssetRec.Zip__c = '95032';
       // scAssetRec.Asset_Status__c = 'Plans Approved, Awaiting NTP';
       // scAssetRec.Facility_Design_Approved__c = date.today();
      //  scAssetRec.NTP_Granted__c = date.today();
       // scAssetRec.Rebate_Conf_Num__c = '12345';
		
		//scAssetRec.SR_Signoff__c = date.today();
       // scAssetRec.Facility_Design_Approved__c = date.today();
      //  scAssetRec.Complete_Deal_Received__c = date.today();
      //  scAssetRec.Initial_Deposit_Processed__c = date.today();
       // scAssetRec.Initial_Deposit_Amount_Received__c = 10000;
       // scAssetRec.Initial_Deposit_Amount__c = 10000;
      //  scAssetRec.Rebate_Conf_Rec_d__c  = date.today();
       // scAssetRec.Final_Rebate_Amount__c = 100.00;
        
        insert scAssetRec;

        RecordType mileStoneRecType = testMileStoneProof.mileStoneRecType;

        Case currentCaseRec3 = new Case();
        currentCaseRec3.RecordTypeId = mileStoneRecType.Id;
        currentCaseRec3.AccountId = accountRec.Id;
        currentCaseRec3.ContactId = contactRec.Id;
        currentCaseRec3.Milestone_Proof_Type__c = 'M3 Proof';
        currentCaseRec3.Status = 'Request Approval';
        currentCaseRec3.Origin = 'Install Partner'; 
        currentCaseRec3.Reason = 'Documentation';
        currentCaseRec3.Description = 'Milestone Proof Submitted';
        currentCaseRec3.Subject = 'Milestone Proof Submitted';
        currentCaseRec3.Service_Contract__c = scAssetRec.Id;
        insert currentCaseRec3;

        currentCaseRec3.Status = 'M3 PTO Denied';
        currentCaseRec3.Denied_Comment__c = 'Test';
        update currentCaseRec3;
        
        currentCaseRec3.Status = 'M3 PTO Approved';
        //update currentCaseRec3;
 
        delete currentCaseRec3;
        Test.stopTest();
        
    }
	*/
}