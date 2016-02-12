@ isTest (seeAllData = true)
public class Test_srvcCon_RelatedObjCntrl {
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
        
        system.debug('proposalObj' +  proposalObj);
        Opportunity opty = [Select Id, name, Install_Branch_Id__c, accountId,account.Name,account.owner.id, Install_Partner__c,contact__r.id,StageName,Owner.Name
                            FROM Opportunity where Id = :proposalObj.Opportunity__c];
        Account acc = new account();
        
        if(opty.id != null)
            acc = [select id , name, owner.name from account where Id =:opty.AccountId ];
        list<sObject> sObjList = new list<sObject>();
        sObjList.add(acc);
        
        // Account Data---------------------
        list<String> HeaderValue = new list<String>{'Account Name','Phone','Owner'};
            test.startTest();
        srvcCon_RelatedObjCompController relatedObjComp = new srvcCon_RelatedObjCompController();
        if(sObjList.size()  > 0) {
            relatedObjComp.accList = sObjList;
            relatedObjComp.objectType = 'Account';
            relatedObjComp.getObjectList('Account',sObjList);
            relatedObjComp.objTitle = 'Accounts';
            relatedObjComp.getParentObjCols();     
            relatedObjComp.getRedirectColNames();
            //
            relatedObjComp.objHeaderValue = HeaderValue;
            relatedObjComp.ParentObjLst();
        }     
        test.stopTest();
    } 
    
    public static testmethod void unitTestTwo(){
        String partnerAccountId = PartnerDetail__c.getValues('ApexTestAccount').PartnerAccountId__C;
        String partnerContactId = PartnerDetail__c.getValues('ApexTestAccount').PartnerContactId__C;
        String partnerSalesRepId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
        String salesRepEmail = PartnerDetail__c.getValues('ApexTestAccount').PartnerContactEmail__C;
        
        Account customerAccount;
        Contact primaryContact;
        Contact secondaryContact;
        Opportunity opprtunityObj;
        //Proposal Data
        Proposal__C proposalObj = UnitTest_ProposalUtil.createProposal('1324 Fremont St CA', 'PFirstName12', 'PLastName12', 
                                                                       'PrimaryCustomer@gmail.com', '1324 Fremont St CA','P124124123-I', 
                                                                       23532, 23, 'Mode-1', salesRepEmail, partnerAccountId, partnerAccountId,
                                                                       customerAccount, primaryContact, secondaryContact, opprtunityObj);
        proposalObj.stage__c = EDPUtil.SR_OPS_APPROVED;
        insert proposalObj;  
        
        system.debug('proposalObj' +  proposalObj);
        //Opty Data Setup
        Opportunity opty = [Select Id, name, Install_Branch_Id__c, accountId,account.Name,
                            account.owner.id, Install_Partner__c,contact__r.id,StageName,Owner.Name
                            FROM Opportunity where Id = :proposalObj.Opportunity__c];
        
        //Account Data Setup
        Account acc = new account();
        if(opty.id != null)
            acc = [select id , name, owner.name from account where Id =:opty.AccountId ];
        list<sObject> sObjList = new list<sObject>();
        
        Contact cnt = TestPRMLibrary.insertContact('SrvcConsoleContact', 
                                                   'Residential', 
                                                   'SrvcLastName',
                                                   'srvccontact@yopmail.com');
        
        //Service Contract Data Setup
        ServiceContract sc = new ServiceContract();
        sc.accountId = acc.Id; 
        sc.Proposal__c = proposalObj.id;
        sc.Opportunity__c = opty.Id;
        insert sc;  
        Reassignment__c SrvcTransfer = new Reassignment__c();
        SrvcTransfer.Service_Contract__c = sc.id;
        SrvcTransfer.Distressed__c = 'Yes';
        insert SrvcTransfer;
        RecordType mileStoneRecType = [Select Id from RecordType Where SobjectType = 'Case' And DeveloperName = 'Milestone_Proof'];
        List<Case> listCase = new List<Case>();
        
        //Case Data Setup
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
        insert listCase; 
        
        //FSD Data Setup
        FS_Dispatch__c fsd = new FS_Dispatch__c(); 
        fsd.FS_Service_Contract__c = sc.Id;
        fsd.Bill_To__c = 'Not Billable to Third Party';
        insert fsd;
        
        test.startTest();
        //Contact------------------------------------
        if(cnt.id != null)
            sObjList.add(cnt);
        
        list<String> HeaderValue = new list<String>{'Contact Name','Phone','Account Name', 'Owner Name'};
           

        srvcCon_RelatedObjCompController relatedObjComp = new srvcCon_RelatedObjCompController();
        
        if(sObjList.size()  > 0) {
            
            relatedObjComp.accList = sObjList;
            relatedObjComp.childRecrds = sObjList;
            relatedObjComp.objectType = 'Contact';
            relatedObjComp.childObjType = 'Contact';
            relatedObjComp.getObjectList('Contact',sObjList);
            relatedObjComp.objTitle = 'Contacts';
            relatedObjComp.getChildObjCols();
            relatedObjComp.getParentObjCols();
            relatedObjComp.getRecCount();
            relatedObjComp.sObj = relatedObjComp.childRecrds; 
            relatedObjComp.objHeaderValue = HeaderValue;
            
        }
        
        //Service COntract -------------------------  
        if(sc.id != null)
            sObjList.add(sc);
        if(sObjList.size()  > 0) {
            relatedObjComp.accList = sObjList;
            relatedObjComp.childRecrds = sObjList;
            relatedObjComp.objectType = 'ServiceContract';
            relatedObjComp.childObjType = 'ServiceContract';
            relatedObjComp.getObjectList('ServiceContract',sObjList);
            relatedObjComp.getChildObjCols();
            
        }
        
        //Opportunity -------------------------------------
        if(opty.id != null)
            sObjList.add(opty);
        
        if(sObjList.size()  > 0) {
            relatedObjComp.accList = sObjList;
            relatedObjComp.childRecrds = sObjList;
            relatedObjComp.objectType = 'Opportunity';
            relatedObjComp.childObjType = 'Opportunity';
            relatedObjComp.getObjectList('Opportunity',sObjList);
            relatedObjComp.getChildObjCols();
            
        }
        //Service Transfer ----------------------------
        if(SrvcTransfer.id != null)
            sObjList.add(SrvcTransfer);
        
        if(sObjList.size()  > 0) {
            relatedObjComp.accList = sObjList;
            relatedObjComp.childRecrds = sObjList;
            relatedObjComp.objectType = 'ServiceTransfer';
            relatedObjComp.childObjType = 'ServiceTransfer';
            relatedObjComp.getObjectList('ServiceTransfer',sObjList);
            relatedObjComp.getChildObjCols();
            
            
        }
        
        //Cases -------------------------------------   
        if(cases.id != null)
            sObjList.add(cases);
        
        if(sObjList.size()  > 0) {
            relatedObjComp.accList = sObjList;
            relatedObjComp.childRecrds = sObjList;
            relatedObjComp.objectType = 'Case';
            relatedObjComp.childObjType = 'Case';
            relatedObjComp.getObjectList('Case',sObjList);
            relatedObjComp.getChildObjCols();
            
        }
        
        //FS Dispatch -------------------------------------   
        if(fsd.id != null)
            sObjList.add(fsd);
        
        
        if(sObjList.size()  > 0) {
            relatedObjComp.accList = sObjList;
            relatedObjComp.childRecrds = sObjList;
            relatedObjComp.objectType = 'FSDispatch';
            relatedObjComp.childObjType = 'FSDispatch';
            relatedObjComp.getObjectList('FSDispatch',sObjList);
            relatedObjComp.getChildObjCols();
            
            
        }
        test.stopTest();
    }
    
}