public class CustomOptyContactRole {
        private final Opportunity opportunityObj;
        public List<ContactRoleWrapper> contactRoleWrapperList {get;set;} 
        public String message {get;set;}
        public String actionName{get;set;}
        public boolean isPartnerUser{get;set;}
        public boolean isAEEUser{get;set;}
        public Id opportunityId {get;set;}
        public Boolean confirmMode {get;set;}
        public Boolean voidProposals {get;set;}
        public boolean enableConfirmSave {get;set;}
        Set<Id> oldPrimaryContactIds;
        public String getBaseURL() {
                String baseURL = EDPUtil.getBaseURL();
                return baseURL;
        }
        Map<Id, OpportunityContactRole>  oldContactRolemap;
        public List<SelectOption> getContactRoles() {
        List<SelectOption> contactRoles = new List<SelectOption>();
        contactRoles.add(new SelectOption('', '-- None --'));
                contactRoles.add(new SelectOption('Homeowner', 'Homeowner'));
                contactRoles.add(new SelectOption('Other', 'Other'));
                return contactRoles;
    }
    
        public CustomOptyContactRole(ApexPages.StandardController stdController){
                confirmMode = false;
                voidProposals = false;
                enableConfirmSave = false;
                oldContactRolemap = new Map<Id, OpportunityContactRole> ();
                opportunityObj = (Opportunity)stdController.getRecord();                
                opportunityId = opportunityObj.Id;
                System.debug('opportunityId: ' + opportunityId);
                contactRoleWrapperList = new List<ContactRoleWrapper>();
                oldPrimaryContactIds = new Set<Id>();
                Set<Id> contactIds = new Set<Id>();
                List<OpportunityContactRole> contactRoleList = new List<OpportunityContactRole>();
                
                for(OpportunityContactRole tempContactRoleObj : [Select Id, ContactId, OpportunityId, isPrimary, Role from OpportunityContactRole
                                                                                                                        where OpportunityId =:opportunityObj.Id]){
                        contactIds.add(tempContactRoleObj.ContactId);
                        contactRoleList.add(tempContactRoleObj);
                        oldContactRolemap.put(tempContactRoleObj.Id, cloneContactRole(tempContactRoleObj));
                        if(tempContactRoleObj.isPrimary == true){
                                oldPrimaryContactIds.add(tempContactRoleObj.contactId);
                        }
                }
                
                Map<Id, Contact> contactMap = new Map<Id, Contact>();
                if(contactIds.size() > 0){
                    contactMap = new Map<Id, Contact>([Select Id, Credit_Status__c,Credit_Received__c, Credit_Submitted__c, Credit_Decision_on_Portal__c, name from Contact where id in :contactIds order by name asc]);
                }
                for(OpportunityContactRole tempContactRoleObj : contactRoleList){
                        Contact tempContactObj = contactMap.get(tempContactRoleObj.contactId);
                        ContactRoleWrapper roleWrapperObj = new ContactRoleWrapper(tempContactRoleObj, tempContactObj);
                        contactRoleWrapperList.add(roleWrapperObj);
                        
                }
                User userObj = PRMContactUtil.getLoginUser();
                if(userObj != null && userObj.contactId != null && userObj.User_Division_Custom__c != null && !userObj.User_Division_Custom__c.contains(label.AEE_label)){
                        isPartnerUser = true;
                }
                if(userObj != null && userObj.contactId != null && userObj.User_Division_Custom__c != null && userObj.User_Division_Custom__c.contains(label.AEE_label)){
                        isAEEUser = true;
                }               
                                
        }
        public List<SelectOption> getActions() {
        List<SelectOption> actions = new List<SelectOption>();
        actions.add(new SelectOption('', '-- None --'));
                actions.add(new SelectOption('EditContactRoles', 'Edit Contact Roles'));
                actions.add(new SelectOption('NewContact', 'New Contact'));
        return actions;
    }

        public Pagereference userActions(){
                Pagereference pageRef = null;
                System.debug('actionName: ' + actionName);
                message = '';

                if(actionName == null || actionName == ''){
                        message = 'Please select an user action';
                        return null;
                }
                /*
                else if(actionName == 'NewContact'){
                        //Pagereference ref;
                        //ref = new PageReference('/partner/apex/NewCustomerContactOverridden?opportunityId=' + opportunityObj.Id);
                        //ref.setRedirect(true);
                        //System.debug('New contact creation ... ');  
                        return null;
                }else if(actionName == 'EditContactRoles'){
                        return null;
                }else{
                        return null;
                }
                */
                else if(actionName == 'NewContact'){
                        //Pagereference ref;
                        //ref = new PageReference('/partner/apex/NewCustomerContactOverridden?opportunityId=' + opportunityObj.Id);
                        //ref.setRedirect(true);
                        //System.debug('New contact creation ... ');  
                        if(isPartnerUser==true && isAEEUser==false){
                         Pagereference ref;
                         ref = new PageReference('/partner/apex/NewCustomerContactOverridden?opportunityId=' + opportunityObj.Id);
                         return ref;    
                        }
                        else if(isAEEUser==true){
                         Pagereference ref;
                         ref = new PageReference('/aeepartner/apex/NewCustomerContactOverridden?opportunityId=' + opportunityObj.Id);
                         return ref;    
                        }
                        else
                         {
                         Pagereference ref;
                         ref = new PageReference('/apex/NewCustomerContactOverridden?opportunityId=' + opportunityObj.Id);
                         return ref;
                         }
                }else if(actionName == 'EditContactRoles'){
                        if(isPartnerUser==true && isAEEUser==false){
                         Pagereference ref;
                         ref = new PageReference('/partner/apex/Edit_Contact_Roles?id=' + opportunityObj.Id);
                         return ref;    
                        }
                        else if(isAEEUser==true){
                         Pagereference ref;
                         ref = new PageReference('/aeepartner/apex/Edit_Contact_Roles?id=' + opportunityObj.Id);
                         return ref;    
                        }
                        else {
                         Pagereference ref;
                         ref = new PageReference('/apex/Edit_Contact_Roles?id=' + opportunityObj.Id);
                         return ref;
                        }
                }else{
                        return null;
                }
        }

        public Integer getContactRoleWrapperListSize(){
                Integer value = 0;
                if(contactRoleWrapperList != null){
                        value = contactRoleWrapperList.size();
                }
                return value;
        }

        public class ContactRoleWrapper{
                public ContactRoleWrapper(){
                        
                }
                public ContactRoleWrapper(OpportunityContactRole contactRoleObj, Contact contactObj){
                        this.contactRoleObj = contactRoleObj;
                        this.contactObj = contactObj;
                }
                public OpportunityContactRole contactRoleObj {get;set;}
                public Contact contactObj {get;set;}
                public boolean selected {get;set;}
        }
        
        private OpportunityContactRole cloneContactRole(OpportunityContactRole contactRoleObj){
                OpportunityContactRole newRoleObj = new OpportunityContactRole();
                newRoleObj.contactId = contactRoleObj.contactId;
                newRoleObj.opportunityId = contactRoleObj.opportunityId;
                newRoleObj.isprimary = contactRoleObj.isPrimary;
                newRoleObj.role = contactRoleObj.role;
                return newRoleObj;
        }
        private boolean isContactRoleModified(OpportunityContactRole newContactRoleObj, OpportunityContactRole oldContactRoleObj){
                boolean isRoleModified = false;
                if(newContactRoleObj != null && oldContactRoleObj != null){
                        if(newContactRoleObj.role != oldContactRoleObj.role){
                                isRoleModified = true;
                        }
                }
                return isRoleModified;
        }

        public Pagereference ConfirmSaveContactRoles(){
                Pagereference ref;
                voidProposals = true;
                ref = saveContactRoles();
                return ref;
        }
        
        public Pagereference saveContactRoles(){
                confirmMode = false;
                List<OpportunityContactRole> modifiedContactRoles = new List<OpportunityContactRole>();
                Boolean contactRoleModified = false;
                Boolean hasPrimaryContactRole = false;
                Set<Id> modifiedContactIds = new Set<Id>();
                Set<Id> primaryContactIds = new Set<Id>();
                
                for(ContactRoleWrapper wrapperObj : contactRoleWrapperList){
                        
                        if(wrapperObj.contactRoleObj.isprimary == true){
                                primaryContactIds.add(wrapperObj.contactRoleObj.contactId);
                        }
                        /*
                        if(voidProposals == false){
                                OpportunityContactRole oldContactRoleObj = oldContactRolemap.get(wrapperObj.contactRoleObj.Id);
                                if(oldContactRoleObj != null){
                                        if(isContactRoleModified(wrapperObj.contactRoleObj, oldContactRoleObj) == true){
                                                modifiedRoleIds.add(wrapperObj.contactRoleObj.Id);
                                        }
                                }
                        }
                        */
                        modifiedContactRoles.add(wrapperObj.contactRoleObj);
                }
                
                if(primaryContactIds.size() != 1){
                        enableConfirmSave = false;
                        String errorMessage = 'Oppotunity should have one Primary Contact.';
                        Exception expObj = new BaseException(errorMessage);
                        expObj.setMessage(errorMessage);
                        ApexPages.addMessages(expObj);
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,errorMessage));
                        return null;                    
                }

                for(Id oldPrimaryContactId : oldPrimaryContactIds){
                        if(!primaryContactIds.contains(oldPrimaryContactId)){
                                modifiedContactIds.add(oldPrimaryContactId);
                        }
                }
                
                for(Id newPrimaryContactId : primaryContactIds){
                        if(!oldPrimaryContactIds.contains(newPrimaryContactId)){
                                modifiedContactIds.add(newPrimaryContactId);
                        }
                }               

                if(modifiedContactIds.size() > 0 && voidProposals == false){
                        enableConfirmSave = true;
                        String errorMessage = 'Editing the Contact role(s) will void the proposals associated with this Opportunity. Click \'Confirm\' to save changes. Otherwise, click \'Cancel\'.';
                        Exception expObj = new BaseException(errorMessage);
                        expObj.setMessage(errorMessage);
                        ApexPages.addMessages(expObj);
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,errorMessage));
                        return null;                                    
                }
                
                if(modifiedContactRoles.size() > 0){
                        update modifiedContactRoles;
                }
                Map<Id, String> reasonMap = new Map<Id, String>();
                if(voidProposals == true && enableConfirmSave == true){
                        Set<Id> optyIds = new Set<Id>();
                        optyIds.add(opportunityId);
                        Map<Id, Map<Id, Proposal__C>> optyProposalmap = ProposalUtil.getActiveProposalsForOpportunities(optyIds);
                        if(optyProposalmap != null && optyProposalmap.containsKey(opportunityId)){
                             Map<Id, Proposal__C> proposalMap = optyProposalmap.get(opportunityId);
                             if(proposalMap != null && !proposalMap.isEmpty()){
                                    ProposalUtil.voidProposals(proposalMap, reasonMap, true);
                             }
                        }
                }
                
                voidProposals = false;
                confirmMode = true;                
               // Pagereference ref = new PageReference('/partner/' + opportunityId);
                System.debug('opportunityId: ' + opportunityId);
                //ref.setRedirect(true);  
                return null;
        }
        public pagereference cancel(){
            if(isPartnerUser==true && isAEEUser==false){
                Pagereference ref = new PageReference('/partner/apex/partneropportunitycreate?id=' + opportunityId);
                return ref;
                }
                else if(isAEEUser==true){
                Pagereference ref = new PageReference('/aeepartner/apex/partneropportunitycreate?id=' + opportunityId);
                return ref;
                }
                else{
                Pagereference ref = new PageReference('/apex/partneropportunitycreate?id=' + opportunityId);
                return ref;
                }
                return null;
        }
        public class BaseException extends Exception {}
}