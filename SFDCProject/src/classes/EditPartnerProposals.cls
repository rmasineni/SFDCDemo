/********************************************************************************
*   Author      : Chandrika Dasaradharaman (chandrikad@sunrunhome.com)          *
*   Date        : March 2012                                                    *
*   Name        : EditPartnerProposals.cls                                      *
*   Description : This class is used to list the available                      * 
*                 notes for a proposal and also allows to add or edit the notes *
*                                                                               *
*********************************************************************************/
public class EditPartnerProposals
{
	
	public boolean isSaved {get;set;}
	public boolean blackBirdProposal {get;set;}
    public boolean confirmSave {get;set;}
    public boolean showconfirmSave {get;set;}
    public String proposalId {get;set;}
    public Proposal__c proposalRecord {get;set;}
    public boolean isEnabled{get;set;}
    public boolean isOriginalProposal{get;set;}
    public String actionName{get;set;}
    public Proposal__c propObj{get;set;}
    public set<string> afterSubmitStages = new set<string>();
    public String parentURL{get;set;}
    public String baseURL{get;set;}
    public String loginProfileId {get;set;}
    public CustomLookup__c customLookupObj {get;set;}
    public String getProposalPrefix(){
        String proposalprefix = Schema.SObjectType.Proposal__c.getKeyPrefix(); 
        return proposalprefix; 
    }

    public EditPartnerProposals(ApexPages.StandardController stdController) {
        
        System.debug('Start ...');
        customLookupObj = new CustomLookup__c();
        //afterSubmitStages.add(EDPUtil.PROPOSAL_ACTIVATE);
        afterSubmitStages.add(EDPUtil.CREATED);
        afterSubmitStages.add(EDPUtil.ON_HOLD);
        afterSubmitStages.add(EDPUtil.READY_FOR_SUBMISSION);
        afterSubmitStages.add(EDPUtil.WITH_DRAWN);
        
        isEnabled = true;
        showconfirmSave = false;
        confirmSave = false;
        blackBirdProposal = false;
        
        this.proposalRecord = (Proposal__c)stdController.getRecord();
        isSaved  = false;
        propObj = [Select id, name, Assigne__c, Partner_Actions__c,stage__c,Original_Proposal_ID__c, signed__c,
        			Change_Order_Information__c, opportunity__c, Revised_Proposal__c, proposal_source__c ,Status_Reason__c 
        			from proposal__c where id =: this.proposalRecord.id];
        this.proposalRecord = propObj;
        this.customLookupObj.User__c = this.proposalRecord.Assigne__c;
        proposalId = this.proposalRecord.Id;
        actionName = propObj.Partner_Actions__c;
        if(!afterSubmitStages.contains(propObj.stage__c)){
            isEnabled = false;
        }

		if(this.proposalRecord.proposal_source__c != null
			&& this.proposalRecord.proposal_source__c == ProposalUtil.BLACK_BIRD){
			blackBirdProposal = true;
		}

        
        isOriginalProposal = false;
        if(propObj.name.indexOf('P') == 0 && blackBirdProposal == false){
            isOriginalProposal = true;
        }
        
        //Building Parent URL to return to Parent window
        baseURL = EDPUtil.getBaseURL();
        parentURL = baseURL + '/' + this.proposalRecord.id;
        system.debug('Parent URL *******' + parentURL);
        
        loginProfileId = UserInfo.getProfileId();
    }
    
    //Build Partner Actions Picklsit Field
    public List<SelectOption> getActionValue(){
        system.debug('getting Acion Value');
        List<SelectOption> actionValue = new List<SelectOption>();
        String opsProfileId = Label.Partner_Ops_Profile;
        System.debug('opsProfileId: ' + opsProfileId);
        
        actionValue.add(new SelectOption('', ''));
		if(this.proposalRecord.proposal_source__c != null
			&& this.proposalRecord.proposal_source__c == ProposalUtil.BLACK_BIRD && this.proposalRecord.Stage__c != EDPUtil.WITH_DRAWN){
			blackBirdProposal = true;
			
			if(this.proposalRecord.stage__c != null && 
				this.proposalRecord.stage__c == EDPUtil.INACTIVE){
				actionValue.add(new SelectOption(EDPUtil.PROPOSAL_ACTIVATE, EDPUtil.PROPOSAL_ACTIVATE));
			}else if(this.proposalRecord.Change_Order_Information__c != null && 
				this.proposalRecord.Change_Order_Information__c == ProposalUtil.NO_SIGNATURES_REQUIRED
				&& this.proposalRecord.signed__c != true){
				actionValue.add(new SelectOption(ProposalUtil.SIGN_PROPOSAL, ProposalUtil.SIGN_PROPOSAL));
			}
			
			if(this.proposalRecord.stage__c != null && this.proposalRecord.stage__c != EDPUtil.VOIDED 
				&& this.proposalRecord.stage__c != EDPUtil.INACTIVE){
				actionValue.add(new SelectOption(ProposalUtil.SUNRUN_VOID_ACTION, ProposalUtil.SUNRUN_VOID_ACTION));
			}

		}
		
		if(this.proposalRecord.stage__c != null && this.proposalRecord.stage__c != EDPUtil.VOIDED 
				&& this.proposalRecord.stage__c != EDPUtil.INACTIVE){

			if(!afterSubmitStages.contains(propObj.stage__c) || propObj.stage__c == EDPUtil.READY_FOR_SUBMISSION){
	            actionValue.add(new SelectOption('hold','On Hold'));
	            actionValue.add(new SelectOption('withdrawn','Withdrawn'));
	        } else if(propObj.stage__c == EDPUtil.WITH_DRAWN){		
	                actionValue.add(new SelectOption('created','Created')); 	
            } else{
	            if(propObj.stage__c == EDPUtil.ON_HOLD){
	                actionValue.add(new SelectOption('rSubmit', 'Ready for Submission'));
	                actionValue.add(new SelectOption('withdrawn','Withdrawn'));
	            }else{
	                actionValue.add(new SelectOption('rSubmit', 'Ready for Submission'));
	                actionValue.add(new SelectOption('hold','On Hold'));
	                actionValue.add(new SelectOption('withdrawn','Withdrawn'));
	            }
	        }
		}
        //actionValue.sort();
        return actionValue;
    }
    
    public String aId = apexpages.currentpage().getParameters().get('id'); 
    public PageReference doCancel() {
        PageReference pr=new PageReference('retURL');
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference confirmSaveForm(){
    	PageReference ref;
    	confirmSave = true;
    	ref = saveForm();
    	return ref;
    }
    
    //Following is to save the Proposal Record
    public PageReference saveForm(){
    	Map<Id, Proposal__c> voidProposalMap = new Map<Id, Proposal__c>();
        System.debug('ActionValue'+actionName);
		if(isEnabled == true && customLookupObj != null && customLookupObj.User__c != null){
			this.proposalRecord.Assigne__c = customLookupObj.User__c;
		}
        
        if(isOriginalProposal && isEnabled && this.proposalRecord.Original_Proposal_ID__c == null && 
            this.proposalRecord.Revised_Proposal__c == true){
            String errorMessage = 'Please select the parent proposal to set the revised proposal information';
            Exception expObj = new BaseException(errorMessage);
            expObj.setMessage(errorMessage);
            ApexPages.addMessages(expObj);
            return null;            
        }
 
        if(isOriginalProposal && isEnabled && this.proposalRecord.Original_Proposal_ID__c != null && 
            this.proposalRecord.Revised_Proposal__c == false){
            String errorMessage = 'Please select the revised proposal check box';
            Exception expObj = new BaseException(errorMessage);
            expObj.setMessage(errorMessage);
            ApexPages.addMessages(expObj);
            return null;            
        }

        if(isOriginalProposal && isEnabled && this.proposalRecord.Original_Proposal_ID__c == this.proposalRecord.Id){
            String errorMessage = CustomErrorMessages.SAME_ORGINAL_AND_REVISED_PROPOSALS;
            Exception expObj = new BaseException(errorMessage);
            expObj.setMessage(errorMessage);
            ApexPages.addMessages(expObj);
            return null;            
        }
                
        if(actionName == ''){
            proposalRecord.Partner_Actions__c = '';
        }else if(actionName == 'rSubmit'){
           proposalRecord.Partner_Actions__c = '';
            proposalRecord.stage__c = EDPUtil.READY_FOR_SUBMISSION;
        }else if(actionName == 'hold'){
            proposalRecord.Partner_Actions__c = '';
            proposalRecord.stage__c = EDPUtil.ON_HOLD;
        }else if(actionName == 'created'){		
            proposalRecord.Partner_Actions__c = '';		
            proposalRecord.stage__c = EDPUtil.CREATED;    
        }else if(actionName == 'withdrawn'){
           // proposalRecord.Partner_Actions__c = '';
            proposalRecord.stage__c = EDPUtil.WITH_DRAWN;
        }else if(actionName == EDPUtil.PROPOSAL_ACTIVATE){
        	if(ProposalUtil.hasActiveProposals(this.proposalRecord.opportunity__c) == true && confirmSave == false){
        		showconfirmSave = true;
				String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000006').error_message__c;
				Exception expObj = new BaseException(errorMessage);
	            expObj.setMessage(errorMessage);
	            ApexPages.addMessages(expObj);
	            return null;        		
        	}
			if(showconfirmSave == true && confirmSave == true){
				Map<Id, Proposal__c> activeProposals = 	ProposalUtil.getActiveProposals(this.proposalRecord.opportunity__c);
				if(activeProposals != null && !activeProposals.isEmpty()){
					activeProposals.remove(this.proposalRecord.Id);
					ProposalUtil.voidProposals(activeProposals, new Map<Id, String>(), false);
				}
			}
			proposalRecord.stage__c = EDPUtil.CREATED;
        }else if(actionName == ProposalUtil.SIGN_PROPOSAL){
        	proposalRecord.Signed__c = true;
        }else if(actionName == ProposalUtil.SUNRUN_VOID_ACTION){
        	if(confirmSave == false){
        		showconfirmSave = true;
	            String errorMessage = 'Are you sure you would like to void this proposal ? Click \'Confirm\' to save your changes.';
	            Exception expObj = new BaseException(errorMessage);
	            expObj.setMessage(errorMessage);
	            ApexPages.addMessages(expObj);	
	            return null;			
			}
        	
			String result = '';
			String alertMessage = '';
			try{
				Set<Id> proposalIds = new Set<Id>();
				voidProposalMap.put(this.proposalRecord.Id, this.proposalRecord);
				proposalIds.add(this.proposalRecord.Id);
				Map<Id, Map<Id, Proposal__c> > childNodes = new Map<Id, Map<Id, Proposal__c> >();
				ProposalUtil.getActiveChildNodes(proposalIds, childNodes);	
				System.debug('childNodes: ' + childNodes);
				if(childNodes != null && !childNodes.isEmpty()){
					//proposalIds.addall(childNodes.keySet());
					for(Map<Id, Proposal__c> nodeMap : childNodes.values()){
						if(!nodeMap.isEmpty()){
							voidProposalMap.putall(nodeMap);
						}
					}
				}
				
				if(voidProposalMap != null && !voidProposalMap.isEmpty()){
					ProposalUtil.voidProposals(voidProposalMap, new Map<Id, String>(), true);
				}
				
				isSaved = true;
				
				//if(proposalVoidResultMap.size() > 0){
				//	result = proposalVoidResultMap.get(this.proposalRecord.Id);	
				//	if(result == null || result != ProposalUtil.SUCCESS){
				//		alertMessage = (result == null) ? CustomErrorMessages.UNABLE_TO_PROCESS_YOUR_REQUEST : result;
			    //        Exception expObj = new BaseException(alertMessage);
			    //        expObj.setMessage(alertMessage);
			    //        ApexPages.addMessages(expObj);					
				//		return null;
				//	}
				//	isSaved = true;
				//}
			}catch(Exception e){
	            ApexPages.addMessages(e);
	            return null;
			}      	
        }
        
        if(actionName != ProposalUtil.SUNRUN_VOID_ACTION){
			update this.proposalRecord;
			isSaved = true;
        }
		return null;
    }
    
    
    public class BaseException extends Exception {}
}