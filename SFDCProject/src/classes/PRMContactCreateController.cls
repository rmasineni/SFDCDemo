public class PRMContactCreateController {
    Id parentAccountId;
    Account accountObj;
    Account parentAccountObj;
 
    Id contactId;
    public ContactModeRelationship contactModeRelObj{get;set;}
    public Contact contactObj{get;set;}
    Contact existingContact = null;
    public CustomLookup__c customLookup{get;set;}
    Contact loginUserContact;
    User loginUser;
    Map<Id, Contact> contactMap;
    Map<String, List<Contact>> roleContactMap;
    Map<String, Map<Id, Contact>> contactRoleMap;
    Map<Id, UserRole> partnerPortalRoles;
    public List<SelectOption> ContactRoles;
    public List<SelectOption> SalutationList{get;set;}
    public Boolean isPartnerConcierge{get;set;}
    public Contact upsertContact{get;set;}
    public List<SelectOption> jobFunctions{get;set;}
    public List<SelectOption> TimeZones{get;set;}
    public List<SelectOption> accountSites;
    Map<Id, String> roleIdToName = new Map<Id, String>();
    Map<String, Id> roleNameToId = new Map<String, Id>();
    public Id siteId{get;set;}
    public Id oldSiteId{get;set;}

    public List<SelectOption> contactReportsToList;
    public boolean isSPOCUser {get; set;}
    public boolean isAEEUser;
  
    public PRMContactCreateController(){
        isPartnerConcierge = false;
        isSPOCUser = false;
        isAEEUser = false;
        contactModeRelObj = new ContactModeRelationship();
        partnerPortalRoles = new Map<Id, UserRole>();
        customLookUP = new CustomLookup__c();
        initialize();   
        //initializeToolsOptions();
    }
    
    public Boolean showSolarUniverseFields {
        get{
            Boolean show = false;
            System.debug('parentAccountObj.name: ' + accountObj.name);
            if(accountObj != null 
                && accountObj.name != null 
                && accountObj.name != '' ){
                                    
                //isPartnerConcierge is set for the Partner Concierge
                if(isPartnerConcierge == false &&
                     accountObj.name.contains(PRMContactUtil.SOLAR_UNIVERSE)){
                    show = true;
                    return show;
                }       
            }
            return show;        
        }
        set;
     }
    
    public void initialize(){
        contactObj = new Contact();
        contactObj.active__c = true;
        contactObj.Deactivation_Reason__c = null;      
        contactObj.Accreditation_Status__c = '';
        contactObj.Application_Status__c = 'Not Received';
       // prmUserObj = new PRMUser();
        contactId = System.currentPagereference().getParameters().get('contactId');
        initializeLoginUser();
        initializeLoginContact();
        
        checkExistingContact();
        setAccountDetails();
        initializeJobFunctions();
        initializeTimeZones();
        initializeContactRoles();
        intializeRoleContactMaps();
        contactModeRelObj = new ContactModeRelationship();
        initializeContactModesobj();
        initializePartnerSites();
        getIsAEEUser();
        
        Set<String> spocUserIdSet = new Set<String>();
        for(SPOCUsers__c obj : SPOCUsers__c.getAll().values()){
            if(obj.SPOC_User_ID__c != null && string.valueOf(obj.SPOC_User_ID__c).length() >= 15)
                spocUserIdSet.add(string.valueOf(obj.SPOC_User_ID__c).subString(0,15));
        }
        
        isSPOCUser = (spocUserIdSet.contains(string.valueOf(UserInfo.getUserId()).subString(0,15))) ? true : false;
        if(isSPOCUser){
        contactObj.Job_Function__c = 'Outside Sales Representative';
        }
    }   
    
    public boolean getIsAEEUser(){
    
    string AEElabel = label.AEE_Label;
    User u = [select id, User_Division_Custom__c from User where Id =: UserInfo.getUserId()];
    isAEEUser = u.User_Division_Custom__c.contains(AEElabel)?True:False;
    system.debug('==>isAEEUser'+isAEEUser);
    return isAEEUser;
    }
    
    private void initializeLoginUser(){
        //Get login user's credentials
        Id userId = UserInfo.getUserId();
        Id profileId =  UserInfo.getProfileId();
        loginUser = PRMContactUtil.getUser(userId);
        if(loginUser != null && loginUser.ContactId == null){
            isPartnerConcierge = true;
        }else if(loginUser != null && loginUser.ContactId != null){
            isPartnerConcierge = false;
            List<Contact> contactObjList = new List<Contact>();
            contactObjList = [Select Id, email, AccountId from Contact where Id = :loginUser.ContactId]; 
            if(contactObjList.size() > 0)
            {
                loginUserContact = contactObjList[0];
                if(customLookup.account__c == null){
                    customLookup.account__c = contactObjList[0].AccountId;
                }
            }
        }
    }   

    private void initializeLoginContact(){
        System.debug('initializeLoginContact');
        if(loginUser == null){
            initializeLoginUser();
        }
        
        System.debug('loginUser.contactId: ' + loginUser.contactId);
        Set<Id> contactIds = new Set<Id>();
        if(loginUser.contactId != null){
            contactIds.add(loginUser.contactId);
            List<Contact> contactList = PRMContactUtil.getContacts(contactIds);
            if(contactList.size() > 0){
                loginUserContact = contactList[0];
                customLookup.account__c = loginUserContact.AccountId;
            }
        }else{
            Id tempAccountId = System.currentPagereference().getParameters().get('accountId');
            if(tempAccountId != null && customLookup.account__c == null){
                customLookup.account__c = tempAccountId;
            }
            
        }

    }   

    private void initializeJobFunctions(){
    
        jobFunctions = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Contact.Job_Function__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        jobFunctions.add(new SelectOption('', '--None--'));
        for( Schema.PicklistEntry entryVal : picklistValues)
        {
            jobFunctions.add(new SelectOption(entryVal.getValue(), entryVal.getLabel()));
        }       
        
     // contactObj.Job_Function__c = 'Outside Sales Representative';  
    }

    private void initializeTimeZones(){
        TimeZones = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = user.timeZoneSidKey.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry entryVal : picklistValues)
        {   
            /*
            String value = entryVal.getValue();
            if( value.startsWith('GMT') || value.startsWith('Atlantic') ||
                value.startsWith('America') || value.startsWith('Pacific') ){
                TimeZones.add(new SelectOption(entryVal.getValue(), entryVal.getLabel()));
                System.debug('entryVal.getValue() ' + entryVal.getValue());
            }
           */
        
            String label = entryVal.getLabel();
            if( label.contains('Los_Angeles') 
                || label.contains('Honolulu')
                || label.contains('New_York')
                || label.contains('Chicago')
                || label.contains('Denver')
                || label.contains('America/Phoenix')){
                TimeZones.add(new SelectOption(entryVal.getValue(), entryVal.getLabel()));
                 if((contactObj.timeZoneSidKey__c == null 
                    || contactObj.timeZoneSidKey__c == '') && label.contains('Los_Angeles')){
                    contactObj.timeZoneSidKey__c = entryVal.getValue();
                }   
            }   

        }       
    }
    
    public void initializeRoleNames(){
        Id accountId;
        if(customLookup.account__c!= null){
            accountId = customLookup.account__c;
            
        }else if(loginUserContact != null && loginUserContact.AccountId != null){
            accountId = loginUserContact.AccountId;
        }       
        for(UserRole roleObj : [Select Id, Name, PortalAccountId from UserRole where PortalAccountId =:accountId]){
            if(roleObj.name.contains(PRMContactUtil.USER_STR)){
                roleIdToName.put(roleObj.Id, PRMContactUtil.INDIVIDUAL_CONTRIBUTOR);
                roleNameToId.put(PRMContactUtil.INDIVIDUAL_CONTRIBUTOR, roleObj.Id);
            }else{
                roleIdToName.put(roleObj.Id, roleObj.name);
                roleNameToId.put(roleObj.name, roleObj.Id);
            }
        }
    }

    private void intializeRoleContactMaps(){
        contactMap = new Map<Id, Contact>();
        roleContactMap = new Map<String, List<Contact>>();
        contactRoleMap = new Map<String, Map<Id, Contact>>();
        
        Id accountId;
        System.debug('customLookup.account__c: ' + customLookup.account__c);
        if(customLookup.account__c!= null){
            accountId = customLookup.account__c;
        }else if(loginUserContact != null && loginUserContact.AccountId != null){
            accountId = loginUserContact.AccountId;
        }
        System.debug('accountId: ' + accountId);
        if(accountId == null){
            return;
        }

       initializeRoleNames();
        for(Contact tempContactObj: [Select Id, firstname, lastname, name, email, accountId, Salutation, title,
                                Key_Contact__c, active__c, Deactivation_Reason__c, Sells_Sunrun__c, Sells_in_CA__c,
                                Department, Job_Function__c, role__c, reportsToId, Phone, MobilePhone, 
                                Single_Point_of_Contact__c,timeZoneSidKey__c, MailingStreet, MailingCity, MailingState, 
                                MailingPostalCode,MailingCountry, 
                                 Fax, Birthdate, HomePhone,
                                Strength_of_relationship_with_SR__c, OtherPhone, Sales_Rep_Ranking__c, AssistantName,
                                T_Shirt_Size__c, AssistantPhone, Application_Status__c,Sales_Registration_Type__c,
                                Application_Submitted__c,  Sales_Registration_Number__c, Application_Received__c,
                                State_registration_expiration_date__c,Date_of_Hire__c, Rejection_Reason__c,
                                Accreditation_Status__c, Accreditation_date__c, Accreditation_period_start_date__c,
                                Partner_Portal_Access__c, Design_Tool_Access__c,
                                e_sign_documents_access__c, Delegated_Admin_Access__c,
                                Supress_EPC_Documents_Access__c, Supress_Sales_Documents_Access__c, 
                                Automatic_Document_Generation_Access__c,Accreditation_period_end_date__c, 
                                Proposal_Tool_Access__c, Can_Run_Change_Orders__c,
                                Sales_Registration_Next_Action_Owner__c,
                                Sales_Registration_License_Notes__c ,
                                Notes_License__c,Location__c,Profile__c,Contact_Number__c,Professional_Certification__c from Contact 
                                 where accountId = :accountId 
                                AND active__c = true 
                                order by name asc]){
            if(tempContactObj.role__C != null && tempContactObj.role__C != ''){
                Map<Id, Contact> tempContactMap = contactRoleMap.containskey(tempContactObj.role__C) ?  
                                        contactRoleMap.get(tempContactObj.role__C) : new Map<Id, Contact>();
                tempContactMap.put(tempContactObj.Id, tempContactObj);
                contactRoleMap.put(tempContactObj.role__C, tempContactMap);
            }else{
                contactMap.put(tempContactObj.Id, tempContactObj);
            }
        }       
        Contact tempContactObj;
        for(User userobj: [Select Id, name,contactId, userRoleId from user where contactId in :contactMap.keySet()]){
            
            if(userobj.userRoleId == null)
                continue;

            System.debug('userobj.userRoleId: ' + userobj.userRoleId);
        
            String tempRoleName = roleIdToName.get(userobj.userRoleId);
            if(tempRoleName == null)
                continue;
            
            System.debug('tempRoleName: ' + tempRoleName);

            String roleName = '';
            if(tempRoleName.contains(PRMContactUtil.EXECUTIVE)){
                roleName = PRMContactUtil.EXECUTIVE;
            }else if(tempRoleName.contains(PRMContactUtil.MANAGER)){
                roleName = PRMContactUtil.MANAGER;
            }if(tempRoleName.contains(PRMContactUtil.USER_STR)){
                roleName = PRMContactUtil.USER_STR;
            }
                
            Map<Id, Contact> tempContactMap = contactRoleMap.containskey(roleName) ?    
                                    contactRoleMap.get(roleName) : new Map<Id, Contact>();
            tempContactObj = contactMap.get(userobj.contactId);
            tempContactMap.put(userobj.contactId, tempContactObj);
            contactRoleMap.put(roleName, tempContactMap);
        }       
    }   


    private void initializeContactRoles(){
        ContactRoles = new List<SelectOption>();

        Schema.DescribeFieldResult fieldResult = Contact.Role__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry entryVal : picklistValues)
        {
            String roleValue = '';
            if(entryVal.getValue() == PRMContactUtil.INDIVIDUAL_CONTRIBUTOR){
                roleValue = PRMContactUtil.USER_STR;
            }else{
                roleValue = entryVal.getValue();
            }
            ContactRoles.add(new SelectOption(roleValue,entryVal.getLabel()));
        }           
    }

    private void setAccountDetails(){
        parentAccountObj = new Account();
        accountObj = new Account();
        if(customLookup.account__c!= null){
            accountObj = getAccount(customLookup.account__c);
            parentAccountId = PRMContactUtil.getUltimateParentAccountId(customLookup.account__c);
            if(parentAccountId != null && parentAccountId != customLookup.account__c){
                //parentAccountObj = getAccount(customLookup.account__c);
                parentAccountObj = getAccount(parentAccountId);
            }
        }
    }

    private Account getAccount(Id accountId){
        Account tempAccountObj = [Select Id, name, accountnumber, 
                                        Partner_Status__c, OwnerId
                                        from Account where id = :accountId];
        System.debug('Name1: ' + tempAccountObj.name);
        return tempAccountObj;
    }

    public List<SelectOption> getContactRoles(){
        intializeRoleContactMaps();
        initializeContactRoles();
        return ContactRoles;
    } 


    public List<SelectOption> getContactReportsToList(){
        intializeRoleContactMaps();
        initializeContactRoles();
        initializeReportsToInfo();
        return contactReportsToList;
    }
    
    private void initializeReportsToInfo(){
        contactReportsToList = new List<SelectOption>();
        contactReportsToList.add(new SelectOption('', '--'));
        String roleName = contactObj.Role__c;
        if(roleName == PRMContactUtil.INDIVIDUAL_CONTRIBUTOR){
            roleName = PRMContactUtil.USER_STR;
        }

        if(roleName == null || roleName == '' || roleName == PRMContactUtil.USER_STR){
            Map<Id, Contact> tempContactMap1 = contactRoleMap.get(PRMContactUtil.MANAGER);          
            if(tempContactMap1 != null && tempContactMap1.size() > 0){
                for(Contact tempContactObj1: tempContactMap1.values()){
                    contactReportsToList.add(new SelectOption(tempContactObj1.Id, tempContactObj1.name));
                }               
            }       
        }else if(roleName == PRMContactUtil.MANAGER){
            Map<Id, Contact> tempContactMap1 = contactRoleMap.get(PRMContactUtil.EXECUTIVE);            
            if(tempContactMap1 != null && tempContactMap1.size() > 0){
                for(Contact tempContactObj1: tempContactMap1.values()){
                    contactReportsToList.add(new SelectOption(tempContactObj1.Id, tempContactObj1.name));
                }               
            }
        }
    }
    
    private void initializeContactModesobj(){
        
        //if(isPartnerConcierge == true){
            setAccountDetails();    
        //}

        System.debug('parentAccountId: ' + parentAccountId);
        
        if(parentAccountId != null){
            contactModeRelObj.ultimateParentAccountId = parentAccountId;
        }

        if(accountObj != null && accountObj.Id != null){
            contactModeRelObj.accountId = accountObj.Id;
        } 
        
        if(existingContact != null){
            contactModeRelObj.contactId = existingContact.Id;
        }
        contactModeRelObj.initializeMultiSelectLists(); 
    }   

    List<Id> leftselected;
    public List<Id> getleftselected(){
        if(contactModeRelObj != null){
            leftselected = contactModeRelObj.leftselected;
        }
        return leftselected;
    }

    public void setleftselected(List<Id> leftselected){
        if(contactModeRelObj != null){
            contactModeRelObj.leftselected = leftselected;
        }
    }

    List<Id> rightselected;
    public List<Id> getRightselected(){
        if(contactModeRelObj != null){
            rightselected = contactModeRelObj.rightselected;
        }
        return rightselected;
    }

    public void setRightselected(List<Id> rightselected){
        if(contactModeRelObj != null){
            contactModeRelObj.rightselected = rightselected;
        }
    }

    public List<SelectOption> getAccountSites(){
        initializePartnerSites();
        return accountSites;
    }

     public List<SelectOption> getunSelectedValues(){
        if(contactModeRelObj != null){
            if(customLookup != null && 
                customLookup.account__c!= null && 
                contactModeRelObj.accountId != customLookup.account__c){
                initializeContactModesobj();
            }
            return contactModeRelObj.getunSelectedValues();
        }else {
            return  new List<SelectOption>();
        }
     }

     public List<SelectOption> getSelectedValues(){
        if(contactModeRelObj != null){
            return contactModeRelObj.getSelectedValues();
        }else {
            return  new List<SelectOption>();
        }
     }
     
     public PageReference selectclick(){
        if(contactModeRelObj != null){
            return contactModeRelObj.selectclick();
        }else{
            return null;
        }
     }   

     public PageReference unselectclick(){
        if(contactModeRelObj != null){
            return contactModeRelObj.unselectclick();
        }else{
            return null;
        }    
    }
    
    Public Boolean isSolarUniverseAccount{
        get{
            system.debug('parentAccountObj 11: ' + parentAccountObj);
            if(parentAccountObj != null && parentAccountObj.name == PRMContactUtil.SOLAR_UNIVERSE){
                return true;
            }else{
                return false;
            }
        }set;
    }
    
    public PageReference cancel() {
        String urlString = '/apex/PRMContactSearch';
        String params = '';
        if(contactObj != null && contactObj.accountId != null){
            urlString += '?accountId=' + contactObj.accountId;
        }else if(customLookup != null && customLookup.account__c != null){
             urlString += '?accountId=' + customLookup.account__c;
        }
        PageReference pageRef = new PageReference( urlString);
        return pageRef;  
    }

    public PageReference submit(){
        ApexPages.getMessages().clear();
        saveContactAndModes();
        if(ApexPages.getMessages().size() > 0){
            return null;
        }

        String urlString = '/apex/PRMViewContact';
        String params = '';
        if(contactObj != null && contactObj.Id != null){
            urlString += '?contactId=' + contactObj.Id;
        }
        PageReference pageRef = new PageReference( urlString);
        pageRef.setRedirect(true);
        return pageRef; 
    }
    
    public PageReference edit(){
        String urlString = '/apex/PRMCreateContact';
        String params = '';
        if(contactObj != null && contactObj.Id != null){
            urlString += '?contactId=' + contactObj.Id;
        }
        PageReference pageRef = new PageReference( urlString);
        pageRef.setRedirect(true);
        return pageRef; 
    }

    private void saveContactAndModes(){

        Contact oldContact = null;
        List<Contact> oldContacts;
        if(contactObj.Id != null){
            Set<Id> contactIds = new Set<Id>();
            contactIds.add(contactObj.Id);
            oldContacts = PRMContactUtil.getContacts(contactIds);
            if(oldContacts.size() > 0 ){
                oldContact = oldContacts[0];
            }   
        }else{
            oldContacts = PRMContactUtil.getContacts(contactObj.firstname, 
                                                    contactObj.lastname, contactObj.email);
            if(oldContacts.size() > 0 ){
                oldContact = oldContacts[0];
            }           
        }

        System.debug('Before Submit : ');
        validateInputs(oldContact);
        System.debug('apexpages.getMessages(): ' + apexpages.getMessages());
         if(apexpages.getMessages().size() > 0){
            return;
        }
        initializeDefaultValues();

        System.debug('Validations are completed ...');
        RecordType recordTypeObj = PRMLibrary.getPartnerContactRecordType();
        if(customLookup != null && 
            customLookup.account__c!= null){     
            contactObj.accountId = customLookup.account__c;
        }

        if(recordTypeObj != null ){
            contactObj.RecordTypeId = recordTypeObj.Id;
            contactObj.Contact_Type__c = 'Partner';
        }
        
        //BSKY-1012
        if(!accountObj.name.contains(PRMContactUtil.SOLAR_UNIVERSE)){
            List<Partner_Location__c> partnerlocObjList = [Select id,name,Account__c,Account_ID__c,Description__c,Headquarters__c 
                                                from Partner_Location__c 
                                                Where Account__c =:accountObj.id and Headquarters__c = true limit 1];
            
            if(partnerlocObjList != null && partnerlocObjList.size() > 0)
            {
                Partner_Location__c partnerlocObj = partnerlocObjList[0];
                if(partnerlocObj != null){
                    contactObj.Location__c = partnerlocObj.id;
                }                                   
            }
        }
        
        System.debug('contactObj: ' + contactObj);

        Savepoint sp = Database.setSavepoint();
        try{
            upsert contactObj;
            if(contactObj.active__c == true){
                Map<Id, Set<Id>> contactModeRelationmap = new Map<Id, Set<Id>>();
                contactModeRelationmap.put(contactObj.Id, contactModeRelObj.rightvalues.keySet());
                System.debug('contactModeRelationmap: ' + contactModeRelationmap);
                List<String> errorMessages = ContactModeRelationship.updateContactModeRelationships(contactModeRelationmap);
            }    
            updateContactRole();
        }catch(Exception exp){
            System.debug('Unable to Save Contact Details: ' + exp.getmessage());
            if(ApexPages.getMessages().size() == 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, exp.getmessage()));
            }
            Database.rollback(sp);
            return;
        }

        if(contactObj != null ){
            //sendContactModesToProposalTool(contactObj.Id);
        }           
        //managePartnerPortalAccess(oldContact);      

    }
    
    //@future (callout=true)
   // public static void sendContactModesToProposalTool(Id contactId){
   //     PRMContactModes prmContactModesObj = new PRMContactModes();
    //    prmContactModesObj.sendContactModesToProposalTool(contactId, false);
   // }


    
    private void checkExistingContact(){

        contactId = System.currentPagereference().getParameters().get('contactId');
        if(contactId != null){
            List<Contact> tempContacts = [Select Id, firstname, lastname, name, email, accountId, Salutation, title,
                                Key_Contact__c, active__c, Deactivation_Reason__c, Sells_Sunrun__c, Sells_in_CA__c,
                                Department, Job_Function__c, role__c, reportsToId, Phone, MobilePhone, 
                                Single_Point_of_Contact__c,timeZoneSidKey__c, MailingStreet, MailingCity, MailingState, 
                                MailingPostalCode,MailingCountry,
                                Fax, Birthdate, HomePhone,
                                Strength_of_relationship_with_SR__c, OtherPhone, Sales_Rep_Ranking__c, AssistantName,
                                T_Shirt_Size__c, AssistantPhone, Application_Status__c,Sales_Registration_Type__c,
                                Application_Submitted__c,  Sales_Registration_Number__c, Application_Received__c,
                                State_registration_expiration_date__c,Date_of_Hire__c, Rejection_Reason__c,
                                Accreditation_Status__c, Accreditation_date__c, Accreditation_period_start_date__c,
                                Accreditation_period_end_date__c, 
                                Proposal_Tool_Access__c, Partner_Portal_Access__c, Design_Tool_Access__c,
                                e_sign_documents_access__c,  Delegated_Admin_Access__c,
                                Supress_EPC_Documents_Access__c, Supress_Sales_Documents_Access__c, 
                                Automatic_Document_Generation_Access__c,Can_Run_Change_Orders__c,                                
                                Sales_Registration_Next_Action_Owner__c,
                                Sales_Registration_License_Notes__c ,
                                Notes_License__c,Location__c,Profile__c,Contact_Number__c,Professional_Certification__c from Contact where Id =:contactId];
            
            if(tempContacts != null && tempContacts.size() > 0){
                existingContact = tempContacts[0];
                contactObj = existingContact;
                customLookup.account__c= contactObj.AccountId;
                //checkExistingPRMUser();               
            }
        }
        
    }   

    private void validateInputs(Contact oldContact){

        if(customLookup.account__c== null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Select a Partner Account in order to save this record.'));
        }
        
        if ( contactObj.firstName == null || contactObj.firstName == '' ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Enter a value for First Name in order to save this record.'));
        }
        if ( contactObj.lastName == null || contactObj.lastName == '' ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Enter a value for Last Name in order to save this record.'));
        }

        if ( contactObj.email == null || contactObj.email == '' ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Enter a value for Email in order to save this record.'));
        }
        
        if ( contactObj.Title == null || contactObj.Title  == '' ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Enter a value for Title in order to save this record.'));
        }
  
        if ( contactObj.Job_Function__c == null || contactObj.Job_Function__c == '' ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Select a value for Job Function in order to save this record.'));
        }
          
        if(contactObj.Sells_Sunrun__c == null  || contactObj.Sells_Sunrun__c == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Select Sells Sunrun? value'));
         }

        if(contactObj.Sells_Sunrun__c != null && contactObj.Sells_Sunrun__c == 'Yes'
            && (contactObj.Sells_in_CA__c == null || contactObj.Sells_in_CA__c == '')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please specify if a sales rep sales Sunrun in the state of California.'));
         }

        if(contactObj.active__c == false && 
            (contactObj.Deactivation_Reason__c == null || contactObj.Deactivation_Reason__c == '')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Select Contact deactivation reason'));
         }
         
                  
         //BSKY-1012
 /*        if((contactObj.Partner_Portal_Access__c  == PRMContactUtil.GRANTED || contactObj.Partner_Portal_Access__c  == PRMContactUtil.REQUESTED)
            && (contactObj.profile__c == null || contactObj.profile__c == '')){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Profile is a required field when access to partner portal is requested or granted'));
         }   */
         if ( contactObj.Location__c == null && accountObj.name.contains(PRMContactUtil.SOLAR_UNIVERSE)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Enter a value for Location in order to save this record.'));
        }
        //
         
        if(isPartnerConcierge == false){
            if((contactObj.Proposal_Tool_Access__c == PRMContactUtil.GRANTED || contactObj.Proposal_Tool_Access__c == PRMContactUtil.REVOKED)
             && (oldContact == null || oldContact.Proposal_Tool_Access__c != contactObj.Proposal_Tool_Access__c)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                        PRMContactUtil.GRANTED_OPTION_ERROR));
            }

            if((contactObj.Can_Run_Change_Orders__c == PRMContactUtil.GRANTED || contactObj.Can_Run_Change_Orders__c == PRMContactUtil.REVOKED)
             && (oldContact == null || oldContact.Can_Run_Change_Orders__c != contactObj.Can_Run_Change_Orders__c)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                        PRMContactUtil.GRANTED_OPTION_ERROR));
            }
  /*          if((contactObj.Partner_Portal_Access__c == PRMContactUtil.GRANTED || contactObj.Partner_Portal_Access__c == PRMContactUtil.REVOKED) 
            && (oldContact == null || oldContact.Partner_Portal_Access__c != contactObj.Partner_Portal_Access__c)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                        PRMContactUtil.GRANTED_OPTION_ERROR));
            } */ 
            
            /*if((contactObj.Delegated_Admin_Access__c == PRMContactUtil.GRANTED || contactObj.Delegated_Admin_Access__c == PRMContactUtil.REVOKED)
             && (oldContact == null || oldContact.Delegated_Admin_Access__c != contactObj.Delegated_Admin_Access__c)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                        PRMContactUtil.GRANTED_OPTION_ERROR));
            }*/         

            if((contactObj.Design_Tool_Access__c == PRMContactUtil.GRANTED || contactObj.Design_Tool_Access__c == PRMContactUtil.REVOKED 
            || contactObj.Design_Tool_Access__c == PRMContactUtil.DENIED)
                && (oldContact == null || oldContact.Design_Tool_Access__c != contactObj.Design_Tool_Access__c)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                        PRMContactUtil.GRANTED_OPTION_ERROR));
            }           

            if((contactObj.e_sign_documents_access__c == PRMContactUtil.GRANTED || contactObj.e_sign_documents_access__c == PRMContactUtil.REVOKED
                || contactObj.e_sign_documents_access__c == PRMContactUtil.DENIED )
                && (oldContact == null || oldContact.e_sign_documents_access__c != contactObj.e_sign_documents_access__c)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                        PRMContactUtil.GRANTED_OPTION_ERROR));
            }

        }
        
        if(contactObj.active__C == true){
           /*  if((PRMContactUtil.GRANTED == contactObj.Delegated_Admin_Access__c 
                ||  PRMContactUtil.REQUESTED == contactObj.Delegated_Admin_Access__c ) && 
                (PRMContactUtil.GRANTED != contactObj.Partner_Portal_Access__c 
                 && PRMContactUtil.REQUESTED != contactObj.Partner_Portal_Access__c )){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Delegated admin access can be requested/granted only for the Partner Portal users.'));
             }  */
            
            if((PRMContactUtil.GRANTED == contactObj.Proposal_Tool_Access__c 
                ||  PRMContactUtil.REQUESTED == contactObj.Proposal_Tool_Access__c ) && 
                (getSelectedValues() == null || getSelectedValues().size() == 0)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please specify selling territories for Proposal Tool access'));
            }
        }
        
        if(PRMContactUtil.NOT_NEEDED == contactObj.Proposal_Tool_Access__c){
            contactObj.Can_Run_Change_Orders__c = PRMContactUtil.NOT_NEEDED;
        }else if(PRMContactUtil.REVOKED == contactObj.Proposal_Tool_Access__c){
            contactObj.Can_Run_Change_Orders__c = PRMContactUtil.REVOKED;
        }
        
        /*
        if(PRMContactUtil.NOT_NEEDED == contactObj.Proposal_Tool_Access__c){
            contactObj.e_sign_documents_access__c = PRMContactUtil.NOT_NEEDED;
        }else if(PRMContactUtil.REVOKED == contactObj.Proposal_Tool_Access__c){
            contactObj.e_sign_documents_access__c = PRMContactUtil.REVOKED;
        }
        */
    }

    private void initializeDefaultValues(){
        if(PRMContactUtil.YES == contactObj.Sells_Sunrun__c && PRMContactUtil.YES == contactObj.Sells_in_CA__c){
            if(contactObj.Application_Status__c == null || contactObj.Application_Status__c == ''){
                 contactObj.Application_Status__c = PRMContactUtil.NOT_RECEIVED;
            }
            
            
            if(contactObj.Accreditation_Status__c == null  || contactObj.Application_Status__c == ''){
                 contactObj.Accreditation_Status__c = PRMContactUtil.ACCREDITATION_PENDING;
                 //contactObj.Accreditation_period_start_date__c = date.today();
                 //contactObj.Accreditation_period_end_date__c = date.today().addDays(14);
            }
            /*
            if(contactObj.Accreditation_Status__c == PRMContactUtil.ACCREDITATION_PENDING 
                && (contactObj.Accreditation_period_start_date__c == null 
                    || contactObj.Accreditation_period_end_date__c == null)){
                 contactObj.Accreditation_period_start_date__c = date.today();
                 contactObj.Accreditation_period_end_date__c = date.today().addDays(14);
            }
            */
        }
    }
    
    private void initializePartnerSites(){
        siteId = null;
        oldSiteId = null;
        accountSites = new List<SelectOption>();
        Map<Id, String> accountSiteMap = new Map<Id, String>();
        accountSites.add(new SelectOption('', '--None--'));
        if(parentAccountId == null)
            return;
        
        accountSiteMap = PRMContactUtil.getPartnerSites(parentAccountId);
        for(Id accountId: accountSiteMap.keySet()){
            String siteName = accountSiteMap.get(accountId);
            accountSites.add(new SelectOption(accountId, siteName));
        }

        if(contactObj != null && contactObj.Id != null){
            List<AccountContactRole> contactRoleList = [Select Id, ContactId, AccountId,
                                                            Account.ParentId from AccountContactRole 
                                                            where ContactId =:contactObj.Id 
                                                            and Account.ParentId != null];
            if(contactRoleList.size() > 0){
                siteId = contactRoleList[0].AccountId;
                oldSiteId = contactRoleList[0].AccountId;
            }
        }
        
     }
     
     private void updateContactRole(){

        if(contactObj != null){

            if(contactObj.Id == null)
                return;
            
            System.debug('oldSiteId: ' + oldSiteId);
            System.debug('siteId: ' + siteId);
            
            if(oldSiteId != siteId){
                if(oldSiteId != null){
                    //Delete existing Contact role
                    List<AccountContactRole> contactRoleList = [Select Id, ContactId, AccountId from AccountContactRole where ContactId =:contactObj.Id];
                    if(contactRoleList != null && contactRoleList.size() > 0 ){
                        delete contactRoleList;
                    }
                }

                if(siteId != null){
                    AccountContactRole contactRoleObj = new AccountContactRole();
                    contactRoleObj.ContactId = contactObj.Id;
                    contactRoleObj.AccountId = siteId;
                    contactRoleObj.Role = 'Other';      
                    insert contactRoleObj;
                }
            }

        }
        
     }
     
     public Boolean isPartnerPortalAccess{
        get{
            if(PRMContactUtil.GRANTED == contactObj.Partner_Portal_Access__c 
                 || PRMContactUtil.REQUESTED == contactObj.Partner_Portal_Access__c ){
                return true;
            }else{
                return false;
            }
        }set;
    }
    
    public Boolean showLocation {
        get{
            Boolean show = false;
            System.debug('parentAccountObj.name: ' + accountObj.name);
            if(accountObj != null 
                && accountObj.name != null 
                && accountObj.name != '' ){

                if(accountObj.name.contains(PRMContactUtil.SOLAR_UNIVERSE)){
                    show = true;
                    return show;
                }       
            }
            return show;        
        }
        set;
     }
    
}