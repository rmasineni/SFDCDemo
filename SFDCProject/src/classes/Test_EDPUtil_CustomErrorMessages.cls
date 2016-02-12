@isTest (SeeAllData=true)
public class Test_EDPUtil_CustomErrorMessages {
	public static testMethod void TestEDPUtil(){
		
		Id userId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
		User partnerUser = [Select id, name, email from User where Id =:userId];
	
		System.runAs(partnerUser){
		
		Test.startTest();
			EDPUtil EDPUtilObj = new EDPUtil();
							
			Account accountRec = new Account();
	        accountRec.Name = 'Test Account Oppties';
	        insert accountRec;
	        //
	        Contact contactRec = new Contact();
	        contactRec.FirstName = 'TestAcct';
	        contactRec.LastName = 'TestAcctOppty';
	        contactRec.Email = 'emailfake@sunrun.com';
	        contactRec.AccountId = accountRec.Id;
	        insert contactRec;
	        //
	        Profile profile = [ Select id,name from Profile where UserType = 'Standard' LIMIT 1];
	        
	        User u1 = new User( email='test-user11@fakeemail.com', profileid = profile.id, 
	                UserName='test-user11@fakeemail.com', alias='tusr11', CommunityNickName='tusr11', 
			        TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
			        LanguageLocaleKey='en_US', FirstName = 'Test', LastName = 'User',Title = 'Key User' );
	       insert u1;
	        
	        Opportunity Opp = new Opportunity();
	        Opp.Name = 'TestOpptyTriggers';
	        Opp.StageName = 'Qualified';
	        Opp.CloseDate = Date.Today().addDays(18);    
	        Opp.AccountId = accountRec.Id;
	        Opp.Sales_Representative__c = contactRec.Id;    
	        Opp.Credit_Status__c = 'Approved';   
	        insert Opp;
	        
	        Proposal__c proposalObj = new Proposal__c();
	        proposalObj.Opportunity__c = Opp.Id;
	        proposalObj.Assigne__c = u1.Id;        
	        proposalObj.Stage__c = 'Created';  
	        proposalObj.Sales_Rep_Email__c = 'therepsemail@repemailfake.com';
	        proposalObj.Date_Issued__c = Date.Today().addDays(18); 
	        proposalObj.Mode_Name__c = '1234';
	        proposalObj.System_Size_STC_DC__c  = 5.8;
	        proposalObj.Upfront_Payment__c = 20.0;
			insert proposalObj;
			
			String profileName = profile.Name;
			Set<String> profileNames = new Set<String>{profileName};
			EDPUtil.getProfiles(profileNames);
			
			Set<Id> userIds = new Set<Id>();
			userIds.add(PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c);
			userIds.add(PartnerDetail__c.getValues('EDPTestAccount').PartnerUserId__c);
			EDPUtil.getUserdetails(userIds);
			
			EDPUtil.getSRUserDetails();
			EDPUtil.getLoginUser();
			
			
			Set<String> nameSet = new Set<String>{'John', 'David'};
			EDPUtil.getUserDetails(nameSet);
			
			Id proposalId = proposalObj.id;
			Set<Id> proposalIds = new Set<Id>{proposalId}; 
			EDPUtil.getProposals(proposalIds);
			
			Id opptyId = Opp.Id;
			Set<Id> opportunityIds = new Set<Id>{opptyId};
			List<Id> listopportunityIds = new List<Id>{opptyId};
			EDPUtil.getOpportunities(opportunityIds);
			EDPUtil.cancelProposals(opportunityIds);
			EDPUtil.getOppsWithProposals(opportunityIds);
			EDPUtil.getContactsForOpportunities(opportunityIds);
			EDPUtil.getOpportunityRoleMap(listopportunityIds);
								
			List<String> sObjectTypes = new List<String>{'Case','Account'};
			EDPUtil.getRecordTypes(sObjectTypes);
			EDPUtil.getTaskEDPRecordType();
			
			String proposalIdVal = proposalObj.id;
			EDPUtil.processWelcomeEmailRequest(proposalIdVal);
			
			Id recordTypeId = [select Id, Name, SobjectType from RecordType where SObjectType = 'task'  and isactive = true Limit 1].id;
			EDPUtil.createProposalPendingTask(recordTypeId, proposalObj);
			Id opsOwnerId = PartnerDetail__c.getValues('EDPTestAccount').PartnerUserId__c;
			String templateName = 'EDPTestEmailTemplate';
			EDPUtil.getEmailTemplateId(templateName);
			
			List<Generation_Assets__c> genAsset = [select id from Generation_Assets__c where Asset_Status__c != 'Deal Cancelled' limit 3];
			List<Id> genAssetIds = new List<Id>();
			for(Generation_Assets__c genAssetObj:genAsset){
				genAssetIds.add(genAssetObj.id);
			}
			EDPUtil.getBaseURL();			
			String envelopId1 = '';
			String proposalIdStr = '' + proposalObj.id;
			
			SR_Attachment__c srAttachmentObj;
			envelopId1 = '';
			srAttachmentObj = UnitTest_ProposalUtil.CreateSRAttachment('EPC', envelopId1, proposalIdStr, 
																	'TestFile02.pdf', EDPUtil.PROPOSAL_TOOL_SOURCE);
			srAttachmentObj.DocuSign_Status__c = EDPUtil.COMPLETED;
			
			EDPUtil.cloneSRAttachmentOnSFDC(srAttachmentObj, proposalId);
			String proposalName = 'P124124123-I';
			EDPUtil.getProposalNameForMasterDocs(proposalName);
			
			Id contactId = contactRec.id;
			List<Messaging.EmailFileAttachment> srAttachments = new List<Messaging.EmailFileAttachment> ();
			//Id templateId = EDPUtil.getEmailTemplateId('EDP Customer Welcome Email 1');			
			//EDPutil.sendCustomerWelcomeEmail(templateId, contactId, proposalId, srAttachments);
			
			
			try{
			
				proposalObj.Assigne__c = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
				proposalObj.Stage__c = EDPUtil.SUBMITTED;
				update proposalObj;
			}catch(Exception expObj){
				
			}
			
			try{
			
				proposalObj.Stage__c = EDPUtil.SR_OPS_REVIEWED;
				update proposalObj;
			}catch(Exception expObj){
				
			}
			
			try{
			
				proposalObj.Stage__c = EDPUtil.SR_OPS_APPROVED;
				//proposalObj.Sales_Partner_Name__c = 'Verengo';
				update proposalObj;
			}catch(Exception expObj){
				
			}
			
			proposalIdVal = proposalObj.id;
			system.debug('Proposal Stage && Proposal sales_partner_name');
			///EDPUtil.processWelcomeEmailRequest(proposalIdVal);
			
			
				
		Test.stopTest();		
		}
	}
	
	public static testMethod void TestCustomErrorMessages(){
		CustomErrorMessages CustomErrorMessagesObj = new CustomErrorMessages();
		CustomErrorMessages.eSignature_ERROR('Utility Bill');
	}
}