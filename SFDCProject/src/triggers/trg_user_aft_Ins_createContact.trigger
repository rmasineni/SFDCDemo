trigger trg_user_aft_Ins_createContact on User (after insert,after update) {    
    Set<id> UserIds=new Set<id>();
    Set<id> EmailUserIds=new Set<id>();
    Set<id> contIds=new Set<id>();
    if(trigger.isInsert){
    for(User u:trigger.new){
        if(u.usertype=='Standard'){         
            UserIds.add(u.id);
            contIds.add(u.PP_Contact_Id__c);
        }
    }
    if(!UserIds.isEmpty()){
        CreateContactOnUserCreate.CreateContact(UserIds,contIds);
    }
    }
    else if(trigger.isUpdate){
        for(User u:trigger.new){
        if(u.usertype=='Standard'&&u.isactive==false&&trigger.oldMap.get(u.id).isactive==true){         
            UserIds.add(u.id);          
        }
        else if(u.usertype=='Standard'&&u.email!=trigger.oldMap.get(u.id).email){
            EmailUserIds.add(u.id);
        }
    }
    if(!UserIds.isempty()){
        CreateContactOnUserCreate.InactivateContact(UserIds);
        }
    if(!EmailUserIds.isempty()){
        CreateContactOnUserCreate.UpdateEmailOnContact(EmailUserIds);
    }       
    }

}