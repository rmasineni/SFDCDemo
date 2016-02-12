public class SendEmailClass extends BaseClass{
    String emailTemplateNtp  ='ACH_Link_at_NTP';
    String emailTemplatePto  ='ACH_link_at_PTO';
    boolean ntpRoleId;
    boolean ptoRoleId;
    boolean creditRoleId;
    boolean ptosendEmail;
    public boolean emptycon = false;
    public static boolean checkptosend = false; 
    EmailTemplate CreditPassCustomer = [Select Id,Name from EmailTemplate where developerName =: 'Credit_Decision_PASS_Customer_New_Address_Rev_1'];
    EmailTemplate CreditCPassCustomer = [Select Id,Name from EmailTemplate where developerName =: 'Credit_Decision_CPASS_Customer_New_Address_Rev_1'];
    //adding spanish templates
    EmailTemplate CreditCPassCustomer_Spanish= [Select Id,Name from EmailTemplate where Name =: 'Credit Decision - CPASS - Customer - New Address- Rev1_SPANISH'];
    EmailTemplate CreditPassCustomer_Spanish= [Select Id,Name from EmailTemplate where Name =: 'Credit Decision - PASS - Customer - New Address - Rev1_SPANISH'];
    OrgWideEmailAddress owcc = [Select Id,Address,DisplayName from OrgWideEmailAddress where DisplayName='Customer Care'];
    OrgWideEmailAddress owea = [Select Id,DisplayName from OrgWideEmailAddress where DisplayName='Sunrun Credit']; 
    EmailTemplate PosigenCreditPassCustomer = [Select Id,Name from EmailTemplate where developerName =: 'Posigen_Credit_Process_Approval_Letter_Customer'];
    EmailTemplate PosigenCreditPassPartner = [Select Id,Name from EmailTemplate where developerName =: 'Posigen_Credit_Process_Approval_Letter_Partner'];
    Id CreditCustomerTemplate;
    Id ContactId ;
    Id CreditPartnerTemplate;
    List<Opportunity> OppNtpListUpdate = New List <Opportunity>();
    List<Opportunity> PtoListUpdate = New List <Opportunity>();
    List<Opportunity> OppListNtp = new List<Opportunity>();
    List<Opportunity> OppListPto = New List<Opportunity>();
    List<Opportunity> OppListCredit = New List<Opportunity>();
    List<Opportunity> OppListCreditUpdate = New List<Opportunity>();
    Set<Id> OppNtpIds = new Set<Id>();
    Set<Id> OppPtoIds = New Set<Id>();
    Set<Id> OppCreditIds = New Set<Id>();
    Map<Id,Opportunity> OppNtpMap = new Map<Id,Opportunity>();
    Map<Id,Opportunity> OppPtoMap = New Map<Id,Opportunity>();
    Map<Id,Opportunity> OppCreditMap = New Map<Id,Opportunity>();
    String roleId;
    String vfPage = 'CustomerOptyAutoPayment';
    public static string POSIGEN='PosiGen';
    
    public void SendEmailSCNtp(List<ServiceContract>ScNtpList) {
        try{
            for (ServiceContract sctem :ScNtpList){
                OppNtpIds.add(sctem.Opportunity__c);
            }
            OppListNtp = [Select id,
                          Payment_Request_Url__c,
                          Payment_Request_Token_Status__c,
                          Payment_Request_Contact_Role_Id__c,
                          (select Id,
                           Role,
                           ContactId,
                           Contact.Id,
                           Contact.FirstName,
                           Contact.LastName,
                           Contact.Email,
                           Contact.Phone,
                           Contact.Contact_Number__c,
                           Contact.MailingStreet,
                           Contact.MailingCity,
                           Contact.MailingState,
                           Contact.MailingPostalCode,
                           Contact.Preferred_Language__c,
                  			IsPrimary
                           from OpportunityContactRoles                        
                          )
                          from Opportunity
                          where Id IN:OppNtpIds
                         ];
            for (Opportunity opptem : OppListNtp){
                OppNtpMap.put(opptem.Id,opptem);
            }
            for (ServiceContract sctem : ScNtpList){
                String baseUrl = Sf.settingsService.getString(Constants.RequestPaymentBaseUrl);
                if (!baseUrl.endsWith('/')) {
                    baseUrl += '/';
                }   
                String token = generateVerificationToken();
                String PrimaryLanguage ='English';
                Opportunity Opty = OppNtpMap.get(sctem.Opportunity__c);
                for (OpportunityContactRole optyRole : Opty.OpportunityContactRoles) {
                    if(optyRole.ContactId == sctem.ContactId && optyRole.Role == 'Billing Contact'){
                        Opty.Payment_Request_Contact_Role_Id__c = optyRole.Id;
                        ntpRoleId = true;
                    }                    
                      if(optyRole.IsPrimary==true){
                         PrimaryLanguage= optyRole.contact.Preferred_Language__c;
                     }
                }
                if (ntpRoleId != true){
                    OpportunityContactRole ntptemp = new OpportunityContactRole();
                    ntptemp.ContactId = sctem.ContactId;
                    ntptemp.OpportunityId = sctem.Opportunity__c;
                    ntptemp.Role ='Billing Contact';
                    insert ntptemp;
                    Opty.Payment_Request_Contact_Role_Id__c = ntptemp.Id;
                   
                }
                 String primaryLanguageCode= PrimaryLanguage=='Spanish'?'es':'en';
               	 baseUrl += vfPage + '?token='+token+'&&'+'language='+primaryLanguageCode;
                 Opty.Payment_Request_Url__c = baseUrl;
                 Opty.Payment_Request_Token__c = token;
                 Opty.Payment_Request_Token_Status__c = 'Valid';
                OppNtpListUpdate.add(opty);
            }
            update OppNtpListUpdate;
            for(ServiceContract sctem : ScNtpList){
                try{
                    SendEmail(emailTemplateNtp,owcc.Address,sctem.ContactId,sctem.Opportunity__c, true);
                }
                catch(system.EmailException ex){}
            }
        }catch(system.EmailException ex){}
    }
    public void SendEmailSCPto(List<ServiceContract> ScPtoList){
        try{
            
            for(ServiceContract sctem1 :ScPtoList){
                OppPtoIds.add(sctem1.Opportunity__c);
            }
            OppListPto =[Select id,
                         Payment_Request_Url__c,
                         Payment_Request_Token_Status__c,
                         Payment_Request_Contact_Role_Id__c,
                         (Select Id,
                          Role,
                          ContactId,
                          Contact.Id,
                          Contact.FirstName,
                          Contact.LastName,
                          Contact.Email,
                          Contact.Phone,
                          Contact.Contact_Number__c,
                          Contact.MailingStreet,
                          Contact.MailingCity,
                          Contact.MailingState,
                          Contact.MailingPostalCode,
                          Contact.Preferred_Language__c,
                    	  IsPrimary
                          from OpportunityContactRoles                        
                         )
                         from Opportunity where Id IN:OppPtoIds
                        ];
            for (Opportunity opptem1 : OppListPto){
                OppPtoMap.put(opptem1.Id,opptem1);
            }
            for (ServiceContract sctem1 : ScPtoList){
                String baseUrl = Sf.settingsService.getString(Constants.RequestPaymentBaseUrl);
                if (!baseUrl.endsWith('/')) {baseUrl += '/';
                                            }   
                String token = generateVerificationToken();
                //baseUrl += vfPage + '?token=' + token
                String PrimaryLanguage ='English';
                Opportunity Opty = OppPtoMap.get(sctem1.Opportunity__c);
                for (OpportunityContactRole optyRole : Opty.OpportunityContactRoles) {
                    if(optyRole.ContactId == sctem1.ContactId && optyRole.Role == 'Billing Contact' ){
                        opty.Payment_Request_Contact_Role_Id__c = optyRole.Id;
                        ptoRoleId = true;
                    }
                     if(optyRole.IsPrimary==true){
                         PrimaryLanguage= optyRole.contact.Preferred_Language__c;
                     }
                }
                if (ptoRoleId != true){
                    OpportunityContactRole ptotemp = new OpportunityContactRole();
                    ptotemp.ContactId = sctem1.ContactId;
                    ptotemp.OpportunityId = sctem1.Opportunity__c;
                    ptotemp.Role = 'Billing Contact';
                    insert ptotemp;
                    Opty.Payment_Request_Contact_Role_Id__c = ptotemp.Id;
                    
                }
                String primaryLanguageCode= PrimaryLanguage=='Spanish'?'es':'en';
                baseUrl += vfPage + '?token='+token+'&&'+'language='+primaryLanguageCode;
                opty.Payment_Request_Url__c = baseUrl;
                opty.Payment_Request_Token__c = token;
                opty.Payment_Request_Token_Status__c ='Valid';
                PtoListUpdate.add(opty);
            }
            Update PtoListUpdate;
            
            for (ServiceContract sctem1 : ScPtoList){
                try{
                    SendEmail(emailTemplatePto,owcc.Address,sctem1.ContactId ,sctem1.Opportunity__c, true);
                }
                catch(System.EmailException ex){}
            }
            checkptosend = true;
        }
        catch(System.EmailException ex){}       
    }
    
    private void sendMailPosigenSalesPerson(EmailTemplate PosigenCreditPassPartner, id whatId, string salesEmail,id OwnerId, contact con){
     
        Messaging.SingleEmailMessage msg1 = New Messaging.SingleEmailMessage();
        msg1.setTemplateId(PosigenCreditPassPartner.Id);
        msg1.setCcAddresses(new string[] {'credit@sunrun.com'});
        msg1.setTargetObjectId(con.id);
        msg1.setOrgWideEmailAddressId(owea.Id);	
        msg1.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {msg1});
      
    }
    
   
 public void SendEmailCredit(List<Customer_Credit__c> CcObj, Map<String,Id> CreditOppMap, Map<Id,Customer_Credit__c> TriggerOldMap){
    
        try{
            for (Id OppId :CreditOppMap.values()){
                OppCreditIds.add(OppId);
            }
            
            OppListCredit =[
                Select
                id,
                AccountId,
                Payment_Request_Url__c,
                Payment_Request_Token_Status__c,
                Payment_Request_Contact_Role_Id__c,
                Deal_id__c,
                Sales_Representative__r.Email,
                 SalesOrganizationName__c,
               ownerId,             
                (
                    select
                    Id,
                    Role,
                    ContactId,
                    Contact.Id,
                    Contact.FirstName,
                    Contact.LastName,
                    Contact.Email,
                    Contact.Phone,
                    Contact.Contact_Number__c,
                    Contact.MailingStreet,
                    Contact.MailingCity,
                    Contact.MailingState,
                    Contact.MailingPostalCode,
                    Contact.Preferred_Language__c,
                    IsPrimary
                    from OpportunityContactRoles                        
                )
                from Opportunity
                where Id IN:OppCreditIds
            ];
            
            String PrimaryLanguage ='English';
            for (Opportunity opptem2 : OppListCredit){
                OppCreditMap.put(opptem2.Id,opptem2);
            }
            for (Customer_Credit__c cctem : CcObj){
                String baseUrl = Sf.settingsService.getString(Constants.RequestPaymentBaseUrl);
                if(!baseUrl.endsWith('/')){
                    baseUrl += '/';
                }  
               Opportunity Opty = OppCreditMap.get(CreditOppMap.get(cctem.Deal_Id__c));
               for (OpportunityContactRole optyRole : Opty.OpportunityContactRoles) {
                    if(optyRole.ContactId == cctem.Contact__c && optyRole.Role == 'Credit Contact'){
                        opty.Payment_Request_Contact_Role_Id__c = optyRole.Id;creditRoleId = true;
                    }
                   //checking the optycontactrole is primary, then assign the preferred language 
                    if(optyRole.IsPrimary==true)
                    {
                       PrimaryLanguage= optyRole.Contact.Preferred_Language__c;
                       
                    }
                   
                }
                String token = generateVerificationToken();
                //adding primary language in payment url
                 String primaryLanguageCode= PrimaryLanguage=='Spanish'?'es':'en';
                baseUrl += vfPage + '?token='+token+'&&'+'language='+primaryLanguageCode;
                Opty.Payment_Request_Url__c = baseUrl;
                Opty.Payment_Request_Token__c = token;
                Opty.Payment_Request_Token_Status__c = 'Valid';
                
                try{
                    if (creditRoleId != true){
                        OpportunityContactRole cctemp = new OpportunityContactRole();
                        cctemp.ContactId = cctem.Contact__c;
                        cctemp.OpportunityId = OppCreditMap.get(CreditOppMap.get(cctem.Deal_Id__c)).Id;
                        cctemp.Role = 'Credit Contact';
                        insert cctemp;
                        Opty.Payment_Request_Contact_Role_Id__c = cctemp.Id;
                    }
                }
                catch(System.DmlException e){}
                OppListCreditUpdate.add(opty);
            }
            Update OppListCreditUpdate;
            
            for(Customer_Credit__c cctem1 : CcObj){
                               
                if (cctem1.Deal_Id__c != null ){
                    cctem1.Sales_Rep_Email_Oppty__c =  OppCreditMap.get(CreditOppMap.get(cctem1.Deal_Id__c)).Sales_Representative__r.Email;
                   
                }
                //adding logic to send email for posigen customer and salesrep
                 string salesOrgName =  OppCreditMap.get(CreditOppMap.get(cctem1.Deal_Id__c)).SalesOrganizationName__c;
                 string salesRepEmail= OppCreditMap.get(CreditOppMap.get(cctem1.Deal_Id__c)).Sales_Representative__r.Email;
                 Id OwnerId = OppCreditMap.get(CreditOppMap.get(cctem1.Deal_Id__c)).ownerId;
                 Id whatId= OppCreditMap.get(CreditOppMap.get(cctem1.Deal_Id__c)).Id;
                if(cctem1.Credit_Email_Sent__c!=true){
                    if(salesOrgName==Label.PosigenID){
                        Contact con = new Contact();
                        con.FirstName = cctem1.First_Name__c;
                        con.LastName = cctem1.Last_Name__c;
                        con.Email = salesRepEmail;
                        con.AccountId = OppCreditMap.get(CreditOppMap.get(cctem1.Deal_Id__c)).AccountId;
                        insert con;
                        CreditCustomerTemplate=PosigenCreditPassCustomer.id;
                        sendMailPosigenSalesPerson(PosigenCreditPassPartner,whatId,salesRepEmail,OwnerId, con);
                        cctem1.Credit_Email_Sent__c=true;
                         delete con;
                    }
                }
                if(cctem1.Sunrun_Credit_Status__c == 'PASS' && TriggerOldMap.get(cctem1.Id).Sunrun_Credit_Status__c != 'PASS' && salesOrgName!=Label.PosigenID ){
                    CreditCustomerTemplate  = PrimaryLanguage=='Spanish'? CreditPassCustomer_Spanish.id:CreditPassCustomer.id ;
                   
                }
                if(cctem1.Sunrun_Credit_Status__c == 'CPASS' && TriggerOldMap.get(cctem1.Id).Sunrun_Credit_Status__c != 'CPASS'  
                   && ((Integer.valueOf(cctem1.Fico__c) > 679  &&  Integer.valueOf(cctem1.Fico__c) < 700)) && salesOrgName!=Label.PosigenID){
                       //&& (cctem1.Fico_Number__c > 679.00  && cctem1.Fico_Number__c < 700))
                       CreditCustomerTemplate  = PrimaryLanguage=='Spanish'? CreditCPassCustomer_Spanish.id: CreditCPassCustomer.Id;   
                   }
                       
                try{
                    Contact con1 = new Contact();
                    con1.FirstName = cctem1.First_Name__c;
                    con1.LastName = cctem1.Last_Name__c;
                    con1.Email = cctem1.Customer_Email__c;
                    con1.AccountId = OppCreditMap.get(CreditOppMap.get(cctem1.Deal_Id__c)).AccountId;
                    insert con1;
                    Messaging.SingleEmailMessage msg1 = New Messaging.SingleEmailMessage();
                    system.debug('CreditCustomerTemplate>>' +  CreditCustomerTemplate);
                    msg1.setTemplateId(CreditCustomerTemplate);
                    msg1.setCcAddresses(new string[] {'credit@sunrun.com'});
                    msg1.setTargetObjectId(con1.Id);
                    msg1.setWhatId(OppCreditMap.get(CreditOppMap.get(cctem1.Deal_Id__c)).Id);
                    msg1.setOrgWideEmailAddressId(owea.Id);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {msg1});
                    delete con1;
                    cctem1.Email_sent_with_ACH_Link__c = true;
                }
                catch(system.DmlException e){}
                } 
        }
        catch(System.EmailException ex){}
    }



}