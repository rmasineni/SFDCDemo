public class PRMContactUtil {

    public static String SOLAR_UNIVERSE = 'Solar Universe';
    public static String INDIVIDUAL_CONTRIBUTOR = 'Individual Contributor';
    public static String NOT_NEEDED = 'Not Needed';
    public static String USER_STR = 'User';
    public static String MANAGER = 'Manager';
    public static String EXECUTIVE = 'Executive';
    public static String GRANTED = 'Granted';
    public static String DENIED = 'Denied';
    public static String REQUESTED = 'Requested';
    public static String RECEIVED = 'Received';
    public static String REVOKED = 'Revoked';
    public static String REJECTED = 'Rejected';
    public static String RESUBMITTED = 'Resubmitted';
    public static String APPROVED = 'Approved';
    public static String YES = 'Yes';
    public static String NO = 'No';
    public static String SUBMITTED = 'Submitted';
    public static final String DelegatedAdmin = Label.PartnerAdminProfileName;
    public static final String PENDING_LEAGAL_REVIEW = 'Pending Legal Review - Criminal';
    public static final String Operations = Label.PartnerOperationsProfileName;
    public static final String Sales = Label.PartnerSalesProfileName;
    public static final String INCOMPLETE = 'Incomplete';
    public static final String NOT_RECEIVED = 'Not Received';
    public static final String NOT_ACCREDITED = 'Not Accredited';
    public static final String NOT_A_SALES_PERSON = 'Not a salesperson - accreditation not needed';
    
    public static final String NOT_APPLICABLE = 'Not Applicable';
    public static final String ACCREDITED = 'Accredited';
    public static final String ACCREDITATION_PENDING = 'Accreditation Pending';
    public static final String NOT_ACCRIDITED_ERROR = 'This contact does not have valid accreditation status. Please do not grant tools access';
    public static final String NOT_CSLB_ERROR = 'Sunrun does not have valid sales registration information about this contact. Please do not grant access to tools.';
    public static final String GRANTED_OPTION_ERROR = 'Partners are not allowed to select Granted/Revoked/Denied options for tools access';
    
    //Added for BSKY-1012
    public static String PARTNERSALES = 'Partner Sales';
    public static String PARTNEROPS = 'Partner Operations';
    public static String SPOC = 'SPOC';
    
    private static Map<String, Id> profileMap = null;
    
    public static Set<Id> emailidssent = new Set<Id>();
    
    private static Map<String, String> profileNameToId = null;
    private static Map<String, String> profileIdToName = null;

    private static void initalize(){
        if(profileNameToId != null && profileIdToName != null)
            return;
        profileNameToId = new Map<String, String>();
        profileIdToName = new Map<String, String>();
        Set<String> profileNames = new Set<String>();
        profileNames.add(Sales);
        profileNames.add(DelegatedAdmin);
        profileNames.add(Operations);
        
        for(Profile profileObj: [select Id, Name from Profile where name in :profileNames]){
            profileNameToId.put(profileObj.name, profileObj.Id);
            profileIdToName.put(profileObj.Id, profileObj.name);
            System.debug('profileNameToId:' + profileNameToId);
            System.debug('profileIdToName:' + profileIdToName);
        }
    }

    public static Id getProfileId(String name){
        initalize();
        Id profileId = profileNameToId.get(name);
        return profileId;
    }

    public static String getProfileName(Id profileId){
        initalize();
        String profileName = profileIdToName.get(profileId);
        return profileName;
    }
    
    
    public static User loginUser;
    public static User getLoginUser(){
        //Get login user's credentials
        Id userId = UserInfo.getUserId();
        system.debug('userId---->'+userId);
        if(loginUser == null || loginUser.Id != userId){
            system.debug('Entering 1--->');
            loginUser = PRMContactUtil.getUser(userId);
        }
        return loginUser;   
    }

    public static Contact getLoginUserContact(){
        User userObj = PRMContactUtil.getLoginUser();
        Contact loginContact;
        if(userObj.contactId != null){
            Set<Id> contactIds = new Set<Id>();
            contactIds.add(userObj.contactId);
            List<Contact> contactList = PRMContactUtil.getContacts(contactIds);
            if(contactList.size() > 0){
                loginContact = contactList[0];
            }
        }
        return loginContact;
    }
    
    public static User getUser(Id userId){
        List<User> usersList = new List<User>();
        User userObj;
        usersList = [Select Id, name, userName, profileId, CompanyName, firstname, lastname, 
                            email, contactId,User_Division_Custom__c from User where Id = :userId];
        system.debug('usersList------>'+usersList);
        if(usersList != null && !usersList.isEmpty()){
            userObj = usersList[0];
        }
        return userObj;
    }

    public static List<Contact> getContacts(String firstNameStr, String lastNameStr, String emailStr){
        List<Contact> contactList = [Select Id, firstname, lastname, name, email, accountId, Salutation, title,
                                Key_Contact__c, active__c, Deactivation_Reason__c, Sells_Sunrun__c, Sells_in_CA__c,
                                Department, Job_Function__c, role__c, reportsToId, Phone, MobilePhone, 
                                Single_Point_of_Contact__c,timeZoneSidKey__c, MailingStreet, MailingCity, MailingState, 
                                MailingPostalCode,MailingCountry,Preferred_Language__c,
                                Fax, Birthdate, HomePhone, Alternate_Phone__c, 
                                Design_New_Proposal__c,Modify_Proposal__c,Manual_Design__c,As_Built__c,eAudit__c,ePermitting__c,Managing_Partner_AVL_Costs__c,Managing_Partner_AVL_Prices__c,//Santosh Changes
                                Strength_of_relationship_with_SR__c, OtherPhone, Sales_Rep_Ranking__c, AssistantName,
                                T_Shirt_Size__c, AssistantPhone, Application_Status__c,Sales_Registration_Type__c,
                                Application_Submitted__c,  Sales_Registration_Number__c, Application_Received__c,
                                State_registration_expiration_date__c,Date_of_Hire__c, Rejection_Reason__c,
                                Location__c, Location__r.Id, Location__r.Headquarters__c,Professional_Certification__c,Contact_Number__c,
                                Accreditation_Status__c, Accreditation_date__c, Accreditation_period_start_date__c,
                                Ultimate_Parent_Account__c,Sales_Registration_Next_Action_Owner__c,
                                Accreditation_period_end_date__c, Notes_License__c,
                                Sales_Registration_License_Notes__c,Sunrun_User__c,
                                Account.Account_Manager__c, Account.Name,Account.stage__c,
                                Account.Site,
                                Account.ValidDomains__C, Profile__c
                                from Contact where firstName =:firstNameStr
                                and lastName =:lastNameStr 
                                and email =:emailStr order by name asc];
        return contactList;
    }
    
    public static List<Contact> getContacts(Set<String> contactIds){
        String soqlStr = getContactSOQL();
        soqlStr += '  where Id = :contactIds order by name asc ';
        List<Contact> contactList = Database.query(soqlStr);
        return contactList;
    }
    
    public static String getContactSOQL(){
        String contactSOQL = 'Select Id, firstname, lastname, name, email, accountId, Salutation, title,';
                contactSOQL += 'Key_Contact__c, active__c, Deactivation_Reason__c, Sells_Sunrun__c, Sells_in_CA__c,';
                contactSOQL += 'Department, Job_Function__c, role__c, reportsToId, Phone, MobilePhone,';
                contactSOQL += 'Single_Point_of_Contact__c,timeZoneSidKey__c, MailingStreet, MailingCity, MailingState, ';
                contactSOQL += 'MailingPostalCode,MailingCountry,Fax, Birthdate, HomePhone,';
                contactSOQL += 'Strength_of_relationship_with_SR__c, OtherPhone, Sales_Rep_Ranking__c, AssistantName,';
                contactSOQL += 'T_Shirt_Size__c, AssistantPhone, Application_Status__c,Sales_Registration_Type__c,';
                contactSOQL += 'Application_Submitted__c,  Sales_Registration_Number__c, Application_Received__c,';
                contactSOQL += 'State_registration_expiration_date__c,Date_of_Hire__c, Rejection_Reason__c,';
                contactSOQL += 'Accreditation_Status__c, Accreditation_date__c, Accreditation_period_start_date__c,';
                contactSOQL += 'Ultimate_Parent_Account__c, Partner_Portal_Access__c, Design_Tool_Access__c,';
                contactSOQL += 'e_sign_documents_access__c,  Delegated_Admin_Access__c, proposal__c,Professional_Certification__c,Contact_Number__c, ';
                contactSOQL += 'Location__c, Location__r.Id, Location__r.Headquarters__c,';
                contactSOQL += 'Supress_EPC_Documents_Access__c, Supress_Sales_Documents_Access__c, ';
                contactSOQL += 'Automatic_Document_Generation_Access__c,Accreditation_period_end_date__c, ';
                contactSOQL += 'Proposal_Tool_Access__c, Notes_License__c, Can_Run_Change_Orders__c,Preferred_Language__c,';
                contactSOQL += 'Design_New_Proposal__c,Modify_Proposal__c,Manual_Design__c,As_Built__c,eAudit__c,ePermitting__c,Managing_Partner_AVL_Costs__c,Managing_Partner_AVL_Prices__c, ';//Santosh Changes
                contactSOQL += 'Account.Account_Manager__c, Account.Name,Account.stage__c,';
                contactSOQL += 'Account.ValidDomains__C, Account.Site, Sales_Registration_Next_Action_Owner__c,';
                contactSOQL += 'Alternate_Phone__c,';
                contactSOQL += 'Sales_Registration_License_Notes__c,Profile__c,Sunrun_User__c  from Contact ';
        return contactSOQL;
    }

    public static Map<Id, Contact> contactMap1 = new Map<Id, Contact>();
    public static List<Contact> getContacts(Set<Id> contactIds){
        List<Contact> contactList = new List<Contact>();
        Boolean getContacts = false;
        for(Id contactId : contactIds){
            if(contactMap1 == null || contactMap1.isEmpty() || !contactMap1.containsKey(contactId)){
                getContacts = true;
                break;
            }else {
                contactList.add(contactMap1.get(contactId));
            }
            
        }
        
        if(getContacts == false){
            return contactList;
        }else if(getContacts == true){
            contactMap1 = new Map<Id, Contact>([Select Id, firstname, lastname, name, email, accountId, Salutation, title,
                                Key_Contact__c, active__c, Deactivation_Reason__c, Sells_Sunrun__c, Sells_in_CA__c,
                                Department, Job_Function__c, role__c, reportsToId, Phone, MobilePhone, 
                                Single_Point_of_Contact__c,timeZoneSidKey__c, MailingStreet, MailingCity, MailingState, 
                                MailingPostalCode,MailingCountry, 
                                 Fax, Birthdate, HomePhone, Alternate_Phone__c, 
                                Strength_of_relationship_with_SR__c, OtherPhone, Sales_Rep_Ranking__c, AssistantName,
                                T_Shirt_Size__c, AssistantPhone, Application_Status__c,Sales_Registration_Type__c,
                                Application_Submitted__c,  Sales_Registration_Number__c, Application_Received__c,
                                State_registration_expiration_date__c,Date_of_Hire__c, Rejection_Reason__c,
                                Accreditation_Status__c, Accreditation_date__c, Accreditation_period_start_date__c,
                                Ultimate_Parent_Account__c, Partner_Portal_Access__c, Design_Tool_Access__c,
                                e_sign_documents_access__c,  Delegated_Admin_Access__c,
                                Location__c, Location__r.Id, Location__r.Headquarters__c,Professional_Certification__c,Contact_Number__c,
                                Supress_EPC_Documents_Access__c, Supress_Sales_Documents_Access__c, 
                                Automatic_Document_Generation_Access__c,Accreditation_period_end_date__c, 
                                Proposal_Tool_Access__c, Notes_License__c, Can_Run_Change_Orders__c,
                                Account.Account_Manager__c, Account.Name,Account.stage__c,Sunrun_User__c,
                                Account.ValidDomains__C, Account.Site, 
                                Sales_Registration_Next_Action_Owner__c,
                                Sales_Registration_License_Notes__c,Profile__c,
                                Design_New_Proposal__c,Modify_Proposal__c,Manual_Design__c,As_Built__c,eAudit__c,ePermitting__c,Managing_Partner_AVL_Costs__c,Managing_Partner_AVL_Prices__c //Santosh Changes
                                from Contact where Id = :contactIds order by name asc]);
        }
        return contactMap1.values();
    }

    public static Id getUltimateParentAccountId(Id accountId){
        Id parentAccountId = accountId;
        while(true){
            Account  accountObj = [Select Id, name,ParentId from Account
                                    where Id =:accountId];
            if(accountObj.ParentId == null){
                parentAccountId = accountObj.Id;
                break;              
            }else{
                accountId = accountObj.ParentId;
            }
        }
        return parentAccountId;
    }

    
    public static Id getProfileId(Account accountObj, Contact contactObj){
        Id profileId;
        Map<String, Id> tempProfileMap = PRMContactUtil.getPartnerProfileMap();
        /*if(GRANTED == contactObj.Delegated_Admin_Access__c){
            profileId = tempProfileMap.get(Label.PartnerAdminProfileName);
        }else{
            Boolean isInstallPartner = false;
            if(accountObj.Partner_Type__c != null && accountObj.Partner_Type__c  != ''){
                if(accountObj.Partner_Type__c.contains('Install') || accountObj.Partner_Type__c.contains('Full Service')){
                    isInstallPartner = true;
                }
            }
            
            if(isInstallPartner == false){
                profileId = tempProfileMap.get(Label.PartnerSalesProfileName);
            }else{
                if(NO == contactObj.Sells_Sunrun__c){
                    profileId = tempProfileMap.get(Label.PartnerOperationsProfileName);
                }else{
                    profileId = tempProfileMap.get(Label.PartnerSalesProfileName);
                }
            }
        }
        if(profileId == null){
            tempProfileMap.get(Label.PartnerSalesProfileName);
        } */
        
        //BSKY-1012
        if(PARTNERSALES == contactObj.Profile__c){
            profileId = tempProfileMap.get(Label.PartnerSalesProfileName);
        }else if(PARTNEROPS == contactObj.Profile__c){
            profileId = tempProfileMap.get(Label.PartnerOperationsProfileName);
        }else if(SPOC == contactObj.Profile__c){
            profileId = tempProfileMap.get(Label.PartnerAdminProfileName);
        }
        return profileId;
    }
    
    
    public static String validateDatabaseOperation(Database.Saveresult upsertUserResult){
        String errorMessage = 'Unable to create the user. ';
        for(Database.error dbErrorObj: upsertUserResult.getErrors()){
            String tempString = dbErrorObj.getMessage();
            if(tempString != null && tempString.contains('Email:')){
                errorMessage += 'Invalid email address';
            }else{
                errorMessage += tempString;
            }
        }   
        return errorMessage;        
    }
    
    public static String validateAccount(Account accountObj){
        String errorMessage = null;
        if(accountObj == null){
            errorMessage = 'Unable to create the portal user : Contact does not have a valid Partner Account';
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));  
            return errorMessage;
        }
        
        if(accountObj.Account_Type__c == null ||   
            accountObj.Account_Type__c != PRMLibrary.PARTNER){
            errorMessage = accountObj.name + ' is not a Partner Account';
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));      
        }           
                
        if(accountObj.Active__c != true ){
            errorMessage = accountObj.name + ' is not an active Partner Account';
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));              
        }               
                
        if(accountObj.parentId != null){
            errorMessage = 'Partner users can\'t associated with the child accounts';
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));              
        }

        if(accountObj.isPartner != true){
            errorMessage = 'Partner Portal is not enabled for ' + accountObj.name ;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));              
        }       
        return errorMessage;
    }

    public static String getUniqueAlias(String tempAlias){
        while(true){
            List<User> users = [Select Id, alias from User where alias = :tempAlias];
            if(users == null || users.size() == 0){
                return tempAlias;
            }else{
                tempAlias = RandomNumberGenerator.generateRandomNumber(4);
            }
        }
        return tempAlias;
    }

    public static String getUniqueNickname(String tempNickname){
        while(true){
            List<User> users = [Select Id, CommunityNickname from User 
                                    where CommunityNickname = :tempNickname];
            if(users == null || users.size() == 0){
                return tempNickname;
            }else{
                tempNickname = RandomNumberGenerator.generateRandomNumber(8);
            }
        }
        return tempNickname;
    }

    public static Map<Id, User> getExistingPortalUsers(Set<Id> contactIds){
        
        Map<Id, User> existingPortalUsers = new Map<Id, User>();
        for(User userObj : [Select Id, firstName, lastName,
                            contactId, alias, userRoleId,
                            CommunityNickname, email, 
                            profileId, userName, 
                            TimeZoneSidKey, EmailEncodingKey, 
                            LocaleSidkey, LanguageLocaleKey
                            from user where contactId = :contactIds]){
                                
            existingPortalUsers.put(userObj.contactId, userObj);            
        }
        return existingPortalUsers;
    }

    public static Map<Id, Map<String, UserRole>> getUserRoles(Set<Id> accountIds){
        Map<Id, Map<String, UserRole>> partnerRoleMap = new Map<Id, Map<String, UserRole>>();
        for(UserRole roleObj : [Select Id, Name, PortalAccountId from UserRole where PortalAccountId in :accountIds order by PortalAccountId]){
            String roleName = '';
            if(roleObj.name.contains(PRMContactUtil.EXECUTIVE)){
                roleName = PRMContactUtil.EXECUTIVE;
            }else if(roleObj.name.contains(PRMContactUtil.MANAGER)){
                roleName = PRMContactUtil.MANAGER;
            }if(roleObj.name.contains(PRMContactUtil.USER_STR)){
                roleName = PRMContactUtil.USER_STR;
            }
            Map<String, UserRole> nameRoleMap = partnerRoleMap.containskey(roleObj.PortalAccountId) ? 
                                                    partnerRoleMap.get(roleObj.PortalAccountId) 
                                                    : new Map<String, UserRole>();
            nameRoleMap.put(roleName, roleObj);
            partnerRoleMap.put(roleObj.PortalAccountId, nameRoleMap);
        }
        System.debug('partnerRoleMap: ' + partnerRoleMap);
        return partnerRoleMap;
    }
    
    
    public static Map<String, Id> getPartnerProfileMap(){
        
        if(profileMap == null ){
            profileMap = new Map<String, Id>();
            for(Profile profileObj : [Select Id, name  from Profile 
                                        where name in ( :Label.PartnerAdminProfileName, 
                                                        :Label.PartnerOperationsProfileName, 
                                                        :Label.PartnerSalesProfileName)]){
                profileMap.put(profileObj.Name, profileObj.Id);
            }
        }
        return profileMap;
    }

    public static void revokeSalesToolsAccess(Contact contactObj){
        /*-----Code Added to Copy old Access Values (3/3/2014)---Prashanth Veloori--------*/
        contactObj.Previous_Design_Tool__c=contactObj.Design_Tool_Access__c;
        contactObj.Previous_Partner_Portal__c=contactObj.Partner_Portal_Access__c;
        contactObj.Previous_Proposal_Tool__c=contactObj.Proposal_Tool_Access__c;
        /*-------------------Code Cahnge End----------------------------------------------*/
        contactObj.Proposal_Tool_Access__c = (contactObj.Proposal_Tool_Access__c == GRANTED) ? REVOKED 
                                                : ((contactObj.Proposal_Tool_Access__c == NOT_NEEDED 
                                                    || contactObj.Proposal_Tool_Access__c == REQUESTED) ? NOT_NEEDED : contactObj.Proposal_Tool_Access__c);

        contactObj.Design_Tool_Access__c = (contactObj.Design_Tool_Access__c == GRANTED) ? REVOKED 
                                                : ((contactObj.Design_Tool_Access__c == NOT_NEEDED 
                                                    || contactObj.Design_Tool_Access__c == REQUESTED) ? NOT_NEEDED : contactObj.Design_Tool_Access__c);

        contactObj.e_sign_documents_access__c = (contactObj.e_sign_documents_access__c == GRANTED) ? REVOKED 
                                                : ((contactObj.e_sign_documents_access__c == NOT_NEEDED 
                                                    || contactObj.e_sign_documents_access__c == REQUESTED) ? NOT_NEEDED : contactObj.e_sign_documents_access__c);

        contactObj.Can_Run_Change_Orders__c = (contactObj.Can_Run_Change_Orders__c == GRANTED) ? REVOKED 
                                                : ((contactObj.Can_Run_Change_Orders__c == NOT_NEEDED 
                                                    || contactObj.Can_Run_Change_Orders__c == REQUESTED) ? NOT_NEEDED : contactObj.Can_Run_Change_Orders__c);
    }


    public static void revokeToolsAccessOnlyIfGranted(Contact contactObj){
        contactObj.Proposal_Tool_Access__c = (contactObj.Proposal_Tool_Access__c == GRANTED) ? REVOKED : contactObj.Proposal_Tool_Access__c;
        contactObj.Partner_Portal_Access__c = (contactObj.Partner_Portal_Access__c == GRANTED) ? REVOKED : contactObj.Partner_Portal_Access__c;
        contactObj.Design_Tool_Access__c = (contactObj.Design_Tool_Access__c == GRANTED) ? REVOKED : contactObj.Design_Tool_Access__c;
        contactObj.e_sign_documents_access__c = (contactObj.e_sign_documents_access__c == GRANTED) ? REVOKED : contactObj.e_sign_documents_access__c;
        contactObj.Can_Run_Change_Orders__c = (contactObj.Can_Run_Change_Orders__c == GRANTED) ? REVOKED : contactObj.Can_Run_Change_Orders__c;
        contactObj.Delegated_Admin_Access__c = (contactObj.Delegated_Admin_Access__c == GRANTED) ? REVOKED : contactObj.Delegated_Admin_Access__c;
        
        contactObj.Supress_EPC_Documents_Access__c = (contactObj.Supress_EPC_Documents_Access__c == GRANTED) ? REVOKED : contactObj.Supress_EPC_Documents_Access__c;
        contactObj.Supress_Sales_Documents_Access__c = (contactObj.Supress_Sales_Documents_Access__c == GRANTED) ? REVOKED : contactObj.Supress_Sales_Documents_Access__c;
        contactObj.Automatic_Document_Generation_Access__c = (contactObj.Automatic_Document_Generation_Access__c == GRANTED) ? REVOKED : contactObj.Automatic_Document_Generation_Access__c;
    }

    public static void revokeToolsAccess(Contact contactObj, boolean solarUniverseAccount){
        
        contactObj.Proposal_Tool_Access__c = (contactObj.Proposal_Tool_Access__c == GRANTED) ? REVOKED 
                                                : ((contactObj.Proposal_Tool_Access__c == NOT_NEEDED 
                                                    || contactObj.Proposal_Tool_Access__c == REQUESTED) ? NOT_NEEDED : contactObj.Proposal_Tool_Access__c);
        
        contactObj.Partner_Portal_Access__c = (contactObj.Partner_Portal_Access__c == GRANTED) ? REVOKED 
                                                : ((contactObj.Partner_Portal_Access__c == NOT_NEEDED 
                                                    || contactObj.Partner_Portal_Access__c == REQUESTED) ? NOT_NEEDED : contactObj.Partner_Portal_Access__c);

        contactObj.Design_Tool_Access__c = (contactObj.Design_Tool_Access__c == GRANTED) ? REVOKED 
                                                : ((contactObj.Design_Tool_Access__c == NOT_NEEDED 
                                                    || contactObj.Design_Tool_Access__c == REQUESTED) ? NOT_NEEDED : contactObj.Design_Tool_Access__c);
                                                    
        contactObj.e_sign_documents_access__c = (contactObj.e_sign_documents_access__c == GRANTED) ? REVOKED 
                                                : ((contactObj.e_sign_documents_access__c == NOT_NEEDED 
                                                    || contactObj.e_sign_documents_access__c == REQUESTED) ? NOT_NEEDED : contactObj.e_sign_documents_access__c);

        contactObj.Can_Run_Change_Orders__c = (contactObj.Can_Run_Change_Orders__c == GRANTED) ? REVOKED 
                                                : ((contactObj.Can_Run_Change_Orders__c == NOT_NEEDED 
                                                    || contactObj.Can_Run_Change_Orders__c == REQUESTED) ? NOT_NEEDED : contactObj.Can_Run_Change_Orders__c);

        contactObj.Delegated_Admin_Access__c = (contactObj.Delegated_Admin_Access__c == GRANTED) ? REVOKED 
                                                : ((contactObj.Delegated_Admin_Access__c == NOT_NEEDED 
                                                    || contactObj.Delegated_Admin_Access__c == REQUESTED) ? NOT_NEEDED : contactObj.Delegated_Admin_Access__c);

        contactObj.Supress_EPC_Documents_Access__c = (contactObj.Supress_EPC_Documents_Access__c == GRANTED) ? REVOKED 
                                                : ((contactObj.Supress_EPC_Documents_Access__c == NOT_NEEDED 
                                                    || contactObj.Supress_EPC_Documents_Access__c == REQUESTED) ? NOT_NEEDED : contactObj.Supress_EPC_Documents_Access__c);

        contactObj.Supress_Sales_Documents_Access__c = (contactObj.Supress_Sales_Documents_Access__c == GRANTED) ? REVOKED 
                                                : ((contactObj.Supress_Sales_Documents_Access__c == NOT_NEEDED 
                                                    || contactObj.Supress_Sales_Documents_Access__c == REQUESTED) ? NOT_NEEDED : contactObj.Supress_Sales_Documents_Access__c);

        contactObj.Automatic_Document_Generation_Access__c = (contactObj.Automatic_Document_Generation_Access__c == GRANTED) ? REVOKED 
                                                : ((contactObj.Automatic_Document_Generation_Access__c == NOT_NEEDED 
                                                    || contactObj.Automatic_Document_Generation_Access__c == REQUESTED) ? NOT_NEEDED : contactObj.Automatic_Document_Generation_Access__c);
    }
    
    public static void setToolsAccessToRequested(Contact contactObj, boolean solarUniverseAccount){
        
        if(REQUESTED == contactObj.Proposal_Tool_Access__c || GRANTED == contactObj.Proposal_Tool_Access__c ){
            contactObj.Proposal_Tool_Access__c = REQUESTED;
        }

 /*       if(REQUESTED == contactObj.Partner_Portal_Access__c || GRANTED == contactObj.Partner_Portal_Access__c){
            contactObj.Partner_Portal_Access__c = REQUESTED;
        }   */       

        if(REQUESTED == contactObj.Design_Tool_Access__c || GRANTED == contactObj.Design_Tool_Access__c){
            contactObj.Design_Tool_Access__c = REQUESTED;
        }

        if(REQUESTED == contactObj.e_sign_documents_access__c || GRANTED == contactObj.e_sign_documents_access__c){
            contactObj.e_sign_documents_access__c = REQUESTED;
        }

        if(REQUESTED == contactObj.Can_Run_Change_Orders__c  || GRANTED == contactObj.Can_Run_Change_Orders__c  ){
            contactObj.Can_Run_Change_Orders__c = REQUESTED;
        }

        if(REQUESTED == contactObj.Delegated_Admin_Access__c || GRANTED == contactObj.Delegated_Admin_Access__c){
            contactObj.Delegated_Admin_Access__c = REQUESTED;
        }           

        if(solarUniverseAccount){
            if(REQUESTED == contactObj.Supress_EPC_Documents_Access__c || GRANTED == contactObj.Supress_EPC_Documents_Access__c){
                contactObj.Supress_EPC_Documents_Access__c = REQUESTED;
            }
    
            if(REQUESTED == contactObj.Supress_Sales_Documents_Access__c  || GRANTED == contactObj.Supress_Sales_Documents_Access__c  ){
                contactObj.Supress_Sales_Documents_Access__c = REQUESTED;
            }
    
            if(REQUESTED == contactObj.Automatic_Document_Generation_Access__c || GRANTED == contactObj.Automatic_Document_Generation_Access__c){
                contactObj.Automatic_Document_Generation_Access__c = REQUESTED;
            }

        }
        
    }

    public static Boolean hasValidApplicationSubmittedDate(Contact contactObj){
        if(contactObj.Sells_Sunrun__c == YES && contactObj.Sells_in_CA__c == YES 
            && (SUBMITTED == contactObj.Application_Status__c  || RESUBMITTED == contactObj.Application_Status__c)
            && contactObj.Application_Submitted__c != null){
            Date dateObj =  date.today();
            dateObj.addDays(90);
            if(contactObj.CSLB_application_end_date__c <  dateObj){
                return false;
            }
        }       
        return true;
    }

    public static void grantToolsAccess(Contact contactObj, boolean solarUniverseAccount){
        
        if(contactObj.active__c != true)
            return;
            
        if(hasValidApplicationSubmittedDate(contactObj) == false){
            revokeToolsAccessOnlyIfGranted(contactObj);
            return;
        }
            

        if(REQUESTED == contactObj.Proposal_Tool_Access__c && contactObj.Application_Status__c != PENDING_LEAGAL_REVIEW){
            contactObj.Proposal_Tool_Access__c = GRANTED;
        }

        if(REQUESTED == contactObj.Partner_Portal_Access__c && contactObj.Application_Status__c != PENDING_LEAGAL_REVIEW){
            contactObj.Partner_Portal_Access__c = GRANTED;
        }       

        //if(REQUESTED == contactObj.Design_Tool_Access__c){
        //  contactObj.Design_Tool_Access__c = GRANTED;
        //}

        //if(REQUESTED == contactObj.e_sign_documents_access__c){
        //  contactObj.e_sign_documents_access__c = GRANTED;
        //}

        if(REQUESTED == contactObj.Can_Run_Change_Orders__c   && contactObj.Application_Status__c != PENDING_LEAGAL_REVIEW ){
            contactObj.Can_Run_Change_Orders__c = GRANTED;
        }

        if(REQUESTED == contactObj.Delegated_Admin_Access__c && contactObj.Application_Status__c != PENDING_LEAGAL_REVIEW){
            contactObj.Delegated_Admin_Access__c = GRANTED;
        }       

        if(solarUniverseAccount){
            if(REQUESTED == contactObj.Supress_EPC_Documents_Access__c && contactObj.Application_Status__c != PENDING_LEAGAL_REVIEW){
                contactObj.Supress_EPC_Documents_Access__c = GRANTED;
            }
    
            if(REQUESTED == contactObj.Supress_Sales_Documents_Access__c && contactObj.Application_Status__c != PENDING_LEAGAL_REVIEW ){
                contactObj.Supress_Sales_Documents_Access__c = GRANTED;
            }
    
            if(REQUESTED == contactObj.Automatic_Document_Generation_Access__c && contactObj.Application_Status__c != PENDING_LEAGAL_REVIEW){
                contactObj.Automatic_Document_Generation_Access__c = GRANTED;
            }

        }

    }
    
    public static void checkToolsAccess(Contact contactObj, 
                                        Contact oldContactObj,
                                        Account accountObj){
        Boolean accridited = hasValidAccreditation(contactObj);
        Boolean cslb = hasValidCSLB(contactObj);
        Boolean validApplicationDate = hasValidApplicationSubmittedDate(contactObj);
        
        if((GRANTED == contactObj.Proposal_Tool_Access__c) 
            &&(oldContactObj == null || contactObj.Proposal_Tool_Access__c !=  oldContactObj.Proposal_Tool_Access__c)){
            if(accridited == false){
                contactObj.addError(NOT_ACCRIDITED_ERROR);
            }else if(cslb == false || validApplicationDate == false){
                contactObj.addError(NOT_CSLB_ERROR);
            }
        }else if((REQUESTED == contactObj.Proposal_Tool_Access__c) 
            &&(oldContactObj == null || contactObj.Proposal_Tool_Access__c !=  oldContactObj.Proposal_Tool_Access__c)){
            if(accridited == true && cslb == true && validApplicationDate == true && contactObj.active__c == true){
                contactObj.Proposal_Tool_Access__c = GRANTED;
            }
        }

        if((GRANTED == contactObj.Delegated_Admin_Access__c) 
            &&(oldContactObj == null || contactObj.Delegated_Admin_Access__c !=  oldContactObj.Delegated_Admin_Access__c)){
            if(accridited == false){
                contactObj.addError(NOT_ACCRIDITED_ERROR);
            }else if(cslb == false || validApplicationDate == false){
                contactObj.addError(NOT_CSLB_ERROR);
            }
        }else if((REQUESTED == contactObj.Delegated_Admin_Access__c) 
            &&(oldContactObj == null || contactObj.Delegated_Admin_Access__c !=  oldContactObj.Delegated_Admin_Access__c)){
            if(accridited == true && cslb == true && validApplicationDate == true && contactObj.active__c == true){
                contactObj.Delegated_Admin_Access__c = GRANTED;
            }
        }
        
  /*      if((GRANTED == contactObj.Partner_Portal_Access__c) 
            &&(oldContactObj == null || contactObj.Partner_Portal_Access__c !=  oldContactObj.Partner_Portal_Access__c)){
            if(accridited == false){
                contactObj.addError(NOT_ACCRIDITED_ERROR);
            }else if(cslb == false || validApplicationDate == false){
                contactObj.addError(NOT_CSLB_ERROR);
            }  
        }*/else if((REQUESTED == contactObj.Partner_Portal_Access__c) 
            &&(oldContactObj == null || contactObj.Partner_Portal_Access__c !=  oldContactObj.Partner_Portal_Access__c)){
            if(accridited == true && cslb == true && validApplicationDate == true && contactObj.active__c == true){
                contactObj.Partner_Portal_Access__c = GRANTED;
            }
        }
        
        if((GRANTED == contactObj.Design_Tool_Access__c) 
            &&(oldContactObj == null || contactObj.Design_Tool_Access__c !=  oldContactObj.Design_Tool_Access__c)){
            if(accridited == false){
                contactObj.addError(NOT_ACCRIDITED_ERROR);
            }else if(cslb == false || validApplicationDate == false){
                contactObj.addError(NOT_CSLB_ERROR);
            }
        } 
        /*
        else if((REQUESTED == contactObj.Design_Tool_Access__c) 
            &&(oldContactObj == null || contactObj.Design_Tool_Access__c !=  oldContactObj.Design_Tool_Access__c)){
            if(accridited == true && cslb == true){
                contactObj.Design_Tool_Access__c = GRANTED;
            }
        }
        */
        
        if((GRANTED == contactObj.Can_Run_Change_Orders__c) 
            &&(oldContactObj == null || contactObj.Can_Run_Change_Orders__c !=  oldContactObj.Can_Run_Change_Orders__c)){
            if(accridited == false){
                contactObj.addError(NOT_ACCRIDITED_ERROR);
            }else if(cslb == false || validApplicationDate == false){
                contactObj.addError(NOT_CSLB_ERROR);
            }
        }else if((REQUESTED == contactObj.Can_Run_Change_Orders__c) 
            &&(oldContactObj == null || contactObj.Can_Run_Change_Orders__c !=  oldContactObj.Can_Run_Change_Orders__c)){
            if(accridited == true && cslb == true && validApplicationDate == true && contactObj.active__c == true){
                contactObj.Can_Run_Change_Orders__c = GRANTED;
            }
        }
        
        if((GRANTED == contactObj.e_sign_documents_access__c) 
            &&(oldContactObj == null || contactObj.e_sign_documents_access__c !=  oldContactObj.e_sign_documents_access__c)){
            if(accridited == false){
                contactObj.addError(NOT_ACCRIDITED_ERROR);
            }else if(cslb == false || validApplicationDate == false){
                contactObj.addError(NOT_CSLB_ERROR);
            }
        }
        
        /*
        else if((REQUESTED == contactObj.e_sign_documents_access__c) 
            &&(oldContactObj == null || contactObj.e_sign_documents_access__c !=  oldContactObj.e_sign_documents_access__c)){
            if(accridited == true && cslb == true){
                contactObj.Can_Run_Change_Orders__c = GRANTED;
            }
        }
        */

        
    }
    
    public static Boolean hasValidAccreditation(Contact contactObj){
        Boolean accridited = false;
        if( NO == contactObj.Sells_Sunrun__c){
            accridited = true;
        }else if((ACCREDITED == contactObj.Accreditation_Status__c) 
                || (ACCREDITATION_PENDING == contactObj.Accreditation_Status__c)){
            accridited = true;
        }
        return accridited;                                              
    }
    
    public static Boolean hasValidCSLB(Contact contactObj){
        Boolean cslb = false;
        if( NO == contactObj.Sells_Sunrun__c){
            cslb = true;
        }else if( NO == contactObj.Sells_in_CA__c){
            cslb = true;
        }else if(APPROVED == contactObj.Application_Status__c){
            cslb = true;
        }else if((null != contactObj.Application_Status__c)
                && ('' != contactObj.Application_Status__c)
                && (REJECTED != contactObj.Application_Status__c)
                && (INCOMPLETE != contactObj.Application_Status__c)
                && (PENDING_LEAGAL_REVIEW != contactObj.Application_Status__c)
                && (NOT_RECEIVED != contactObj.Application_Status__c)){
            cslb = true;
        }
        return cslb;                                                
    }

    public static void performAccreditationProcess(Contact contactObj, 
                                                    Contact oldContactObj,
                                                    Account accountObj){
        Boolean solarUniverseAccount = false;
        if(accountObj.name == SOLAR_UNIVERSE){
            solarUniverseAccount = true;
        }
        System.debug('contactObj.Application_Status__c: ' + contactObj.Application_Status__c);
        if(contactObj.active__c != true){
            return;
        }
        System.debug('Proposal_Tool_Access__c: ' + contactObj.Proposal_Tool_Access__c);
        
        if((NO == contactObj.Sells_Sunrun__c) 
            || (YES == contactObj.Sells_Sunrun__c && NO == contactObj.Sells_in_CA__c )){
                
                if(NOT_RECEIVED == contactObj.Application_Status__c){
                    contactObj.Application_Status__c = NOT_APPLICABLE;
                }
                
                if(null == contactObj.Sales_Registration_Type__c 
                || '' == contactObj.Sales_Registration_Type__c){
                    contactObj.Sales_Registration_Type__c = NOT_NEEDED;
                }               
        }
        
        
        if(oldContactObj == null || (oldContactObj != null 
            && (contactObj.Sells_Sunrun__c != oldContactObj.Sells_Sunrun__c
            || contactObj.Sells_in_CA__c != oldContactObj.Sells_in_CA__c
            || contactObj.Accreditation_Status__c != oldContactObj.Accreditation_Status__c
            || contactObj.Application_Submitted__c != oldContactObj.Application_Submitted__c
            || contactObj.Application_Status__c != oldContactObj.Application_Status__c))){

            if((NO == contactObj.Sells_Sunrun__c)
               && (oldContactObj == null 
                || (contactObj.Sells_Sunrun__c != oldContactObj.Sells_Sunrun__c))){
                if(ACCREDITED != contactObj.Accreditation_Status__c){
                    contactObj.Accreditation_Status__c = NOT_A_SALES_PERSON;
                    contactObj.Accreditation_period_start_date__c = null;
                    contactObj.Accreditation_period_end_date__c = null;
                }
                if(contactObj.Application_Status__c != PRMContactUtil.APPROVED){
                     contactObj.Application_Status__c = PRMContactUtil.NOT_APPLICABLE;
                     contactObj.Sales_Registration_Type__c = PRMContactUtil.NOT_NEEDED;
                }
                grantToolsAccess(contactObj, solarUniverseAccount);
            }else if(YES == contactObj.Sells_Sunrun__c){
                
                if(contactObj.Accreditation_Status__c == null 
                || contactObj.Accreditation_Status__c == '' 
                || contactObj.Accreditation_Status__c == NOT_A_SALES_PERSON){
                    contactObj.Accreditation_Status__c = ACCREDITATION_PENDING;
                }
                
                if(ACCREDITATION_PENDING == contactObj.Accreditation_Status__c || 
                    ACCREDITED == contactObj.Accreditation_Status__c ){
                    if((NO == contactObj.Sells_in_CA__c) 
                        && (oldContactObj == null || oldContactObj.Sells_in_CA__c != contactObj.Sells_in_CA__c)) {
                        if(contactObj.Application_Status__c != PRMContactUtil.APPROVED){
                             contactObj.Application_Status__c = PRMContactUtil.NOT_APPLICABLE;
                             contactObj.Sales_Registration_Type__c = PRMContactUtil.NOT_NEEDED;
                        }                   
                        grantToolsAccess(contactObj, solarUniverseAccount);
                    }else if (((YES == contactObj.Sells_in_CA__c ) 
                                && (NOT_RECEIVED == contactObj.Application_Status__c
                                    || NOT_APPLICABLE == contactObj.Application_Status__c
                                    || INCOMPLETE == contactObj.Application_Status__c))
                                && (oldContactObj == null 
                                    || oldContactObj.Sells_in_CA__c != contactObj.Sells_in_CA__c)){
                                        
                        contactObj.Application_Status__c = NOT_RECEIVED;
                        if(contactObj.Sales_Registration_Type__c == NOT_NEEDED){
                            contactObj.Sales_Registration_Type__c = null;       
                        }
                        setToolsAccessToRequested(contactObj, solarUniverseAccount);
                    }else if (((YES == contactObj.Sells_in_CA__c ) 
                                && (RECEIVED == contactObj.Application_Status__c
                                    || APPROVED == contactObj.Application_Status__c
                                    || PENDING_LEAGAL_REVIEW == contactObj.Application_Status__c
                                    || SUBMITTED == contactObj.Application_Status__c
                                    || RESUBMITTED == contactObj.Application_Status__c))
                                && (oldContactObj == null 
                                    || oldContactObj.Sells_in_CA__c != contactObj.Sells_in_CA__c
                                    || oldContactObj.Application_Status__c != contactObj.Application_Status__c
                                    || oldContactObj.Application_Submitted__c != contactObj.Application_Submitted__c)){
                        
                        if(contactObj.Application_Received__c == null){
                            contactObj.Application_Received__c = date.today();
                        }
                        grantToolsAccess(contactObj, solarUniverseAccount); 
                        if(contactObj.Sales_Registration_Type__c == NOT_NEEDED){
                            contactObj.Sales_Registration_Type__c = null;       
                        }
                                
                    }
                }else if(( NOT_ACCREDITED == contactObj.Accreditation_Status__c)){
                        if((oldContactObj == null) 
                            || (contactObj.Sells_Sunrun__c != oldContactObj.Sells_Sunrun__c)
                            || (contactObj.Accreditation_Status__c != oldContactObj.Accreditation_Status__c)){
                        revokeSalesToolsAccess(contactObj);             
                    }
                }else if(( PENDING_LEAGAL_REVIEW == contactObj.Accreditation_Status__c)){
                    if((oldContactObj == null) 
                        || (contactObj.Sells_Sunrun__c != oldContactObj.Sells_Sunrun__c)
                        || (contactObj.Accreditation_Status__c != oldContactObj.Accreditation_Status__c)){
                        revokeSalesToolsAccess(contactObj);             
                    }
                }
                System.debug('contactObj.Sells_Sunrun__c-2' + contactObj);
                if(oldContactObj != null){
                    System.debug('oldContactObj1' + oldContactObj); 
                }
                //Following condition is applicable if the Contact.Sells_Sunrun__c
                //value changed from NO to YES
                if(oldContactObj != null 
                    && NO == oldContactObj.Sells_Sunrun__c 
                    && YES == contactObj.Sells_Sunrun__c){
                    
                    if(YES == contactObj.Sells_in_CA__c){                   
                        if(null == contactObj.Application_Status__c
                         || ('' == contactObj.Application_Status__c)
                         || (INCOMPLETE == contactObj.Application_Status__c)
                         || (NOT_RECEIVED == contactObj.Application_Status__c)
                         || (REJECTED == contactObj.Application_Status__c)){
                            setToolsAccessToRequested(contactObj, solarUniverseAccount);
                            contactObj.Application_Status__c = NOT_RECEIVED;
                        }else{
                            
                            grantToolsAccess(contactObj, solarUniverseAccount); 
                         }
                    }
                }else if(oldContactObj != null 
                    && NO == oldContactObj.Sells_in_CA__c 
                    && YES == contactObj.Sells_in_CA__c){       
                    if((INCOMPLETE == contactObj.Application_Status__c)
                     || (NOT_RECEIVED == contactObj.Application_Status__c)
                     || (REJECTED == contactObj.Application_Status__c)){
                        //System.debug('Line-2');
                        setToolsAccessToRequested(contactObj ,solarUniverseAccount);    
                    }
                }
                

                System.debug('contactObj.Application_Status__c2: ' + contactObj.Application_Status__c);
                if (((YES == contactObj.Sells_in_CA__c ) 
                    && (REJECTED == contactObj.Application_Status__c))
                        && (oldContactObj == null 
                            || oldContactObj.Sells_in_CA__c != contactObj.Sells_in_CA__c
                            || oldContactObj.Application_Status__c != contactObj.Application_Status__c)){
                    revokeToolsAccess(contactObj, solarUniverseAccount);    
                }else if (((YES == contactObj.Sells_in_CA__c ) 
                    && (PENDING_LEAGAL_REVIEW == contactObj.Application_Status__c))
                        && (oldContactObj == null 
                            || oldContactObj.Sells_in_CA__c != contactObj.Sells_in_CA__c
                            || oldContactObj.Application_Status__c != contactObj.Application_Status__c)){
                    revokeToolsAccessOnlyIfGranted(contactObj); 
                }else if (((YES == contactObj.Sells_in_CA__c ) 
                            && (SUBMITTED == contactObj.Application_Status__c))
                            && (oldContactObj == null 
                                || oldContactObj.Sells_in_CA__c != contactObj.Sells_in_CA__c
                                || oldContactObj.Application_Status__c != contactObj.Application_Status__c)){
                    
                    if(contactObj.Application_Submitted__c == null){
                        contactObj.Application_Submitted__c = date.today();
                    }
                }else if (((YES == contactObj.Sells_in_CA__c ) 
                            && (RECEIVED == contactObj.Application_Status__c))
                            && (oldContactObj == null 
                                || oldContactObj.Sells_in_CA__c != contactObj.Sells_in_CA__c
                                || oldContactObj.Application_Status__c != contactObj.Application_Status__c)){
                    if(contactObj.Application_Received__c == null){
                        contactObj.Application_Received__c = date.today();
                    }
                }if ((YES == contactObj.Sells_in_CA__c ) 
                        && (NOT_RECEIVED == contactObj.Application_Status__c
                            || INCOMPLETE == contactObj.Application_Status__c)
                        && (oldContactObj == null 
                            || oldContactObj.Application_Status__c != contactObj.Application_Status__c)){
                    if(contactObj.Application_Status__c == NOT_RECEIVED){
                        contactObj.Application_Received__c = null;
                        contactObj.Application_Submitted__c = null;
                    }
                    if(contactObj.Sales_Registration_Type__c == NOT_NEEDED){
                        contactObj.Sales_Registration_Type__c = null;       
                    }
                    setToolsAccessToRequested(contactObj, solarUniverseAccount);
                }
                
            }
        }
        System.debug('Proposal_Tool_Access__c: ' + contactObj.Proposal_Tool_Access__c);
    }

    public static Id checkPartnerPortalAccess(Contact contactObj, Contact oldContact){

        if(oldContact == null && contactObj != null 
            && contactObj.active__c == true && (PRMContactUtil.GRANTED == contactObj.Partner_Portal_Access__c)){
            return contactObj.id;
        }else if(oldContact != null && contactObj != null){
            if((PRMContactUtil.GRANTED == contactObj.Partner_Portal_Access__c)
               && (contactObj.Partner_Portal_Access__c != oldContact.Partner_Portal_Access__c)){
                return contactObj.id;
            }else if((PRMContactUtil.GRANTED == contactObj.Partner_Portal_Access__c)
               && (contactObj.role__c != oldContact.role__c)){
                return contactObj.id;
            }/*else if((PRMContactUtil.GRANTED == contactObj.Partner_Portal_Access__c) 
               && (contactObj.Delegated_Admin_Access__c != oldContact.Delegated_Admin_Access__c)){
               return contactObj.id;
            }*/else if((PRMContactUtil.GRANTED == contactObj.Partner_Portal_Access__c)
               && (contactObj.Sells_Sunrun__c != oldContact.Sells_Sunrun__c)){  //Removed the Partner Portal Access
                return contactObj.id;
            }else if((PRMContactUtil.GRANTED == oldContact.Partner_Portal_Access__c)
               && (contactObj.Partner_Portal_Access__c != oldContact.Partner_Portal_Access__c)){  //Removed the Partner Portal Access
                return contactObj.id;
            }else if((contactObj.active__c == false)
               && (contactObj.active__c != oldContact.active__c)){  //Removed the Partner Portal Access
                //contactObj.Partner_Portal_Access__c = REVOKED;
                return contactObj.id;
            }else if((PRMContactUtil.GRANTED == contactObj.Partner_Portal_Access__c)
               && (contactObj.Profile__c != oldContact.Profile__c)){
                return contactObj.id;
            }
        }
        return null;
    }

    @future
    public static void revokePartnerPortalAccess(Set<Id> contactIds){
        System.debug('contactIds: ' + contactIds);
        
        Savepoint contactSavePoint;     
        try{
            Map<Id, User> existingContactUsermap = getExistingPortalUsers(contactIds);
            String requestedAction = '';
            User userObj;
            List<User> revokedUsers = new List<User>();
            List<User> updatedUsers = new List<User>();
            for(Contact contactobj : [Select Id, Ultimate_Parent_Account__c, timeZoneSidKey__c, 
                                        Title,
                                        Delegated_Admin_Access__c, Partner_Portal_Access__c, 
                                        Sells_Sunrun__c, Sells_in_CA__c, active__c,
                                        firstname, lastname, email, role__C,Location__c,Profile__c from Contact
                                        where Id in :contactIds]){
                if(GRANTED != contactobj.Partner_Portal_Access__c){
                    if(existingContactUsermap.containskey(contactobj.Id)){
                        userObj = existingContactUsermap.get(contactobj.Id);
                        if(userObj != null){
                            userObj.IsActive = false;
                            revokedUsers.add(userObj);
                        }
                        
                    }
                }
            }
            if(revokedUsers.size() > 0 ){
                contactSavePoint = Database.setSavepoint();
                List<Database.Saveresult> updateResult = Database.update(revokedUsers); 
            }
        
        }catch(DmlException ex){
            System.debug('Exception1: ' + ex);  
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable revoke Partner Website access. Please contact Salesforce Administrator.'));
            if(contactSavePoint != null)
                Database.rollback(contactSavePoint);    
            return;
        }
        catch(Exception ex){
            System.debug('Exception2: ' + ex);
            ApexPages.addMessages(ex);
            if(contactSavePoint != null)
                Database.rollback(contactSavePoint);    
           return;
        }   
                    
    }


    @future
    public static void managePortalUsers(Set<Id> contactIds){
        System.debug('contactIds: ' + contactIds);
        Map<Id, Contact> createPortalUserMap = new Map<Id, Contact>();
        Map<Id, Contact> updatePortalUserMap = new Map<Id, Contact>();
        Map<Id, Contact> revokePortalUserMap = new Map<Id, Contact>();
        
        Map<Id, User> existingContactUsermap = getExistingPortalUsers(contactIds);
        String requestedAction = '';
        User userObj;
        List<User> revokedUsers = new List<User>();
        List<User> updatedUsers = new List<User>();
        for(Contact contactobj : [Select Id, Ultimate_Parent_Account__c, timeZoneSidKey__c, 
                                    Title,accountId, name,
                                    Delegated_Admin_Access__c, Partner_Portal_Access__c, 
                                    Sells_Sunrun__c, Sells_in_CA__c, active__c,
                                    firstname, lastname, email, role__C,Location__c,Profile__c from Contact
                                    where Id in :contactIds]){
            if(GRANTED == contactobj.Partner_Portal_Access__c){
                if(existingContactUsermap.containskey(contactobj.Id)){
                    updatePortalUserMap.put(contactobj.Id, contactobj);
                    if(existingContactUsermap.containskey(contactobj.Id)){
                        userObj = existingContactUsermap.get(contactobj.Id);
                        if(userObj != null){
                            userObj.IsActive = false;
                            updatedUsers.add(userObj);
                        }                       
                    }
                }else{
                    createPortalUserMap.put(contactobj.Id, contactobj);
                }
            }
        }
            
        
        if(createPortalUserMap.size() > 0 ){
            createPartnerPortalUsers(createPortalUserMap);
        }   

        if(updatePortalUserMap.size() > 0 ){
            updatePartnerPortalUsers(updatePortalUserMap, updatedUsers);
        }

        if(revokedUsers.size() > 0 ){
            List<Database.Saveresult> updateResult = Database.update(revokedUsers); 
        }           
    }

    public static void updatePartnerPortalUsers(Map<Id, Contact> contactMap, List<User> updatedUsers){

        Set<Id> ultimateParentAccountIds = new Set<Id>();
        Set<Id> contactAccountIds = new Set<Id>();
        Map<Id, Id> contactUltimateAccountMap = new Map<Id, Id>();
        Map<Id, Account> ultimateParentAccounts = new Map<Id, Account>();
        for(Contact contactObj : contactMap.values()){
            if(contactObj.Ultimate_Parent_Account__c != null){
                ultimateParentAccountIds.add(contactObj.Ultimate_Parent_Account__c);
                contactUltimateAccountMap.put(contactObj.Id, contactObj.Ultimate_Parent_Account__c);
            }
            if(contactObj.accountId != null){
                contactAccountIds.add(contactObj.accountId);
            }
        }
        
        for(Account accountObj : [Select Id, Account_Manager__c, name, Account_Type__c,
                                    Partner_Type__c, Active__c, parentId,isPartner from Account 
                                    where Id in :ultimateParentAccountIds]){
            ultimateParentAccounts.put(accountObj.Id, accountObj);
        }
        Map<Id, Map<String, UserRole>> partnerRoleMap = PRMContactUtil.getUserRoles(ultimateParentAccountIds);
        //Map<Id, Map<String, UserRole>> partnerRoleMap = PRMContactUtil.getUserRoles(contactAccountIds);
        Account accountObj; 
        Contact contactObj;
        for(User userObj : updatedUsers){
            contactObj = contactMap.get(userObj.contactId);
            accountObj = ultimateParentAccounts.get(contactObj.Ultimate_Parent_Account__c);
            userObj.IsActive = true;
            userObj.FirstName =  contactObj.FirstName;
            userObj.LastName = contactObj.LastName;
            userObj.Email = contactObj.email;
            //userObj.contactId = '02ZR00000001YF4MAM';
            userObj.TimeZoneSidKey = contactObj.timeZoneSidKey__c;
            Id profileId = getProfileId(accountObj,contactObj);
            if(profileId == null){
                System.debug('Invalid profile Id: ' + profileId);
            }
            userObj.ProfileId = profileId;
            
            //Update Role Information ... 
            //Map<String, UserRole> partnerRoles = partnerRoleMap.get(contactObj.accountId);
            System.debug('contactObj.Ultimate_Parent_Account__c: ' + contactObj.Ultimate_Parent_Account__c);
            Map<String, UserRole> partnerRoles = partnerRoleMap.get(contactObj.Ultimate_Parent_Account__c);
            System.debug('partnerRoles: ' + partnerRoles);
            String contactRoleName = '';
            if(contactObj.role__c == INDIVIDUAL_CONTRIBUTOR 
                || contactObj.role__C == null
                || contactObj.role__C == '' ){
                contactRoleName = 'User';
            }else{
                contactRoleName = contactObj.role__c;
            }
            System.debug('contactRoleName: '  +contactRoleName);
            if(partnerRoles != null){
                UserRole roleObj = partnerRoles.get(contactRoleName);
                if(roleObj != null && roleObj.Id != null){
                    userobj.UserRoleId = roleObj.Id;
                }                   
            }
            System.debug('userobj.UserRoleId: ' + userobj.UserRoleId);
        }
        if(updatedUsers.size() > 0 ){
            update updatedUsers;
        }
    }

    public static void createPartnerPortalUsers(Map<Id, Contact> contactMap){
        Set<Id> ultimateParentAccountIds = new Set<Id>();
        Set<Id> contactAccountIds = new Set<Id>();
        Map<Id, Id> contactUltimateAccountMap = new Map<Id, Id>();
        Map<Id, Account> ultimateParentAccounts = new Map<Id, Account>();
        for(Contact contactObj : contactMap.values()){
            if(contactObj.Ultimate_Parent_Account__c != null){
                ultimateParentAccountIds.add(contactObj.Ultimate_Parent_Account__c);
                contactUltimateAccountMap.put(contactObj.Id, contactObj.Ultimate_Parent_Account__c);
            }
            if(contactObj.accountId != null){
                contactAccountIds.add(contactObj.accountId);
            }
        }
        
        for(Account accountObj : [Select Id, Account_Manager__c, name, Account_Type__c,
                                    Partner_Type__c, Active__c, parentId,isPartner from Account 
                                    where Id in :ultimateParentAccountIds]){
            ultimateParentAccounts.put(accountObj.Id, accountObj);
        }
        
        //Map<Id, Map<String, UserRole>> partnerRoleMap = PRMContactUtil.getUserRoles(ultimateParentAccountIds);
        Map<Id, Map<String, UserRole>> partnerRoleMap = PRMContactUtil.getUserRoles(contactAccountIds);
        List<User> portalUsers = new List<User>();
        //Savepoint contactSavePoint;       
        try{
            //contactSavePoint = Database.setSavepoint();
            Id tempContactId;
            for(Contact contactObj : contactMap.values()){
                if(contactObj.Ultimate_Parent_Account__c == null){
                    continue;
                }
                
                Account accountObj = ultimateParentAccounts.get(contactObj.Ultimate_Parent_Account__c);
                String companyName = accountObj.name;                                           
                User upsertUser = new User();
                upsertUser.TimeZoneSidKey = contactObj.timeZoneSidKey__c;
                upsertUser.EmailEncodingKey = 'ISO-8859-1';
                upsertUser.LocaleSidkey = 'en_US';
                upsertUser.LanguageLocaleKey = 'en_US'; 
                upsertUser.ContactId =  contactObj.Id;
                tempContactId = contactObj.Id;
                System.debug('tempContactId: ' + tempContactId);
                //upsertUser.contactId = '02ZR00000001YF4MAM';
                                
                String tempFirstName = contactObj.firstname;
                String tempLastName = contactObj.lastname;              
                
                upsertUser.FirstName = contactObj.firstname;
                upsertUser.LastName = contactObj.lastname;
                upsertUser.Email = contactObj.email;
                upsertUser.title = contactObj.title;
                String tempUserName = contactObj.Email + '.sr';
                upsertUser.Username = tempUserName;
                String tempAlias = null;
                String tempNickName = null;
                if(tempAlias == null || tempAlias == ''){
                    String lastAlias = (tempLastName.length() > 2) ? tempLastName.substring(0,2) : tempLastName;
                    String firstAlias = (tempFirstName.length() > 2) ? tempFirstName.substring(0,2) : tempFirstName;
                    tempAlias = getUniqueAlias(firstAlias + lastAlias);
                }
                upsertUser.Alias = tempAlias;
                
                if(tempNickName == null || tempNickName == ''){
                    String lastNickName = (tempLastName.length() > 4) ? tempLastName.substring(0,4) : tempLastName;
                    String firstNickName = (tempFirstName.length() > 4) ? tempFirstName.substring(0,4) : tempFirstName;
                    tempNickName = getUniqueNickname(firstNickName + lastNickName);
                }
                upsertUser.CommunityNickname = tempNickName;
                upsertUser.companyName = companyName;
                String errorMessage = validateAccount(accountObj);              
                if(errorMessage != null && errorMessage != ''){
                    User accountManagerObj;
                    if(accountObj.Account_Manager__c != null){
                        accountManagerObj = PRMContactUtil.getUser(accountObj.Account_Manager__c );
                    }
                    PRMEmailManager.communicateErrorDetails(accountObj, contactObj,accountManagerObj,errorMessage);
                }
                upsertUser.ProfileId = getProfileId(accountObj,contactObj);

                //Update Role Information ... 
                //Map<String, UserRole> partnerRoles = partnerRoleMap.get(contactObj.Ultimate_Parent_Account__c);
                Map<String, UserRole> partnerRoles = partnerRoleMap.get(contactObj.accountId);
                System.debug('contactObj.accountId: ' + contactObj.accountId);
                //Map<String, UserRole> partnerRoles = partnerRoleMap.get(contactObj.accountId);
                System.debug('partnerRoles: ' + partnerRoles);
                String contactRoleName = '';
                if(contactObj.role__c == INDIVIDUAL_CONTRIBUTOR 
                    || contactObj.role__C == null
                    || contactObj.role__C == '' ){
                    contactRoleName = 'User';
                }else{
                    contactRoleName = contactObj.role__c;
                }
                
                if(partnerRoles != null){
                    UserRole roleObj = partnerRoles.get(contactRoleName);
                    if(roleObj != null && roleObj.Id != null){
                        //upsertUser.UserRoleId = roleObj.ParentRoleId;
                        upsertUser.UserRoleId = roleObj.Id;
                    }                   
                }
                System.debug('upsertUser.UserRoleId: ' + upsertUser.UserRoleId);
                portalUsers.add(upsertUser);                
            }
            
            Database.DMLOptions dlo = new Database.DMLOptions();
            dlo.EmailHeader.triggerUserEmail = true;            
            
            System.debug('portalUsers: ' + portalUsers);
            List<Database.Saveresult> upsertUserResults = Database.insert(portalUsers, dlo);    
            Integer counter = 0;
            for(Database.Saveresult upsertUserResult : upsertUserResults){

                Id contactId = portalUsers[counter].ContactId;
                System.debug('contactId: ' + contactId);
                System.debug('contactUltimateAccountMap: ' + contactUltimateAccountMap);
                Contact contactObj = contactMap.get(contactId);
                Id ultimateParentAccountId = contactUltimateAccountMap.get(contactId);
                Account accountObj = ultimateParentAccounts.get(ultimateParentAccountId);
                System.debug('accountObj: ' + accountObj);  
                User accountManagerObj;
                System.debug('Account_Manager__c: ' + accountObj.Account_Manager__c);   
                if(accountObj.Account_Manager__c != null){
                    accountManagerObj = PRMContactUtil.getUser(accountObj.Account_Manager__c );
                }
                User tempUser = portalUsers[counter];               
                if(!upsertUserResult.isSuccess()){

                    String errorMessage = validateDatabaseOperation(upsertUserResult);      
                    System.debug('errorMessage: ' +errorMessage);   
                    System.debug('accountManagerObj: ' +accountManagerObj);         
                    if(errorMessage != null && errorMessage != '' && accountManagerObj != null){
                        Id newUserId = upsertUserResult.getId();
                        PRMEmailManager.communicateErrorDetails(accountObj, contactObj,accountManagerObj,errorMessage);
                    }
                }
                //else{
                //  PRMEmailManager.communicateNewUserDetails(tempUser,accountManagerObj, 
                //                                              portalUsers[0].companyName, 
                //                                              true, null);
                //}
                counter++;          
            }
            return;     
            
        }catch(DmlException ex){
            System.debug('Exception1: ' + ex);
            //ApexPages.addMessages(ex);
            //if(contactSavePoint != null)
            //  Database.rollback(contactSavePoint);    
            return;
        }
        catch(Exception ex){
            System.debug('Exception2: ' + ex);
           // ApexPages.addMessages(ex);
            //if(contactSavePoint != null)
            //  Database.rollback(contactSavePoint);    
           return;
        }
    }

    public static Map<Id, String> getPartnerSites(Id parentAccountId){
        Map<Id, String> accountSiteMap = new Map<Id, String>();
        Set<Id> parentAccountIds = new Set<Id>();
        parentAccountIds.add(parentAccountId);
        while(parentAccountIds.size() > 0){
            Set<Id> tempParentAccountIds = new Set<Id> ();
            for(Account accountObj: [Select Id, name, accountnumber, Site, ParentId,
                                    Partner_Status__c, OwnerId
                                    from Account where ParentId in :parentAccountIds]){
                tempParentAccountIds.add(accountObj.Id);
                if(accountObj.site != null && accountObj.site != ''){
                    accountSiteMap.put(accountObj.Id, accountObj.site);
                }
            }
            parentAccountIds = tempParentAccountIds;
        }

        return accountSiteMap;
    } 
    

    /*
        
    public static void testPortal(){
            Map<Id, Contact> contactMap = new Map<Id, Contact>();
            Set<Id> contactIds = new Set<Id>();
            contactIds.add('003R000000fOXzo');
            List<Contact> contacts;
            contacts = PRMContactUtil.getContacts(contactIds);
            Contact contactObj;
            if(contacts.size() > 0 ){
                contactObj = contacts[0];
            }           
            contactMap.put(contactObj.Id, contactObj);
            System.debug('contactMap: ' + contactMap);
            PRMContactUtil.createPartnerPortalUsers(contactMap);
    }
    
    public static void testEmail(){
        Account accountObj = [Select Id, name , Account_Manager__c from Account where Id = '001R000000jQuRX'];
        Contact contactObj = [Select Id, name , email,Ultimate_Parent_Account__c from Contact where Id = '003R000000fOXzo'];
        User accountManagerObj = PRMContactUtil.getUser(accountObj.Account_Manager__c );
        //User tempUser = PRMContactUtil.getUser('005R0000000tG7Z');
        String errorMessage = 'Test message ... ';
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        contactMap.put(contactObj.Id, contactObj);
        createPartnerPortalUsers(contactMap);
        //PRMEmailManager.communicateErrorDetails(accountObj, contactObj,accountManagerObj,errorMessage);
    }
    */
    /*
    public static Contact getLoginUserAccountAndContact(Date partnerGoLiveDate, Date salesRepGoLiveDate){
        Contact loginUserContact = getLoginUserAccountAndContact();
        if(loginUserContact != null && loginUserContact.EDP_Go_Live_Date__c != null){
            salesRepGoLiveDate = loginUserContact.EDP_Go_Live_Date__c ;
        }
        if(loginUserContact.Account != null && loginUserContact.Account.EDP_Go_Live_Date__c != null){
            partnerGoLiveDate = loginUserContact.Account.EDP_Go_Live_Date__c ;
        }
        System.debug('tempContactObj: ' + loginUserContact);
        System.debug('tempContactObj.Account.EDP_Go_Live_Date__c: ' + partnerGoLiveDate);
        return loginUserContact;
    }
    */
    public static Contact getLoginUserAccountAndContact(){
        User userObj = PRMContactUtil.getLoginUser();
        system.debug('userObj---->'+userObj);
        
        Contact tempContactObj;
        if(userObj != null){
            system.debug('Entering 2---->');
            if(userObj.ContactId != null){
                system.debug('Entering 3---->');
                tempContactObj = [Select Id, Name, RecordTypeId, EMAIL,As_Built__c, PHONE, Division__c, EDP_Go_Live_Date__c, Sunrun_User__c, Ultimate_Parent_Account__c, Ultimate_Parent_Account__r.name, Department__c,
											Preferred_Language__c, Contact_Number__c, Sales_Registration_Number__c,
                                            account.DocuSign_Host_Email__c, account.DocuSign_Host_Name__c,Modify_Proposal__c,Manual_Design__c,ePermitting__c,eAudit__c,Managing_Partner_AVL_Costs__c,Managing_Partner_AVL_Prices__c,
                                            Account.Id, Account.EDP_Go_Live_Date__c, Account.partner_type__c,Location__c,Profile__c,Design_New_Proposal__c,Pricing_Only__c,Business_Division_Description__c   
                                            from Contact where Id =:userObj.ContactId and Ultimate_Parent_Account__c != null and Ultimate_Parent_Account__c != ''];               
            }else{
            
                List<Contact> contactList = [Select Id, RecordTypeId, Name, EMAIL, Division__c, PHONE, EDP_Go_Live_Date__c, Sunrun_User__c, Ultimate_Parent_Account__c, Ultimate_Parent_Account__r.name, Account.Id, Department__c,
                                            Preferred_Language__c, Contact_Number__c, Sales_Registration_Number__c,
                                            account.DocuSign_Host_Email__c, account.DocuSign_Host_Name__c,As_Built__c,Modify_Proposal__c,Manual_Design__c,Managing_Partner_AVL_Costs__c,Managing_Partner_AVL_Prices__c,
                                            Account.EDP_Go_Live_Date__c, Account.partner_type__c,Location__c,Profile__c,ePermitting__c,eAudit__c,Design_New_Proposal__c,Pricing_Only__c,Business_Division_Description__c   
                                            from Contact where  Sunrun_User__c =:userObj.Id and Ultimate_Parent_Account__c != null and Ultimate_Parent_Account__c != ''];
                if(contactList != null && !contactList.isEmpty()){
                    tempContactObj = contactList[0];
                }
            }
        }
        return tempContactObj;  
    }
    
    public static Boolean isPartnerContact(Contact contactObj){
        Boolean result = false;
        if(contactObj != null && contactObj.Id != null){
            RecordType empRecordTypeObj = PRMLibrary.getEmployeeContactRecordType();
            RecordType partnerRecordTypeObj = PRMLibrary.getPartnerContactRecordType();
            if(((empRecordTypeObj != null && contactObj.RecordTypeId == empRecordTypeObj.Id) 
                || (partnerRecordTypeObj != null && contactObj.RecordTypeId == partnerRecordTypeObj.Id)) 
                && (contactObj.Sunrun_User__c == null || (contactObj.Sunrun_User__c != null 
                && (contactObj.Division__c == 'Field Sales' || contactObj.Division__c == 'Inside Sales')))){
                result = true;
            }
        }
        return result;
    }
    

}