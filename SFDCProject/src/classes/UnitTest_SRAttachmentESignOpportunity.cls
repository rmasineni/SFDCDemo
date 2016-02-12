@isTest(SeeAllData=true)
public class UnitTest_SRAttachmentESignOpportunity {

    public static testmethod void testSendEPCDocuments(){
        //Select Partner Account and Partner Contact
        String partnerAccountId = PartnerDetail__c.getValues('ApexTestAccount').PartnerAccountId__C;
        String partnerContactId = PartnerDetail__c.getValues('ApexTestAccount').PartnerContactId__C;
        String partnerSalesRepId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
        String salesRepEmail = PartnerDetail__c.getValues('ApexTestAccount').PartnerContactEmail__C;
        
        Account customerAccount;
        Contact primaryContact;
        Contact secondaryContact;
        Opportunity opprtunityObj;
        Opportunity optyObj1 = TestPRMLibrary.insertOpportunity('ResidentialAccount-3', 'Residential',
                                                                'ResOpty-3', 'Platinum');   
       
        Proposal__C proposal = [select Id from Proposal__C limit 1];
        String envelopId1 = '';
        String proposalIdStr = proposal.id;
        dsfs__DocuSign_Status__c docuStatus = new dsfs__DocuSign_Status__c(dsfs__DocuSign_Envelope_ID__c='1234ess');
        docuStatus.dsfs__Envelope_Status__c = 'Inprogress';
        insert docuStatus;
        dsfs__DocuSign_Recipient_Status__c reciStatus = UnitTest_ProposalUtil.CreateDocuSignRecipientStatus(null,'1234ess',UserInfo.getUserId(),'sttest@mail.com','Inprogress');
        insert reciStatus;
        list<dsfs__DocuSign_Recipient_Status__c> lstReciStatus = [Select Id,Name from dsfs__DocuSign_Recipient_Status__c where Id=:reciStatus.id];
        customerAccount = TestPRMLibrary.insertAccount('accountName', 'Residential');
        primaryContact = TestPRMLibrary.insertContact(customerAccount.Id, 'Residential', '', lstReciStatus[0].name, 'sttest@mail.com');
        List<SR_Attachment__c> srAttachmentList = new List<SR_Attachment__c>();
        SR_Attachment__c srAttachmentObj1;

        Map<String, String> newAttachments = new Map<String, String>();
        //Create SR Attachment

        
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Customer Agreement', envelopId1, proposalIdStr, 
                                                                    'TestFile01.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentObj1.Active__c = true;
        srAttachmentObj1.Envelop_Id__c='1234ess';
        srAttachmentObj1.Opportunity__c  = optyObj1.Id;
        srAttachmentList.add(srAttachmentObj1);

        envelopId1 = '';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('EPC', envelopId1, proposalIdStr, 
                                                                    'TestFile02.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentObj1.Envelop_Id__c='abc111';
        srAttachmentObj1.Active__c = true;
        srAttachmentObj1.Opportunity__c  = optyObj1.Id;
        srAttachmentList.add(srAttachmentObj1);

        envelopId1 = '5335SDFF-43643-GSGA341';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Utility Bill', envelopId1, proposalIdStr, 
                                                                    'TestFile03.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.WET_SIGNED;
        srAttachmentObj1.Active__c = true;
        srAttachmentObj1.Envelop_Id__c='ttttt123';
        srAttachmentObj1.Opportunity__c  = optyObj1.Id;
        srAttachmentList.add(srAttachmentObj1);     
        newAttachments.put(srAttachmentObj1.Document_Classification__c, 'TestFile03.pdf');

        envelopId1 = '7335SDFF-43643-GSGA342';
        srAttachmentObj1 = UnitTest_ProposalUtil.CreateSRAttachment('Large System Contract Approval Request', envelopId1, proposalIdStr, 
                                                                    'TestFile04.pdf', EDPUtil.MANUAL_UPLOAD_SOURCE);
        newAttachments.put(srAttachmentObj1.Document_Classification__c, 'TestFile04.pdf');
        srAttachmentObj1.DocuSign_Status__c = EDPUtil.COMPLETED;
        srAttachmentObj1.Envelop_Id__c='ccccc1112';
        srAttachmentObj1.Active__c = true;
        
        srAttachmentObj1.Opportunity__c  =optyObj1.Id;
        srAttachmentList.add(srAttachmentObj1);         
        insert srAttachmentList;
        String relatedObjectId = optyObj1.Id;
            String queryString = SRAttachmentManager.getSCAttachmentSOQL();
            String whereClause = ' where ';
            whereClause += ' Active__c = true ' ;
            whereClause += ' and Opportunity__c =:relatedObjectId ';
            queryString += whereClause;
            queryString += ' order by Document_Type_Name__c asc ';
            System.debug('queryString: ========================================================' + queryString);
            System.debug(Database.query(queryString));
            Map<String, SunRunS3Proxy_Settings__c> sunrunS3ProxySettings = SunRunS3Proxy_Settings__c.getall();
            System.debug(' SunRunS3Proxy_Settings__c sunrunS3ProxySetting == '+sunrunS3ProxySettings.get('Prospects'));
        //Initiate eSignature
        
        System.currentPagereference().getParameters().put('id', optyObj1.Id);
        System.currentPagereference().getParameters().put('OpptyEdit','false');
        SRAttachmentRelatedListOpp eSignControllerObj = new SRAttachmentRelatedListOpp();
        eSignControllerObj.setRelatedObjectId(optyObj1.Id);     
        eSignControllerObj.relatedObjectId = optyObj1.Id;
        /*
        boolean istest = eSignControllerObj.showActions;
        eSignControllerObj.getActions();
        eSignControllerObj.getSRAttachments();
        eSignControllerObj.getSRAttachmentsSize();
        boolean isShowCheck = eSignControllerObj.showCheckbox;
        eSignControllerObj.initializeSRAttachments();
        eSignControllerObj.resend();
        eSignControllerObj.updateDocuSignStatus();
        eSignControllerObj.userActions();
        eSignControllerObj.actionName = 'VoidESignature';
        eSignControllerObj.userActions();
        eSignControllerObj.actionName = 'ResendESignature';
        eSignControllerObj.userActions();
        eSignControllerObj.actionName = 'Delete';
        eSignControllerObj.userActions();
        eSignControllerObj.getSelectedIds();
        eSignControllerObj.selectSRAttachments();
        eSignControllerObj.getRefreshPage();
        eSignControllerObj.deleteSRAttachments();
        eSignControllerObj.getIsSystemAdmin();
        eSignControllerObj.getIsPartnerUser();
        eSignControllerObj.displayValue = true;
        */
        
        
        
        SRAttachmentRelatedListOpp eSignControllerObj1 = new SRAttachmentRelatedListOpp();
        eSignControllerObj1.setRelatedObjectId(optyObj1.Id);        
        eSignControllerObj1.relatedObjectId = optyObj1.Id;
        
        eSignControllerObj1.getActions();
        eSignControllerObj1.getSRAttachments();
        eSignControllerObj1.selectSRAttachments();
        eSignControllerObj1.getSRAttachmentsSize();
        eSignControllerObj1.voidESignature();
        eSignControllerObj1.resendESignature();
        eSignControllerObj1.deleteSRAttachments();
        eSignControllerObj1.userActions();
        eSignControllerObj1.actionName = 'VoidESignature';
        eSignControllerObj1.userActions();
        eSignControllerObj1.actionName = 'ResendESignature';
        eSignControllerObj1.userActions();
        eSignControllerObj1.actionName = 'Delete';
        eSignControllerObj1.userActions();
        eSignControllerObj1.getSelectedIds();
        eSignControllerObj1.selectSRAttachments();
        eSignControllerObj1.getRefreshPage();
        eSignControllerObj1.deleteSRAttachments();
        eSignControllerObj1.getIsSystemAdmin();
        eSignControllerObj1.getIsPartnerUser();
        eSignControllerObj1.displayValue = true;
        
        
        String relatedObjectId1 = optyObj1.Id;
        eSignControllerObj.isPartnerUser = false;
        eSignControllerObj.canInitiateESignature = true;
        eSignControllerObj.refreshURL = '/test';
        eSignControllerObj.getRelatedObjectId();
        String str11 = eSignControllerObj.uploadStageError;
        eSignControllerObj.voidReason = 'test';
        eSignControllerObj.displayMasterDocuments = true;
        eSignControllerObj.getActions();
        eSignControllerObj.displayMasterDocuments = false;
        eSignControllerObj.displayGeneralDocuments = true;
        eSignControllerObj.getActions();
        eSignControllerObj.getRelatedlistRefreshURL();       
        
        FileUploaderComponentOpp.checkexistingSRAttachments(relatedObjectId1, newAttachments); 
    }
}