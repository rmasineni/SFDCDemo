/*
  Test Methods for Hamm: EDP, ChannelMgmt.
  Coded by: Peter Alexander Mandy
  Date: 10022012:15:33:22.22
 */
@isTest
private class testObservingContacts {

    static testMethod void myUnitTest() {
    //
    Account a = new Account();
    a.Name = 'Observing Account';
    a.BillingStreet = '1290 Happy Path';
    a.BillingCity = 'San Francisco';
    a.BillingState = 'CA';
    a.BillingCountry = 'USA';
    insert a;
    //
    List<Contact> listCon = new List<Contact>();
    Contact c = new Contact();
    c.AccountId = a.Id;
    c.LastName = 'Observer';
    c.FirstName = 'Johnny Q.';
    c.Email = 'JQ@sunrunobserver.com';
    c.Phone = '2022022029'; 
    c.MailingStreet = '45 Fremont St';
    c.MailingState = 'CA';
    c.MailingCountry = 'USA';
    c.MailingCity = 'San Francisco';
    c.MailingPostalCode = '99999';       
    c.Accreditation_period_start_date__c = Date.Today().addDays(-180);
    c.Accreditation_period_end_date__c = Date.Today().addDays(180);
    c.Job_Function__c = 'Executive';
    c.Role__c = 'Executive';
    c.Proposal_Tool_Access__c = 'Granted';
    listCon.add(c);
    Contact c2 = new Contact();
    c2.AccountId = a.Id;
    c2.LastName = 'Observer2';
    c2.FirstName = 'Johnny Q.';
    c2.Email = 'JQ2@sunrunobserver.com';
    c2.Phone = '2022022029'; 
    c2.MailingStreet = '45 Fremont St';
    c2.MailingState = 'CA';
    c2.MailingCountry = 'USA';
    c2.MailingCity = 'San Francisco';
    c2.MailingPostalCode = '99999';       
    c2.Accreditation_period_start_date__c = Date.Today().addDays(-180);
    c2.Accreditation_period_end_date__c = Date.Today().addDays(180);
    c2.Job_Function__c = 'Executive';
    c2.Role__c = 'Executive';
    c2.Proposal_Tool_Access__c = 'Granted';
    listCon.add(c2);
    //    
    insert listCon;
    ApexPages.StandardController sc = new ApexPages.StandardController(c);
    ContactObservingExtension COE = new ContactObservingExtension(sc);
    COE.init();
    //Executive
    COE.conObj.Job_Function__c = 'Executive';
    COE.conObj.Role__c = 'Executive';
    //
    COE.listAdditionalPartnerCons = new List<ContactObservingExtension.ObservingContact>();
    COE.listPartnerCons = new List<ContactObservingExtension.ObservingContact>();    
    //
    try{
      PageReference pr1 = COE.AddAll();
    }
    catch(Exception e)
    {
    	System.Debug('Testing Error: ' + e.getMessage());
    }
    //
    try{
    	COE.conObj.ObservingContact__c = c2.Id;
        PageReference pr2 = COE.addOne();
    }
    catch(Exception e)
    {
    	System.Debug('Testing Error: ' + e.getMessage());
    }    
    //
    try{
    	COE.listAdditionalPartnerCons.add(new ContactObservingExtension.ObservingContact(c, true));
        PageReference pr3 = COE.AddToList();
    }
    catch(Exception e)
    {
    	System.Debug('Testing Error: ' + e.getMessage());
    }     
    //
    try{
      PageReference pr4 = COE.Cancel();
    }
    catch(Exception e)
    {
    	System.Debug('Testing Error: ' + e.getMessage());
    }     
    //
    try{
      PageReference pr5 = COE.RemoveContacts(); 
    }
    catch(Exception e)
    {
    	System.Debug('Testing Error: ' + e.getMessage());
    }     
    //
    try{
    	//
        ContactObservingExtension.ObservingContact crdtInfo = new ContactObservingExtension.ObservingContact(c, true);
     	COE.listPartnerCons.add(new ContactObservingExtension.ObservingContact(c, true));
     	for(ContactObservingExtension.ObservingContact oc:COE.listPartnerCons)
    	{
    	   oc.selected = true;
    	}    	
        PageReference pr7 = COE.UpdateProposalTool();
    }
    catch(Exception e)
    {
    	System.Debug('Testing Error: ' + e.getMessage());
    }       
    try{    	
    	//String responseXml = '<?xml version="1.0" encoding="utf-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><ns1:updateObservationRelationshipsResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="http://protocol010000.contract.sunrungeneration.com"><updateObservationRelationshipsReturn xsi:type="ns2:observerObservedUpdateResponse010000" xmlns:ns2="srg"><errorDescription xsi:type="soapenc:string" xsi:nil="true" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"/><observedResponses soapenc:arrayType="ns2:observedUpdateResponse010000[1]" xsi:type="soapenc:Array" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"><observedResponses xsi:type="ns2:observedUpdateResponse010000"><errorDescription xsi:type="soapenc:string" xsi:nil="true"/><salesforceContactIdObserved xsi:type="soapenc:string">3204883552</salesforceContactIdObserved><statusCode xsi:type="soapenc:string">SUCCESS</statusCode></observedResponses></observedResponses><statusCode xsi:type="soapenc:string" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">SUCCESS</statusCode></updateObservationRelationshipsReturn></ns1:updateObservationRelationshipsResponse></soapenv:Body></soapenv:Envelope>';
    	String responseXml = '<?xml version="1.0" encoding="utf-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><ns1:updateObservationRelationshipsResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="http://protocol010000.contract.sunrungeneration.com"><updateObservationRelationshipsReturn xsi:type="ns2:observerObservedUpdateResponse010000" xmlns:ns2="srg"><errorDescription xsi:type="soapenc:string" xsi:nil="true" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"/><observedResponses soapenc:arrayType="ns2:observedUpdateResponse010000[10]" xsi:type="soapenc:Array" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"><observedResponses xsi:type="ns2:observedUpdateResponse010000"><errorDescription xsi:type="soapenc:string" xsi:nil="true"/><salesforceContactIdObserved xsi:type="soapenc:string">1583546911</salesforceContactIdObserved><statusCode xsi:type="soapenc:string">SUCCESS</statusCode></observedResponses><observedResponses xsi:type="ns2:observedUpdateResponse010000"><errorDescription xsi:type="soapenc:string" xsi:nil="true"/><salesforceContactIdObserved xsi:type="soapenc:string">1913016747</salesforceContactIdObserved><statusCode xsi:type="soapenc:string">SUCCESS</statusCode></observedResponses><observedResponses xsi:type="ns2:observedUpdateResponse010000"><errorDescription xsi:type="soapenc:string" xsi:nil="true"/><salesforceContactIdObserved xsi:type="soapenc:string">1186825961</salesforceContactIdObserved><statusCode xsi:type="soapenc:string">SUCCESS</statusCode></observedResponses><observedResponses xsi:type="ns2:observedUpdateResponse010000"><errorDescription xsi:type="soapenc:string" xsi:nil="true"/><salesforceContactIdObserved xsi:type="soapenc:string">3204883552</salesforceContactIdObserved><statusCode xsi:type="soapenc:string">SUCCESS</statusCode></observedResponses><observedResponses xsi:type="ns2:observedUpdateResponse010000"><errorDescription xsi:type="soapenc:string" xsi:nil="true"/><salesforceContactIdObserved xsi:type="soapenc:string">4064584412</salesforceContactIdObserved><statusCode xsi:type="soapenc:string">SUCCESS</statusCode></observedResponses><observedResponses xsi:type="ns2:observedUpdateResponse010000"><errorDescription xsi:type="soapenc:string" xsi:nil="true"/><salesforceContactIdObserved xsi:type="soapenc:string">2135051845</salesforceContactIdObserved><statusCode xsi:type="soapenc:string">SUCCESS</statusCode></observedResponses><observedResponses xsi:type="ns2:observedUpdateResponse010000"><errorDescription xsi:type="soapenc:string" xsi:nil="true"/><salesforceContactIdObserved xsi:type="soapenc:string">2033966804</salesforceContactIdObserved><statusCode xsi:type="soapenc:string">SUCCESS</statusCode></observedResponses><observedResponses xsi:type="ns2:observedUpdateResponse010000"><errorDescription xsi:type="soapenc:string" xsi:nil="true"/><salesforceContactIdObserved xsi:type="soapenc:string">1190703668</salesforceContactIdObserved><statusCode xsi:type="soapenc:string">SUCCESS</statusCode></observedResponses><observedResponses xsi:type="ns2:observedUpdateResponse010000"><errorDescription xsi:type="soapenc:string" xsi:nil="true"/><salesforceContactIdObserved xsi:type="soapenc:string">1875370055</salesforceContactIdObserved><statusCode xsi:type="soapenc:string">SUCCESS</statusCode></observedResponses><observedResponses xsi:type="ns2:observedUpdateResponse010000"><errorDescription xsi:type="soapenc:string">No contact exists for the SalesForce external id 3363784612</errorDescription><salesforceContactIdObserved xsi:type="soapenc:string">3363784612</salesforceContactIdObserved><statusCode xsi:type="soapenc:string">PROCESS_ERROR</statusCode></observedResponses></observedResponses><statusCode xsi:type="soapenc:string" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">SUCCESS</statusCode></updateObservationRelationshipsReturn></ns1:updateObservationRelationshipsResponse></soapenv:Body></soapenv:Envelope>';    	
    	Boolean bResult = COE.getInvalidObservedIdsFromSOAPResponse(responseXml);
    }
    catch(Exception e)
    {
    	System.Debug('Testing Error: ' + e.getMessage());
    } 
    try{
    	Set<String> setIds = ContactObservingExtension.getObservedIdsFromSOAPResponse('<?xml version="1.0" encoding="utf-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><ns1:getObservedSalesForceContactIdsResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="http://protocol010000.contract.sunrungeneration.com"><getObservedSalesForceContactIdsReturn soapenc:arrayType="soapenc:string[34]" xsi:type="soapenc:Array" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">1913016747</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">1583546911</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">4132689331</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">1251290968</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">4472280761</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">1343592044</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">1034210356</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">5955418208</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string" xsi:nil="true"/><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">2001682072</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">7153496468</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">2499256251</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">6323912082</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">3830625151</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">7463226551</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string" xsi:nil="true"/><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">2091246362</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">2135051845</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string" xsi:nil="true"/><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">1810829924</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">3204883552</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">1875370055</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">1013156750</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">1190703668</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">1877722930</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">2128531081</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">4021687161</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">1717819004</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">1246443643</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">8595270792</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">9588199210</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">2747567824</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">1662907706</getObservedSalesForceContactIdsReturn><getObservedSalesForceContactIdsReturn xsi:type="soapenc:string">1773305613</getObservedSalesForceContactIdsReturn></getObservedSalesForceContactIdsReturn></ns1:getObservedSalesForceContactIdsResponse></soapenv:Body></soapenv:Envelope>'); 
    }
    catch(Exception e)
    {
    	System.Debug('Testing Error: ' + e.getMessage());
    } 
    //  
    }
}