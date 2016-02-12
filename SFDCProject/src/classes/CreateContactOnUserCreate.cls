public with sharing class CreateContactOnUserCreate {
    @future
    public static void CreateContact(Set <id> ids,set<id> contIds){
        Id rectypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Employee').getRecordTypeId();
        Id SunrunId=System.label.sunrun_inc_id;
        List<Contact> conList=new List<Contact>();
        Map<id,Contact> contMap=new Map<id,Contact>([select id,Professional_Certification__c,Accreditation_Status__c,Accreditation_date__c,design_tool_access__c,proposal_tool_access__c,Sells_Sunrun__c from contact where id in:contIds]);
        List<User> userList=[select id,External_ID__c,external_source__c,PP_Contact_Id__c,firstname,lastname,phone,email,division,department from user where id in:ids];
        for(User u:userList){
            Contact c=new Contact();
            c.accountid=sunrunId;
            c.Parent_Account__c=sunrunId;
            c.Ultimate_Parent_Account__c=sunrunId;
            c.lastname=u.lastname;
            c.firstname=u.firstname;
            c.Sunrun_User__c=u.id;
            c.Division__c=u.Division;
            c.recordtypeid=rectypeId;
            c.Department__c=u.Department;
            c.External_Id__c=u.External_ID__c;
            c.DataSourceC__c=u.external_source__c;
            c.phone=u.phone;
            c.Email=u.email;
            if(u.PP_Contact_Id__c!=null&&contMap.containsKey(u.PP_Contact_Id__c)){
                c.Design_Tool_Access__c=contMap.get(u.PP_Contact_Id__c).Design_Tool_Access__c;
                c.Proposal_Tool_Access__c=contMap.get(u.PP_Contact_Id__c).Proposal_Tool_Access__c;
                c.Accreditation_date__c=contMap.get(u.PP_Contact_Id__c).Accreditation_date__c;
                c.Accreditation_Status__c=contMap.get(u.PP_Contact_Id__c).Accreditation_Status__c;
                c.Sells_Sunrun__c=contMap.get(u.PP_Contact_Id__c).Sells_Sunrun__c;  
                c.Professional_Certification__c=contMap.get(u.PP_Contact_Id__c).Professional_Certification__c;          
            }
            conList.add(c);
        }
        if(!conList.isEmpty()){
            database.insert(conList,false);
        }
    }
    @future
    public static void InactivateContact(Set <id> ids){
        List<Contact> conList=new List<Contact>();
        for(Contact c:[select id,active__c from contact where sunrun_user__c in:ids]){
            c.active__c=false;
            conList.add(c);
        }
        if(!conList.isEmpty()){
            update conList;
        }
    }
    @future 
    public static void UpdateEmailOnContact(Set <id> ids){
        List<Contact> conList=new List<Contact>();
        for(Contact c:[select id,sunrun_user__r.email from contact where sunrun_user__c in:ids]){
            c.email=c.sunrun_user__r.email;
            conList.add(c);
        }
        if(!conList.isEmpty()){
            update conList;
        }
    }

}