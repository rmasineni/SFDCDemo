public class CreateServiceContractController{
  
  private Id proposalId;
    private String proposalStage;
    public List<OpportunityContactRole> oppurtunityContactRoles {get;set;}
    public boolean showError {get;set;}
    public boolean showExistingSC {get;set;}
    public boolean overwriteExisting {get;set;}
    public boolean generateNewSC {get;set;}
  public Proposal__c proposalObj;
  private Id replacedProposalId;
  Transient Savepoint sp;

    public CreateServiceContractController(ApexPages.StandardController sc)
    {
      showError = false;
      overwriteExisting = false;
      generateNewSC = false;
      showExistingSC = false;
        proposalId = ((Proposal__c)sc.getRecord()).Id; 
        proposalStage = ((Proposal__c)sc.getRecord()).Stage__c;  
    }
    
  public CreateServiceContractController(){
         proposalId = System.currentPagereference().getParameters().get('id');
         system.debug('proposalId: ' + proposalId);
    }

    public CreateServiceContractController(Id proposalId, String proposalStage){
        this.proposalId = proposalId;
        this.proposalStage = proposalStage;
    }
    
    public PageReference ReturnToProposal()
    {
        PageReference pr = new PageReference('/' + proposalId);
        return pr;    
    }
  public Map<Id, Set<String>> existingContactRoles;
  public Map<Id, Set<String>> existingPartnerRoles;

    public String createServiceContract()
    {
        String returnValue = 'Sucess';
    ServiceContract serviceContract;
        Proposal__c proposal;
        //Set<String> proposalFields;
        //Set<String> assetInformationFields;
        Savepoint sp = Database.setSavepoint();
        try
        {
            ServiceContractUtil.setServiceContractCreation(true);
            List<Create_Service_Contract_Proposal_Stage__c> stages = [select Id, Name from Create_Service_Contract_Proposal_Stage__c where Name = :proposalStage];
            if(stages.size() == 0 || stages == null)
            {
                showError = true;
                returnValue = SunrunErrorMessage.getErrorMessage('ERROR_000025').error_message__c;
                Database.rollback(sp);
                return returnValue;                    
            } 
            
            //Set<String> proposalFields = ProposalToServiceContractGenerationUtil.getProposalFields();
            proposal = ServiceContractUtil.getProposal(proposalId);
      if(proposal.Sunrun_Credit_Status__c == null || proposal.Sunrun_Credit_Status__c != EDPUtil.CREDIT_APPROVED){
        showError = true;
                returnValue = SunrunErrorMessage.getErrorMessage('ERROR_000024').error_message__c; 
                Database.rollback(sp);
                return returnValue;  
            }

      if(proposal.Original_Proposal_ID__c != null && proposal.Opportunity__c != proposal.Original_Proposal_ID__r.Opportunity__c){
        showError = true;
                returnValue = SunrunErrorMessage.getErrorMessage('ERROR_000032').error_message__c; 
                Database.rollback(sp);
                return returnValue;  
            }

      if(proposal.product_type__c != null && (proposal.product_type__c == 'A' || proposal.product_type__c == 'E' || proposal.product_type__c == 'F')
        && proposal.Price_per_kWh__c > 0){
        showError = true;
                returnValue = SunrunErrorMessage.getErrorMessage('ERROR_000027').error_message__c; 
                Database.rollback(sp);
                return returnValue;  
            }            
            
      
      serviceContract = getServiceContract(proposal.Opportunity__r.Id);
            if(serviceContract == null || serviceContract.Id == null){
                serviceContract = new ServiceContract();
                
                List<String> randomNumners = RandomNumberGenerator.getUniqueServiceContractNumbers(1);
                if(randomNumners != null && !randomNumners.isEmpty()){
                    serviceContract.name = randomNumners[0];
                }
            }

      if(serviceContract == null || serviceContract.Id == null || generateNewSC == true){
                serviceContract = new ServiceContract();
                serviceContract.Billing_Notification_Preference__c = 'Email';
        String tempSCName = ServiceContractUtil.getSCNameFromOptyNumber(proposal.Opportunity__r.Opportunity_Number__c);
                if(tempSCName == null || tempSCName == ''){
          List<String> randomNumners = RandomNumberGenerator.getUniqueServiceContractNumbers(1);
                  if(randomNumners != null && !randomNumners.isEmpty()){
                      serviceContract.name = randomNumners[0];
                  }
                }else{
                  serviceContract.name = tempSCName;
                }
      }

            
            if(proposal != null && proposal.stage__c == EDPUtil.SR_OPS_APPROVED && proposal.Proposal_Scenarios__c == ProposalUtil.AS_BUILT 
              && serviceContract != null && serviceContract.Id != null){
              processAsBuiltChangeOrder(proposal, serviceContract);
            }else{
              System.debug('1: serviceContract.Billing_Notification_Preference__c: ' + serviceContract.Billing_Notification_Preference__c);
              invalidateServiceContractAssets(serviceContract);
              
              String result = upsertServiceContract(serviceContract, proposal);
              System.debug('result: ' + result);
              if(result != null && result != ProposalUtil.SUCCESS){
                showError = true;
                  returnValue = result; 
                  Database.rollback(sp);
                  return returnValue;                 
              } 
              
              upsertServiceContractRelatedRecords(serviceContract, proposal, true);  
            }

        }
        catch(DMLException ex)
        {
            System.debug('Exception: ' + ex);
            showError = true;
            String exceptionStr = 'There was a problem creating the Service Contract.  Please contact System Administrator.';
            if(ex.getDmlType(0) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION || ex.getDmlType(0) == StatusCode.REQUIRED_FIELD_MISSING){
                exceptionStr = ex.getDmlMessage(0);
            }
            returnValue = exceptionStr;
            Database.rollback(sp);
            return returnValue;           
        }
        catch(Exception e)
        {
          showError = true;
            System.debug('Exception: ' + e);
            returnValue = 'There was a problem creating the Service Contract.  Please contact System Administrator.';
            Database.rollback(sp);
            return returnValue;           
        }            
        return returnValue;
    }
    
    public PageReference overwriteExistingSC(){
      overwriteExisting = true;
      PageReference pageRef = create();
      return pageRef;
    }

    public PageReference generateNewServiceContract(){
      generateNewSC = true;
      PageReference pageRef;
      
      if(proposalObj == null){
        return null;
      }
    try{
      sp = Database.setSavepoint();

      Set<Id> accountIds = new Set<Id>();
        accountIds.add(proposalObj.Opportunity__r.AccountId);
        List<Sobject> accountList = ServiceContractUtil.cloneSobject(accountIds, 'Account');
        insert accountList;

        Set<Id> optyIds = new Set<Id>();
        Id optyId = proposalObj.Opportunity__r.Id;
        accountIds.add(proposalObj.Opportunity__r.Id);
        List<Opportunity> optyList = ServiceContractUtil.cloneSobject(accountIds, 'Opportunity');
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
      
      List<Proposal__c> modifiedProposals = new List<Proposal__c>();
      proposalObj.Opportunity__c = optyList[0].Id;
      if(replacedProposalId != null){
        List<Proposal__c> replacedProposalsList = [Select Id, name, stage__c from Proposal__c where Id =:replacedProposalId];
        if(!replacedProposalsList.isEmpty()){
          replacedProposalsList[0].stage__c = EdpUtil.SR_OPS_APPROVED;
          modifiedProposals.add(replacedProposalsList[0]);
        }
      }
      modifiedProposals.add(proposalObj);
      update modifiedProposals;
      pageRef = createSCImpl();      
      return pageRef;             
    }catch(DMLException ex){
            showError = true;
            System.debug('Exception: ' + ex);
            String exceptionStr = 'There was a problem creating the Service Contract.  Please contact System Administrator.';
            if(ex.getDmlType(0) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION || ex.getDmlType(0) == StatusCode.REQUIRED_FIELD_MISSING){
                exceptionStr = ex.getDmlMessage(0);
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, exceptionStr));
            Database.rollback(sp);
            return null;           
        }catch(Exception e){
           showError = true;   
            System.debug('Exception: ' + e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was a problem creating the Service Contract.  Please contact System Administrator.'));
            Database.rollback(sp);
            return null;           
        } 
      //PageReference pageRef = create();
      return pageRef;
    }
    
    public PageReference create(){
    sp = Database.setSavepoint();
    PageReference pageRef = createSCImpl();
    return pageRef;
    }
    
  public PageReference createSCImpl(){
    
    showExistingSC = false; 
    showError = false;
        ServiceContract serviceContract;
        Proposal__c proposal;

        try
        {
            ServiceContractUtil.setServiceContractCreation(true);
            List<Create_Service_Contract_Proposal_Stage__c> stages = [select Id, Name from Create_Service_Contract_Proposal_Stage__c where Name = :proposalStage];
            if(stages.size() == 0 || stages == null)
            {
                 showError = true; 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, SunrunErrorMessage.getErrorMessage('ERROR_000025').error_message__c));
                Database.rollback(sp);
                return null;                    
            } 
            
            //Set<String> proposalFields = ProposalToServiceContractGenerationUtil.getProposalFields();
            proposal = ServiceContractUtil.getProposal(proposalId);
            proposalObj = proposal;
            if(proposal.Sunrun_Credit_Status__c == null || proposal.Sunrun_Credit_Status__c != EDPUtil.CREDIT_APPROVED){
                showError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, SunrunErrorMessage.getErrorMessage('ERROR_000024').error_message__c));
                Database.rollback(sp);
                return null;  
            }

      if(overwriteExisting == true && proposal.Original_Proposal_ID__c != null && proposal.Opportunity__c != proposal.Original_Proposal_ID__r.Opportunity__c){
        showError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, SunrunErrorMessage.getErrorMessage('ERROR_000032').error_message__c));
                Database.rollback(sp);
                return null;  

            }

      if(proposal.product_type__c != null && (proposal.product_type__c == 'A' || proposal.product_type__c == 'E' || proposal.product_type__c == 'F')
        && proposal.Price_per_kWh__c > 0){
                showError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, SunrunErrorMessage.getErrorMessage('ERROR_000027').error_message__c));
                Database.rollback(sp);
                return null;   
            }
            
            serviceContract = getServiceContract(proposal.Opportunity__r.Id);
            if(overwriteExisting == false && generateNewSC == false && proposal.Proposal_Scenarios__c != ProposalUtil.AS_BUILT 
              && serviceContract != null && serviceContract.Id != null){
        showExistingSC = true;   
        replacedProposalId = (serviceContract.Proposal__r.stage__c == EDPUtil.REPLACED_BY) ? serviceContract.Proposal__r.Id : null;
        String addressStr = ServiceContractUtil.getAddressString(proposal.Opportunity__r.Account);     
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The home address \'' + addressStr + '\' is associated with an existing service contract ' + serviceContract.name ));
                Database.rollback(sp);
                System.debug(sp);
                return null;                
            }         
      
      if(serviceContract == null || serviceContract.Id == null || generateNewSC == true){
                serviceContract = new ServiceContract();
                String tempSCName = ServiceContractUtil.getSCNameFromOptyNumber(proposal.Opportunity__r.Opportunity_Number__c);
                if(tempSCName == null || tempSCName == ''){
          List<String> randomNumners = RandomNumberGenerator.getUniqueServiceContractNumbers(1);
                  if(randomNumners != null && !randomNumners.isEmpty()){
                      serviceContract.name = randomNumners[0];
                  }
                }else{
                  serviceContract.name = tempSCName;
                }
      }
      
      if(generateNewSC == false && proposal != null && proposal.stage__c == EDPUtil.SR_OPS_APPROVED 
        && proposal.Proposal_Scenarios__c == ProposalUtil.AS_BUILT 
              && serviceContract != null && serviceContract.Id != null){
        processAsBuiltChangeOrder(proposal, serviceContract);
            }else{
              invalidateServiceContractAssets(serviceContract);
              
              String result = upsertServiceContract(serviceContract, proposal);
              System.debug('result: ' + result);
              if(result != null && result != ProposalUtil.SUCCESS){
                  showError = true;
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, result));
                  Database.rollback(sp);
                  return null;                
              }
              if(generateNewSC == true){
          upsertServiceContractRelatedRecords(serviceContract.Id, proposal.Id, true); 
              }else{
                upsertServiceContractRelatedRecords(serviceContract, proposal, true); 
              }
            }
              
        }catch(DMLException ex){
            showError = true;
            System.debug('Exception: ' + ex);
            String exceptionStr = 'There was a problem creating the Service Contract.  Please contact System Administrator.';
            if(ex.getDmlType(0) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION || ex.getDmlType(0) == StatusCode.REQUIRED_FIELD_MISSING){
                exceptionStr = ex.getDmlMessage(0);
            }
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, exceptionStr));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            Database.rollback(sp);
            return null;           
        }catch(Exception e){
           showError = true;   
            System.debug('Exception: ' + e);
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was a problem creating the Service Contract.  Please contact System Administrator.'));
           //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            Database.rollback(sp);
            return null;           
        }            
                
        PageReference pr = new PageReference('/' + serviceContract.Id);
        pr.SetRedirect(true);
        return pr;
    }
    
    
    private ServiceContract getServiceContract(Id opportunityId){
        ServiceContract existingSCObj;
        String activeStr = ServiceContractUtil.ACTIVE;
        String fieldsString = ProposalToServiceContractGenerationUtil.getServiceContractFieldsString();
        String serviceContractFields = 'select Id, Name, StartDate, EndDate, Service_Contract_Status__c, ERP_Customer_Name__c, description, ContactId ' + fieldsString;
        if(!fieldsString.contains('Billing_Notification_Preference__c')){
          serviceContractFields += ', Billing_Notification_Preference__c ';
        }
        serviceContractFields += ', As_Built_Size__c, As_Built_Production__c ';
        serviceContractFields += ', Proposal__r.Id, Proposal__r.Stage__c ';
      serviceContractFields += ', (select Id, Name, Status__c, type__c, System_Size_CEC_AC__c from Assets__r where Status__c =:activeStr ) ';
    serviceContractFields += ', (select Id, Type__c, Contact__c from Service_Contract_Contact_Rels__r) ';
    serviceContractFields += ', (select Id, Account__c, Type__c from Service_Contract_Partner_Rels__r) ';// 
        serviceContractFields += ' from ServiceContract where Service_Contract_Status__c =:activeStr and Opportunity__c =:opportunityId ';      
        List<ServiceContract> activeServiceContracts = Database.query(serviceContractFields);  
        if(activeServiceContracts != null && !activeServiceContracts.isEmpty()){
            existingSCObj = activeServiceContracts[0];
        }
    
    existingContactRoles = new Map<Id, Set<String>>();
      if(existingSCObj != null && existingSCObj.Id != null && existingSCObj.Service_Contract_Contact_Rels__r != null
        && !existingSCObj.Service_Contract_Contact_Rels__r.isEmpty()){
         for(Service_Contract_Contact_Rel__c contactRelObj : existingSCObj.Service_Contract_Contact_Rels__r){
           if(contactRelObj.Type__c != null && contactRelObj.Type__c != '' && contactRelObj.Contact__c != null){
             String roleStr = (contactRelObj.Type__c.contains('Homeowner') ? 'Homeowner' : (contactRelObj.Type__c.contains('Billing') ? 'Billing' :  (contactRelObj.Type__c.contains('Credit') ? 'Credit' :  contactRelObj.Type__c))); 
             Set<String> roles = existingContactRoles.containsKey(contactRelObj.Contact__c) ? existingContactRoles.get(contactRelObj.Contact__c) : new Set<String>();
             roles.add(roleStr);
             existingContactRoles.put(contactRelObj.Contact__c, roles);
           }
      }  
      }
    existingPartnerRoles = new Map<Id, Set<String>>();
      if(existingSCObj != null && existingSCObj.Id != null && existingSCObj.Service_Contract_Partner_Rels__r != null
        && !existingSCObj.Service_Contract_Partner_Rels__r.isEmpty()){
         for(Service_Contract_Partner_Rel__c partnerRelObj : existingSCObj.Service_Contract_Partner_Rels__r){
           if(partnerRelObj.Type__c != null && partnerRelObj.Type__c != '' && partnerRelObj.Account__c != null){
             Set<String> roles = existingPartnerRoles.containsKey(partnerRelObj.Account__c) ? existingPartnerRoles.get(partnerRelObj.Account__c) : new Set<String>();
             roles.add(partnerRelObj.Type__c);
             existingPartnerRoles.put(partnerRelObj.Account__c, roles);
           }
      }  
      }
    System.debug('existingPartnerRoles: ' + existingPartnerRoles);
      System.debug('existingContactRoles1: ' + existingContactRoles);

        return existingSCObj;
    }
    
    
    private void invalidateServiceContractAssets(ServiceContract existingSCObj)
    {
        Id serviceContractId = null;
        List<Asset__c> updatedAssets = new List<Asset__c>();
        String activeStr = ServiceContractUtil.ACTIVE;
       if(existingSCObj!=null){
      // if(existingSCObj.Assets__r != null && !existingSCObj.Assets__r.isEmpty()){
      //  for(Asset__c asset: existingSCObj.Assets__r)
        for(Asset__c asset: [select  Id, Name, Status__c, type__c, System_Size_CEC_AC__c,ServiceContract__c from Asset__c where ServiceContract__c =:existingSCObj.Id and status__c=:activeStr] )
            {
                if(asset.Type__c != null && asset.Type__c == ServiceContractUtil.ASSET_TYPE_METER){
                    continue;
                }else{

                    if(asset.Type__c != null && asset.Type__c == ServiceContractUtil.ASSET){
                        OriginalSystemSizeCECAC = asset.System_Size_CEC_AC__c;
                    } 
                    asset.Status__c = ServiceContractUtil.INACTIVE;
                    updatedAssets.add(asset);
                }
            }
        }
        if(updatedAssets != null && !updatedAssets.isEmpty()){
            update updatedAssets;
        }     
    }
    
    private List<Service_Contract_Partner_Rel__c> createPartnerRelationshipsFromOpportunity(ServiceContract contract)
    {
        List<Service_Contract_Partner_Rel__c> serviceContractPartnerRelationships = new List<Service_Contract_Partner_Rel__c>();
        Service_Contract_Partner_Rel__c serviceContractPartner;
        if(contract.Opportunity__c != null)
        {
            
            //List<OpportunityPartner> oppurtunityPartners = [select Id, AccountToId, Role, OpportunityId from OpportunityPartner where OpportunityId = :contract.Opportunity__c];
            //for(OpportunityPartner partner: oppurtunityPartners)
            //{
            //    serviceContractPartner = new Service_Contract_Partner_Rel__c(ServiceContract__c = contract.Id, Type__c = partner.Role, Account__c = partner.AccountToId );
            //    serviceContractPartnerRelationships.Add(serviceContractPartner);          
            //}         
            
            List<Partner_Role__c> partnerRolesPartner = [select Id, Partner_Name__r.Id, Role__c from Partner_Role__c where Opportunity__c = :contract.Opportunity__c];
            for(Partner_Role__c partnerRole: partnerRolesPartner )
            {
              Boolean isRoleAlreadyExists = false;
                if(partnerRole.Role__c != null && partnerRole.Role__c != ''){
              if(existingPartnerRoles != null && existingPartnerRoles.containsKey(partnerRole.Partner_Name__r.Id)){
                    Set<String> existingRoleTypes = existingPartnerRoles.get(partnerRole.Partner_Name__r.Id);
                    System.debug('existing Partner Roles: ' + existingRoleTypes);
                    if(existingRoleTypes != null && existingRoleTypes.contains(partnerRole.Role__c)){
                      isRoleAlreadyExists = true;
                    }
                  }      
                }  
                if(!isRoleAlreadyExists){  
                  serviceContractPartner = new Service_Contract_Partner_Rel__c(ServiceContract__c = contract.Id, Type__c = partnerRole.Role__c, Account__c = partnerRole.Partner_Name__r.Id);
                  serviceContractPartnerRelationships.Add(serviceContractPartner);
                }          
            }                            
        }
        return serviceContractPartnerRelationships;   
    }
    
    private List<Service_Contract_Contact_Rel__c> createContactRelationshipsFromOpportunity(ServiceContract contract)
    {
        List<Service_Contract_Contact_Rel__c> serviceContractContactRelationships = new List<Service_Contract_Contact_Rel__c>();
        Service_Contract_Contact_Rel__c serviceContractContact;
        if(contract.Opportunity__c != null)
        {
            System.debug('existingContactRoles: ' + existingContactRoles);
            //List<OpportunityContactRole> oppurtunityContactRoles = [select Id, ContactId, Role, OpportunityId from OpportunityContactRole where OpportunityId = :contract.Opportunity__c];
            for(OpportunityContactRole contactRole: oppurtunityContactRoles)
            {
        Boolean isRoleAlreadyExists = false;
        if(contactRole.Role != null && contactRole.Role != ''){
          String roleStr = (contactRole.Role.contains('Homeowner') ? 'Homeowner' : (contactRole.Role.contains('Billing') ? 'Billing' :  (contactRole.Role.contains('Credit') ? 'Credit' :  contactRole.Role))); 
          if(existingContactRoles != null && existingContactRoles.containsKey(contactRole.ContactId)){
                    Set<String> existingRoleTypes = existingContactRoles.get(contactRole.ContactId);
                    System.debug('existingRoleTypes: ' + existingRoleTypes);
                    if(existingRoleTypes != null && existingRoleTypes.contains(roleStr)){
                      isRoleAlreadyExists = true;
                    }
                  }
        }
        System.debug('isRoleAlreadyExists: ' + isRoleAlreadyExists);
                if(!isRoleAlreadyExists){
                  serviceContractContact = new Service_Contract_Contact_Rel__c(ServiceContract__c = contract.Id, Type__c = contactRole.Role, Contact__c = contactRole.ContactId);
                  serviceContractContactRelationships.Add(serviceContractContact);
                }          
            }                
        }
        return serviceContractContactRelationships;    
    }
    
    private Asset__c createAsset(Set<String> assetInformationFields, ServiceContract serviceContract, Asset__c parentAsset, Asset_Information__c assetInformation)
    {
        Asset__c asset = new Asset__c(ServiceContract__c = serviceContract.Id, Asset__c = parentAsset.Id);
            
        for (String assetInformationField: assetInformationFields) {
            String assetField = AssetInformationToAssetGenerationUtil.getAssetInformationFieldMapTo(assetInformationField);
            Object assetInformationFieldValue = assetInformation.get(assetInformationField);
            Object assetFieldValue = asset.get(assetField);
            if(assetInformationFieldValue  == null)
                asset.put(assetField, null);
            else
                asset.put(assetField, assetInformationFieldValue);
        }
        Map<String, Id> assetRecordTypes = ServiceContractUtil.getAssetRecordTypes();
        Id recordTypeId = assetRecordTypes.get(asset.type__c);
        asset.RecordTypeId = recordTypeId;
        return asset;
    }

    private Asset__c createMeterAsset(ServiceContract parentServiceContract, Asset__c parentAsset)
    {
        return new Asset__c(ServiceContract__c = parentServiceContract.Id, Type__c = 'Meter', Asset__c = parentAsset.Id);
    }
    
    private Asset__c createInstallationAsset(ServiceContract parentServiceContract, Decimal sizeAC, Decimal sizeDC)
    {
        Map<String, Id> assetRecordTypes = ServiceContractUtil.getAssetRecordTypes();
        Id assetRecordTypeId = assetRecordTypes.get('Asset');
        return new Asset__c(ServiceContract__c = parentServiceContract.Id, Type__c = 'Asset', System_Size_CEC_AC__c = sizeAC, System_Size_DC__c = sizeDC, recordTypeId = assetRecordTypeId, Original_System_Size_CEC_AC__c = OriginalSystemSizeCECAC);
    }
    

    
    private List<Asset_Information__c> getAssetInformationForProposal(String fieldsString)
    {
        String assetInformationSelectStatement = 'select Id, Name, Count__c' + fieldsString + ' from Asset_Information__c where ProposalName__r.Id = \'' + proposalId + '\'';      
        return (List<Asset_Information__c>)Database.query(assetInformationSelectStatement);          
    }    
    
    private ServiceContract createNewServiceContractFromProposal(Proposal__c proposal, Set<String> proposalFields, ServiceContract serviceContract)
    {
        if(serviceContract != null && serviceContract.Id == null){
            //serviceContract.Name = proposal.Name;
            serviceContract.StartDate = Date.today();
            serviceContract.EndDate = Date.today().addYears(20);
            serviceContract.AccountId = proposal.Opportunity__r.AccountId;
            serviceContract.Opportunity__c = proposal.Opportunity__r.Id;
            //serviceContract.project_manager__c = proposal.opportunity__r.project_manager__c;
        }
        
        if(serviceContract != null && serviceContract.Id != null){
            serviceContract.Original_Price_per_kWh__c = serviceContract.Price_per_kWh__c;
            serviceContract.Original_Full_System_Cost__c = serviceContract.Full_System_Cost__c;
            serviceContract.Original_Yr_1_Gen__c = serviceContract.Est_Yr_1_Generation__c;
        }
    
    String oldBillingMethod = serviceContract.Billing_Method__c;
        for (String proposalField: proposalFields) {
            String serviceContractField = ProposalToServiceContractGenerationUtil.getProposalFieldMapTo(proposalField);
            Object proposalFieldValue = proposal.get(proposalField);
            Object serviceContractFieldValue = serviceContract.get(serviceContractField);
            if(proposalFieldValue == null)
                serviceContract.put(serviceContractField, null);
            else
                serviceContract.put(serviceContractField, proposalFieldValue);
         
        }
       
        if((serviceContract.Id == null || (serviceContract.Deal_ID__c == null || serviceContract.Deal_ID__c  == ''))  
            &&  (proposal.Opportunity__r.Deal_Id__c != NULL && proposal.Opportunity__r.Deal_Id__c != '')){
            String tempDealId = proposal.Opportunity__r.Deal_Id__c;
            string newDealId = tempDealId.substring(0,4) + '-' + tempDealId.substring(4,6) + '-' + tempDealId.substring(6,8)  + '-' + tempDealId.substring(8,12)  ;
            System.debug('newDealId: ' + newDealId);
            serviceContract.Deal_ID__c = newDealId;
        }
        String paymentMode = (serviceContract.Id != null && serviceContract.Payment_Mode__c != null && serviceContract.Payment_Mode__c != '') ? serviceContract.Payment_Mode__c : proposal.Opportunity__r.Payment_Mode__c;
    ServiceContractUtil.setBillingMethod(serviceContract,proposal, paymentMode, oldBillingMethod);
        
        
        if(serviceContract.Billing_Type__c != null && serviceContract.Billing_Type__c == 'Fixed monthly PPA with annual reset'){
            serviceContract.Year_1_monthly_payment__c = serviceContract.base_lease_payment_amount__c;
            serviceContract.base_lease_payment_amount__c = null;
        }else{
            serviceContract.Year_1_monthly_payment__c = null;
        }
    
    if(serviceContract.Id == null){
          serviceContract.Description = ServiceContractUtil.getAddressString(proposal.Opportunity__r.Account);
      //proposal.Opportunity__r.Account.BillingStreet + ', ' + proposal.Opportunity__r.Account.BillingCity + ', ' +  proposal.Opportunity__r.Account.BillingState + ', ' +  proposal.Opportunity__r.Account.BillingCountry + ', ' + proposal.Opportunity__r.Account.BillingPostalCode ;
        }
        if(serviceContract.Description == null || !serviceContract.Description.contains(proposal.name)){
          serviceContract.Description += '; Proposal Name: ' + proposal.name;
        }
        serviceContract.Proposal__c = proposal.Id;
    return serviceContract;
    }

    private void initializeOptyContactRolesAndBillingContact(ServiceContract serviceContract, Service_Contract_Event__c serviceContractEventObj){
        oppurtunityContactRoles = new List<OpportunityContactRole>();
        Id contactId;
        if(serviceContract.Opportunity__c != null){
            
            Id serviceContractOptyId = serviceContract.Opportunity__c;
            String contactRelSOQL = ServiceContractUtil.getContactSOQLForOptyContactRole();
            String optyContactRoleSOQL = ' select Id, ContactId, Role, OpportunityId, ' + contactRelSOQL + ' from OpportunityContactRole where OpportunityId = :serviceContractOptyId order by isPrimary desc ' ;
            oppurtunityContactRoles =  Database.query(optyContactRoleSOQL);
            //oppurtunityContactRoles = [select Id, ContactId, Role, OpportunityId, contact.Id, contact.Name, contact.ERP_Contact_of_Record__c, contact.Email from OpportunityContactRole where OpportunityId = :serviceContract.Opportunity__c];
            if(serviceContract.ContactId == null && oppurtunityContactRoles != null && !oppurtunityContactRoles.isEmpty()){
                String emailId = '';
                Contact contactRoleContact;
                Contact erpTargetContact = new Contact();
                for(OpportunityContactRole roleObj : oppurtunityContactRoles){
                    if(contactId == null && roleObj.role != null && roleObj.role.contains('Homeowner')){
                        contactId = roleObj.ContactId;
                        contactRoleContact = roleObj.Contact;
                        emailId = (roleObj.contact != null && roleObj.Contact.Id != null) ? roleObj.Contact.email : '';
                        System.debug('Homeowner Id: ' + contactId);
                    }else if(roleObj.role != null && roleObj.role.contains('Billing')){
                        contactId = roleObj.ContactId;
                        System.debug('Billing Contact Id: ' + contactId);
                        emailId = (roleObj.Contact != null && roleObj.Contact.Id != null) ? roleObj.Contact.email : '';
                        contactRoleContact = roleObj.Contact;
                    }
                }

                Contact tempERPContact;
                if(emailId != null && emailId != ''){
                    tempERPContact = ServiceContractUtil.getERPContact(emailId);
                    if(tempERPContact != null && tempERPContact.Id != null){
                        erpTargetContact = tempERPContact;
                    }
                }
                ServiceContractUtil.cloneERPContact(contactRoleContact, erpTargetContact);
                if((tempERPContact != null && tempERPContact.Id != null) || (contactRoleContact != null && contactRoleContact.Id != null)){
                    upsert erpTargetContact;
                    serviceContract.ContactId = erpTargetContact.Id;
                     System.debug('erpTargetContact.email: ' + erpTargetContact.email);
                    serviceContractEventObj.Customer_s_Email__c = erpTargetContact.email;
                    serviceContract.ERP_Customer_Name__c = ServiceContractUtil.getContactName(erpTargetContact);
                }
            }
        }
    }

    public String upsertServiceContract(ServiceContract serviceContract, Proposal__c proposal){
        String result = ProposalUtil.SUCCESS;
        Boolean createEventObj = false;
        Service_Contract_Event__c serviceContractEventObj = new Service_Contract_Event__c();
        Set<String> proposalFields = ProposalToServiceContractGenerationUtil.getProposalFields();       
        createNewServiceContractFromProposal(proposal, proposalFields, serviceContract);  
        serviceContract.Service_Contract_Status__c  = ServiceContractUtil.ACTIVE;   
        serviceContract.RelatedObjects_Last_Modified_Date__c = datetime.now();
        if(proposal.Opportunity__r != null && proposal.Opportunity__r.Id != null){
            //serviceContract.Avg_Monthly_Electric_Bill__c = proposal.Opportunity__r.Average_Monthly_Electric_Bill__c;
            //serviceContract.Average_Monthly_Electricity_Usage__c = proposal.Opportunity__r.Average_Monthly_Electricity_Usage__c;
        }
        initializeOptyContactRolesAndBillingContact(serviceContract, serviceContractEventObj);
        System.debug('2: serviceContract.Billing_Notification_Preference__c: ' + serviceContract.Billing_Notification_Preference__c);
        upsert serviceContract;
        
        
        String fieldsString = ProposalToServiceContractGenerationUtil.getServiceContractEventFieldsString();
        
        System.debug('serviceContractEventObj.Customer_s_Email__c 0: ' + serviceContractEventObj.Customer_s_Email__c);
        if(serviceContract != null && serviceContract.Id != null){
            //Checking existing Service Contract Event
            Id scId = serviceContract.Id;
            String serviceContractFields = 'select Id, Name ' + fieldsString;
            serviceContractFields += ' from Service_Contract_Event__c where service_contract__c =:scId ';      
            List<Service_Contract_Event__c> tempSCEventList = Database.query(serviceContractFields);  
            if(tempSCEventList != null && !tempSCEventList.isEmpty()){
                if(serviceContractEventObj != null && serviceContractEventObj.Customer_s_Email__c != null && serviceContractEventObj.Customer_s_Email__c != ''){
                    tempSCEventList[0].Customer_s_Email__c = serviceContractEventObj.Customer_s_Email__c;
                }
                serviceContractEventObj = tempSCEventList[0];
            }
        }
        System.debug('serviceContractEventObj.Customer_s_Email__c: ' + serviceContractEventObj.Customer_s_Email__c);
        if(serviceContractEventObj.Id == null && serviceContractEventObj.Service_Contract__c == null){
          serviceContractEventObj.Service_Contract__c = serviceContract.Id;
          serviceContractEventObj.Site_Audit_Scheduled__c = proposal.Opportunity__r.Site_Audit_Scheduled__c;
        }
    serviceContract.Proposal__c = proposal.Id;
        
        //Creating Service Contract Event
        //if(serviceContractEventObj == null || serviceContractEventObj.Id == null){
        //    serviceContractEventObj = new Service_Contract_Event__c(); 
        //}
        
        if(serviceContractEventObj != null && serviceContractEventObj.Id != null){
            serviceContractEventObj.Original_Upfront_Payment_Amount__c = serviceContractEventObj.Upfront_payment_amount__c;
            serviceContractEventObj.Original_Rebate_Estimate__c = serviceContractEventObj.est_rebate_amount__c;
        }
        
        DateTime customerSignOffDate = serviceContractEventObj.Customer_Signoff__c;   
        DateTime revisedCustSignOffDateValue = serviceContractEventObj.Revised_Customer_SignOff__c;
        DateTime srSignOffDate = serviceContractEventObj.SR_Signoff__c;   
        DateTime revisedSignOffDate = serviceContractEventObj.Revised_SR_Signoff__c;   
        string  custSignOffDate = 'Customer_Signoff__c';
         string  revisedcustSignOffDateField = 'Revised_Customer_SignOff__c';
        Set<String> proposalSCEventFields = ProposalToServiceContractGenerationUtil.getProposalFieldsForSCEvent();  
    for (String proposalField: proposalSCEventFields) {
            String scEventField = ProposalToServiceContractGenerationUtil.getProposalFieldMapToSCEvent(proposalField);
            Object proposalFieldValue = proposal.get(proposalField);
            Object scEventFieldValue = serviceContractEventObj.get(scEventField);
      
        if(proposalFieldValue == null && !scEventField.equalsIgnoreCase(revisedcustSignOffDateField) )
                serviceContractEventObj.put(scEventField, null);
            else if ( scEventField.equalsIgnoreCase(custSignOffDate)  && scEventFieldValue != null ) 
                continue;
        
           	 else if ( scEventField.equalsIgnoreCase(revisedcustSignOffDateField)  && scEventFieldValue != null 
                      && proposalFieldValue == null ){
                        if(  proposal.Customer_Signoff_Date__c != null && proposal.Customer_Signoff_Date__c >= revisedCustSignOffDateValue ) 
                        { 
                            system.debug( 'ScEvent Feild Name' + scEventField + '--ProposalField Name' + proposalField );	
                            serviceContractEventObj.put(scEventField, proposal.get('Customer_Signoff_Date__c'));
                        }
                      }
        	else
                serviceContractEventObj.put(scEventField, proposalFieldValue);
        } 
    serviceContractEventObj.Customer_Signoff__c = (serviceContractEventObj.Customer_Signoff__c != null) ? serviceContractEventObj.Customer_Signoff__c : customerSignOffDate; 
    //serviceContractEventObj.SR_Signoff__c = (serviceContractEventObj.SR_Signoff__c != null) ? serviceContractEventObj.SR_Signoff__c : srSignOffDate; 
    //serviceContractEventObj.Revised_SR_Signoff__c = (serviceContractEventObj.Revised_SR_Signoff__c != null) ? serviceContractEventObj.Revised_SR_Signoff__c : revisedSignOffDate; 
        if(serviceContractEventObj.id == null){
          serviceContractEventObj.SR_Signoff__c = proposal.SR_Signoff__c;
          serviceContractEventObj.Revised_SR_Signoff__c = (proposal.Revised_SR_Signoff__c != NULL) ? proposal.Revised_SR_Signoff__c : serviceContractEventObj.Revised_SR_Signoff__c;
        }else{
          serviceContractEventObj.Revised_SR_Signoff__c = (proposal.Revised_SR_Signoff__c != NULL) ? proposal.Revised_SR_Signoff__c : serviceContractEventObj.Revised_SR_Signoff__c;
        }
        //Comment this code as part of BSKY-4133,4134---Prashanth Veloori
    /**/
    Set<String> newHomeTypes = new Set<String>();
        newHomeTypes.add('Vertically-split duplex');
        newHomeTypes.add('Townhome / rowhome');
        newHomeTypes.add('Single-family detached home in condo development');
        if(serviceContractEventObj.id == null){
            if(proposal.home_type__c != null && newHomeTypes.contains(proposal.home_type__c)){
                serviceContractEventObj.HOA__c = 'Yes - attached home / single-family condo';
            }else if(proposal.home_type__c != null && 'detached single family home' == proposal.home_type__c.toLowerCase()){
                serviceContractEventObj.HOA__c = null ;
            } 
        }
        /**/  

        // End  BSKY-4133,4134   
        upsert serviceContractEventObj; 
        
        if(serviceContract.Service_Contract_Event__c == null){
            serviceContract.Service_Contract_Event__c = serviceContractEventObj.Id;
      update serviceContract;
    }
        return result;
    }

    public double OriginalSystemSizeCECAC = 0.0;
    
    @future
    public static void upsertServiceContractRelatedRecords(Id scId, Id proposalId, Boolean createRelationships){
      ServiceContract serviceContract =  ServiceContractUtil.getServiceContract(scId);
    Proposal__c proposal;
    Set<Id> proposalIds = new Set<Id>();
    proposalIds.add(proposalId);
    List<Proposal__c> proposalList = ProposalUtil.getProposals(proposalIds);
    ApexPages.StandardController controller = new ApexPages.StandardController(proposalList[0]);
        CreateServiceContractController createSCController = new CreateServiceContractController(controller);
        createSCController.oppurtunityContactRoles = new List<OpportunityContactRole>();
        Id contactId;
        if(serviceContract.Opportunity__c != null){
      Id serviceContractOptyId = serviceContract.Opportunity__c;
            String contactRelSOQL = ServiceContractUtil.getContactSOQLForOptyContactRole();
            String optyContactRoleSOQL = ' select Id, ContactId, Role, OpportunityId, ' + contactRelSOQL + ' from OpportunityContactRole where OpportunityId = :serviceContractOptyId order by isPrimary desc ' ;
             createSCController.oppurtunityContactRoles =  Database.query(optyContactRoleSOQL);
            createSCController.upsertServiceContractRelatedRecords(serviceContract, proposal, createRelationships);
        }
  }
    
    
    public void upsertServiceContractRelatedRecords(ServiceContract serviceContract, Proposal__c proposal, Boolean createRelationships){
        
        Service_Contract_Event__c scEventObj = new Service_Contract_Event__c();
        if(serviceContract != null && serviceContract.Id != null){
            List<Service_Contract_Event__c> scList = [Select Id, name, Service_Contract__c from Service_Contract_Event__c where Service_Contract__c =:serviceContract.Id];
            if(scList != null && !scList.isEmpty()){
                scEventObj = scList[0];
            }
        }
        
        Set<String> assetInformationFields;
        assetInformationFields = AssetInformationToAssetGenerationUtil.getAssetInformationFields();
        List<Asset_Information__c> assetInformation = getAssetInformationForProposal(AssetInformationToAssetGenerationUtil.getAssetInformationFieldsString());
    
         //BSKY-6079
        Set<String> assetInformationFieldsforPricing;
        assetInformationFieldsforPricing = AssetInfoToContractPricingGenerationUtil.getAssetInformationFields();
        List<Asset_Information__c> assetInformationForPricing = ContractPricingUtil.getAssetInformationForProposalForPricing(AssetInfoToContractPricingGenerationUtil.getAssetInformationFieldsString(), proposalId);
        List<Contract_Pricing__c> existingContractPricingList = new List<Contract_Pricing__c>();  
        List<Contract_pricing__c> ContractpricingList = new List<Contract_pricing__c>(); 
        
        String inactiveStr = ServiceContractUtil.INACTIVE;
        List<Asset__c> existingAssetList = new List<Asset__c>();
        List<Asset__c> assetList = new List<Asset__c>();
        for(Asset__c assetObj: [Select Id, name, ServiceContract__c, Original_System_Size_CEC_AC__c, System_Size_CEC_AC__c, Status__c, Type__c from Asset__c where ServiceContract__c =:serviceContract.Id and Status__c != :inactiveStr]){
            existingAssetList.add(assetObj);
            if(assetObj.Type__c != null && assetObj.Type__c == ServiceContractUtil.ASSET_TYPE_METER){
                continue;
            }else{
                assetObj.Status__c = ServiceContractUtil.INACTIVE;
            }
            
        }
        // BSKY-6079
        for(  Contract_Pricing__c cPricingObj: [Select Id, name, Service_Contract__c, SKU__c, Status__c, Total_Price__c, Total_Tax__c , Asset_Type__c
                                                  from Contract_Pricing__c where Service_Contract__c =:serviceContract.Id and Status__c != :inactiveStr]){
                  cPricingObj.Status__c = ServiceContractUtil.INACTIVE;
                  existingContractPricingList.add(cPricingObj);
                  System.debug('cPricingObj.Status__c' + cPricingObj.Status__c);                                      
                                                  }          
            
        if(!existingAssetList.isEmpty()){
            update existingAssetList;
        }  
          //BSK-6079
        if(!existingContractPricingList.isEmpty()){
            update existingContractPricingList;
        }  
            
        proposal = ServiceContractUtil.getProposal(proposalId);
        
        Asset__c installationAsset = createInstallationAsset(serviceContract, proposal.System_Size_CEC_AC__c, proposal.System_Size_STC_DC__c);
        installationAsset.service_contract_event__c = (scEventObj != null && scEventObj.Id != null) ? scEventObj.Id : null;
        insert installationAsset;

        //BSKY-6079
        Contract_Pricing__c installationPricing = ContractPricingUtil.createInstallationPricing( serviceContract, proposal );
        insert installationPricing; 

        Asset__c asset;
        for(Asset_Information__c assetInfo: assetInformation)
        {
           Decimal assetInformationCount = assetInfo.Count__c;
           Integer count = 0;
           while(count < assetInformationCount)
           {
                asset = createAsset(assetInformationFields, serviceContract, installationAsset, assetInfo); 
                asset.service_contract_event__c = (scEventObj != null && scEventObj.Id != null) ? scEventObj.Id : null; 
                assetList.add(asset);
               count++;
           }                  
        }
        
         //BSKY-6079
        Contract_pricing__c cPricing;
        for(Asset_Information__c assetInfo: assetInformationForPricing)
        {     
            if( assetInfo.Type__c != Null && (assetInfo.Type__c == 'Panel' || assetInfo.Type__c == 'Inverter' )){

                cPricing = ContractPricingUtil.createContractPricing(assetInformationFieldsforPricing, serviceContract, assetInfo); 
                ContractPricingList.add(cPricing);              
             }
        }
        
        for(Asset__c assetObj: existingAssetList){
            if(assetObj.Type__c != null && assetObj.Type__c == ServiceContractUtil.ASSET_TYPE_METER 
                && assetObj.status__c == ServiceContractUtil.ACTIVE){
                assetObj.Asset__c = installationAsset.Id;
                assetList.add(assetObj);
            }
        }
        
        if(!assetList.isEmpty()){
            upsert assetList;
        }

          //BSKY-6079
        if(!ContractPricingList.isEmpty()){
            upsert ContractPricingList;
        }
        
        if(createRelationships == true){
            List<Service_Contract_Partner_Rel__c> partnerRelationships = createPartnerRelationshipsFromOpportunity(serviceContract);
            if(partnerRelationships != null && !partnerRelationships.isEmpty()){
              insert partnerRelationships;
            }
            
            List<Service_Contract_Contact_Rel__c> contactRelationships = createContactRelationshipsFromOpportunity(serviceContract);
            if(contactRelationships != null && !contactRelationships.isEmpty()){
              insert contactRelationships;
            }
    }       
    }
    
    public void processAsBuiltChangeOrder(Proposal__c proposalObj, ServiceContract scObj){
      //Copy As Built Size and As Built Production fields
      scObj.As_Built_Size__c = proposalObj.System_Size_STC_DC__c;
      scObj.As_Built_Production__c = proposalObj.First_Year_Generation_Estimate__c;
      scObj.Proposal__c = proposalObj.Id;
      update scObj;
    
    Service_Contract_Event__c tempSCEventObj = getServiceContractEvent(scObj);
    if(tempSCEventObj != null && tempSCEventObj.Id != null){
      tempSCEventObj.Revised_SR_Signoff__c = proposalObj.SR_Signoff__c;
      update tempSCEventObj;
    }
    upsertServiceContractRelatedRecords(scObj, proposalObj, false);
    }
    
    public Service_Contract_Event__c getServiceContractEvent(ServiceContract serviceContract){
      Service_Contract_Event__c serviceContractEventObj;
        if(serviceContract != null && serviceContract.Id != null){
          String fieldsString = ProposalToServiceContractGenerationUtil.getServiceContractEventFieldsString();
            //Checking existing Service Contract Event
            Id scId = serviceContract.Id;
            String serviceContractFields = 'select Id, Name ' + fieldsString;
            serviceContractFields += ' from Service_Contract_Event__c where service_contract__c =:scId ';      
            List<Service_Contract_Event__c> tempSCEventList = Database.query(serviceContractFields);  
      if(tempSCEventList != null && !tempSCEventList.isEmpty()){
        serviceContractEventObj = tempSCEventList[0];
      }
             
        }
        return serviceContractEventObj;
    }
    
    public void initializeOracleERPFields(Opportunity optyObj){
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
      optyObj.Permitting_Process_Finish_Date__c   = null;
      optyObj.Permit_Jurisdiction_municipality__c = null;
      optyObj.Submit_Final_Interconnection__c = null;
    optyObj.Permitting_Process_Start_Date__c = null;
      optyObj.Layout_Approval_Finish__c = null;
      optyObj.Layout_Approval_Start__c = null;
      optyObj.Launch_date__c = null;
    optyObj.Prospect_Id__c = null;
    }
}