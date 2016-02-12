public class ProposalRelatedListController {

	public static Integer PAGE_SIZE1 = 10;
	public static Integer PAGE_SIZE2 = 5;

	public String oppotunityId{get;set;}
	public Opportunity opprotunityObj{get;set;}
	public ApexPages.StandardSetController ssc {get; set;}
	public Integer pageSize {get; set;}
	public Id deleteRecordId {get; set;}
	public Proposal__c proposalObj{get;set;}	
	public String dealSubmitStatus{get;set;}
	public List<SelectOption> opportunities{get;set;}
    public string customerAgreementFileName {get;set;}   
	public transient Blob customerAgreementFileBody {get;set;} 
    public string epcFileName {get;set;}   
	public transient Blob epcFileBody {get;set;} 		
    public string proofOfCreditPassFileName {get;set;}   
	public transient Blob proofOfCreditPassfileBody {get;set;} 	
    public string voidedcheckFileName {get;set;}   
	public transient Blob voidedcheckFileBody {get;set;} 
    public string rebateReservationFilename {get;set;}   
	public transient Blob rebateReservationFileBody {get;set;} 			
	public String proposalId{get;set;}
	public List<SelectOption> proposalsList;
	public String currentProposalId {get; set;}
	public String deleteAttachmentId{get;set;}
	public List<ProposalWrapper> proposalsWrapperList;
	List<Attachment> attachments;
	User userObj ;
	private String proposalStage;

	public List<ProposalWrapper> getProposalsWrapperList(){
		System.debug('Start: getproposalsList');
		initializeProposalList();
		System.debug('End: getproposalsList');		
		return proposalsWrapperList;
	}

	public ProposalRelatedListController(ApexPages.StandardController stdController){
		opprotunityObj = (Opportunity)stdController.getRecord();
		initializeOpportunityInfo();	
		initializeProposalList();	
	}

	public ProposalRelatedListController(){
		initializeOpportunityInfo();
		initializeProposalList();	
	}

	public void initializeOpportunityInfo(){
		pagesize = PAGE_SIZE2; 
		String pageStr = System.currentPagereference().getParameters().get('PageSize');
		if(pageStr != null && pageStr != ''){
			pagesize = Integer.valueOf(pageStr);
		}
		if(opprotunityObj != null){
			oppotunityId = opprotunityObj.Id;			
			if(oppotunityId != null){
				opprotunityObj = [Select Id, name from Opportunity where Id =:oppotunityId];
			}			
		}
	}
	
	public List<SelectOption> getproposalsList(){return  proposalsList;}
	public void initializeProposalList(){
		proposalsList = new List<SelectOption>();
		proposalsWrapperList = new List<ProposalWrapper>();
		Set<String> stageList = new Set<String>();
		getLoginUserProfile();
		System.debug('ssc: ' + ssc);
		 if(ssc == null){
			String queryString ;
			String whereClause = '';
			proposalStage = '';
			
			queryString = 	'Select Id, Stage__c, Proposal_ID__c, name,Assigne__c, Generation_Asset__c, Generation_Asset__r.name,';
			queryString += 'Partner_Name__c, Change_Order__c,Change_Order_ID__c,Electronically_Signed_Document__c,';
			queryString += 'Change_Order_With_New_Proposal__c, Change_Order_Type__c,';
			queryString +=  'Deal_Type__c, Date_Time_Finance_Received_Proposal__c from Proposal__C ';
			if(oppotunityId != null){
				whereClause = ' where Opportunity__c =:oppotunityId ';
			}else{
				String profileName = getLoginUserProfile();
				System.debug('profileName: ' + profileName);
				if(profileName == label.SR_Finance_Profile){
					proposalStage = 'Submitted';
					whereClause = ' where (stage__c =:proposalStage AND Electronically_Signed_Document__c = true) OR ' ;
					whereClause += ' (stage__c in :stageList )';
					stageList.add(EDPUtil.CREDIT_REVIEW);
					stageList.add(EDPUtil.SR_OPS_REVIEWED);
					
				}else if(profileName == label.SR_Operations_Profile){
					proposalStage = 'Submitted';
					whereClause = ' where (stage__c =:proposalStage AND Electronically_Signed_Document__c = false) OR ';
					whereClause += ' (stage__c in :stageList )';
					stageList.add(EDPUtil.CREDIT_APPROVED);
					stageList.add(EDPUtil.SR_SIGNOFF_REVIEW);
					stageList.add(EDPUtil.SR_OPS_RECEIVED);		
				}
			}

			queryString += whereClause;
			queryString += ' limit 10000 ';
			//Query records and setup standard set controller for pagination
			ssc = new ApexPages.StandardSetController(Database.query(queryString));
			//Set pagination size based on value set in component
			pageSize = (pageSize == null || pageSize <= 0) ? PAGE_SIZE2 : pageSize;
			if(pageSize != null){
			    ssc.setPageSize(pageSize);
			}  
		 }  
             
		List<Proposal__C> proposalList = ssc.getRecords();    
		for(Proposal__C proposalObj: proposalList){
			proposalsList.add(new SelectOption(proposalObj.Id, proposalObj.name));	
			proposalsWrapperList.add(new ProposalWrapper(proposalObj));		
		}	
	}

    public class ProposalWrapper
    {
        public Proposal__c proposalObj{get; set;}
        public Boolean recSelected {get; set;}
        public String checked {get; set;}
        public String electornicallySigned {get;set;}
		public String changeOrderWithNewProposal {get;set;}
		public ProposalWrapper(Proposal__c proposal)
        {
            proposalObj = proposal;
            recSelected = false;
            checked = '';
            changeOrderWithNewProposal = '';
            if(proposalObj.Electronically_Signed_Document__c == true){
            	electornicallySigned = 'Yes';
            }else{
            	electornicallySigned = 'No';
            }
            if(proposalObj.Change_Order_With_New_Proposal__c == true){
            	changeOrderWithNewProposal = 'Yes';
            }else{
            	changeOrderWithNewProposal = 'No';
            }
            
        }
    }

	public String getLoginUserProfile(){
		Id userId = UserInfo.getUserId();
		String profileName = '';
		userObj = [Select Id, contactId, profileId from user where Id =:userId];
		Profile profileObj = [Select Id, name from Profile where Id = :userObj.ProfileId];
		System.debug('profileObj.name: ' + profileObj.name);
		return profileObj.name;
	}	

	public boolean getIsPortalUser(){
		System.debug('userObj: ' + userObj);
		if(userObj != null && userObj.contactId != null){
			return true;
		}else{
			return false;
		}
	}

	/*
    @RemoteAction
    public static String getProposalSubmitStatus() {
		if(proposalObj != null && proposalObj.dealSubmitted__c == true){
			return 'Deal Submitted';
		}else if(proposalObj != null && proposalObj.dealSubmitted__c == false){
			return 'Attach documents';
		}else{
			return 'Select a proposal';
		}
    }
    */
	/*
    public PageReference uploadDocument()
    {
    	proposalObj = null;
		if(proposalsWrapperList != null){
			for(ProposalWrapper proposalWrapperObj : proposalsWrapperList){
				if(proposalWrapperObj.recSelected == true){
					proposalObj = proposalWrapperObj.proposalObj;
					proposalId = proposalObj.Id;
					if(proposalObj.Electronically_Signed_Document__c){
						proposalObj.stage__c = 'Submitted';
						update proposalObj;
						dealSubmitStatus = 'DEAL_SUBMITTED';
					}	
					break;
				}
			}
		}
	
		if(proposalObj != null && proposalObj.Electronically_Signed_Document__c == false){
			dealSubmitStatus = 'INSUFFICIENT_DOCS';
		}
		
		if(proposalObj == null || proposalObj.Id == null){
			dealSubmitStatus = 'SELECT_PROPOSAL';
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Select a proposal'));
			return null;
		}
		
		initializeProposalList();
		return null;
    }
    */
	/*
	Public void updateProposalSection()
	{
	    String selectedProposalId = System.currentPagereference().getParameters().get('proposalId');
		System.debug('selectedProposalId: ' + selectedProposalId);
		if(proposalsWrapperList != null){
			for(ProposalWrapper proposalWrapperObj : proposalsWrapperList){
				if(proposalWrapperObj.proposalObj.Id == selectedProposalId){
					proposalWrapperObj.checked = 'yes';
				}else{
					proposalWrapperObj.checked = '';
				}
			}
		}
	}
	*/
	
}