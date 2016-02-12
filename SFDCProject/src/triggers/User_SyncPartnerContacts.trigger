/****************************************************************************
Author  : Raghu Masineni (rmasineni@sunrunhome.com)
Date    : April 2012

Description: This trigger will Sync the following Contact fields
            First name
            Last Name
            Email
*****************************************************************************/
trigger User_SyncPartnerContacts on User (after update) {
    
    Set<Id> contactIds = new Set<Id>();
    Set<Id> activateContactIds = new Set<Id>();
    Set<Id> deActivateContactIds = new Set<Id>();
    
    Map<Id, Contact> contactMapForLMSInfo = new Map<Id, Contact>();
    Map<Id, User> contactUserMap = new Map<Id, User>();
    for(User userObj: Trigger.new){
        
        if(userObj.contactId == null)
            continue; 
        
        User oldUserObj = Trigger.oldMap.get(userObj.id);
        if((userObj.FirstName != null && userObj.FirstName != oldUserObj.FirstName) || 
            (userObj.LastName != null && userObj.LastName != oldUserObj.LastName) ||
            (userObj.title != null && userObj.title != oldUserObj.title) ||
            (userObj.Phone != null && userObj.Phone != oldUserObj.Phone) ||
            (userObj.MobilePhone != null && userObj.MobilePhone != oldUserObj.MobilePhone) ||
            (userObj.Fax != null && userObj.Fax != oldUserObj.Fax) ||
            (userObj.Street != null && userObj.Street != oldUserObj.Street) ||
            (userObj.City != null && userObj.City != oldUserObj.City) ||
            (userObj.State != null && userObj.State != oldUserObj.State) ||
            (userObj.Country != null && userObj.Country != oldUserObj.Country) ||
            (userObj.PostalCode != null && userObj.PostalCode != oldUserObj.PostalCode) ||
            (userObj.Email != null && userObj.Email != oldUserObj.Email)){
            
            if(userObj.ContactId != null){
                contactIds.add(userObj.ContactId);
                contactUserMap.put(userObj.ContactId, userObj);
            }
        }
    }
    Set<Id> accountIds = new Set<Id>();
    Set<Id> lmsInfoContactIds = new Set<Id>();  
    if(contactIds.size() > 0){
        Set<Id> updateContactIds = new Set<Id>();
        for(Contact contactObj: [Select Id, firstname, title, lastname, email, Phone, Fax,MobilePhone, Ultimate_Parent_Account__c,
                                    MailingStreet, MailingCity, MailingState, MailingCountry, 
                                    MailingPostalCode from Contact where 
                                    Id in :contactIds]){
            User userObj = contactUserMap.get(contactObj.id);
            if(contactObj.Ultimate_Parent_Account__c != null && 
                ((userObj.FirstName != contactObj.firstname) || 
                (userObj.lastname != contactObj.lastname) || 
                (userObj.email != contactObj.email))){
                accountIds.add(contactObj.Ultimate_Parent_Account__c);
                contactMapForLMSInfo.put(contactObj.Id, contactObj);
            }
            
            if((userObj.FirstName != contactObj.firstname) || 
                (userObj.lastname != contactObj.lastname) || 
                (userObj.title != contactObj.title) || 
                (userObj.Phone != contactObj.Phone) ||
                (userObj.MobilePhone != contactObj.MobilePhone) ||
                (userObj.Fax != contactObj.Fax) ||
                (userObj.Street != contactObj.MailingStreet) ||
                (userObj.City != contactObj.MailingCity) ||
                (userObj.State != contactObj.MailingState) ||
                (userObj.Country != contactObj.MailingCountry) ||
                (userObj.PostalCode != contactObj.MailingPostalCode) ||
                (userObj.email != contactObj.email)){
                updateContactIds.add(contactObj.Id);    
            }
        }
        
        Map<Id, Account> accountsMapForLMSInfo = new Map<Id, Account>();
        if(accountIds.size() > 0){
            accountsMapForLMSInfo = PRMLibrary.getAccounts(accountIds);
        }
        
        for(Id contactId : contactMapForLMSInfo.keySet()){
            Contact contactObj = contactMapForLMSInfo.get(contactId);
            Account accountObj = accountsMapForLMSInfo.get(contactObj.Ultimate_Parent_Account__c);
            if(accountObj != null && accountObj.stage__c != null && 
                (accountObj.stage__c == 'Confirmed' || accountObj.stage__c.contains('Contract Negotiation'))){
                lmsInfoContactIds.add(contactObj.Id);       
            }
        }
        
        if(updateContactIds.size() > 0 && PRMLibrary.contactsUpdated == false && !Test.isRunningTest()){
            PRMLibrary.updatePartnerContacts(updateContactIds, lmsInfoContactIds);
        }

        if(lmsInfoContactIds != null && !lmsInfoContactIds.isEmpty()){
            NetExamWebServiceAPIHelper7.SendContactFromTrigger(lmsInfoContactIds, activateContactIds, deactivateContactIds);
        }

    }
}