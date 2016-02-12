@isTest(SeeAllData=true)
public class Test_FileUploaderComponentOpp {
    public static testMethod void TestFileUploaderComponent(){
        
        Id userId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
        User partnerUser = [Select id, name, email from User where Id =:userId];
        //Test.startTest();
        List<Document_Classification__c> docClassList = new List<Document_Classification__c>();
        
        Document_Classification__c docClassRec1 = new Document_Classification__c();
        docClassRec1.Name = 'Test Customer Agreement';
        docClassRec1.Document_Name__c = 'Test Customer Agreement';
        docClassRec1.Allow_To_Over_Write__c = true;
        docClassList.add(docClassRec1);
        
        Document_Classification__c docClassRec2 = new Document_Classification__c();
        docClassRec2.Name = 'Test Customer Agreement1';
        docClassRec2.Document_Name__c = 'Test Customer Agreement1';
        docClassRec2.Allow_To_Over_Write__c = false;
        docClassList.add(docClassRec2);
        
        insert(docClassList);
        
        //System.runAs(partnerUser){
        
        Opportunity optyObj1 = TestPRMLibrary.insertOpportunity('ResidentialAccount-3', 'Residential',
                                                                'ResOpty-3', 'Platinum');   
        List<Proposal__c> proposalList = new List<Proposal__c>();
        Proposal__c proposalObj1 = new Proposal__c();
        proposalObj1.Name = 'P87A13E7174V1BN-H';
        proposalObj1.Opportunity__c = optyObj1.Id;
        proposalObj1.Upfront_Payment__c = 1000;
        proposalObj1.Proposal_ID__c = 2441242;
        proposalObj1.System_Size_STC_DC__c = 1;
        proposalObj1.Mode_Name__c = 'Mode-1';
        proposalObj1.Date_Issued__c =  date.today();
        proposalObj1.Sales_Rep_Email__c = 'test@gmail.com';
        proposalList.add(proposalObj1);

        Proposal__c proposalObj2 = new Proposal__c();
        proposalObj2.Name = 'Proposal-2';
        proposalObj2.Opportunity__c = optyObj1.Id;
        proposalObj2.Upfront_Payment__c = 1000;
        proposalObj2.Proposal_ID__c = 2441242;
        proposalObj2.System_Size_STC_DC__c = 1;
        proposalObj2.Mode_Name__c = 'Mode-2';
        proposalObj2.Date_Issued__c =  date.today();
        proposalObj2.Sales_Rep_Email__c = 'test2@gmail.com';
        proposalObj2.Change_Order_With_New_Proposal__c = true;
        proposalList.add(proposalObj2); 
        // insert proposalList;
        
        
        List<SR_Attachment__c> srAttachmentList = new List<SR_Attachment__c>();
        SR_Attachment__c srAttachmentObj1;
        List<Proposal__C> lstProposal = [select Id from Proposal__C limit 1];
        String envelopId1 = '';
        String proposalIdStr = lstProposal[0].Id;
        Map<String, String> newAttachments = new Map<String, String>();
        //Create SR Attachment

        
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Customer Agreement', envelopId1, proposalIdStr, 
                                                                    'TestFile01.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentObj1.Active__c = true;
        srAttachmentObj1.Opportunity__c  = optyObj1.Id;
        srAttachmentList.add(srAttachmentObj1);

        envelopId1 = '';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('EPC', envelopId1, proposalIdStr, 
                                                                    'TestFile02.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentObj1.Active__c = true;
        srAttachmentObj1.Opportunity__c  = optyObj1.Id;
        srAttachmentList.add(srAttachmentObj1);

        envelopId1 = '5335SDFF-43643-GSGA341';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Utility Bill', envelopId1, proposalIdStr, 
                                                                    'TestFile03.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.WET_SIGNED;
        srAttachmentObj1.Active__c = true;
        srAttachmentObj1.Opportunity__c  = optyObj1.Id;
        srAttachmentList.add(srAttachmentObj1);     
        newAttachments.put(srAttachmentObj1.Document_Classification__c, 'TestFile03.pdf');

        envelopId1 = '7335SDFF-43643-GSGA342';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Large System Contract Approval Request', envelopId1, proposalIdStr, 
                                                                    'TestFile04.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
        newAttachments.put(srAttachmentObj1.Document_Classification__c, 'TestFile04.pdf');
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentObj1.Active__c = true;
        
        srAttachmentObj1.Opportunity__c  =optyObj1.Id;
        srAttachmentList.add(srAttachmentObj1);         
        insert srAttachmentList;


        
       
        
        //ApexPages.StandardController stdcon = new ApexPages.StandardController(proposalObj1);
        ApexPages.StandardController stdcon = new ApexPages.StandardController(optyObj1);
        FileUploader FileUploaderObj1 = new FileUploader(stdcon);
        FileUploader FileUploaderObj = new FileUploader();
        Id relatedObjectId = FileUploaderObj.relatedObjectId;
        
        FileUploaderComponentOpp FileUploaderComponentObj = New FileUploaderComponentOpp();
        
        //FileUploaderComponentObj.relatedObject = 'a08g0000000J8Ao';
        FileUploaderComponentObj.relatedObject = optyObj1.id;
        
        FileUploaderComponentObj.getBaseURL();
        FileUploaderComponentObj.getDocumentTypes();
        FileUploaderComponentObj.getExistingSRAttachments();
        FileUploaderComponentObj.getDocumentClasification();

        FileUploaderComponentOpp.ExistingAttachmentsResponse ExistingAttachmentsResponseObj = new FileUploaderComponentOpp.ExistingAttachmentsResponse();
        FileUploaderComponentOpp.UpsertRequest UpsertRequestObj = new FileUploaderComponentOpp.UpsertRequest();
        FileUploaderComponentOpp.SRUpsertResponse SRUpsertResponseObj = new FileUploaderComponentOpp.SRUpsertResponse();
        
        //String relatedObjectId1 = 'a08g0000000J8Ao';
        String relatedObjectId1 = optyObj1.id;
        //Map<String, String> newAttachments = new Map<String, String>();
        newAttachments.put(docClassRec1.id, 'Filename1');
        newAttachments.put(docClassRec2.id, 'Filename2');   
    
        FileUploaderComponentOpp.checkexistingSRAttachments(relatedObjectId1, newAttachments); 
        
        String proposalName = optyObj1.id;
        String objectName = optyObj1.id;
        String mimeType = 'pdf';
        String sObjectType = '';
        FileUploaderComponentOpp.getS3ProxyInfoForPut(sObjectType, proposalName, objectName, mimeType);
        
        string test = 'Test';
        //FileUploaderComponent.deleteSelectedRecords(test);
        
        String strDocType = 'Utility';
        FileUploaderComponentOpp.DocSignStatus(strDocType);
        
        String parentObjectId = optyObj1.id;
        String fileName = 'TestFilename';
        String amazonS3FileName = 'TestFilename20130523903';
        String contactDocumentType = 'Utility'; 
        String contactDocumentTypeName = 'Utility';
        String fileSize = '3000';
        String contactDocumentWetSign = 'Signed';
        FileUploaderComponentOpp.upsertSRAttachment(parentObjectId, fileName, amazonS3FileName, contactDocumentType, contactDocumentTypeName, fileSize, contactDocumentWetSign);
        FileUploaderComponentObj.getExistingSRAttachments();
        FileUploaderComponentOpp.UpsertRequest UR = new FileUploaderComponentOpp.UpsertRequest();
        UR.relatedObjectId = 'ab';
        UR.fileName = 'ab';
        UR.amazonS3FileName = 'ab';
        UR.documentType = 'ab';
        UR.documentTypeName = 'ab';
        UR.size = 'ab';
        UR.wetSign = 'ab';
        UR.conentType = 'ab';
        
       // }
       // Test.stopTest();
    }
}