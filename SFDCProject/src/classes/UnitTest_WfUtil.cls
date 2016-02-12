@isTest(SeeAllData=true)
public class UnitTest_WfUtil {

    public static testMethod void testCreateWorkflowProject(){
        
        Id userId = UserInfo.getUserId();
        Project__c projectObj = UnitTest_WorkflowManagement.createProject();
        System.debug('projectObj.Status__c : ' + projectObj.Status__c);
        Task__C taskObj = [select Id, name, Phase__r.Project__r.account__c, Task_Owner__c, group_name__c, SLA_In_Hours__c, Expected_Close_Date2__c, Expected_Close_Date__c from Task__c where Phase__r.project__c = :projectObj.Id and name = 'Verification Call'];
        UnitTest_WorkflowManagement.createUserGroup(userId, taskObj.group_name__c);
        taskObj.Task_Owner__c = userId;
        update taskObj;

        wfUtil.getTaskNameForProposal(Label.WFM_Submit_Proposal, null, projectObj);
        Map<String, sObject> objectMap = new Map<String, sObject>();
        Set<String>  objectNames = new Set<String>();
        objectNames.add('Proposal__c');
        objectNames.add('Opportunity');
        objectNames.add('ServiceContract');
        objectNames.add('Service_Contract_Event__c');
        objectNames.add('Service_Contract_Partner_Rel__c');
        objectNames.add('Project__c');
        
        wfUtil.initSObjectMap(taskObj, objectNames, objectMap);
        List<Task__c> taskList = new List<Task__c>();
        Map<Id, Task__c> newMap = new Map<Id, Task__c>();
        Map<Id, Task__c> oldMap = new Map<Id, Task__c>();
        taskList.add(taskObj);
        newMap.put(taskObj.Id, taskObj);
        oldMap.put(taskObj.Id, taskObj);
        
        Test.startTest();
            wfUtil.checkProjectStatus(false, true,taskList, newMap, oldMap);
            wfUtil.eligibleForWFProject('', '');
			wfutil.getNotesCount(taskList[0].id,'task');
        	wfutil.isEmpty('test');
        	wfutil.processAfterTaskUpdate(false, true,taskList, newMap, oldMap);
            Account accountObj = [Select Id, name, BillingCountry, BillingState, BillingStreet, BillingPostalCode from Account where Id =:taskObj.Phase__r.Project__r.account__c];
            accountObj.BillingStreet = '596 Market St';
            accountObj.BillingCountry = 'USA';
            accountObj.BillingPostalCode = '94105';
            accountObj.BillingState = 'CA';
            update accountObj;
            
            Map<Id, Id> proposalOptyMap = new Map<Id, Id>();
            proposalOptyMap.put(projectObj.proposal__c, projectObj.Opportunity__c);
            wfUtil.updateProposalWFProjects(proposalOptyMap);
            
            String uniqueString = projectObj.Opportunity__c + Label.WFM_Submit_Proposal;
            Map<String, Id> optyMap = new  Map<String, Id>();
            Map<String, String> taskNameMap = new  Map<String, String>();
            taskNameMap.put(uniqueString, Label.WFM_Submit_Proposal);
            optyMap.put(uniqueString, projectObj.Opportunity__c);       

            Map<String, String> reasonMap = new Map<String, String>();
            Map<String, String> actionMap = new Map<String, String>();
            
            wfUtil.updateProposalWFTasks(optyMap,taskNameMap, reasonMap, actionMap);
           
            //wfUtil.completeSCTasks(Map<String, Id> scMap, Map<String, String> taskNameMap);
            //wfUtil.updateWFProjectsForProposal(Map<Id, Id> proposalOptyMap, Map<Id, String> optyStatusMap);
            //updateWFProjects(Map<Id, Id> scOptyMap);
            //updateWFProjectStatus(Map<Id, String> scStatusModifiedOptyIds);
            
        Test.stopTest();
    }
    
    public static testMethod void serviceContractMilestoneProofTest(){
        UnitTest_ProposalUtil.disableExternalServices();
        Test_Partner_User__c testPartnerUserObj = UnitTest_ServiceContractUtil.getBlackBirdSalesRep();
        User u = [Select Id from User where ContactID != NULL and IsActive = true and Id =:testPartnerUserObj.User_Id__c  limit 1];
        ServiceContract scObj;
        Service_Contract_Event__c scEventObj;
        String custRefNum = '';
        String acctName = '';
        String custMailAddress = '';
        System.runAs(u) {  

            
            UnitTest_ServiceContractUtil.createServiceContractData();
            scObj = UnitTest_ServiceContractUtil.scObj;
            scEventObj = UnitTest_ServiceContractUtil.scEventObj;
            System.currentPagereference().getParameters().put('id', scEventObj.Id);
            custRefNum = scObj.Cust_Ref_Num__c;
            acctName = scObj.Customer_Name__c;
            custMailAddress = scObj.Customer_Mailing_Address__c;
            
            System.debug('custMailAddress: ' + custMailAddress);
 
            WorkflowManagement wfObj = new WorkflowManagement();
            Map<Id, Id> optyProposalMap = new Map<Id, Id>();
            Map<Id, String> projectTypeMap = new Map<Id, String>();
            optyProposalMap.put(scObj.Opportunity__C, scObj.Proposal__c);
            projectTypeMap.put(scObj.Proposal__c,  'Direct');
           // wfObj.createProject(optyProposalMap, projectTypeMap); 
            
            Test.startTest();
                Map<Id, Id> scOptyMap = new Map<Id, Id>();
                scOptyMap.put(scObj.Id, scObj.Opportunity__C);
                  wfUtil.updateWFProjects(scOptyMap);
            	
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

                Map<String, Id> scMap = new  Map<String, Id>();
                Map<String, String> taskNameMap = new  Map<String, String>();
                scMap.put(scObj.Id+Label.WFM_Submit_M1_Proof, scObj.Id);
                taskNameMap.put(scObj.Id+Label.WFM_Submit_M1_Proof, Label.WFM_Submit_M1_Proof);
                wfUtil.completeSCTasks(scMap,taskNameMap);
                                    
                //String scStatus = 'Deal Cancelled';
                //scObj.status__c = scStatus;
                //update scObj;
                Map<Id, String> scStatusModifiedOptyIds = new Map<Id, String>();
                scStatusModifiedOptyIds.put(scObj.Opportunity__c, wfUtil.CANCELLED);
                wfUtil.updateWFProjectStatus(scStatusModifiedOptyIds);
            Test.stopTest();
        }
    }
    
    public static testMethod void testWFUpdateRules(){
        List<Task_Template__c> templateMap = [Select Id from Task_Template__c limit 3];
        Workflow_Update_Rule__c wfObj = new Workflow_Update_Rule__c();
        wfObj.Dependent_Task_Template__c = templateMap[0].Id;
        wfObj.Parent_Task_Template__c = templateMap[1].Id;
        wfObj.Field_Name1__c = 'Using_Build_Partner__c';
        wfObj.Field_Value1__c = 'FALSE';
        wfObj.Object_Name1__c = 'Service_Contract_Event__c';
        insert wfObj;
        
        wfObj.Parent_Task_Template__c = templateMap[2].Id;
        update wfObj;
        
        delete wfObj;
        
        undelete wfObj;
        
    }
}