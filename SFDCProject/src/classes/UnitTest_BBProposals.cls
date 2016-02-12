@isTest(SeeAllData=true)
public class UnitTest_BBProposals {
	
	public static testMethod void testNodeProposals(){
		Proposal__c proposal  = UnitTest_ServiceContractUtil.createTestProposal();
		proposal.name = 'PKRN9CF4661C-A';
		proposal.Signed__c = true;
		Proposal.Proposal_Source__c = 'BB';
		insert proposal;   
		
		String proposalIdStr = '' + proposal.Id;
		String envelopId1 = '';
		List<SR_Attachment__c> srAttachmentList = new List<SR_Attachment__c>();
		SR_Attachment__c srAttachmentObj1;
		srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Customer Agreement', envelopId1, proposalIdStr, 
																	'TestFile01.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
		srAttachmentList.add(srAttachmentObj1);
		
		envelopId1 = '1335SDFF-43643-GSGA346';
		srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Customer Agreement', envelopId1, proposalIdStr, 
																	'TestFile01.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);																	
		srAttachmentList.add(srAttachmentObj1);

		srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Customer Agreement', envelopId1, proposalIdStr, 
																	'TestFile03.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);		
		srAttachmentObj1.Partner_Name__c = 'Sungevity';
		srAttachmentObj1.Proposal_Document_Type__c = 'Customer Agreement';
		srAttachmentObj1.Parent_Proposal_Name__c = proposal.name;
		srAttachmentList.add(srAttachmentObj1);
		
		srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Other', envelopId1, proposalIdStr, 
																	'TestFile04.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);		
		srAttachmentObj1.Partner_Name__c = 'Sungevity';
		srAttachmentObj1.Proposal_Document_Type__c = 'Other';
		srAttachmentObj1.Parent_Proposal_Name__c = proposal.name;
		srAttachmentList.add(srAttachmentObj1);		
		insert srAttachmentList;
		
		Map<Id, String> signedProposalMap = new Map<Id, String>();
		String signedRootId = ProposalUtil.getSignedRootId(proposal, true);
		signedProposalMap.put(proposal.Id, signedRootId);

		Proposal__c nodeproposal  = UnitTest_ServiceContractUtil.createTestProposal();
		nodeproposal.name = 'HPKRN9CF4661C:003-A';
		nodeproposal.Proposal_Source__c = ProposalUtil.BLACK_BIRD;
		nodeproposal.Proposal_Type__c = ProposalUtil.NODE;
		nodeproposal.Change_Order_Information__c = ProposalUtil.FULL_PROPOSAL;
		nodeproposal.Sunrun_Credit_Status__c = EDPUtil.CREDIT_APPROVED;
		nodeproposal.Original_Proposal_ID__c = proposal.Id;
		//nodeproposal.Signed__c = true;
		nodeproposal.Proposal_Source__c = 'BB';
		insert nodeproposal; 
		
		ProposalUtil.setParentProposalInformation(nodeproposal, proposal);
		ProposalUtil.copyCreditInformation(nodeproposal);
		ProposalUtil.copyCreditInformation(nodeproposal, proposal);
		Set<Id> parentProposalIds = new Set<Id>();
		parentProposalIds.add(proposal.Id);
		ProposalUtil.updateChildproposalsForCreditInfo(parentProposalIds);
		
		parentProposalIds.add(nodeproposal.Id);
		List<Proposal__c> proposallist = ProposalUtil.getProposals(parentProposalIds);
		
		Test.startTest();
			boolean forceVoid = true;
			Map<Id, Proposal__C> proposalMap = new Map<Id, Proposal__C>();
			proposalMap.put(nodeproposal.Id,  nodeproposal);
	
			boolean result = ProposalUtil.hasActiveProposals(proposal.Opportunity__c);
			Set<Id> proposalIds = new Set<Id>();
			proposalIds.add(proposal.Id);
			Map<Id, Map<Id, Proposal__c> > childNodes = new Map<Id, Map<Id, Proposal__c> >();
			ProposalUtil.getActiveChildNodes(proposalIds,childNodes);
			ProposalUtil.getSignedRootProposalName(proposal);
			
			Map<Id, Set<Id>> opportunityProposalMap = new Map<Id, Set<Id>>();
			opportunityProposalMap.put(proposal.Opportunity__c, proposalIds);
			ProposalUtil.inactivateChildProposals(opportunityProposalMap, proposalIds, proposalIds);
			
	
			Map<Id, String> reasonMap = new  Map<Id, String>();
			reasonMap.put(nodeproposal.Id, 'Test');
			ProposalUtil.voidProposals(proposalMap, reasonMap, forceVoid);
			//ProposalUtil.processNewlyCreatedBBProposals(submittedNodeMap, signedProposalMap, true, true);
		Test.stopTest();
	}
	
}