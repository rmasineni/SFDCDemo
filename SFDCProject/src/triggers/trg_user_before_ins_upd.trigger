trigger trg_user_before_ins_upd on User (before insert, before update) {

    List<User> usersList = new List<User>();
    Map<Id, String> contactEmails = new Map<Id, String>();
    for(User userObj: Trigger.new){
        userObj.User_Division_Custom__c=userObj.DefaultDivision;
        if(userObj.contactId == null)
            continue; 

        User oldUserObj = null;
        if(trigger.isUpdate){
            oldUserObj  = Trigger.oldMap.get(userObj.id);
        }

        if((userObj.firstname == null || userObj.firstname == '')
            && (oldUserObj == null || oldUserObj.firstname != userObj.firstname)){              
            userObj.adderror('Required value for the Firstname. It can\'t null OR empty');
        }
        
        if((userObj.title == null || userObj.title == '')
            && (oldUserObj == null || oldUserObj.title != userObj.title)){              
            userObj.adderror('Required value for the Title. It can\'t null OR empty');
        }

        if(userObj.Email != null 
            && (oldUserObj == null || userObj.Email != oldUserObj.Email)){
            contactEmails.put(userObj.ContactId, userObj.email);
            usersList.add(userObj);
        }
    }
       
    Map<Id, String> contactsWithInvalidDomain = new Map<Id, String>();
    if(contactEmails.size() > 0){
        contactsWithInvalidDomain = PRMLibrary.getContactsWithInvalidDomain(contactEmails);
        for(User tempUserObj : usersList){
            if(contactsWithInvalidDomain.containsKey(tempUserObj.contactId)){
                String tempValidDomainlist = contactsWithInvalidDomain.get(tempUserObj.contactId);
                tempUserObj.adderror('Email doesn\'t contain a valid partner domain. Please select one of the valid domains : ' + tempValidDomainlist);
            }
        }
    }

}