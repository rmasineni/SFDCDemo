public class NewCustomerContactOverridden {
  Opportunity opty;
  Account account;
  Proposal__C proposalObj;
  public String lastName{get;set;}
  public Contact addCon {get;set;}
  public Contact oldContact {get;set;}
  public String optyId {get;set;}
  public String inputOptyId {get;set;}
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
    public String oldEmailAddress {get;set;}
    public boolean enableConfirmSave {get;set;}
    public boolean userConfirmed {get;set;}
    public String opportunityName {get;set;}
    public String roleName{get;set;}
    User userObj;
    public string sunruncrm {get;set;}
  public boolean showOptyDetails{get;set;}
  public string preferredLanguage{get;set;}

  public NewCustomerContactOverridden(ApexPages.StandardController stdController){
    enableConfirmSave = false;
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
    sunruncrm = System.currentPageReference().getParameters().get('sunruncrm');
    inputOptyId = System.currentPageReference().getParameters().get('opportunityId');
    showOptyDetails = (inputOptyId != null && inputOptyId != '') ? true : false;
    optyId = inputOptyId;
    contactId = System.currentPageReference().getParameters().get('contactId');
    System.debug('contactId: ' + contactId);
    
    confirmMode = false;
    showEditSec = true;
        showReadSec = false;
    init();
    if(contactId != null && (sunruncrm == null || sunruncrm == '')){
      oldContact = addCon.clone(false, true);
    }else if(contactId != null && (sunruncrm != null && sunruncrm == '1')){
      showEditSec = false;
          showReadSec = true;  
          title = 'Contact Details';  
    }
    
    
  }

  public List<SelectOption> getContactRoles() {
        List<SelectOption> contactRoles = new List<SelectOption>();
        contactRoles.add(new SelectOption('', '-- None --'));
    contactRoles.add(new SelectOption('Homeowner', 'Homeowner'));
     contactRoles.add(new SelectOption('UtilityBillContact', 'Utility Bill Contact'));
    contactRoles.add(new SelectOption('Other', 'Other'));
    return contactRoles;
    }

  
  public Pagereference setProposal(){
    initializeProposal();
    return null;
  }

  private void initializeOpportunity(){
    if(optyId != null){
      opty = [select Id, Name, AccountId from Opportunity where Id = :optyId LIMIT 1];
      opportunityName = opty.Name;
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
    }
  }

  private void initializeProposal(){
    if(addCon.Proposal__c != null){
      String tempProposalId = addCon.Proposal__c;
      String proposalSOQLStr = ProposalUtil.getProposalSQLStr();
      proposalSOQLStr += ' where Id =:tempProposalId ' ;
      List<Proposal__c> proposalsList = Database.query(proposalSOQLStr);
      proposalObj = proposalsList[0];
      optyId = proposalObj.Opportunity__c;
      initializeOpportunity();
    }
  }
  
  public NewCustomerContactOverridden(){
    addCon = new Contact();
    account = new Account();
    opty = new Opportunity();
    proposalId = System.currentPageReference().getParameters().get('proposalId');
    inputOptyId = System.currentPageReference().getParameters().get('opportunityId');
    showOptyDetails = (inputOptyId != null && inputOptyId != '') ? true : false;
    optyId = inputOptyId;
    confirmMode = false;
    init();
    if(contactId != null){
      oldContact = new Contact();
      oldContact.FirstName = addCon.FirstName;
      oldContact.lastName = addCon.lastName;
      oldContact.email = addCon.email;
      oldContact.MailingStreet = addCon.MailingStreet;
      oldContact.MailingState = addCon.MailingState;
      oldContact.MailingCity = addCon.MailingCity;
      oldContact.MailingPostalCode = addCon.MailingPostalCode;
      oldContact.Preferred_Language__c = addCon.Preferred_Language__c;
    }
    
    System.debug('End Init ...');
  }  
  
  private Id getAccountIdForProposal(Id proposalId){
    Id accountId;
    Proposal__C tempProposalObj = [Select Id, Opportunity__c from Proposal__c where Id =:addCon.Proposal__c];
    Opportunity optyObj = [Select Id, accountId from Opportunity where Id =:tempProposalObj.Opportunity__c];
    optyId = optyObj.Id;
    return optyObj.accountId;
  }

  Map<Id, Proposal__c> activeProposals;
  
  public Pagereference confirmSave(){
    addCon.Void_Proposals__c = true;
    userConfirmed = true;
    return saveContact();
    
  }

  public Pagereference saveContact(){
    
    try{
      
      System.debug('Account Id: ' + addCon.accountId);
      confirmMode = false;
      errorMessage = '';
      if(addCon.email == null || addCon.FirstName == null || lastName == null 
        || addCon.MailingStreet == null || addCon.MailingCity == null || addCon.Mailingstate == null
        || addCon.MailingPostalCode == null
        || String.isEmpty(addCon.Preferred_Language__c)){
        errorMessage = 'Please enter values for the required fields';
        Exception expObj = new BaseException(errorMessage);
        expObj.setMessage(errorMessage);
        ApexPages.addMessages(expObj);
        return null;
      }
  
      addCon.LastName = lastName;  
      oldEmailAddress = '';  
      Id tempAccountId;
      if(addCon != null && addCon.Proposal__c != null){
        tempAccountId = getAccountIdForProposal(addCon.Proposal__c);
        if(addCon.AccountId != null && addCon.AccountId  != tempAccountId){
          errorMessage = 'This Contact does not belong to the selected proposal';
          Exception expObj = new BaseException(errorMessage);
          expObj.setMessage(errorMessage);
          ApexPages.addMessages(expObj);
          return null;        
        }
      }else if(account != null && account.Id != null){
        tempAccountId = account.Id;
      }else if(addCon.accountId != null){
        tempAccountId = addCon.accountId;
      }
      
      Proposal__c tempProposalObj;
      enableConfirmSave = checkForModifications();
      if(addCon != null && addCon.Id != null){
        if(activeProposals == null || activeProposals.isEmpty()){
          Set<Id> tempContactIds = new Set<Id>();
          tempContactIds.add(addCon.Id);
          Map<Id, Map<Id, Proposal__C>> tempContactProposalMap = ProposalUtil.getActiveProposalsForContacts(tempContactIds);
          if(tempContactProposalMap != null && tempContactProposalMap.containsKey(addCon.Id)){
            activeProposals = tempContactProposalMap.get(addCon.Id);
          }
        }
      }
      
      if(enableConfirmSave == true && activeProposals != null &&
        activeProposals.size() > 0 && userConfirmed == false){
        errorMessage = 'Editing this contact will void any proposals associated with it. Click \'Confirm\' to save changes. Otherwise, click \'Cancel\'.';
        Exception expObj = new BaseException(errorMessage);
        expObj.setMessage(errorMessage);
        ApexPages.addMessages(expObj);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,errorMessage));
        return null;
      }
      
      userConfirmed = false;
      if(tempAccountId == null){
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
        User dacoAccount = [Select Id from User where Username =:sunrunDevelopmentAccount and firstname = 'Developer' and lastname = 'Account' limit 1  ];
        account.OwnerId = dacoAccount.Id;
        insert account;
        addCon.AccountId = account.Id;
        tempAccountId = account.Id;
      }
      
      addCon.AccountId = tempAccountId;
      addCon.RecordTypeId = contactRecordTypeId;
      addCon.Partner_Name__c = partnername;
      upsert addCon;    
      contactId = addCon.Id;
      Set<id> OpptyShareIds=new Set<id>();
      Set<id> ContShareIds=new Set<id>();
      if(optyId != null && optyId != ''){
        String roleNameStr = (this.roleName != null && this.roleName != '') ? this.roleName : EDPUtil.OTHER;
        List<OpportunityContactRole> optyContactRoleList = [Select Id, ContactId, OpportunityId, role from OpportunityContactRole 
                                  where ContactId =:addCon.Id and OpportunityId =:optyId];
        
        System.debug('optyContactRoleList: ' + optyContactRoleList);
        if(optyContactRoleList == null || optyContactRoleList.size() == 0){
          OpportunityContactRole newOCR = new OpportunityContactRole();
          newOCR.ContactId = addCon.Id;
          newOCR.OpportunityId = optyId;
          newOCR.Role = roleNameStr;
          upsert newOCR;
          OpptyShareIds.add(optyId);
          ContShareIds.add(addCon.Id);
        }
      }
      System.debug('addCon.Proposal__c: ' + addCon.Proposal__c);
      System.debug('tempProposalObj ' + tempProposalObj);
      if(!OpptyShareIds.isEmpty()&&!ContShareIds.isEmpty()){
        ContactShareByOppty.doContactSharing(ContShareIds,OpptyShareIds);
      }
      if(tempProposalObj != null){
        Map<Id, Proposal__c> proposalMap = new Map<Id, Proposal__c>();
        proposalMap.put(tempProposalObj.Id, tempProposalObj);
        ProposalUtil.optyAndContactSharingForProposals(proposalMap.values());
      }
  
      confirmMode = true;
      showEditSec = false;
          showReadSec = true;
      if(confirmMode == true){
        Pagereference ref;
        String baseURL = EDPUtil.getBaseURL();
        String partnerStr = (baseURL != null && baseURL.contains('/partner')) ? '/partner' : '';
        partnerStr = (baseURL != null && baseURL.contains('/aeepartner')) ? '/aeepartner' : '';
        if(sunruncrm != null && sunruncrm == '1'){
          ref = new PageReference(partnerStr + '/apex/NewCustomerContact2?sunruncrm=1&contactId=' + contactId + '&opportunityId=' + inputOptyId);
        }else if(inputOptyId != null && inputOptyId != '' && (sunruncrm == null || sunruncrm == '')){
          ref = new PageReference(partnerStr + '/apex/partneropportunitycreate?id=' + inputOptyId);
        }else{
          ref = new PageReference(partnerStr + '/' + contactId);
        }
        ref.setRedirect(true); 
            return ref;
          }
      return null;      
        }catch(Exception exceptionObj){
            ApexPages.addMessages(exceptionObj);
            return null;          
        } 
  }
  
  private Proposal__c getProposal(Id proposalIdValue){
    System.debug('proposalIdValue: ' + proposalIdValue);
    Proposal__c tempProposalObj;
    String proposalSOQLStr = ProposalUtil.getProposalSQLStr();
    proposalSOQLStr += ' where Id =:proposalIdValue ' ;
    List<Proposal__c> proposalsList = Database.query(proposalSOQLStr);
    if(proposalsList.size() > 0){
      tempProposalObj = proposalsList[0];
    }
    return tempProposalObj;
  }


  private void init(){
    enableConfirmSave = false;
    userConfirmed = false;

    if(proposalId != null && proposalId != ''){
      proposalObj = getProposal(proposalId);
      optyId = proposalObj.Opportunity__c;
    }
    if(optyId != null){
      initializeOpportunity();
    }
        
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
        oldEmailAddress = addCon.email;
        System.debug('addCon 1 : ' + addCon);
        editContact = true;
        preferredLanguage = addCon.Preferred_Language__c;
      }
    }
    System.debug('addCon 2 : ' + addCon);
  }  

  public String getBaseURL() {
    String baseURL = EDPUtil.getBaseURL();
    return baseURL;
  }

  public Boolean getEditAdditionalInfo(){
    if(proposalId == null || proposalId == ''){
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
      contactRecordTypeId = Contact.sObjectType.getDescribe().getRecordTypeInfosByName().get('Residential').getRecordTypeId();
      //List<RecordType> recordTypeObjs = [select Id, Name, SobjectType from RecordType where SObjectType = 'Contact' and name = 'Residential' limit 1 ];
      //if(recordTypeObjs != null && recordTypeObjs.size() > 0){
      //  contactRecordTypeId = recordTypeObjs[0].Id;
      //}      
    }
  }
  
  private void initializePartnerName(){
    if(partnername == null || partnername == ''){
      Id userId = UserInfo.getUserId();
      userObj = [Select Id, contactId, companyname from User where Id =:userId ];
      if(userObj.contactId != null){
        Contact contactObj = [Select Id, Ultimate_Parent_Account__c, Ultimate_Parent_Account__r.name from Contact where Id =:userObj.contactId];
        partnername = contactObj.Ultimate_Parent_Account__r.name;
      }
    }
  }
  
  public Map<Id, Proposal__C> getActiveProposals(){
    Set<String> stageList = ProposalUtil.getInactiveProposalStages();
    Map<Id,Proposal__C> proposals;
    if(addCon != null && addCon.Id != null){
      proposals = new Map<Id,Proposal__C>([Select Id, name, Primary_Customer__c, stage__c from Proposal__C where Primary_Customer__c =:addCon.Id 
                                                   and stage__c not in :stageList]);
    }
    return proposals;
  }
  
  public boolean checkForModifications(){
    boolean result = false;
    if(oldContact != null && ((addCon.FirstName != oldContact.FirstName) || (lastName != oldContact.lastName))){
      result = true;
    }
    System.debug('result: ' + result);
    return result;
  }
  
  public Pagereference returnToOpportunity(){
    Pagereference ref;
    if(inputOptyId != null && inputOptyId != ''){
      String baseURL = EDPUtil.getBaseURL();
      String partnerStr;
      if(baseURL.contains('/aeepartner')){
        partnerStr = '/aeepartner';
      }
      else if(baseURL.contains('/partner')){
        partnerStr = '/partner';
      }
      else{
        partnerStr = '';
      }
      ref = new PageReference(partnerStr + '/apex/partneropportunitycreate?id=' + inputOptyId);
      System.debug('inputOptyId: ' + inputOptyId);
    }else{
      ref = new PageReference('/partner/003/o');
      System.debug('Contact list ..');
    }
    ref.setRedirect(true);  
    return ref;
  }
  public class BaseException extends Exception {}

}