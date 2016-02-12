public class CreditCheckApiHandler extends ProposalBaseHandler {

    override public String getApiName() {
        return 'creditCheck';
    }
    
    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
      /*  String testMode = req.getStringParam('testMode');
        if(!String.isEmpty(testMode) && testMode == '1'){       
            // resp.jsonWriter = new JsonWriterRestService(true);
            resp.jsonWriter.write('url', 'http://www.leasedimensions.com/');
        }
        else{*/
            
           // String prospectId = req.getStringParam('prospectId');
            String contactId = req.getStringParam('contactId');
            
             String prospectId = req.getRequiredStringParam('prospectId');
             //String contactId = req.getRequiredStringParam('contactId');
          /*  if(String.isEmpty(prospectId)){
                throw createBusinessException(RestServiceDto.Error_RequiredParametersMissing, 'Prospect Id is not found');
            }
            if(String.isEmpty(contactId)){
                throw createBusinessException(RestServiceDto.Error_RequiredParametersMissing, 'Contact Id is not found');
            }*/
            // String prospectId =  getRecordIdFromPath('prospectId', req);
            //String contactId =  getRecordIdFromPath('contactId', req);
           // String opptySoql = createSoqlWithAuditFields(getOptyFieldMapping().values(), 'Opportunity', 'Prospect_Id__c  = :prospectId');
           // 
           // 
                       
            String opptySoql='Select Id,Install_Branch__c,Deal_Id__c from Opportunity where Prospect_Id__c=:prospectId';
            List<SObject> ooptySobj = Database.query(opptySoql);
            
            if (ooptySobj.isEmpty()) {
                throw createBusinessException(RestServiceDto.Error_NotFound, 'Opportunity with specified Prospect Id [' + prospectId + '] is not found');
            }
            Opportunity opptyObj= (Opportunity) ooptySobj.get(0);
            
            if(String.isEmpty(contactId)){
                Map<String, Contact> contactMap = getOptyContacts(opptyObj.Id);
                Contact primaryContact;
                if(contactMap.containsKey(HOMEOWNER_PRIMARY)){
                    primaryContact = contactMap.get(HOMEOWNER_PRIMARY);
                    contactId = primaryContact.Id;
                }else{
                    List<Contact> contacts = contactMap.values();
                    if(contacts != null && !contacts.isEmpty()){
                        primaryContact = contacts[0];
                        contactId = primaryContact.Id;
                    }
                }                
            }
            
            String contactSoql = createSoqlWithAuditFields(getContactFieldMapping().values(), 'Contact', 'Id  = :contactId');
            List<SObject> contactSobj = Database.query(contactSoql);
            
            if (contactSobj.isEmpty()) {
                throw createBusinessException(RestServiceDto.Error_NotFound, 'Contact with specified contact Id [' + contactId + '] is not found');
            }
            
            resp.stopWatch.markSubElapsedTime();
            
            system.debug('opptyObjopptyObj>' +  opptyObj);
            Contact contactObj= (Contact) contactSobj.get(0); 
            system.debug('contactObj>' +  contactObj);
            string inPersonCreditURL=createInpersonCreditURL (opptyObj,contactObj);
            resp.jsonWriter.write('url', inPersonCreditURL);
        //}
    }
    
  /*  public Map<String, String> getOptyFieldMapping() {
        return RestServiceDto.getFieldMapping('Opportunity Api', 'Opportunity');        
    }*/
    
    public Map<String, String> getContactFieldMapping() {
        return RestServiceDto.getFieldMapping('Contact Api', 'Contact');        
    }
    
    public String createInpersonCreditURL(Opportunity opptyObj, Contact contactObj) {
        
        
        String hFName = contactObj.FirstName;
        String hLName = contactObj.LastName;
        String hEmail = contactobj.Email;
        String hdealId = (opptyObj.Deal_Id__c == null) ? '' : opptyObj.Deal_Id__c;
        String hCustomerNumber = contactObj.Id;
        String hInstallBr =(opptyObj.Install_Branch__c== null) ? '' : opptyObj.Install_Branch__c;
        String hhomePhone = '';
        String homePhone=contactObj.Phone;
        System.debug('homePhone: ' + homePhone);
        if(homePhone!= null){
          homePhone=  homePhone.replaceAll('\\W', '');
           // homePhone = homePhone.remove('(').remove(')').remove('-').remove(' ');
            if(homePhone.length() == 10){
                hhomePhone = homePhone.substring(0,3) + '-' + homePhone.substring(3,6) + '-' + homePhone.substring(6); 
            }
        }
        
        String hstreet = (contactObj.MailingStreet == null) ? '' : contactObj.MailingStreet;
        String hcity = (contactObj.MailingCity == null) ? '' : contactObj.MailingCity;
        String hstate = (contactObj.MailingState == null) ? '' : contactObj.MailingState;
        String hzip = (contactObj.MailingPostalCode == null) ? '' : contactObj.MailingPostalCode.split('-')[0];
        
        String sFName = UserInfo.getFirstName();
        String sLName = UserInfo.getLastName();       
        String sEmail = 'bogus@bogus.com'; //s_email;
        String sGroupID = Label.LeaseDimensions_DefaultInstaller;  //'0123456789QyY2'; //valid sunrunuat.leasedimensions.com/apirest value
        ///String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm();
        String fullFileURL =  EDPUtil.getBaseURL();
        
        String inpersonURL = Label.LeaseDimensions_Inperson + '?apikey=' + Label.LeaseDimension_InpersonAPIKey;
        inpersonURL += '&FirstName=' +  EncodingUtil.urlEncode(hFName, 'UTF-8');
        inpersonURL += '&LastName=' +  EncodingUtil.urlEncode(hLName, 'UTF-8');
        inpersonURL += '&CustomerEmail=' +  EncodingUtil.urlEncode(hEmail, 'UTF-8');
        
        inpersonURL += '&HomePhone=' +  EncodingUtil.urlEncode(hhomePhone, 'UTF-8');
        inpersonURL += '&Street=' +  EncodingUtil.urlEncode(hstreet, 'UTF-8');
        inpersonURL += '&City=' +  EncodingUtil.urlEncode(hcity, 'UTF-8');
        inpersonURL += '&State=' +  EncodingUtil.urlEncode(hstate, 'UTF-8');
        inpersonURL += '&Zip=' +  EncodingUtil.urlEncode(hzip, 'UTF-8');
        
        inpersonURL += '&years_at_address=';
        inpersonURL += '&borrower_income=';
        inpersonURL += '&employment_status=';
        inpersonURL += '&size_of_household=';
        
        inpersonURL += '&ContactNumber=' +  EncodingUtil.urlEncode(hCustomerNumber, 'UTF-8');
        inpersonURL += '&deal_id=' + EncodingUtil.urlEncode(hdealId,'UTF-8');
        inpersonURL += '&Installer=' + EncodingUtil.urlEncode(hInstallBr,'UTF-8');
        //inpersonURL += '&langCode=' + langCode;
        //inpersonURL += '&Installer_id=' + ( (Installer == 'Sungevity') ? 'NA7' : '');
        inpersonURL += '&proposal_id=' ;
        inpersonURL += '&SalesRepEmail=' +  EncodingUtil.urlEncode(sEmail, 'UTF-8');
        inpersonURL += '&SalesRepFirstName=' +  EncodingUtil.urlEncode(sFName, 'UTF-8');
        inpersonURL += '&SalesRepLastName=' +  EncodingUtil.urlEncode(sLName, 'UTF-8');
        //inpersonURL += '&returnurl=';
        inpersonURL += '&returnurl=' +  fullFileURL + '/apex/InPersonCreditResponse';
        return inpersonURL;   
    } 
    
    

}