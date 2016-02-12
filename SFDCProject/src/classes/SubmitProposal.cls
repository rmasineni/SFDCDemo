public class SubmitProposal {
	private Id proposalId;
    private String proposalStage;
    public boolean showClose {get;set;}
	public boolean showSubmitFirst {get;set;}
	public boolean showSubmitSecond {get;set;}
	public boolean showError {get;set;}
    public boolean showSubmit{get;set;}
    public boolean showCloneAndSubmit {get;set;}
    public boolean generateNewSC {get;set;}
	public Proposal__c proposalObj;
	Transient Savepoint sp;
	public String titleStr {get;set;}
	public String parentURL {get;set;}
	
	public SubmitProposal(ApexPages.StandardController sc){
		showSubmitFirst = false;
		showSubmitSecond = false;
		showClose = false;
    	showError = false;
    	showCloneAndSubmit = false;
    	generateNewSC = false;
    	showSubmit = true;
        proposalId = ((Proposal__c)sc.getRecord()).Id;
        System.debug('proposalId1: ' + proposalId);
		proposalObj = ((Proposal__c)sc.getRecord());
        initialize();
        proposalStage = proposalObj.Stage__c;  	
        titleStr = 	'Submit Proposal: ' + proposalObj.name;
        checkProposalStage(proposalObj);
	}
	
	public void initialize(){
		showSubmitSecond = false;
		showSubmitFirst = true;
		proposalObj = [Select Id, name, stage__c, Finance_Type__c, Sales_Partner__c, Agreement_Type__c, Proposal_Source__c, Opportunity__c, 
							Opportunity__r.AccountId, Opportunity__r.Id,Opportunity__r.Account.NAME,
							Original_Proposal_ID__c from Proposal__c where Id =:proposalId];
		if(proposalObj.Original_Proposal_ID__c == null && proposalObj.Proposal_Source__c == ProposalUtil.PROPOSAL_TOOL){
			List<ServiceContract> scList = [Select Id, name, Service_Contract_Status__c from ServiceContract where Opportunity__c =:proposalObj.Opportunity__c 
												and Service_Contract_Status__c != 'Inactive' and Marked_For_Deletion__c != 'Yes'];
			System.debug('scList.isEmpty(): ' + scList.isEmpty());
			if(!scList.isEmpty()){
				showSubmitSecond = true;
				showSubmitFirst = false;
			}else{
				showSubmitSecond = false;
				showSubmitFirst = true;				
			}
			System.debug('showSubmitSecond: ' + showSubmitSecond);
			System.debug('showSubmitFirst: ' + showSubmitFirst);
		}
		String baseURL = EDPUtil.getBaseURL();
        parentURL = baseURL + '/' + this.proposalObj.id;
	}
	
	public SubmitProposal(){
       	proposalId = System.currentPagereference().getParameters().get('id');
       	system.debug('proposalId: ' + proposalId);		
	}

    public PageReference submitProposal(){
		PageReference pageRef;
		Savepoint sp = Database.setSavepoint();
		try{
			String proposalId = proposalObj.Id; 
			String resultStr = '';
			resultStr = EDPWebServices.submitProposal(proposalId);
			System.debug('resultStr2: ' + resultStr);
			if(!String.isEmpty(resultStr) && !resultStr.contains(CustomErrorMessages.SUBMITTED_PROPOSAL_SUCCESSFULLY)){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, resultStr));
			}else{
				showSubmitFirst = false;
				showSubmitSecond = false;
				showClose = true;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, CustomErrorMessages.SUBMITTED_PROPOSAL_SUCCESSFULLY));
			}			
		}catch(Exception expObj){
            System.debug('Exception: ' + expObj);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There is a problem in submitting this proposal.  Please contact Sunrun operations.'));
            Database.rollback(sp);
            return null;           
		}
		return pageRef;
    }
	
	

    public PageReference cloneAndSubmitProposal(){
		PageReference pageRef;
		Savepoint sp = Database.setSavepoint();
		try{
			Opportunity newOptyObj = ServiceContractUtil.cloneDataForSecondProject(proposalObj);
			proposalObj.Opportunity__c = newOptyObj.Id;
			update proposalObj;
			
			String proposalId = proposalObj.Id; 
			String resultStr = '';
			resultStr = EDPWebServices.submitProposal(proposalId);
			System.debug('resultStr1: ' + resultStr);
			if(!String.isEmpty(resultStr) && !resultStr.contains(CustomErrorMessages.SUBMITTED_PROPOSAL_SUCCESSFULLY)){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, resultStr));
			}else{
				showSubmitFirst = false;
				showSubmitSecond = false;
				showClose = true;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, CustomErrorMessages.SUBMITTED_PROPOSAL_SUCCESSFULLY));
			}			
		}catch(Exception expObj){
            System.debug('Exception: ' + expObj);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There is a problem in submitting this proposal.  Please contact Sunrun operations.'));
            Database.rollback(sp);
            return null;           
		}
		return pageRef;
    }

	public PageReference ReturnToProposal(){
        PageReference pr = new PageReference('/' + proposalId);
        return pr;    
    }
    
    public void checkProposalStage(Proposal__c propsalObject){
    	Boolean result = false;
    	String errorMessage = '';
    	if(propsalObject != null){
    		Id sunrunId = System.Label.Sunrun_Inc_Id;
    		if(propsalObject.stage__c == 'Created' || propsalObject.stage__c == 'Ready for Submission'){
				//if(propsalObject.stage__c == 'Created' && propsalObject.Sales_Partner__c == sunrunId
				//	 &&  propsalObject.Agreement_Type__c == 'Customer Owned - Full Upfront'
				//	&& (propsalObject.Finance_Type__c != 'N/A' && propsalObject.Finance_Type__c != 'Bank Financed')){
				//	errorMessage = 'Since this is a proposal for Customer Owned system, please specify Finance Type (either Bank Financed or N/A)';
				//}else{
					DesignToolWebservice.DesignToolWebserviceResponse responseObj = new DesignToolWebservice.DesignToolWebserviceResponse();
					responseObj = DesignTool.canUserSubmitProposal(propsalObject.Opportunity__c);
					if(responseObj != null && responseObj.status == ProposalUtil.SUCCESS){
						responseObj.errorMessage = 'Are you sure you would like to submit this proposal ?';
						if(showSubmitSecond){
							responseObj.errorMessage = 'Are you sure you would like to submit this proposal? There is already an approved proposal for '; 
							responseObj.errorMessage += propsalObject.Opportunity__r.Account.NAME;
							responseObj.errorMessage += '. If this is a change order, please click \'Submit Proposal\'. If this is an additional system for this customer, please click \'Submit Proposal for Additional System\'.';
						}
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, responseObj.errorMessage));
						result = true;
					}else if(responseObj != null && responseObj.status == ProposalUtil.WARNING){
						responseObj.errorMessage = 'Are you sure you would like to submit this proposal? <br/>';
						responseObj.errorMessage += 'NTP has been revoked on the original proposal. Please remember to request NTP again on this modification.';
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, responseObj.errorMessage));
						result = true;
					}else{
						errorMessage = responseObj.errorMessage;
					}
				//}
    		}else{
    			if(propsalObject.stage__c == 'SR Ops Approved'){
    				errorMessage = 'This is an approved proposal. You can not resubmit it again';
				}else{
    				errorMessage = 'Invalid proposal stage for submission';
    			}
    		}
    	}
    	if(result == false){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
			showSubmitFirst = false;
			showSubmitSecond = false;
			showClose = true;    		
    	}
    }
}