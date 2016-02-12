/**
 * This is part of Lead API which exposes set of Rest Services to interact with Leads. This class specifically lets different partners
 * upload one or more leads using rest service.
 * 
 * Full url for this would be,
 * https://{instance}.salesforce.com/services/apexrest/v1/leads/createLead
 */
@RestResource(urlMapping='/v1/leads/createLead1')
global without sharing class LeadCreateLeadRestService {

    private static BaseClass utils = new BaseClass();
    
    //This map keeps the mapping betweeen current user email and corresponding handler. If there is no handler found for specific
    //email, then default handler (LeadCreateLeadsHandlerImpl) will be used.
    private static Map<String, String> handlers = new Map<String, String>{
        //There is nothing specific but only default (LeadCreateLeadsHandlerImpl)
    };

    @HttpPost
    global static LeadServiceDto.CreateLeadResponse httpPost() {
        utils.debug('Coming to httpPost request with Request ' + RestContext.request + ' and response ' + RestContext.response);
        
        String handlerClz = utils.firstNonEmpty(handlers.get(UserInfo.getUserEmail()), 'LeadCreateLeadsHandlerImpl');
        utils.debug('Chosen handler for current user ' + UserInfo.getUserEmail() + ' is ' + handlerClz);
        
        LeadCreateLeadsHandler handler = (LeadCreateLeadsHandler) utils.createInstance(handlerClz);
		
		List<LeadServiceDto.CreateLeadResponse> leads = handler.handleRequestV1(RestContext.request, RestContext.response);
		
        LeadServiceDto.CreateLeadResponse resp =  leads.get(0);
        if (resp.errorCode == RestServiceDto.Error_RequiredFieldsMissing) {
            RestContext.response.statusCode = 400;
        }
        
		return resp;
    }
}