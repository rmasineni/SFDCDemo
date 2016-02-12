@isTest(SeeAllData=true)
public with sharing class Test_AuditEmailTemplateController {
    public static testmethod void AuditEmailTemplateController (){
       // SunRun_Audit_Data__c aetc = new SunRun_Audit_Data__c();
       // aetc.name= 'Audit Email Signature';
      //  aetc.Sunrun_Audit_Email_Signature_Name__c='Audit Email Signature';
      //  aetc.Sunrun_Audit_Email_Signature_Title__c='manager';
      //  aetc.Sunrun_Audit_Email_Signature_Address__c='Test@yopmail.com';
      //  
      //  insert aetc;
        
        AuditEmailTemplateController aetc1 = new AuditEmailTemplateController();        
           Install_Audit__c instaudit = [select id, Auditor_Contact__r.Name, Generation_Asset__r.Name,
                Generation_Asset__r.Account_Name__r.Name, Generation_Asset__r.Home_Address__c,
                Generation_Asset__r.Install_Partner__c, Denied_Reason__c, Install_Audit_Type__c,
                Generation_Asset__r.Customer_Contact__r.Name, 
                Service_Contract__r.Name,
                Service_Contract__r.Account.Id, Service_Contract__r.Account.name, Service_Contract__r.Customer_Mailing_Address__c,
                Service_Contract__r.Install_Partner__c, Service_Contract__r.Contact.Name
           from Install_Audit__c limit 1];
          
                          
    }

}