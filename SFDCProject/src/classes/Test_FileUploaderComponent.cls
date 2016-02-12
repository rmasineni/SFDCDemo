@isTest (SeeAllData=true)
public with sharing class Test_FileUploaderComponent {
	public static testmethod void TestFileUploaderComponent(){
		
		Id userId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
		User partnerUser = [Select id, name, email from User where Id =:userId];
		Test.startTest();
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
		
		System.runAs(partnerUser){
		
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
		insert proposalList;
		
		ApexPages.StandardController stdcon = new ApexPages.StandardController(proposalObj1);
		FileUploader FileUploaderObj1 = new FileUploader(stdcon);
		FileUploader FileUploaderObj = new FileUploader();
		Id relatedObjectId = FileUploaderObj.relatedObjectId;
		
		FileUploaderComponent FileUploaderComponentObj = New FileUploaderComponent();
		
		//FileUploaderComponentObj.relatedObject = 'a08g0000000J8Ao';
		FileUploaderComponentObj.relatedObject = proposalObj1.id;
		
		FileUploaderComponentObj.getBaseURL();
		FileUploaderComponentObj.getDocumentTypes();
		FileUploaderComponentObj.getExistingSRAttachments();
		FileUploaderComponentObj.getDocumentClasification();

		FileUploaderComponent.ExistingAttachmentsResponse ExistingAttachmentsResponseObj = new FileUploaderComponent.ExistingAttachmentsResponse();
		FileUploaderComponent.UpsertRequest UpsertRequestObj = new FileUploaderComponent.UpsertRequest();
		FileUploaderComponent.SRUpsertResponse SRUpsertResponseObj = new FileUploaderComponent.SRUpsertResponse();
		
		//String relatedObjectId1 = 'a08g0000000J8Ao';
		String relatedObjectId1 = proposalObj1.id;
		Map<String, String> newAttachments = new Map<String, String>();
		newAttachments.put(docClassRec1.id, 'Filename1');
		newAttachments.put(docClassRec2.id, 'Filename2'); 	
	
		FileUploaderComponent.checkexistingSRAttachments(relatedObjectId1, newAttachments);	
		
		String proposalName = proposalObj1.Name;
		String objectName = 'Filename1';
		String mimeType = 'pdf';
		String sObjectType = '';
		FileUploaderComponent.getS3ProxyInfoForPut(sObjectType, proposalName, objectName, mimeType);
		
		string test = 'Test';
		//FileUploaderComponent.deleteSelectedRecords(test);
		
		String strDocType = 'Utility';
		FileUploaderComponent.DocSignStatus(strDocType);
		
		String parentObjectId = proposalObj1.id;
		String fileName = 'TestFilename';
		String amazonS3FileName = 'TestFilename20130523903';
		String contactDocumentType = 'Utility'; 
		String contactDocumentTypeName = 'Utility';
		String fileSize = '3000';
		String contactDocumentWetSign = 'Signed';
		FileUploaderComponent.upsertSRAttachment(parentObjectId, fileName, amazonS3FileName, contactDocumentType, contactDocumentTypeName, fileSize, contactDocumentWetSign);
		
		}
		Test.stopTest();
	}
}