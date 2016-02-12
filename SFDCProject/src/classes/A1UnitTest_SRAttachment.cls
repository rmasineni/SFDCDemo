@isTest(SeeAllData=true)
public class A1UnitTest_SRAttachment {

   public static testmethod void testSRAttachmentInsert(){
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
		List<SR_Attachment__c> srAttachmentList = new List<SR_Attachment__c>();
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

        insert srAttachmentList;

        proposalList[0].Customer_SignOff_Date__c = Datetime.now();
        proposalList[0].SR_Signoff__c = Datetime.now();
        proposalList[0].Revised_SR_Signoff__c = Datetime.now();
        proposalList[0].Stage__c = EDPUtil.CREDIT_APPROVED; 

        update proposalList;

        Proposal__c proposalObj =  proposalList[0];
        proposalObj.Stage__c = EDPUtil.PENDING;
        proposalObj.Pending_Proposal_Reason__c = EDPUtil.PENDING;
        proposalObj.Pending_notes__c = 'TestComments';
        proposalObj.Submitted_By__c = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
        
        update proposalObj;
        
        Task taskObj = [Select Id,whatId, Status, Original_Task_Owner__c from task where whatId =:proposalObj.Id];
        taskObj.Status = EDPUtil.RESOLVED;
        update taskObj;
        
        SRAttachmentRelatedList srAttachmentListObj;    
        srAttachmentListObj = new SRAttachmentRelatedList();
        srAttachmentListObj.displayMasterDocuments = true;
        srAttachmentListObj.relatedObjectId = proposalObj.Id;
        srAttachmentListObj.initializeSRAttachments();
        srAttachmentListObj.getActions();
        String htmlBody = PRMEmailManager.getChangeOrderHTMLBody(proposalObj);

    }
}