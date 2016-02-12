public class ProposalModifyApiHandler extends ProposalBaseHandler {
    override public String getApiName() {
        return 'Proposal Modify';
    }
    
    public void validateRequest(RestServiceDto.Request req) {
        List<String> requriedFields = new List<String>();
        requriedFields.add('proposalName');
        requriedFields.add('action');
        validateRequiredFields(requriedFields, req);
    }
    
    
    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        String SUBMIT= 'Submit';
        String VOIDSTR= 'Void';
        String INACTIVE= 'Inactive';
        String EXPIRED= 'Expired';
        String VOIDEDSTR= 'Voided';
        String WITHDRAWN= 'Withdrawn';
        string msgStr ='';
        String testMode = req.jsonReader.getString('testMode');
        resp.jsonWriter = new JsonWriter(true);
        if(!String.isEmpty(testMode) && testMode == '1'){    	
            // resp.jsonWriter = new JsonWriterRestService(true);
            resp.jsonWriter.write('Message', 'Proposal Submit/Void');
        }
        else{
            validateRequest(req);
            String proposalName = req.jsonReader.getString('proposalName');
            String actionString = req.jsonReader.getString('action');
            system.debug('proposalNameproposalName' +  proposalName) ;
            system.debug('action' +  actionstring) ;
            Proposal__c proposalObj   = getProposalByName(proposalName);
            system.debug('proposalObj>' + proposalObj);
            if(proposalObj==null) {
                resp.jsonWriter.write('Message','Proposal with specified proposal name  [' + proposalName + '] is not found');
                throw createBusinessException(RestServiceDto.Error_NotFound, 'Proposal with specified proposal name  [' + proposalName + '] is not found');
            }
            Id sunrunId = System.Label.Sunrun_Inc_Id;
            //proposal Submit 
            if(actionString==SUBMIT){
                if(proposalObj.stage__c == 'Created' || proposalObj.stage__c == 'Ready for Submission'){
                    if(proposalObj.stage__c == 'Created' && proposalObj.Sales_Partner__c == sunrunId
                       &&  proposalObj.Agreement_Type__c == 'Customer Owned - Full Upfront'
                       && (proposalObj.Finance_Type__c != 'N/A' && proposalObj.Finance_Type__c != 'Bank Financed')){
                           resp.jsonWriter.write('Message','Since this is a proposal for Customer Owned system, please specify Finance Type (either Bank Financed or N/A)');
                           throw createBusinessException(RestServiceDto.Error_ValidationError, 'Since this is a proposal for Customer Owned system, please specify Finance Type (either Bank Financed or N/A)');
                       }
                    else{
                        DesignToolWebservice.DesignToolWebserviceResponse responseObj = new DesignToolWebservice.DesignToolWebserviceResponse();
                        responseObj = DesignTool.canUserSubmitProposal(proposalObj.Opportunity__c);
                        if(responseObj!= null && responseObj.status==ProposalUtil.WARNING){
                            responseObj.errorMessage = 'Are you sure you would like to submit this proposal? <br/>';
                            responseObj.errorMessage += 'NTP has been revoked on the original proposal. Please remember to request NTP again on this modification.';
                            resp.jsonWriter.write('Message',responseObj.errorMessage);
                            throw createBusinessException(RestServiceDto.Error_ValidationError, responseObj.errorMessage);
                        }
                    }
                }
                else{
                    if(proposalObj.stage__c == 'SR Ops Received'){
                        resp.jsonWriter.write('Message','This is [' + proposalName + '] an approved proposal. You can not resubmit it again ');
                        throw createBusinessException(RestServiceDto.Error_ValidationError, 'This is [' + proposalName + '] an approved proposal. You can not resubmit it again');
                    }else{
                        resp.jsonWriter.write('Message','Proposal stage is invalid for submission : [' + proposalName + ']');
                        throw createBusinessException(RestServiceDto.Error_ValidationError, 'Proposal stage is invalid for submission : [' + proposalName + ']');
                    }
                }
                msgStr= EDPWebServices.submitProposal(proposalObj.Id);
                resp.jsonWriter.write('Message',msgStr);
                if(msgStr.contains('submitted successfully')){
                    throw createBusinessException('Success', msgStr);
                }else {
                    throw createBusinessException(RestServiceDto.Error_ValidationError, msgStr);
                }
                
            }
            // Void Proposal 
            else if(actionString==VOIDSTR) {
                if(proposalObj.stage__c == VOIDEDSTR){
                    throw createBusinessException(RestServiceDto.Error_ValidationError, 'Proposal is already voided : [' + proposalName + ']');  
                }
                if(proposalObj.stage__c == INACTIVE||proposalObj.stage__c == EXPIRED || proposalObj.stage__c == WITHDRAWN){
                    throw createBusinessException(RestServiceDto.Error_ValidationError, 'Proposal stage is invalid for void : [' + proposalName + ']');  
                }
                msgStr = EDPWebServices.voidProposal(proposalObj.Id);
                resp.jsonWriter.write('Message',msgStr);
                if(msgStr.contains('voided successfully')){
                    throw createBusinessException('Success' ,msgStr);
                }else{ throw createBusinessException(RestServiceDto.Error_ValidationError, msgStr);}
                
            }else{
                resp.jsonWriter.write('Message','Action parameter values are not valid');
                throw createBusinessException(RestServiceDto.Error_InvalidRequest, 'Action parameter values are not valid');  
                
            }
        }
    }
}