public with sharing class ContactApiGetContactHandler extends RestService implements RestRequestHandler {
    public override String getApiName() {
        return 'ContactApiGetContact';
    }

    public override void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        prepareResponse(queryContact(req, resp), req, resp);
    }
    
    public Contact queryContact(RestServiceDto.Request req, RestServiceDto.Response resp) {
		String contactNumber =  getRecordIdFromPath(req, 'contacts');
        String soql = createSoqlWithAuditFields(ContactApiDto.getContactApiContactFieldMapping().values(), 'Contact', 'contact_number__c = :contactNumber or id = :contactNumber');
        
       	List<SObject> sobjs = Database.query(soql);
        
        if (sobjs.isEmpty()) {
            throw createBusinessException(RestServiceDto.Error_NotFound, 'Contact with specified Contact Number [' + contactNumber + '] is not found.');
        }
        
        resp.stopWatch.markSubElapsedTime();
        
        return (Contact) sobjs.get(0);
    }
    
	public void prepareResponse(Contact contact, RestServiceDto.Request req, RestServiceDto.Response resp) {
        addToResponse(contact, ContactApiDto.getContactApiContactFieldMapping(), true, req, resp);
        resp.stopWatch.markSubElapsedTime();
    }
}