global class EDPWebServices {
	webService static String sendWelcomeEmail(String proposalId){
		String result = EDPUtil.processWelcomeEmailRequest(proposalId);
		return result;
	}

	webService static String sendWelcomeEmailForPartner(String proposalId){
		String result = EDPUtil.processWelcomeEmailRequestForPartners(proposalId);
		return result;
	}
	
	
	webService static String voidProposal(String proposalId){
		String result = '';
		String alertMessage = '';
		try{
			Set<Id> proposalIds = new Set<Id>();
			proposalIds.add(proposalId);
			Map<Id, String> proposalVoidResultMap = ProposalUtil.voidProposals(proposalIds, new Map<Id, String>(), true);
			System.debug('Result: ' + proposalVoidResultMap);
			if(proposalVoidResultMap.size() > 0){
				result = proposalVoidResultMap.get(proposalId);
				alertMessage =  (result != null && result == ProposalUtil.SUCCESS) ? 'This proposal has been voided successfully.' : result;
			}
		}catch(Exception e){
			System.debug('System Error: ' + e.getMessage());
			return CustomErrorMessages.SFDC_SYSTEM_ERROR;
		}
		return alertMessage;
	}
	
	webService static DesignToolWebservice.DesignToolWebserviceResponse canUserSubmitProposal(String objectId){
		DesignToolWebservice.DesignToolWebserviceResponse responseObj = new DesignToolWebservice.DesignToolWebserviceResponse();
		responseObj = DesignTool.canUserSubmitProposal(objectId);
		if(responseObj != null && responseObj.status == ProposalUtil.SUCCESS){
			responseObj.errorMessage = 'Are you sure you would like to submit this proposal ?';
		}else if(responseObj != null && responseObj.status == ProposalUtil.WARNING){
			responseObj.errorMessage = 'Are you sure you would like to submit this proposal? \r\n';
			responseObj.errorMessage += 'NTP has been revoked on the original proposal. Please remember to request NTP again on this modification.';
		}
		return responseObj;
	}
	
	webService static String updateCreditInformation(String proposalId){
		String result = '';
		String alertMessage = '';
		List<Proposal__c> proposalList = new List<Proposal__c>();
		try{
			
			String parentProposalId = proposalId;
			Set<String> proposalIds = new Set<String>();
			proposalIds.add(parentProposalId);
			String originalProposalId;
			Proposal__c parentProposalObj;
			Proposal__c sourceProposalObj = [select Id, Stage__c, Opportunity__c, Revised_Proposal__c, Original_Proposal_ID__c, Opportunity__r.AccountId, Sunrun_Credit_Status__c,
												Primary_Customer__c, Current_Customer_Credit_Report__c, Credit_Status__c,Credit_team_notes__c,ACH_Required__c,Name_on_Credit_Verified__c,
												Total_Solar_Prepay_Required__c,Partner_Financed__c, Conditional_Approval_Amount__c, Conditional_Approval__c,Proposal_Source__c, 
												Date_Time_Ops_Received_Proposal_back__c,Original_Proposal_ID__r.Date_Time_Ops_Received_Proposal_back__c, Customer_SignOff_Date__c,
												Original_Proposal_ID__r.Id, Original_Proposal_ID__r.Stage__c, Original_Proposal_ID__r.Opportunity__c, Original_Proposal_ID__r.Revised_Proposal__c,
												Original_Proposal_ID__r.Primary_Customer__c, Original_Proposal_ID__r.Current_Customer_Credit_Report__c, Original_Proposal_ID__r.Credit_Status__c,
												Original_Proposal_ID__r.Credit_team_notes__c, Original_Proposal_ID__r.ACH_Required__c, Original_Proposal_ID__r.Total_Solar_Prepay_Required__c,
												Original_Proposal_ID__r.Partner_Financed__c, Original_Proposal_ID__r.Conditional_Approval_Amount__c, Original_Proposal_ID__r.Conditional_Approval__c,
												Original_Proposal_ID__r.Sunrun_Credit_Status__c, Original_Proposal_ID__r.Name_on_Credit_Verified__c, Original_Proposal_ID__r.Customer_SignOff_Date__c
												from Proposal__c where id = :proposalId];
			
			if(sourceProposalObj != null && sourceProposalObj.Proposal_Source__c != null && sourceProposalObj.Proposal_Source__c == ProposalUtil.BLACK_BIRD){
					result = ProposalUtil.copyCreditInformation(sourceProposalObj);
					if(result != null && result == ProposalUtil.SUCCESS){
						alertMessage = 'Credit information has been copied successfully to the related proposals.';
					}else{
						return CustomErrorMessages.SFDC_SYSTEM_ERROR;
					}
			}else{
				
				if(sourceProposalObj.Original_Proposal_ID__c != null && sourceProposalObj.Revised_Proposal__c == true){
					originalProposalId = sourceProposalObj.Id;
					parentProposalObj = sourceProposalObj;
				}else{
					originalProposalId = (sourceProposalObj.Original_Proposal_ID__c != null) ? sourceProposalObj.Original_Proposal_ID__c : sourceProposalObj.Id;
					if(sourceProposalObj.Original_Proposal_ID__c != null){
						parentProposalObj = sourceProposalObj.Original_Proposal_ID__r;
						ProposalUtil.copyCreditInformation(sourceProposalObj, parentProposalObj);
						proposalList.add(parentProposalObj);
					}else{
						parentProposalObj = sourceProposalObj;
					}
				}
				
				for(Proposal__c proposalObj:[select id, Stage__c, Opportunity__c, Revised_Proposal__c, Original_Proposal_ID__c, Conditional_Approval_Amount__c, 
												Name_on_Credit_Verified__c, Conditional_Approval__c, Primary_Customer__c,Credit_team_notes__c,ACH_Required__c,
												Total_Solar_Prepay_Required__c,
												Current_Customer_Credit_Report__c, Primary_Customer__r.email, Credit_Status__c,Partner_Financed__c,Sunrun_Credit_Status__c,
												Generation_Asset__r.Name from Proposal__c where Original_Proposal_ID__c =:parentProposalObj.Id])
				{
					//if((sourceProposalObj != null) && (proposalObj.ID != proposalId) 
					//	&& ((sourceProposalObj.Revised_Proposal__c == true && sourceProposalObj.Original_Proposal_ID__c == proposalObj.id) 
					//		|| (proposalObj.Revised_Proposal__c == true && proposalObj.Original_Proposal_ID__c == sourceProposalObj.Id) 
					//		|| (proposalObj.Revised_Proposal__c == true && proposalObj.Original_Proposal_ID__c == sourceProposalObj.Original_Proposal_ID__c))){
					//	continue;	
					//}
	
					if(proposalObj.Revised_Proposal__c == true && proposalObj.Original_Proposal_ID__c != null)
						continue;
					
					ProposalUtil.copyCreditInformation(parentProposalObj, proposalObj);
					proposalList.add(proposalObj);
				}
					
				if(!proposalList.isEmpty()){
					update proposalList;
					alertMessage = 'Credit information has been copied successfully to the related proposals.';
				}else{
					alertMessage = 'No related proposals are found.';
				}
			}
		}catch(Exception e){
			System.debug('System Error: ' + e.getMessage());
			return CustomErrorMessages.SFDC_SYSTEM_ERROR;
		}
		return alertMessage;		
	}

	
	webService static String submitProposal(String proposalId){
		String result = '';
		String alertMessage = '';
		try{
			String status = EDPUtil.SUBMITTED;
			Set<Id> proposalIds = new Set<Id>();
			proposalIds.add(proposalId);
			Map<Id, Proposal__c> parentProposalMap = new Map<Id, Proposal__c>();
			//Map<Id, Proposal__c> proposalMap = EDPUtil.getProposalObjects(proposalIds);
			Map<Id, Proposal__c> proposalMap = ProposalUtil.getProposalsMap(proposalIds);
			Proposal__c proposalObj = proposalMap.get(proposalId);
			if(proposalObj.Opportunity__r == null || proposalObj.Opportunity__r.Id == null){
				return CustomErrorMessages.FOUND_NO_VALID_OPPORTUNITY;
			}	

			Map<Id, String> proposalValidationMap = EDPUtil.validateProposalSubmission(proposalMap);
			if(proposalValidationMap != null && proposalValidationMap.size() > 0){
				alertMessage =  proposalValidationMap.get(proposalId);
				return alertMessage;
			}
			
			Set<Id> oprtyIds = new Set<Id>();
			oprtyIds.add(proposalObj.Opportunity__r.Id);
			Boolean modifiedProposal = false;
			Id originalProposalId;
			proposalValidationMap = EDPUtil.processSubmittedProposals(oprtyIds, proposalMap, parentProposalMap);	
			Proposal__c parentProposalObj;
			if(parentProposalMap.size() > 0){
				parentProposalObj = parentProposalMap.get(proposalObj.Id);
			}else{
				if(proposalObj.Revised_Proposal__c == true && proposalObj.Original_Proposal_ID__c != null){
					originalProposalId = proposalObj.Original_Proposal_ID__c;
					String proposalSOQLStr = ProposalUtil.getProposalSQLStr();
					proposalSOQLStr += '  where Id =:originalProposalId ' ;
					parentProposalObj = Database.query(proposalSOQLStr);
				}
			}

			if(parentProposalObj != null){
				if(parentProposalObj.SR_Signoff__c != null){
					proposalObj.SR_Signoff__c = parentProposalObj.SR_Signoff__c;
				}
				if(parentProposalObj.Customer_Signoff_Date__c != null){
					proposalObj.Customer_Signoff_Date__c = parentProposalObj.Customer_Signoff_Date__c;
				}

				if(parentProposalObj.Revised_SR_Signoff__c != null){
					proposalObj.Revised_SR_Signoff__c = parentProposalObj.Revised_SR_Signoff__c;
				}	
				proposalObj.Completed_Approval_Process__c = parentProposalObj.Completed_Approval_Process__c;
				modifiedProposal = true;
			}
			
			
			if(proposalValidationMap != null && proposalValidationMap.size() > 0){
				alertMessage =  proposalValidationMap.get(proposalId);
			}else {
				alertMessage = CustomErrorMessages.SUBMITTED_PROPOSAL_SUCCESSFULLY;
				proposalObj.Submitted_By__c = UserInfo.getUserId();
				proposalObj.stage__c = EDPUtil.SUBMITTED;
				String proposalType = proposalObj.Change_Order_Information__c;
				System.debug('proposalType: ' + proposalType);
				if(proposalType != null && proposalType == ProposalUtil.NO_SIGNATURES_REQUIRED){
					proposalObj.signed__c = true;
				}
				System.debug('proposalObj.signed__c1: ' + proposalObj.signed__c);
				modifiedProposal = true;
			}	
			if(modifiedProposal){
				update proposalObj;
			}
				
		}catch(Exception e){
			System.debug('System Error: ' + e.getMessage());
			return CustomErrorMessages.SFDC_SYSTEM_ERROR;
		}
		return alertMessage;
	}
}