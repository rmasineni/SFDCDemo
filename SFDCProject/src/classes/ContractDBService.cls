public class ContractDBService {
  
    public static string errorMessage='';
  
    //Send the SOAP request to the Proposal tool, process the SOAP response and update
    @future(callout=true)
    public static void processContractDB(set<String> agreementIds){
        String strAction = 'triggerDataSync';
        String strRequest = '';
        strRequest += '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:prot="http://protocol010000.accountmanagement.sunrungeneration.com" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">';
        strRequest += '<soapenv:Header/>';
        strRequest += '<soapenv:Body>';
        strRequest += '<prot:triggerDataSync soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:con="https://api:8080/accountmanagement/services/AccountManagement010000">';
       
        //Serialize sunrunhome Relationship objects into XMl
        String requestObjectsXML = getSunrunHomeSOAPBody(agreementIds);
        strRequest += ' ' + requestObjectsXML;      
        strRequest += '</prot:triggerDataSync>';
        strRequest += '</soapenv:Body>'; 
        strRequest += '</soapenv:Envelope>';
        ContractDBService ContractService = new ContractDBService();
        Httpresponse response = ContractService.SendSOAPRequest(Label.SunRunHomesEndPoint, strAction, strRequest);
        System.debug('HTTP Response:' + response);
        processHTTPResponse(response);
    }
    
    
    //Serialize the sunrunhome  into XML
    public static  String getSunrunHomeSOAPBody(Set<String> agreementNos){
        String soapBody = '';
        boolean IsrunForTimeSinceLastUpdate= false;
        boolean Isthread= true;
        integer[] homearray = new Integer[]{2010,2015};
            soapBody += '<salesforceSyncTemplate010000>';
        //soapBody += ' <modifiedEnd xsi:type="xsd:dateTime">'+  datetime.now() +'</modifiedEnd>';
        //soapBody += ' <modifiedStart xsi:type="xsd:dateTime">'+ datetime.now()  +'</modifiedStart>';
        soapBody += ' <runForTimeSinceLastUpdate xsi:type="xsd:boolean">'+IsrunForTimeSinceLastUpdate +'</runForTimeSinceLastUpdate>';
        soapBody += '<sunRunHomes xsi:type="impl:ArrayOf_xsd_int" soapenc:arrayType="xsd:int[]">';
        for(string agreementNo : agreementNos ){
        if(agreementNo.isNumeric()){
             soapBody +='<data>' + long.valueOf(agreementNo) + '</data>';
         }
          // soapBody +='<data>' + agreementNo + '</data>';
            system.debug('agreementNo>>>' + agreementNo);
        }
        
        soapBody +=  '</sunRunHomes>';
        soapBody += ' <thread xsi:type="xsd:boolean">'+Isthread +'</thread>';
        soapBody += ' </salesforceSyncTemplate010000> ';
        System.debug('soapBody: ' + soapBody);
        return soapBody; 
    }
    
    //Send the SOAP request to  contractDB
    public  Httpresponse SendSOAPRequest(string strEndPoint, string strAction, string strXML){
        http soap = new http();
        Httprequest soap_request = new Httprequest();
        Httpresponse soap_response = new Httpresponse();
        Integer iTimeout = 0;
        if(Label.HTTP_Timeout != null &&  Label.HTTP_Timeout != ''){
            iTimeout = Integer.valueOf(Label.HTTP_Timeout);
        }else{
            iTimeout = 60000;  
        }
        system.debug('strEndPoint>>>' +  strEndPoint);
        system.debug('strXML>>>>'  + strXML);
        soap_request.setEndpoint(strEndPoint);
        soap_request.setMethod('POST');
        soap_request.setHeader('Content-type', 'text/xml;charset=utf-8');
        soap_request.setHeader('SOAPAction', strAction);
        
        String userName = Label.SunrunHomesUser;
        String password = Label.SunrunHomesPassword;
        
        Blob headerValue = Blob.valueOf(userName + ':' + password);
        String authorizationHeader = 'BASIC ' +
            EncodingUtil.base64Encode(headerValue);
        
        soap_request.setHeader('Authorization', authorizationHeader);
        soap_request.setTimeout(iTimeout);
        soap_request.setBody(strXML);
        
        try
        {
            //Invoke the SOAP call
            system.debug('soap_request>>>'  + soap_request);
            If(!Test.isRunningTest()){
            soap_response = soap.send(soap_request);
            system.debug('soap_response>>>'  + soap_response);
            System.debug('getBody: ' + soap_response.getBody());
            System.debug('getStatusCode: ' + soap_response.getStatusCode());
            System.debug('getStatus: ' + soap_response.getStatus());
            return soap_response;
            }
        }
        catch (Exception e)
        {
            System.Debug('Unable to send the agreementno. information from SFDC ' + e.getMessage());
            errorMessage = e.getMessage();
        }
        return null;
    }
    
    public static void processHTTPResponse(Httpresponse response){
        
        if(response != null){
            System.debug('response.getStatus():' + response.getStatus());
            System.debug('response.getBody():' + response.getBody());
        }else{
            System.debug('Null Response');
        }
        if(response != null && response.getStatus() != 'OK'){
            errorMessage = response.getStatus() + ' ' + response.getStatusCode(); 
            System.debug('errorMessage' + errorMessage);
        }   
    }

}