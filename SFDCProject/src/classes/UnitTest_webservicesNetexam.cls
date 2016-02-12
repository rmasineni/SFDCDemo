@istest
public class UnitTest_webservicesNetexam {

    public static testmethod void testGetUserServiceSoap(){
        webservicesNetexamComUserservice7 webserviceObj = new webservicesNetexamComUserservice7();
        webservicesNetexamComUserservice7.UserServiceSoap userServObj = webserviceObj.GetUserServiceSoap();
        webservicesNetexamComUserservice7.BulkUpsertUsers_element bulkUserObj = new webservicesNetexamComUserservice7.BulkUpsertUsers_element();
        webservicesNetexamComUserservice7.ArrayOfUser arrayUserObj = new webservicesNetexamComUserservice7.ArrayOfUser();

        webservicesNetexamComUserservice7.GetLoginTokenResponse_element GetLoginTokenResponseObj = new webservicesNetexamComUserservice7.GetLoginTokenResponse_element();
        webservicesNetexamComUserservice7.AddEditUserGroup_element AddEditUserGroupObj = new webservicesNetexamComUserservice7.AddEditUserGroup_element();
        webservicesNetexamComUserservice7.ArrayOfUserUserGroup ArrayOfUserUserGroupObj = new webservicesNetexamComUserservice7.ArrayOfUserUserGroup();

        webservicesNetexamComUserservice7.UpsertUserResponse_element UpsertUserResponseObj = new webservicesNetexamComUserservice7.UpsertUserResponse_element();
        webservicesNetexamComUserservice7.UpsertUserWithUserGroups_element UpsertUserWithUserGroupsObj = new webservicesNetexamComUserservice7.UpsertUserWithUserGroups_element();

        webservicesNetexamComUserservice7.GetToken_element GetToken_elementObj = new webservicesNetexamComUserservice7.GetToken_element();
        webservicesNetexamComUserservice7.AddEditUser_element AddEditUser_elementObj = new webservicesNetexamComUserservice7.AddEditUser_element();
        webservicesNetexamComUserservice7.GetAdminLoginTokenResponse_element GetAdminLoginTokenResponse_elementObj = new webservicesNetexamComUserservice7.GetAdminLoginTokenResponse_element();

        webservicesNetexamComUserservice7.ArrayOfString ArrayOfStringObj = new webservicesNetexamComUserservice7.ArrayOfString();
        webservicesNetexamComUserservice7.GetTokenResponse_element GetTokenResponse_elementObj = new webservicesNetexamComUserservice7.GetTokenResponse_element();

        webservicesNetexamComUserservice7.ActivateUserByExternalID_element ActivateUserByExternalID_elementObj = new webservicesNetexamComUserservice7.ActivateUserByExternalID_element();
        webservicesNetexamComUserservice7.AddEditUserResponse_element AddEditUserResponse_elementObj = new webservicesNetexamComUserservice7.AddEditUserResponse_element();
        webservicesNetexamComUserservice7.ActivateUserByExternalIDResponse_element ActivateUserByExternalIDResponse_elementObj = new webservicesNetexamComUserservice7.ActivateUserByExternalIDResponse_element();

        webservicesNetexamComUserservice7.GetLoginToken_element GetLoginToken_elementObj = new webservicesNetexamComUserservice7.GetLoginToken_element();
        webservicesNetexamComUserservice7.DeactivateUserByExternalID_element DeactivateUserByExternalID_elementObj = new webservicesNetexamComUserservice7.DeactivateUserByExternalID_element();

        webservicesNetexamComUserservice7.BulkUpsertUsersResponse_element BulkUpsertUsersResponse_elementObj = new webservicesNetexamComUserservice7.BulkUpsertUsersResponse_element();
        webservicesNetexamComUserservice7.DeactivateUserByExternalIDResponse_element DeactivateUserByExternalIDResponse_elementObj = new webservicesNetexamComUserservice7.DeactivateUserByExternalIDResponse_element();
        webservicesNetexamComUserservice7.User_x User_xObj = new webservicesNetexamComUserservice7.User_x();

        webservicesNetexamComUserservice7.UpsertUser_element UpsertUser_elementObj = new webservicesNetexamComUserservice7.UpsertUser_element();
        webservicesNetexamComUserservice7.GetAdminLoginToken_element GetAdminLoginToken_elementObj = new webservicesNetexamComUserservice7.GetAdminLoginToken_element();
        
        webservicesNetexamComUserservice7.UserServiceSoap UserServiceSoapObj = new webservicesNetexamComUserservice7.UserServiceSoap();
        webservicesNetexamComUserservice7.ApiResult resultObj1 = UserServiceSoapObj.DeactivateUserByExternalID('','','','');
        webservicesNetexamComUserservice7.ApiResult resultObj2 = UserServiceSoapObj.UpsertUser('','','','','','','','','','','', null,false,null,true,'');
        String result3 = UserServiceSoapObj.GetAdminLoginToken('','','','','','','','','');
        String result4 = UserServiceSoapObj.GetLoginToken('','','','','','','','','','') ;
        String result5 = UserServiceSoapObj.AddEditUser('','','','','','','','','','');
        String result6 = UserServiceSoapObj.GetToken('','','','');
        webservicesNetexamComUserservice7.ApiResult result7 = UserServiceSoapObj.BulkUpsertUsers('','','',null);
        webservicesNetexamComUserservice7.ApiResult result8 = UserServiceSoapObj.ActivateUserByExternalID('','','','');
        
    }   
}