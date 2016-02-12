@isTest(SeeAllData=true)
public with sharing class Test_ServiceContractQuickCase {
     public static testMethod void quickCaseTest(){
        Test.startTest();
        
        Account accountRec = new Account();
        accountRec.Name = 'Test Class';
        insert accountRec;
 
        Contact contactRec = new Contact();
        contactRec.FirstName = 'DSG';
        contactRec.LastName = 'Test';
        contactRec.AccountId = accountRec.Id;
        insert contactRec;
     
        ServiceContract scObjRec = new ServiceContract();
        scObjRec.AccountId = accountRec.Id;
        scObjRec.contactId = contactRec.Id;
        scObjRec.Name = 'DSG Test';
        //scObjRec.Home_Address__c = '123 Main Street';
        //scObjRec.City__c = 'Los Gatos';
        //scObjRec.Zip__c = '95032';
        insert scObjRec;
 
        ApexPages.StandardController stdCont = new ApexPages.StandardController(scObjRec);
        ServiceContractQuickCase qCaseTestController = new ServiceContractQuickCase(stdCont);      
        qCaseTestController.getCaseReasons();
        qCaseTestController.srchCaseReason = '---All---';
        qCaseTestController.fsTicket = '';
    //  ServiceContractQuickCase.qCaseWrapper qCaseWrapper=new ServiceContractQuickCase.qCaseWrapper();
        Quick_Case_Template__c qct=new Quick_Case_Template__c();
        ServiceContractQuickCase.qCaseWrapper qwrapper=new ServiceContractQuickCase.qCaseWrapper(qct);
        List<ServiceContractQuickCase.qCaseWrapper> qCaseTemplates = qCaseTestController.getqCaseTemplates();
        qCaseTestController.refreshTemplates();
        qCaseTestController.sortField = 'Case_Reason__c';
//      qCaseTestController.doSort();
        
        for(ServiceContractQuickCase.qCaseWrapper qCaseWrapperRec : qCaseTemplates)
        {
            qCaseWrapperRec.recSelected = true;
            qCaseTemplates.add(qCaseWrapperRec);
            break;
            qCaseWrapperRec.recSelected = false;
        }         
               
        qCaseTestController.qCaseTemplates = qCaseTemplates;
        qCaseTestController.GetSelectedTemplate();
        qCaseTestController.createCase();        

        qCaseTestController.fsTicket = 'FST';
        qCaseTestController.getCaseReasons();
        qCaseTestController.srchCaseReason = 'Metering';
        qCaseTemplates = qCaseTestController.getqCaseTemplates();
        qCaseTestController.refreshTemplates();        
        qCaseTestController.sortField = 'Case_Reason__c';
        //qCaseTestController.doSort();
        for(ServiceContractQuickCase.qCaseWrapper qCaseWrapperRec : qCaseTemplates)
        {
            qCaseWrapperRec.recSelected = true;
             qCaseTemplates.add(qCaseWrapperRec);
            break;
        }
        qCaseTestController.qCaseTemplates = qCaseTemplates;
        qCaseTestController.GetSelectedTemplate();
        qCaseTestController.recTypeName='FS Ticket';
        qCaseTestController.createCase();
       

        Test.stopTest();
    }
    
}