/****************************************************************************
Author  : Raghu Masineni (rmasineni@sunrunhome.com)
Date    : April 2012

Description: This class contains all the generic methods

*****************************************************************************/
public class PRMLibrary {

    public final static String PARTNER = 'Partner';
    public final static String SUNRUN = 'Sunrun Internal';
    public final static String EMPLOYEE = 'Employee';
    public final static String CUSTOMER = 'Customer';
    public final static String COMPANY = 'Company';
    public static boolean contactsUpdated = false;
    
    public static Map<String, List<Contact>> getExistingContactsByEmail(List<String> contactEmails){
        Map<String, List<Contact>> existingContacts = new Map<String, List<Contact>>();
        Set<String> existingEmails = new Set<String>();
        List<Contact> contacts = null;
        for(Contact contactObj: [Select Id, firstname, lastname, email, account.Account_Type__c from 
                                    Contact where email in :contactEmails]){
        
            contacts = existingContacts.containskey(contactObj.email) ? 
                            existingContacts.get(contactObj.email) : new List<Contact>();
            contacts.add(contactObj);
            existingContacts.put(contactObj.email, contacts);
        }
        return existingContacts;
    }   
    
    public static List<String> getUniqueAcountNumbers(Integer size){
        List<String> generatedAccountNumbers = new List<String>();
        List<Account> accountList = new List<Account>();        
        do{
            for(Integer counter = 0; counter < size;  counter++){
                generatedAccountNumbers.add(RandomNumberGenerator.generateRandomNumber());
            }
            if(!Test.isRunningTest()){
            	accountList = [Select Id from Account where account_number__c in :generatedAccountNumbers];
            }
            
        }while(accountList != null && accountList.size() > 0);
        return generatedAccountNumbers;     
    }

    public static List<String> getUniqueContactNumbers(Integer size){
        List<String> generatedContactNumbers = new List<String>();
        List<Contact> contactList = new List<Contact>();        
        do{
            for(Integer counter = 0; counter < size;  counter++){
                generatedContactNumbers.add(RandomNumberGenerator.generateRandomNumber());
            }
            if(!Test.isRunningTest()){
				contactList = [Select Id from Contact where contact_number__c in :generatedContactNumbers];
            }
            
        }while(contactList != null && contactList.size() > 0);
        return generatedContactNumbers;     
    }

    public static List<String> getUniqueContractNumbers(Integer size){
        List<String> generatedContractNumbers = new List<String>();
        List<Partner_Contract__c> contractList = new List<Partner_Contract__c>();       
        do{
            for(Integer counter = 0; counter < size;  counter++){
                generatedContractNumbers.add(RandomNumberGenerator.generateRandomNumber());
            }
            contractList = [Select Id from Partner_Contract__c where 
                                contract_number__c in :generatedContractNumbers];
        }while(contractList != null && contractList.size() > 0);
        return generatedContractNumbers;        
    }

    static Map<Id, RecordType> contactRecordTypeMap;
    public static Map<Id, RecordType> getContactRecordTypes(){
        if(contactRecordTypeMap == null || contactRecordTypeMap.size() ==0){
            contactRecordTypeMap = new Map<Id, RecordType>();
            accountRecordTypeMap = new Map<Id, RecordType>();
            for(RecordType recordTypeoBJ : [select Id, Name, SobjectType from RecordType 
                                            where (SObjectType = 'Contact' OR SObjectType = 'Account' )]){
                if(recordTypeoBJ.SObjectType == 'Contact'){
                	contactRecordTypeMap.put(recordTypeoBJ.Id, recordTypeoBJ);
                }else if(recordTypeoBJ.SObjectType == 'Account'){
					accountRecordTypeMap.put(recordTypeoBJ.Id, recordTypeoBJ);
                }                 
            }
        }
        return contactRecordTypeMap;
    }   
    
    public static Map<Id, RecordType> accountRecordTypeMap;
    public static Map<Id, RecordType> getAccountRecordTypes(){
        
        if(accountRecordTypeMap == null){
            accountRecordTypeMap = new Map<Id, RecordType>();
            contactRecordTypeMap = new Map<Id, RecordType>();
            for(RecordType recordTypeoBJ : [select Id, Name, SobjectType from RecordType 
                                            where (SObjectType = 'Contact' OR SObjectType = 'Account' )]){
                if(recordTypeoBJ.SObjectType == 'Contact'){
                	contactRecordTypeMap.put(recordTypeoBJ.Id, recordTypeoBJ);
                }else if(recordTypeoBJ.SObjectType == 'Account'){
					accountRecordTypeMap.put(recordTypeoBJ.Id, recordTypeoBJ);
                }                      
            }
        }
        return accountRecordTypeMap;
    }

    public static Map<Id, Account> staticAccountMap = new Map<Id, Account>();
    public static Map<Id, Account> getAccounts(Set<Id> accountIds){
        Map<Id, Account> accountMap = new Map<Id, Account>();
        Set<Id> tempAccountIds = new Set<Id>();
        for(Id accountId : accountIds){
            if(staticAccountMap.containsKey(accountId)){
                Account tempAccountObj = staticAccountMap.get(accountId);
                accountMap.put(accountId, tempAccountObj);
            }else{
                tempAccountIds.add(accountId);
            }
        }
		if(!tempAccountIds.isEmpty()){
            for(Account accountObj : [select Id, parentId,Account_Manager__c,Stage__c,
                                         Active__c, account_type__c,validdomains__c,
                                         isPartner, Name from Account 
                                         where Id in :tempAccountIds ]){
                accountMap.put(accountObj.Id, accountObj);
                staticAccountMap.put(accountObj.Id, accountObj);                        
            }
        }
        return accountMap;
    }
    

    public static void updateContacts(Set<Id> accountIds, Boolean active){
        Map<Id, Contact> contactsWithNoRoles = new Map<Id, Contact>();
        Map<Id, Contact> contactsWithRoles = new Map<Id, Contact>();
        Map<Id, Account> contactRoleAccountMap = new Map<Id, Account>();
        List<Contact> contactsForUpdate = new List<Contact>();
        Set<Id> contactRoleAcctIds = new Set<Id>();
        List<Account> activeChildAccounts = new List<Account>();
        System.debug('Account Id: ' + accountIds);
        for( Account accountObj: [Select Id, name, parentId, Active__c,Deactivation_Reason__c
                                        from Account 
                                        where parentId in :accountIds 
                                        and Active__c != :active]){
            if(active == false){
                accountObj.Active__c = false;
                accountObj.Deactivation_Reason__c = 'Parent Deactivated';
                activeChildAccounts.add(accountObj);
                accountIds.add(accountObj.Id);  
            }else {
                if(accountObj.Deactivation_Reason__c != null && 
                    (accountObj.Deactivation_Reason__c == 'Parent Deactivated')){   
                    accountObj.Active__c = true;
                    accountObj.Deactivation_Reason__c = '';                 
                    activeChildAccounts.add(accountObj);
                    accountIds.add(accountObj.Id);                      
                }
            }
                                            
        }
        
        if(activeChildAccounts.size() > 0){
            //System.debug('Deactivate child accounts: ' + activeChildAccounts);
            update activeChildAccounts;
        }
        
        for(Contact contactObj : [Select Id,accountId, name,
                                    active__c, Deactivation_Reason__c,
                                    (select Id, AccountId, ContactId from AccountContactRoles)  
                                    from Contact where accountId in :accountIds AND active__c != :active]){
            if(contactObj.AccountContactRoles == null || 
                contactObj.AccountContactRoles.size() == 0){
                contactsWithNoRoles.put(contactObj.Id, contactObj);
            }else{
                contactsWithRoles.put(contactObj.Id, contactObj);
                for(AccountContactRole acctContactRole :contactObj.AccountContactRoles){
                    contactRoleAcctIds.add(acctContactRole.AccountId);
                }
            }
        }
        
        for(Account accountObj : [Select Id, Active__c from Account where Id in :contactRoleAcctIds]){
            contactRoleAccountMap.put(accountObj.Id, accountObj);
        }
        
        //If the contact is associated with more than one account and if any of those 
        //accounts are active then don't deactivate the contact
        Boolean eligibleForUpdate = false;
        for(Contact contactObj : contactsWithRoles.values()){
            eligibleForUpdate = active ? false : true;
            for(AccountContactRole acctContactRole :contactObj.AccountContactRoles){
                Account accountObj = contactRoleAccountMap.get(acctContactRole.accountId);
                if(active == false){
                    if(!accountIds.contains(accountObj.Id) && accountObj.Active__c == true){
                        eligibleForUpdate = false;
                        break;
                    }
                }else{
                    if(!accountIds.contains(accountObj.Id) && accountObj.Active__c == true){
                        eligibleForUpdate = true;
                        break;
                    }                   
                }
            }
            
            if(eligibleForUpdate){
                contactsForUpdate.add(contactObj);
            }
        }
        contactsForUpdate.addall(contactsWithNoRoles.values());
        System.debug('contactsWithNoRoles: ' + contactsWithNoRoles);
        List<Contact> modifiedContacts = new List<Contact>();
        Set<Id> deactivatedContactIds = new Set<Id>();
        for(Contact contactObj : contactsForUpdate){
            if(contactObj.active__c == active)
                continue;
            if(active == false){    
                deactivatedContactIds.add(contactObj.Id);
                contactObj.active__c = false;
                contactObj.Deactivation_Reason__c = 'Account Deactivated';
                modifiedContacts.add(contactObj);
            }else if(active == true){
                if((contactObj.active__C == null ||contactObj.active__C == false) && 
                    (contactObj.Deactivation_Reason__c != null && 
                    contactObj.Deactivation_Reason__c == 'Account Deactivated')){
                    deactivatedContactIds.add(contactObj.Id);
                    contactObj.active__c = true;
                    contactObj.Deactivation_Reason__c = '';
                    modifiedContacts.add(contactObj);       
                }           
            }
            
        }
        
        if(modifiedContacts.size() > 0){
            update modifiedContacts;
            PRMLibrary.updatePortalUsers(deactivatedContactIds, active);
        }
        System.debug('Updated contacts ....');
    }
    
    public static void updatePortalUsers(Set<Id> contactIds, Boolean active){
        
        if(Test.isRunningTest())
            return;
            
        updatePortalUsers_Future(contactIds, active);
    }

    @future
    public static void updatePortalUsers_Future(Set<Id> contactIds, Boolean active){    
        System.debug('Contact Ids: ' + contactIds);
        List<User> modifiedUsers = new List<User>();
        if(contactIds == null || contactIds.size() ==0)
            return;

        for(User userObj : [Select Id, IsActive, IsPortalEnabled, contactId from User 
                            where contactId in : contactIds]){
            userObj.IsActive = active;
            //userObj.IsPortalEnabled = false;
            //userObj.contactId = null;
            modifiedUsers.add(userObj);         
        }
        
        List<Database.Saveresult> updateUserResults = Database.update(modifiedUsers, false);
        for(Database.Saveresult resultObj: updateUserResults){
            if(!resultObj.isSuccess()){
                System.debug('Save error: ' + resultObj.getErrors());
            }               
        }
    }

    
    public static void updatePartnerContacts(Set<Id> contactIds, Set<Id> netExamContactIds){
        if(Test.isRunningTest())
                return;
        updatePartnerContacts_Future(contactIds, netExamContactIds);
    }
    
    @future
    public static void updatePartnerContacts_Future(Set<Id> contactIds, Set<Id> netExamContactIds){
        Boolean isTesting = Test.isRunningTest();
        //System.debug('userEmailMap: ' + userEmailMap);
        System.debug('contactIds: ' + contactIds);
        if(netExamContactIds != null){
            LMSInfoManager.processedContactIds = netExamContactIds;
        }
        Map<Id, User> userEmailMap = new Map<Id, User>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        for(User userObj: [Select Id, firstname, title, lastname, email, contactId, MobilePhone,
                            Phone, Fax, Street, City, State, Country, PostalCode
                            from User
                            where ContactId in :contactIds]){
            userEmailMap.put(userObj.ContactId, userObj);               
        }       
        
        
        List<Contact> modifiedContacts = new List<Contact>();
        for(Contact contactObj: [Select Id, firstname, title, lastname, email, Phone, Fax,MobilePhone,
                                    MailingStreet, MailingCity, MailingState, MailingCountry, 
                                    MailingPostalCode from Contact 
                                    where Id in :userEmailMap.KeySet() 
                                    AND ((contact_type__c = :PRMLibrary.PARTNER) OR (contact_type__c = :PRMLibrary.EMPLOYEE) OR(contact_type__c = :PRMLibrary.COMPANY))]){
            User userObj = userEmailMap.get(contactObj.Id);
            Boolean modified = false;
            if(contactObj.firstname != userObj.firstname || isTesting){ 
                contactObj.firstname = userObj.firstname;
                modified = true;
            }
                        
            if(contactObj.lastname != userObj.lastname || isTesting){   
                contactObj.lastname = userObj.lastname;
                modified = true;
            }
            if(contactObj.email != userObj.email || isTesting){ 
                contactObj.email = userObj.email;
                modified = true;
            }
            if(contactObj.title != userObj.title || isTesting){ 
                contactObj.title = userObj.title;
                modified = true;
            }

            if(contactObj.phone != userObj.phone || isTesting){ 
                contactObj.phone = userObj.phone;
                modified = true;
            }
                        
            if(contactObj.fax != userObj.fax || isTesting){ 
                contactObj.fax = userObj.fax;
                modified = true;
            }
            if(contactObj.mobilephone != userObj.mobilephone || isTesting){ 
                contactObj.mobilephone = userObj.mobilephone;
                modified = true;
            }

            if(contactObj.mailingstreet != userObj.street || isTesting){    
                contactObj.mailingstreet = userObj.street;
                modified = true;
            }

            if(contactObj.mailingcity != userObj.city || isTesting){    
                contactObj.mailingcity = userObj.city;
                modified = true;
            }
                        
            if(contactObj.mailingstate != userObj.state || isTesting){  
                contactObj.mailingstate = userObj.state;
                modified = true;
            }
            if(contactObj.MailingCountry != userObj.country || isTesting){  
                contactObj.MailingCountry = userObj.country;
                modified = true;
            }
            if(contactObj.MailingPostalCode != userObj.PostalCode  || isTesting){   
                contactObj.MailingPostalCode = userObj.PostalCode;
                modified = true;
            }

                        
            if(modified){
                modifiedContacts.add(contactObj);
            }       
        }
        if(modifiedContacts.size() > 0){
            update modifiedContacts;
        }
    }

    
    @future
    public static void updatePartnerusers(Set<Id> contacts){
        Boolean isTesting = Test.isRunningTest();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        for(Contact contactObj: [Select Id, firstname, active__c, lastname, email from Contact
                                    where account.IsPartner = true and Id in :contacts]){
            contactMap.put(contactObj.Id, contactObj);              
        }
        System.debug('contactMap: ' + contactMap);
        
        List<User> modifiedUsers = new List<User>();
        for(User userObj: [Select Id, IsActive, firstname, lastname, email, contactId from User 
                                where ContactId in :contactMap.KeySet()]){
            Contact contactObj = contactMap.get(userObj.contactId);
            Boolean modified =false;
            if(userObj.firstname != contactObj.firstname || isTesting){ 
                userObj.firstname =contactObj.firstname;
                modified = true;
            }

            if(userObj.lastname != contactObj.lastname  || isTesting ){ 
                userObj.lastname =contactObj.lastname;
                modified = true;
            }

            if(userObj.email != contactObj.email || isTesting){ 
                userObj.email =contactObj.email;
                modified = true;
            }           

            if(userObj.IsActive != contactObj.active__c || isTesting){  
                userObj.IsActive =contactObj.active__c;
                modified = true;
            }
                        
            if(modified){
                modifiedUsers.add(userObj);
            }
        }
        
        if(modifiedUsers.size() > 0){
            List<Database.Saveresult> updateUserResults = Database.update(modifiedUsers, false);
            for(Database.Saveresult resultObj: updateUserResults){
                if(!resultObj.isSuccess()){
                    System.debug('Save error: ' + resultObj.getErrors());
                }               
            }   
        }
    }
    
    //This code will be invoked from Account trigger
    public static void createContactRoles(Set<Id> accountIds){
        Map<Id, Set<Id>> accountContactMap = new Map<Id, Set<Id>>();
        Set<Id> contactIds;
        Set<Id> modifiedContactIds = new Set<Id>();
        System.debug('accountIds: ' + accountIds);
        for(Contact contactObj: [Select Id, accountId from Contact where 
                                    accountId in :accountIds]){
            
            
            contactIds = accountContactMap.containskey(contactObj.accountId) ? 
                            accountContactMap.get(contactObj.accountId) : new Set<Id>();
            contactIds.add(contactObj.Id);
            accountContactMap.put(contactObj.accountId, contactIds);
            modifiedContactIds.add(contactObj.Id);
        }
        if(accountContactMap.size() > 0){
            PRMLibrary.createContactRoles(accountContactMap, modifiedContactIds);
        }
        
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
    
    //This code will be invoked from Contact trigger
    public static void createContactRoles(Map<Id, Set<Id>> accountContactMap, 
                                        Set<Id> modifiedContactIds){

        if(accountContactMap == null || accountContactMap.size() == 0){
            return;
        }       
        Set<Id> contactIds;
        Set<Id> contractRoleContactIds = new Set<Id>();
        Map<Id, Set<Id>> parentAccountContactMap = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> ultimateParentAccountContactMap = new Map<Id, Set<Id>>();
        for(Account  accountObj: [Select Id, name,ParentId from Account 
                                    where ParentId != null 
                                    and Id in :accountContactMap.keyset()]) {

            if(accountObj.ParentId == null){
                continue;
            }
            Id parentId = getUltimateParentAccountId(accountObj.ParentId);
            
            contactIds = parentAccountContactMap.containsKey(accountObj.ParentId) ? 
                        parentAccountContactMap.get(accountObj.ParentId) : new Set<Id>();
            
            contactIds.addall(accountContactMap.get(accountObj.Id));
            parentAccountContactMap.put(accountObj.ParentId,contactIds);
            
            contactIds = ultimateParentAccountContactMap.containsKey(parentId) ? 
                        ultimateParentAccountContactMap.get(parentId) : new Set<Id>();
            
            contactIds.addall(accountContactMap.get(accountObj.Id));
            ultimateParentAccountContactMap.put(parentId,contactIds);
            
            contractRoleContactIds.addall(contactIds);

        }
        
        System.debug('Parent AccountIds: ' + parentAccountContactMap);

        Map<Id, Id> contactParentAccountMap = new Map<Id, Id>();
        Map<Id, Id> contactUltimateParentAccountMap = new Map<Id, Id>();    
        if(ultimateParentAccountContactMap.size() == 0){
            if(modifiedContactIds.size() > 0){
                updateContactsParentAccount(contactUltimateParentAccountMap,
                                            contactParentAccountMap, 
                                            modifiedContactIds);
            }           
            return;
        }

        //Check for existing AccountContactRoles
        Map<Id, Map<Id, AccountContactRole>> accountContactRoleMap = new Map<Id, Map<Id, AccountContactRole>>();    
        Map<Id, AccountContactRole> contactRoleMap;
        for(AccountContactRole accountContactRoleObj : [Select Id, accountId, contactId, Role 
                                                        from AccountContactRole 
                                                        where Role = 'Other' and 
                                                        accountId in :ultimateParentAccountContactMap.keySet() and 
                                                        ContactId in :contractRoleContactIds]){
            contactRoleMap = accountContactRoleMap.containsKey(accountContactRoleObj.accountId) ? 
                                                accountContactRoleMap.get(accountContactRoleObj.accountId) : 
                                                new Map<Id, AccountContactRole>();
            contactRoleMap.put(accountContactRoleObj.contactId, accountContactRoleObj);
            accountContactRoleMap.put(accountContactRoleObj.accountId, contactRoleMap);                                     
        }

        List<AccountContactRole> contactRoles = new List<AccountContactRole>();
        for(Id accountId : ultimateParentAccountContactMap.keySet()){
            contactIds = ultimateParentAccountContactMap.get(accountId);
            for(Id contactId: contactIds){
                contactUltimateParentAccountMap.put(contactId, accountId);  
                contactRoleMap = accountContactRoleMap.get(accountId);
                if(contactRoleMap != null && contactRoleMap.containskey(contactId)){
                    continue;
                }
                AccountContactRole contactRoleObj = new AccountContactRole();
                contactRoleObj.ContactId = contactId;
                contactRoleObj.AccountId = accountId;
                contactRoleObj.Role = 'Other';
                contactRoles.add(contactRoleObj);
        
            }           
        }       
        
        System.debug('New Contact Roles: ' + contactRoles);
        if(contactRoles.size() > 0){
            insert contactRoles;
        }
        
        for(Id accountId : parentAccountContactMap.keySet()){
            contactIds = parentAccountContactMap.get(accountId);
            for(Id contactId: contactIds){
                contactParentAccountMap.put(contactId, accountId);  
            }           
        }   
        
        if(modifiedContactIds.size() > 0){
            updateContactsParentAccount(contactUltimateParentAccountMap,
                                        contactParentAccountMap, 
                                        modifiedContactIds);
        }
    }
    
    public static void updateContactsParentAccount(Map<Id, Id> contactUltimateParentAccountMap,
                                                    Map<Id, Id> contactParentAccountMap, 
                                                    Set<Id> modifiedContactIds){
        System.debug('modifiedContactIds: ' + modifiedContactIds);
        List<Contact> contactList = new List<Contact>();
        for(Contact contactObj : [Select Id, Parent_Account__c, accountId from 
                                    Contact where Id in :modifiedContactIds]){
            Id accountId = contactParentAccountMap.get(contactObj.Id);
            if(accountId == null){
                if(contactObj.accountId != null){
                    contactObj.Parent_Account__c = contactObj.accountId;
                }else{
                    contactObj.Parent_Account__c = null;
                }
            }else{
                contactObj.Parent_Account__c = accountId;
            }

            Id ultimateParentAccountId = contactUltimateParentAccountMap.get(contactObj.Id);
            if(ultimateParentAccountId == null){
                if(contactObj.accountId != null){
                    contactObj.Ultimate_Parent_Account__c = contactObj.accountId;
                }else{
                    contactObj.Ultimate_Parent_Account__c = null;
                }
            }else{
                contactObj.Ultimate_Parent_Account__c = ultimateParentAccountId;
            }
            contactList.add(contactObj);
        }
        if(contactList.size() > 0 ){
            update contactList;
        }
    }
    
    public static void setContactType(Set<Id> accountIdList){
        Map<Id, Contact> contactmap = new Map<Id, Contact>();
        for(Contact contactObj: [Select Id,accountId, name, active__c, 
                                 contact_Type__c from Contact 
                                  where accountId in :accountIdList]){
            contactmap.put(contactObj.id, contactObj);
        }   
        
        for(AccountContactRole roleObj : [Select accountId, contactId, AccountContactRole.contact.Id, 
                                                 AccountContactRole.contact.accountId,
                                                 AccountContactRole.contact.active__c, 
                                                AccountContactRole.contact.name, 
                                                AccountContactRole.contact.contact_Type__c
                                                from AccountContactRole where accountId in :accountIdList]){    
            if(roleObj.contact.active__c != null && roleObj.contact.active__c == true){
                contactmap.put(roleObj.contact.Id, roleObj.contact);
            }                                                   
        }
        
        if(contactmap.size() > 0){
            List<Contact> updatedContacts =     PRMLibrary.setContactType(contactmap.values());
            update updatedContacts;
        }                                           
    }   
    
    public static List<Contact>  setContactType(List<Contact> contactsForRecordType){
        
        Map<Id, Account> accountMap ; 
        map<Id, Set<Id>> contactRoleMap = new map<Id, Set<Id>>();
        Set<Id> roleAccountIds;
        Set<Id> contactIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>(); 
        for(Contact contactObj: contactsForRecordType){     
            if(contactObj.Id != null)
                contactIds.add(contactObj.Id);
            accountIds.add(contactObj.accountId);
        }
        
        if(!contactIds.isEmpty()){
            for(AccountContactRole roleObj: [Select accountId, contactId from AccountContactRole  
                                                where contactId in :contactIds]){
                roleAccountIds = contactRoleMap.containsKey(roleObj.contactId) ? 
                                    contactRoleMap.get(roleObj.contactId) : new Set<Id>();
                roleAccountIds.add(roleObj.accountId);
                contactRoleMap.put(roleObj.contactId, roleAccountIds);
                accountIds.add(roleObj.accountId);
            }
        }

        accountMap = PRMLibrary.getAccounts(accountIds);
        //System.debug('accountMap: ' + accountMap);
        for(Contact contactObj: contactsForRecordType){

            Id accountId = contactObj.AccountId;
            Account accountObj = accountMap.get(accountId);
            contactObj.contact_Type__c = '';
            //First verify the account to which the Contact is associated.
            if(accountObj.Account_Type__c != null && 
                accountObj.Account_Type__c == PRMLibrary.PARTNER){
                contactObj.contact_Type__c = PRMLibrary.PARTNER;
                continue;
            }else if(accountObj.Account_Type__c != null && 
                accountObj.Account_Type__c == PRMLibrary.SUNRUN){
                contactObj.contact_Type__c = PRMLibrary.EMPLOYEE;
                continue;
            }
            else if(accountObj.Account_Type__c != null && 
                accountObj.Account_Type__c == PRMLibrary.COMPANY){
                contactObj.contact_Type__c = PRMLibrary.EMPLOYEE;
                continue;
            }
            
            
            //If associated account is not Partner account then check AccountContactRole        
            if(contactObj.Id != null && contactRoleMap.containsKey(contactObj.Id)){
                roleAccountIds = contactRoleMap.get(contactObj.Id);
                for(Id tempAccountId : roleAccountIds){
                    accountObj = accountMap.get(tempAccountId);
                    //System.debug('accountObj.Account_Type__c: ' + accountObj.Account_Type__c);
                    if(accountObj.Account_Type__c != null && 
                        accountObj.Account_Type__c == PRMLibrary.PARTNER){
                        contactObj.contact_Type__c = PRMLibrary.PARTNER;
                        break;
                    }else if(accountObj.Account_Type__c != null && 
                        accountObj.Account_Type__c == PRMLibrary.SUNRUN){
                        contactObj.contact_Type__c = PRMLibrary.EMPLOYEE;
                        break;
                        
                    }
                     else if(accountObj.Account_Type__c != null && 
                        accountObj.Account_Type__c == PRMLibrary.COMPANY){
                        contactObj.contact_Type__c = PRMLibrary.EMPLOYEE;
                        break;
                        
                    }    
                }
            }
        }
        return contactsForRecordType;
    }
    
    public static void modifyChildAccountsName(Set<Id> parentAccountIds){
        list<Account> childAccounts = [Select Id, Name, ParentId, account_number__c from Account 
                                        where parentId in :parentAccountIds];
        if(childAccounts != null && childAccounts.size() > 0){
            PRMLibrary.updateAccountName(parentAccountIds, childAccounts);
            update childAccounts;
        }
    }

    public static void updateAccountName(Set<Id> parentAccountIds, List<Account> childAccounts){
        Map<Id, Account> accountMap = PRMLibrary.getAccounts(parentAccountIds);
        for(Account accountObj: childAccounts){
            if(accountMap != null && accountMap.containsKey(accountObj.ParentId)){
                Account tempAccountObj = accountMap.get(accountObj.ParentId);
                accountObj.name = tempAccountObj.name;
            }
        }       
    }
    
    public static Map<Id, UserRole> getPartnerPortalRoles(String accountId){
        Map<Id, UserRole> portalRoles = new Map<Id, UserRole>();
        for(UserRole userRoleObj: [Select Id, PortalRole, PortalAccountId, 
                        PortalType from UserRole 
                        where PortalAccountId = :accountId 
                        AND PortalType = :PRMLibrary.PARTNER]){
            portalRoles.put(userRoleObj.id, userRoleObj);               
        }
        return portalRoles;
    }

    public static void updatePartneruserEmails(Set<Id> contacts){
        if(Test.isRunningTest())
            return;
        updatePartneruserEmails_Future(contacts);
	}
    

    @future
    public static void updatePartneruserEmails_Future(Set<Id> contacts){
        Boolean isTesting = Test.isRunningTest();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        for(Contact contactObj: [Select Id, firstname, lastname, email, title, Phone, Fax,mobilephone,
                                    MailingStreet, MailingCity, MailingState, MailingCountry, 
                                    MailingPostalCode, TimeZoneSidKey__c
                                    from Contact
                                    where account.IsPartner = true and Id in :contacts]){
            contactMap.put(contactObj.Id, contactObj);              
        }
        System.debug('contactMap: ' + contactMap);
        
        List<User> modifiedUsers = new List<User>();
        for(User userObj: [Select Id, firstname, title, lastname, email, contactId, MobilePhone,
                                Phone, Fax, Street, City, State, Country, PostalCode, TimeZoneSidKey 
                                from User 
                                where ContactId in :contactMap.KeySet()]){
            Contact contactObj = contactMap.get(userObj.contactId);
            Boolean modified =false;
            if(userObj.firstname != contactObj.firstname || isTesting){ 
                userObj.firstname =contactObj.firstname;
                modified = true;
            }

            if(userObj.lastname != contactObj.lastname || isTesting){   
                userObj.lastname =contactObj.lastname;
                modified = true;
            }

            if(userObj.email != contactObj.email || isTesting){ 
                userObj.email =contactObj.email;
                modified = true;
            }           

            if(userObj.title != contactObj.title || isTesting){ 
                userObj.title =contactObj.title;
                modified = true;
            }           

            if(userObj.Phone != contactObj.phone || isTesting){ 
                userObj.Phone =contactObj.phone;
                modified = true;
            }

            if(userObj.fax != contactObj.fax || isTesting){ 
                userObj.fax =contactObj.fax;
                modified = true;
            }

            if(userObj.MobilePhone != contactObj.MobilePhone || isTesting){ 
                userObj.MobilePhone =contactObj.MobilePhone;
                modified = true;
            }

            if(userObj.street != contactObj.mailingstreet || isTesting){    
                userObj.street =contactObj.mailingstreet;
                modified = true;
            }           
            if(userObj.city != contactObj.mailingcity || isTesting){    
                userObj.city =contactObj.mailingcity;
                modified = true;
            }
            if(userObj.state != contactObj.mailingstate || isTesting){
                userObj.state =contactObj.mailingstate;
                modified = true;
            }
            if(userObj.country != contactObj.mailingcountry || isTesting){  
                userObj.country =contactObj.mailingcountry;
                modified = true; 
            }           
            if(userObj.postalcode != contactObj.mailingpostalcode || isTesting){    
                userObj.postalcode =contactObj.mailingpostalcode;
                modified = true;
            }
            if(userObj.TimeZoneSidKey != contactObj.timeZoneSidKey__c || isTesting){
                userObj.TimeZoneSidKey = contactObj.timeZoneSidKey__c;
                modified = true;
            }       

            if(modified){
                modifiedUsers.add(userObj);
            }
        }
        
        if(modifiedUsers.size() > 0){
            contactsUpdated = true;
            update modifiedUsers;
        }   
    
    }

    public static RecordType getResidentialContactRecordType(){
        Map<Id, RecordType> tempcontactRecordTypeMap = PRMLibrary.getContactRecordTypes();
        RecordType recordTypeObj = null;
        for(RecordType tempRecodType : tempcontactRecordTypeMap.values()){
            if(tempRecodType.name == 'Residential'){
                recordTypeObj =  tempRecodType;
                break;
            }
        }
        return recordTypeObj;
    }

    public static RecordType getEmployeeContactRecordType(){
        Map<Id, RecordType> tempContactRecordTypeMap = PRMLibrary.getContactRecordTypes();
        RecordType recordTypeObj = null;
        for(RecordType tempRecodType : contactRecordTypeMap.values()){
            if(tempRecodType.name == 'Employee'){
                recordTypeObj =  tempRecodType;
                break;
            }
        }
        return recordTypeObj;
    }

    public static Set<Id> getPartnerAndEmployeeRecordTypes(){
        Set<Id> recordTypeIds = new Set<Id>();
        Map<Id, RecordType> tempContactRecordTypeMap = PRMLibrary.getContactRecordTypes();
        RecordType recordTypeObj = null;
        for(RecordType tempRecodType : contactRecordTypeMap.values()){
            if(tempRecodType.name == PARTNER || tempRecodType.name == EMPLOYEE){
				recordTypeIds.add(tempRecodType.Id);
            }
        }
        return recordTypeIds;
    }

    public static RecordType getPartnerContactRecordType(){
        Map<Id, RecordType> tempContactRecordTypeMap = PRMLibrary.getContactRecordTypes();
        RecordType recordTypeObj = null;
        for(RecordType tempRecodType : contactRecordTypeMap.values()){
            if(tempRecodType.name == 'Partner'){
                recordTypeObj =  tempRecodType;
                break;
            }
        }
        return recordTypeObj;
    }

    //This method will be invoked to check active child records for a given account
    //This will be invoked when an account is deactivated.
    public static Map<Id, String> checkForActiveAccountsAndContacts(Set<Id> accountIds){
        Map<Id, String> accountsWithActiveRecords = new Map<Id, String>();
        for(Account accountObj: [Select Id, (Select Id, active__C, accountId 
                                                from Contacts where active__C = true limit 1) 
                                    from Account where Id in :accountIds]){
            if(accountObj.contacts != null && accountObj.contacts.size() > 0){
                accountsWithActiveRecords.put(accountObj.Id, 'This account has active child Accounts/Contacts and can\'t be deactivated');
            }   
        }

        for(Account accountObj: [Select Id, active__c ,ParentId from Account where ParentId in :accountIds
                                    And active__c = true]){
            accountsWithActiveRecords.put(accountObj.ParentId, 'This account has active child Accounts/Contacts and can\'t be deactivated');
        }       
        
        return accountsWithActiveRecords;
    }

    //This method will check Inactive parent accounts.
    //This method will be invoke during account activation
    public static Set<Id> getInactiveParentAccounts(Set<Id> accountIds){
        Set<Id> inactiveParents = new Set<Id>();
        for(Account accountObj: [Select Id, active__c from Account where Id in :accountIds
                                    And active__c != true ]){
            inactiveParents.add(accountObj.Id);
        }       
        return inActiveParents;
    }   

    //This method will check Inactive parent accounts.
    //This method will be invoke during contact activation  
    public static Set<Id> getInactiveAccounts(Set<Id> accountIds){
        Set<Id> inActiveAccounts = new Set<Id>();
        for(Account accountObj: [Select Id, active__c from Account where Id in :accountIds
                                    And active__c != true ]){
            inActiveAccounts.add(accountObj.Id);
        }       
        return inActiveAccounts;
    }

    public class ErrorDescription{
        public ErrorDescription(){
        
        }
        public ErrorDescription(String contractNumber, String errorMessage){
            this.contractNumber = contractNumber;
            this.errorMessage = errorMessage;
        }
        public String contractNumber{ set; get;}
        public String errorMessage{set; get;}
    }
    public static Map<Id, String> getContactsWithInvalidDomain(Map<Id, String> contactEmailMap){
        System.debug('contactEmailMap: ' + contactEmailMap);
        Map<Id, String> contactsWithInvalidDomain = new Map<Id, String>();
        if(contactEmailMap != null && !contactEmailMap.isEmpty()){
            for(Contact contactObj : [Select Id, Name, FirstName, LastName, Email, 
                                            AccountId, Title, Job_Function__c, reportsToId,
                                            Account.Account_Manager__c, Account.Name,
                                            Account.ValidDomains__C
                                            from Contact where Id = :contactEmailMap.keySet()]){
                String emailId = contactEmailMap.get(contactObj.Id);
                if(isValidDomain(contactObj.Account.ValidDomains__C, emailId) == false){
                    contactsWithInvalidDomain.put(contactObj.Id, contactObj.Account.ValidDomains__C);
                }
            }
        }

        return contactsWithInvalidDomain;
    }

    public static boolean isValidDomain(String validDomainList, string emailId){
        String[] emailIdList = new List<String>();
        if(emailId == null)
            return false;
            
        emailIdList = emailId.split('@');
        if(emailIdList == null || emailIdList.size() != 2)
            return false;
        
        if(validDomainList == null || 
            validDomainList == ''){
            return true;    
        }
        
        String[] domainList = validDomainList.split(';');
        System.debug('domainList: ' + domainList);          
        for(String tempDomain : domainList){
            if(tempDomain == emailIdList[1]){
                return true;
            }
        }
        return false;
    }

}