public class HomeDepotSCELookupDto {
    
    public Map<String, sceDTO> sceDTOMap {get;set;}
    public string code{get;set;}
    public string message{get;set;}
    
    public HomeDepotSCELookupDto(){
        sceDTOMap = new Map<String, sceDTO>();
    }

    public HomeDepotSCELookupDto(JSONReader readerObj){
        initializeResponse(readerObj);
    }
    
    public void initializeResponse(JSONReader readerObj){
        sceDTOMap = new Map<String, sceDTO>();
        
        if(readerObj != null){
            code = readerObj.getString('SFILEADLOOKUPWS_Output.Code');
            message = readerObj.getString('SFILEADLOOKUPWS_Output.Message');
            if(code == '200' && message == 'Success'){
            system.debug('-->Reader Obj'+readerObj.getList('SFILEADLOOKUPWS_Output.ListOfSfileadbows.Sfileadheaderws'));
              if(readerObj.getList('SFILEADLOOKUPWS_Output.ListOfSfileadbows.Sfileadheaderws') != null){
                for (Object obj : readerObj.getList('SFILEADLOOKUPWS_Output.ListOfSfileadbows.Sfileadheaderws')) {
                    JsonReader sceLookup = new JsonReader(obj);
                    System.debug('sceLookup: ' + sceLookup);
                    
                    HomeDepotSCELookupDto.SCEDTO sceDTOObj = new HomeDepotSCELookupDto.SCEDTO();
                    sceDTOObj.sceId = sceLookup.getString('MMSVCSServiceProviderOrderNumber');
                    system.debug('-->SCE Id'+sceDTOObj.sceId);
                    
                    sceDTOObj.externalId = sceLookup.getString('ListOfSfiestimatews.Sfiestimatews[0].Id'); 
                    system.debug('-->Value'+sceDTOObj.externalId);
                    
                    if(!String.isEmpty(sceDTOObj.sceId)){
                        sceDTOMap.put(sceDTOObj.sceId, sceDTOObj);
                    }
                   
                }
              }             
            }
        }       
    }
    
    public class SCEDTO{
        public string externalId {get;set;}
        public string sceId {get;set;} //Salesforce Id
      
    }
}