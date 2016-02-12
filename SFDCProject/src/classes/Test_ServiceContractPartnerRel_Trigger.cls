@isTest(SeeAllData=true)
private class Test_ServiceContractPartnerRel_Trigger {

    static testMethod void Test_ServiceContractPartnerRel_Trigger() {
        UnitTest_ProposalUtil.disableExternalServices();
        Account a = New Account(Name = 'TestAccount2');
        insert a;
        
        Opportunity oppty = new Opportunity();
        oppty.AccountId = a.id;
        oppty.Name = 'NewCC Test';
        oppty.StageName = 'Qualified';
        oppty.CloseDate = Date.Today().addDays(18);
        insert oppty;
        
        Proposal__c ProposalObj= UnitTest_ServiceContractUtil.createProposal(oppty.id);
        
        
        ServiceContract sc = New ServiceContract(Name = 'Testsc',AccountId =a.Id,Legacy_Asset_Number__c = '12222006');
        insert sc; 
        
         Test.startTest(); 
        project__c project = new project__c ( name = 'projectname', Account__c= a.id , Opportunity__c= oppty.id, Proposal__c = ProposalObj.id, service_contract__c = sc.id); 
        insert project; 
       
        Phase__c phase = new Phase__c(name='Phasename', Project__c=project.Id);
        insert phase;
        Task__c tasklocal = new Task__c(name='Prepare Electrical Subk', Project_Name__c =project.id, Phase__c = phase.Id,category__c='Optional',status__c ='OPEN');
        insert tasklocal ;
        Task__c tasklocal2 = new Task__c(name='Get Electrical Subk Signed', Project_Name__c =project.id, Phase__c = phase.Id,category__c='Optional',status__c ='OPEN');
        insert tasklocal2 ;
        Task__c tasklocal1 = new Task__c(name='Prepare Solar Waterproofing Subk', Project_Name__c =project.id, Phase__c = phase.Id,category__c='Optional',status__c ='OPEN');
        insert tasklocal1 ;
        Task__c tasklocal3 = new Task__c(name='Get Solar Waterproofing Subk Signed', Project_Name__c =project.id, Phase__c = phase.Id,category__c='Optional',status__c ='OPEN');
        insert tasklocal3 ;
        
        Task__c tasklocal4 = new Task__c(name='Prepare Other Subk', Project_Name__c =project.id, Phase__c = phase.Id,category__c='Optional',status__c ='OPEN');
        insert tasklocal4 ;
        
      //Task__c tasklocal5 = new Task__c(name='Get Other Subk Signed', Project_Name__c =project.id, Phase__c = phase.Id,category__c='Optional',status__c ='OPEN');
      //insert tasklocal5 ;
        
        Service_Contract_Partner_Rel__c scpr = New Service_Contract_Partner_Rel__c(Account__c=a.Id, ServiceContract__c = sc.Id, Type__c = 'Install');
        insert  scpr;  
        update scpr;
        Service_Contract_Partner_Rel__c scpr1 = New Service_Contract_Partner_Rel__c(Account__c=a.Id, ServiceContract__c = sc.Id, Type__c = 'Sales');
        insert  scpr1;     
        Service_Contract_Partner_Rel__c scpr3 = New Service_Contract_Partner_Rel__c(Account__c=a.Id, ServiceContract__c = sc.Id, Type__c = 'Electrical Subcontractor');
        insert  scpr3; 
        Service_Contract_Partner_Rel__c scpr2 = New Service_Contract_Partner_Rel__c(Account__c=a.Id, ServiceContract__c = sc.Id, Type__c = 'Solar Waterproofing Subcontractor');
        insert  scpr2; 
        Service_Contract_Partner_Rel__c scpr4 = New Service_Contract_Partner_Rel__c(Account__c=a.Id, ServiceContract__c = sc.Id, Type__c = 'Other Subcontractor');
        insert  scpr4; 
        delete scpr4;
        Test.stopTest(); 
        
    }
}