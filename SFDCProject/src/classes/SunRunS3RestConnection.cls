/****************************************************************************
Author  : ZCloudInc.net
Date    : March 2013
Description: This class contains all the methods to perform CRUD
            operations on Amazon S3 using SunRun S3 proxy.
*****************************************************************************/

public class SunRunS3RestConnection {

    public static String PROPOSAL_DOCS_SETTINGS_NAME = 'ProposalDoc';
    public static String UPLOADED_DOCS_SETTINGS_NAME = 'UploadedDoc';
    public static String UPLOADED_PHOTOS_SETTINGS_NAME = 'FinalMilestoneDoc';
    public static String INCOMPLETE_DOCS_SETTINGS_NAME = 'IncompleteSignedDoc';
    public static String COMPLETED_SIGNED_DOCS_SETTINGS_NAME = 'CompleteSignedDoc';
    public static String SERVICE_CONTRACT_DOCS_SETTINGS_NAME = 'ServiceContract';
    public static String OPPORTUNITY_DOCS_SETTINGS_NAME = 'Opportunity';
    public static String QUALIFICATION_DOC = 'qualificationDoc';
    
    public static String proxyEndpoint = Label.SunRun_S3_Proxy;
    public static string sunrunS3BucketName = Label.SunRun_S3_Bucket;
    public static Map<String, SunRunS3Proxy_Settings__c> sunrunS3ProxySettings = SunRunS3Proxy_Settings__c.getall();
    
    Integer debug = 10; 
    public SunRunS3Proxy_Settings__c sunrunS3ProxySetting {get;set;}
    public string s3ProxySettingName {get;set;}

    public string getSecretKey(){ return sunrunS3ProxySetting.Secret_Key__c; }
    public string getAccessKey(){ return sunrunS3ProxySetting.Access_Key__c; }
    public string getSunrunS3FolderName(){ return sunrunS3ProxySetting.Folder_Name__c; }

    public string proposalName {get;set;}
    public string fileName {get;set;}
    
    private String dateString;  
    public void setDateString(Integer sec) { this.dateString = this.formatDateString(System.now().addSeconds(-5)); }
    public string getDateString(){return dateString;}
    
    private HttpResponse res = null;
    public HTTPResponse getResponse() { return res; }
    private Map<String,String> headers = new Map<String, String>{};
    public void setHeaders(Map<String, String> h) {headers = h.clone();}
    public blob documentBlob{get;set;}
    public String errorMessage {get;set;}
	public static string proxySetting{get;set;}
    public SunRunS3RestConnection(){

    }

    public SunRunS3RestConnection(String proxySettingsNameStr){
        if(proxySettingsNameStr != null && proxySettingsNameStr != ''){
            initializeProxySettings(proxySettingsNameStr);
        }
    }

    public string formatDateString(DateTime d) {
        //d.addSeconds(-5);
        String timeFormat = d.formatGmt('EEE, dd MMM yyyy HH:mm:ss') + ' GMT';
        if(debug>3) system.debug(timeFormat);
        return timeFormat; 
    }
    
    public string getAuthorizationPath(){
        String authorizationPath = '';
        authorizationPath += (sunrunS3BucketName != null) ? sunrunS3BucketName  : ''; 
        authorizationPath += (getSunrunS3FolderName() != null) ? ('/' + getSunrunS3FolderName()) : ''; 
        
        String tempFilePath = '';
        tempFilePath += (proposalName != null) ? ('/' + proposalName) : ''; 
        tempFilePath += '/' ; 
        authorizationPath += EncodingUtil.urlEncode(tempFilePath, 'UTF-8');
        //authorizationPath += fileName.replaceAll(' ', '%20');
        authorizationPath += encodeFileName(fileName);
        
        
        return authorizationPath;
    }

    public string getEndPoint(){
        System.debug('this.proposalname2' + this.proposalname);
        String endPoint = '';
        endPoint += (proxyEndpoint != null) ? proxyEndpoint + '/' : ''; 
        endPoint += (getSunrunS3FolderName() != null) ? getSunrunS3FolderName() + '/' : ''; 
        endPoint += (proposalName != null) ? proposalName + '/' : ''; 
        //endPoint += (fileName != null) ? fileName.replaceAll(' ', '%20') : '';
        endPoint += (fileName != null) ? encodeFileName(fileName) : '';
        return endPoint;
    }

    public void initializeProxySettings(String proxySettingsNameStr){
        System.debug('sunrunS3ProxySettings: ' + sunrunS3ProxySettings);
        sunrunS3ProxySetting = sunrunS3ProxySettings.get(proxySettingsNameStr);
    }

    private void setAuthHeader(HTTPRequest req) {   
        string buf = make_canonicalBuffer(req.getMethod(),getDateString(),new string[]{});
        if(debug>2) system.debug ('>'+buf +'<');
        string signature  = make_sig(buf);      
        
        req.setHeader('authorization','AWS '+getAccessKey()+':'+signature);
    }

    private string make_sig(string canonicalBuffer) {
        system.debug(canonicalBuffer);
        String macUrl ;
        System.debug('canonicalBuffer2: ' + canonicalBuffer);
        
        System.debug('getAccessKey(): ' + getAccessKey());
        System.debug('getSecretKey(): ' + getSecretKey());
        System.debug('getSunrunS3FolderName(): ' + getSunrunS3FolderName());
        
        Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(canonicalBuffer),blob.valueof(getSecretKey()));  
        macUrl = EncodingUtil.base64Encode(mac);        
        if (debug > 1) system.debug(macUrl);
        return macUrl;
    }   

    private String make_canonicalBuffer(string method, string datestr, string[] aws_headers) {
        String canonicalBuffer = method + '\n';
        canonicalBuffer += '\n';
        if ( method == 'PUT' ) { 
            canonicalBuffer += headers.get('content-type') + '\n';
            headers.remove('content-type');
        } else {
            canonicalBuffer += '\n';
        }
        canonicalBuffer += datestr + '\n';
        if (!headers.isEmpty() ) { 
            for(string k:headers.keySet() ) {
                canonicalBuffer += k + ':' + headers.get(k) + '\n';
            }
        }
        canonicalBuffer += '/' + getAuthorizationPath() ;
        System.debug('canonicalBuffer: ' + canonicalBuffer);
        return  canonicalBuffer;
    }

    public void makeRequest(String method, String proposalName, String fileName, Blob blobValue, Map<String, String> headers) {
        this.proposalName = proposalName; 
        System.debug('proposalName1:' + proposalName);  
        this.fileName = fileName;
        if (blobValue != null){ 
            documentBlob = blobValue ;
        }
        if (headers != null ) setHeaders(headers);  
        makeRequest( method);       
    }

    public void makeRequest(string method, String proposalName, String fileName) {
        this.proposalName = proposalName;   
        this.fileName = fileName;
        makeRequest( method);       
    }
    
    public void makeRequest(string method) {
        System.debug('this.proposalname1' + this.proposalname);
        HttpRequest req = new HttpRequest(); 
        req.setMethod(method);
        if(method == 'PUT') { 
            if (!headers.containsKey('content-type') ) { 
                system.debug('ERROR: missing content-type in PUT request'); return; 
            } 
            system.debug('content-type is >' +headers.get('content-type'));
            req.setHeader('content-type', headers.get('content-type') );
            if ( documentBlob == null ) { 
                system.debug( 'body must not be null in PUT'); return; 
            }
            req.setBodyAsBlob(documentBlob); 
            //req.setCompressed(true); // otherwise we hit a limit of 32000
        }
        req.setEndpoint(getEndPoint());
        
        if(method == 'PUT'){
            setDateString(0);
        }else{
            setDateString(0);   
        }

        req.setHeader('Date',getDateString()); 
        setAuthHeader(req);     
        if (!headers.isEmpty() ) { 
            for(string k:headers.keySet() ) { 
                system.debug('setheader ' + k + ' => ' +headers.get(k) ); 
                req.setHeader(k, headers.get(k) ); 
            }
        }
        
        Http http = new Http();
        try {

            If(!Test.isRunningTest()){
                system.debug(req);
                res = http.send(req);   
                if (debug > 1) {
                    //system.debug(res.toString());
                    //System.debug('BODY: '+res.getBody());
                }
                if(method == 'GET') { 
                    documentBlob = res.getBodyAsBlob();
                }
            }else{
                res = new HttpResponse();
                String myString = 'StringToBlob';
                documentBlob = Blob.valueof(myString);
                res.setBodyAsBlob(documentBlob);            
                res.setStatusCode(200);
            }
        } catch(System.CalloutException e) {
            if (res != null && res.getStatus()=='OK') { 
                system.debug(res.toString()); // for some reason HEAD ends up here
            } else { 
                errorMessage = e.getMessage();
                System.debug('ERROR: '+ e);
                //system.debug(res.toString());
            }
        }
        headers.clear(); 
    }

    public static SunRunProxyRequestInfo getPhotoURL(String method, String proxySettingName, String GenAssetName, String fileName, String fileType){
        DateTime d = System.now();
        String timeFormat = d.formatGmt('EEE, dd MMM yyyy HH:mm:ss') + ' GMT';
        SunRunS3Proxy_Settings__c sunrunS3ProxySetting = sunrunS3ProxySettings.get(proxySettingName);
//fileType = 'text/html';
        String serviceEndPoint = getServiceEndPoint(sunrunS3ProxySetting.Folder_Name__c, GenAssetName, fileName);
        String encodedPath = getEncodedPathForSignature(sunrunS3ProxySetting.Folder_Name__c, GenAssetName, fileName);
        //String stringtosign = method + '\n\n' + fileType + '\n\n' + 'x-amz-date:' + timeFormat + '\n' + '/' + encodedPath; 
        String stringtosign = method + '\n\n' + fileType + '\n\n' + 'x-amz-date:' + timeFormat + '\n' + '/' + encodedPath;
        
        System.debug('method: ' + method);
        System.debug('file type: ' + fileType);
        System.debug('timeFormat: ' + timeFormat);
        System.debug('encodedPath: ' + encodedPath);
        
        System.debug('buf1 : ' + stringtosign);

        string signature  = make_sunrunProxysig(stringtosign, sunrunS3ProxySetting.Secret_Key__c);      

        SunRunProxyRequestInfo requestInfo = new SunRunProxyRequestInfo();
        requestInfo.requestEndpoint = serviceEndPoint;
        requestInfo.signature = signature;
        requestInfo.timestamp = timeFormat;
        requestInfo.accessKey = sunrunS3ProxySetting.Access_Key__c;
        System.debug('requestInfo: ' + requestInfo);
        return requestInfo;
    }
    
    public static String getPhotoURL(String method, String proxySettingName, String genAssetName, String fileName){
        Long Lexpires = getExpirationTime();
        SunRunS3Proxy_Settings__c sunrunS3ProxySetting = sunrunS3ProxySettings.get(proxySettingName);

        String serviceEndPoint = getServiceEndPoint(sunrunS3ProxySetting.Folder_Name__c, genAssetName, fileName);
        String encodedPath = getEncodedPathForSignature(sunrunS3ProxySetting.Folder_Name__c, genAssetName, fileName);
        
        System.Debug('S3 Folder: ' + sunrunS3ProxySetting.Folder_Name__c);
        System.Debug('Gen Asset: ' + genAssetName);
        System.Debug('File Name: ' + fileName);
        
        String stringtosign = method +  '\n\n\n'+ Lexpires +'\n/'+ encodedPath;         
        
        /*
        DateTime d = System.now();
        String timeFormat = d.formatGmt('EEE, dd MMM yyyy HH:mm:ss') + ' GMT';
        String stringtosign = method +  '\n\n' + 'jpg' + '\n\n' + timeFormat +'\n/'+ encodedPath;
        String fileType = 'image/jpeg';
        String stringtosign = method + '\n\n' + fileType + '\n\n' + 'x-amz-date:' + timeFormat + '\n' + '/' + encodedPath;
        */

        System.debug('sunrunS3ProxySetting.Access_Key__c: ' + sunrunS3ProxySetting.Access_Key__c);
        
        String signed = make_sunrunProxysig(stringtosign, sunrunS3ProxySetting.Secret_Key__c);
        String codedsigned = EncodingUtil.urlEncode(signed,'UTF-8');
        System.debug('signed: ' + signed);

        String url = serviceEndPoint + '?AWSAccessKeyId=' + sunrunS3ProxySetting.Access_Key__c + '&Expires=' + Lexpires+'&Signature='+signed;
        System.debug('Signed URL-2: ' + url);
        
        String url2 = serviceEndPoint + '?AWSAccessKeyId=' + sunrunS3ProxySetting.Access_Key__c + '&Expires=' + Lexpires+'&Signature='+codedsigned;
        System.debug('Signed URL-2: ' + url2);
        url = url2;
        return url;
    }
    
    public static String getSignedURL(String method, String proxySettingName, String proposalName, String fileName){
        Long Lexpires = getExpirationTime();
        SunRunS3Proxy_Settings__c sunrunS3ProxySetting = sunrunS3ProxySettings.get(proxySettingName);
        if(sunrunS3ProxySetting == null){
        	sunrunS3ProxySetting = sunrunS3ProxySettings.get(UPLOADED_DOCS_SETTINGS_NAME);
        }
        
        String serviceEndPoint = getServiceEndPoint(sunrunS3ProxySetting.Folder_Name__c, proposalName, fileName);
        String encodedPath = getEncodedPathForSignature(sunrunS3ProxySetting.Folder_Name__c, proposalName, fileName);
        
        String stringtosign = method +  '\n\n\n'+ Lexpires +'\n/'+ encodedPath;
        
        String signed = make_sunrunProxysig(stringtosign, sunrunS3ProxySetting.Secret_Key__c);
        String codedsigned = EncodingUtil.urlEncode(signed,'UTF-8');
        System.debug('signed: ' + signed);

        String url = serviceEndPoint + '?AWSAccessKeyId=' + sunrunS3ProxySetting.Access_Key__c + '&Expires=' + Lexpires+'&Signature='+signed;
        System.debug('Signed URL-2: ' + url);
        
        String url2 = serviceEndPoint + '?AWSAccessKeyId=' + sunrunS3ProxySetting.Access_Key__c + '&Expires=' + Lexpires+'&Signature='+codedsigned;
        System.debug('Signed URL-2: ' + url2);
        url = url2;
        return url;
    }

    public static SunRunProxyRequestInfo getSignedURL(String method, String proxySettingName, String proposalName, String fileName, String fileType){
        DateTime d = System.now();
        String timeFormat = d.formatGmt('EEE, dd MMM yyyy HH:mm:ss') + ' GMT';
        SunRunS3Proxy_Settings__c sunrunS3ProxySetting = sunrunS3ProxySettings.get(proxySettingName);

        String serviceEndPoint = getServiceEndPoint(sunrunS3ProxySetting.Folder_Name__c, proposalName, fileName);
        String encodedPath = getEncodedPathForSignature(sunrunS3ProxySetting.Folder_Name__c, proposalName, fileName);
        String stringtosign = method + '\n\n' + fileType + '\n\n' + 'x-amz-date:' + timeFormat + '\n' + '/' + encodedPath; 
        System.debug('buf1 : ' + stringtosign);

        string signature  = make_sunrunProxysig(stringtosign, sunrunS3ProxySetting.Secret_Key__c);      

        SunRunProxyRequestInfo requestInfo = new SunRunProxyRequestInfo();
        requestInfo.requestEndpoint = serviceEndPoint;
        requestInfo.signature = signature;
        requestInfo.timestamp = timeFormat;
        requestInfo.accessKey = sunrunS3ProxySetting.Access_Key__c;
        System.debug('requestInfo: ' + requestInfo);
        return requestInfo;
    }
    
    public static String getServiceEndPoint(String folderName, String proposalName, String fileName){
        String serviceEndPoint = proxyEndpoint + '/' + folderName + '/';
        if(proposalName != null && proposalName != ''){
            serviceEndPoint += proposalName + '/';
        }
        //serviceEndPoint += fileName.replaceAll(' ', '%20');
        serviceEndPoint += encodeFileName(fileName);
        return serviceEndPoint;
    }
    
    public static string getEncodedPathForSignature(String folderName, String proposalName, String fileName){
        String encodedPath = sunrunS3BucketName;
        encodedPath +=  '/' +  folderName ;
        String filePath = '';
        if(proposalName != null && proposalName != ''){
            filePath += '/' + proposalName;
        }
        filePath += '/'; 
        encodedPath += EncodingUtil.urlEncode(filePath,'UTF-8');
        //encodedPath += fileName;
        //encodedPath = encodedPath.replaceAll(' ', '%20');
        encodedPath += encodeFileName(fileName);
        return encodedPath;
    } 

    public static Long getExpirationTime(){
        Datetime now = DateTime.now();
        Datetime expireson = now.addMinutes(55);
        Long Lexpires = expireson.getTime()/1000;
        return Lexpires;
    }   
    
    public static String make_sunrunProxysig(string canonicalBuffer, String sunrunSecrectKey) {
        System.debug('canonicalBuffer: ' + canonicalBuffer);  
        System.debug('sunrunSecrectKey: ' + sunrunSecrectKey);      
        String sig ;
        Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(canonicalBuffer),blob.valueof(sunrunSecrectKey)); 
        sig = EncodingUtil.base64Encode(mac);                
        return sig;
    }
    
    public static String getProposalNameForMasterDocs(String proposalName){
        String tempProposalName = proposalName;
        Integer index = tempProposalName.indexOf('-');
        proposalName = tempProposalName.substring(0, index);
        return proposalName;
    }
    
    public static String encodeFileName(String fileName){
        System.debug('fileName: ' + fileName);
        fileName = (fileName != null ) ? fileName.replaceAll(' ', '%20') : fileName;
        String modifiedFileName = (fileName != null) ? EncodingUtil.urlEncode(fileName, 'UTF-8').replaceall('%2520', '%20') : fileName;
        System.debug('modifiedFileName: ' + modifiedFileName);
        return modifiedFileName;
    }

    
	public static String getAccessKey(String proxySettingsNameStr){
		String result = '';
		SunRunS3Proxy_Settings__c sunrunS3ProxySetting = sunrunS3ProxySettings.get(proxySettingsNameStr);
		result =  (sunrunS3ProxySetting != null) ? sunrunS3ProxySetting.Access_Key__c : 'AKIAIU2BKN3RTR3GCBFQ';
		return result;
	}

	public static String getSecretKey(String proxySettingsNameStr){
		String result = '';
		SunRunS3Proxy_Settings__c sunrunS3ProxySetting = sunrunS3ProxySettings.get(proxySettingsNameStr);
		result =  (sunrunS3ProxySetting != null) ? sunrunS3ProxySetting.Secret_Key__c : 'DealDocManager-secretAccessKey-inbound-production';
		return result;
	}
	
}