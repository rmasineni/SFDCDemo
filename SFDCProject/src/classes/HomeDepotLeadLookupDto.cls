public class HomeDepotLeadLookupDto {
    
    public Map<String, LeadDTO> leadDTOMap {get;set;}
    public List<LeadDTO> leadDTOsWithNoSFDCId {get;set;}
    public string code{get;set;}
    public string message{get;set;}
    
    public HomeDepotLeadLookupDto(){
        leadDTOMap = new Map<String, LeadDTO>();
    }

    public HomeDepotLeadLookupDto(JSONReader readerObj){
        initializeResponse(readerObj);
    }
    
    public void initializeResponse(JSONReader readerObj){
        leadDTOMap = new Map<String, LeadDTO>();
        leadDTOsWithNoSFDCId = new List<LeadDTO>();
        if(readerObj != null){
            code = readerObj.getString('SFILEADLOOKUPWS_Output.Code');
            message = readerObj.getString('SFILEADLOOKUPWS_Output.Message');
            if(code == '200' && message == 'Success'){
                for (Object obj : readerObj.getList('SFILEADLOOKUPWS_Output.ListOfSfileadbows.Sfileadheaderws')) {
                    JsonReader leadLookup = new JsonReader(obj);
                    System.debug('leadLookup: ' + leadLookup);
                    
                    HomeDepotLeadLookupDto.LeadDTO leadDTOObj = new HomeDepotLeadLookupDto.LeadDTO();
                    leadDTOObj.externalRowId = leadLookup.getString('Id'); 
                    leadDTOObj.externalId = leadLookup.getString('OrderNumber'); 
                    leadDTOObj.leadId = leadLookup.getString('MMSVCSServiceProviderOrderNumber');   
                    System.debug('leadDTOObj.externalId  : ' + leadDTOObj.externalId  + ' &&&&&&&&&&&&&&&&& leadDTOObj.leadId ' + leadDTOObj.leadId );
                    
                    leadDTOObj.firstname = leadLookup.getString('ContactFirstName');    
                    leadDTOObj.lastname = leadLookup.getString('ContactLastName');  
                    leadDTOObj.email = leadLookup.getString('MainEmailAddress');    
                    //leadDTOObj.batchIdOutbound = leadLookup.getString('MMSVCSLeadBatchNumber');
                    leadDTOObj.createdDate = leadLookup.getString('Created');   
                    if(!String.isEmpty(leadDTOObj.leadId)){
                        leadDTOMap.put(leadDTOObj.leadId, leadDTOObj);
                    }else{
                        leadDTOsWithNoSFDCId.add(leadDTOObj);
                    }
                }           
            }
        }       
    }
    
    public class LeadDTO{
        public string externalId {get;set;}
        public string externalRowId {get;set;}
        public string leadId {get;set;} //Salesforce Id
        public string firstname {get;set;}
        public string lastName {get;set;}
        public string email {get;set;}
        //public string batchIdOutbound {get;set;}
        public string integrationStatus {get;set;}
        public string integrationDescription {get;set;}
        public string backOfficeOrderNumber {get;set;}
        public string createdDate {get;set;}
    }
}