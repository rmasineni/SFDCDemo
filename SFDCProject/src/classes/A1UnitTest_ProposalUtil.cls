@isTest(SeeAllData=true)
public class A1UnitTest_ProposalUtil {
	
	//Remove the comments after testing 
	public static testmethod void testSRAttachmentWrapper(){
		UnitTest_ProposalUtil.disableExternalServices();
        Opportunity optyObj1 = TestPRMLibrary.insertOpportunity('ResidentialAccount-01', 'Residential',
                                                                'ResOpty-01', 'Platinum');  
        List<Proposal__C> proposalList = new List<Proposal__C>();
        proposalList.add(UnitTest_ProposalUtil.getProposalObject(''+ optyObj1.Id, 'H77A13CD6KDRRF1:IIC-I', 12345, 10 ,'Mode-01', 'test01@gmail.com'));
        proposalList.add(UnitTest_ProposalUtil.getProposalObject(''+ optyObj1.Id, 'Proposal-02', 22346, 20 ,'Mode-02', 'test02@gmail.com'));
        insert proposalList;        

        String envelopId1 = '4335SDFF-43643-GSGA346';
        String proposalIdStr = '' + proposalList[0].id;
		SR_Attachment__c srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Customer Agreement', envelopId1, proposalIdStr, 
                                                                                    'TestFile01.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
        srAttachmentObj1.Parent_Proposal_Name__c = 'H77A13CD6KDRRF1:IIC-I';
        srAttachmentObj1.Wet_Sign_Status__c = EDPUtil.SIGNED;
        srAttachmentObj1.Partner_Signed__c = EDPUtil.COMPLETED;
        srAttachmentObj1.Customer_Signed__c = EDPUtil.COMPLETED;
        srAttachmentObj1.Document_Source__c = EDPUtil.PROPOSAL_TOOL_SOURCE;
        srAttachmentObj1.Wet_Sign_Status__c = EDPUtil.SR_COUNTERSIGNED;
        SRAttachmentWrapper wrapperObj = new SRAttachmentWrapper(srAttachmentObj1);
    }
	
	/**/
	//Working test method .... 
	public static testmethod void testWelcomeEmail2(){
        UnitTest_ProposalUtil.disableExternalServices();
        String strProposalApprovalLimit1 = Label.ProposalApprovalLimit1;
        if(strProposalApprovalLimit1 == null || strProposalApprovalLimit1 == ''){
            strProposalApprovalLimit1 = '15';
        }

        String partnerAccountId = PartnerDetail__c.getValues('EDPTestAccount').PartnerAccountId__C;
        String partnerContactId = PartnerDetail__c.getValues('EDPTestAccount').PartnerContactId__C;
        String partnerSalesRepId = PartnerDetail__c.getValues('EDPTestAccount').PartnerUserId__c;
        String salesRepEmail = PartnerDetail__c.getValues('EDPTestAccount').PartnerContactEmail__C;

        Account customerAccount;
        Contact primaryContact;
        Contact secondaryContact;
        Opportunity opprtunityObj;

        Decimal proposalLimit1 = Decimal.valueOf(strProposalApprovalLimit1);

        Proposal__C proposalObj1 = UnitTest_ProposalUtil.createProposal('1324 Fremont St CA', 'PFirstName12', 'PLastName12', 
                                            'PrimaryCustomer@gmail.com', '1324 Fremont St CA','P124124123-I', 
                                            23532, 23, 'Mode-1', salesRepEmail, partnerAccountId, partnerAccountId,
                                            customerAccount, primaryContact, secondaryContact, opprtunityObj);
        insert proposalObj1;    

        SR_Attachment__c srAttachmentObj0 = UnitTest_ProposalUtil.CreateSRAttachment('Utility Bill', '', ''+proposalObj1.Id, 
                                                                    'TestFile01.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
        insert  srAttachmentObj0;                                                       
        
        Opportunity optyObj1 = TestPRMLibrary.insertOpportunity('ResidentialAccount-02', 'Residential',
                                                                'ResOpty-02', 'Platinum');  
        
        Proposal__C proposalObj2 = UnitTest_ProposalUtil.createProposal('1524 Fremont St CA', 'PFirstName12', 'PLastName12', 
                                            'PrimaryCustomer@gmail.com', '1524 Fremont St CA','P224124123-I', 
                                            23532, 10, 'Mode-1', salesRepEmail, partnerAccountId, partnerAccountId,
                                            customerAccount, primaryContact, secondaryContact, opprtunityObj);
        proposalObj2.Original_Proposal_ID__c = proposalObj1.Id;
        proposalObj2.Revised_Proposal__c = true;
        insert proposalObj2;            

        opprtunityObj = [Select Id, name, accountId from Opportunity where id =:proposalObj2.Opportunity__c];
        customerAccount = [Select Id, name,(Select Id, name, email from Contacts) from Account where Id =:opprtunityObj.accountId];
        primaryContact = customerAccount.contacts[0];
        secondaryContact = customerAccount.contacts[1];
        
        String envelopId1 = '';
        String proposalIdStr = '' + proposalObj2.id;
        List<OpportunityContactRole> contactRolelist = new List<OpportunityContactRole>();
        OpportunityContactRole contactRoleObj = new OpportunityContactRole();
        contactRoleObj.ContactId = primaryContact.Id;
        contactRoleObj.OpportunityId = opprtunityObj.Id;
        contactRoleObj.Role = 'Homeowner';
        contactRoleObj.IsPrimary = true;
        contactRolelist.add(contactRoleObj);
        
        contactRoleObj = new OpportunityContactRole();
        contactRoleObj.ContactId = secondaryContact.Id;
        contactRoleObj.OpportunityId = opprtunityObj.Id;
        contactRoleObj.Role = 'Other';
        contactRolelist.add(contactRoleObj);
        insert contactRolelist;
        
        envelopId1 = '1335SDFF-43643-GSGA346';
        proposalIdStr = '' + proposalObj2.id;
        List<SR_Attachment__c> srAttachmentList = new List<SR_Attachment__c>();
        SR_Attachment__c srAttachmentObj1;
        
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Customer Agreement', envelopId1, proposalIdStr, 
                                                                    'TestFile01.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentList.add(srAttachmentObj1);

        envelopId1 = '2335SDFF-43643-GSGA346';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('EPC', envelopId1, proposalIdStr, 
                                                                    'TestFile02.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentList.add(srAttachmentObj1);

        envelopId1 = '5335SDFF-43643-GSGA341';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Utility Bill', envelopId1, proposalIdStr, 
                                                                    'TestFile03.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.WET_SIGNED;
        srAttachmentList.add(srAttachmentObj1);     

        envelopId1 = '7335SDFF-43643-GSGA342';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Large System Contract Approval Request', envelopId1, proposalIdStr, 
                                                                    'TestFile04.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentList.add(srAttachmentObj1);         
        
         List<User> userList = EDPUtil.getSRUserDetails();
        
        insert srAttachmentList;


        User defaultOpsUser = null;
        User defaultFinanceUser = null;
            for(User userObj : userList){
                if(defaultOpsUser == null && userObj.name == EDPUtil.USER_NAME_TEST){
                    defaultOpsUser = userObj;
                }
                if(defaultFinanceUser == null && userObj.name == EDPUtil.USER_NAME_TEST){
                    defaultFinanceUser = userObj;
                }
        
                if(userObj.name == EDPUtil.USER_NAME_SR_OPS){
                    defaultOpsUser = userObj;
                }           
                else if(userObj.name == EDPUtil.USER_NAME_SR_FINANCE){
                    defaultFinanceUser = userObj;
                }
            }
            
            Test.startTest();   
            
            Proposal__c proposalObj =  proposalObj2;
            proposalObj.Assigne__c = PartnerDetail__c.getValues('EDPTestAccount').PartnerUserId__c;
            EDPWebServices.submitProposal(proposalObj.Id);
            
            proposalObj.Assigne__c = defaultOpsUser.Id;
            update proposalObj;
            
                    
            proposalObj.Customer_SignOff_Date__c = Datetime.now();
            proposalObj.System_Size_Validated_by_SR_Ops__c = false;
            proposalObj.Stage__c = EDPUtil.SR_OPS_REVIEWED;
            update proposalObj;

            proposalObj.Assigne__c = defaultFinanceUser.Id;
            update proposalObj;
        
            System.debug('proposalObj.stage__c1: ' + proposalObj.stage__c);
            proposalObj.Stage__c = EDPUtil.CREDIT_APPROVED;
            update proposalObj;
            System.debug('proposalObj.stage__c2: ' + proposalObj.stage__c);
            
            proposalObj.Stage__c = EDPUtil.SR_OPS_APPROVED;
            proposalObj.Revised_Proposal__c = true;
            proposalObj.System_Size_Validated_by_SR_Ops__c = false;
            proposalObj.SR_Signoff__c = null;
            update proposalObj;     
            
            Set<Id> optyIds = new Set<Id>();
            optyIds.add(proposalObj.Opportunity__c);
            EDPUtil.getApprovedProposals(optyIds);
        
            srAttachmentList[0].Document_Source__c = EDPUtil.E_SIGN;
            srAttachmentList[1].Document_Source__c = EDPUtil.E_SIGN;
            srAttachmentList[2].Document_Source__c = EDPUtil.E_SIGN;
            srAttachmentList[3].Document_Source__c = EDPUtil.E_SIGN;
            update srAttachmentList;

            System.debug('proposalObj.stage__c3: ' + proposalObj.stage__c);
            proposalObj.System_Size_STC_DC__c = 1;
            proposalObj.Assigne__c = defaultOpsUser.Id;
            proposalObj.Stage__c = EDPUtil.SR_OPS_APPROVED;
            proposalObj.Submitted_By__c = PartnerDetail__c.getValues('EDPTestAccount').PartnerUserId__c;
            
            //System.debug('Start update2 ..');
            update proposalObj; 
            //System.debug('End update2 ..');
            
            //EDPUtil.getProposalObject(proposalObj.Id);            
            //EDPWebServices.sendWelcomeEmail(proposalObj.Id);
            //System.debug('Welcome Error1: ' + EDPUtil.processWelcomeEmailRequest(''+proposalObj.Id));
            
            //delete srAttachmentList;
            //System.debug('Welcome Error3: ' + EDPUtil.processWelcomeEmailRequest(''+proposalObj.Id));
            
            //System.runAs(defaultFinanceUser){
            //  Set<Id> opportunityIds = new Set<Id>();
            //  opportunityIds.add(opprtunityObj.Id);
            //  EDPUtil.cancelProposals(opportunityIds);
            //}

        Test.stopTest();    
    }


	//Remove the comments after testing 
    public static testmethod void testChangeOrder(){
		 UnitTest_ProposalUtil.disableExternalServices();
        String strProposalApprovalLimit1 = Label.ProposalApprovalLimit1;
        if(strProposalApprovalLimit1 == null || strProposalApprovalLimit1 == ''){
            strProposalApprovalLimit1 = '15';
        }

        String partnerAccountId = PartnerDetail__c.getValues('ApexTestAccount').PartnerAccountId__C;
        String partnerContactId = PartnerDetail__c.getValues('ApexTestAccount').PartnerContactId__C;
        String partnerSalesRepId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
        String salesRepEmail = PartnerDetail__c.getValues('ApexTestAccount').PartnerContactEmail__C;

        Account customerAccount;
        Contact primaryContact;
        Contact secondaryContact;
        Opportunity opprtunityObj;

        Decimal proposalLimit1 = Decimal.valueOf(strProposalApprovalLimit1);

        Proposal__C proposalObj2 = UnitTest_ProposalUtil.createProposal('1524 Fremont St CA', 'PFirstName12', 'PLastName12', 
                                            'PrimaryCustomer@gmail.com', '1524 Fremont St CA','P224124123-I', 
                                            23532, 23, 'Mode-1', salesRepEmail, partnerAccountId, partnerAccountId,
                                            customerAccount, primaryContact, secondaryContact, opprtunityObj);
        insert proposalObj2;            

        String envelopId1 = '1335SDFF-43643-GSGA346';
        String proposalIdStr = '' + proposalObj2.id;
        List<SR_Attachment__c> srAttachmentList = new List<SR_Attachment__c>();
        SR_Attachment__c srAttachmentObj1;
        
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Customer Agreement', envelopId1, proposalIdStr, 
                                                                    'TestFile01.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentList.add(srAttachmentObj1);

        envelopId1 = '2335SDFF-43643-GSGA346';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('EPC', envelopId1, proposalIdStr, 
                                                                    'TestFile02.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentList.add(srAttachmentObj1);

        envelopId1 = '5335SDFF-43643-GSGA341';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Utility Bill', envelopId1, proposalIdStr, 
                                                                    'TestFile03.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.WET_SIGNED;
        srAttachmentList.add(srAttachmentObj1);     

        envelopId1 = '7335SDFF-43643-GSGA342';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Large System Contract Approval Request', envelopId1, proposalIdStr, 
                                                                    'TestFile04.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentList.add(srAttachmentObj1);         
        
         List<User> userList = EDPUtil.getSRUserDetails();
        
        insert srAttachmentList;

        opprtunityObj = [Select Id, name, accountId from Opportunity where id =:proposalObj2.Opportunity__c];
        customerAccount = [Select Id, name,(Select Id, name, email from Contacts) from Account where Id =:opprtunityObj.accountId];
        primaryContact = customerAccount.contacts[0];
        secondaryContact = customerAccount.contacts[1];

        List<OpportunityContactRole> contactRolelist = new List<OpportunityContactRole>();
        OpportunityContactRole contactRoleObj = new OpportunityContactRole();
        contactRoleObj.ContactId = primaryContact.Id;
        contactRoleObj.OpportunityId = opprtunityObj.Id;
        contactRoleObj.Role = 'Homeowner';
        contactRoleObj.IsPrimary = true;
        contactRolelist.add(contactRoleObj);
        
        contactRoleObj = new OpportunityContactRole();
        contactRoleObj.ContactId = secondaryContact.Id;
        contactRoleObj.OpportunityId = opprtunityObj.Id;
        contactRoleObj.Role = 'Other';
        contactRolelist.add(contactRoleObj);
        insert contactRolelist;
        
        proposalObj2.System_Size_STC_DC__c = 10;
        update proposalObj2;

        User defaultOpsUser = null;
        User defaultFinanceUser = null;
            for(User userObj : userList){
                if(defaultOpsUser == null && userObj.name == EDPUtil.USER_NAME_TEST){
                    defaultOpsUser = userObj;
                }
                if(defaultFinanceUser == null && userObj.name == EDPUtil.USER_NAME_TEST){
                    defaultFinanceUser = userObj;
                }
        
                if(userObj.name == EDPUtil.USER_NAME_SR_OPS){
                    defaultOpsUser = userObj;
                }           
                else if(userObj.name == EDPUtil.USER_NAME_SR_FINANCE){
                    defaultFinanceUser = userObj;
                }
            }

            Proposal__c proposalObj =  proposalObj2;
            proposalObj.Assigne__c = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
            EDPWebServices.submitProposal(proposalObj.Id);
            proposalObj.Stage__c = EDPUtil.SUBMITTED;
            update proposalObj;
            
            Test.startTest();   

            Proposal__C proposalObj1 = UnitTest_ProposalUtil.createProposal('1324 Fremont St CA', 'PFirstName12', 'PLastName12', 
                                                'PrimaryCustomer@gmail.com', '1324 Fremont St CA','P124124123-I', 
                                                23532, 23, 'Mode-1', salesRepEmail, partnerAccountId, partnerAccountId,
                                                customerAccount, primaryContact, secondaryContact, opprtunityObj);
            
            proposalObj1.Opportunity__c = proposalObj2.Opportunity__c;
            proposalObj1.Original_Proposal_ID__c = proposalObj2.Id;
            System.debug('proposalObj1.Original_Proposal_ID__c: ' + proposalObj1.Original_Proposal_ID__c);
            proposalObj1.Change_Order__c = true;        
            insert proposalObj1;    
            System.debug('proposalObj1.Id: ' + proposalObj1.Id);
    
            SR_Attachment__c srAttachmentObj0 = UnitTest_ProposalUtil.CreateSRAttachment('Utility Bill', '', ''+proposalObj1.Id, 
                                                                        'TestFile01.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
            insert  srAttachmentObj0;       

            proposalObj1.Assigne__c = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
            EDPWebServices.submitProposal(proposalObj1.Id);         
			
			
			Map<Id, Proposal__C> asBuiltProposalMap = new Map<Id, Proposal__C>();
			asBuiltProposalMap.put(proposalObj1.Id, proposalObj1);
			Set<Id>  asBuiltOriginalProposalIds = new Set<Id>();
			asBuiltOriginalProposalIds.add(proposalObj1.Original_Proposal_ID__c);
			ProposalUtil.processAsBuiltProposals(asBuiltProposalMap, asBuiltOriginalProposalIds);    

			Customer_Credit__c ccObj = new Customer_Credit__c();
			Map<Id, Customer_Credit__c> modifiedCustomerCredits = new Map<Id, Customer_Credit__c>();
			Map<Id, Id> optyContactMap = new Map<Id, Id>();
			ccObj.Date_Pulled__c = Date.Today();
			ccObj.Sunrun_Credit_Status__c = CustomerCreditUtil.PASS;
			opprtunityObj.Payment_Mode__c = 'Recurring';
			proposalObj1.Agreement_Type__c = ProposalUtil.CUST_OWNED_FULL_UPFRONT;
			ProposalUtil.updateProposalAndCustomerCreditForCreditAutomation(opprtunityObj, proposalObj1,ccObj, defaultOpsUser, 
                                                                            modifiedCustomerCredits, optyContactMap);

			proposalObj1.Agreement_Type__c = '';
			proposalObj1.Partner_Financed__c = true; 
			ccObj.Sunrun_Credit_Status__c = CustomerCreditUtil.CPASS;
			ProposalUtil.updateProposalAndCustomerCreditForCreditAutomation(opprtunityObj, proposalObj1,ccObj, defaultOpsUser, 
                                                                            modifiedCustomerCredits, optyContactMap);

        Test.stopTest();    
    }

	/**/

	//Remove the comments after testing -2
    public static testmethod void testProposalStages(){
          UnitTest_ProposalUtil.disableExternalServices();
        String strProposalApprovalLimit1 = Label.ProposalApprovalLimit1;
        if(strProposalApprovalLimit1 == null || strProposalApprovalLimit1 == ''){
            strProposalApprovalLimit1 = '15';
        }

        String partnerAccountId = PartnerDetail__c.getValues('EDPTestAccount').PartnerAccountId__C;
        String partnerContactId = PartnerDetail__c.getValues('EDPTestAccount').PartnerContactId__C;
        String partnerSalesRepId = PartnerDetail__c.getValues('EDPTestAccount').PartnerUserId__c;
        String salesRepEmail = PartnerDetail__c.getValues('EDPTestAccount').PartnerContactEmail__C;

        Account customerAccount;
        Contact primaryContact;
        Contact secondaryContact;
        Opportunity opprtunityObj;

        Decimal proposalLimit1 = Decimal.valueOf(strProposalApprovalLimit1);
        Proposal__C proposalObj1 = UnitTest_ProposalUtil.createProposal('1324 Fremont St CA', 'PFirstName12', 'PLastName12', 
                                            'PrimaryCustomer@gmail.com', '1324 Fremont St CA','P124124123-I', 
                                            23532, 23, 'Mode-1', salesRepEmail, partnerAccountId, partnerAccountId,
                                            customerAccount, primaryContact, secondaryContact, opprtunityObj);
        insert proposalObj1;    

        SR_Attachment__c srAttachmentObj0 = UnitTest_ProposalUtil.CreateSRAttachment('Utility Bill', '', ''+proposalObj1.Id, 
                                                                    'TestFile01.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
        insert  srAttachmentObj0;                                                       
        
        Opportunity optyObj1 = TestPRMLibrary.insertOpportunity('ResidentialAccount-02', 'Residential',
                                                                'ResOpty-02', 'Platinum');  
        Proposal__C proposalObj2 = UnitTest_ProposalUtil.createProposal('1524 Fremont St CA', 'PFirstName12', 'PLastName12', 
                                            'PrimaryCustomer@gmail.com', '1524 Fremont St CA','P224124123-I', 
                                            23532, 10, 'Mode-1', salesRepEmail, null, null,
                                            customerAccount, primaryContact, secondaryContact, opprtunityObj);
        proposalObj2.Original_Proposal_ID__c = proposalObj1.Id;
        proposalObj2.Revised_Proposal__c = true;
        insert proposalObj2;            
        System.debug('proposalObj2.Opportunity__c: ' + proposalObj2.Opportunity__c);
        opprtunityObj = [Select Id, name, accountId from Opportunity where id =:proposalObj2.Opportunity__c];
        customerAccount = [Select Id, name,(Select Id, name, email from Contacts) from Account where Id =:opprtunityObj.accountId];
        primaryContact = customerAccount.contacts[0];
        secondaryContact = customerAccount.contacts[1];
        
        String envelopId1 = '';
        String proposalIdStr = '' + proposalObj2.id;

        envelopId1 = '1335SDFF-43643-GSGA346';
        proposalIdStr = '' + proposalObj2.id;
        List<SR_Attachment__c> srAttachmentList = new List<SR_Attachment__c>();
        SR_Attachment__c srAttachmentObj1;
        
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Customer Agreement', envelopId1, proposalIdStr, 
                                                                    'TestFile01.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentList.add(srAttachmentObj1);

        envelopId1 = '2335SDFF-43643-GSGA346';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('EPC', envelopId1, proposalIdStr, 
                                                                    'TestFile02.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentList.add(srAttachmentObj1);

        envelopId1 = '5335SDFF-43643-GSGA341';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Utility Bill', envelopId1, proposalIdStr, 
                                                                    'TestFile03.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.WET_SIGNED;
        srAttachmentList.add(srAttachmentObj1);     

        envelopId1 = '7335SDFF-43643-GSGA342';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Large System Contract Approval Request', envelopId1, proposalIdStr, 
                                                                    'TestFile04.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentList.add(srAttachmentObj1);         
        
         List<User> userList = EDPUtil.getSRUserDetails();
        
        insert srAttachmentList;

        List<OpportunityContactRole> contactRolelist = new List<OpportunityContactRole>();
        OpportunityContactRole contactRoleObj = new OpportunityContactRole();
        contactRoleObj.ContactId = primaryContact.Id;
        contactRoleObj.OpportunityId = proposalObj2.Opportunity__c;
        contactRoleObj.Role = 'Homeowner';
        contactRoleObj.IsPrimary = true;
        contactRolelist.add(contactRoleObj);
        
        contactRoleObj = new OpportunityContactRole();
        contactRoleObj.ContactId = secondaryContact.Id;
        contactRoleObj.OpportunityId = proposalObj2.Opportunity__c;
        contactRoleObj.Role = 'Other';
        contactRolelist.add(contactRoleObj);
        Database.SaveResult[] lsr = Database.insert(contactRolelist);

        proposalObj2.System_Size_Validated_by_SR_Ops__c = true;
        proposalObj2.status__c = 'Valid';
        proposalObj2.Sales_Partner__c = partnerAccountId;
        proposalObj2.Install_Partner__c = partnerAccountId;
        update proposalObj2;
        System.debug('End update ... ');

        User defaultOpsUser = null;
        User defaultFinanceUser = null;
        
        Test.startTest();       

            for(User userObj : userList){
                if(defaultOpsUser == null && userObj.name == EDPUtil.USER_NAME_TEST){
                    defaultOpsUser = userObj;
                }
                if(defaultFinanceUser == null && userObj.name == EDPUtil.USER_NAME_TEST){
                    defaultFinanceUser = userObj;
                }
        
                if(userObj.name == EDPUtil.USER_NAME_SR_OPS){
                    defaultOpsUser = userObj;
                }           
                else if(userObj.name == EDPUtil.USER_NAME_SR_FINANCE){
                    defaultFinanceUser = userObj;
                }
            }

            Proposal__c proposalObj =  proposalObj2;
            proposalObj.Assigne__c = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
            EDPWebServices.submitProposal(proposalObj.Id);
            
            //proposalObj.Stage__c = EDPUtil.SUBMITTED;
            //update proposalObj;

            proposalObj.Assigne__c = defaultOpsUser.Id;
            update proposalObj;
            
            proposalObj.Customer_SignOff_Date__c = Datetime.now();
            proposalObj.System_Size_Validated_by_SR_Ops__c = false;
            proposalObj.Stage__c = EDPUtil.SR_OPS_REVIEWED;
            update proposalObj;

            proposalObj.Assigne__c = defaultFinanceUser.Id;
            update proposalObj;
    
            //proposalObj.Stage__c = EDPUtil.CREDIT_APPROVED;
            //update proposalObj;
    
            //optyObj1.SR_Credit_Status__c = EDPUtil.CREDIT_APPROVED;
            //update optyObj1;
            System.debug('proposalObj.stage__c1: ' + proposalObj.stage__c);
            proposalObj.Stage__c = EDPUtil.CREDIT_APPROVED;
            update proposalObj;
            System.debug('proposalObj.stage__c2: ' + proposalObj.stage__c);
            
            proposalObj.Stage__c = EDPUtil.SR_OPS_APPROVED;
            proposalObj.Revised_Proposal__c = true;
            proposalObj.System_Size_Validated_by_SR_Ops__c = false;
            proposalObj.SR_Signoff__c = null;
            update proposalObj;     
            
            Set<Id> optyIds = new Set<Id>();
            optyIds.add(proposalObj.Opportunity__c);
            EDPUtil.getApprovedProposals(optyIds);
        
            srAttachmentList[0].Document_Source__c = EDPUtil.E_SIGN;
            srAttachmentList[1].Document_Source__c = EDPUtil.E_SIGN;
            srAttachmentList[2].Document_Source__c = EDPUtil.E_SIGN;
            srAttachmentList[3].Document_Source__c = EDPUtil.E_SIGN;
            update srAttachmentList;
            
            System.debug('Welcome Error: ' + EDPUtil.processWelcomeEmailRequest(''+proposalObj.Id));

            System.debug('proposalObj.stage__c3: ' + proposalObj.stage__c);
            proposalObj.System_Size_STC_DC__c = 1;
            proposalObj.Assigne__c = defaultOpsUser.Id;
            proposalObj.Stage__c = EDPUtil.SR_OPS_APPROVED;
            update proposalObj;     
            EDPUtil.getProposalObject(proposalObj.Id);
            
            System.runAs(defaultOpsUser){
                Set<Id> opportunityIds = new Set<Id>();
                opportunityIds.add(opprtunityObj.Id);
                EDPUtil.cancelProposals(opportunityIds);
            }
            
        Test.stopTest();    

    }
	/**/
	
	/**/
	//Remove the comments after testing 
    public static testmethod void testApprovalProcess2(){
		 UnitTest_ProposalUtil.disableExternalServices();
        Id userId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
        User partnerUser = [Select id, name, email from User where Id =:userId];        

        //System.runAs(partnerUser){
        
            String strProposalApprovalLimit1 = Label.ProposalApprovalLimit2;
            if(strProposalApprovalLimit1 == null || strProposalApprovalLimit1 == ''){
                strProposalApprovalLimit1 = '25';
            }
            Decimal proposalLimit1 = Decimal.valueOf(strProposalApprovalLimit1);
    
            Opportunity optyObj1 = TestPRMLibrary.insertOpportunity('ResidentialAccount-03', 'Residential',
                                                                    'ResOpty-03', 'Platinum');  
            List<Proposal__C> proposalList = new List<Proposal__C>();
            //proposalList.add(UnitTest_ProposalUtil.getProposalObject(''+ optyObj1.Id, 'P77A13CD6KDRRF1-I', 22346, proposalLimit1, 'Mode-02', 'test02@gmail.com'));
            Proposal__C tempProposalObj = UnitTest_ProposalUtil.getProposalObject(''+ optyObj1.Id, 'P77A13CD6KDRRF1-I', 22346, proposalLimit1, 'Mode-02', 'test02@gmail.com');
            insert tempProposalObj;
            
            proposalList.add(UnitTest_ProposalUtil.getProposalObject(''+ optyObj1.Id, 'C97A13CD6KDRRF1:IIC-I', 12345, proposalLimit1, 'Mode-01', 'test01@gmail.com'));        
            insert proposalList;        
    
            String envelopId1 = '1335SDFF-43643-GSGA346';
            String proposalIdStr = '' + proposalList[0].id;
            List<SR_Attachment__c> srAttachmentList = new List<SR_Attachment__c>();
            SR_Attachment__c srAttachmentObj1;
            
            srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Customer Agreement', envelopId1, proposalIdStr, 
                                                                        'TestFile01.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
            srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
            srAttachmentList.add(srAttachmentObj1);
    
            envelopId1 = '2335SDFF-43643-GSGA346';
            srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('EPC', envelopId1, proposalIdStr, 
                                                                        'TestFile02.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
            srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
            srAttachmentList.add(srAttachmentObj1);
    
            envelopId1 = '5335SDFF-43643-GSGA341';
            srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Utility Bill', envelopId1, proposalIdStr, 
                                                                        'TestFile03.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
            srAttachmentObj1.DocuSign_Status__c = EDPUtil.WET_SIGNED;
            srAttachmentList.add(srAttachmentObj1);     
    
            envelopId1 = '7335SDFF-43643-GSGA342';
            srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Large System Contract Approval Request', envelopId1, proposalIdStr, 
                                                                        'TestFile04.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
            srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
            srAttachmentList.add(srAttachmentObj1);         

            envelopId1 = '7335SDFF-43643-GSGA352';
            srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Customer Change Order Cover Sheet', envelopId1, proposalIdStr, 
                                                                        'TestFile05.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
            srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
            srAttachmentList.add(srAttachmentObj1); 

             List<User> userList = EDPUtil.getSRUserDetails();
            
            insert srAttachmentList;
    
            User defaultOpsUser = null;
            User defaultFinanceUser = null;
            
            Test.startTest();       
    
                for(User userObj : userList){
                    if(defaultOpsUser == null && userObj.name == EDPUtil.USER_NAME_TEST){
                        defaultOpsUser = userObj;
                    }
                    if(defaultFinanceUser == null && userObj.name == EDPUtil.USER_NAME_TEST){
                        defaultFinanceUser = userObj;
                    }
            
                    if(userObj.name == EDPUtil.USER_NAME_SR_OPS){
                        defaultOpsUser = userObj;
                    }           
                    else if(userObj.name == EDPUtil.USER_NAME_SR_FINANCE){
                        defaultFinanceUser = userObj;
                    }
                }
    
                Proposal__c proposalObj =  proposalList[0];
                proposalObj.Assigne__c = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
                //proposalObj.Stage__c = EDPUtil.SUBMITTED;
                update proposalObj;
                
                EDPWebServices.submitProposal('' + proposalObj.Id);
    
                proposalObj.Assigne__c = defaultOpsUser.Id;
                update proposalObj;
                
                proposalObj.Customer_SignOff_Date__c = Datetime.now();
                proposalObj.Stage__c = EDPUtil.SR_OPS_REVIEWED;
                proposalObj.SR_Ops_Actions__c = EDPUtil.SR_OPS_REVIEWED;
                proposalObj.System_Size_Validated_by_SR_Ops__c = true;
                update proposalObj;
    
                proposalObj.Assigne__c = defaultFinanceUser.Id;
                update proposalObj;
    
                System.debug('proposalObj.stage__c1: ' + proposalObj.stage__c);
                proposalObj.Stage__c = EDPUtil.CREDIT_APPROVED;
                proposalObj.SR_Finance_Action__c = EDPUtil.CREDIT_APPROVED;
                update proposalObj;
                System.debug('proposalObj.stage__c2: ' + proposalObj.stage__c);
                
                proposalObj.SR_Ops_Actions__c = '';
                proposalObj.SR_Finance_Action__c = '';
                proposalObj.Stage__c = EDPUtil.SR_OPS_APPROVED;
                proposalObj.Revised_Proposal__c = true;
                proposalObj.System_Size_Validated_by_SR_Ops__c = true;
                proposalObj.SR_Signoff__c = null;               
                proposalObj.Submitted_By__c = PartnerDetail__c.getValues('EDPTestAccount').PartnerUserId__c;
                
                System.debug('Start update ..');
                update proposalObj; 
                System.debug('End update ..');
                
                tempProposalObj = [Select Id, stage__c from Proposal__C where Id =:proposalObj.Id];
                System.debug('tempProposalObj.stage__c2: ' + tempProposalObj.stage__c); 
                EDPUtil.processWelcomeEmailRequest(''+proposalObj.Id);
                EDPUtil.processWelcomeEmailRequestForPartners(''+proposalObj.Id);
    
            Test.stopTest();    
        //}
    }

	
    public static testmethod void testProposalExceptions(){
		 UnitTest_ProposalUtil.disableExternalServices();
        String strProposalApprovalLimit1 = Label.ProposalApprovalLimit2;
        if(strProposalApprovalLimit1 == null || strProposalApprovalLimit1 == ''){
            strProposalApprovalLimit1 = '25';
        }
        Decimal proposalLimit1 = Decimal.valueOf(strProposalApprovalLimit1);

        Opportunity optyObj1 = TestPRMLibrary.insertOpportunity('ResidentialAccount-03', 'Residential',
                                                                'ResOpty-03', 'Platinum');  
        List<Proposal__C> proposalList = new List<Proposal__C>();
        proposalList.add(UnitTest_ProposalUtil.getProposalObject(''+ optyObj1.Id, 'P77A13CD6KDRRF1-I', 22346, proposalLimit1, 'Mode-02', 'test02@gmail.com'));
        proposalList.add(UnitTest_ProposalUtil.getProposalObject(''+ optyObj1.Id, 'C97A13CD6KDRRF1:IIC-I', 12345, proposalLimit1, 'Mode-01', 'test01@gmail.com'));        
        insert proposalList;        

        String envelopId1 = '1335SDFF-43643-GSGA346';
        String proposalIdStr = '' + proposalList[0].id;
        List<SR_Attachment__c> srAttachmentList = new List<SR_Attachment__c>();
        SR_Attachment__c srAttachmentObj1;
        
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Customer Agreement', envelopId1, proposalIdStr, 
                                                                    'TestFile01.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentList.add(srAttachmentObj1);

        envelopId1 = '2335SDFF-43643-GSGA346';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('EPC', envelopId1, proposalIdStr, 
                                                                    'TestFile02.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentList.add(srAttachmentObj1);
        List<User> userList = EDPUtil.getSRUserDetails();
        
        insert srAttachmentList;

        User defaultOpsUser = null;
        User defaultFinanceUser = null;
        
        Test.startTest();       

            for(User userObj : userList){
                if(defaultOpsUser == null && userObj.name == EDPUtil.USER_NAME_TEST){
                    defaultOpsUser = userObj;
                }
                if(defaultFinanceUser == null && userObj.name == EDPUtil.USER_NAME_TEST){
                    defaultFinanceUser = userObj;
                }
        
                if(userObj.name == EDPUtil.USER_NAME_SR_OPS){
                    defaultOpsUser = userObj;
                }           
                else if(userObj.name == EDPUtil.USER_NAME_SR_FINANCE){
                    defaultFinanceUser = userObj;
                }
            }
            
            Proposal__c proposalObj =  proposalList[0];
            try{
            
                proposalObj.Assigne__c = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
                proposalObj.Stage__c = EDPUtil.SUBMITTED;
                update proposalObj;
            }catch(Exception expObj){
                
            }
            
            List<SR_Attachment__c> srAttachmentList2 = new List<SR_Attachment__c>();
            envelopId1 = '5335SDFF-43643-GSGA341';
            srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Utility Bill', envelopId1, proposalIdStr, 
                                                                        'TestFile03.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
            srAttachmentObj1.DocuSign_Status__c = EDPUtil.WET_SIGNED;
            srAttachmentList2.add(srAttachmentObj1);        
    
            envelopId1 = '7335SDFF-43643-GSGA342';
            srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Large System Contract Approval Request', envelopId1, proposalIdStr, 
                                                                        'TestFile04.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
            srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
            srAttachmentList2.add(srAttachmentObj1);    
            insert srAttachmentList2;

            try{
                proposalObj.Assigne__c = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
                proposalObj.Stage__c = EDPUtil.SUBMITTED;
                update proposalObj;
            }catch(Exception expObj){
                
            }
            
            proposalObj.Assigne__c = defaultOpsUser.Id;
            update proposalObj;
            
            try{
                //proposalObj.Customer_SignOff_Date__c = Datetime.now();
                proposalObj.SR_Ops_Actions__c = EDPUtil.SR_OPS_REVIEWED;
                proposalObj.System_Size_Validated_by_SR_Ops__c = true;
                update proposalObj;             
            }catch(Exception expObj){
                    
            }

            try{
                //proposalObj.Customer_SignOff_Date__c = Datetime.now();
                proposalObj.Stage__c = EDPUtil.SR_OPS_REVIEWED;
                proposalObj.SR_Ops_Actions__c = EDPUtil.SR_OPS_REVIEWED;
                proposalObj.System_Size_Validated_by_SR_Ops__c = false;
                update proposalObj;             
            }catch(Exception expObj){
                    
            }

            try{
                proposalObj.Stage__c = EDPUtil.SR_OPS_REVIEWED;
                proposalObj.SR_Ops_Actions__c = EDPUtil.SR_OPS_REVIEWED;
                proposalObj.System_Size_Validated_by_SR_Ops__c = true;
                update proposalObj;             
            }catch(Exception expObj){
                    
            }

            try{
                proposalObj.Stage__c = EDPUtil.SR_OPS_APPROVED;
                proposalObj.SR_Ops_Actions__c = EDPUtil.SR_OPS_APPROVED;
                proposalObj.System_Size_Validated_by_SR_Ops__c = true;
                update proposalObj;             
            }catch(Exception expObj){
                    
            }

            try{
                proposalObj.Stage__c = EDPUtil.CREDIT_APPROVED;
                proposalObj.SR_Ops_Actions__c = EDPUtil.CREDIT_APPROVED;
                proposalObj.System_Size_Validated_by_SR_Ops__c = true;
                update proposalObj;             
            }catch(Exception expObj){
                    
            }


            //proposalObj.Assigne__c = defaultFinanceUser.Id;
            //update proposalObj;

            //System.debug('proposalObj.stage__c1: ' + proposalObj.stage__c);
            //proposalObj.Stage__c = EDPUtil.CREDIT_APPROVED;
            //proposalObj.SR_Finance_Action__c = EDPUtil.CREDIT_APPROVED;
            //update proposalObj;
            //System.debug('proposalObj.stage__c2: ' + proposalObj.stage__c);
            
            //proposalObj.SR_Ops_Actions__c = '';
            //proposalObj.SR_Finance_Action__c = '';
            //proposalObj.Stage__c = EDPUtil.SR_OPS_APPROVED;
            //proposalObj.Revised_Proposal__c = true;
            //proposalObj.System_Size_Validated_by_SR_Ops__c = true;
            //proposalObj.SR_Signoff__c = null;
            //update proposalObj;       
            
        Test.stopTest();    
    }

    public static testmethod void testChangeOrders(){
		 UnitTest_ProposalUtil.disableExternalServices();
        String strProposalApprovalLimit1 = Label.ProposalApprovalLimit2;
        if(strProposalApprovalLimit1 == null || strProposalApprovalLimit1 == ''){
            strProposalApprovalLimit1 = '25';
        }
        Decimal proposalLimit1 = Decimal.valueOf(strProposalApprovalLimit1);

        Opportunity optyObj1 = TestPRMLibrary.insertOpportunity('ResidentialAccount-03', 'Residential',
                                                                'ResOpty-03', 'Platinum');  
        List<Proposal__C> proposalList = new List<Proposal__C>();
        proposalList.add(UnitTest_ProposalUtil.getProposalObject(''+ optyObj1.Id, 'P77A13CD6KDRRF1-I', 22346, proposalLimit1, 'Mode-02', 'test02@gmail.com'));
        
        //proposalList.add(UnitTest_ProposalUtil.getProposalObject(''+ optyObj1.Id, 'C97A13CD6KDRRF1:IIC-I', 12345, proposalLimit1, 'Mode-01', 'test01@gmail.com'));      
        insert proposalList;        

        String envelopId1 = '1335SDFF-43643-GSGA346';
        String proposalIdStr = '' + proposalList[0].id;
        List<SR_Attachment__c> srAttachmentList = new List<SR_Attachment__c>();
        SR_Attachment__c srAttachmentObj1;
        
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Customer Agreement', envelopId1, proposalIdStr, 
                                                                    'TestFile01.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentList.add(srAttachmentObj1);

        envelopId1 = '2335SDFF-43643-GSGA346';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('EPC', envelopId1, proposalIdStr, 
                                                                    'TestFile02.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentList.add(srAttachmentObj1);

        envelopId1 = '5335SDFF-43643-GSGA341';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Utility Bill', envelopId1, proposalIdStr, 
                                                                    'TestFile03.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.WET_SIGNED;
        srAttachmentList.add(srAttachmentObj1);     

        envelopId1 = '7335SDFF-43643-GSGA342';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Large System Contract Approval Request', envelopId1, proposalIdStr, 
                                                                    'TestFile04.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentList.add(srAttachmentObj1);         
        
        List<User> userList = EDPUtil.getSRUserDetails();
        
        insert srAttachmentList;

        Proposal__c proposalObj =  proposalList[0];
        proposalObj.Assigne__c = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
        proposalObj.Stage__c = EDPUtil.SUBMITTED;
        update proposalObj;
        
        Test.startTest();       
            
            proposalList = new List<Proposal__C>();
            Proposal__C tempProposalObj = UnitTest_ProposalUtil.getProposalObject(''+ optyObj1.Id, 'C97A13CD6KDRRF1:IIC-I', 12345, proposalLimit1, 'Mode-01', 'test01@gmail.com');
            tempProposalObj.Change_Order__c = true;
            tempProposalObj.Original_Proposal_ID__c = proposalObj.Id;
            proposalList.add(tempProposalObj);
            insert proposalList;        
    
            envelopId1 = '2335SDFF-43643-GAGA346';
            proposalIdStr = '' + proposalList[0].id;
            srAttachmentList = new List<SR_Attachment__c>();
            
            srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Customer Agreement', envelopId1, proposalIdStr, 
                                                                        'TestFile11.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
            srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
            srAttachmentList.add(srAttachmentObj1);
    
            envelopId1 = '23A5SDFF-43643-GSGA346';
            srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('EPC', envelopId1, proposalIdStr, 
                                                                        'TestFile12.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
            srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
            srAttachmentList.add(srAttachmentObj1);
    
            envelopId1 = '53B5SDFF-43643-GSGA341';
            srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Utility Bill', envelopId1, proposalIdStr, 
                                                                        'TestFile03.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
            srAttachmentObj1.DocuSign_Status__c = EDPUtil.WET_SIGNED;
            srAttachmentList.add(srAttachmentObj1);     
    
            envelopId1 = '733CSDFF-43643-GSGA342';
            srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Large System Contract Approval Request', envelopId1, proposalIdStr, 
                                                                        'TestFile04.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
            srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
            srAttachmentList.add(srAttachmentObj1);         
            insert srAttachmentList;
            
            proposalObj =  proposalList[0];
            proposalObj.Assigne__c = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
            proposalObj.Stage__c = EDPUtil.SUBMITTED;
            update proposalObj; 

        Test.stopTest();    
    }


	//Remove the comments after testing -2
    public static testmethod void testSignedSRAttachmentRelatedList(){
		  UnitTest_ProposalUtil.disableExternalServices();
        Id userId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
        User partnerUser = [Select id, name, email from User where Id =:userId];    
        SRAttachmentRelatedList srAttachmentListObj;    
        System.runAs(partnerUser){
            String strProposalApprovalLimit1 = Label.ProposalApprovalLimit2;
            if(strProposalApprovalLimit1 == null || strProposalApprovalLimit1 == ''){
                strProposalApprovalLimit1 = '25';
            }
            Decimal proposalLimit1 = Decimal.valueOf(strProposalApprovalLimit1);
    
            String partnerAccountId = PartnerDetail__c.getValues('ApexTestAccount').PartnerAccountId__C;
            String partnerContactId = PartnerDetail__c.getValues('ApexTestAccount').PartnerContactId__C;
            String partnerSalesRepId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
            String salesRepEmail = PartnerDetail__c.getValues('ApexTestAccount').PartnerContactEmail__C;
    
            Account customerAccount;
            Contact primaryContact;
            Contact secondaryContact;
            Opportunity opprtunityObj;
            
            System.debug('partnerAccountId: ' + partnerAccountId);
            String customerEmail = 'PrimaryCustomer@gmail.com';
            Proposal__C proposalObj = UnitTest_ProposalUtil.createProposal('1234 Fremont St CA', 'PFirstName1', 'PLastName1', 
                                                customerEmail, '1234 Fremont St CA','P124124123-I', 
                                                23532, 23, 'Mode-1', salesRepEmail, partnerAccountId, partnerAccountId,
                                                customerAccount, primaryContact, secondaryContact, opprtunityObj);
            insert proposalObj; 
    
            String envelopId1 = '1335SDFF-43643-GSGA346';
            String proposalIdStr = '' + proposalObj.id;
            List<SR_Attachment__c> srAttachmentList = new List<SR_Attachment__c>();
            SR_Attachment__c srAttachmentObj1;
            
            String customerAgreementEnvelopId = '1335SDFF-43643-GSGA346';
            srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Customer Agreement', customerAgreementEnvelopId, proposalIdStr, 
                                                                        'TestFile01.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
            srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
            srAttachmentList.add(srAttachmentObj1);
    
            envelopId1 = '2335SDFF-43643-GSGA346';
            srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('EPC', envelopId1, proposalIdStr, 
                                                                        'TestFile02.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
            srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
            srAttachmentList.add(srAttachmentObj1);
    
            envelopId1 = '5335SDFF-43643-GSGA341';
            srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Utility Bill', envelopId1, proposalIdStr, 
                                                                        'TestFile03.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
            srAttachmentObj1.DocuSign_Status__c = EDPUtil.WET_SIGNED;
            srAttachmentList.add(srAttachmentObj1);     
    
            envelopId1 = '7335SDFF-43643-GSGA342';
            srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Large System Contract Approval Request', envelopId1, proposalIdStr, 
                                                                        'TestFile04.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
            srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
            srAttachmentList.add(srAttachmentObj1);         
            
             List<User> userList = EDPUtil.getSRUserDetails();
            
            insert srAttachmentList;
    
            dsfs__DocuSign_Status__c docuSignStatus2 = UnitTest_ProposalUtil.CreateDocuSignStatus(customerAgreementEnvelopId, EDPUtil.COMPLETED);
            insert docuSignStatus2;     
        
            String recipientId = '345SDFF-43643-GSGA336';
            String recipientEmail = 'test.sunrundocusing@gmail.com';
            String primaryContactEmail = 'first.' + customerEmail;
            String secondaryContactEmail = 'second.' + customerEmail;
        
            List<dsfs__DocuSign_Recipient_Status__c> recipientStatusList = new List<dsfs__DocuSign_Recipient_Status__c>();
            dsfs__DocuSign_Recipient_Status__c recipientStatus1 = UnitTest_ProposalUtil.CreateDocuSignRecipientStatus('' + docuSignStatus2.Id, customerAgreementEnvelopId, 
                                                                                            recipientId, primaryContactEmail, EDPUtil.COMPLETED);
            recipientStatus1.name = 'PFirstName1-1 PLastName1-1';
            recipientId = '445SDFF-43643-GSGA336';
            dsfs__DocuSign_Recipient_Status__c recipientStatus2 = UnitTest_ProposalUtil.CreateDocuSignRecipientStatus('' + docuSignStatus2.Id, customerAgreementEnvelopId, 
                                                                                            recipientId, secondaryContactEmail, EDPUtil.COMPLETED);
            recipientStatus2.name = 'PFirstName1-2 PLastName1-2';
            recipientStatusList.add(recipientStatus1);
            recipientStatusList.add(recipientStatus2);
            insert recipientStatusList;
            
            Map<String, String> recipientEnvelopMap = new Map<String, String>();
            recipientEnvelopMap.put(recipientStatus1.dsfs__DocuSign_Recipient_Id__c, recipientStatus1.dsfs__Envelope_Id__c);
            recipientEnvelopMap.put(recipientStatus2.dsfs__DocuSign_Recipient_Id__c, recipientStatus2.dsfs__Envelope_Id__c);
            DocuSignUtil.updateProposals(recipientEnvelopMap);
            
            srAttachmentListObj = new SRAttachmentRelatedList();
            srAttachmentListObj.setRelatedObjectId(proposalIdStr);  
            srAttachmentListObj.displayMasterDocuments = false;
            srAttachmentListObj.displaySignedDocuments = true;
            Boolean value2 = srAttachmentListObj.showActions;
            Boolean value1 = srAttachmentListObj.showCheckbox;
            srAttachmentListObj.getActions();
            srAttachmentListObj.initializeSRAttachments();
            srAttachmentListObj.selectSRAttachments();
            srAttachmentListObj.getSelectedIds();
            srAttachmentListObj.getRelatedlistRefreshURL();
            
            proposalObj.stage__c = EDPUtil.PENDING_TASK_COMPLETED;
            update proposalObj;
            srAttachmentListObj.deleteSRAttachments();
            
            proposalObj.stage__c =  EDPUtil.WITH_DRAWN;
            update proposalObj;
            srAttachmentListObj.deleteSRAttachments();
            
            List<SR_Attachment__c> modifiedSRAttachments = new List<SR_Attachment__c>();
            for(SR_Attachment__c srAttachmentObj : srAttachmentList){
                srAttachmentObj.DocuSign_Status__c = EDPUtil.SENT;
                modifiedSRAttachments.add(srAttachmentObj);
            }
            update modifiedSRAttachments;
            srAttachmentListObj.deleteSRAttachments();
                
            srAttachmentList[0].DocuSign_Status__c = EDPUtil.WET_SIGNED;
            srAttachmentList[1].DocuSign_Status__c = EDPUtil.WET_SIGNED;
            srAttachmentList[2].DocuSign_Status__c = EDPUtil.WET_SIGNED;
            srAttachmentList[3].DocuSign_Status__c = EDPUtil.WET_SIGNED;
            update srAttachmentList;
            
            proposalObj.stage__c = EDPUtil.CREATED;
            update proposalObj;
            srAttachmentListObj.deleteSRAttachments();
            srAttachmentListObj.getIsPartnerUser();
        }
        srAttachmentListObj.getIsSystemAdmin();

    }

	//Remove the comments after testing 
    public static testmethod void testResendDocuSign(){
		 UnitTest_ProposalUtil.disableExternalServices();
        Id userId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
        User partnerUser = [Select id, name, email from User where Id =:userId];    
        SRAttachmentRelatedList srAttachmentListObj;    
        System.runAs(partnerUser){
            String strProposalApprovalLimit1 = Label.ProposalApprovalLimit2;
            if(strProposalApprovalLimit1 == null || strProposalApprovalLimit1 == ''){
                strProposalApprovalLimit1 = '25';
            }
            Decimal proposalLimit1 = Decimal.valueOf(strProposalApprovalLimit1);
    
            String partnerAccountId = PartnerDetail__c.getValues('ApexTestAccount').PartnerAccountId__C;
            String partnerContactId = PartnerDetail__c.getValues('ApexTestAccount').PartnerContactId__C;
            String partnerSalesRepId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
            String salesRepEmail = PartnerDetail__c.getValues('ApexTestAccount').PartnerContactEmail__C;
    
            Account customerAccount;
            Contact primaryContact;
            Contact secondaryContact;
            Opportunity opprtunityObj;
            
            System.debug('partnerAccountId: ' + partnerAccountId);
    
            Proposal__C proposalObj = UnitTest_ProposalUtil.createProposal('1234 Fremont St CA', 'PFirstName1', 'PLastName1', 
                                                'PrimaryCustomer@gmail.com', '1234 Fremont St CA','P124124123-I', 
                                                23532, 23, 'Mode-1', salesRepEmail, partnerAccountId, partnerAccountId,
                                                customerAccount, primaryContact, secondaryContact, opprtunityObj);
            insert proposalObj; 
    
            String envelopId1 = '1335SDFF-43643-GSGA346';
            String proposalIdStr = '' + proposalObj.id;
            List<SR_Attachment__c> srAttachmentList = new List<SR_Attachment__c>();
            SR_Attachment__c srAttachmentObj1;
            
            String customerAgreementEnvelopId = '1335SDFF-43643-GSGA346';
            srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Customer Agreement', customerAgreementEnvelopId, proposalIdStr, 
                                                                        'TestFile01.pdf', EDPUtil.E_SIGN);
            srAttachmentObj1.DocuSign_Status__c = EDPUtil.SENT;
            srAttachmentList.add(srAttachmentObj1);     

            String customerAgreementEnvelopId2 = '2335SDFF-43643-GSGA346';
            srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('EPC', customerAgreementEnvelopId2, proposalIdStr, 
                                                                        'TestFile02.pdf', EDPUtil.E_SIGN);
            srAttachmentObj1.DocuSign_Status__c = EDPUtil.SENT;
            srAttachmentList.add(srAttachmentObj1);     
            List<User> userList = EDPUtil.getSRUserDetails();
            List<Id> proposalIds = new List<Id> {proposalIdStr};
            insert srAttachmentList;
    
            srAttachmentListObj = new SRAttachmentRelatedList();
            Boolean booleanResult = srAttachmentListObj.showActions;
            booleanResult = srAttachmentListObj.showCheckbox;
            List<SelectOption> sectOptions = srAttachmentListObj.getActions();
            
            srAttachmentListObj.setRelatedObjectId(proposalIdStr);  
            srAttachmentListObj.displayMasterDocuments = false;
            srAttachmentListObj.displaySignedDocuments = true;
            Boolean value2 = srAttachmentListObj.showActions;
            Boolean value1 = srAttachmentListObj.showCheckbox;
            srAttachmentListObj.getActions();
            srAttachmentListObj.initializeSRAttachments();
            srAttachmentListObj.resendESignature();
            
            srAttachmentListObj.selectSRAttachments();
            srAttachmentObj1 = srAttachmentList[0];
            srAttachmentObj1.Envelop_Id__c = '';
            update srAttachmentObj1;
            srAttachmentListObj.resendESignature();
            
            srAttachmentObj1.Envelop_Id__c = customerAgreementEnvelopId;
            update srAttachmentObj1;    

            dsfs__DocuSign_Status__c docuSignStatus2 = UnitTest_ProposalUtil.CreateDocuSignStatus(customerAgreementEnvelopId, EDPUtil.SENT);
            insert docuSignStatus2;     
        
            String recipientId = '345SDFF-43643-GSGA336';
            String recipientEmail = 'test.sunrundocusing@gmail.com';
            dsfs__DocuSign_Recipient_Status__c recipientStatus = UnitTest_ProposalUtil.CreateDocuSignRecipientStatus('' + docuSignStatus2.Id, customerAgreementEnvelopId, 
                                                                                            recipientId, recipientEmail, EDPUtil.SENT);
            insert recipientStatus;         
            srAttachmentListObj.resendESignature();
            
            docuSignStatus2.dsfs__Envelope_Status__c = EDPUtil.VOIDED;
            update docuSignStatus2;
            srAttachmentListObj.resendESignature();
             
            delete recipientStatus;
            delete docuSignStatus2;

            srAttachmentListObj.getRefreshPage();
            srAttachmentListObj.resendESignature();
            Test.startTest(); 
            dsfs__DocuSign_Status__c docuSignStatus3 = UnitTest_ProposalUtil.CreateDocuSignStatus(customerAgreementEnvelopId2, EDPUtil.VOIDED);
            insert docuSignStatus3;     

            recipientId = '345SDFF-43643-GSGA336';
            recipientEmail = 'test2.sunrundocusing@gmail.com';
            recipientStatus = UnitTest_ProposalUtil.CreateDocuSignRecipientStatus(''+docuSignStatus3.Id, customerAgreementEnvelopId2, recipientId, recipientEmail, EDPUtil.SENT);
            insert recipientStatus;
            SRAttachmentManager.verifyDocumentSignatures(proposalIds);
            Test.stopTest();
        }
    }
    
    public static testmethod void testVoidDocuSign(){
		  UnitTest_ProposalUtil.disableExternalServices();
        Id userId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
        User partnerUser = [Select id, name, email from User where Id =:userId];    
        SRAttachmentRelatedList srAttachmentListObj;    
        System.runAs(partnerUser){
            String strProposalApprovalLimit1 = Label.ProposalApprovalLimit2;
            if(strProposalApprovalLimit1 == null || strProposalApprovalLimit1 == ''){
                strProposalApprovalLimit1 = '25';
            }
            Decimal proposalLimit1 = Decimal.valueOf(strProposalApprovalLimit1);
    
            String partnerAccountId = PartnerDetail__c.getValues('ApexTestAccount').PartnerAccountId__C;
            String partnerContactId = PartnerDetail__c.getValues('ApexTestAccount').PartnerContactId__C;
            String partnerSalesRepId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
            String salesRepEmail = PartnerDetail__c.getValues('ApexTestAccount').PartnerContactEmail__C;
    
            Account customerAccount;
            Contact primaryContact;
            Contact secondaryContact;
            Opportunity opprtunityObj;
            
            System.debug('partnerAccountId: ' + partnerAccountId);
    
            Proposal__C proposalObj = UnitTest_ProposalUtil.createProposal('1234 Fremont St CA', 'PFirstName1', 'PLastName1', 
                                                'PrimaryCustomer@gmail.com', '1234 Fremont St CA','P124124123-I', 
                                                23532, 23, 'Mode-1', salesRepEmail, partnerAccountId, partnerAccountId,
                                                customerAccount, primaryContact, secondaryContact, opprtunityObj);
            insert proposalObj; 
    
            String envelopId1 = '1335SDFF-43643-GSGA346';
            String proposalIdStr = '' + proposalObj.id;
            System.currentPagereference().getParameters().put('id', proposalIdStr);
            List<SR_Attachment__c> srAttachmentList = new List<SR_Attachment__c>();
            SR_Attachment__c srAttachmentObj1;
            
            String customerAgreementEnvelopId = '1335SDFF-43643-GSGA346';
            srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Customer Agreement', customerAgreementEnvelopId, proposalIdStr, 
                                                                        'TestFile01.pdf', EDPUtil.E_SIGN);
            srAttachmentObj1.DocuSign_Status__c = EDPUtil.SENT;
            srAttachmentList.add(srAttachmentObj1);
             List<User> userList = EDPUtil.getSRUserDetails();
            
            insert srAttachmentList;
    
            srAttachmentListObj = new SRAttachmentRelatedList();
            srAttachmentListObj.setRelatedObjectId(proposalIdStr);  
            srAttachmentListObj.displayMasterDocuments = false;
            srAttachmentListObj.displaySignedDocuments = true;
            Boolean value2 = srAttachmentListObj.showActions;
            Boolean value1 = srAttachmentListObj.showCheckbox;
            srAttachmentListObj.getActions();
            srAttachmentListObj.initializeSRAttachments();
            srAttachmentListObj.resendESignature();
            
            srAttachmentListObj.selectSRAttachments();
            srAttachmentObj1 = srAttachmentList[0];
            srAttachmentObj1.Envelop_Id__c = '';
            update srAttachmentObj1;
            srAttachmentListObj.voidESignature();
            
            srAttachmentObj1.Envelop_Id__c = customerAgreementEnvelopId;
            update srAttachmentObj1;    

            dsfs__DocuSign_Status__c docuSignStatus2 = UnitTest_ProposalUtil.CreateDocuSignStatus(customerAgreementEnvelopId, EDPUtil.SENT);
            insert docuSignStatus2;     
        
            String recipientId = '345SDFF-43643-GSGA336';
            String recipientEmail = 'test.sunrundocusing@gmail.com';
            dsfs__DocuSign_Recipient_Status__c recipientStatus = UnitTest_ProposalUtil.CreateDocuSignRecipientStatus('' + docuSignStatus2.Id, customerAgreementEnvelopId, 
                                                                                            recipientId, recipientEmail, EDPUtil.SENT);
            insert recipientStatus;         
            srAttachmentListObj.voidESignature();
            
             docuSignStatus2.dsfs__Envelope_Status__c = EDPUtil.VOIDED;
             update docuSignStatus2;
             srAttachmentListObj.voidESignature();
             
             delete recipientStatus;
             delete docuSignStatus2;
             srAttachmentListObj.voidESignature();
             
        }
    }

	//Remove the comments after testing -2
    public static testmethod void testWelcomeEmail(){
		  UnitTest_ProposalUtil.disableExternalServices();
        List<User> userList = EDPUtil.getSRUserDetails();
        User defaultOpsUser = null;
        User defaultFinanceUser = null;
        for(User userObj : userList){
            if(defaultOpsUser == null && userObj.name == EDPUtil.USER_NAME_TEST){
                defaultOpsUser = userObj;
            }
            if(defaultFinanceUser == null && userObj.name == EDPUtil.USER_NAME_TEST){
                defaultFinanceUser = userObj;
            }
    
            if(userObj.name == EDPUtil.USER_NAME_SR_OPS){
                defaultOpsUser = userObj;
            }           
            else if(userObj.name == EDPUtil.USER_NAME_SR_FINANCE){
                defaultFinanceUser = userObj;
            }
        }
        
        String strProposalApprovalLimit1 = Label.ProposalApprovalLimit1;
        if(strProposalApprovalLimit1 == null || strProposalApprovalLimit1 == ''){
            strProposalApprovalLimit1 = '15';
        }

        String partnerAccountId = PartnerDetail__c.getValues('EDPTestAccount').PartnerAccountId__C;
        String partnerContactId = PartnerDetail__c.getValues('EDPTestAccount').PartnerContactId__C;
        String partnerSalesRepId = PartnerDetail__c.getValues('EDPTestAccount').PartnerUserId__c;
        String salesRepEmail = PartnerDetail__c.getValues('EDPTestAccount').PartnerContactEmail__C;

        Account customerAccount;
        Contact primaryContact;
        Contact secondaryContact;
        Opportunity opprtunityObj;

        Decimal proposalLimit1 = Decimal.valueOf(strProposalApprovalLimit1);

        Proposal__C proposalObj1 = UnitTest_ProposalUtil.createProposal('1324 Fremont St CA', 'PFirstName12', 'PLastName12', 
                                            'PrimaryCustomer@gmail.com', '1324 Fremont St CA','P124124123-I', 
                                            23532, 23, 'Mode-1', salesRepEmail, partnerAccountId, partnerAccountId,
                                            customerAccount, primaryContact, secondaryContact, opprtunityObj);
        insert proposalObj1;    

        SR_Attachment__c srAttachmentObj0 = UnitTest_ProposalUtil.CreateSRAttachment('Utility Bill', '', ''+proposalObj1.Id, 
                                                                    'TestFile01.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
        insert  srAttachmentObj0;                                                       
        
        Opportunity optyObj1 = TestPRMLibrary.insertOpportunity('ResidentialAccount-02', 'Residential',
                                                                'ResOpty-02', 'Platinum');  
        
        Proposal__C proposalObj2 = UnitTest_ProposalUtil.createProposal('1524 Fremont St CA', 'PFirstName12', 'PLastName12', 
                                            'PrimaryCustomer@gmail.com', '1524 Fremont St CA','P224124123-I', 
                                            23532, 10, 'Mode-1', salesRepEmail, partnerAccountId, partnerAccountId,
                                            customerAccount, primaryContact, secondaryContact, opprtunityObj);
        proposalObj2.Original_Proposal_ID__c = proposalObj1.Id;
        proposalObj2.Revised_Proposal__c = true;

        System.debug('proposalObj.stage__c3: ' + proposalObj2.stage__c);
        proposalObj2.System_Size_STC_DC__c = 1;
        proposalObj2.Assigne__c = defaultOpsUser.Id;
        proposalObj2.Stage__c = EDPUtil.SR_OPS_APPROVED;
        proposalObj2.Submitted_By__c = PartnerDetail__c.getValues('EDPTestAccount').PartnerUserId__c;
        proposalObj2.Revised_Proposal__c = true;
        proposalObj2.System_Size_Validated_by_SR_Ops__c = true;
        proposalObj2.SR_Signoff__c = date.today();

        insert proposalObj2;            

        opprtunityObj = [Select Id, name, accountId from Opportunity where id =:proposalObj2.Opportunity__c];
        customerAccount = [Select Id, name,(Select Id, name, email from Contacts) from Account where Id =:opprtunityObj.accountId];
        primaryContact = customerAccount.contacts[0];
        secondaryContact = customerAccount.contacts[1];
        
        String envelopId1 = '';
        String proposalIdStr = '' + proposalObj2.id;
        List<OpportunityContactRole> contactRolelist = new List<OpportunityContactRole>();
        OpportunityContactRole contactRoleObj = new OpportunityContactRole();
        contactRoleObj.ContactId = primaryContact.Id;
        contactRoleObj.OpportunityId = opprtunityObj.Id;
        contactRoleObj.Role = 'Homeowner';
        contactRoleObj.IsPrimary = true;
        contactRolelist.add(contactRoleObj);
        
        contactRoleObj = new OpportunityContactRole();
        contactRoleObj.ContactId = secondaryContact.Id;
        contactRoleObj.OpportunityId = opprtunityObj.Id;
        contactRoleObj.Role = 'Other';
        contactRolelist.add(contactRoleObj);
        insert contactRolelist;
        
        Test.startTest();
            envelopId1 = '1335SDFF-43643-GSGA346';
            proposalIdStr = '' + proposalObj2.id;
            List<SR_Attachment__c> srAttachmentList = new List<SR_Attachment__c>();
            SR_Attachment__c srAttachmentObj1;
            
            srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Customer Agreement', envelopId1, proposalIdStr, 
                                                                        'TestFile01.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
            srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
            srAttachmentList.add(srAttachmentObj1);
    
            envelopId1 = '2335SDFF-43643-GSGA346';
            srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('EPC', envelopId1, proposalIdStr, 
                                                                        'TestFile02.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
            srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
            srAttachmentList.add(srAttachmentObj1);
    
            envelopId1 = '5335SDFF-43643-GSGA341';
            srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Utility Bill', envelopId1, proposalIdStr, 
                                                                        'TestFile03.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
            srAttachmentObj1.DocuSign_Status__c = EDPUtil.WET_SIGNED;
            srAttachmentList.add(srAttachmentObj1);     
    
            envelopId1 = '7335SDFF-43643-GSGA342';
            srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Large System Contract Approval Request', envelopId1, proposalIdStr, 
                                                                        'TestFile04.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
            srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
            srAttachmentList.add(srAttachmentObj1);         
            

            srAttachmentList[0].Document_Source__c = EDPUtil.E_SIGN;
            srAttachmentList[1].Document_Source__c = EDPUtil.E_SIGN;
            srAttachmentList[2].Document_Source__c = EDPUtil.E_SIGN;
            srAttachmentList[3].Document_Source__c = EDPUtil.E_SIGN;        
            insert srAttachmentList;
            
            Set<Id> optyIds = new Set<Id>();
            optyIds.add(proposalObj2.Opportunity__c);
            EDPUtil.getApprovedProposals(optyIds);
            
            EDPUtil.getProposalObject(proposalObj2.Id);         
            EDPWebServices.sendWelcomeEmail(proposalObj2.Id);
            System.debug('Welcome Error1: ' + EDPUtil.processWelcomeEmailRequest(''+proposalObj2.Id));
            
            delete srAttachmentList;
            System.debug('Welcome Error3: ' + EDPUtil.processWelcomeEmailRequest(''+proposalObj2.Id));

        Test.stopTest();    
    }


    public static testmethod void testPartnerWelcomeEmail(){
		 UnitTest_ProposalUtil.disableExternalServices();
        String strProposalApprovalLimit1 = Label.ProposalApprovalLimit1;
        if(strProposalApprovalLimit1 == null || strProposalApprovalLimit1 == ''){
            strProposalApprovalLimit1 = '15';
        }

        String partnerAccountId = PartnerDetail__c.getValues('EDPTestAccount').PartnerAccountId__C;
        String partnerContactId = PartnerDetail__c.getValues('EDPTestAccount').PartnerContactId__C;
        String partnerSalesRepId = PartnerDetail__c.getValues('EDPTestAccount').PartnerUserId__c;
        String salesRepEmail = PartnerDetail__c.getValues('EDPTestAccount').PartnerContactEmail__C;


        User defaultOpsUser = null;
        User defaultFinanceUser = null;
        List<User> userList = EDPUtil.getSRUserDetails();
        for(User userObj : userList){
            if(defaultOpsUser == null && userObj.name == EDPUtil.USER_NAME_TEST){
                defaultOpsUser = userObj;
            }
            if(defaultFinanceUser == null && userObj.name == EDPUtil.USER_NAME_TEST){
                defaultFinanceUser = userObj;
            }
    
            if(userObj.name == EDPUtil.USER_NAME_SR_OPS){
                defaultOpsUser = userObj;
            }           
            else if(userObj.name == EDPUtil.USER_NAME_SR_FINANCE){
                defaultFinanceUser = userObj;
            }
        }


        Account customerAccount;
        Contact primaryContact;
        Contact secondaryContact;
        Opportunity opprtunityObj;

        Decimal proposalLimit1 = Decimal.valueOf(strProposalApprovalLimit1);

        Proposal__C proposalObj1 = UnitTest_ProposalUtil.createProposal('1324 Fremont St CA', 'PFirstName12', 'PLastName12', 
                                            'PrimaryCustomer@gmail.com', '1324 Fremont St CA','P124124123-I', 
                                            23532, 23, 'Mode-1', salesRepEmail, partnerAccountId, partnerAccountId,
                                            customerAccount, primaryContact, secondaryContact, opprtunityObj);
        
        
        
        
        insert proposalObj1;    

        SR_Attachment__c srAttachmentObj0 = UnitTest_ProposalUtil.CreateSRAttachment('Utility Bill', '', ''+proposalObj1.Id, 
                                                                    'TestFile01.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
        insert  srAttachmentObj0;                                                       
        
        Opportunity optyObj1 = TestPRMLibrary.insertOpportunity('ResidentialAccount-02', 'Residential',
                                                                'ResOpty-02', 'Platinum');  
        
        Proposal__C proposalObj2 = UnitTest_ProposalUtil.createProposal('1524 Fremont St CA', 'PFirstName12', 'PLastName12', 
                                            'PrimaryCustomer@gmail.com', '1524 Fremont St CA','P224124123-I', 
                                            23532, 10, 'Mode-1', salesRepEmail, partnerAccountId, partnerAccountId,
                                            customerAccount, primaryContact, secondaryContact, opprtunityObj);
        proposalObj2.Original_Proposal_ID__c = proposalObj1.Id;
        proposalObj2.Revised_Proposal__c = true;
        proposalObj2.Revised_Proposal__c = true;
        proposalObj2.System_Size_Validated_by_SR_Ops__c = true;
        proposalObj2.SR_Signoff__c = null;

        System.debug('proposalObj2.stage__c3: ' + proposalObj2.stage__c);
        proposalObj2.System_Size_STC_DC__c = 1;
        proposalObj2.Assigne__c = defaultOpsUser.Id;
        proposalObj2.Stage__c = EDPUtil.SR_OPS_APPROVED;
        proposalObj2.Submitted_By__c = PartnerDetail__c.getValues('EDPTestAccount').PartnerUserId__c;

        insert proposalObj2;            

        opprtunityObj = [Select Id, name, accountId from Opportunity where id =:proposalObj2.Opportunity__c];
        customerAccount = [Select Id, name,(Select Id, name, email from Contacts) from Account where Id =:opprtunityObj.accountId];
        primaryContact = customerAccount.contacts[0];
        secondaryContact = customerAccount.contacts[1];
        
        String envelopId1 = '';
        String proposalIdStr = '' + proposalObj2.id;
        List<OpportunityContactRole> contactRolelist = new List<OpportunityContactRole>();
        OpportunityContactRole contactRoleObj = new OpportunityContactRole();
        contactRoleObj.ContactId = primaryContact.Id;
        contactRoleObj.OpportunityId = opprtunityObj.Id;
        contactRoleObj.Role = 'Homeowner';
        contactRoleObj.IsPrimary = true;
        contactRolelist.add(contactRoleObj);
        
        contactRoleObj = new OpportunityContactRole();
        contactRoleObj.ContactId = secondaryContact.Id;
        contactRoleObj.OpportunityId = opprtunityObj.Id;
        contactRoleObj.Role = 'Other';
        contactRolelist.add(contactRoleObj);
        insert contactRolelist;
    
        Test.startTest();           
        
        envelopId1 = '1335SDFF-43643-GSGA346';
        proposalIdStr = '' + proposalObj2.id;
        List<SR_Attachment__c> srAttachmentList = new List<SR_Attachment__c>();
        SR_Attachment__c srAttachmentObj1;
        
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Customer Agreement', envelopId1, proposalIdStr, 
                                                                    'TestFile01.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentList.add(srAttachmentObj1);

        envelopId1 = '2335SDFF-43643-GSGA346';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('EPC', envelopId1, proposalIdStr, 
                                                                    'TestFile02.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentList.add(srAttachmentObj1);

        envelopId1 = '5335SDFF-43643-GSGA341';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Utility Bill', envelopId1, proposalIdStr, 
                                                                    'TestFile03.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.WET_SIGNED;
        srAttachmentList.add(srAttachmentObj1);     

        envelopId1 = '7335SDFF-43643-GSGA342';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Large System Contract Approval Request', envelopId1, proposalIdStr, 
                                                                    'TestFile04.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentList.add(srAttachmentObj1);         

        
        srAttachmentList[0].Document_Source__c = EDPUtil.E_SIGN;
        srAttachmentList[1].Document_Source__c = EDPUtil.E_SIGN;
        srAttachmentList[2].Document_Source__c = EDPUtil.E_SIGN;
        srAttachmentList[3].Document_Source__c = EDPUtil.E_SIGN;        
        insert srAttachmentList;
        

        EDPUtil.getProposalObject(proposalObj2.Id);
        EDPWebServices.sendWelcomeEmailForPartner(proposalObj2.Id);
        System.debug('Welcome Error2: ' + EDPUtil.processWelcomeEmailRequestForPartners(''+proposalObj2.Id));
        
        delete srAttachmentList;
        System.debug('Welcome Error4: ' + EDPUtil.processWelcomeEmailRequestForPartners(''+proposalObj2.Id));

        Test.stopTest();    
    }


	//Remove the comments after testing 
    public static testmethod void testInsertAttachment(){
    	  UnitTest_ProposalUtil.disableExternalServices();
        
        Id userId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
        User partnerUser = [Select id, name, email from User where Id =:userId];    
        SRAttachmentRelatedList srAttachmentListObj;    
        
            String strProposalApprovalLimit1 = Label.ProposalApprovalLimit2;
            if(strProposalApprovalLimit1 == null || strProposalApprovalLimit1 == ''){
                strProposalApprovalLimit1 = '25';
            }
            Decimal proposalLimit1 = Decimal.valueOf(strProposalApprovalLimit1);

            String partnerAccountId = PartnerDetail__c.getValues('ApexTestAccount').PartnerAccountId__C;
            String partnerContactId = PartnerDetail__c.getValues('ApexTestAccount').PartnerContactId__C;
            String partnerSalesRepId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
            String salesRepEmail = PartnerDetail__c.getValues('ApexTestAccount').PartnerContactEmail__C;
            String partnerAccountId2 = PartnerDetail__c.getValues('EDPTestAccount').PartnerAccountId__C;
    
            Account customerAccount;
            Contact primaryContact;
            Contact secondaryContact;
            Opportunity opprtunityObj;
            
            System.debug('partnerAccountId: ' + partnerAccountId);
            Proposal__C proposalObj = UnitTest_ProposalUtil.createProposal('1234 Fremont St CA', 'PFirstName1', 'PLastName1', 
                                                'PrimaryCustomer@gmail.com', '1234 Fremont St CA','P124124123-I', 
                                                23532, 23, 'Mode-1', salesRepEmail, partnerAccountId, partnerAccountId,
                                                customerAccount, primaryContact, secondaryContact, opprtunityObj);
            insert proposalObj; 
            
            String envelopId1 = '1335SDFF-43643-GSGA346';
            String proposalIdStr = '' + proposalObj.id;
             EDPUtil.processWelcomeEmailRequest(''+proposalObj.Id);
             EDPUtil.processWelcomeEmailRequestForPartners(''+proposalObj.Id);
            
            System.currentPagereference().getParameters().put('id', proposalIdStr);
            List<SR_Attachment__c> srAttachmentList = new List<SR_Attachment__c>();
            SR_Attachment__c srAttachmentObj1;
            
            String customerAgreementEnvelopId = '1335SDFF-43643-GSGA346';
            srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Utility Bill', customerAgreementEnvelopId, proposalIdStr, 
                                                                        'TestFile01.pdf', EDPUtil.E_SIGN);
            srAttachmentObj1.DocuSign_Status__c = EDPUtil.SENT;
            srAttachmentList.add(srAttachmentObj1);
            List<User> userList = EDPUtil.getSRUserDetails();
            insert srAttachmentList;
        
        	Test.startTest();
	            Set<String> envelopIds = new Set<String>();
	            envelopIds.add(customerAgreementEnvelopId);
	            SRAttachmentManager.getSRAttachments(envelopIds);
	
	            SR_Attachment__c srAttachmentObj2 = UnitTest_ProposalUtil.CreateSRAttachment('Customer Agreement', customerAgreementEnvelopId, proposalIdStr, 
	                                                                        'TestFile01.pdf', EDPUtil.SIGNED);          
	            FileUploaderComponent.SRUpsertResponse responseObj = FileUploaderComponent.upsertSRAttachment(proposalIdStr, 'TestFile12.pdf', 'TestFile13.pdf', 
	                                                    srAttachmentObj2.Document_Classification__c, 'Customer Agreement', '322',EDPUtil.SIGNED);                   
	            System.debug('responseObj: ' + responseObj);
	
	            Proposal__C proposalObj2 = UnitTest_ProposalUtil.createProposal('1524 Fremont St CA', 'PFirstName12', 'PLastName12', 
	                                                'PrimaryCustomer@gmail.com', '1524 Fremont St CA','P224124123-I', 
	                                                23532, 10, 'Mode-1', salesRepEmail, partnerAccountId, partnerAccountId,
	                                                customerAccount, primaryContact, secondaryContact, opprtunityObj);
	            insert proposalObj2;    
	            proposalObj2.Install_Partner__c = partnerAccountId2;    
	            update  proposalObj2;
            Test.stopTest();
        
        //System.runAs(partnerUser){    
        //  opprtunityObj = [Select Id, name, accountId from Opportunity where id =:proposalObj2.Opportunity__c];
        //  customerAccount = [Select Id, name,(Select Id, name, email from Contacts) from Account where Id =:opprtunityObj.accountId];
        //  primaryContact = customerAccount.contacts[0];
        //  secondaryContact = customerAccount.contacts[1];
        //  primaryContact.proposal__c = proposalObj.Id;
        //  update primaryContact;
        //} 
    }

	//Remove the comments after testing --2
    public static testmethod void testPartnerWelcomeEmail2(){
          UnitTest_ProposalUtil.disableExternalServices();
        String strProposalApprovalLimit1 = Label.ProposalApprovalLimit1;
        if(strProposalApprovalLimit1 == null || strProposalApprovalLimit1 == ''){
            strProposalApprovalLimit1 = '15';
        }

        String partnerAccountId = PartnerDetail__c.getValues('EDPTestAccount').PartnerAccountId__C;
        String partnerContactId = PartnerDetail__c.getValues('EDPTestAccount').PartnerContactId__C;
        String partnerSalesRepId = PartnerDetail__c.getValues('EDPTestAccount').PartnerUserId__c;
        String salesRepEmail = PartnerDetail__c.getValues('EDPTestAccount').PartnerContactEmail__C;

        Account customerAccount;
        Contact primaryContact;
        Contact secondaryContact;
        Opportunity opprtunityObj;

        Decimal proposalLimit1 = Decimal.valueOf(strProposalApprovalLimit1);

        Proposal__C proposalObj1 = UnitTest_ProposalUtil.createProposal('1324 Fremont St CA', 'PFirstName12', 'PLastName12', 
                                            'PrimaryCustomer@gmail.com', '1324 Fremont St CA','P124124123-I', 
                                            23532, 23, 'Mode-1', salesRepEmail, partnerAccountId, partnerAccountId,
                                            customerAccount, primaryContact, secondaryContact, opprtunityObj);
        insert proposalObj1;    

        SR_Attachment__c srAttachmentObj0 = UnitTest_ProposalUtil.CreateSRAttachment('Utility Bill', '', ''+proposalObj1.Id, 
                                                                    'TestFile01.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
        insert  srAttachmentObj0;                                                       
        
        Opportunity optyObj1 = TestPRMLibrary.insertOpportunity('ResidentialAccount-02', 'Residential',
                                                                'ResOpty-02', 'Platinum');  
        
        Proposal__C proposalObj2 = UnitTest_ProposalUtil.createProposal('1524 Fremont St CA', 'PFirstName12', 'PLastName12', 
                                            'PrimaryCustomer@gmail.com', '1524 Fremont St CA','P224124123-I', 
                                            23532, 10, 'Mode-1', salesRepEmail, partnerAccountId, partnerAccountId,
                                            customerAccount, primaryContact, secondaryContact, opprtunityObj);
        proposalObj2.Original_Proposal_ID__c = proposalObj1.Id;
        proposalObj2.Revised_Proposal__c = true;
        insert proposalObj2;            

        opprtunityObj = [Select Id, name, accountId from Opportunity where id =:proposalObj2.Opportunity__c];
        customerAccount = [Select Id, name,(Select Id, name, email from Contacts) from Account where Id =:opprtunityObj.accountId];
        primaryContact = customerAccount.contacts[0];
        secondaryContact = customerAccount.contacts[1];
        
        String envelopId1 = '';
        String proposalIdStr = '' + proposalObj2.id;
        List<OpportunityContactRole> contactRolelist = new List<OpportunityContactRole>();
        OpportunityContactRole contactRoleObj = new OpportunityContactRole();
        contactRoleObj.ContactId = primaryContact.Id;
        contactRoleObj.OpportunityId = opprtunityObj.Id;
        contactRoleObj.Role = 'Homeowner';
        contactRoleObj.IsPrimary = true;
        contactRolelist.add(contactRoleObj);
        
        contactRoleObj = new OpportunityContactRole();
        contactRoleObj.ContactId = secondaryContact.Id;
        contactRoleObj.OpportunityId = opprtunityObj.Id;
        contactRoleObj.Role = 'Other';
        contactRolelist.add(contactRoleObj);
        insert contactRolelist;

        
        
        envelopId1 = '1335SDFF-43643-GSGA346';
        proposalIdStr = '' + proposalObj2.id;
        List<SR_Attachment__c> srAttachmentList = new List<SR_Attachment__c>();
        SR_Attachment__c srAttachmentObj1;
        
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Customer Agreement', envelopId1, proposalIdStr, 
                                                                    'TestFile01.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentList.add(srAttachmentObj1);

        envelopId1 = '2335SDFF-43643-GSGA346';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('EPC', envelopId1, proposalIdStr, 
                                                                    'TestFile02.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentList.add(srAttachmentObj1);

        envelopId1 = '5335SDFF-43643-GSGA341';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Utility Bill', envelopId1, proposalIdStr, 
                                                                    'TestFile03.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.WET_SIGNED;
        srAttachmentList.add(srAttachmentObj1);     

        envelopId1 = '7335SDFF-43643-GSGA342';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Large System Contract Approval Request', envelopId1, proposalIdStr, 
                                                                    'TestFile04.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentList.add(srAttachmentObj1);         

        List<User> userList = EDPUtil.getSRUserDetails();
        
        insert srAttachmentList;
        
        
                
        User defaultOpsUser = null;
        User defaultFinanceUser = null;
            for(User userObj : userList){
                if(defaultOpsUser == null && userObj.name == EDPUtil.USER_NAME_TEST){
                    defaultOpsUser = userObj;
                }
                if(defaultFinanceUser == null && userObj.name == EDPUtil.USER_NAME_TEST){
                    defaultFinanceUser = userObj;
                }
        
                if(userObj.name == EDPUtil.USER_NAME_SR_OPS){
                    defaultOpsUser = userObj;
                }           
                else if(userObj.name == EDPUtil.USER_NAME_SR_FINANCE){
                    defaultFinanceUser = userObj;
                }
            }
        
        Test.startTest();
        
            Proposal__c proposalObj =  proposalObj2;
            proposalObj.Assigne__c = PartnerDetail__c.getValues('EDPTestAccount').PartnerUserId__c;
            EDPWebServices.submitProposal(proposalObj.Id);
            
            proposalObj.Assigne__c = defaultOpsUser.Id;
            proposalObj.Customer_SignOff_Date__c = Datetime.now();
            proposalObj.System_Size_Validated_by_SR_Ops__c = false;
            //proposalObj.Stage__c = EDPUtil.SR_OPS_REVIEWED;
            //update proposalObj;

            proposalObj.Assigne__c = defaultFinanceUser.Id;
            //update proposalObj;
        
            
            System.debug('proposalObj.stage__c1: ' + proposalObj.stage__c);
            proposalObj.Stage__c = EDPUtil.CREDIT_APPROVED;
            update proposalObj;
            System.debug('proposalObj.stage__c2: ' + proposalObj.stage__c);
            
            proposalObj.Stage__c = EDPUtil.SR_OPS_APPROVED;
            proposalObj.Revised_Proposal__c = true;
            proposalObj.System_Size_Validated_by_SR_Ops__c = false;
            proposalObj.SR_Signoff__c = null;
            update proposalObj;     
            
            Set<Id> optyIds = new Set<Id>();
            optyIds.add(proposalObj.Opportunity__c);
            EDPUtil.getApprovedProposals(optyIds);
        
            srAttachmentList[0].Document_Source__c = EDPUtil.E_SIGN;
            srAttachmentList[1].Document_Source__c = EDPUtil.E_SIGN;
            srAttachmentList[2].Document_Source__c = EDPUtil.E_SIGN;
            srAttachmentList[3].Document_Source__c = EDPUtil.E_SIGN;
            update srAttachmentList;
			
			System.debug('proposalObj.stage__c3: ' + proposalObj.stage__c);
            proposalObj.System_Size_STC_DC__c = 1;
            proposalObj.Assigne__c = defaultOpsUser.Id;
            proposalObj.Stage__c = EDPUtil.SR_OPS_APPROVED;
            proposalObj.Submitted_By__c = PartnerDetail__c.getValues('EDPTestAccount').PartnerUserId__c;
            
            //System.debug('Start update2 ..');
            update proposalObj; 
            //System.debug('End update2 ..');
            
            //EDPUtil.getProposalObject(proposalObj.Id);
            //EDPWebServices.sendWelcomeEmailForPartner(proposalObj.Id);
            //System.debug('Welcome Error2: ' + EDPUtil.processWelcomeEmailRequestForPartners(''+proposalObj.Id));
            
            //delete srAttachmentList;
            //System.debug('Welcome Error4: ' + EDPUtil.processWelcomeEmailRequestForPartners(''+proposalObj.Id));
            
            //System.runAs(defaultFinanceUser){
            //  Set<Id> opportunityIds = new Set<Id>();
            //  opportunityIds.add(opprtunityObj.Id);
            //  EDPUtil.cancelProposals(opportunityIds);
            //}
            
			Id SunrunIncId = System.Label.Sunrun_Inc_Id;
			proposalObj.sales_partner__c = SunrunIncId;
			proposalObj.install_partner__c = proposalObj.sales_partner__c;
			Contact partnerContact = new Contact();
			partnerContact.Division__c = 'Field Sales';
			proposalObj.Proposal_Source__c = '';
			ProposalUtil.calculateProposalCostStack(proposalObj, partnerContact);
			partnerContact.Division__c = '';
			ProposalUtil.calculateProposalCostStack(proposalObj, partnerContact);
			proposalObj.install_partner__c = null;
			ProposalUtil.calculateProposalCostStack(proposalObj, partnerContact);			
        Test.stopTest();    
    }

	 public static testmethod void testSubmitProposalForSecondSystem1(){
        UnitTest_ProposalUtil.disableExternalServices();
        String strProposalApprovalLimit1 = Label.ProposalApprovalLimit1;
        if(strProposalApprovalLimit1 == null || strProposalApprovalLimit1 == ''){
            strProposalApprovalLimit1 = '15';
        }

        String partnerAccountId = PartnerDetail__c.getValues('EDPTestAccount').PartnerAccountId__C;
        String partnerContactId = PartnerDetail__c.getValues('EDPTestAccount').PartnerContactId__C;
        String partnerSalesRepId = PartnerDetail__c.getValues('EDPTestAccount').PartnerUserId__c;
        String salesRepEmail = PartnerDetail__c.getValues('EDPTestAccount').PartnerContactEmail__C;

        Account customerAccount;
        Contact primaryContact;
        Contact secondaryContact;
        Opportunity opprtunityObj;

        Decimal proposalLimit1 = Decimal.valueOf(strProposalApprovalLimit1);
                                                
		Opportunity optyObj1 = TestPRMLibrary.insertOpportunity('ResidentialAccount-02', 'Residential',
                                                                'ResOpty-02', 'Platinum');  
        
        Proposal__C proposalObj2 = UnitTest_ProposalUtil.createProposal('1524 Fremont St CA', 'PFirstName12', 'PLastName12', 
                                            'PrimaryCustomer@gmail.com', '1524 Fremont St CA','P224124123-I', 
                                            23532, 10, 'Mode-1', salesRepEmail, partnerAccountId, partnerAccountId,
                                            customerAccount, primaryContact, secondaryContact, opprtunityObj);
        insert proposalObj2;            

        opprtunityObj = [Select Id, name, accountId from Opportunity where id =:proposalObj2.Opportunity__c];
        customerAccount = [Select Id, name,(Select Id, name, email from Contacts) from Account where Id =:opprtunityObj.accountId];
        primaryContact = customerAccount.contacts[0];
        secondaryContact = customerAccount.contacts[1];
        
        String envelopId1 = '';
        String proposalIdStr = '' + proposalObj2.id;
        List<OpportunityContactRole> contactRolelist = new List<OpportunityContactRole>();
        OpportunityContactRole contactRoleObj = new OpportunityContactRole();
        contactRoleObj.ContactId = primaryContact.Id;
        contactRoleObj.OpportunityId = opprtunityObj.Id;
        contactRoleObj.Role = 'Homeowner';
        contactRoleObj.IsPrimary = true;
        contactRolelist.add(contactRoleObj);
        
        contactRoleObj = new OpportunityContactRole();
        contactRoleObj.ContactId = secondaryContact.Id;
        contactRoleObj.OpportunityId = opprtunityObj.Id;
        contactRoleObj.Role = 'Other';
        contactRolelist.add(contactRoleObj);
        insert contactRolelist;
        
        envelopId1 = '1335SDFF-43643-GSGA346';
        proposalIdStr = '' + proposalObj2.id;
        List<SR_Attachment__c> srAttachmentList = new List<SR_Attachment__c>();
        SR_Attachment__c srAttachmentObj1;
        
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Customer Agreement', envelopId1, proposalIdStr, 
                                                                    'TestFile01.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentList.add(srAttachmentObj1);

        envelopId1 = '2335SDFF-43643-GSGA346';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('EPC', envelopId1, proposalIdStr, 
                                                                    'TestFile02.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentList.add(srAttachmentObj1);

        envelopId1 = '5335SDFF-43643-GSGA341';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Utility Bill', envelopId1, proposalIdStr, 
                                                                    'TestFile03.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.WET_SIGNED;
        srAttachmentList.add(srAttachmentObj1);     

        envelopId1 = '7335SDFF-43643-GSGA342';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Large System Contract Approval Request', envelopId1, proposalIdStr, 
                                                                    'TestFile04.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentList.add(srAttachmentObj1);         
        
         List<User> userList = EDPUtil.getSRUserDetails();
        
        insert srAttachmentList;


        User defaultOpsUser = null;
        User defaultFinanceUser = null;
            for(User userObj : userList){
                if(defaultOpsUser == null && userObj.name == EDPUtil.USER_NAME_TEST){
                    defaultOpsUser = userObj;
                }
                if(defaultFinanceUser == null && userObj.name == EDPUtil.USER_NAME_TEST){
                    defaultFinanceUser = userObj;
                }
        
                if(userObj.name == EDPUtil.USER_NAME_SR_OPS){
                    defaultOpsUser = userObj;
                }           
                else if(userObj.name == EDPUtil.USER_NAME_SR_FINANCE){
                    defaultFinanceUser = userObj;
                }
            }
            
		Test.startTest();  	 	
	 	 	ApexPages.StandardController stdcon = new ApexPages.StandardController(proposalObj2);
	 	 	SubmitProposal submitPropObj = new SubmitProposal(stdcon);
	 	 	submitPropObj.submitProposal();
	 	 	submitPropObj.cloneAndSubmitProposal();

			proposalObj2.Proposal_Source__c = ProposalUtil.PROPOSAL_TOOL;
			update proposalObj2;
			
			stdcon = new ApexPages.StandardController(proposalObj2);
			submitPropObj = new SubmitProposal(stdcon);
	 	 	submitPropObj.submitProposal();
	 	 	submitPropObj.cloneAndSubmitProposal();
	 	 		 	 	
	 	 Test.stoptest();  	 
	 }

	 public static testmethod void testSubmitProposalForSecondSystem2(){
        UnitTest_ProposalUtil.disableExternalServices();
        String strProposalApprovalLimit1 = Label.ProposalApprovalLimit1;
        if(strProposalApprovalLimit1 == null || strProposalApprovalLimit1 == ''){
            strProposalApprovalLimit1 = '15';
        }

        String partnerAccountId = PartnerDetail__c.getValues('EDPTestAccount').PartnerAccountId__C;
        String partnerContactId = PartnerDetail__c.getValues('EDPTestAccount').PartnerContactId__C;
        String partnerSalesRepId = PartnerDetail__c.getValues('EDPTestAccount').PartnerUserId__c;
        String salesRepEmail = PartnerDetail__c.getValues('EDPTestAccount').PartnerContactEmail__C;

        Account customerAccount;
        Contact primaryContact;
        Contact secondaryContact;
        Opportunity opprtunityObj;

        Decimal proposalLimit1 = Decimal.valueOf(strProposalApprovalLimit1);
        Proposal__C proposalObj2 = UnitTest_ProposalUtil.createProposal('1524 Fremont St CA', 'PFirstName12', 'PLastName12', 
                                            'PrimaryCustomer@gmail.com', '1524 Fremont St CA','P224124123-I', 
                                            23532, 10, 'Mode-1', salesRepEmail, partnerAccountId, partnerAccountId,
                                            customerAccount, primaryContact, secondaryContact, opprtunityObj);
        proposalObj2.Proposal_Source__c = ProposalUtil.PROPOSAL_TOOL;
        insert proposalObj2;            

        opprtunityObj = [Select Id, name, accountId from Opportunity where id =:proposalObj2.Opportunity__c];
        customerAccount = [Select Id, name,(Select Id, name, email from Contacts) from Account where Id =:opprtunityObj.accountId];
        primaryContact = customerAccount.contacts[0];
        secondaryContact = customerAccount.contacts[1];
        
        String envelopId1 = '';
        String proposalIdStr = '' + proposalObj2.id;
        List<OpportunityContactRole> contactRolelist = new List<OpportunityContactRole>();
        OpportunityContactRole contactRoleObj = new OpportunityContactRole();
        contactRoleObj.ContactId = primaryContact.Id;
        contactRoleObj.OpportunityId = opprtunityObj.Id;
        contactRoleObj.Role = 'Homeowner';
        contactRoleObj.IsPrimary = true;
        contactRolelist.add(contactRoleObj);
        
        contactRoleObj = new OpportunityContactRole();
        contactRoleObj.ContactId = secondaryContact.Id;
        contactRoleObj.OpportunityId = opprtunityObj.Id;
        contactRoleObj.Role = 'Other';
        contactRolelist.add(contactRoleObj);
        insert contactRolelist;
        
        envelopId1 = '1335SDFF-43643-GSGA346';
        proposalIdStr = '' + proposalObj2.id;
        List<SR_Attachment__c> srAttachmentList = new List<SR_Attachment__c>();
        SR_Attachment__c srAttachmentObj1;
        
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Customer Agreement', envelopId1, proposalIdStr, 
                                                                    'TestFile01.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentList.add(srAttachmentObj1);

        envelopId1 = '2335SDFF-43643-GSGA346';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('EPC', envelopId1, proposalIdStr, 
                                                                    'TestFile02.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentList.add(srAttachmentObj1);

        envelopId1 = '5335SDFF-43643-GSGA341';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Utility Bill', envelopId1, proposalIdStr, 
                                                                    'TestFile03.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.WET_SIGNED;
        srAttachmentList.add(srAttachmentObj1);     

        envelopId1 = '7335SDFF-43643-GSGA342';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Large System Contract Approval Request', envelopId1, proposalIdStr, 
                                                                    'TestFile04.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentList.add(srAttachmentObj1);         
        
         List<User> userList = EDPUtil.getSRUserDetails();
        
        insert srAttachmentList;


        User defaultOpsUser = null;
        User defaultFinanceUser = null;
            for(User userObj : userList){
                if(defaultOpsUser == null && userObj.name == EDPUtil.USER_NAME_TEST){
                    defaultOpsUser = userObj;
                }
                if(defaultFinanceUser == null && userObj.name == EDPUtil.USER_NAME_TEST){
                    defaultFinanceUser = userObj;
                }
        
                if(userObj.name == EDPUtil.USER_NAME_SR_OPS){
                    defaultOpsUser = userObj;
                }           
                else if(userObj.name == EDPUtil.USER_NAME_SR_FINANCE){
                    defaultFinanceUser = userObj;
                }
            }
            
		Test.startTest(); 
			DesignToolWebservice.DesignToolWebserviceResponse responseObj = new DesignToolWebservice.DesignToolWebserviceResponse(); 	 	
	 	 	ApexPages.StandardController stdcon = new ApexPages.StandardController(proposalObj2);
	 	 	SubmitProposal submitPropObj = new SubmitProposal(stdcon);
	 	 	//submitPropObj.responseObj = responseObj;
	 	 	submitPropObj.submitProposal();
	 	 	submitPropObj.cloneAndSubmitProposal();
			
		
			//submitPropObj.responseObj.status = ProposalUtil.SUCCESS;
	 	 	//submitPropObj.showSubmitSecond = true;
	 	 	//proposalObj2.stage__c = 'Created';
	 	 	//submitPropObj.checkProposalStage(proposalObj2);

	 	 	//submitPropObj.responseObj.status = ProposalUtil.WARNING;
	 	 	//submitPropObj.showSubmitSecond = false;
	 	 	//submitPropObj.checkProposalStage(proposalObj2);
	 	 	
			//proposalObj2.stage__c = 'SR Ops Approved';
	 	 	//submitPropObj.checkProposalStage(proposalObj2);

			//proposalObj2.stage__c = '';
	 	 	//submitPropObj.checkProposalStage(proposalObj2);

	 	 Test.stoptest();  	 
	 }

    public static testmethod void testOptySRAttachment(){
		 UnitTest_ProposalUtil.disableExternalServices();
        String strProposalApprovalLimit1 = Label.ProposalApprovalLimit2;
        if(strProposalApprovalLimit1 == null || strProposalApprovalLimit1 == ''){
            strProposalApprovalLimit1 = '25';
        }
        Decimal proposalLimit1 = Decimal.valueOf(strProposalApprovalLimit1);

        Opportunity optyObj1 = TestPRMLibrary.insertOpportunity('ResidentialAccount-03', 'Residential',
                                                                'ResOpty-03', 'Platinum');  
		
		Document_Classification__c classificationObj = [Select Id, Document_Name__c from Document_Classification__c where Document_Name__c = 'Utility Bill'];
		SR_Attachment__c srAttachmentObj = new SR_Attachment__c();
		srAttachmentObj.Document_Name_On_File_Server__c = 'Test1.pdf';
		srAttachmentObj.folder_name__c = 'qualificatondocs';
		srAttachmentObj.Parent_Proposal_Name__c = '1234567';
		srAttachmentObj.Document_Source__c = EDPDocumentSettings.MANUAL_UPLOAD;
		srAttachmentObj.Wet_Sign_Status__c = EDPDocumentSettings.NA;
		srAttachmentObj.Document_Classification__c = classificationObj.Id;
		srAttachmentObj.Document_Name__c = 'Test1.pdf';
		srAttachmentObj.active__c = true;
		srAttachmentObj.size__c = '1 MB';
		insert srAttachmentObj;
		
        List<Proposal__C> proposalList = new List<Proposal__C>();
        proposalList.add(UnitTest_ProposalUtil.getProposalObject(''+ optyObj1.Id, 'P77A13CD6KDRRF1-I', 22346, proposalLimit1, 'Mode-02', 'test02@gmail.com'));
        proposalList.add(UnitTest_ProposalUtil.getProposalObject(''+ optyObj1.Id, 'C97A13CD6KDRRF1:IIC-I', 12345, proposalLimit1, 'Mode-01', 'test01@gmail.com'));        
        insert proposalList;        
		
		Set<Id> proposalIds = new Set<Id>();
		proposalIds.add(proposalList[0].Id);
		proposalIds.add(proposalList[1].Id);
		Map<Id, Set<Id>> optyProposalMap = new Map<Id, Set<Id>>();
		optyProposalMap.put(optyObj1.Id, proposalIds);
		ProposalUtil.copySRAttachmentsToProposal(optyProposalMap);
    }	 
    /**/
}