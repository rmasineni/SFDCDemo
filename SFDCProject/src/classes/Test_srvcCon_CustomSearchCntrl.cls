@ isTest (seeAllData = true)
public class Test_srvcCon_CustomSearchCntrl {
     
    public static testmethod void unitTestOne(){
       String partnerAccountId = PartnerDetail__c.getValues('ApexTestAccount').PartnerAccountId__C;
        String partnerContactId = PartnerDetail__c.getValues('ApexTestAccount').PartnerContactId__C;
        String partnerSalesRepId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
        String salesRepEmail = PartnerDetail__c.getValues('ApexTestAccount').PartnerContactEmail__C;
        
        Account customerAccount;
        Contact primaryContact;
        Contact secondaryContact;
        Opportunity opprtunityObj;
        
        Proposal__C proposalObj = UnitTest_ProposalUtil.createProposal('1324 Fremont St CA', 'PFirstName12', 'PLastName12', 
                                            'PrimaryCustomer@gmail.com', '1324 Fremont St CA','P124124123-I', 
                                            23532, 23, 'Mode-1', salesRepEmail, partnerAccountId, partnerAccountId,
                                            customerAccount, primaryContact, secondaryContact, opprtunityObj);
        proposalObj.stage__c = EDPUtil.SR_OPS_APPROVED;
        insert proposalObj;  
       
         system.debug('>>>>proposalObj' +  proposalObj);
         Opportunity opty = [Select Id, name, Install_Branch_Id__c, accountId,account.Name, Install_Partner__c,contact__r.id FROM Opportunity where Id = :proposalObj.Opportunity__c];
         Account acc = new account();
         acc.id = opty.accountId;
         acc.name = opty.account.Name;
        Contact cnt = TestPRMLibrary.insertContact('SrvcConsoleContact', 
                                            'Residential', 
                                            'SrvcLastName',
                                            'srvccontact@yopmail.com');
       // cnt = [select id,name from contact where id = :contactID];
        
         ServiceContract sc = new ServiceContract();
            sc.accountId = acc.Id;
            // scAssetRec.contactId = contactRec.Id;  
            sc.Proposal__c = proposalObj.id;
            sc.Opportunity__c = opty.Id;
            insert sc;  
        RecordType mileStoneRecType = [Select Id from RecordType Where SobjectType = 'Case' And DeveloperName = 'Milestone_Proof'];
        List<Case> listCase = new List<Case>();
        Case cases = new Case();
        cases.RecordTypeId = mileStoneRecType.Id;
        cases.AccountId = acc.id;
        cases.ContactId = cnt.id;
        cases.Milestone_Proof_Type__c = 'M1 Proof';
        cases.Status = 'Request Approval';
        cases.Origin = 'Install Partner'; 
        cases.Reason = 'Documentation';
        cases.Description = 'Milestone Proof Submitted';
        cases.Subject = 'Milestone Proof Submitted';
        cases.First_Response_Updated__c = true;
        cases.First_Response_Date_Time__c = Date.Today();
        cases.Service_Contract__c = sc.Id;
        listCase.add(cases);
        //
        insert listCase; 
        

        Test.startTest();
        
        // Account Search
        PageReference pageRef = Page.srvcCon_CustomSearch;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('objType', 'Account');
        ApexPages.currentPage().getParameters().put('RecId', acc.Id);
        string BaseURL1 = ApexPages.currentPage().getUrl();
        system.debug('Base URl' + BaseURL1);
        srvcCon_CustomSearchController customSearchAcnt = new srvcCon_CustomSearchController(); 
       
        
        customSearchAcnt.searchString = acc.name;
        customSearchAcnt.getRedirectColNames();
        customSearchAcnt.searchsObject();
        customSearchAcnt.sObjLst = customSearchAcnt.accSearchList;
        customSearchAcnt.getSobjRecords();
        
        //Contact Search
        ApexPages.currentPage().getParameters().put('objType', 'Contact');
        ApexPages.currentPage().getParameters().put('RecId', cnt.Id);
        string BaseURL2 = ApexPages.currentPage().getUrl();
        system.debug('Base URl' + BaseURL2);
        srvcCon_CustomSearchController customSearchCnt = new srvcCon_CustomSearchController();  
        customSearchCnt.searchString = cnt.name;
        customSearchCnt.getRedirectColNames();
        customSearchCnt.searchsObject();
        
        //Case Search
        ApexPages.currentPage().getParameters().put('objType', 'Case');
        ApexPages.currentPage().getParameters().put('RecId', cases.Id);
        string BaseURL3 = ApexPages.currentPage().getUrl();
        system.debug('Base URl' + BaseURL3);
        srvcCon_CustomSearchController customSearchCase = new srvcCon_CustomSearchController(); 
        customSearchCase.searchString = cases.Casenumber;
        customSearchCase.getRedirectColNames();
        customSearchCase.searchsObject();
        
        // Opportunity Search
        ApexPages.currentPage().getParameters().put('objType', 'Opportunity');
        ApexPages.currentPage().getParameters().put('RecId', opty.Id);
        string BaseURL4 = ApexPages.currentPage().getUrl();
        system.debug('Base URl' + BaseURL4);
        srvcCon_CustomSearchController customSearchOpty = new srvcCon_CustomSearchController(); 
        customSearchOpty.searchString = opty.Name;
        customSearchOpty.getRedirectColNames();
        customSearchOpty.searchsObject();
        
        //ServiceContract Search
        ApexPages.currentPage().getParameters().put('objType', 'ServiceContract');
        ApexPages.currentPage().getParameters().put('RecId', sc.Id);
        string BaseURL5 = ApexPages.currentPage().getUrl();
        system.debug('Base URl' + BaseURL5);
        srvcCon_CustomSearchController customSearchSc = new srvcCon_CustomSearchController();   
        customSearchSc.searchString = sc.name;
        customSearchSc.getRedirectColNames();
        customSearchSc.searchsObject();
        
        test.stopTest();
  
     }
            
}