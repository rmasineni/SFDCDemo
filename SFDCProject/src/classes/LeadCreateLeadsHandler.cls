/**
 * This interface defines the usual life cycle methods that we go through as we 
 * process the leads. There will be a default implementaion of this interface (LeadCreateLeadsHandlerImpl)
 * which can be overridden for different clients.
 */
public interface LeadCreateLeadsHandler {

    /**
	 * Main method of the handler, which calls all other mehtods. This is the method invokved by the LeadServiceImpl.
	 * 
	 * Usually client's don't need to override this method but they can if they want complete control over processing of 
	 * createLeadsRequest.
	 */
	List<LeadServiceDto.CreateLeadResponse> handleRequestV1(RestRequest req, RestResponse resp);
    
    /**
	 * Parses the given json into various list of lead response objects. 
     * 
	 * If there is any error while parsing the whole response then throw exception. 
	 * If there is any error while parsing the individual lead, then populate its 
	 * corresponding object's status=error, corresponding code and detailed message.
	 */
	List<LeadServiceDto.CreateLeadResponse> parseRequest(String json);

    LeadServiceDto.CreateLeadResponse parseLead(Map<String, Object> jsonLead);
    
	/**
	 * Validate the leads to make sure they have the appropriate fields populated.
	 * 
	 * if there is any error, then populate the corresponding leads status=error, (and code/message as appropriate)
	 */
	void validateLeads(List<LeadServiceDto.CreateLeadResponse> leads);

	/**
	 * Finally inserts or updates the leads as appropriate.
	 */
	void insertOrUpdateLeads(List<LeadServiceDto.CreateLeadResponse> leads);

	/**
	 * Prepare the lead responses to be returned to client. You can populate the required fields
	 */ 
	void prepareResponses(List<LeadServiceDto.CreateLeadResponse> leads);
}