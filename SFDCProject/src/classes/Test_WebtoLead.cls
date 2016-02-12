@istest(seeAllData=true)
public with sharing class Test_WebtoLead {
    public static testMethod void Test_WebtoLead(){
        Recordtype r=[select id from recordtype where sobjecttype='Account' and name='Partner' limit 1];
         Created_By__c devAccount =  Created_By__c.getValues('Created By Name');
      if(devAccount==null){
        Created_By__c dev=new Created_By__c(name='Created By Name',Created_By_User__c='SunRun Admin',User_ID__c=userinfo.getUserId());
        insert dev;
        devAccount=dev;
      } 
      //user contactuser=[select id,email,contactid from user where contactid!=null and isactive=true limit 1];
      
      Account Acc= new Account(name='Costco-Hawaii',billingpostalcode='00000',office_location__c='Headquarters',stage__c='Confirmed',Channel_Type__c='Retail',recordtypeid=r.id);
        insert Acc;
        List<Contact> contactuserList;
        try{
        contactuserList=[select id,email from contact where email=:userinfo.getuseremail() limit 1];
        }
        Catch(exception e){}
        if(contactuserList.isempty()){
        Contact contactuser=new Contact(firstname='TestFirst',lastname='test111',email=userinfo.getuseremail(),accountid=acc.id);
        insert contactuser; 
        contactuserList.add(contactuser); 
        }                  
        Contact_Preferences__c CP = new Contact_Preferences__c(Lead_Organization_Location__c=acc.id, Contact__c=contactuserList[0].id);     
         insert cp; 
       // user u=[select id from user where id=:devAccount.User_ID__c limit 1];  
       User u=new User(id=devAccount.user_id__c); 
       String loggedinemail=userinfo.getUserEmail(); 
     system.runAs(u){   
     List<Lead> LeadList = new List<Lead>();
     Lead l = new Lead(FirstName='Test',company='Test', LastName='Lead',Lead_Organization_Location_2__c=acc.id,channel__c='Retail',Field_Marketing_Branch__c='Denver',Sales_Rep_email__c='sample23244@email.com',lead_classification__c='Field Sales');
     Lead l2 = new Lead(FirstName='Test1',company='Test', LastName='Lead1',Lead_Organization_Location_2__c=acc.id,channel__c='Retail',Field_Marketing_Branch__c='Denver',Sales_Rep_email__c=loggedinemail,lead_classification__c='Field Sales');
     LeadList.add(l);
     LeadList.add(l2);
     Test.starttest();
     insert LeadList;
     
     Set<id> leadset=new Set<id>();
     leadSet.add(l.id);
     leadset.add(l2.id);
     Web2LeadOwnerUpdate.Web2LeadOwnerUpdate(leadset);
     
     Test.stopTest();
     }       
     
   }
}