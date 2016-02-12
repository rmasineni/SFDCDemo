@isTest (SeeAllData=true)
public class Test_EditPartnerProposals {
	public static testMethod void TestEditPartnerProposals(){
		
		Id userId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
		User partnerUser = [Select id, name, email from User where Id =:userId];
		
		Test.startTest();
		System.runAs(partnerUser){
		
			Opportunity optyObj1 = TestPRMLibrary.insertOpportunity('ResidentialAccount-3', 'Residential',
																			'ResOpty-3', 'Platinum');	
			Proposal__c proposalObj1 = new Proposal__c();
			proposalObj1.Name = 'P87A13E7174V1BN-H';
			proposalObj1.Opportunity__c = optyObj1.Id;
			proposalObj1.Upfront_Payment__c = 1000;
			proposalObj1.Proposal_ID__c = 2441242;
			proposalObj1.System_Size_STC_DC__c = 1;
			proposalObj1.Mode_Name__c = 'Mode-1';
			proposalObj1.Date_Issued__c =  date.today();
			proposalObj1.Sales_Rep_Email__c = 'test@gmail.com';
			insert proposalObj1;
		
			ApexPages.StandardController stdcon = new ApexPages.StandardController(proposalObj1);
			EditPartnerProposals editPropObj = new EditPartnerProposals(stdcon);
									
			editPropObj.getProposalPrefix();
			editPropObj.isEnabled = true;
			editPropObj.proposalId = proposalObj1.id;
			editPropObj.getActionValue();
			editPropObj.doCancel();
			editPropObj.actionName = 'rsubmit';
			editPropObj.saveForm();
			editPropObj.actionName = 'hold';
			editPropObj.saveForm();
			editPropObj.actionName = 'withdrawn';
			editPropObj.saveForm();
			editPropObj.actionName = '';
			editPropObj.saveForm();
			editPropObj.loginProfileId = partnerUser.id;
			editPropObj.getActionValue();
			try{
			
				proposalObj1.stage__c = 'Submitted';
				update proposalObj1;
			}catch(Exception expObj){
				
			}
			
			stdcon = new ApexPages.StandardController(proposalObj1);
			editPropObj = new EditPartnerProposals(stdcon);

			editPropObj.getActionValue();
			editPropObj.loginProfileId = partnerUser.id;
			editPropObj.getActionValue();
			
			Opportunity optyObj2 = TestPRMLibrary.insertOpportunity('ResidentialAccount-3', 'Residential',
																		'ResOpty-3', 'Platinum');	
			Proposal__c proposalObj4 = new Proposal__c();
			proposalObj4.Name = 'P87A13E7174V1BN-H';
			proposalObj4.Opportunity__c = optyObj2.Id;
			proposalObj4.Upfront_Payment__c = 1000;
			proposalObj4.Proposal_ID__c = 2441242;
			proposalObj4.System_Size_STC_DC__c = 1;
			proposalObj4.Mode_Name__c = 'Mode-1';
			proposalObj4.Date_Issued__c =  date.today();
			proposalObj4.Sales_Rep_Email__c = 'test@gmail.com';
			insert proposalObj4;
			
			Proposal__c proposalObj2 = new Proposal__c();
			proposalObj2.Name = 'C87A13E7174V1BN-H';
			proposalObj2.Opportunity__c = optyObj2.Id;
			proposalObj2.Upfront_Payment__c = 1000;
			proposalObj2.Proposal_ID__c = 2441242;
			proposalObj2.System_Size_STC_DC__c = 1;
			proposalObj2.Mode_Name__c = 'Mode-1';
			proposalObj2.Date_Issued__c =  date.today();
			proposalObj2.Sales_Rep_Email__c = 'test@gmail.com';
			proposalObj2.Original_Proposal_ID__c = proposalObj4.id;
			proposalObj2.stage__c = 'On Hold';
			proposalObj2.Revised_Proposal__c = true;
			insert proposalObj2;
			
			ApexPages.StandardController stdcon1  = new ApexPages.StandardController(proposalObj2);
			EditPartnerProposals editPropObj1 = new EditPartnerProposals(stdcon1);
			
			editPropObj1.isEnabled = true;
			editPropObj1.isOriginalProposal = true;
			editPropObj1.getActionValue();
			editPropObj1.loginProfileId = partnerUser.id;
			editPropObj1.getActionValue();
			
			
		}

		Test.stopTest();	
			
		
			Id userId1 = PartnerDetail__c.getValues('PartnerSalesTestAccount').PartnerUserId__c;
			User partnerUser1 = [Select id, name, email from User where Id =:userId1];
						
			System.runAs(partnerUser1) {
			
			Opportunity optyObj3 = TestPRMLibrary.insertOpportunity('ResidentialAccount-3', 'Residential',
																		'ResOpty-3', 'Platinum');	
			Proposal__c proposalObj3 = new Proposal__c();
			proposalObj3.Name = 'P87A13E7174V1BN-H';
			proposalObj3.Opportunity__c = optyObj3.Id;
			proposalObj3.Upfront_Payment__c = 1000;
			proposalObj3.Proposal_ID__c = 2441242;
			proposalObj3.System_Size_STC_DC__c = 1;
			proposalObj3.Mode_Name__c = 'Mode-1';
			proposalObj3.Date_Issued__c =  date.today();
			proposalObj3.Sales_Rep_Email__c = 'test@gmail.com';
			insert proposalObj3;
		
			ApexPages.StandardController stdcon3 = new ApexPages.StandardController(proposalObj3);
			EditPartnerProposals editPropObj3 = new EditPartnerProposals(stdcon3);
									
			editPropObj3.getProposalPrefix();
			editPropObj3.isEnabled = true;
			editPropObj3.proposalId = proposalObj3.id;
			editPropObj3.getActionValue();
			editPropObj3.doCancel();
			editPropObj3.actionName = 'rsubmit';
			editPropObj3.saveForm();
			editPropObj3.actionName = 'hold';
			editPropObj3.saveForm();
			editPropObj3.actionName = 'withdrawn';
			editPropObj3.saveForm();
			editPropObj3.actionName = '';
			editPropObj3.saveForm();
			editPropObj3.loginProfileId = partnerUser.id;
			editPropObj3.getActionValue();
			try{
			
				proposalObj3.stage__c = 'Submitted';
				update proposalObj3;
			}catch(Exception expObj){
				
			}
			
			stdcon3 = new ApexPages.StandardController(proposalObj3);
			editPropObj3 = new EditPartnerProposals(stdcon3);

			editPropObj3.getActionValue();
			editPropObj3.loginProfileId = partnerUser.id;
			editPropObj3.getActionValue();
			
			}
			

	}
}