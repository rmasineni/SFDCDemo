@isTest(SeeAllData=true)
public class UnitTestEDPUtil {
	
	public static testmethod void testContactRoles(){
		Account accountObj = TestPRMLibrary.insertAccount('TestEDP', 'Residential');
        Contact primaryContact = TestPRMLibrary.insertContact(accountObj.Id, 'Residential', 'James-1', 'Smith-1', 'James_1.Smith_1@yopmail.com');
        Contact secondaryContact = TestPRMLibrary.insertContact(accountObj.Id, 'Residential', 'James-2', 'Smith-2', 'James_2.Smith_2@yopmail.com');
        Opportunity oppotyObj = TestPRMLibrary.insertOpportunity(accountObj.Id, '595 Market St, SFO, CA', 'Platinum');

		List<OpportunityContactRole> contactRolelist = new List<OpportunityContactRole>();
        OpportunityContactRole contactRoleObj = new OpportunityContactRole();
        contactRoleObj.ContactId = primaryContact.Id;
        contactRoleObj.OpportunityId = oppotyObj.Id;
        contactRoleObj.Role = 'Homeowner';
        contactRoleObj.IsPrimary = true;
        contactRolelist.add(contactRoleObj);
        
        contactRoleObj = new OpportunityContactRole();
        contactRoleObj.ContactId = secondaryContact.Id;
        contactRoleObj.OpportunityId = oppotyObj.Id;
        contactRoleObj.Role = 'Other';
        contactRolelist.add(contactRoleObj);
        insert contactRolelist;
        
        List<Id> opportunityIds = new List<Id>();
        Set<Id> opportunityIdSet = new Set<Id>();
        opportunityIds.add(oppotyObj.Id);
        opportunityIdSet.add(oppotyObj.Id);
        EDPUtil.getOpportunityRoleMap(opportunityIds);
        EDPUtil.getContactRoles(opportunityIdSet);
        EDPUtil.isPartnerPortalURL();
        
        Proposal__c prposalObj = new Proposal__c();
        Id partnerId1 = '0016000000xSz4Q';
        Id partnerId2 = '0016000000xABCQ';
        prposalObj.Sales_Partner__c = partnerId1;
        prposalObj.Sales_Partner__c = partnerId2;
        EDPUtil.getPartnerType(prposalObj,partnerId1);
        EDPUtil.getPartnerType(prposalObj,partnerId2);
		
		Set<Id> accountIds = new Set<Id>();
		accountIds.add(System.Label.Sunrun_Inc_Id);
		EDPUtil.getHeadquartersLocation(accountIds);
		EDPUtil.generateVerificationToken();
		//OrgWideEmailAddress oweaObj = EDPUtil.getOrgWideEmailAddress(Label.Sunrun_Customer_Care_Email);
	}
	
	public static void testProposal(){
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
        proposalObj1.stage__C = EdpUtil.SUBMITTED;
        insert proposalObj1;
            
		EDPUtil.getProposalObject(proposalObj1.Id);
		
		Set<Id> opportunityIds = new Set<Id>();
		opportunityIds.add(opprtunityObj.Id);
		
		Map<Id, Map<Id, Proposal__C>> submittedProposalMapForOptys = new Map<Id, Map<Id, Proposal__C>>();
		Map<Id, Map<Id, Proposal__C>> proposalsByOpty = new Map<Id, Map<Id, Proposal__C>>();
		EDPUtil.getSubmittedProposals(opportunityIds, submittedProposalMapForOptys, proposalsByOpty );

	}

}