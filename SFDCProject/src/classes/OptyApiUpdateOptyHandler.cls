global with sharing class OptyApiUpdateOptyHandler extends OptyApiBaseHandler {
    override public String getApiName() {
        return 'OptyApiUpdateOpty';
    }

    /**
     * Method implements the patch protocol for lead. For patch, it will process only the fields
     * which are explicitly requested in the request.
     */ 
    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        
        info('Coming to opty update handler...');
        
        OptyApiReadOptyHandler readHandler = new OptyApiReadOptyHandler();
        OptyApiCreateOptyHandler createHandler = new OptyApiCreateOptyHandler();
        
        parseRequest(req, resp);
        
        Opportunity opty = readHandler.queryOpty(req, resp);
        applyOptyPatch(opty, req, resp);
        createHandler.saveOpty(opty, req, resp);
        
        Account account = opty.account;
        if (account != null) {
            applyAccountPatch(account, req, resp);
            createHandler.saveOptyAccount(account, req, resp);
        }
		
        applyContactPatch(opty, account, req, resp);
        
        //We will need to send updated lead so we will delegate to read.		        
        readHandler.handleRequest(req, resp);
    }

    public void applyOptyPatch(Opportunity opty, RestServiceDto.Request req, RestServiceDto.Response resp) {
    	
		applyPatch(opty, OptyApiDto.getOptyApiOptyFieldMapping(), req);
        
        resp.stopWatch.markSubElapsedTime();
    }

    public void applyAccountPatch(Account account, RestServiceDto.Request req, RestServiceDto.Response resp) {
    	
		applyPatch(account, OptyApiDto.getOptyApiAccountFieldMapping(), req);
        
        resp.stopWatch.markSubElapsedTime();
    }

    public void applyContactPatch(Opportunity opty, Account account, RestServiceDto.Request req, RestServiceDto.Response resp) {
        //Updating customer details is little tricky as there are multiple of them
        //and we have to deal with primary contact. Here is the logic.
        //
        //1. As part of the main lead api, we will always dealwith primary contact (i.e. with 
        //		opty contact role of IsPrimary=true).
        //2. While returning the response we will always return the primary contact role details.
        //3. While updating we will look for a contact role with matching email. If found, 
        //		update it and also make it as primary. If not found, then create a new contact
        //		and make it as primary.
        String email = req.jsonReader.getString('customerEmail');
        
        info('Customer email that needs to be updated is ' + email);
        
		OpportunityContactRole contactRole;
        
        if (isNotEmpty(email)) {
            contactRole = queryOptyContactRoleByEmail(opty.id, email);
        } else {
            contactRole = queryPrimaryOptyContactRole(opty.id);
        }

        //We need to have an email or contact role based on primary. If none of those two,
        //then we will not update the contact.
        if (isEmpty(email) && contactRole == null) {
            info('Both email is null and there is no primary defined so we will not be able to update contact.');
            return;
        }
        
        Contact contact = contactRole!=null?contactRole.Contact:null;
        if (contact == null) {
            contact = new Contact();
            contact.AccountId = account.id;
            contact.RecordTypeId = getRecordTypeId('Contact', 'Residential');
        }
        
        info('Contact to be updated/inserted ' + contact);
        
        applyPatch(contact, OptyApiDto.getOptyApiContactFieldMapping(), req);
        
        info('After patching ' + contact);
        
        if (contact.id == null) {
            insert contact;
        } else {
            update contact;
        }
        
        if (contactRole == null) {
            contactRole = new OpportunityContactRole(OpportunityId=opty.id, 
                                                     Role=Sf.settingsService.getString('OptyApiOptyContactRole', 'Homeowner'));
        }
        contactRole.ContactId=contact.id;
        contactRole.IsPrimary = true;
        
        info('Contact role to be updated ' + contactRole);
        
        if (contactRole.id == null) {
            insert contactRole;
        } else {
            update contactRole;
        }

        resp.stopWatch.markSubElapsedTime();
    }
}