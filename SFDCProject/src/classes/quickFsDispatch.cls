public with sharing class quickFsDispatch 
{
    public Case caseRec;
    public List<qFsDispWrapper> qFsDispTemplates = new List<qFsDispWrapper>();
    public String dispPhase {get;set;}
    public String dispState {get;set;}
    public String dispConstraint {get;set;}
    public String dispInstructions {get;set;}
    public String dispFinanceResponsibility {get;set;}
     public String dispBillTo {get;set;}
    public Boolean dispDontEmail {get;set;}
    public Boolean dispDontSurvey {get;set;}
       
    public quickFsDispatch(ApexPages.StandardController stdController) 
    {
        this.caseRec = (Case)stdController.getRecord();

    }

    public class qFsDispWrapper
    {
        public FS_Dispatch_Template__c qFsDispTemplateRec{get; set;}
        public Boolean recSelected {get; set;}

        public qFsDispWrapper(FS_Dispatch_Template__c qFsDispTemplate)
        {
            qFsDispTemplateRec = qFsDispTemplate;
            recSelected = false;
        }
    }

    public List<qFsDispWrapper> getqFsDispTemplates() 
    {
        if (qFsDispTemplates == null || qFsDispTemplates.size() <= 0)
        {
            FS_Dispatch_Template__c[] qFsDispTemplateList;
            qFsDispTemplateList = [SELECT Financial_Responsibility__c, ConnectionReceivedId,ConnectionSentId,FS_Dispatch_Constraint__c,
                                   FS_Dispatch_Instructions__c,FS_Dispatch_Phase__c,FS_Dispatch_State__c,Don_t_send_dispatch_email_to_customer__c,
                                   Do_Not_Send_Survey__c,Id,Name,Bill_To__c FROM FS_Dispatch_Template__c];
            
            for(FS_Dispatch_Template__c qFsDispTemplateRec : qFsDispTemplateList)
            {
                qFsDispTemplates.add(new qFsDispWrapper(qFsDispTemplateRec));
            }    
        }
        return qFsDispTemplates;
    }

    public PageReference GetSelectedTemplate()
    {
        dispPhase = '';
        dispState = '';
        dispConstraint = '';
        dispInstructions = '';
        dispFinanceResponsibility = '';
 
        for(qFsDispWrapper qFsDispTemplateWrapperRec : qFsDispTemplates)
        {
            if(qFsDispTemplateWrapperRec.recSelected == true)
            {
                dispPhase = qFsDispTemplateWrapperRec.qFsDispTemplateRec.FS_Dispatch_Phase__c;
                dispState = qFsDispTemplateWrapperRec.qFsDispTemplateRec.FS_Dispatch_State__c;
                dispConstraint = qFsDispTemplateWrapperRec.qFsDispTemplateRec.FS_Dispatch_Constraint__c;
                dispInstructions = qFsDispTemplateWrapperRec.qFsDispTemplateRec.FS_Dispatch_Instructions__c;
                dispFinanceResponsibility =  qFsDispTemplateWrapperRec.qFsDispTemplateRec.Financial_Responsibility__c;
                dispBillTo = qFsDispTemplateWrapperRec.qFsDispTemplateRec.Bill_To__c;
                dispDontEmail = qFsDispTemplateWrapperRec.qFsDispTemplateRec.Don_t_send_dispatch_email_to_customer__c;
                dispDontSurvey = qFsDispTemplateWrapperRec.qFsDispTemplateRec.Do_Not_Send_Survey__c;
                
                break;
            }
        }
        return null;
    }
    
    public PageReference createFsDispatch()
    {
        try
        {
            String dispatchTo = null, accessInfo = '';
             
            Case caseRec = [Select Id,Service_Contract__c,Service_Contract_Event__c, Generation_Asset__c,Generation_Asset__r.Installer__c,FS_Financial_Resp__c,Generation_Asset__r.Home_Address__c,Generation_Asset__r.City__c,Generation_Asset__r.State__c,Generation_Asset__r.zip__c from Case where Id = :caseRec.Id];
            
            Service_Contract_Partner_Rel__c partnerRel;
            if(caseRec != null && caseRec.Service_Contract__c != null){
                List<Service_Contract_Partner_Rel__c> partnerList = [Select Id, type__c, Account__c from Service_Contract_Partner_Rel__c where 
                                                                        ServiceContract__c =:caseRec.Service_Contract__c and type__c = 'Install' 
                                                                        and Account__c != null];
                System.debug('partnerList: ' + partnerList);
                if(partnerList != null && !partnerList.isEmpty()){
                    partnerRel = partnerList[0];
                    Contact[] contList = [Select Id from Contact where AccountId = :partnerRel.Account__c and Contact_Role__c = 'FS Point of Contact' limit 1];
                    if (contList.size() > 0)
                    {
                        dispatchTo = contList[0].Id;
                    } 
                }
            }
                        
           
            
            if (caseRec.Generation_Asset__c != null)
            {
                if (caseRec.Generation_Asset__r.Installer__c != null)
                {
                    Contact[] contList = [Select Id from Contact where AccountId = :caseRec.Generation_Asset__r.Installer__c and Contact_Role__c = 'FS Point of Contact' limit 1];
                    if (contList.size() > 0)
                    {
                        dispatchTo = contList[0].Id;
                    }
                }

            }
            FS_Dispatch__c dispRec = new FS_Dispatch__c();
                        
            dispRec.FS_Parent_Case__c = caseRec.Id;
            dispRec.FS_Dispatch_Phase__c = dispPhase;
            dispRec.FS_Dispatch_State__c = dispState;
            dispRec.FS_Dispatch_Constraint__c = dispConstraint;
            dispRec.FS_Dispatch_Instructions__c = dispInstructions;
            
            dispRec.FS_Generation_Asset__c = caseRec.Generation_Asset__c;
            dispRec.FS_Service_Contract__c = caseRec.Service_Contract__c;
            dispRec.FS_Service_Contract_Event__c = caseRec.Service_Contract_Event__c;
            dispRec.FS_Dispatched_By__c = UserInfo.getUserId();
            if (caseRec.Generation_Asset__c != null)
            {
                dispRec.FS_Dispatch_Partner__c = caseRec.Generation_Asset__r.Installer__c;
            }
            
            if (caseRec.Service_Contract__c != null && partnerRel != null)
            {
                dispRec.FS_Dispatch_Partner__c = partnerRel.Account__c;
            }
            
            dispRec.FS_Access_Info__c = accessInfo;
            dispRec.FS_Dispatch_To__c = dispatchTo;
            //dispRec.FS_Financial_Resp__c = caseRec.FS_Financial_Resp__c;
            dispRec.FS_Financial_Resp__c = dispFinanceResponsibility;
            dispRec.Bill_to__c = dispBillTo;
            if(dispDontEmail!=null)
            dispRec.Don_t_send_dispatch_email_to_customer__c = dispDontEmail;
            if(dispDontSurvey!=null)
            dispRec.Do_Not_Send_Survey__c = dispDontSurvey;
            insert dispRec;

            PageReference fsDispPage = new ApexPages.StandardController(dispRec).view();
            fsDispPage.setRedirect(true);
            return fsDispPage;
        }
        catch(Exception ex)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getMessage()));
            return null;
        }
    }
    
    public static testMethod void quickFsDispatchTest()
    {
        Test.startTest();
        
        Account accountRec = new Account();
        accountRec.Name = 'Test Class';
        insert accountRec;
 
        Contact contactRec = new Contact();
        contactRec.FirstName = 'DSG';
        contactRec.LastName = 'Test';
        contactRec.Contact_Role__c = 'FS Point of Contact';
        contactRec.AccountId = accountRec.Id;
        insert contactRec;
     
        Generation_Assets__c genAssetRec = new Generation_Assets__c();
        genAssetRec.Account_Name__c = accountRec.Id;
        genAssetRec.Installer__c = accountRec.Id;        genAssetRec.Customer_Contact__c = contactRec.Id;
        genAssetRec.Name = 'DSG Test';
        genAssetRec.Home_Address__c = '123 Main Street';
        genAssetRec.City__c = 'Los Gatos';
        genAssetRec.Zip__c = '95032';
        insert genAssetRec;
 
        Case caseRec = new Case();
        caseRec.AccountId = accountRec.Id;
        caseRec.ContactId = contactRec.Id;
        caseRec.Generation_Asset__c = genAssetRec.Id;
        caseRec.Origin = 'Internal';
        caseRec.Status = 'Open';
        caseRec.Reason = 'Metering';
        caseRec.Subject = 'test case';
        insert caseRec;
        
        ApexPages.StandardController stdCont = new ApexPages.StandardController(caseRec);
        quickFsDispatch qFsDispTestController = new quickFsDispatch(stdCont);
 
        List<qFsDispWrapper> qFsDispTemplatesList = qFsDispTestController.getqFsDispTemplates();
        for(qFsDispWrapper qFsDispWrapperRec : qFsDispTemplatesList)
        {
            qFsDispWrapperRec.recSelected = true;
            break;
        }
        qFsDispTestController.GetSelectedTemplate();
        qFsDispTestController.createFsDispatch();
        
        qFsDispTestController.caseRec = null;
        qFsDispTestController.createFsDispatch();
        
        Test.stopTest();
    }
}