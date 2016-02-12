@isTest(SeeAllData=true)
public class UnitTest_ProposalUtil {
    
	public static void disableExternalServices(){
		/*
	 	Sf.settingsService.setString('AddressStandardizationForAcctsEnabled', 'false'); 
	 	Sf.settingsService.setString('AddressStandardizationForLeadsEnabled', 'false'); 
	 	Sf.settingsService.setString('AmbassadorRealtimeSyncEnabled', 'false'); 
	 	Sf.settingsService.setString('AwsOptysSqsSyncEnabled', 'false'); 
	 	Sf.settingsService.setString('AwsOptysSqsRealtimeSyncEnabled', 'false'); 
	 	Sf.settingsService.setString('AwsLeadsSqsSyncEnabled', 'false'); 
	 	Sf.settingsService.setString('AwsLeadsSqsRealtimeSyncEnabled', 'false'); 
	 	Sf.settingsService.setString('SobjectAuditCaptureEnabled', 'false'); 
	 	*/
	 	Sf.settingsService.setString('AwsSqsLeadsSyncEnabled', 'false'); 
	 	Sf.settingsService.setString('AwsSqsOptysSyncEnabled', 'false'); 
	 	Sf.settingsService.setString('AwsSqsContractsSyncEnabled', 'false'); 
	 	Sf.settingsService.setString('AwsSqsProposalsSyncEnabled', 'false'); 
	 	Sf.settingsService.setString('AwsSqsPaymentsSyncEnabled', 'false'); 
	 	Sf.settingsService.setString('AwsSqsCreditsSyncEnabled', 'false'); 

	}
    
    public static dsfs__DocuSign_Status__c CreateDocuSignStatus(String envelopId, String status) {
        dsfs__DocuSign_Status__c docuSignStatusObj = new dsfs__DocuSign_Status__c();
        docuSignStatusObj.dsfs__DocuSign_Envelope_ID__c = envelopId;
        docuSignStatusObj.dsfs__Envelope_Status__c = status;
        return  docuSignStatusObj;
    }

    public static dsfs__DocuSign_Recipient_Status__c CreateDocuSignRecipientStatus(String docuSignStatusId, String envelopId, String recipientId, 
                                                                                    String recipientEmail, String status) {
        dsfs__DocuSign_Recipient_Status__c docuSignRecipientStatusObj = new dsfs__DocuSign_Recipient_Status__c();
        docuSignRecipientStatusObj.dsfs__Envelope_Id__c = envelopId;
        docuSignRecipientStatusObj.dsfs__DocuSign_Recipient_Id__c = recipientId;
        docuSignRecipientStatusObj.dsfs__DocuSign_Recipient_Email__c = recipientEmail;
        docuSignRecipientStatusObj.dsfs__Recipient_Status__c = status;
        docuSignRecipientStatusObj.dsfs__Parent_Status_Record__c = docuSignStatusId;
        return  docuSignRecipientStatusObj;
    }
    

    public static Proposal__c createProposal(String accountName, String firstName, String lastName, 
                                            String customerEmail, String opptyName, String ProposalName, 
                                            Integer proposalId, Decimal proposalLimit, String modeValue,
                                            String salesRepEmail, String salesPartnerId, String installPartnerId,
                                            Account accountObj, Contact primaryContact, Contact secondaryContact, 
                                            Opportunity oppotyObj){
        
        System.debug('salesRepEmail: ' + salesRepEmail);
        System.debug('salesPartnerId: ' + salesPartnerId);
        System.debug('installPartnerId: ' + installPartnerId);
        
        Proposal__C proposalObj = new Proposal__C();
        accountObj = TestPRMLibrary.insertAccount(accountName, 'Residential');
        primaryContact = TestPRMLibrary.insertContact(accountObj.Id, 'Residential', firstName+ '-1', lastName+'-1', 'first.' + customerEmail);
        secondaryContact = TestPRMLibrary.insertContact(accountObj.Id, 'Residential', firstName+ '-2', lastName+'-2', 'second.' + customerEmail);
        oppotyObj = TestPRMLibrary.insertOpportunity(accountObj.Id, opptyName, 'Platinum');

        proposalObj.Name = ProposalName;
        proposalObj.Opportunity__c = oppotyObj.Id;
        proposalObj.Upfront_Payment__c = 1000;
        proposalObj.Proposal_ID__c = proposalId;
        proposalObj.System_Size_STC_DC__c = proposalLimit;
        proposalObj.Mode_Name__c = modeValue;
        proposalObj.Date_Issued__c =  date.today();
        proposalObj.Sales_Rep_Email__c = salesRepEmail; 
        proposalObj.Sales_Partner__c = salesPartnerId;
        proposalObj.Install_Partner__c = installPartnerId;
        proposalObj.EDP_Phase__c = 'EDP Phase-1';
        System.debug('salesPartnerId: ' + salesPartnerId);
        System.debug('installPartnerId: ' + installPartnerId);
        return proposalObj;
    }

 
    public static SR_Attachment__c CreateOptySRAttachment(Id optyId) {
        SR_Attachment__c srAttachmentObj = new SR_Attachment__c();
        srAttachmentObj.Active__c = true;
        srAttachmentObj.Opportunity__c = optyId;
        srAttachmentObj.DocuSign_Status__c = '';
        srAttachmentObj.Envelop_Id__c = '';
        srAttachmentObj.Wet_Sign_Status__c = '';
        srAttachmentObj.Document_Classification__c = '';
        return srAttachmentObj;
    }

    
    public static SR_Attachment__c CreateSRAttachment(Id proposalId) {
        SR_Attachment__c srAttachmentObj = new SR_Attachment__c();
        srAttachmentObj.Active__c = true;
        srAttachmentObj.Proposal__c = proposalId;
        srAttachmentObj.DocuSign_Status__c = '';
        srAttachmentObj.Envelop_Id__c = '';
        srAttachmentObj.Wet_Sign_Status__c = '';
        srAttachmentObj.Document_Classification__c = '';
        return srAttachmentObj;
    }


    public static SR_Attachment__c CreateSCSRAttachment(String documentTypeName, String optyId,String documentName, String documentSource) {
        Map<String, Document_Classification__c> documentClassificationMap = EDPDocumentSettings.getDocumentSettingsInformation();
        System.debug('documentClassificationMap: ' + documentClassificationMap);
        Document_Classification__c documentClassificationObj = documentClassificationMap.get(documentTypeName);
        SR_Attachment__c srAttachmentObj = new SR_Attachment__c();
        srAttachmentObj.Active__c = true;
        srAttachmentObj.DocuSign_Status__c = '';
        srAttachmentObj.Wet_Sign_Status__c = '';
        srAttachmentObj.Document_Classification__c = documentClassificationObj.Id;
        srAttachmentObj.Document_Source__c = documentSource;
        srAttachmentObj.Document_Name__c = documentName;
        srAttachmentObj.Document_Name_On_File_Server__c = documentName;
        srAttachmentObj.Service_Contract__c = optyId;
        return srAttachmentObj;
    }

    public static SR_Attachment__c CreateOptySRAttachment(String documentTypeName, String optyId,String documentName, String documentSource) {
        Map<String, Document_Classification__c> documentClassificationMap = EDPDocumentSettings.getDocumentSettingsInformation();
        System.debug('documentClassificationMap: ' + documentClassificationMap);
        Document_Classification__c documentClassificationObj = documentClassificationMap.get(documentTypeName);
        SR_Attachment__c srAttachmentObj = new SR_Attachment__c();
        srAttachmentObj.Active__c = true;
        srAttachmentObj.DocuSign_Status__c = '';
        srAttachmentObj.Wet_Sign_Status__c = '';
        srAttachmentObj.Document_Classification__c = documentClassificationObj.Id;
        srAttachmentObj.Document_Source__c = documentSource;
        srAttachmentObj.Document_Name__c = documentName;
        srAttachmentObj.Document_Name_On_File_Server__c = documentName;
        srAttachmentObj.Opportunity__c = optyId;
        return srAttachmentObj;
    }

    public static SR_Attachment__c CreateSRAttachment(String documentTypeName, String envelopId, String proposalId, 
                                                    String documentName, String documentSource) {
        Map<String, Document_Classification__c> documentClassificationMap = EDPDocumentSettings.getDocumentSettingsInformation();
        System.debug('documentClassificationMap: ' + documentClassificationMap);
        Document_Classification__c documentClassificationObj = documentClassificationMap.get(documentTypeName);
        SR_Attachment__c srAttachmentObj = new SR_Attachment__c();
        srAttachmentObj.Active__c = true;
        srAttachmentObj.DocuSign_Status__c = '';
        srAttachmentObj.Wet_Sign_Status__c = '';
        srAttachmentObj.Document_Classification__c = documentClassificationObj.Id;
        srAttachmentObj.Document_Source__c = documentSource;
        srAttachmentObj.Envelop_Id__c = envelopId;
        srAttachmentObj.Document_Name__c = documentName;
        srAttachmentObj.Document_Name_On_File_Server__c = documentName;
        srAttachmentObj.proposal__C = proposalId;
        return srAttachmentObj;
    }
    
    public static Proposal__C getProposalObject(String optyId, String proposalName, Integer proposalId, Decimal proposalLimit,
                                                String modeValue, String salesRepEmail){
        Proposal__C proposalObj1 = new Proposal__C();
        proposalObj1.Name = proposalName;
        proposalObj1.Opportunity__c = optyId;
        proposalObj1.Upfront_Payment__c = 1000;
        proposalObj1.Proposal_ID__c = proposalId;
        proposalObj1.System_Size_STC_DC__c = proposalLimit;
        proposalObj1.Mode_Name__c = modeValue;
        proposalObj1.Date_Issued__c =  date.today();
        proposalObj1.Sales_Rep_Email__c = salesRepEmail;
        proposalObj1.EDP_Phase__c = 'EDP Phase-1';
        return proposalObj1;        
    }
    

   
    
    

}