global class AuditEmailTemplateController {

global AuditEmailTemplateController(){           
           PhotoSubmitDate = (DateTime.now().addDays(7)).format('MMMM dd, yyyy');
           SiteSubmitDate = (DateTime.now().addDays(21)).format('MMMM dd, yyyy'); 
           
           SunRun_Audit_Data__c auditEmailSetting = [select Sunrun_Audit_Email_Signature_Address__c, Sunrun_Audit_Email_Signature_Name__c, 
                                                            Sunrun_Audit_Email_Signature_Title__c from SunRun_Audit_Data__c where Name = 'Audit Email Signature'];
                                                            
           SignatureName = auditEmailSetting.Sunrun_Audit_Email_Signature_Name__c;
           SignatureTitle = auditEmailSetting.Sunrun_Audit_Email_Signature_Title__c;
           SignatureAddress = auditEmailSetting.Sunrun_Audit_Email_Signature_Address__c;
           
           AuditURL = System.Label.PartnerPortalSiteUrl + '/installaudit?id=';
           //AuditURL = 'https://intdev-sunrunhome.cs17.force.com/partner/installaudit?id=' + ia.Id;
           string strOrgId = UserInfo.getOrganizationId();
           string orgInst = URL.getSalesforceBaseUrl().getHost();
           SunrunURL = URL.getSalesforceBaseUrl().getProtocol() + '://' + orgInst; //+ '/servlet/servlet.ImageServer?id=' + lstDocument[0].Id + '&oid=' + strOrgId;
}

/*global Install_Audit__c getInstallAudit(){
       return [select id, Auditor_Contact__r.Name, Generation_Asset__r.Name,
                Generation_Asset__r.Account_Name__r.Name, Generation_Asset__r.Home_Address__c,
                Generation_Asset__r.Install_Partner__c, Denied_Reason__c, Install_Audit_Type__c,
                Generation_Asset__r.Customer_Contact__r.Name
           from Install_Audit__c where Id = :InstallAuditId];   
}
*/
global Install_Audit__c getInstallAudit(){
       return [select id, Auditor_Contact__r.Name, Service_Contract__r.Name,
                Service_Contract__r.Account.Name, Service_Contract__r.Home_Address__c,
                Service_Contract__r.Install_Partner__c, Denied_Reason__c, Install_Audit_Type__c,
                Service_Contract__r.Contact.Name,Service_Contract__r.Customer_Mailing_Address__c
           from Install_Audit__c where Id = :InstallAuditId];   
}

global Id InstallAuditId { get; set; }
global Install_Audit__c ia { get; set; }

global String PhotoSubmitDate{get;set;}
global String SiteSubmitDate{get;set;}
global String SignatureName{get;set;}
global String SignatureTitle{get;set;}
global String SignatureAddress{get;set;}
global String AuditURL{get;set;}
global String SunrunURL{get; set;}
}