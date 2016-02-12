public with sharing class LMAuthoritiesButtonProposalExt{
    public String selectedDesign {get;set;}
    public String warningMessage {get;set;}
    public boolean showErrorAlert{get;set;}
    public boolean showWarning {get;set;}
    private boolean unsignedOrVoided;
    public Proposal__c proposalObj{set;get;}
    public String baseURL {get;set;}
    public Boolean shouldRedirect {public get; private set;}
    public boolean displayTandCURL{get;set;} 
    public String redirectUrl {public get; private set;}
    public Id partnerContactId{get;set;}  
    public boolean partnerTandCAccepted{get;set;}
    public User CurrentUser;

    public LMAuthoritiesButtonProposalExt(ApexPages.StandardController controller){
    	unsignedOrVoided=true;
    	String customerAgreementStr = EDPUtil.CUSTOMER_AGREEMENT;
        proposalObj=(Proposal__c)controller.getrecord();
        proposalObj=[select id,Signed__c,Proposal_Source__c,Stage__c,Last_Customer_Signed_Proposal__c,Status_Reason__c  from proposal__c where id=:controller.getid()];
        List<SR_Attachment__c> srAttachments = [Select Id, active__c, Customer_Signed__c, Wet_Sign_Status__c, proposal__r.Customer_Signoff_Date__c, Document_Source__c,
        										proposal__r.Ultimate_Parent_Proposal__r.Customer_Signoff_Date__c, proposal__r.Change_Order_Information__c
        										from SR_Attachment__c where Proposal__c =:proposalObj.Id and active__c = true 
        										and Document_Source__c in ('Manual Upload', 'eSign') AND Document_Type_Name__c =:customerAgreementStr];
        
        if(srAttachments != null && !srAttachments.isEmpty()){
        	for(SR_Attachment__c srAttachmentObj : srAttachments){
	        	if((srAttachmentObj.Document_Source__c == 'Manual Upload' && srAttachmentObj.Customer_Signed__c == 'Wet Signed')
	        		|| (srAttachmentObj.Document_Source__c == 'eSign' 
	        			&& (srAttachmentObj.proposal__r.Customer_Signoff_Date__c != null 
	        				|| (srAttachmentObj.proposal__r.Change_Order_Information__c != ProposalUtil.FULL_PROPOSAL 
	        					&& srAttachmentObj.proposal__r.Ultimate_Parent_Proposal__r.Customer_Signoff_Date__c != null)))){
	        		unsignedOrVoided=false;	
	        		break;
	        	}
        	}
		}
        
        //if(!proposalObj.signed__c) //||proposalObj.Stage__c=='Voided'
        //{
       ///	unsignedOrVoided=true;
       // }
        CurrentUser=[select id,Email,contact.id,contact.T_C_Accepted__c from user where id=:userinfo.getUserId()];  
        baseURL = EDPUtil.getBaseURL();
    }
    
    public String errorMessage {get;set;}   
     
    public pagereference redirectToDesign(){    
     errorMessage = '';
     showErrorAlert = false;
     //shouldRedirect = false;
     if(proposalObj.Proposal_Source__c==null||proposalObj.Proposal_Source__c!='BB'){
         errorMessage='This is not a valid proposal for modification';
         //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));
         showErrorAlert = true;
         return null;
     }
     else if(proposalObj.Stage__c==null|| (proposalObj.Stage__c=='Voided' && !proposalUtil.getIgnoreVoidReasons().contains(proposalObj.Status_Reason__c) ) ||proposalObj.Stage__c=='Inactive'||proposalObj.Stage__c=='Replaced'){
         errorMessage='This is not an active proposal to modify the design documents';
         //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));
         showErrorAlert = true;
         return null;
    }
    else if(selectedDesign!=null&&selectedDesign=='eAudit'&&!proposalObj.Signed__c && proposalObj.Last_Customer_Signed_Proposal__c == null ){
         errorMessage='Cannot audit an unsigned proposal';
         showErrorAlert = true;
         return null;
    }
//If user modifying the proposal has not accepted T&C yet, redirect to T&C page; Otherwise follow 
//the regular flow to redirect to lightmile     

        if(userinfo.getUserType().equalsIgnoreCase('PowerPartner')){
           partnerContactId = CurrentUser.contact.id;
           partnerTandCAccepted = CurrentUser.contact.T_C_Accepted__c; 
        }else{
          list<Contact> CurrentContact=[select id, T_C_Accepted__c from Contact where Sunrun_User__c=:userinfo.getUserId() AND Email= :CurrentUser.Email AND Contact_Type__c='Employee'];     
            if(CurrentContact.size() == 1){
               partnerContactId = CurrentContact[0].id;
               partnerTandCAccepted = CurrentContact[0].T_C_Accepted__c;   
            }else{
                  errorMessage='The valid user contact is required';
                  showErrorAlert = true;
                  return null;
            }           
        }
        
        system.debug('userId:' +userinfo.getUserId());
        system.debug('partnerContactId:' +partnerContactId);
        system.debug('partnerTandCAccepted:' +partnerTandCAccepted);
        
        if(!partnerTandCAccepted){
            system.debug('In T&C not accepted');
            PageReference partnerTandCPage = TermsConditionsUtil.redirectToTermsConditions(partnerContactId,proposalObj.id,'Proposal',selectedDesign,'0','PARTNER','P');
                  
            system.debug('partnerTandCPage pageRef : ' +partnerTandCPage.getUrl());  
               
            if(userinfo.getUserType()=='PowerPartner' &&baseURL.containsIgnoreCase('partner'))               
                 redirectUrl= '/partner' + partnerTandCPage.getUrl();
            else
                redirectUrl= partnerTandCPage.getUrl();
                  
            system.debug('redirectURL:' +redirectUrl); 
            displayTandCURL = true;
            return null;  
        }
//          }else{
            System.debug('selectedDesign: ' + selectedDesign);
            DesignTool.function=selectedDesign;
            DesignToolWebservice.DesignToolWebserviceResponse responseObj = DesignTool.getModifyProposalURL(proposalObj.id);  
       
            System.debug('responseObj: ' + responseObj);
            
            if(responseObj.status == ProposalUtil.FAILURE || responseObj.status == ProposalUtil.ERROR){
                errorMessage = responseObj.errorMessage;
                showErrorAlert = true;
                return null;            
            }
            System.debug('responseObj2: ' + responseObj);
            
            //shouldRedirect = true;
            if(responseObj.status == 'Warning'){
                showWarning = true;
                warningMessage = responseObj.errorMessage;
                redirectUrl = responseObj.url;
                return null;                 
            }
            
            if(responseObj.status!=null&&responseObj.status=='SUCCESS'){
                //PageReference redirectDesign = new PageReference(responseObj.url);
               // redirectDesign.setRedirect(true);
               // return redirectDesign;
               redirectUrl=responseObj.url;
            }  
            else{
                //PageReference redirectDesign = new PageReference('/'+proposalObj.id);
                //redirectDesign.setRedirect(true);
                //return redirectDesign;
                if(Userinfo.getUserType()=='PowerPartner'){
                redirectUrl='partner'+'/'+proposalObj.id;
                }
                else{
                redirectUrl='/'+proposalObj.id;
                }
            }
          shouldRedirect = true;       
//         }
         return null;
    }
        
    public List<SelectOption> getDesignTypes(){
        Contact loggedInUserContact=PRMContactUtil.getLoginUserAccountAndContact();
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('--None--','--None--'));
        if(loggedInUserContact!=null){
            if(loggedInUserContact.As_Built__c=='Granted'){
                options.add(new SelectOption('AsBuilt','As Built'));    
            }
            /*
            if(loggedInUserContact.Managing_Partner_AVL_Costs__c=='Granted'){
                options.add(new SelectOption('Managing Partner AVL Costs','Managing Partner AVL Costs'));
            }
            if(loggedInUserContact.Managing_Partner_AVL_Prices__c=='Granted'){
                options.add(new SelectOption('Managing Partner AVL Prices','Managing Partner AVL Prices'));
            }
            
            if(loggedInUserContact.Manual_Design__c=='Granted')    {
                options.add(new SelectOption('Manual Design','Manual Design'));
            }
            */
            if(loggedInUserContact.ePermitting__c=='Granted'){
               // options.add(new SelectOption('ePermitting','ePermitting'));
            }
            if(loggedInUserContact.Modify_Proposal__c=='Granted'){
                if(unsignedOrVoided){                
                    options.add(new SelectOption('DesignNewProposal','New Project'));
                    options.add(new SelectOption('SavedProject','Saved Project'));
                }
                else{
                    options.add(new SelectOption('ModifyProposal','Modify Proposal'));                  
                }
            }
            /*
            if(loggedInUserContact.Design_New_Proposal__c=='Granted'){
                options.add(new SelectOption('Design New Proposal','Design New Proposal'));
            }
            */
            if(loggedInUserContact.eAudit__c=='Granted'){
                options.add(new SelectOption('eAudit','eAudit'));
            }
            
        }
        return options;
    }
   
}