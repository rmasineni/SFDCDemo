@isTest(SeeAllData=true)
public class UnitTest_CreateContactOnUserCreate {

    private static testMethod void CreateContactOnUserCreate(){
    
    User u=[Select id from user where isactive=true and usertype='Standard' limit 1];
    Contact c=[select id from contact limit 1];
    Set<id> userids=new Set<id>();
    Set<id> contIds=new Set<id>();
    userids.add(u.id);
    contIds.add(c.id);
    CreateContactOnUserCreate.CreateContact(userids,contIds);
    //CreateContactOnUserCreate.InactivateContact(userIds);
    CreateContactOnUserCreate.UpdateEmailOnContact(userids);
    }
    }