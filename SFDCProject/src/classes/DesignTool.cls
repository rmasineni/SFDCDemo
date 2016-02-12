public class DesignTool {
    Public Static String function;
    public static DesignToolWebservice.DesignToolWebserviceResponse getDesignToolURL(String objectId, String prospectId, String ObjectType){
        
        DesignToolWebservice.DesignToolWebserviceResponse responseObj = new DesignToolWebservice.DesignToolWebserviceResponse();
        responseObj.status = ProposalUtil.SUCCESS;        
        String urlStr = '';
        String prospectIdVal = '';
        String designToolSecretKey = Label.Design_Tool_Secret_Key;
        String returnURL = '';
        String baseURL = EDPUtil.getBaseURL();
        String designToolFromPartnerPortal = Label.Design_Tool_From_PartnerPortal;
        String designToolFromSalesforce = Label.Design_Tool_From_Salesforce;
        String Authorities=EDPUtil.getAccessRights();
        User userObj = PRMContactUtil.getLoginUser(); 
        String designToolBaseURL = (userObj.contactId != null) ? designToolFromPartnerPortal : designToolFromSalesforce;
        String designToolUserId = userObj.email;
        if(ObjectType == 'Lead'){
            prospectIdVal = 'L' + prospectId;
            returnURL = (userObj.contactId != null) ? EDPUtil.getBaseURL() + '/apex/CustomizeLeadDetailPage?Id=' + objectId : EDPUtil.getBaseURL() + '/' + objectId;
        }else if(ObjectType == 'Opportunity'){
            prospectIdVal = 'O' + prospectId;
            returnURL = (userObj.contactId != null) ? EDPUtil.getBaseURL() + '/apex/partneropportunitycreate?id=' + objectId : EDPUtil.getBaseURL() + '/' + objectId;
        }
        /*else if(ObjectType == 'Proposal'){
            prospectIdVal = 'P' + prospectId;
            returnURL = (userObj.contactId != null) ? EDPUtil.getBaseURL() + '/apex/proposalNavigateLightMile?Id=' + objectId : EDPUtil.getBaseURL() + '/' + objectId;
        }
        */
        System.debug('returnURL: ' + returnURL);

        String expiresVal = '';
        String signatureVal = '';
        Long Lexpires = SunRunS3RestConnection.getExpirationTime();
        
        String canonicalStr = 'prospectId=' + prospectIdVal + '&expires=' + Lexpires + '&userId=' + EncodingUtil.urlEncode(designToolUserId,'UTF-8');
        if(function!=null){
           canonicalStr = 'prospectId=' + prospectIdVal + '&expires=' + Lexpires + '&userId=' + EncodingUtil.urlEncode(designToolUserId,'UTF-8')+'&function='+function+'&authorities='+authorities;
        } 
        System.debug('canonicalStr: ' + canonicalStr);
        String signed = SunRunS3RestConnection.make_sunrunProxysig(canonicalStr, designToolSecretKey);
        String codedsigned = EncodingUtil.urlEncode(signed,'UTF-8');
        //String codedsigned = signed;
        System.debug('signed: ' + signed);
        System.debug('codedsigned: ' + codedsigned);
        
        if(ObjectType == 'Lead'){
            responseObj.url = designToolBaseURL + '?' + canonicalStr + '&signature=' + codedsigned + '&returnUrl=' + returnURL ;
            //if(function!=null)
            //responseObj.url = designToolBaseURL + '?' + canonicalStr + '&signature=' + codedsigned+ '&returnUrl=' + returnURL ;            
        }else if(ObjectType == 'Opportunity'){
            String errMsg = '';
			
			List<Opportunity> OpptyList = [select id, name, Annual_kWh_usage__c,Utility_Company__c,Territory__c from Opportunity where id =:objectId];
            system.debug('Annual kWh Use:' + OpptyList[0].Annual_kWh_usage__c);
            List<Territory_Information__c> isTerritoryList = [Select id, Name, IsTerritory__c from Territory_Information__c where IsTerritory__c =: true];
            set<string> isTerritoryTrue = new set<string>();
            Boolean isTerritory = false;
            if(isTerritoryList != null && isTerritoryList.size() > 0){
                for(Territory_Information__c terriInfo : isTerritoryList){
                    isTerritoryTrue.add(terriInfo.name);
                }
                
                if(isTerritoryTrue.contains(OpptyList[0].Utility_Company__c)){
                    isTerritory = true;
                }
            }
            
            if(isTerritory == true && OpptyList[0].Utility_Company__c != null && OpptyList[0].Territory__c == null){
                responseObj.errorMessage = 'NoTerritory';
                responseObj.status = ProposalUtil.FAILURE;
                responseObj.url = '';
                System.debug('responseObj:::::::::::::::::::::::::83 ' + responseObj);
                return responseObj;
            }
            responseObj.url = designToolBaseURL + '?' + canonicalStr + '&signature=' + codedsigned + '&returnUrl=' + returnURL;
            DesignToolWebservice.DesignToolWebserviceResponse tempResponse = canUserCreateORModifyProposal(objectId);
            if(tempResponse.errorMessage != null){
                responseObj.status = tempResponse.status;
                responseObj.errorMessage = tempResponse.errorMessage;
                System.debug('responseObj:::::::::::::::::::::::::54 ' + responseObj);
                return responseObj;            
            }

        }
        System.debug('responseObj:::::::::::::::::::::::::94 ' + responseObj);
        return responseObj;
    }

    public static DesignToolWebservice.DesignToolWebserviceResponse getModifyProposalURL(String objectId){
        String Authorities=EDPUtil.getAccessRights();   
        Map<Id, List<ServiceContract>> serviceContractsMap = new  Map<Id, List<ServiceContract>>();
        set<id> opptyId = new set<id> ();
        DesignToolWebservice.DesignToolWebserviceResponse responseObj = new DesignToolWebservice.DesignToolWebserviceResponse();
        responseObj.status = '';
        try{
            String urlStr = '';
            String prospectIdVal = '';
            String designToolSecretKey = Label.Design_Tool_Secret_Key;
            //String designToolBaseURL = Label.Design_Tool_Base_URL;
            String returnURL = '';
            String baseURL = EDPUtil.getBaseURL();

            String designToolFromPartnerPortal = Label.Design_Tool_From_PartnerPortal;
            String designToolFromSalesforce = Label.Design_Tool_From_Salesforce;
            User userObj = PRMContactUtil.getLoginUser(); 
            String designToolBaseURL = (userObj.contactId != null) ? designToolFromPartnerPortal : designToolFromSalesforce;
            
            Set<Id> proposalIds = new Set<Id>();
            proposalIds.add(objectId);
            List<Proposal__c> proposalList = ProposalUtil.getProposals(proposalIds);
            if(proposalList.size() == 0){
                responseObj.status = ProposalUtil.FAILURE;
                responseObj.errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000001').error_message__c;
                responseObj.url = '';
                return responseObj;
            }
            Proposal__C proposalObj = proposalList[0];
            if(proposalObj.Proposal_Source__c == null || proposalObj.Proposal_Source__c != ProposalUtil.BLACK_BIRD){
                responseObj.status = ProposalUtil.FAILURE;
                responseObj.errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000004').error_message__c;
                responseObj.url = '';
                return responseObj;
            }
    
            if(proposalObj.Stage__c != null 
               && (proposalObj.Stage__c == ProposalUtil.INVALID || proposalObj.Stage__c == ProposalUtil.SUNRUN_VOID )){
                   
                   if(proposalObj != null && proposalObj.Opportunity__c != null ){
                       opptyId.add(proposalObj.Opportunity__c);
                       serviceContractsMap = ServiceContractUtil.getServiceContracts('scforvoidprops', opptyId);
                       system.debug('ServiceContractforVoid proposals' + serviceContractsMap);
                   }
                   
                   if( !(serviceContractsMap.isEmpty() 
                         && proposalUtil.getIgnoreVoidReasons().contains(proposalObj.Status_Reason__c )) ) {    
                             responseObj.status = ProposalUtil.FAILURE;
                             responseObj.errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000002').error_message__c;
                             responseObj.url = '';
                             return responseObj;
                         }
            }
    
            //As Built Validations ....
            Boolean result = true;
            if(function == 'AsBuilt'){
                result = canInvokeAsBuiltAction(objectId);
                if(result == false){
                    responseObj.status = ProposalUtil.FAILURE;
                    responseObj.errorMessage = 'This is not a valid proposal to create an As Built change order either because Service Contract is not associated with proposal or Service Contract is not at M2 stage or there is already a Sunrun Approved As Built change order.';
                    responseObj.url = '';
                    System.debug('responseObj: ' + responseObj);
                    return responseObj;   
                }
            }
            //else{

	            String designToolUserId = userObj.email;
	            returnURL = EDPUtil.getBaseURL() + '/' + proposalObj.Id;
	            prospectIdVal = 'O' + proposalObj.Opportunity__r.Prospect_Id__c;
	            
	            System.debug('returnURL: ' + returnURL);
	            String canonicalStr = 'prospectId=' + prospectIdVal;
	    
	            String expiresVal = '';
	            String signatureVal = '';
	            Long Lexpires = SunRunS3RestConnection.getExpirationTime();
	
	            String proposalName = proposalObj.Name; 
	
	            String tempSignedRootName = ProposalUtil.getSignedRootProposalName(proposalObj);
	            System.debug('tempSignedRootName: ' + tempSignedRootName);
	            String signedRootId = tempSignedRootName;
	
	            String modifyProposalInfo = '';
	
	        
	            canonicalStr += '&expires=' + Lexpires + '&userId=' + EncodingUtil.urlEncode(designToolUserId,'UTF-8') ;
	            if(function!=null){
	                canonicalStr +='&function='+function+'&authorities='+authorities;
	            }
	            if(proposalName != null && proposalName != ''){
	                canonicalStr +=  '&parentProposalId=' + proposalName;
	            }
	            
	            if(signedRootId != null && signedRootId != ''){
	                canonicalStr += '&signedRootId=' + signedRootId;
	            }           
	            
	            System.debug('canonicalStr: ' + canonicalStr);
	            String signed = SunRunS3RestConnection.make_sunrunProxysig(canonicalStr, designToolSecretKey);
	            String codedsigned = EncodingUtil.urlEncode(signed,'UTF-8');
	            urlStr = designToolBaseURL + '?' + canonicalStr  + '&signature=' + codedsigned + '&returnUrl=' + returnURL ;
	            
	            System.debug('urlStr: ' + urlStr);
	            responseObj.status = ProposalUtil.SUCCESS;
	            responseObj.errorMessage = '';
	            responseObj.url = urlStr;           

				if(function != 'AsBuilt'){
	                DesignToolWebservice.DesignToolWebserviceResponse tempResponse = canUserCreateORModifyProposal(proposalObj.Opportunity__c);
	                if(tempResponse.errorMessage != null){
	                    responseObj.status = tempResponse.status;
	                    responseObj.errorMessage = tempResponse.errorMessage;               
	                    return responseObj;  
	                }
				} 
			
			//}           
            
        }catch(Exception exceptionObj){
            responseObj.status = ProposalUtil.FAILURE;
            responseObj.errorMessage = exceptionObj.getmessage();
            responseObj.url = '';
            System.debug('Exception: ' + exceptionObj); 
        }
        return responseObj;
    }   

    public static DesignToolWebservice.DesignToolWebserviceResponse canUserCreateORModifyProposal(Id objectId){
        DesignToolWebservice.DesignToolWebserviceResponse responseObj = new DesignToolWebservice.DesignToolWebserviceResponse();
        responseObj.status = ProposalUtil.SUCCESS;
        String result = ProposalUtil.SUCCESS;
        Set<Id> searchIds = new Set<Id>();
        searchIds.add(objectId);
        Contact loginUserContact = PRMContactUtil.getLoginUserAccountAndContact();
        Map<Id, List<ServiceContract>> serviceContractsMap = ServiceContractUtil.getServiceContracts('Opportunity', searchIds);
        if(serviceContractsMap != null && serviceContractsMap.containsKey(objectId)){
            Set<String> ntpStages = ServiceContractUtil.getNTPStages();
            Set<String> postNTPStages = ServiceContractUtil.getAfterNTPStages();
            
            for(ServiceContract serviceContractObj : serviceContractsMap.get(objectId)){
                System.debug('serviceContractObj.Status__c: 0' + serviceContractObj.Status__c);
                System.debug('postNTPStages: ' + postNTPStages);
                if(((serviceContractObj.TE_Fund_Name__c != null && serviceContractObj.TE_Fund_Name__c != '') 
                    || (postNTPStages.contains(serviceContractObj.Status__c))) && PRMContactUtil.isPartnerContact(loginUserContact)){
                    responseObj.status = ProposalUtil.ERROR;
                    responseObj.errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000023').error_message__c; 
                    System.debug('serviceContractObj.Status__c: 1' + serviceContractObj.Status__c);
                    break;              
                }if(((serviceContractObj.TE_Fund_Name__c != null && serviceContractObj.TE_Fund_Name__c != '') 
                    || (postNTPStages.contains(serviceContractObj.Status__c))) && !PRMContactUtil.isPartnerContact(loginUserContact)){
                    responseObj.status = ProposalUtil.WARNING;
                    responseObj.errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000022').error_message__c; 
                    System.debug('serviceContractObj.Status__c: 2' + serviceContractObj.Status__c);
                    break;               
                }else if(ntpStages.contains(serviceContractObj.Status__c)) {
                    responseObj.status = ProposalUtil.WARNING;
                    responseObj.errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000022').error_message__c; 
                    System.debug('serviceContractObj.Status__c: 2' + serviceContractObj.Status__c);
                    break;                  
                }               
            }
        }       
        return responseObj;
    }


    public static DesignToolWebservice.DesignToolWebserviceResponse canUserSubmitProposal(Id objectId){
        System.debug('Inside DesignToolWebserviceResponse ' + objectId);
        DesignToolWebservice.DesignToolWebserviceResponse responseObj = new DesignToolWebservice.DesignToolWebserviceResponse();
        responseObj.status = ProposalUtil.SUCCESS;
        String result = ProposalUtil.SUCCESS;
        Set<Id> searchIds = new Set<Id>();
        searchIds.add(objectId);
        Contact loginUserContact = PRMContactUtil.getLoginUserAccountAndContact();
        if(!PRMContactUtil.isPartnerContact(loginUserContact)){
            return responseObj;
        }
        Map<Id, List<ServiceContract>> serviceContractsMap = ServiceContractUtil.getServiceContracts('Opportunity', searchIds);
        if(serviceContractsMap != null && serviceContractsMap.containsKey(objectId)){
            for(ServiceContract serviceContractObj : serviceContractsMap.get(objectId)){
                System.debug('serviceContractObj.Opportunity__r.Opportunity_Source_Type__c: ' + serviceContractObj.Opportunity__r.Opportunity_Source_Type__c);
                if(serviceContractObj.Opportunity__r != null && serviceContractObj.Opportunity__r.Opportunity_Source_Type__c != null 
                    && serviceContractObj.Opportunity__r.Opportunity_Source_Type__c ==  ProposalUtil.BLACK_BIRD){
					Set<String> contractStages = new Set<String>();
					contractStages.addall(ServiceContractUtil.getNTPStages());
					contractStages.addall(ServiceContractUtil.getAfterNTPStages());		
                    if((ServiceContractUtil.getNTPStages().contains(serviceContractObj.Status__c) 
                        || ServiceContractUtil.getAfterNTPStages().contains(serviceContractObj.Status__c)) 
                       && (serviceContractObj.TE_Fund_Name__c != null && serviceContractObj.TE_Fund_Name__c != '')){
                        responseObj.status = ProposalUtil.ERROR;
                        responseObj.errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000023').error_message__c;     
                        break;                      
                    }else if(((ServiceContractUtil.getNTPStages().contains(serviceContractObj.Status__c) 
                        		|| ServiceContractUtil.getAfterNTPStages().contains(serviceContractObj.Status__c)) 
                      || (serviceContractObj.Status__c == ServiceContractUtil.PENDING && 
                      		(contractStages.contains(serviceContractObj.Previous_Status__c)
                        	)))
                       && (serviceContractObj.TE_Fund_Name__c == null || serviceContractObj.TE_Fund_Name__c == '')){
                        responseObj.status = ProposalUtil.WARNING;
                        responseObj.errorMessage = 'NTP has been revoked on the original proposal. Please remember to request NTP again on this modification.';     
                        break;                      
                    }
                }        
            }
        }           
        return responseObj;
    }
    
    public static DesignToolWebservice.DesignToolWebserviceResponse getModifyProposalURLForOpty(String objectId){
        DesignToolWebservice.DesignToolWebserviceResponse responseObj = new DesignToolWebservice.DesignToolWebserviceResponse();
        responseObj.status = '';
        try{
                
        }catch(Exception exceptionObj){
            responseObj.status = ProposalUtil.FAILURE;
            responseObj.errorMessage = exceptionObj.getmessage();
            responseObj.url = '';
            System.debug('Exception: ' + exceptionObj); 
        }
        return responseObj;     
    }

    public static Boolean canInvokeAsBuiltAction(String objectId){
        Boolean result = false;
        Boolean validServiceContract = false;
        String objectName = 'Proposal';
        Set<Id> objectIds = new Set<Id>();
        objectIds.add(objectId);
        Map<Id, List<ServiceContract>> proposalSCMap = ServiceContractUtil.getServiceContracts(objectName, objectIds);
        List<ServiceContract> existingSCs = proposalSCMap.get(objectId);
        if(existingSCs != null && !existingSCs.isEmpty()){
            Set<String> scStages = new Set<String>();
            scStages.add('09. M2 received, Awaiting PTO');
            scStages.add('10. PTO Granted, Facility Active');
            ServiceContract scObj = existingSCs[0];
            if(scStages.contains(scObj.status__c)){
                validServiceContract = true;
                List<Proposal__c> existingASBuiltProposals = [Select Id, stage__c, Proposal_Scenarios__c from Proposal__c where opportunity__c =:scObj.Opportunity__c and stage__c = 'SR Approved' and Proposal_Scenarios__c = 'AS_BUILT'];
                if(existingASBuiltProposals == null || existingASBuiltProposals.isEmpty()){
                    result = true;
                }
            }
        }
        System.debug('Result: ' + result);
        return result;
    }

    /*
    public static String getProposalName(String name){
        String proposalId = '';
        if(name != null && name != ''){
            Integer val = name.indexOf('-');
            if(val < 0){
                val = name.indexOf(':');
            }
            
            if(val >= 0){
                proposalId = proposalName.substring(0,val)
            }
        }
        return proposalId;
    }
    */

}