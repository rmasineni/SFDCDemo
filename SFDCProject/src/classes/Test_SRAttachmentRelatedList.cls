@isTest (SeeAllData=true)
public class Test_SRAttachmentRelatedList {
	public static testMethod void TestSRAttachmentRelatedList(){
		
		Id userId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
		User partnerUser = [Select id, name, email from User where Id =:userId];
		Test.startTest();
		System.runAs(partnerUser){
		
		Opportunity optyObj1 = TestPRMLibrary.insertOpportunity('ResidentialAccount-3', 'Residential',
																'ResOpty-3', 'Platinum');	
		List<Proposal__C> proposalList = new List<Proposal__C>();
		Proposal__C proposalObj1 = new Proposal__C();
		proposalObj1.Name = 'P87A13E7174V1BN-H';
		proposalObj1.Opportunity__c = optyObj1.Id;
		proposalObj1.Upfront_Payment__c = 1000;
		proposalObj1.Proposal_ID__c = 2441242;
		proposalObj1.System_Size_STC_DC__c = 1;
		proposalObj1.Mode_Name__c = 'Mode-1';
		proposalObj1.Date_Issued__c =  date.today();
		proposalObj1.Sales_Rep_Email__c = 'test@gmail.com';
		Insert proposalObj1;
		
		SRAttachmentRelatedList SRAttachmentRelatedListObj = new SRAttachmentRelatedList();
		
		SRAttachmentRelatedListObj.relatedObjectId = proposalObj1.id;
		
		SRAttachmentRelatedListObj.deleteSRAttachments();
		SRAttachmentRelatedListObj.getActions();
		SRAttachmentRelatedListObj.getIsPartnerUser();
		SRAttachmentRelatedListObj.getIsSystemAdmin();
		SRAttachmentRelatedListObj.getRelatedObjectId();
		SRAttachmentRelatedListObj.getSRAttachments();
		SRAttachmentRelatedListObj.getSRAttachmentsSize();
		SRAttachmentRelatedListObj.initializeSRAttachments();
		SRAttachmentRelatedListObj.resend();
		SRAttachmentRelatedListObj.resendESignature();
		//SRAttachmentRelatedListObj.setRelatedObjectId(relatedObjIdVal);
		SRAttachmentRelatedListObj.updateDocuSignStatus();
		SRAttachmentRelatedListObj.actionName = '';
		SRAttachmentRelatedListObj.userActions();
		SRAttachmentRelatedListObj.actionName = 'VoidESignature';
		SRAttachmentRelatedListObj.userActions();
		SRAttachmentRelatedListObj.actionName = 'ResendESignature';
		SRAttachmentRelatedListObj.userActions();
		SRAttachmentRelatedListObj.actionName = 'Delete';
		SRAttachmentRelatedListObj.userActions();

		Test.stopTest();
		}
	}
}