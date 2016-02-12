public class ServiceContractUtil {
    private static boolean isExecuting = true;
    public static Set<Id> processedSCIdsForPG = new Set<Id>();
    private static Set<String> beforeNTPStages = new Set<String>();
    private static Set<String> afterNTPStages = new Set<String>();
    private static Set<String> NTPStages = new Set<String>();
    private static Set<String> NTPStagesForDealCancel = new Set<String>();
    public static Map<Id, ServiceContract> scMapForSCEventTrigger = new Map<Id, ServiceContract>();
    public static Map<Id, ServiceContract> scMapForSCEventTrigger2 = new Map<Id, ServiceContract>();
    public static String ACTIVE = 'Active';
    public static String SALES = 'Sales';
    public static String INSTALL = 'Install';
    
    public static String ASSET_TYPE_METER = 'Meter';
    public static String CREDIT_CONTACT = 'Credit';
    public static String BILLING_CONTACT = 'Billing';
    public static String ASSET = 'Asset';
    public static String INACTIVE = 'Inactive';
    
    public static String PAY_BY_CHECK = 'Pay by Check';
    public static String RECURRING = 'Recurring';
    
    public static String PENDING = 'Pending';
    public static boolean isServiceContractCreation = false;
    public static boolean skipSCAuditTrail = false;
    public static void setServiceContractCreation(Boolean value){
        isServiceContractCreation = value;
    }
    
    public static Map<String, Sunrun_Audit_Trail__c> scEventAuditTrail = new Map<String, Sunrun_Audit_Trail__c>();
    public static Map<String, Sunrun_Audit_Trail__c> scAuditTrail = new Map<String, Sunrun_Audit_Trail__c>();
    
    public static Set<String> getBeforeNTPStages(){
        if(beforeNTPStages.isEmpty()){
            beforeNTPStages.add('01. Deal Signed, Welcome Call');
            beforeNTPStages.add('02. Site Survey Scheduled');
            beforeNTPStages.add('02. Welcome Call Complete, Awaiting Plans');
            beforeNTPStages.add('03. Engineering');
            beforeNTPStages.add('04. Design True Up');
            beforeNTPStages.add('05. Awaiting CAP and NTP');
            beforeNTPStages.add('05. Awaiting Plans, CAP and NTP');
            beforeNTPStages.add('05. CAP granted, Awaiting NTP');
            beforeNTPStages.add('05. Plans approved, Awaiting CAP & NTP');
            beforeNTPStages.add('Deal Not Signed, Approved with stipulation (ACH)');
            beforeNTPStages.add('Deal not signed, awaiting complete docs from partner');
            beforeNTPStages.add('Deal Not Signed, Back to Sales');
            beforeNTPStages.add('Deal not signed, credit question');
            beforeNTPStages.add('Deal Not Signed, Failed Credit');
            beforeNTPStages.add('Deal Not Signed, Needs more info');            
        }
        return beforeNTPStages;
    }
    
    public static Set<String> getAfterNTPStages(){
        if(afterNTPStages.isEmpty()){
            afterNTPStages.add('08. M1 received, Awaiting M2');
            afterNTPStages.add('09. M2 received, Awaiting PTO');
            afterNTPStages.add('10. PTO Granted, Facility Active');
            afterNTPStages.add('Deal Cancelled');
            afterNTPStages.add('Redeployed');
            afterNTPStages.add('Removed - Temporary');
            afterNTPStages.add('Removed - Permanent');
            afterNTPStages.add('Awaiting Cust Signoff on Change Order');
            afterNTPStages.add('Awaiting Change Order Docs from Partner');
            afterNTPStages.add('Customer Purchased System');
            afterNTPStages.add('Deal Cancelled due to credit');
            afterNTPStages.add('Deal On Hold');
            afterNTPStages.add('Deactivated');
        }
        return afterNTPStages;
    }
    
    public static Set<String> getNTPStages(){
        if(NTPStages.isEmpty()){
            NTPStages.add('05. NTP granted, Awaiting CAP');
            NTPStages.add('05a. NTP Granted, Awaiting M1');
            NTPStages.add('05a. NTP granted, Awaiting M1');
            NTPStages.add('06. NTP Granted, In Permitting');
            NTPStages.add('07. Install Scheduling');    
        }
        return NTPStages;
    }   
    
    
    public static Map<Id, Boolean> checkForCompletedServiceContracts(String objectName, Set<Id> objectIds){
        Map<Id, List<ServiceContract>> serviceContractsMap = getServiceContracts(objectName, objectIds);
        Map<Id, Boolean> resultMap = new Map<Id, Boolean>();
        for(Id objectId : serviceContractsMap.keySet()){
            List<ServiceContract> contractList = serviceContractsMap.get(objectId);
            for(ServiceContract contractObj : contractList){
                if(contractObj.Status__c != null && contractObj.Status__c != ''){ 
                    if((getAfterNTPStages().contains(contractObj.Status__c) || getNTPStages().contains(contractObj.Status__c)) 
                        && (contractObj.TE_Fund_Name__c != null && contractObj.TE_Fund_Name__c != '')){
                        resultMap.put(objectId, true);
                        break;  
                    }
                }

            }
        }
        return resultMap;
    }
    
    public static String getServiceContractSQLStr(){
        String contractSQLStr = 'Select Id, ContactId, Proposal__c, Previous_Status__c, Opportunity__r.Opportunity_Source_Type__c, ERP_Customer_Name__c, Agreement_Number__c, AccountId, Opportunity__c, TE_Fund_Name__c, Status__c, Service_Contract_Status__c from ServiceContract ';
        
        return contractSQLStr;
    }

    public static Map<Id, List<ServiceContract>> getServiceContracts(String objectName, Set<Id> objectIds){
        Map<Id, List<ServiceContract>> serviceContractsMap = new Map<Id, List<ServiceContract>>();
        String inactiveStr = ServiceContractUtil.INACTIVE;
        
        if(objectIds != null && !objectIds.isEmpty()){
            String soqlStr;
            soqlStr = getServiceContractSQLStr();
             if(objectName != null && objectName == 'scforvoidprops'){
                soqlStr += ' where Opportunity__c in :objectIds ';
            } else { 
                soqlStr += ' where Service_Contract_Status__c != :inactiveStr ';  
                if(objectName != null && objectName == 'Contact'){
                    soqlStr += ' and ContactId in :objectIds ';  
                }else if(objectName != null && objectName == 'Account'){
                    soqlStr += ' and AccountId in :objectIds ';  
                }else if(objectName != null && objectName == 'Opportunity'){
                    soqlStr += ' and Opportunity__c in :objectIds ';  
                }else if(objectName != null && objectName == 'Proposal'){
                    soqlStr += ' and Proposal__c in :objectIds ';  
                }
            }
            System.debug('soqlStr: ' + soqlStr);
            System.debug('objectIds: ' + objectIds);
            
            for(ServiceContract serviceContractObj : Database.query(soqlStr)){
                List<ServiceContract> contractList = new List<ServiceContract>();
                if(objectName != null && objectName == 'Contact'){
                    contractList= serviceContractsMap.containsKey(serviceContractObj.ContactId) ? 
                                                        serviceContractsMap.get(serviceContractObj.ContactId) : new List<ServiceContract>();
                    contractList.add(serviceContractObj);
                    serviceContractsMap.put(serviceContractObj.ContactId, contractList);

                }else if(objectName != null && objectName == 'Account'){
                    contractList= serviceContractsMap.containsKey(serviceContractObj.AccountId) ? 
                                                        serviceContractsMap.get(serviceContractObj.AccountId) : new List<ServiceContract>();
                    contractList.add(serviceContractObj);
                    serviceContractsMap.put(serviceContractObj.AccountId, contractList);
                }else if(objectName != null && objectName == 'Opportunity'){
                    contractList= serviceContractsMap.containsKey(serviceContractObj.Opportunity__c) ? 
                                                        serviceContractsMap.get(serviceContractObj.Opportunity__c) : new List<ServiceContract>();
                    contractList.add(serviceContractObj);
                    serviceContractsMap.put(serviceContractObj.Opportunity__c, contractList);
                    System.debug('serviceContractObj.Opportunity__c: ' + serviceContractObj.Opportunity__c);
                }else if(objectName != null && objectName == 'scforvoidprops'){
                    contractList= serviceContractsMap.containsKey(serviceContractObj.Opportunity__c) ? 
                                                        serviceContractsMap.get(serviceContractObj.Opportunity__c) : new List<ServiceContract>();
                    contractList.add(serviceContractObj);
                    serviceContractsMap.put(serviceContractObj.Opportunity__c, contractList);
                    System.debug('serviceContractObj.Opportunity__c: ' + serviceContractObj.Opportunity__c);
                }else if(objectName != null && objectName == 'Proposal'){
                    contractList= serviceContractsMap.containsKey(serviceContractObj.Proposal__c) ? 
                                                        serviceContractsMap.get(serviceContractObj.Proposal__c) : new List<ServiceContract>();
                    contractList.add(serviceContractObj);
                    serviceContractsMap.put(serviceContractObj.Proposal__c, contractList);
                    System.debug('serviceContractObj.Proposal__c: ' + serviceContractObj.Proposal__c);
                }               
            }
        }
        System.debug('serviceContractsMap1: ' + serviceContractsMap);
        return serviceContractsMap;
    }   
    
    public static String getContractFieldsString(){
        String contractFields = ' ';
        Map<String, Schema.SobjectField> fieldsMap = SObjectType.Servicecontract.fields.getMap();
        if (fieldsMap != null){
            
            for (String fieldName : fieldsMap.keySet()){               
                if(fieldName == 'BillingAddress' || fieldName== 'ShippingAddress')
                    continue;                
                contractFields += fieldName + ',';
            }
            
            /*
            for (Schema.SObjectField ft : fieldsMap.values()){               
                Schema.DescribeFieldResult fd = ft.getDescribe(); 
                if(fd.getName() == 'BillingAddress' || fd.getName() == 'ShippingAddress')
                    continue;                
                contractFields += fd.getName() + ',';
            }
            */
            if (contractFields.endsWith(',')){
                contractFields = contractFields.substring(0,contractFields.lastIndexOf(','));
            }
        }
        System.debug('contractFields: ' + contractFields);
        return contractFields;
    }

 
    public static void updateServiceContract(Map<Id, String> proposalStageMap){
        
        if(Test.isRunningTest())
            return;
        updateServiceContract_Future(proposalStageMap);
    }
    
    @future
    public static void updateServiceContract_Future(Map<Id, String> proposalStageMap){
        String inactiveStr = ServiceContractUtil.INACTIVE;
        if(proposalStageMap == null || proposalStageMap.isEmpty())
            return;
        
        Map<Id, Id> proposalOptyMap = new Map<Id, Id>();
        Map<Id, Proposal__c> proposalMap = new Map<Id, Proposal__c>();
        Map<Id, ServiceContract> optyContractMap = new Map<Id, ServiceContract>();
        
        Set<Id> proposalIds =  proposalStageMap.keySet();
        
        String fieldsString = ProposalToServiceContractGenerationUtil.getProposalFieldsString();
        String proposalSelectStatement = 'select Id, stage__c, Name, Proposal_Name__c, Opportunity__r.AccountId, Opportunity__r.Id, System_Size_CEC_AC__c';
        if(fieldsString != null && !fieldsString.contains('System_Size_STC_DC__c')){
            proposalSelectStatement += ', System_Size_STC_DC__c';
        }
        proposalSelectStatement += fieldsString + ' from Proposal__c where Id =:proposalIds ';      
        for(Proposal__c proposalObj : Database.query(proposalSelectStatement)){
            proposalOptyMap.put(proposalObj.Id, proposalObj.Opportunity__c);
            proposalMap.put(proposalObj.Id, proposalObj);
        }   
        
        
        //for(Proposal__c proposalObj : [Select Id, stage__c, Opportunity__c from Proposal__C where Id in :proposalStageMap.keySet()]){
        //  proposalOptyMap.put(proposalObj.Id, proposalObj.Opportunity__c);
        //}
        List<Id> optyIds = proposalOptyMap.values();
        String query = 'SELECT ';
        query += ServiceContractUtil.getContractFieldsString() ;
        query += ' from Servicecontract where Service_Contract_Status__c != :inactiveStr and Opportunity__c in :optyIds ' ;
        for(Servicecontract serviceContractObj : Database.query(query)){
            optyContractMap.put(serviceContractObj.Opportunity__c, serviceContractObj);
        }

        for(Id proposalId : proposalStageMap.keySet()){
            Id tempOptyId = proposalOptyMap.get(proposalId);
            if(!optyContractMap.containsKey(tempOptyId))
                continue;
            
            ServiceContract serviceContractObj = optyContractMap.get(tempOptyId);
            String proposalStage = proposalStageMap.get(proposalId);
            CreateServiceContractController contractControllerObj = new CreateServiceContractController(proposalId, proposalStage);
            Proposal__c proposal = proposalMap.get(proposalId);
            contractControllerObj.upsertServiceContract(serviceContractObj, proposal);
            System.debug('proposal0: ' + proposal);
            contractControllerObj.upsertServiceContractRelatedRecords(serviceContractObj, proposal,false);
        }
    }   
    
    
    public static ServiceContract getServiceContract(Id contractId){
        ServiceContract contractObj;
        Set<Id> contractIdSet = new Set<Id>();
        contractIdSet.add(contractId);
        List<ServiceContract>  serviceContracts = getServiceContracts(contractIdSet);
        if(serviceContracts != null && !serviceContracts.isEmpty()){
            contractObj = serviceContracts[0];
        }
        return contractObj;
    }
    
    public static List<ServiceContract> getServiceContracts(Set<Id> contractIds){
        String contractSOQLStr = ServiceContractUtil.getServiceContractSOQLString();
        contractSOQLStr += ' where Id in :contractIds ' ;
        List<ServiceContract>  serviceContracts = Database.query(contractSOQLStr);
        return serviceContracts;
    }   

    public static Map<Id, ServiceContract> getServiceContractMap(Set<Id> contractIds){
        Map<Id, ServiceContract> scMap = new Map<Id, ServiceContract>();
        if(contractIds != null && !contractIds.isEmpty()){
            String contractSOQLStr = ServiceContractUtil.getServiceContractSOQLString();
            contractSOQLStr += ' where Id in :contractIds ' ;
            for(ServiceContract scObj : Database.query(contractSOQLStr)){
                scMap.put(scObj.Id, scObj);
            }           
        }
        return scMap;
    }

    public static List<ServiceContract> getServiceContractsByProposalIds(Set<Id> proposalIds){
        String contractSOQLStr = ServiceContractUtil.getServiceContractSOQLString();
        String activeString = 'Active';
        contractSOQLStr += ' where Proposal__c in :proposalIds and Status =:activeString ' ;
        List<ServiceContract>  serviceContracts = Database.query(contractSOQLStr);
        return serviceContracts;
    }

    
    public static String getServiceContractSOQLString(){
        String soqlString = 'Select Id, Name, AccountId,TE_Fund_name__c,Customer_Mailing_Address__c,referral__c,offer__c,contactid, Agreement_Number__c, Customer_Name__c, Cust_Ref_Num__c, Home_Address__c,Proposal__c, City__c, State__c, Zip__c, Install_Partner__c, Account.Id, Account.Name, ';
        soqlString += ' Large_system_NTP_form__c, EPC_Price__c, Cash_Grant_Eligible__c, Transfer_Watt__c, Transfer_Price__c, Status__c,Previous_Status__c,ERP_Customer_Name__c, Opportunity__c, ';
        soqlString += ' Process_Install_Date__c, ';
        soqlString += ' (Select Id,M1_Status__c, M2_Status__c, M1_proof_panel_inverter_delivery__c, M3_Status__c, name, M1_Proof_Upload_Date__c, M2_Proof_Upload_Date__c, ';
        soqlString += ' Customer_Signoff__c, Revised_SR_Signoff__c, SR_Signoff__c,  ';
        soqlString += ' Partner_PTO_proof_date__c, M3_Proof_Upload_Date__c, M1_Proof_Count__c, M2_Proof_Count__c, M3_Proof_Count__c, M2_proof_substantial_completion__c, Meter_Registration_Date__c, Rebate_Form_Sent__c, NTP_Granted__c,PTO__c from Service_Contract_Events__r), ';
        soqlString += ' (Select Id, Status__c, name, Asset__c, System_Size_DC__c, Manufacturer__c, Model__c, Serial_Number__c, Type__c from Assets__r where Serial_Number__c !=null and Status__c = \'Active\' ) ';
        soqlString += ' From ServiceContract  ';
        
        //Meter_Test_Date__c
        return soqlString;
    }       
    
    
    
    public static void updatePartnerDetailsOnServiceContract(Set<Id> scIds, Map<Id,Service_Contract_Partner_Rel__c> assetInstallerMap, Map<Id,Service_Contract_Partner_Rel__c> assetSalesPartnerMap){
        if(scIds != null && !scIds.isEmpty()){
            List<ServiceContract> scList = new List<ServiceContract>();
            List<ServiceContract> scIPList = new List<ServiceContract>();
            for(ServiceContract scObj : [Select Id, name, Installed_By__c, Install_partner__c, Install_Partner_Id__c, Sales_Organization_Id__c, Sales_Organization__c from ServiceContract where Id in :scIds]){
                if(assetInstallerMap != null && assetInstallerMap.containsKey(scObj.Id)){
                    scObj.Install_Partner__c = assetInstallerMap.get(scObj.Id).Account_Name__c;
                    scObj.Install_Partner_Id__c = assetInstallerMap.get(scObj.Id).Account__c;
                }
                if(assetSalesPartnerMap != null && assetSalesPartnerMap.containsKey(scObj.Id)){
                    scObj.Sales_Organization__c = assetSalesPartnerMap.get(scObj.Id).Account_Name__c;
                    scObj.Sales_Organization_Id__c = assetSalesPartnerMap.get(scObj.Id).Account__c;
                }
                if(scObj.Installed_By__c == null && scObj.Install_Partner_Id__c != null){
                    scObj.Installed_By__c = (scObj.Install_Partner_Id__c == Label.Sunrun_Inc_Id) ? Label.Sunrun_Installation_Service : scObj.Install_Partner_Id__c;
                }
                scList.add(scObj);
  /*              if(scObj.Install_Partner_Id__c != null){
                  scIPList.add(scObj);
                  if(!scIPList.isEmpty()){
                    ServiceContractUtil.photoRequirement(scIPList);
                  }
                }    */
            }
            System.debug('scList: ' + scList);
            if(scList != null && !scList.isEmpty()){
                update scList;
            }
        }
    }
    
    public static void updateServiceContracts(Map<Id, Proposal__c> proposalMap){
        if(proposalMap != null && !proposalMap.isEmpty()){
            List<ServiceContract> scList = ServiceContractUtil.getServiceContractsByProposalIds(proposalMap.keySet());
            List<Service_Contract_Event__c> modifiedSCEventList = new List<Service_Contract_Event__c>();
            for(ServiceContract scObj : scList){
                Service_Contract_Event__c scEventObj;
                if(scObj.Service_Contract_Events__r != null && !scObj.Service_Contract_Events__r.isEmpty()){
                    scEventObj = scObj.Service_Contract_Events__r[0];
                }
                System.debug('scEventObj: ' + scEventObj);
                
                Proposal__c proposalObj = proposalMap.get(scObj.proposal__c);
                Boolean modified = false;
                if(scEventObj != null && scEventObj.Customer_Signoff__c == null && proposalObj.Customer_SignOff_Date__c != null){
                    scEventObj.Customer_Signoff__c = Date.newInstance(proposalObj.Customer_SignOff_Date__c.year(),proposalObj.Customer_SignOff_Date__c.month(),proposalObj.Customer_SignOff_Date__c.day());
                    modified = true;
                }
                
                if(scEventObj != null &&  scEventObj.SR_Signoff__c == null && proposalObj.SR_Signoff__c != null ){ 
                    scEventObj.SR_Signoff__c = Date.newInstance(proposalObj.SR_Signoff__c.year(),proposalObj.SR_Signoff__c.month(),proposalObj.SR_Signoff__c.day());
                    modified = true;
                }

                if(scEventObj != null &&  proposalObj.Revised_SR_Signoff__c != null ){ 
                    scEventObj.Revised_SR_Signoff__c = Date.newInstance(proposalObj.Revised_SR_Signoff__c.year(),proposalObj.Revised_SR_Signoff__c.month(),proposalObj.Revised_SR_Signoff__c.day());
                    modified = true;
                }
                                
                if(modified){
                    modifiedSCEventList.add(scEventObj);
                }
            }
            
            if(modifiedSCEventList != null && !modifiedSCEventList.isEmpty()){
                update modifiedSCEventList;
            }
        }
    }

    public static String getSCNameFromOptyNumber(String optyNumber){
        String result = '';
        if(optyNumber != null && optyNumber != ''){
            List<String> stringList = optyNumber.split('-');
            if(stringList.size() == 2){
                result = stringList[1];
            }
        }
        return result;
    }

    public static String getProjectNameFromOptyNumber(String optyNumber){
        String result = '';
        if(optyNumber != null && optyNumber != ''){
            List<String> stringList = optyNumber.split('-');
            if(stringList.size() ==2){
                result = stringList[1];
                result = 'PR-' + result;
            }
        }
        return result;
    }
    
    public static Proposal__c getProposal(String proposalId)
    {
        String  fieldsString = ProposalToServiceContractGenerationUtil.getProposalFieldsString();
        String proposalSelectStatement = 'select Id, Name, Proposal_Name__c, Original_Proposal_ID__c, System_Size_CEC_AC__c, Opportunity__r.AccountId, Opportunity__r.Deal_Id__C,  Opportunity__r.Payment_Mode__c, Opportunity__r.Id, Opportunity__r.Average_Monthly_Electric_Bill__c, Opportunity__r.Average_Monthly_Electricity_Usage__c, ';
        proposalSelectStatement += ' stage__c, Proposal_Scenarios__c, Tax_on_Installation__c, ';
        proposalSelectStatement += ' Original_Proposal_ID__r.Id, Original_Proposal_ID__r.Opportunity__c, Opportunity__r.Opportunity_Number__c, ';
        proposalSelectStatement += ' Opportunity__r.Site_Audit_Scheduled__c, Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingState,  Opportunity__r.Account.BillingCountry, Opportunity__r.Account.BillingPostalCode ' +  fieldsString + ' from Proposal__c where Id = \'' + proposalId + '\'';      
        
        return Database.query(proposalSelectStatement);   
    }
    
    public static void updateMilestoneProofInformation(Set<Id> m1AssetIds, Set<Id> m2AssetIds, Set<Id> m3AssetIds){
        
        Set<Id> serviceContractIds = new Set<Id>();
        if (m1AssetIds != null && !m1AssetIds.isEmpty()){
            serviceContractIds.addall(m1AssetIds);
        }
        if (m2AssetIds != null && !m2AssetIds.isEmpty()){
            serviceContractIds.addall(m2AssetIds);
        }
        if (m3AssetIds != null && !m3AssetIds.isEmpty()){
            serviceContractIds.addall(m3AssetIds);
        }   
        Map<Id, ServiceContract> scMap = getServiceContractMap(serviceContractIds);
        List<Service_Contract_Event__c> scEventList = new List<Service_Contract_Event__c>();
        if (m1AssetIds != null && !m1AssetIds.isEmpty())
        {
            
            for(Id m1SCId : m1AssetIds)
            {
                ServiceContract scObj = scMap.get(m1SCId);
                if(scObj.Service_Contract_Events__r != null && !scObj.Service_Contract_Events__r.isEmpty()){
                    Service_Contract_Event__c eventObj = scObj.Service_Contract_Events__r[0];
                
                    eventObj.M1_Proof_Upload_Date__c = null;       
                    eventObj.M1_Status__c = null;
                    eventObj.M1_Denied_Comments__c = null;
                    eventObj.M1_proof_panel_inverter_delivery__c = null;
                    
                    scEventList.add(eventObj);
                }
            }
        }
        else if (m2AssetIds != null && !m2AssetIds.isEmpty())
        {
            for(Id m2SCId :m2AssetIds){
                ServiceContract scObj = scMap.get(m2SCId);
                if(scObj.Service_Contract_Events__r != null && !scObj.Service_Contract_Events__r.isEmpty()){
                    Service_Contract_Event__c eventObj = scObj.Service_Contract_Events__r[0];
                    eventObj.M2_Proof_Upload_Date__c = null;       
                    eventObj.M2_Status__c = null;
                    eventObj.M2_Denied_Comments__c = null;
                    eventObj.M2_proof_substantial_completion__c = null;
                    scEventList.add(eventObj);
                }
            }
        }
        else if (m3AssetIds != null && !m3AssetIds.isEmpty())
        {

            for(Id m3SCId :m3AssetIds){
                ServiceContract scObj = scMap.get(m3SCId);
                if(scObj.Service_Contract_Events__r != null && !scObj.Service_Contract_Events__r.isEmpty()){
                    Service_Contract_Event__c eventObj = scObj.Service_Contract_Events__r[0];
                    eventObj.M3_Proof_Upload_Date__c = null;       
                    eventObj.M3_Status__c = null;
                    eventObj.M3_Denied_Comments__c = null;
                    
                    scEventList.add(eventObj);
                }
            }
        }
        if (!scEventList.isEmpty())
        {
            update scEventList;
        }

    }
    
    public static void updateMilestoneProofInformation(Set<Id> scIds, Set<Id> caseIds){
        Map<Id, ServiceContract> scMap = getServiceContractMap(scIds);
        List<Case> casesToUpdate = new List<Case>();
        List<Service_Contract_Event__c> scEventList = new List<Service_Contract_Event__c>();
        for(Case caseRec:[Select Id,Status, Milestone_Proof_Type__c,Electrical_sign_off__c, Milestone_Proof_Approval_Date__c, Denied_Comment__c, Service_Contract__c from Case where Id in:caseIds And Service_Contract__c != null And RecordTypeId In (Select Id from RecordType Where SobjectType = 'Case' And DeveloperName = 'Milestone_Proof')])
        {
            ServiceContract scObj = scMap.get((ID)caseRec.Service_Contract__c);
            if(scObj.Service_Contract_Events__r != null && !scObj.Service_Contract_Events__r.isEmpty()){
                Service_Contract_Event__c eventObj = scObj.Service_Contract_Events__r[0];
                if (caseRec.Status == 'Request Approval' && caseRec.Milestone_Proof_Type__c == 'M1 Proof')
                {
                    eventObj.M1_Status__c = 'Pending';
                    eventObj.M1_proof_panel_inverter_delivery__c = null;
                }           
                else if (caseRec.Status == 'Request Approval' && caseRec.Milestone_Proof_Type__c == 'M2 Proof')
                {
                    eventObj.M2_Status__c = 'Pending';
                    eventObj.M2_proof_substantial_completion__c = null;
                }           
                else if (caseRec.Status == 'Request Approval' && caseRec.Milestone_Proof_Type__c == 'M3 Proof')
                {
                    eventObj.M3_Status__c = 'Pending';
                }           
                else if (caseRec.Status == 'M1 Proof Approved' && caseRec.Milestone_Proof_Type__c == 'M1 Proof')
                {
                    eventObj.M1_Status__c = 'Approved';
    //              assetRec.M1_proof_panel_inverter_delivery__c = date.today();
                    eventObj.M1_proof_panel_inverter_delivery__c = eventObj.M1_Proof_Upload_Date__c;
                    caseRec.Milestone_Proof_Approval_Date__c = date.today();
    
                    casesToUpdate.add(caseRec);
                    
                }           
                else if (caseRec.Status == 'M2 Proof Approved (non meter test)' && caseRec.Milestone_Proof_Type__c == 'M2 Proof')
                {
                    eventObj.M2_Status__c = 'Approved';
    //              assetRec.M2_proof_substantial_completion__c = date.today();
                    eventObj.M2_proof_substantial_completion__c = eventObj.M2_Proof_Upload_Date__c;
                    eventObj.Electrical_Sign_Off__c = caseRec.Electrical_Sign_Off__c ;
                    caseRec.Milestone_Proof_Approval_Date__c = date.today();
                    casesToUpdate.add(caseRec);
                }           
                else if (caseRec.Status == 'M3 PTO Approved' && caseRec.Milestone_Proof_Type__c == 'M3 Proof')
                {
                    eventObj.M3_Status__c = 'Approved';
                    
                    caseRec.Milestone_Proof_Approval_Date__c = date.today();
                    casesToUpdate.add(caseRec);
                }           
                else if (caseRec.Status == 'M1 Proof Denied' && caseRec.Milestone_Proof_Type__c == 'M1 Proof')
                {
                    eventObj.M1_Status__c = 'Denied';
                    eventObj.M1_Proof_Upload_Date__c = null;
                    eventObj.M1_proof_panel_inverter_delivery__c = null;
                    eventObj.M1_Denied_Comments__c = caseRec.Denied_Comment__c;
    
                    caseRec.Milestone_Proof_Approval_Date__c = null;
                    casesToUpdate.add(caseRec);
                }           
                else if ((caseRec.Status == 'M2 Proof Denied (non meter test)' || caseRec.Status == 'M2 Meter Test Denied')&& caseRec.Milestone_Proof_Type__c == 'M2 Proof')
                {
                    eventObj.M2_Status__c = 'Denied';
                    eventObj.M2_Proof_Upload_Date__c = null;
                    eventObj.M2_proof_substantial_completion__c = null;
                    eventObj.M2_Denied_Comments__c = caseRec.Denied_Comment__c;
    
                    caseRec.Milestone_Proof_Approval_Date__c = null;
                    casesToUpdate.add(caseRec);
                }           
                else if (caseRec.Status == 'M3 PTO Denied' && caseRec.Milestone_Proof_Type__c == 'M3 Proof')
                {
                    eventObj.M3_Status__c = 'Denied';
                    eventObj.M3_Proof_Upload_Date__c = null;
                    eventObj.M3_Denied_Comments__c = caseRec.Denied_Comment__c;
    
                    caseRec.Milestone_Proof_Approval_Date__c = null;
                    casesToUpdate.add(caseRec);
                }    
                scEventList.add(eventObj);      
            }                
                    
            if (!scEventList.isEmpty())
            {
                update scEventList;
            }
            if (!casesToUpdate.isEmpty())
            {
                update casesToUpdate;
            }
        }
    }
    
     //Return the AssetDetails 
    public static String getAssetSOQL(){
      String scEventSQLQuery = 'Select  Serial_Number__c,ServiceContract__r.name, ServiceContract__r.Customer_Name__c,';
      scEventSQLQuery += 'Monitoring_Site_ID__c,Vendor__c,Status__c,Meter_Type__c,LastModifiedDate from Asset__c'; 
      return scEventSQLQuery;
    }
    
    public static String getServiceContractEventSOQL(){
       String scEventSQLQuery = ' Select Id, name, Service_Contract__r.Id, Service_Contract__r.name, Service_Contract__r.Account.Id,  Service_Contract__r.EPC_Price__c, Service_Contract__r.Large_system_NTP_form__c,  ' ;
        scEventSQLQuery += ' Service_Contract__r.Agreement_Number__c ,Service_Contract__r.install_partner__c,Service_Contract__r.Account.Name, Service_Contract__r.Home_Address__c, Service_Contract__r.Customer_Name__c, Service_Contract__r.Cust_Ref_Num__c, Service_Contract__r.Customer_Mailing_Address__c, ';
        scEventSQLQuery += ' NTP_Granted__c, PTO__c, Meter_Registration_Date__c ,M1_Proof_Upload_Date__c, M2_Proof_Upload_Date__c, M3_Proof_Upload_Date__c, M1_proof_panel_inverter_delivery__c, M2_proof_substantial_completion__c,Meter_Test_Date__c ';
        scEventSQLQuery += ' from Service_Contract_Event__c ';
        return scEventSQLQuery;
    }

    public static String ptoValidationRule(ServiceContract scObj, Service_Contract_Event__c scEventObj){
        String result = 'SUCCESS';
        Set<String> assetStatus = new Set<String>();
        assetStatus.add('Removed - Permanent');
        assetStatus.add('Deactivated');
        assetStatus.add('Redeployed');
        
        if(scObj != null && scEventObj != null){
            List<Asset__c> assetList = new List<Asset__c>();
            if(scObj.assets__r != null && !scObj.assets__r.isEmpty()){
                for(Asset__c assetObj : scObj.assets__r){
                    if(assetObj.type__c == ASSET_TYPE_METER && assetObj.serial_number__c != null && assetObj.serial_number__c != ''){
                        assetList.add(assetObj);
                    }
                }
            }                
            if(scEventObj.PTO__c != null && (scEventObj.Meter_Registration_Date__c == null || assetList.isEmpty()) &&
                scObj.status__c != null && !assetStatus.contains(scObj.status__c)){
                result = 'PTO Date cannot be specified if Meter Serial Num and Meter Registration Date are not also specified. Likewise, Meter Serial Num and Meter Registration Date are required if PTO Date is populated.';
            }

        }
        return result;
    }
    
    public static boolean isSCEfieldsModified(Service_Contract_Event__c newSCE, Service_Contract_Event__c oldSCE){
     boolean fieldsModifiedOnSCE;
        if (newSCE != null && oldSCE != Null) {
            if(newSCE.Completion_of_Construction__c!=oldSCE.Completion_of_Construction__c || newSCE.M1_proof_panel_inverter_delivery__c!=oldSCE.M1_proof_panel_inverter_delivery__c || newSCE.M2_proof_substantial_completion__c!=oldSCE.M2_proof_substantial_completion__c){
                fieldsModifiedOnSCE = true;
            }
            else
                fieldsModifiedOnSCE = false;
        }
     return fieldsModifiedOnSCE;  
    }
    
    public static Set<String> scTaskName = new Set<String>();
    public static void updateSCEvents(Boolean isInsert, Boolean isUpdate, List<Service_Contract_Event__c> newList, Map<Id, Service_Contract_Event__c> newMap, Map<Id, Service_Contract_Event__c> oldMap){
        Set<Id> scIds = new Set<Id>();
        Set<Id> transferPriceIds = new Set<Id>();
        Set<Id> transferPriceEventIds = new Set<Id>();
        Set<Id> ptoValidationSCIDs = new Set<Id>();
        Set<Id> ptoValidationEventIDs = new Set<Id>();
        Set<Id> SCEids = new Set<Id>();
        Set<Id> SCids2 = new Set<Id>();
        list<ServiceContract> toBeUpdateSCList = new List<ServiceContract>();
        Map<String, Id> scMap = new  Map<String, Id>();
        Map<String, String> taskNameMap = new  Map<String, String>();
                
        for(Service_Contract_Event__c scEventObj : newList){
            Service_Contract_Event__c oldSCEventObj;
            if(isUpdate != null && isUpdate == true && oldMap != null){
                oldSCEventObj = oldMap.get(scEventObj.Id);
            }

            if(scEventObj.PTO__c != null && ((oldSCEventObj != null && oldSCEventObj.PTO__c != scEventObj.PTO__c))){
                ptoValidationEventIDs.add(scEventObj.Id);
                ptoValidationSCIDs.add(scEventObj.service_contract__c);
            }
            if(oldSCEventObj != null && oldSCEventObj.Meter_Registration_Date__c == null && scEventObj.Meter_Registration_Date__c != null){
                String uniqueString = scEventObj.Service_Contract__c + Label.WFM_Submit_Meter_Registration;
                if(!scTaskName.contains(uniqueString)){
                    scTaskName.add(uniqueString);
                    taskNameMap.put(scEventObj.Service_Contract__c + Label.WFM_Submit_Meter_Registration, Label.WFM_Submit_Meter_Registration);
                    scMap.put(scEventObj.Service_Contract__c + Label.WFM_Submit_Meter_Registration, scEventObj.Service_Contract__c);
                }
            }
            if(oldSCEventObj != null && oldSCEventObj.M1_proof_panel_inverter_delivery__c == null && scEventObj.M1_proof_panel_inverter_delivery__c != null){
                String uniqueString = scEventObj.Service_Contract__c + Label.WFM_Approve_M1_Proof;
                if(!scTaskName.contains(uniqueString)){
                    scTaskName.add(uniqueString);
                    taskNameMap.put(scEventObj.Service_Contract__c + Label.WFM_Approve_M1_Proof, Label.WFM_Approve_M1_Proof);
                    scMap.put(scEventObj.Service_Contract__c + Label.WFM_Approve_M1_Proof, scEventObj.Service_Contract__c);
                }
            }
            if(oldSCEventObj != null && oldSCEventObj.M2_proof_substantial_completion__c == null && scEventObj.M2_proof_substantial_completion__c != null){
                String uniqueString = scEventObj.Service_Contract__c + Label.WFM_Approve_M2_Proof;
                if(!scTaskName.contains(uniqueString)){
                    scTaskName.add(uniqueString);
                    taskNameMap.put(scEventObj.Service_Contract__c + Label.WFM_Approve_M2_Proof, Label.WFM_Approve_M2_Proof);
                    scMap.put(scEventObj.Service_Contract__c + Label.WFM_Approve_M2_Proof, scEventObj.Service_Contract__c);
                }
            }
            if(oldSCEventObj != null && oldSCEventObj.PTO__c == null && scEventObj.PTO__c != null){
                String uniqueString = scEventObj.Service_Contract__c + Label.WFM_Approve_M3_Proof;
                if(!scTaskName.contains(uniqueString)){
                    scTaskName.add(uniqueString);
                    taskNameMap.put(scEventObj.Service_Contract__c + Label.WFM_Approve_M3_Proof, Label.WFM_Approve_M3_Proof);
                    scMap.put(scEventObj.Service_Contract__c + Label.WFM_Approve_M3_Proof, scEventObj.Service_Contract__c);
                }
            }

            if(oldSCEventObj != null && !String.isEmpty(scEventObj.state__c) 
                && ((oldSCEventObj.UCC_Filed__c != scEventObj.UCC_Filed__c && scEventObj.UCC_Filed__c != null && (scEventObj.state__c != 'CA' && scEventObj.state__c != 'California'))
                    || (scEventObj.PUC_Filed__c != null && scEventObj.UCC_Filed__c != null && 
                    (oldSCEventObj.PUC_Filed__c != scEventObj.PUC_Filed__c || oldSCEventObj.UCC_Filed__c != scEventObj.UCC_Filed__c)
                    && (scEventObj.state__c == 'CA' || scEventObj.state__c == 'California')))){
                String uniqueString = scEventObj.Service_Contract__c + Label.WFM_Approve_M3_Proof;
                if(!scTaskName.contains(uniqueString)){
                    scTaskName.add(uniqueString);
                    taskNameMap.put(scEventObj.Service_Contract__c + Label.WFM_Submit_UCC_PUC, Label.WFM_Submit_UCC_PUC);
                    scMap.put(scEventObj.Service_Contract__c + Label.WFM_Submit_UCC_PUC, scEventObj.Service_Contract__c);
                }
            }

            
            Date dateObj = Date.newInstance(2012, 11, 14);
            if (scEventObj.SR_Signoff__c != null && scEventObj.Welcome_Call__c != null && 
                (isInsert || (oldSCEventObj != null && scEventObj.Welcome_Call__c != oldSCEventObj.Welcome_Call__c || scEventObj.SR_Signoff__c != oldSCEventObj.SR_Signoff__c ) ) )
            {
                double busDaysDiff = 0;
                Datetime fromDateTime = scEventObj.SR_Signoff__c;
                Date fromDate = fromDateTime.date();
                Date toDate = scEventObj.Welcome_Call__c;
                integer daysDiff = fromDate.daysBetween(toDate);
                if (daysDiff > 0){
                    integer weekDiff = math.mod(daysDiff,7);
                    integer w1 = fromDate.toStartOfWeek().daysBetween(fromDate);
                    integer w2 = toDate.toStartOfWeek().daysBetween(toDate);
                    if (w1 > w2)
                        weekDiff -= 2;
                    if ((w1 == 0 && w2 == 6) || w1 == 6) 
                        weekDiff--;
                        
                    busDaysDiff = Math.abs((Math.floor(daysDiff/7)*5) + weekDiff);
                }
                scEventObj.Days_until_Welcome_Call_Made__c = busDaysDiff;
            }
            if((isUpdate) && (scEventObj.Grant_Application_Date__c == null && scEventObj.service_contract__c != null)){
                //scIds.add(scEventObj.service_contract__c);
                transferPriceIds.add(scEventObj.service_contract__c);
                transferPriceEventIds.add(scEventObj.Id);
            }       
        boolean FieldsModified;
            
        FieldsModified = isSCEfieldsModified(scEventObj , oldSCEventObj);
            
        if(FieldsModified != null && FieldsModified==true){
           SCids2.add(scEventObj.service_contract__c);
         }
        
        }
        scIds.addall(transferPriceIds);
        scIds.addall(ptoValidationSCIDs);
        if(!SCids2.isEmpty()){
           scMapForSCEventTrigger2 = getServiceContractMap(SCids2);
         for(Id scID : SCids2){
           ServiceContract SCobj = scMapForSCEventTrigger2.get(scID);
           SCobj.Process_Install_Date__c = true;
           toBeUpdateSCList.add(SCobj);
         }
         if(!toBeUpdateSCList.isEmpty()){
         update toBeUpdateSCList;
         }
        }
        //Map<Id, ServiceContract> scMap = new Map<Id, ServiceContract>();
        if(scIds != null && !scIds.isEmpty()){
            scMapForSCEventTrigger = getServiceContractMap(scIds);
        }
        
        if(ptoValidationEventIDs != null && !ptoValidationEventIDs.isEmpty()){
            for(Id scEventId : ptoValidationEventIDs){
                Service_Contract_Event__c scEventObj = newMap.get(scEventId);
                if(scEventObj != null && scMapForSCEventTrigger != null && scMapForSCEventTrigger.containsKey(scEventObj.service_contract__c)){
                    ServiceContract scObj = scMapForSCEventTrigger.get(scEventObj.service_contract__c);
                    String result = ptoValidationRule(scObj, scEventObj);
                    if(result != 'SUCCESS' ){
                        scEventObj.adderror(result);
                    }
                }
            }
        }

        if(scMap != null && !scMap.isEmpty()){
            wfUtil.completeSCTasks(scMap, taskNameMap);
        }
    
    }
    
    //public static void updateServiceContractTransferPrice(Boolean isInsert, Boolean isUpdate, List<Asset__c> new, Map<Id, ServiceContract> newMap, Map<Id, ServiceContract> oldMap){
    //
    //  if(isInsert == true)
    //      return;
    //  List<ServiceContract> modifiedSCList = calculateTransferPrice(newMap.keySet(), newMap.values());
    //}

        
    //public static List<ServiceContract> calculateTransferPrice(Set<Id> scIds, List<ServiceContract> scList){
    //    List<ServiceContract> modifiedSCList = new List<ServiceContract>();
    //    Map<Id, Service_Contract_Event__c> scToSCEventMap = new Map<Id, Service_Contract_Event__c>();
    //    if(scIds != null && !scIds.isEmpty()){
    //        for(Service_Contract_Event__c scEventObj : [Select Id, service_contract__c, Grant_Application_Date__c from Service_Contract_Event__c where 
    //                                                        service_contract__c in :scIds and Grant_Application_Date__c = null]){
    //            scToSCEventMap.put(scEventObj.service_contract__c, scEventObj);
    //        }
    
    //        Map<Id, Asset__c> scToAssetMap = new Map<Id, Asset__c>();
    //        for(Asset__c assetObj : [Select Id, ServiceContract__c, Status__c, System_Size_DC__c from Asset__c where 
    //                                                        ServiceContract__c in :scIds and    Status__c = 'Active' and type__c = 'Asset']){
    //            scToAssetMap.put(assetObj.ServiceContract__c, assetObj);
    //        }       
            
    //        for(ServiceContract scObj : scList){
    //            if(scToAssetMap.containsKey(scObj.Id) && scToSCEventMap.containsKey(scObj.Id)){
    //                Asset__c assetObj = scToAssetMap.get(scObj.Id);
    //                Double systemSize = (assetObj.System_Size_DC__c != null && assetObj.System_Size_DC__c > 0) ? assetObj.System_Size_DC__c : 1;
    //                scObj.Transfer_Price__c = ((scObj.Transfer_Watt__c != NULL) ? scObj.Transfer_Watt__c : 0) * systemSize;
    //                modifiedSCList.add(scObj);
    //            }
    //        }
    //    }
    //   return modifiedSCList;
    //}

    public static void processServiceContractPostUpdate(Boolean isInsert, Boolean isUpdate, Map<Id, ServiceContract> newMap, Map<Id, ServiceContract> oldMap){
        Map<Id, Id> scContactMap = new Map<Id, Id>();
        if(isUpdate != null && isUpdate == true){
            for(ServiceContract sc: newMap.values()){
                ServiceContract oldScObj;
                if(oldMap != null && oldMap.containsKey(sc.Id)){
                    oldScObj = oldMap.get(sc.Id); 
                }
                if(sc.ContactId != null && oldScObj != null && oldScObj.contactId != sc.ContactId){
                    scContactMap.put(sc.Id, sc.ContactId);
                }
            }
        }       
        updateServiceContractEmail(scContactMap);
    }
    
    public static void updateServiceContractEmail(Set<Id> contactIds){
        Map<Id, Id> scContactMap = new Map<Id, Id>();
        if(contactIds != null && !contactIds.isEmpty()){
            for(ServiceContract scObj : [Select Id, contactId from ServiceContract where contactId in :contactIds]){
                scContactMap.put(scObj.Id, scObj.contactId);
            }
            updateServiceContractEmail(scContactMap);
        }
    }
    
    public static void updateServiceContractEmail(Map<Id, Id> scContactMap){
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        List<Service_Contract_Event__c> modifiedSCEvents = new List<Service_Contract_Event__c>();
        Map<Id, Service_Contract_Event__c> scEventMap = new Map<Id, Service_Contract_Event__c>();
        if(scContactMap != null && !scContactMap.isEmpty()){
            contactMap = new Map<Id, Contact>([Select Id, email, name from Contact where Id in :scContactMap.values()]);
            for(Service_Contract_Event__c scEventObj : [Select Id, Customer_s_Email__c, Service_Contract__c FROM  Service_Contract_Event__c where 
                                                        Service_Contract__c in :scContactMap.keySet()]){
                Id contactId =  scContactMap.get(scEventObj.Service_Contract__c);
                Contact contactObj = contactMap.get(contactId);
                if(contactObj != null){
                    scEventObj.Customer_s_Email__c = contactObj.email;
                    modifiedSCEvents.add(scEventObj);
                }
            }
            if(modifiedSCEvents != null && !modifiedSCEvents.isEmpty()){
                update modifiedSCEvents;
            }
        }       
    }
    
    public static void SetBillingMethod(ServiceContract scObj, String paymentMethod){
        String billingMethod = (scObj.Billing_Method__c != null) ? scObj.Billing_Method__c : '';
        if(!billingMethod.contains('Full Upfront') && !billingMethod.contains('Customer Owned')){
            if(paymentMethod == 'Recurring'){
                scObj.Billing_Method__c = 'Recurring';
            }else{
                scObj.Billing_Method__c = 'Pay by Check';
            }
        }           
    }

    public static void SetBillingMethod(ServiceContract scObj, Proposal__C proposalObj, String paymentMethod, String oldBillingMethod){
        System.debug('paymentMethod: ' + paymentMethod);
        System.debug('scObj.Billing_Method__c: ' + scObj.Billing_Method__c);
        System.debug('proposalObj.Billing_Method__c: ' + proposalObj.Billing_Method__c);
        System.debug('scObj.Proposal__c: ' + scObj.Proposal__c);
        System.debug('proposalObj.Id: ' + proposalObj.Id);
        
        if(scObj.Proposal__c != proposalObj.Id){
            if(scObj.Id == null){
                String billingMethod = (scObj.Billing_Method__c != null) ? scObj.Billing_Method__c : '';
                if(paymentMethod == RECURRING && !billingMethod.contains('Full Upfront') && !billingMethod.contains('Customer Owned')){
                    scObj.Billing_Method__c = RECURRING;
                }
            }else{
                String proposalBillingMethod = (proposalObj.Billing_Method__c == null) ? '' : proposalObj.Billing_Method__c;
                System.debug('proposalBillingMethod: ' + proposalBillingMethod);
                proposalBillingMethod = proposalBillingMethod.toLowerCase();
                if(proposalBillingMethod == 'pay by check' && oldBillingMethod == RECURRING){
                    scObj.Billing_Method__c = oldBillingMethod;
                }
            } 
            
        }else if(scObj.Id != null){
            scObj.Billing_Method__c = oldBillingMethod;
        }
    }

    public static Map<Id, Proposal__C> contractInfoProposals = new Map<Id, Proposal__C>();
    public static Map<Id, Proposal__C> getContractInfoProposals(List<Id> proposalIds){
        Map<Id, Proposal__C> resultMap = new Map<Id, Proposal__C>();
        Set<Id> tempProposalIds = new Set<Id>();
        for(Id proposalId : proposalIds){
            if(contractInfoProposals.containskey(proposalId)){
                resultMap.put(proposalId, contractInfoProposals.get(proposalId));
            }else{
                tempProposalIds.add(proposalId);
            }
        }
        
        if(!tempProposalIds.isEmpty()){
            for(Proposal__c proposalObj : [SELECT Id, Est_Yr_1_Generation__c, Price_Per_kWh__c, X20_Year_Estimated_Generation__c, 
                                                       Year_1_monthly_payment__c, Base_Lease_Payment_Amount__c, 
                                                       Annual_Monthly_Payment_Escalator__c, First_Year_Generation_Estimate__c, 
                                                       Production_Estimate_Source__c, Last_Customer_Signed_Proposal__c,Signed__c, Proposal_Source__c, 
                                                       Change_Order_Information__c,Monthly_SunRun_Bill__c,Escalation_Rate__c,Total_Production_over_Agreement_Length__c,Monthly_solar_prod_ratio__c
                                                       FROM Proposal__c where Id in :tempProposalIds]){
                
                contractInfoProposals.put(proposalObj.Id, proposalObj);
                resultMap.put(proposalObj.Id, proposalObj);
            }
        }
        return resultMap;
    }
  
    public static void updateServiceContract(Boolean isInsert, Boolean isUpdate, List<ServiceContract> newList, 
                                            Map<Id, ServiceContract> newMap, Map<Id, ServiceContract> oldMap) {
        
        Map<Id, Id> mapOppReferral = new Map<Id, Id>();
        Map<Id, Id> mapOppOffer = new Map<Id, Id>();
        Set<Id> optyIds = new Set<Id>();
        Map<Id, ServiceContract> scMapForTransferPrice = new Map<Id, ServiceContract>();
        Map<Id,Id> serviceContractToProposal = new Map<Id,Id>();
        Map<Id,Id> SrvcToCntrcProposal = new Map<Id,Id>();
        Map<Id, ServiceContract> scMap = new Map<Id, ServiceContract>();
        //serviceContract sce = new serviceContract();                                                
                                                
        for(ServiceContract sc: newList){
            if(isInsert != null && isInsert == true){
                if(sc.Opportunity__c != null){
                    optyIds.add(sc.Opportunity__c);
                }
            }
            //if(isUpdate != null && isUpdate == true && newMap.get(sc.Id).Transfer_Watt__c != oldMap.get(sc.Id).Transfer_Watt__c){
             //   scMapForTransferPrice.put(sc.Id, sc);
            //}
            
            System.debug('Start: Payment Method Update');
            if(isUpdate != null && isUpdate == true && newMap.get(sc.Id).Payment_Mode__c != oldMap.get(sc.Id).Payment_Mode__c){ 
                String paymentMode = (newMap.get(sc.Id).Payment_Mode__c != null && newMap.get(sc.Id).Payment_Mode__c != '') ? newMap.get(sc.Id).Payment_Mode__c : '';
                SetBillingMethod(sc, paymentMode);              
            }
            System.debug('End: Payment Method Update');
                       
            if(sc.Proposal__c != null && (isinsert || isUpdate) && sc.Proposal_Source__c != null && sc.Proposal_Source__c == 'BB'   ) { //&& !checkRecursive.scIds.Contains(sc.id)
                serviceContractToProposal.put(sc.Id, sc.Proposal__c); 
                // checkRecursive.scIds.add(sc.id);
            }
            
        }
                                                
        Map<Id, Proposal__c> proposalMp = new Map<Id, Proposal__c>();
        List<Proposal__c> proposalList = new List<Proposal__c>();
       
         if(serviceContractToProposal != null && !serviceContractToProposal.isEmpty()){  
                /*                                                 
                proposalMp = new Map<Id, Proposal__c>([SELECT Id, Est_Yr_1_Generation__c, Price_Per_kWh__c, X20_Year_Estimated_Generation__c, 
                                                       Year_1_monthly_payment__c, Base_Lease_Payment_Amount__c, 
                                                       Annual_Monthly_Payment_Escalator__c, First_Year_Generation_Estimate__c, 
                                                       Production_Estimate_Source__c, Last_Customer_Signed_Proposal__c,Signed__c, Proposal_Source__c, 
                                                       Change_Order_Information__c,Monthly_SunRun_Bill__c,Escalation_Rate__c,Total_Production_over_Agreement_Length__c,Monthly_solar_prod_ratio__c
                                                       FROM Proposal__c 
                                                       WHERE id IN :serviceContractToProposal.values()]);
                */
                proposalMp =  getContractInfoProposals(serviceContractToProposal.values());   
                System.debug('>>>>> ProposalMP' + proposalMp );
                                         
         }
                                                
          for(Id scId: serviceContractToProposal.keySet()){
                Id proposalId = serviceContractToProposal.get(scId);
                if(proposalMp.containsKey(proposalId)) {
                   Proposal__c prop = proposalMp.get(proposalId);
                    
                    if(prop.Proposal_Source__c != null && prop.Proposal_Source__c == ProposalUtil.BLACK_BIRD) {
                        if(prop.Last_Customer_Signed_Proposal__c != null ){
                            SrvcToCntrcProposal.put(scId, Prop.Last_Customer_Signed_Proposal__c);
                            
                        }
                        else if (prop.Change_Order_Information__c != null ) {
                        if (( prop.Proposal_Source__c.equals('BB') && prop.Signed__c && (prop.Change_Order_Information__c.containsIgnoreCase('CUSTOMER_CHANGE_ORDER') || 
                                                                                         prop.Change_Order_Information__c.containsIgnoreCase('FULL_PROPOSAL')))){
                                
                            SrvcToCntrcProposal.put(scId, Prop.id);
                            
                        }
                        system.debug('>>> SrvcToCntrcProposal Cust Facing' + SrvcToCntrcProposal);
                    }    
                  }
                   
                }    
            }     
           
     
            if(SrvcToCntrcProposal != null && !SrvcToCntrcProposal.isEmpty()){
                
               /* proposalMp.putAll([SELECT ID, Est_Yr_1_Generation__c, Price_Per_kWh__c, X20_Year_Estimated_Generation__c, 
                                   Year_1_monthly_payment__c, Base_Lease_Payment_Amount__c, 
                                   Annual_Monthly_Payment_Escalator__c, First_Year_Generation_Estimate__c, Proposal_Source__c, Signed__c,Change_Order_Information__c ,
                                   Production_Estimate_Source__c, Last_Customer_Signed_Proposal__c,Monthly_SunRun_Bill__c,Escalation_Rate__c, Total_Production_over_Agreement_Length__c,Monthly_solar_prod_ratio__c
                                   FROM Proposal__c 
                                   WHERE id IN :SrvcToCntrcProposal.values()]); */
                
               proposalMp.putAll(getContractInfoProposals(SrvcToCntrcProposal.values()));  
                System.debug(' count' + proposalMp.size() +'>>>>> ProposalMP' + proposalMp  );
            }
           list<serviceContract> newSC = new list<serviceContract>();                                    
     for(serviceContract sc : newlist ) {
            
             
       if(sc.Proposal__c != null && (isinsert || (isUpdate) ) ){ 
             id proposalId = SrvcToCntrcProposal.get(sc.id);
             if(proposalId != null && proposalMp.containsKey(proposalId) ){
                  Proposal__c proposalObj = proposalMp.get(proposalId);
             
             system.debug('>>' + proposalObj);
              if (proposalObj.Proposal_Source__c != null && proposalObj.Change_Order_Information__c != null ) {
                 if ( proposalObj.Proposal_Source__c.equals('BB') ){
    
                                     system.debug('>>> proposalObj.Est_Yr_1_Generation__c ' + proposalObj.Est_Yr_1_Generation__c);
                                     sc.Est_Yr_1_Generation__c = proposalObj.Est_Yr_1_Generation__c;
                                     sc.Price_per_kWh__c = proposalObj.Price_Per_kWh__c;
                                     sc.X20_Year_Estimated_Generation__c= proposalObj.Total_Production_over_Agreement_Length__c;
                                     if(sc.Billing_Type__c != null && sc.Billing_Type__c == 'Fixed monthly PPA with annual reset'){
                                         sc.Year_1_monthly_payment__c = proposalObj.Monthly_SunRun_Bill__c;
                                             sc.base_lease_payment_amount__c = null;  
                                     }
                                     else { 
                                         sc.Year_1_monthly_payment__c = null;
                                         sc.Base_Lease_Payment_Amount__c = proposalObj.Monthly_SunRun_Bill__c;
                                     }
                                     sc.Annual_Monthly_Payment_Escalator__c = proposalObj.Escalation_Rate__c;
                                     sc.Production_Estimate_Source__c = proposalObj.Production_Estimate_Source__c;
                                     sc.First_Year_Generation_Estimate__c = proposalObj.First_Year_Generation_Estimate__c;
                                     sc.Monthly_solar_prod_ratio__c = proposalObj.Monthly_solar_prod_ratio__c;
                                     system.debug('>>> sce.Est_Yr_1_Generation__c ' + sc.Est_Yr_1_Generation__c);                        
                      }  
                   }
                }
             }                                      
         }  
                                               
        if(optyIds != null && !optyIds.isEmpty()){
            for(Opportunity o:[select Id, Referral__c, Offer__c,Sales_Representative__c, Payment_Mode__c, Sales_Representative__r.Account.Corporate_Email_Address__c from Opportunity where id in :optyIds]){
                mapOppReferral.put(o.Id, o.Referral__c);
                mapOppOffer.put(o.Id, o.Offer__c);
            }           
        }

        for(ServiceContract sc: newList){
            if(isInsert && sc.Opportunity__c != null && mapOppReferral.containsKey(sc.Opportunity__c)){
                sc.Referral__c = mapOppReferral.get(sc.Opportunity__c);
            }
            if(isInsert && sc.Opportunity__c != null && mapOppOffer.containsKey(sc.Opportunity__c)){
                sc.Offer__c = mapOppOffer.get(sc.Opportunity__c);
            }
        }
       // calculateTransferPrice(scMapForTransferPrice.keySet(), scMapForTransferPrice.values());
       if(!isInsert && isUpdate != null && isUpdate == true ){
         for(ServiceContract sc: newList){
          if(sc.Install_Partner_Id__c != oldMap.get(sc.Id).Install_Partner_Id__c || sc.M1_Terms__c != oldMap.get(sc.Id).M1_Terms__c){
              sc.Process_Install_Date__c = true;
             }
            }
       }
    }
    
    public static void photoreq(List<Service_Contract_Event__c> sceList, map<Id,Service_Contract_Event__c> old_map, map<Id,Service_Contract_Event__c> new_map){
     
     Map<Id, ServiceContract> scMapForSCEventTrigger3 = new Map<Id, ServiceContract>();
     set<Id> scIds = new Set<Id>();
     list<ServiceContract> updateSClist = new List<ServiceContract>();
     for(Service_Contract_Event__c sce : sceList){
        if(sce.M1_proof_panel_inverter_delivery__c != null && sce.M1_proof_panel_inverter_delivery__c != old_map.get(sce.Id).M1_proof_panel_inverter_delivery__c ){ //
           scIds.add(sce.Service_Contract__c);        
        }
     }
     if(!scIds.isempty()){
      scMapForSCEventTrigger3 = getServiceContractMap(scIds);
       for(Id scId : scIds){
         ServiceContract SCobj = scMapForSCEventTrigger3.get(scId);
         updateSClist.add(SCobj);
         system.debug('UpdateSClist'+updateSClist);
       }
     }
     if(!updateSClist.isEmpty() && !scIds.isEmpty()){
       ServiceContractUtil.photoRequirement(updateSClist, scIds);
     }
    }
    public static void photoRequirement(List<ServiceContract> newList, Set<Id> servConIds){
       
       List<ServiceContract> scList = new List<ServiceContract>();
       Map<Id,Partner_Contract__c> ptrMap = new Map<Id,Partner_Contract__c>();
       Set<String> scAccSet = new Set<String>();
       List<ServiceContract> updateSClist = new List<ServiceContract>();
       
       List<ServiceContract> sconlist = [select Id, Install_Partner_Id__c from ServiceContract where id in: servConIds];
       
       if(!sconlist.isEmpty()){
         for(servicecontract sc : sconlist){
           scAccSet.add(sc.Install_Partner_Id__c);
         }
       }
       if(!scAccSet.isEmpty()){  
        for(Partner_Contract__c ptrobj : [select Id, Account__c, Photo_Requirements_Apply__c,Contract_Type__c from Partner_Contract__c where Account__c in: scAccSet and Contract_Status__c = 'Active' and Contract_Type__c in ( 'Full Service Contract', 'Full Service', 'Install', 'Install Only') ]){
          ptrMap.put(ptrobj.Account__c,ptrobj);
        }
       }
       if(!ptrMap.isEmpty()){
         for(ServiceContract sc:sconlist){
           if(ptrMap.containsKey(sc.Install_Partner_Id__c)){
             sc.Photo_Requirements_Apply__c = ptrMap.get(sc.Install_Partner_Id__c).Photo_Requirements_Apply__c;
           system.debug('Photo Requirement'+sc.Photo_Requirements_Apply__c);
             updateSClist.add(sc);
           }
         }
        }
       if(!updateSClist.isEmpty()){
         update updateSClist;
       } 
    }
    
    public static void createServiceContractSharing(Map<Id, Set<Id>> scInstallerMap, Set<Id> installerIds){
        
        List<ServiceContractShare> scObjectShares = new List<ServiceContractShare>();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        if(installerIds != null && !installerIds.isEmpty()){
            for(Account accountObj : [Select Id, group_Id__c from Account where Id in :installerIds and group_Id__c != null and group_Id__c  != '']){
                accountMap.put(accountObj.Id, accountObj);
            }
        }
        
        if(scInstallerMap != null && !scInstallerMap.isEmpty()){
            for(Id scId : scInstallerMap.keySet()){
                Set<id> tempInstallerIds = scInstallerMap.get(scId);
                for(Id installerId: tempInstallerIds){
                    if(accountMap != null && accountMap.containsKey(installerId)) {
                        Account accountObj = accountMap.get(installerId);
                        //ServiceContractShare share = new ServiceContractShare();
                        //share.ParentId = scId;
                        //share.UserOrGroupId = accountObj.group_Id__c;
                        //share.AccessLevel = 'edit';             
                        Id userOrGroupId = (Test.isRunningTest()) ? UserInfo.getUserId() : accountObj.Group_Id__c;
                        ServiceContractShare share = createSCSharing(userOrGroupId, scId);
                        scobjectShares.add(share);                 
                    }
                }
                
            }
        }

        if(scObjectShares != null && !scObjectShares.isEmpty()){
            Database.SaveResult[] shareInsertResult = Database.insert(scObjectShares,false);
        }
        
    }
    public static void createServiceContractSharingSales(Map<Id,Set<Id>> scSalesOrgMap,Set<Id> salesIds){
        List<ServiceContractShare> scObjectShares = new List <ServiceContractShare>();
        Map<Id,Account> accountMap = new Map<Id,Account>();
        if(salesIds != null && !salesIds.isEmpty()){
            for(Account accountObj :[Select Id,group_Id__c from Account where Id in: salesids and group_Id__c!=null and group_Id__c!='']){
                accountMap.put(accountObj.Id,accountObj);
            }
        }
        if(scSalesOrgMap != null && !scSalesOrgMap.isEmpty()){
            for(Id scId : scSalesOrgMap.keySet()){
                Set<Id> tempSalesIds = scSalesOrgMap.get(scId);
                for(Id salesId : tempSalesIds){
                    if(accountMap != null && accountMap.containsKey(salesId)){
                        Account accountObj = accountMap.get(salesId);
                       // ServiceContractShare share = new ServiceContractShare();
                       // share.ParentId = scId;
                       // share.UserOrGroupId = accountObj.Group_Id__c;
                       // share.AccessLevel = 'edit';
                       Id userOrGroupId = (Test.isRunningTest()) ? UserInfo.getUserId() : accountObj.Group_Id__c;
                       ServiceContractShare share = createSCSharing(userOrGroupId, scId);
                       scobjectShares.add(share);
                    }
                }
            }
        }
        if(scObjectShares != null && !scObjectShares.isEmpty()){
            Database.SaveResult[] shareInsertResult = Database.insert(scObjectShares,false);
        }
    }
    
    public static ServiceContractShare createSCSharing(Id groupId, Id scId){
        ServiceContractShare share = new ServiceContractShare();
        share.ParentId = scId;
        share.UserOrGroupId = groupId;
        share.AccessLevel = 'edit'; 
        return share;
    }

    public static boolean isPTONull(Id opportunityId){
        Boolean ptoNull = true;
        if(opportunityId != null){
            List<Service_Contract_Event__c> scEventList = [Select Id, pto__c from Service_Contract_Event__c where 
                                                            Service_Contract__r.Opportunity__c = :opportunityId AND pto__c != NULL];
            if(scEventList != null && !scEventList.isEmpty()){
                ptoNull = false;
            }
        }
        return ptoNull;
    }
    
    //#1
    //@future
    public static void updateServiceContractsForAccount(Map<Id, boolean> accountIdMap, DateTime modifiedDateTime){
        if (Test.isRunningTest())
            return;        
        List<ServiceContract> modifiedSCList = new List<ServiceContract>();
        if((isServiceContractCreation != true) && accountIdMap != null && !accountIdMap.isEmpty()){
            for(ServiceContract scObj : [Select Id, description, RelatedObjects_Last_Modified_Date__c, AccountId, Account.BillingCity, Account.BillingStreet, Account.BillingState, 
                                            Account.BillingCountry, Account.BillingPostalCode  from ServiceContract where AccountId in :accountIdMap.keySet()]){
                scObj.RelatedObjects_Last_Modified_Date__c = modifiedDateTime;
                if(accountIdMap.get(scObj.AccountId) != null && accountIdMap.get(scObj.AccountId) == true){
                    scObj.description = ServiceContractUtil.getAddressString(scObj.Account); 
                    //scObj.description = scObj.Account.BillingStreet + ', ' + scObj.Account.BillingCity + ', ' + scObj.Account.BillingState + ', ' + scObj.Account.BillingCountry + ', '+ scObj.Account.BillingPostalCode ;
                } 
                modifiedSCList.add(scObj);
            }
        }
        if(modifiedSCList != null && !modifiedSCList.isEmpty()){
            update modifiedSCList;
        }
        
    }

    public static void updateSCDescriptionForAccount(Map<Id, boolean> accountIdMap){
        if (Test.isRunningTest())
            return;    
        updateSCDescriptionForAccount_Future(accountIdMap);
    }

    @future
    public static void updateSCDescriptionForAccount_Future(Map<Id, boolean> accountIdMap){      
        List<ServiceContract> modifiedSCList = new List<ServiceContract>();
        if((isServiceContractCreation != true) && accountIdMap != null && !accountIdMap.isEmpty()){
            for(ServiceContract scObj : [Select Id, description, RelatedObjects_Last_Modified_Date__c, AccountId, Account.BillingCity, Account.BillingStreet, Account.BillingState, 
                                            Account.BillingCountry, Account.BillingPostalCode  from ServiceContract where AccountId in :accountIdMap.keySet()]){
                if(accountIdMap.get(scObj.AccountId) != null && accountIdMap.get(scObj.AccountId) == true){
                    scObj.description = ServiceContractUtil.getAddressString(scObj.Account); 
                } 
                modifiedSCList.add(scObj);
            }
        }
        if(modifiedSCList != null && !modifiedSCList.isEmpty()){
            update modifiedSCList;
        }
        
    }

    //#2
    public static void updateServiceContractsForAsset(Set<Id> assetIds, DateTime modifiedDateTime){
        if (Test.isRunningTest())
            return;        
            
        Map<Id, ServiceContract> modifiedSCList = new Map<Id, ServiceContract>();
        if((isServiceContractCreation != true) && assetIds != null && !assetIds.isEmpty()){
            for(Asset__c assetObj : [Select Id, Type__c, Serial_Number__c, ServiceContract__r.Id,  ServiceContract__r.description, ServiceContract__r.RelatedObjects_Last_Modified_Date__c 
                                    from Asset__c where Id in :assetIds and ServiceContract__c != null]){
                if(assetObj.ServiceContract__r != null && assetObj.ServiceContract__r.Id != null){
                    assetObj.ServiceContract__r.RelatedObjects_Last_Modified_Date__c = modifiedDateTime;
                    if(assetObj.Type__c == 'Meter' && assetObj.Serial_Number__c != null && assetObj.Serial_Number__c != '' && 
                        (assetObj.ServiceContract__r.description == null || !assetObj.ServiceContract__r.description.contains(assetObj.Serial_Number__c))){
                        assetObj.ServiceContract__r.description += '; Meter Serial Number: ' + assetObj.Serial_Number__c;
                    }
                    modifiedSCList.put(assetObj.ServiceContract__r.Id, assetObj.ServiceContract__r);
                }
            }
        }
        if(modifiedSCList != null && !modifiedSCList.isEmpty()){
            update modifiedSCList.values();
        }
    }   
    
    //#3
    public static void updateServiceContractsForEvents(Set<Id> relatedObjectIds, DateTime modifiedDateTime){
        if (Test.isRunningTest())
            return;        
        Map<Id, ServiceContract> modifiedSCList = new Map<Id, ServiceContract>();
        if((isServiceContractCreation != true) && relatedObjectIds != null && !relatedObjectIds.isEmpty()){
            for(Service_Contract_Event__c scEventObj : [Select Id, Rebate_Conf_Num__c, SREC_acct__c, Service_Contract__r.description, Service_Contract__r.service_contract_event__c, Service_Contract__r.Id, Service_Contract__r.RelatedObjects_Last_Modified_Date__c 
                                    from Service_Contract_Event__c where Id in :relatedObjectIds and Service_Contract__c != null]){
                if(scEventObj.Service_Contract__r != null && scEventObj.Service_Contract__r.Id != null){
                    scEventObj.Service_Contract__r.RelatedObjects_Last_Modified_Date__c = modifiedDateTime;
                    scEventObj.Service_Contract__r.service_contract_event__c = scEventObj.Id;
                    if(scEventObj.SREC_acct__c != null && scEventObj.SREC_acct__c != '' && 
                        (scEventObj.Service_Contract__r.description == null || !scEventObj.Service_Contract__r.description.contains(scEventObj.SREC_acct__c))){
                        scEventObj.Service_Contract__r.description += '; SREC Acct: ' + scEventObj.SREC_acct__c;
                    }                    
                    if(scEventObj.Rebate_Conf_Num__c != null && scEventObj.Rebate_Conf_Num__c != '' && 
                        (scEventObj.Service_Contract__r.description == null || !scEventObj.Service_Contract__r.description.contains(scEventObj.Rebate_Conf_Num__c))){
                        scEventObj.Service_Contract__r.description += '; Rebate Conf Number: ' + scEventObj.Rebate_Conf_Num__c;
                    }
                    modifiedSCList.put(scEventObj.Service_Contract__r.Id, scEventObj.Service_Contract__r);
                }
            }
        }
        if(modifiedSCList != null && !modifiedSCList.isEmpty()){
            skipSCAuditTrail = true;
            update modifiedSCList.values();
        }
    }

    //#4
    //@future
    public static void updateServiceContractsForContacts(Set<Id> relatedObjectIds, DateTime modifiedDateTime){
        if (Test.isRunningTest())
            return;
        List<ServiceContract> modifiedSCList = new List<ServiceContract>();
         List<Service_Contract_Event__c> modifiedSCEventList = new List<Service_Contract_Event__c>();
        if((isServiceContractCreation != true) && relatedObjectIds != null && !relatedObjectIds.isEmpty()){
           
            for(ServiceContract scObj : [Select Id, contactId, erp_customer_name__c,  RelatedObjects_Last_Modified_Date__c, contact.Name, contact.Email
                                    , (Select Id, Customer_s_Email__c from Service_Contract_Events__r)
                                    from ServiceContract where contactId in :relatedObjectIds]){
                
                System.debug('scObj.contact.Name: ' + scObj.contact.Name);
                scObj.erp_customer_name__c = scObj.contact.Name;
                scObj.RelatedObjects_Last_Modified_Date__c = modifiedDateTime;
                modifiedSCList.add(scObj);
                
                if(scObj.Service_Contract_Events__r != null && !scObj.Service_Contract_Events__r.isEmpty()){
                    System.debug('scObj.contact.Email: ' + scObj.contact.Email);
                    scObj.Service_Contract_Events__r[0].Customer_s_Email__c = scObj.contact.Email;
                    modifiedSCEventList.add(scObj.Service_Contract_Events__r[0]);
                }
            }
        }
        if(modifiedSCList != null && !modifiedSCList.isEmpty()){
            update modifiedSCList;
        }
        
        System.debug('modifiedSCEventList ' + modifiedSCEventList);
        if(modifiedSCEventList != null && !modifiedSCEventList.isEmpty()){
            update modifiedSCEventList;
        }
    }

    //#5
   // public static void updateServiceContractsForInstallPartners(Set<Id> relatedObjectIds, DateTime modifiedDateTime){
    //  if (Test.isRunningTest())
  //          return;
    //    List<ServiceContract> modifiedSCList = new List<ServiceContract>();
   //     if((isServiceContractCreation != true) && relatedObjectIds != null && !relatedObjectIds.isEmpty()){
   //         for(Service_Contract_Partner_Rel__c scEventObj : [Select Id, Account__c, ServiceContract__r.Id, ServiceContract__r.RelatedObjects_Last_Modified_Date__c 
   //                                 from Service_Contract_Partner_Rel__c where Account__c in :relatedObjectIds and ServiceContract__c != null and
   //                                 type__c = 'Install']){
   //             if(scEventObj.ServiceContract__r != null && scEventObj.ServiceContract__r.Id != null){
   //                 scEventObj.ServiceContract__r.RelatedObjects_Last_Modified_Date__c = modifiedDateTime;
   //                 modifiedSCList.add(scEventObj.ServiceContract__r);
   //             }
   //         }
    //    }
   //     if(modifiedSCList != null && !modifiedSCList.isEmpty()){
    //        //update modifiedSCList;
    //    }
   // }
    
    //#6
    public static void updateServiceContractsForContractPG(Set<Id> relatedObjectIds, DateTime modifiedDateTime){
        if (Test.isRunningTest())
            return;
        Map<Id, ServiceContract> modifiedSCList = new Map<Id, ServiceContract>();
        if((isServiceContractCreation != true) && relatedObjectIds != null && !relatedObjectIds.isEmpty()){
            for(Contract_Performance_Guarantee__c contractPGObj : [Select Id, Service_Contract__r.Id, Service_Contract__r.RelatedObjects_Last_Modified_Date__c 
                                    from Contract_Performance_Guarantee__c where Id in :relatedObjectIds and Service_Contract__c != null]){
                if(contractPGObj.Service_Contract__r != null && contractPGObj.Service_Contract__r.Id != null){
                    contractPGObj.Service_Contract__r.RelatedObjects_Last_Modified_Date__c = modifiedDateTime;
                    modifiedSCList.put(contractPGObj.Service_Contract__r.Id, contractPGObj.Service_Contract__r);
                }
            }
        }
        if(modifiedSCList != null && !modifiedSCList.isEmpty()){
            update modifiedSCList.values();
        }
    }

    public static Contact getERPContact(String email){
        Contact erpContactObj;
        if(email != null && email != ''){
            String contactSOQL = ServiceContractUtil.getContactSOQL();
            Boolean erpContact = true;
            contactSOQL += ' WHERE EMAIL =:email and ERP_Contact_of_Record__c =:erpContact ' ;
            List<Contact> erpContactlist =  Database.query(contactSOQL);
           // List<Contact> erpContactlist = [Select Id, email, ERP_Contact_of_Record__c FROM Contact WHERE EMAIL =: email and ERP_Contact_of_Record__c = true];
            if(erpContactlist != null && !erpContactlist.isEmpty()){
                erpContactObj = erpContactlist[0];
            }
        }
        return erpContactObj;
    }
    
    public static void cloneERPContact(Contact sourceContact, Contact targetContact){
        Set<String> notEditableFields = new Set<String>();
        notEditableFields.add('Contact_Number__c');
        notEditableFields.add('LastModifiedById');
        notEditableFields.add('ownerId');
        notEditableFields.add('OwnerId');
        
        if(sourceContact != null &&  targetContact != null){
            String objectName = 'Contact';
            Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
            if (fMap != null){
                //for (String fieldName : fMap.keySet()){ 
                //  if(fieldName)
                //  Object sourceFieldValue = sourceContact.get(fieldName);
                //  targetContact.put(fieldName, sourceFieldValue);          
                //}
                for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                    Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                    if (fd.isCreateable() && fd.isUpdateable() && !(notEditableFields.contains(fd.getName()))){ // field is creatable
                        Object sourceFieldValue = sourceContact.get(fd.getName());
                        targetContact.put(fd.getName(), sourceFieldValue);                    
                    }
                }
            }
            targetContact.ERP_Contact_of_Record__c = true;
        }
    }
    
    public static string getContactSOQLForOptyContactRole(){
        String objectName = 'contact';  
        String soqlString = getCreatableFieldsSOQL(objectName, 'Contact.');
        return soqlString;
    }

    public static string getContactSOQL(){
        String objectName = 'contact';  
        String soqlString = getCreatableFieldsSOQL(objectName, '');
        String returnVal = ' Select ' + soqlString + ' from Contact ';
        return returnVal;
    }
    
    public static string getCreatableFieldsSOQL(String objectName, String relatedObjName){
        String selects = '';
        String soqlQuery = '';
        
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        if (fMap != null){
            
            //for (String fieldName : fMap.keySet()){
            //  selectFields.add(relatedObjName + fieldName);
            //}
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                SYSTEM.debug('fd>>>' +  fd);
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(relatedObjName + fd.getName());
                    SYSTEM.debug('selectFields>>' +  selectFields);
                }
            }
        }
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
        }     
        if(selects != null && selects != ''){
            selects = ', ' + selects;
        }
        soqlQuery =  relatedObjName + 'Id ' + selects;
        return soqlQuery;
    }
    
    static Map<String, Id> assetRecordTypeMap;
    public static Map<String, Id> getAssetRecordTypes(){
        if(assetRecordTypeMap == null || assetRecordTypeMap.size() ==0){
            assetRecordTypeMap = new Map<String, Id>();
            for(RecordType recordTypeoBJ : [select Id, Name, SobjectType from RecordType 
                                            where SObjectType = 'Asset__c']){
                assetRecordTypeMap.put(recordTypeoBJ.name, recordTypeoBJ.Id);                     
            }
        }
        return assetRecordTypeMap;
    }  
    
    public static String getContactName(Contact contactObj){
        String name = '';
        name = (contactObj.FirstName == null) ? '' : (contactObj.FirstName + ' ') ;
        name += (contactObj.lastName == null) ? '' : (contactObj.lastName) ;
        return name;
    } 

    
    public static void trackFieldChanges(ServiceContract scNew, ServiceContract scOld){
        if (Test.isRunningTest() || skipSCAuditTrail == true)
            return;
            
        try{
            trackSCFieldChanges(scNew, scOld);
        }catch(Exception exp){
            System.debug('exp: ' + exp.getMessage());
        }        
    }
    
    //public static Map<String, Schema.SObjectField> scFieldMap;
    public static Map<String, Service_Contract_History_Fields__c> scFieldMap;
    public static void trackSCFieldChanges(ServiceContract scNew, ServiceContract scOld){        
        if(scNew != null &&  scOld != null){
            if(scFieldMap == null || scFieldMap.size() == 0){
                //scFieldMap = Schema.getGlobalDescribe().get('ServiceContract').getDescribe().Fields.getMap();
                scFieldMap = Service_Contract_History_Fields__c.getAll();
            }
            if (scFieldMap != null){
                Service_Contract_History_Fields__c scFieldHistoryObj;
                for (String fieldName : scFieldMap.keySet()){ // loop through all field tokens (ft)
                    System.debug('fieldName: ' + fieldName);
                    scFieldHistoryObj = scFieldMap.get(fieldName);
                    Object newFieldValue = scNew.get(fieldName);
                    Object oldFieldValue = scOld.get(fieldName);
                    
                    if(newFieldValue != oldFieldValue ){
                        String value1 = String.valueOf(newFieldValue);
                        String value2 = String.valueOf(oldFieldValue);
                        Sunrun_Audit_Trail__c auditTrailObj = new Sunrun_Audit_Trail__c();
                        auditTrailObj.API_Name__c = fieldName;
                        auditTrailObj.Field_Name__c = scFieldHistoryObj.Field_Label__c;
                        auditTrailObj.New_Value__c = value1;
                        auditTrailObj.Previous_Value__c = value2;
                        auditTrailObj.Object_Name__c = 'Service Contract';
                        auditTrailObj.Service_Contract__c = scNew.Id;
                        String keyValue = scNew.Id + '_' + fieldName;
                        scAuditTrail.put(keyValue, auditTrailObj);
                    }                    
                }
            }
        }else if(scNew != null &&  scOld == null){
            System.debug('Created the record ...');
            Sunrun_Audit_Trail__c auditTrailObj = new Sunrun_Audit_Trail__c();
            auditTrailObj.New_Value__c = scNew.Id + '';
            auditTrailObj.Previous_Value__c = 'Created';
            auditTrailObj.Object_Name__c = 'Service Contract Event';
            auditTrailObj.Service_Contract__c = scNew.Id;
            String keyValue = scNew.Id + '_' + auditTrailObj.Object_Name__c;
            scAuditTrail.put(keyValue, auditTrailObj);
        }
    }

    public static void trackFieldChanges(Service_Contract_Event__c scEventNew, Service_Contract_Event__c scEventOld){
        if (Test.isRunningTest())
            return;
        
        try{  
            trackSCEventFieldChanges(scEventNew, scEventOld);
        }catch(Exception exp){
            System.debug('exp: ' + exp.getMessage());
        }

    }
    
    //public static Map<String, Schema.SObjectField> scEventFieldMap;
    public static Map<String, Service_Contract_Event_History_Fields__c> scEventFieldMap;
    public static void trackSCEventFieldChanges(Service_Contract_Event__c scEventNew, Service_Contract_Event__c scEventOld){ 
        
        if(scEventNew != null &&  scEventOld != null){
            if(scEventFieldMap == null ){
                //scEventFieldMap = Schema.getGlobalDescribe().get('Service_Contract_Event__c').getDescribe().Fields.getMap();
                scEventFieldMap = Service_Contract_Event_History_Fields__c.getAll();
            }
            
            if (scEventFieldMap != null){
                Service_Contract_Event_History_Fields__c scEventFieldHistoryObj;
                for (String fieldName : scEventFieldMap.keySet()){ // loop through all field tokens (ft)
                    scEventFieldHistoryObj = scEventFieldMap.get(fieldName);
                    Object newFieldValue = scEventNew.get(fieldName);
                    Object oldFieldValue = scEventOld.get(fieldName);
                    if(newFieldValue != oldFieldValue ){
                        String value1 = String.valueOf(newFieldValue);
                        String value2 = String.valueOf(oldFieldValue);
                        
                        Sunrun_Audit_Trail__c auditTrailObj = new Sunrun_Audit_Trail__c();
                        auditTrailObj.API_Name__c = fieldName;
                        auditTrailObj.Field_Name__c = scEventFieldHistoryObj.Field_Label__c;
                        auditTrailObj.New_Value__c = value1;
                        auditTrailObj.Previous_Value__c = value2;
                        auditTrailObj.Object_Name__c = 'Service Contract Event';
                        auditTrailObj.Service_Contract_Event__c = scEventNew.Id;
                        String keyValue = scEventNew.Id + '_' + fieldName;
                        scEventAuditTrail.put(keyValue, auditTrailObj);
                    }                   
                }
            }
        }else if(scEventNew != null &&  scEventOld == null){
            System.debug('Created the record ...');
            Sunrun_Audit_Trail__c auditTrailObj = new Sunrun_Audit_Trail__c();
            auditTrailObj.New_Value__c = scEventNew.Id + '';
            auditTrailObj.Previous_Value__c = 'Created';
            auditTrailObj.Object_Name__c = 'Service Contract Event';
            auditTrailObj.Service_Contract_Event__c = scEventNew.Id;
            String keyValue = scEventNew.Id + '_' + auditTrailObj.Object_Name__c;
            scEventAuditTrail.put(keyValue, auditTrailObj);
        }
    }

    public static void insertSCAuditTrail(){
        
        try{
            if(scAuditTrail != null && !scAuditTrail.isEmpty()){
                upsert scAuditTrail.values();
            }
        }catch(Exception exp){
            System.debug('exp: ' + exp.getMessage());
        }
        
    }
    
    public static void insertAuditTrail(){
        try{
            if(scEventAuditTrail != null && !scEventAuditTrail.isEmpty()){
                System.debug('auditTrail.values(): ' + scEventAuditTrail.values());
                upsert scEventAuditTrail.values();
            }
        }catch(Exception exp){
            System.debug('exp: ' + exp.getMessage());
        }
    }

 
    public static void updateERPContactDetails(Set<Id> contactIds){
        if (Test.isRunningTest())
            return;
        updateERPContactDetails_Future(contactIds);
    }

    @future
    public static void updateERPContactDetails_Future(Set<Id> contactIds){       
        Map<Id, ServiceContract> modifiedSCMap = new Map<Id, ServiceContract>();
        if(contactIds != null && !contactIds.isEmpty()){
            Map<Id, List<ServiceContract>> scMap = getServiceContracts('Contact', contactIds);
            Map<Id, Contact> contactMap = new Map<Id, Contact>([Select Id, name from Contact where Id in :contactIds]);
            for(Id contactId : contactIds){
                List<ServiceContract> scList = scMap.get(contactId);
                if(scList != null && !scList.isEmpty()){
                    Contact contactObj = contactMap.get(contactId);
                    if(contactObj != null){
                        for(ServiceContract scObj : scList){
                            scObj.erp_customer_name__c = contactObj.name;
                            modifiedSCMap.put(scObj.Id, scObj);
                        }
                    }
                }
            }
            if(modifiedSCMap != null && !modifiedSCMap.isEmpty()){
                update modifiedSCMap.values();
            }
        }
    }
    
    public static void createServiceContract(List<Proposal__c> proposalList){
        Set<Id> proposalIds = new Set<Id>();
        Map<Id, Proposal__c> proposalMap = new Map<Id, Proposal__c>();
        for(Proposal__c proposalObj :proposalList ){
            try{
                System.debug('proposalObj: ' + proposalObj);
                ApexPages.StandardController controller = new ApexPages.StandardController(proposalObj);
                CreateServiceContractController serviceContractController = new CreateServiceContractController(controller);
                String result = serviceContractController.createServiceContract();
                proposalMap.put(proposalObj.Id, proposalObj);
               
            }catch(Exception exp){
                System.debug(exp.getMessage());
            }
        }
        
        List<Proposal__c> modifiedProposals = new List<Proposal__c>();
        Map<Id, List<ServiceContract>> scMap = getServiceContracts('Proposal', proposalMap.keySet());
        for(Proposal__c proposalObj : proposalMap.values()){
            
            if(scMap != null && scMap.containskey(proposalObj.Id)){
                proposalObj.Create_Service_Contract__c = 'No';
                modifiedProposals.add(proposalObj);
            }
        }
        
        if(modifiedProposals != null && !modifiedProposals.isEmpty()){
            update modifiedProposals;
        }
        
    }
    
    public static void UpdateDateCancelledSCE(List<ServiceContract> serviceContList,Map<id,ServiceContract> serviceContOldMap){
        List<Service_Contract_Event__c> sceList=new List<Service_Contract_Event__c>(); 
        for(ServiceContract sc:serviceContList){
            if(sc.Status__c=='Deal Cancelled'&&serviceContOldMap.get(sc.id).status__c!='Deal Cancelled'&&sc.Service_Contract_Event__c!=null)
            {
                Service_Contract_Event__c sce=new Service_Contract_Event__c(id=sc.Service_Contract_Event__c);
                sce.Date_Cancelled__c=system.today(); 
                sceList.add(sce);
            }
        }
        if(!sceList.isempty()){
            update sceList;
        }
    }
    public static String getAddressString(Account accountObj){
        String addressStr = '';
        String street = (accountObj.BillingStreet != null && accountObj.BillingStreet != '' )  ? accountObj.BillingStreet + ', ' : '';
        String city = (accountObj.BillingCity != null && accountObj.BillingCity != '' )  ? accountObj.BillingCity + ', ' : '';
        String state = (accountObj.BillingState != null && accountObj.BillingState != '' )  ? accountObj.BillingState + ', ' : '';
        String country = (accountObj.BillingCountry != null && accountObj.BillingCountry != '' )  ? accountObj.BillingCountry + ', ' : '';
        String postalCode = (accountObj.BillingPostalCode != null && accountObj.BillingPostalCode != '' )  ? accountObj.BillingPostalCode : '';
        addressStr = street + city + state + country + postalCode ;
        return addressStr;
    }
    
    public static void updateNumberOfPhotosForServiceContracts(Set<Id> scIds){
        List<ServiceContract> modifiedServiceContracts = new List<ServiceContract>();
        for(ServiceContract scObj : [Select Id, Number_of_Photos_Uploaded__c,(Select Id, Active__c from SR_Gen_Asset_Attachments__r where Active__c = true) from ServiceContract WHERE Id in :scIds]){
            scObj.Number_of_Photos_Uploaded__c = (scObj.SR_Gen_Asset_Attachments__r != null) ? scObj.SR_Gen_Asset_Attachments__r.size() : 0;
            modifiedServiceContracts.add(scObj);
        }
        
        if(!modifiedServiceContracts.isEmpty()){
            update modifiedServiceContracts;
        }
    }
    
    public static List<Sobject> cloneSobject(Set<Id> objectIds, String objectName){
        List<SObject> newSObjectList = new List<SObject>();
        String soqlString = ServiceContractUtil.getCreatableFieldsSOQL(objectName, '');
        String accountSOQLStr = ' Select ' + soqlString + ' from ' + objectName + ' where Id in :objectIds ';
        for(Sobject tempSobject : Database.query(accountSOQLStr)){
            SObject newSObject = tempSObject.clone(false,true,false,false);
            newSObjectList.add(newSObject);
        }
        return newSObjectList;
    }

    public static List<Sobject> cloneChildObject(Set<Id> parentObjectIds, String objectName, String parentName){
        List<SObject> newSObjectList = new List<SObject>();
        String soqlString = ServiceContractUtil.getCreatableFieldsSOQL(objectName, '');
        String accountSOQLStr = ' Select ' + soqlString + ' from ' + objectName + ' where ' + parentName +   ' in :parentObjectIds ';
        for(Sobject tempSobject : Database.query(accountSOQLStr)){
            SObject newSObject = tempSObject.clone(false,false,false,false);
            newSObjectList.add(newSObject);
        }
        return newSObjectList;
    }
    
    private static Map<Id, ServiceContract> optySCMap;
    public static Map<Id, ServiceContract> getServiceContractForOpty(Set<Id> optyIds){
        Boolean runQuery = false;
        if(optySCMap != null && !optySCMap.isEmpty()){
            for(Id optyId : optyIds){
                if(!optySCMap.containsKey(optyId)){
                    runQuery = true;
                    break;
                }
            }           
        }
        if(optySCMap == null || runQuery == true){
            optySCMap = new Map<Id, ServiceContract>();
            for(ServiceContract scObj : [select id,opportunity__c from ServiceContract where Opportunity__c in:optyIds 
                                            and (Marked_For_Deletion__c = null OR Marked_For_Deletion__c = '' OR Marked_For_Deletion__c = 'No')]){
                optySCMap.put(scObj.opportunity__c, scObj);
            }           
        }
        return optySCMap;
    }

    public static Opportunity cloneDataForSecondProject(Proposal__c proposalObj){
        Opportunity returnOpty;
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(proposalObj.Opportunity__r.AccountId);
        List<Sobject> accountList = ServiceContractUtil.cloneSobject(accountIds, 'Account');
        insert accountList;

        Set<Id> optyIds = new Set<Id>();
        Id optyId = proposalObj.Opportunity__r.Id;
        optyIds.add(proposalObj.Opportunity__r.Id);
        List<Opportunity> optyList = ServiceContractUtil.cloneSobject(optyIds, 'Opportunity');
        optyList[0].accountId = accountList[0].Id;
        initializeOracleERPFields(optyList[0]);
        insert optyList;

        String objectName = 'Contact'; 
        String parentName = 'AccountId';
        List<Contact> contactList = new List<Contact>();
        String soqlString = ServiceContractUtil.getCreatableFieldsSOQL(objectName, '');
        String accountSOQLStr = ' Select ' + soqlString + ' from ' + objectName + ' where ERP_Contact_of_Record__c != true and ' + parentName +   ' in :accountIds ';
        for(Contact tempSobject : Database.query(accountSOQLStr)){
            if(tempSobject.ERP_Contact_of_Record__c == false){
                Contact newSObject = tempSObject.clone(false,false,false,false);
                newSObject.OwnerId = UserInfo.getUserId();
                newSObject.AccountId = accountList[0].Id;
                newSObject.contact_Number__c = null;
                contactList.add(newSObject);
            }
        }
        if(contactList != null && !contactList.isEmpty()){
            insert contactList;
        }
        
        List<OpportunityContactRole> newRoleList = new List<OpportunityContactRole>();
        for(OpportunityContactRole roleObj : [Select Id, ContactId, Role, isPrimary, OpportunityId,contact.lastname,  contact.firstname, contact.Email from OpportunityContactRole where OpportunityId =:optyId]){
            OpportunityContactRole newRoleObj = new OpportunityContactRole();
            newRoleObj.OpportunityId = optyList[0].Id;
            newRoleObj.Role = roleObj.role;
            newRoleObj.IsPrimary = roleObj.IsPrimary;
            for(Contact contactObj : contactList){
                if(roleObj.contact.lastname == contactObj.lastname && roleObj.contact.firstname == contactObj.firstname && roleObj.contact.email == contactObj.email){
                    newRoleObj.contactId = contactObj.Id;
                    break;
                }
            }
            newRoleList.add(newRoleObj);
        }           

        if(newRoleList != null && !newRoleList.isEmpty()){
            insert newRoleList;
        }

        List<Partner_Role__c> newPartnerRoleList = new List<Partner_Role__c>();
        for(Partner_Role__c partnerRole:  [select Id, Contract_Execution_Date__c, CorporatePartner__c, Department__c, Market__c, Market_Assignment__c, Opportunity__c, Partner_Name__c, 
                                            Performance_adder__c, Role__c, SalesRep__c, Sales_Rep_Division__c, Sales_Rep_Email__c, Sales_Rep_Phone__c, Sunrun_fee_adder__c from Partner_Role__c where Opportunity__c = :optyId]){
            Partner_Role__c newRoleObj = new Partner_Role__c();
            newRoleObj.Opportunity__c = optyList[0].Id;
            newRoleObj.Contract_Execution_Date__c = partnerRole.Contract_Execution_Date__c;
            newRoleObj.CorporatePartner__c = partnerRole.CorporatePartner__c; 
            newRoleObj.Department__c = partnerRole.Department__c;
            newRoleObj.Market__c = partnerRole.Market__c;
            newRoleObj.Market_Assignment__c = partnerRole.Market_Assignment__c;
            newRoleObj.Partner_Name__c = partnerRole.Partner_Name__c;
            newRoleObj.Performance_adder__c = partnerRole.Performance_adder__c;
            newRoleObj.Role__c = partnerRole.Role__c;
            newRoleObj.SalesRep__c = partnerRole.SalesRep__c;
            newRoleObj.Sales_Rep_Division__c = partnerRole.Sales_Rep_Division__c;
            newRoleObj.Sales_Rep_Email__c = partnerRole.Sales_Rep_Email__c;
            newRoleObj.Sales_Rep_Phone__c = partnerRole.Sales_Rep_Phone__c;
            newRoleObj.Sunrun_fee_adder__c = partnerRole.Sunrun_fee_adder__c;
            newPartnerRoleList.add(newRoleObj);
        }
        if(newPartnerRoleList != null && !newPartnerRoleList.isEmpty()){
            insert newPartnerRoleList;
        }
        returnOpty = optyList[0];
        return returnOpty;
    }

    public static void initializeOracleERPFields(Opportunity optyObj){
        optyObj.Date_when_Site_Audit_was_Scheduled__c = null;
        optyObj.Site_Audit_Completed__c = null;
        optyObj.Site_Audit_Scheduled__c = null;
        optyObj.Job_Type__c = null;
        optyObj.Project_Number__c = null;
        optyObj.Oracle_DC_Watts__c = null;
        optyObj.Project_Status__c = null;
        optyObj.Oracle_Revenue_Amount__c = null;
        optyObj.Permit_Jurisdiction_municipality__c = null;
        optyObj.Oracle_Opportunity_Close_Date__c = null;
        optyObj.Oracle_Project_Created_By__c = null;
        optyObj.Oracle_Revenue_Amount__c = null;
        optyObj.Plans_Completed_Date__c = null;
        optyObj.Plans_Reviewed_Date__c = null;

        optyObj.Project_Creation_Date__c = null;
        optyObj.Actual_Construction_Finish__c = null;
        optyObj.Actual_Construction_Start__c = null;
        optyObj.PV_Designer_Assign_Date__c = null;
        optyObj.PV_module_manufacturer_and_model__c = null;
        optyObj.Elect_PV_Finish_Date__c = null;
        optyObj.Scheduled_Construction_Start_Date__c = null;
        optyObj.Oracle_DC_Watts__c = null;
        optyObj.Oracle_Opportunity_Close_Date__c = null;
        optyObj.SunRun_NTP_Costco_PO_Issued__c = null;
        optyObj.Submit_Final_Interconnection__c = null;
        optyObj.Permitting_Process_Finish_Date__c    = null;
        optyObj.Permit_Jurisdiction_municipality__c = null;
        optyObj.Submit_Final_Interconnection__c = null;
        optyObj.Permitting_Process_Start_Date__c = null;
        optyObj.Layout_Approval_Finish__c = null;
        optyObj.Layout_Approval_Start__c = null;
        optyObj.Launch_date__c = null;
        optyObj.Prospect_Id__c = null;
    }
    private static Set<String> IgnoreSCStatus = new Set<String>();
    public static Set<String> getIgnoreScStatusForVoid(){
        if(IgnoreSCStatus.isEmpty()){
            IgnoreSCStatus.add('08. M1 received, Awaiting M2');
            IgnoreSCStatus.add('09. M2 received, Awaiting PTO');
            IgnoreSCStatus.add('10. PTO Granted, Facility Active');       
        }
        return IgnoreSCStatus;
    } 


    public static Set<String> getNTPStagesForDealCancel()
    {
        if(NTPStagesForDealCancel.isEmpty())
        {
          NTPStagesForDealCancel.add('Deal Cancelled');
          NTPStagesForDealCancel.add('Deal Cancelled due to credit');
         
        }
        return NTPStagesForDealCancel;
    }
    
   
    
}