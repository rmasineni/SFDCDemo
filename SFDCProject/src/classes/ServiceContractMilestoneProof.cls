public with sharing class ServiceContractMilestoneProof {
        ServiceContract srchServiceContractRec = new ServiceContract();
        public String baseURL;
        ServiceContract selServiceContractRec;
        Service_Contract_Event__c scEventObj;
        Asset__c meterAssetObj;
        List<Service_Contract_Event__c> scEventList;
        List<Case> caseList;
        List<Attachment> attachments;
        List<Milestone_Proof_Case_Owner__c> dfltCaseOwnerList;
        List<EmailTemplate> templateList;
        List<Milestone_Proof_Partner_Preference__c> partnerPreferenceList;
        public String srchOptionFilter {get; set;}
        public String currentAssetId {get; set;}
        public String milestoneProofType {get; set;}
        public RecordType mileStoneRecType {get;set;}
        public Milestone_Proof_Case_Owner__c dfltCaseOwnerDtl  {get;set;}
        public List<ServiceContractWrapper> searchedAssetsList = new List<ServiceContractWrapper>();
        public List<ServiceContractWrapper> selectedAssetsList = new List<ServiceContractWrapper>();    
        public Boolean bSelectedSingleAsset{get{if (selectedAssetsList == null || selectedAssetsList.size() <=  0 || selectedAssetsList.size() >  1){return false;}else{return true;}}set;}
        public String docType {get; set;}
        public String errorPageDetails {get{if (errorPageDetails == '') {errorPageDetails = 'Photos can only be uploaded to one Service Contract at a time, please select one and only one Service Contract.';} return errorPageDetails;} set;}
        public Integer iNumSunRunOwnedModulesUsed{get;set;}
        public Boolean bError{get;set;}
        public Map<String, PreBoughtPanelLimits__c> mapPanelLimits {get;set;}
        public Id partnerId;
    
        static final String eligibleStatusList1 = 'Plans Approved, Awaiting NTP';
        static final String eligibleStatusList2 = 'NTP granted, Awaiting M1';
        static final String eligibleStatusList3 = 'M1 received, Awaiting M2';
        static final String eligibleStatusList4 = 'M2 received, Awaiting PTO';
    
        static final String cancelledStatus1 = 'Deal Cancelled';
        static final String cancelledStatus2 = 'Deal Cancelled due to credit';
    
    
        public static List<Proposal__c> getServiceContract(Set<Id> proposalIds){
            String proposalSOQLStr = ProposalUtil.getProposalSQLStr();
            proposalSOQLStr += ' where Id in :proposalIds ' ;
            List<Proposal__c> proposalsList = Database.query(proposalSOQLStr);
            return proposalsList;
        }
        
        public void initializeServiceContractInfo(Id contractId){
            baseURL = EDPUtil.getBaseURL();
            selServiceContractRec = ServiceContractUtil.getServiceContract(contractId);
            if(selServiceContractRec != null && selServiceContractRec.Service_Contract_Events__r != null 
                && selServiceContractRec.Service_Contract_Events__r.size() > 0 ){
                scEventObj  = selServiceContractRec.Service_Contract_Events__r[0];
            } 
            
            if(selServiceContractRec != null && selServiceContractRec.Assets__r != null 
                && selServiceContractRec.Assets__r.size() > 0 ){
                for(Asset__c assetObj : selServiceContractRec.Assets__r){
                    if(assetObj.status__c != null && assetObj.status__c == ServiceContractUtil.ACTIVE 
                        && assetObj.Type__c == ServiceContractUtil.ASSET_TYPE_METER){
                        meterAssetObj = assetObj;
                        break;
                    }
                }
            }     
        }
        
        public ServiceContractMilestoneProof(ApexPages.StandardController stdController)
        {
            System.debug('Inside Constructor ...');
            currentAssetId = System.currentPagereference().getParameters().get('id');   
            initializeServiceContractInfo(currentAssetId);
        }

        public ServiceContractMilestoneProof(Id currentAssetId)
        {
            if(currentAssetId != null){
                initializeServiceContractInfo(currentAssetId);
            }           
        }
        
        public ServiceContractMilestoneProof()
        {
            bError = false;
            mileStoneRecType = [Select Id from RecordType Where SobjectType = 'Case' And DeveloperName = 'Milestone_Proof'];
            dfltCaseOwnerList = [Select Name, Case_Owner_Email__c from Milestone_Proof_Case_Owner__c];
            templateList = [select Subject, body , HtmlValue, DeveloperName from EmailTemplate Where developerName = 'Milestone_Proof_Upload_Confirmation' Limit 1];
            //User userRec = [Select Contact.AccountId, Contact.Ultimate_Parent_Account__c From User WHERE Id = :Userinfo.getUserid()];
            Contact contactObj = PRMContactUtil.getLoginUserAccountAndContact();
            partnerPreferenceList = new List<Milestone_Proof_Partner_Preference__c>();
            if(contactObj != null && contactObj.Id != null){
                partnerPreferenceList = [Select Id, Notify_Milestone_Proof_Upload__c, Emails_To_Notify_Milestone_Proof_Upload__c 
                            From Milestone_Proof_Partner_Preference__c Where Partner_Account__c = :contactObj.Ultimate_Parent_Account__c Limit 1];
                partnerId = contactObj.Ultimate_Parent_Account__c;
            }
            
            System.debug('partnerId: ' + partnerId);
            if (errorPageDetails == null)
                errorPageDetails = '';
           
        }
    
        public Attachment attachmentFile
        {
            get 
            {
                if (attachmentFile == null)
                {
                    attachmentFile = new Attachment();
                }
                return attachmentFile;
            }
          set;
        }
        
        public Pagereference userActions(){
           return null;
        }

        public PageReference validateConfigurationFromProofType()
        {
           return validateConfiguration();
        }
        
        public PageReference validateConfiguration()
        {
            return null;
        }
        
        public PageReference OnlyUpdatePanelCount()
        {
            validateConfiguration();
            if(!bError)
            {
                UpdateNumberOfPreBoughtPanels();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Number of Sunrun-Owned Panels Successfully Updated.'));
            }
            return null;
        }
        
        public void UpdateNumberOfPreBoughtPanels()
        {
            ////selServiceContractRec.Number_of_Sunrun_owned_Modules__c = iNumSunRunOwnedModulesUsed;
            update selServiceContractRec;
        }
        
        public string fullPathFileName {get;set;}   
        public string fileName {get;set;}
        public string acctName {get;set;}
        public string custRefNum {get;set;}
        public string custMailAddress {get;set;}
        public Decimal m1Count {get;set;}   
        public Decimal m2Count {get;set;}
        public Decimal m3Count {get;set;}
        public string panelSerialNumbers {get;set;}
    
        public String serverURL
        {
            get{
                if (serverURL == null)
                {
                     serverURL = 'https://' + ApexPages.CurrentPage().getHeaders().get('Host');
                }
                return serverURL;
            }
            set;
        }

        public boolean getIsPartnerUser(){
            Boolean ispartnerUser = false;
            String userType = UserInfo.getUserType();
            if(userType != null && userType != ''){
                if(userType.contains('Partner'))
                    return true;
            }
            return ispartnerUser;
        }

        public Boolean isPartnerVerengo
        {
            get{
               
                String installPartner;
                isPartnerVerengo = false;
                return isPartnerVerengo;
            }
            set;
        }
        
        public Boolean enableAttachFile
        {
            get{
                if (isM2Proof)
                {
                    enableAttachFile = true;                                
                }
                else
                {
                     enableAttachFile = true;
                }
                return enableAttachFile;
            }
            set;
        }
    
        public Boolean enableSlNoUpload
        {
            get{
                    if (scEventObj != null && scEventObj.M2_Status__c != 'Approved')
                    {
                        enableSlNoUpload = true;
                    }
                    else
                    {
                        enableSlNoUpload = false;
                    }
                    return enableSlNoUpload;                
                }
            set;
        }
        
        public PageReference backToUpload()
        {
            return Page.ServiceContractMilestoneproofuploadfile;
        }
        
        public PageReference submitSerialNumber(){
            return null;
        }

    
        public Boolean isPTOSaved
        {
            get{
                if (isPTOSaved == null)
                {
                     isPTOSaved = false;
                }
                return isPTOSaved;
            }
            set;
        }
    
    
        public String approvedStatusValue
        {
            get {
                approvedStatusValue = 'Approved';
                return approvedStatusValue;
            }
            set;
        }
    
        public String pendingStatusValue
        {
            get {
                pendingStatusValue = 'Pending';
                return pendingStatusValue;
            }
            set;
        }
    
        public String deniedStatusValue
        {
            get {
                deniedStatusValue = 'Denied';
                return deniedStatusValue;
            }
            set;
        }
    
        public String proofTypeM1
        {
            get {
                proofTypeM1 = 'M1 Proof';
                return proofTypeM1;
            }
            set;
    
        }
    
        public String proofTypeM2
        {
            get {
                proofTypeM2 = 'M2 Proof';
                return proofTypeM2;
            }
            set;
    
        }
    
        public String proofTypeM3
        {
            get {
                proofTypeM3 = 'M3 Proof';
                return proofTypeM3;
            }
            set;
        }
    
        public String caseStatusM1Approved
        {
            get {
                caseStatusM1Approved = 'M1 Proof Approved';
                return caseStatusM1Approved;
            }
            set;
        }
    
        public String caseStatusM2Approved
        {
            get {
                caseStatusM2Approved = 'M2 Proof Approved (non meter test)';
                return caseStatusM2Approved;
            }
            set;
        }
    
        public String caseStatusM3Approved
        {
            get {
                caseStatusM3Approved = 'M3 PTO Approved';
                return caseStatusM3Approved;
            }
            set;
        }
    
        public Boolean isM2Proof
        {
            get {
                if (milestoneProofType == 'M2 Proof')
                {
                    isM2Proof = true;
                }
                else
                {
                    isM2Proof = false;
                }   
                return isM2Proof;
            }
            set;
        }
    
        public Boolean isM3Proof
        {
            get {
                if (milestoneProofType == 'M3 Proof')
                {
                    isM3Proof = true;
                }
                else
                {
                    isM3Proof = false;
                }   
                return isM3Proof;
            }
            set;
        }
        
    
        public transient Blob fileBody {get;set;}   
    
        public ServiceContract getSrchServiceContractRec()
        {
            if(srchServiceContractRec == null) 
            {
                srchServiceContractRec = new ServiceContract();
            }
            return srchServiceContractRec;   
        }    
     
        public Asset__c getMeterAssetObj(){
            if(meterAssetObj == null) 
            {
                meterAssetObj = new Asset__c();
            }
            return meterAssetObj;       
        }
     
        public Service_Contract_Event__c getSCEventObj()
        {
            if(scEventObj == null) 
            {
                scEventObj = new Service_Contract_Event__c();
            }
            return scEventObj;   
        } 
        
        public ServiceContract getselServiceContractRec()
        {
            if(selServiceContractRec == null) 
            {
                selServiceContractRec = new ServiceContract();
            }
            return selServiceContractRec;   
        }    
    
        public List<SelectOption> getSearchOption() 
        {
            List<SelectOption> options = new List<SelectOption>();
    
            options.add(new SelectOption( 'Show Service Contracts Needing M1', 'Show Service Contracts Needing M1'));
            options.add(new SelectOption( 'Show Service Contracts Needing M2', 'Show Service Contracts Needing M2'));
            options.add(new SelectOption( 'Show Service Contracts Needing M3', 'Show Service Contracts Needing M3'));
            options.add(new SelectOption( 'Show Service Contracts with ANY Proofs', 'Show Service Contracts with ANY Proofs'));
            options.add(new SelectOption( 'Show Service Contracts with ALL Proofs Submitted', 'Show Service Contracts with ALL Proofs Submitted'));
            options.add(new SelectOption( 'Show All Denied Proofs', 'Show All Denied Proofs'));
            
            return options;    
        }
    
        public List<SelectOption> getproofType() 
        {
            List<SelectOption> options = new List<SelectOption>();
    
            options.add(new SelectOption( 'Please Select', 'Please Select'));
            options.add(new SelectOption( 'M1 Proof', 'M1 Proof'));
            options.add(new SelectOption( 'M2 Proof', 'M2 Proof'));
            options.add(new SelectOption( 'M3 Proof', 'M3 Proof'));
            
            return options;    
        }

        public PageReference doSearch() 
        {
            String scEventSQLQuery = ServiceContractUtil.getServiceContractEventSOQL();
            String scSQLWhereQuery = ' ';
            String scEventSQLWhereQuery = ' ';
            if (acctName != null && acctName != '')
            {
                String likeQryString = '%' + acctName + '%';
                scSQLWhereQuery += ' And Service_Contract__r.Customer_Name__c Like ' + '\'' + String.escapeSingleQuotes(likeQryString) + '\'';
            }
            if (custRefNum != null && custRefNum != '')
            {
                String likeQryString = '%' + custRefNum + '%';
                scSQLWhereQuery += ' And Service_Contract__r.Cust_Ref_Num__c Like ' + '\'' + String.escapeSingleQuotes(likeQryString) + '\'';
            }        
            if (custMailAddress != null && custMailAddress != '')
            {
                String likeQryString = '%' + custMailAddress + '%';
                scSQLWhereQuery +=  ' And Service_Contract__r.Customer_Mailing_Address__c Like ' + '\'' + String.escapeSingleQuotes(likeQryString) + '\'';
            }
    
            if (srchOptionFilter == 'Show Service Contracts Needing M1')
            {
                scEventSQLWhereQuery += ' And M1_Proof_Upload_Date__c = null And M1_proof_panel_inverter_delivery__c = null And M2_proof_substantial_completion__c = null';
            }
    
            if (srchOptionFilter == 'Show Service Contracts Needing M2')
            {
              scEventSQLWhereQuery += ' And M2_Proof_Upload_Date__c = null And M2_proof_substantial_completion__c = null';
            }
        
            if (srchOptionFilter == 'Show Service Contracts Needing M3')
            {
              scEventSQLWhereQuery +=' And M3_Proof_Upload_Date__c = null And PTO__c = null And Partner_PTO_proof_date__c = null';
            }
    
            if (srchOptionFilter == 'Show Service Contracts with ANY Proofs')
            {
                scEventSQLWhereQuery +=' And (M1_Status__c != null OR M2_Status__c != null OR M3_Status__c != null)' ;
            }
            
            if (srchOptionFilter == 'Show Service Contracts with ALL Proofs Submitted')
            {
                scEventSQLWhereQuery += ' And (M1_Status__c  != null AND M2_Status__c != null AND M3_Status__c != null)' ;
            }
    
            if (srchOptionFilter == 'Show All Denied Proofs')
            {
                scEventSQLWhereQuery += ' AND (M1_Status__c  = ' + '\'' + String.escapeSingleQuotes(deniedStatusValue) + '\'' ;
                scEventSQLWhereQuery += 'OR M2_Status__c = ' + '\'' + String.escapeSingleQuotes(deniedStatusValue) + '\'' ; 
                scEventSQLWhereQuery += 'OR M3_Status__c = ' + '\'' + String.escapeSingleQuotes(deniedStatusValue) + '\'' + ')' ;
            }
    
            String numberOfRows = '';
            if (!Test.isRunningTest())
            {
                numberOfRows += ' Limit 100';
            }
            else
            {
                numberOfRows += ' Limit 10';
            }
            String sqlQuery = '';
            sqlQuery = scEventSQLQuery;
            sqlQuery += ' where NTP_Granted__c != null And  ';
            System.debug('Partner Id: ' + partnerId);
            if(partnerId != null && !Test.isRunningTest()){
                sqlQuery += ' Service_Contract__r.Install_Partner_Id__c =:partnerId  AND ' ;
            }
            sqlQuery += ' Asset_Status__c NOT IN (' + '\'' + String.escapeSingleQuotes(cancelledStatus1) + '\'';
            sqlQuery += ',' + '\'' + String.escapeSingleQuotes(cancelledStatus2) + '\'' + ')';
            sqlQuery += scSQLWhereQuery;
            sqlQuery += scEventSQLWhereQuery;
            sqlQuery += numberOfRows;
            
            system.debug('sqlQuery: ' + sqlQuery);
    
            List<Service_Contract_Event__c> tempSCEventList = Database.query(sqlQuery);
            searchedAssetsList.clear();
            for(Service_Contract_Event__c scEventRec : tempSCEventList)
            {
                searchedAssetsList.add(new ServiceContractWrapper(null, scEventRec, null));
                System.debug('scEventRec: ' + scEventRec);
            }
            buildPagedAssetList(1);
            if (caseList != null)
            {
                caseList.clear();
            }
            iNumSunRunOwnedModulesUsed = null;
            
            return null;
        }

        public PageReference doSearchCase() 
        {
            String sqlQuery = 'Select Id, CaseNumber, Milestone_Proof_Type__c, Status, Milestone_Proof_Approval_Date__c From Case Where RecordTypeId = ' ;
            sqlQuery = sqlQuery + '\'' + String.escapeSingleQuotes(mileStoneRecType.Id) + '\'';
            sqlQuery = sqlQuery + ' And Service_Contract__c = '; 
            sqlQuery = sqlQuery + '\'' + String.escapeSingleQuotes(currentAssetId) + '\'';
    
            sqlQuery = sqlQuery + ' Limit 1000';
            system.debug(sqlQuery);
    
            caseList = Database.query(sqlQuery);
            return null;
        }
        
        public List<Case> getCaseList()
        {
            return caseList;
        }
        
        public PageReference uploadDocument()
        {
            GetSelectedAsset();
            
            if (selectedAssetsList == null || selectedAssetsList.size() <=  0)
            {
                errorPageDetails = 'To Upload a Milestone Proof, you must first select a Service Contract.';
                return Page.milestoneProof_Error;
            }
            else if (selectedAssetsList.size() >  1)
            {
                errorPageDetails = 'Proofs can only be uploaded to one Service Contract at a time, please select only one Service Contract.';
                return Page.milestoneProof_Error;
            }
            
            milestoneProofType = 'Please Select';
            isPTOSaved = false;
            String genAssetId = selectedAssetsList[0].scEventRec.Service_Contract__r.Id;
            currentAssetId = genAssetId;
            initializeServiceContractInfo(genAssetId);
            if (scEventObj != null){
                if(scEventObj.M1_Proof_Count__c == null) {
                    m1Count = 1;
                }
                else {
                    m1Count = scEventObj.M1_Proof_Count__c + 1;
                } 
    
                if (scEventObj.M2_Proof_Count__c == null) {
                    m2Count = 1;
                }
                else {
                    m2Count = scEventObj.M2_Proof_Count__c + 1;
                } 
        
                if (scEventObj.M3_Proof_Count__c == null){
                    m3Count = 1;
                }
                else{
                    m3Count = scEventObj.M3_Proof_Count__c + 1;
                }         
            }
            PageReference ref;
            String urlPrefix = '/partner';
            urlPrefix = baseURL.contains(urlPrefix) ? urlPrefix : '';
            String tempURL = urlPrefix + '/apex/ServiceContractMilestoneproofuploadfile';
            ref = new PageReference(tempURL);
            ref.setRedirect(true); 
            return Page.ServiceContractMilestoneproofuploadfile;
            //return ref;
        } 

        public String getGenAssetId()
        {       
            GetSelectedAsset();                
            milestoneProofType = 'Please Select';
            isPTOSaved = false;
            if (selectedAssetsList != null && selectedAssetsList.size() >  0)
            {
               String genAssetId = selectedAssetsList[0].scEventRec.Service_Contract__r.Id;
               currentAssetId = genAssetId;
               return currentAssetId;
            }
            return null;
        }
    
        public PageReference showAlbum()
        {     
            Boolean bHasPhotos = false;
            Integer photoCount = 0;
            GetSelectedAsset();
            String genAssetId = selectedAssetsList[0].scEventRec.Service_Contract__r.Id;
            currentAssetId = genAssetId;
            System.Debug('SELECTED GEN ASSET FOR SHOW ALBUM = ' + currentAssetId);
            
            selServiceContractRec = [Select Id, Name, AccountId, Cust_Ref_Num__c, Home_Address__c, City__c, State__c, Zip__c, Cash_Grant_Eligible__c,
                                        (Select Id,M1_Status__c, M2_Status__c, M3_Status__c, name from Service_Contract_Events__r)
                                        From ServiceContract Where Id = :genAssetId];        
            System.Debug('SELECTED GEN ASSET LIST SIze = ' + selectedAssetsList.size());
            if (selectedAssetsList == null || selectedAssetsList.size() <=  0)
            {
                System.Debug('none selected');
                bHasPhotos = false;
                errorPageDetails = 'To View Photo Album, you must first select a Service Contract.';
                return Page.milestoneProof_Error;
            }
            if(selectedAssetsList.size() >  1)
            {
                System.Debug('many selected');
                bHasPhotos = false;
                errorPageDetails = 'Photos can only be viewed in relatin to one Service Contract at a time, please select only one Service Contract.';
                return Page.milestoneProof_Error;
            }
            for(SR_Gen_Asset_Attachment__c gaa:[select Id, Document_Name__c, Size__c, Active__c, Service_Contract__c, Service_Contract__r.Name, Document_Name_On_File_Server__c, Thumbnail__c 
                                                  from SR_Gen_Asset_Attachment__c 
                                                 where Service_Contract__c = :genAssetId 
                                                   and Active__c = true])
            {
                bHasPhotos = true;
                photoCount++;
            }       
            if(photoCount == 0)
            {
                errorPageDetails = 'No photos have been uploaded to this asset yet.';
            }
            return null;    
        }
        
        public PageReference uploadPhotos()
        {
            GetSelectedAsset();
            System.Debug('selectedAssetsList VALUE: ' + selectedAssetsList);
            if (selectedAssetsList == null || selectedAssetsList.size() <=  0)
            {
                errorPageDetails = 'To Upload Photos, you must first select a Service Contract.';
                PageReference pr = Page.milestoneProof_Error;
                pr.setRedirect(true);
                return pr;
            }
            else if (selectedAssetsList.size() >  1)
            {
                errorPageDetails = 'Photos can only be uploaded to one Service Contract at a time, please select only one Service Contract.';
                return Page.milestoneProof_Error;
            }
            
            milestoneProofType = 'Please Select';
            isPTOSaved = false;
            String genAssetId = selectedAssetsList[0].scEventRec.Service_Contract__r.Id;
            currentAssetId = genAssetId;
            System.Debug('SELECTED GEN ASSET for Upload Photos = ' + currentAssetId);
            initializeServiceContractInfo(genAssetId);
            
            if(scEventObj != null){
                if (scEventObj.M1_Proof_Count__c == null)
                {
                    m1Count = 1;
                }
                else
                {
                    m1Count = scEventObj.M1_Proof_Count__c + 1;
                } 
        
                if (scEventObj.M2_Proof_Count__c == null)
                {
                    m2Count = 1;
                }
                else
                {
                    m2Count = scEventObj.M2_Proof_Count__c + 1;
                } 
        
                if (scEventObj.M3_Proof_Count__c == null)
                {
                    m3Count = 1;
                }
                else
                {
                    m3Count = scEventObj.M3_Proof_Count__c + 1;
                } 
                
                //if(selServiceContractRec.Number_of_Sunrun_owned_Modules__c != null)
                //{
                //    iNumSunRunOwnedModulesUsed = Integer.ValueOf(selServiceContractRec.Number_of_Sunrun_owned_Modules__c);
                //}
                
            }
            
            return null;
        }
    
        public PageReference attachFile()
        {
            if (selectedAssetsList == null || selectedAssetsList.size() <=  0)
            {
                errorPageDetails = 'To Upload a Milestone Proof, you must first select a Service Contract.';
                return Page.milestoneProof_Error;
            }   
            
            if(milestoneProofType == proofTypeM3){
                if(meterAssetObj == null || (meterAssetObj != null && meterAssetObj.Serial_Number__c == null || meterAssetObj.Serial_Number__c == '')){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Missing Meter Registration - You cannot Upload M3 Proof if Meter Serial Number is not Registered'));
                    return null;
                }
            }
            
            if ((fileBody != null && fullPathFileName != null) || isPTOSaved)
            {
                if (fileBody != null && fullPathFileName != null && fileBody.size() > 5242880 )
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Max attachment size is 5Mb'));
                }
                else
                {
                    currentAssetId = selectedAssetsList[0].scEventRec.Service_Contract__r.Id;
                    
                    String sqlQuery = 'Select Id, Status From Case Where IsClosed = false And RecordTypeId = ' ;
                    sqlQuery = sqlQuery + '\'' + String.escapeSingleQuotes(mileStoneRecType.Id) + '\'';
                    sqlQuery = sqlQuery + ' And Service_Contract__c = '; 
                    sqlQuery = sqlQuery + '\'' + String.escapeSingleQuotes(currentAssetId) + '\'';
                    sqlQuery = sqlQuery + ' And Milestone_Proof_Type__c = '; 
                    System.debug('milestoneProofType: ' + milestoneProofType);
                    sqlQuery = sqlQuery + '\'' + String.escapeSingleQuotes(milestoneProofType) + '\'';
    
                    system.debug(sqlQuery);
            
                    Case[] currentCaseList = Database.query(sqlQuery);
                    Case currentCaseRec;
                    
                    //User userRec = [SELECT Contact.AccountId, Contact.FirstName,  ContactId From User WHERE Id = :Userinfo.getUserid()];
                    Contact contactObj = PRMContactUtil.getLoginUserAccountAndContact();
                    Id partnerId;
                    Id partnerContactId;
                    String partnerContactName = '';
                    if (contactObj != null && contactObj.Id != null){
                        partnerId = contactObj.Ultimate_Parent_Account__c;
                        partnerContactId =  contactObj.Id;   
                        partnerContactName =  contactObj.name;      
                    }
                    
                    if (currentCaseList != null && currentCaseList.size() > 0)
                    {
                        currentCaseRec = currentCaseList[0];
                     //   if (currentCaseRec.Status == 'Request Approval' || currentCaseRec.Status.contains('Approved')) 
                          if (currentCaseRec.Status.contains('Approved')) 
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Milestone Proof of type ' + milestoneProofType + ' already exists for the project located at ' + selServiceContractRec.Home_Address__c));
                            return null;
                        }
                        
                        currentCaseRec.Status = 'Request Approval';
                        update currentCaseRec;
                    }
                    else
                    {
                        if ((scEventObj != null && milestoneProofType == proofTypeM1 && scEventObj.M1_proof_panel_inverter_delivery__c != null) ||
                                (milestoneProofType == proofTypeM2 && scEventObj.M2_proof_substantial_completion__c != null) ||
                                (milestoneProofType == proofTypeM3 && scEventObj.PTO__c  != null))
                                {
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Milestone Proof of type ' + milestoneProofType + ' already exists for the project located at ' + selServiceContractRec.Home_Address__c));
                                    return null;
                                }
    
                        String dfltCaseOwnerEmail = null;
                        String dfltCaseOwnerId = null;
                        for (Milestone_Proof_Case_Owner__c dfltCaseOwnerDtl : dfltCaseOwnerList)
                        {
                            if (dfltCaseOwnerDtl.Name == selServiceContractRec.Install_Partner__c)
                            {
                                dfltCaseOwnerEmail = dfltCaseOwnerDtl.Case_Owner_Email__c;
                                break;
                            }
                        }
                        
                        if (dfltCaseOwnerEmail != null)
                        {
                            User[] ownerList = [Select Id From User Where Email = :dfltCaseOwnerEmail];
                             
                            if (ownerList != null && ownerList.size() > 0)
                            {
                                dfltCaseOwnerId = ownerList[0].Id;
                            }
                            else
                            {
                                Group[] groupList = [Select Id From Group Where Email = :dfltCaseOwnerEmail];
                                if (groupList != null && groupList.size() > 0)
                                {
                                    dfltCaseOwnerId = groupList[0].Id;
                                }
                            }
                        }
                        
                        currentCaseRec = new Case();
                        currentCaseRec.RecordTypeId = mileStoneRecType.Id;
                        currentCaseRec.AccountId = partnerId;
                        currentCaseRec.ContactId = partnerContactId;
                        currentCaseRec.Milestone_Proof_Type__c = milestoneProofType;
                        currentCaseRec.Status = 'Request Approval';
                        currentCaseRec.Origin = 'Install Partner'; 
                        currentCaseRec.Reason = 'Documentation';
                        currentCaseRec.Description = 'Milestone Proof Submitted';
                        currentCaseRec.Subject = 'Milestone Proof Submitted';
                        currentCaseRec.Service_Contract__c = currentAssetId;
                        currentCaseRec.Install_Partner__c = selServiceContractRec.Install_Partner__c;
                        if (dfltCaseOwnerId != null)
                        {
                            currentCaseRec.OwnerId = dfltCaseOwnerId;
                        }
                        insert currentCaseRec;
                    }
                    if (!isPTOSaved)
                    {   
                        String descriptiveName = '';
                        Integer lastIndex = fullPathFileName.lastIndexOf('.');
                        if (lastIndex > 0)
                        {
                            String fileExt = fullPathFileName.substring(lastIndex);
                            if (milestoneProofType == proofTypeM1)
                            {
                                descriptiveName = 'M1_Proof_' + m1Count + fileExt;
                            }
                            else if (milestoneProofType == proofTypeM2)
                            {
                                descriptiveName = 'M2_Proof_' + m2Count +  fileExt;
                            }
                            else if (milestoneProofType == proofTypeM3)
                            {
                                descriptiveName = 'M3_Proof_' + m3Count +  + fileExt;
                            }
                        }
                        else
                        {
                            descriptiveName = fullPathFileName;
                        }
                        
                        attachmentFile.Body = fileBody;   
                        attachmentFile.Name = descriptiveName;   
                        attachmentFile.ParentId = currentCaseRec.Id;
                        try 
                        {
                            insert attachmentFile;  
                            
                            if (partnerPreferenceList != null && partnerPreferenceList.size() > 0)
                            {
                                Milestone_Proof_Partner_Preference__c partnerPreference = partnerPreferenceList[0];
                                if (partnerPreference.Notify_Milestone_Proof_Upload__c && partnerPreference.Emails_To_Notify_Milestone_Proof_Upload__c != null)
                                {
                                    List<String> partnerEmailId = partnerPreference.Emails_To_Notify_Milestone_Proof_Upload__c.split(',');
    //                              String[] partnerEmailId = new String[1];
    //                              partnerEmailId[0] = partnerPreference.Emails_To_Notify_Milestone_Proof_Upload__c;
                                    
                                    if (templateList != null && templateList.size() > 0)
                                    {
                                            Case tempCaseRec = [Select CaseNumber, Milestone_Proof_Type__c, Customer_Reference_Number__c, 
                                                                    Customer_Name__c, Customer_Mailing_Address__c From Case Where Id = :currentCaseRec.Id];                                         
                                            
                                            EmailTemplate templRec1 = templateList[0];
                                            String templBody =  templRec1.Body;
                                            String emailSubject = templRec1.Subject;
                                            String caseURL = serverURL + '/' +  currentCaseRec.Id;
                                            templBody = templBody.replace('{!Contact.FirstName}', partnerContactName);
                                            templBody = templBody.replace('{!Case.Link}', caseURL);
                                            templBody = templBody.replace('{!Case.CaseNumber}', tempCaseRec.CaseNumber);
                                            templBody = templBody.replace('{!Case.Milestone_Proof_Type__c}', tempCaseRec.Milestone_Proof_Type__c);
                                            templBody = templBody.replace('{!Case.Customer_Reference_Number__c}', tempCaseRec.Customer_Reference_Number__c);
                                            templBody = templBody.replace('{!Case.Customer_Name__c}', tempCaseRec.Customer_Name__c);
                                            templBody = templBody.replace('{!Case.Customer_Mailing_Address__c}', tempCaseRec.Customer_Mailing_Address__c);
                                            
                                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                            mail.setSubject(emailSubject);
                                            mail.setToAddresses( partnerEmailId );
                                            mail.setPlainTextBody(templBody);
    
                                            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });                                       
                                    }                               
                                }
                            }
                           // UpdateNumberOfPreBoughtPanels(); 
                        } 
                        catch (DMLException e) 
                        {
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading file'));
                            return null;
                        } 
                        finally 
                        {
                            attachmentFile.Body = null; // clears the viewstate
                            attachmentFile = new Attachment();
                            fileBody = null;
                            fullPathFileName = null;
                        }
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'File uploaded successfully'));
                        updateAssetRec();       
                        getAttachments();
                        
                    }
                    else
                    {
                        scEventObj.M3_Status__c = 'Pending';
                        update scEventObj;
                    }
                }
            }
            return null;
        } 
    
        public PageReference savePTO()
        {
            if(milestoneProofType == proofTypeM3){
    
                ////|| selServiceContractRec.Meter_Test_Date__c == null
                if(meterAssetObj == null || (meterAssetObj != null && meterAssetObj.Serial_Number__c == null || meterAssetObj.Serial_Number__c == '')){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Missing Meter Registration - You cannot Save PTO date if Meter Serial Number is not Registered'));
                    return null;
                }
            }
            
            isPTOSaved = true;
            attachFile();
            return backToSearch();
        }
        
        public void updateAssetRec()
        {
            if (milestoneProofType == proofTypeM1)
            {
                scEventObj.M1_Proof_Upload_Date__c = date.today();
                scEventObj.M1_Proof_Count__c = m1Count;
                scEventObj.M1_Status__c = 'Pending';
                m1Count++;
                update scEventObj;
            }
            else if (milestoneProofType == proofTypeM2)
            {
                scEventObj.M2_Proof_Upload_Date__c = date.today();
                scEventObj.M2_Proof_Count__c = m2Count;
                scEventObj.M2_Status__c = 'Pending';
                m2Count++;
                update scEventObj;
            }
            else if (milestoneProofType == proofTypeM3)
            {
                scEventObj.M3_Proof_Upload_Date__c = date.today();
                //selServiceContractRec.Partner_PTO_proof_date__c = date.today();
                scEventObj.M3_Proof_Count__c = m3Count;
                scEventObj.M3_Status__c = 'Pending';
                m3Count++;
                update scEventObj;
            }
        }
        
        public PageReference backToSearch()
        {
            doSearch();
            return Page.servicecontractmilestoneproof;
        } 
        
        public List<ServiceContractWrapper> getSearchedAssetsList()
        {
            return searchedAssetsList;
        }
        
        public PageReference GetSelectedAsset()
        {
            selectedAssetsList.clear();
            for(ServiceContractWrapper ServiceContractWrapperRec : searchedAssetsList)
            {
                if(ServiceContractWrapperRec.recSelected == true)
                {
                    selectedAssetsList.add(ServiceContractWrapperRec);
                }
            }
            return null;
        }
        
        public List<Attachment> getAttachments()
        {
            try 
            {
                if (currentAssetId != null)
                {
                    Set <Id> caseIds = new Set <Id>();
                    Integer iCount = 0;
                    for (Case caseRec : [SELECT Id FROM Case WHERE Service_Contract__c = :currentAssetId])
                    {
                        caseIds.add(caseRec.Id);
                        iCount++;
                    }
                    system.debug(caseIds);
                    if(!caseIds.isEmpty())
                    {
                       attachments = [Select ParentId, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById From Attachment Where ParentId IN :caseIds];
                    }
                }
            }
            catch (Exception e)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to get attachments'));          
            }
            return attachments;
        }
        
        public class ServiceContractWrapper
        {
            public ServiceContract scAssetRec{get; set;}
            public Service_Contract_Event__c scEventRec{get; set;}
            public Asset__c assetRec{get; set;}
            public Boolean recSelected {get; set;}
            public string refnNumber {get;set;}
            public ServiceContractWrapper(ServiceContract scObj, Service_Contract_Event__c scEventObj, Asset__c assetObj)
            {
                scAssetRec = scObj;
                scEventRec = scEventObj;
                assetRec = assetObj; 
                recSelected = false;
                if(scObj == null && scEventObj.Service_Contract__r != null && scEventObj.Service_Contract__r.Id != null){
                    scAssetRec = scEventObj.Service_Contract__r;
                }
                if(scEventRec != null && scEventRec.Service_Contract__r != null && scEventRec.Service_Contract__r.Id != null){
                    refnNumber = scEventRec.Service_Contract__r.Cust_Ref_Num__c;
                }
            }
        }
     
        public String sortField {get; set;}
        public String previousSortField {get; set;}
    
        public void doAssetSort()
        {
            String order = 'asc';
            /*This checks to see if the same header was click two times in a row, if so
            it switches the order.*/
            
            if (scEventList == null || scEventList.size() <= 0)
            {
                return;
            }
            if(previousSortField == sortField){
                order = 'desc';
                previousSortField = null;
            }else{
                previousSortField = sortField;
            }
            //To sort the table we simply need to use this one line, nice!
            superSort.sortList(scEventList,sortField,order);
            searchedAssetsList.clear();
            pagedAssetList.clear();
            for(Service_Contract_Event__c scEventObj : scEventList)
            {
                searchedAssetsList.add(new ServiceContractWrapper(null,scEventObj, null));
            }
            assetPageNumber = 1;
            buildPagedAssetList(assetPageNumber);
        }
     
        public List<ServiceContractWrapper> pagedAssetList = new List<ServiceContractWrapper>();
        private Integer assetPageNumber = 0;
        private Integer assetPageSize = 50;
        private Integer assetTotalPageNumber = 0;
        
        public Integer getAssetPageNumber()
        {
            return assetPageNumber;
        }
        public Boolean getAssetPreviousButtonEnabled()    //Contracts Previous 
        {
            return !(assetPageNumber > 1);
        }
    
        public Boolean getAssetNextButtonDisabled()       //Contracts Next
        {
            return ((assetPageNumber * assetPageSize) >= searchedAssetsList.size());
        }
    
        public Integer getassetTotalPageNumber()
        {
            if (assetTotalPageNumber == 0 && searchedAssetsList !=null)
            {
                assetTotalPageNumber = searchedAssetsList.size() / assetPageSize;
                Integer mod = searchedAssetsList.size() - (assetTotalPageNumber * assetPageSize);
                if (mod > 0)
                assetTotalPageNumber++;
            }
            return assetTotalPageNumber;
        }
    
        public List<ServiceContractWrapper> getpagedAssetList()
        {
            return pagedAssetList;
        }
    
        public void buildpagedAssetList(Integer newPageIndex)
        {
            try
            {
                pagedAssetList = new List<ServiceContractWrapper>();
                Transient Integer counter = 0;
                Transient Integer min = 0;
                Transient Integer max = 0;
    
                if (newPageIndex > assetPageNumber)
                {
                    min = assetPageNumber * assetPageSize;
                    max = newPageIndex * assetPageSize;
                }
                else
                {
                    max = newPageIndex * assetPageSize;
                    min = max - assetPageSize;
                }
                for(ServiceContractWrapper assetRec : searchedAssetsList)
                {
                    counter++;
                    if (counter > min && counter <= max)
                    pagedAssetList.add(assetRec);
                }
                assetPageNumber = newPageIndex;
            }
            catch(Exception ex)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getMessage()));
            }
        }
    
        public PageReference assetNextBtnClick() 
        {
            buildpagedAssetList(assetPageNumber + 1);
    
            return null;
        }
    
        public PageReference assetPreviousBtnClick() 
        {
            buildpagedAssetList(assetPageNumber - 1);
            return null;
    
        }
        public String getBaseURL(){
            return EDPUtil.getBaseURL();
        }
    //update payment terms in service contract and SCE --M0, M1, M2, M3
    public static void updateMileStoneDetails( List<ServiceContract> newSCList, Map<Id,ServiceContract> newSCMap,Map<Id,ServiceContract> oldSCMap){   
        List<ServiceContract> updateServiceContract =  new  List<ServiceContract>();
        List<Service_Contract_Event__c> updateServiceContractEvents =  new  List<Service_Contract_Event__c>();
        List<ServiceContract> ServiceContractList =[select Id,Install_Partner_Id__c,Proposal__r.Customer_Signoff_Date__c, M1_Terms__c, M2_Terms__c,M3_Terms__c,Customer_Signoff__c from ServiceContract where id in:newSCMap.keySet()];
        Map<String,Partner_Contract__c> MapPartnerContract =  new  Map<String,Partner_Contract__c>();
        Map<Id,Service_Contract_Event__c>  MapSCE =  new Map<Id,Service_Contract_Event__c>();
        for(Service_Contract_Event__c sce:  [select Id, Utility_Classification__c,M0_Terms__c,Service_Contract__c 
                                             from Service_Contract_Event__c where Service_Contract__c in:newSCMap.keySet() ]){
                                                 MapSCE.put(sce.Service_Contract__c, sce) ;
                                             }
        
        
        Set<Id> installPartners = new Set<Id>();
        for(ServiceContract sc: newSCList){
            If(sc.Install_Partner_Id__c!=null ){
                installPartners.add(sc.Install_Partner_Id__c);
                system.debug('sc.Install_Partner_Id__c>>' +  sc.Install_Partner_Id__c);
            }
        }
        system.debug('installPartners>>' +  installPartners);
        If(installPartners.size()>0){
            for(Partner_Contract__c pcc: [select Id, Account__c, M1_percentage__c, M1_Percentage_1__c, M0_Percentage_1__c, M0_Percentage__c, M2_Percentage__c, M2_Percentage_1__c, M3_Percentage__c, M3_Percentage_1__c 
                                          , Contract_Number__c,  Effective_End_Date_1__c, Effective_End_Date__c,Effective_Start_Date__c, Effective_Start_Date_1__c from Partner_Contract__c where Account__c in: installPartners and Contract_Status__c='Active' ]){
                                              MapPartnerContract.put(pcc.Account__c, pcc);
                                          }
            
            for(ServiceContract sc: ServiceContractList){
            	 If(sc.Proposal__r.Customer_Signoff_Date__c!=null){
                    If(sc.Customer_Signoff__c!=null && sc.Customer_Signoff__c!=''){
                        system.debug('sc.Customer_Signoff__c>>' +  sc.Customer_Signoff__c);
                        Datetime customerSign=  datetime.valueOf(sc.Customer_Signoff__c);
                        Date CustomerSignOff = date.newinstance(customerSign.year(),customerSign.month(),customerSign.day());
                        if( MapPartnerContract.get(sc.Install_Partner_Id__c)!=null){
                            If(CustomerSignOff>= MapPartnerContract.get(sc.Install_Partner_Id__c).Effective_Start_Date__c && CustomerSignOff <= MapPartnerContract.get(sc.Install_Partner_Id__c).Effective_End_Date__c ) {
                                Partner_Contract__c pccObj= MapPartnerContract.get(sc.Install_Partner_Id__c);
                                If(pccObj!=null){
                                    If(pccObj.M1_percentage__c!=null && pccObj.M1_percentage__c/100!= oldSCMap.get(sc.Id).M1_Terms__c)
                                        sc.M1_Terms__c = pccObj.M1_percentage__c/100;
                                    If(pccObj.M2_Percentage__c!=null && pccObj.M2_Percentage__c/100!= oldSCMap.get(sc.Id).M2_Terms__c)
                                        sc.M2_Terms__c = pccObj.M2_Percentage__c/100;
                                    If(pccObj.M3_Percentage__c!=null && pccObj.M3_Percentage__c/100!= oldSCMap.get(sc.Id).M3_Terms__c)
                                        sc.M3_Terms__c = pccObj.M3_Percentage__c/100;
                                    Service_Contract_Event__c sce=  MapSCE.get(sc.Id);
                                    
                                    If(pccObj.M0_Percentage__c!=null && String.valueOf(pccObj.M0_Percentage__c/100)!= sce.M0_Terms__c){
                                        sce.M0_Terms__c=String.valueOf(pccObj.M0_Percentage__c/100);
                                        sce.Utility_Classification__c='NA';
                                    }
                                    updateServiceContractEvents.add(sce);
                                    updateServiceContract.add(sc);
                                }
                            }
                            else if (CustomerSignOff>= MapPartnerContract.get(sc.Install_Partner_Id__c).Effective_Start_Date_1__c && CustomerSignOff <= MapPartnerContract.get(sc.Install_Partner_Id__c).Effective_End_Date_1__c )
                            {
                                Partner_Contract__c pccObj= MapPartnerContract.get(sc.Install_Partner_Id__c);
                                If(pccObj!=null){
                                    If(pccObj.M1_Percentage_1__c!=null && pccObj.M1_Percentage_1__c/100!= oldSCMap.get(sc.Id).M1_Terms__c)
                                        sc.M1_Terms__c = pccObj.M1_Percentage_1__c/100;
                                    If(pccObj.M2_Percentage_1__c!=null && pccObj.M2_Percentage_1__c/100!= oldSCMap.get(sc.Id).M2_Terms__c)
                                        sc.M2_Terms__c = pccObj.M2_Percentage_1__c/100;
                                    If(pccObj.M3_Percentage_1__c!=null && pccObj.M3_Percentage_1__c/100!= oldSCMap.get(sc.Id).M3_Terms__c)
                                        sc.M3_Terms__c = pccObj.M3_Percentage_1__c/100;
                                    Service_Contract_Event__c sce=  MapSCE.get(sc.Id);
                                    
                                    If(pccObj.M0_Percentage_1__c!=null && String.valueOf(pccObj.M0_Percentage_1__c/100)!= sce.M0_Terms__c){
                                        sce.M0_Terms__c=String.valueOf(pccObj.M0_Percentage_1__c/100);
                                        sce.Utility_Classification__c='NA';
                                    }
                                    updateServiceContractEvents.add(sce);
                                    updateServiceContract.add(sc);
                                }
                            }
                        }
                    } 
               }
            }
        }
        if(!updateServiceContract.isEmpty()){
            system.debug('updateServiceContract>>>>' + updateServiceContract);
            update  updateServiceContract;
        }
        If(!updateServiceContractEvents.isEmpty()){
            system.debug('updateServiceContractEvents>>>>' + updateServiceContractEvents);
            update updateServiceContractEvents;
        }
        
        //}
        
        //}
    }
    
    
}