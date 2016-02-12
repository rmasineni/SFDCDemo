public class SunRunS3RestConnectionAsync {
    
  public static String PROPOSAL_DOCS_SETTINGS_NAME = 'ProposalDoc';
    public static String UPLOADED_DOCS_SETTINGS_NAME = 'UploadedDoc';
    public static String UPLOADED_PHOTOS_SETTINGS_NAME = 'FinalMilestoneDoc';
    public static String INCOMPLETE_DOCS_SETTINGS_NAME = 'IncompleteSignedDoc';
    public static String COMPLETED_SIGNED_DOCS_SETTINGS_NAME = 'CompleteSignedDoc';
    public static String SERVICE_CONTRACT_DOCS_SETTINGS_NAME = 'ServiceContract';
    public static String OPPORTUNITY_DOCS_SETTINGS_NAME = 'Opportunity';
    
    public static String proxyEndpoint = Label.SunRun_S3_Proxy;
    public static string sunrunS3BucketName = Label.SunRun_S3_Bucket;
    public static Map<String, SunRunS3Proxy_Settings__c> sunrunS3ProxySettings = SunRunS3Proxy_Settings__c.getall(); 
   
    public  static SunRunS3Proxy_Settings__c sunrunS3ProxySetting {get;set;}
    public  static string s3ProxySettingName {get;set;}

    public  static string getSecretKey(){ return sunrunS3ProxySetting.Secret_Key__c; }
    public  static string getAccessKey(){ return sunrunS3ProxySetting.Access_Key__c; }
    public  static string getSunrunS3FolderName(){ return sunrunS3ProxySetting.Folder_Name__c; }
   
    
    public static string proposalName {get;set;}
    public static string fileName {get;set;}
    
    private static  String dateString;  
    public static void setDateString(Integer sec) {dateString = formatDateString(System.now().addSeconds(-5)); }
    public static string getDateString(){return dateString;}
    
    private static HttpResponse res = null;
    public  static HTTPResponse getResponse() { return res; }
    private static Map<String,String> headers = new Map<String, String>{};
    public static void setHeaders(Map<String, String> h) {headers = h.clone();}
    
    public static blob documentBlob{get;set;}
    public static String errorMessage {get;set;}
    public static string proxySetting{get;set;}
    
     public static string formatDateString(DateTime d) {
        //d.addSeconds(-5);
        String timeFormat = d.formatGmt('EEE, dd MMM yyyy HH:mm:ss') + ' GMT';
        return timeFormat; 
    }
    private static void setAuthHeader(HTTPRequest req) {   
        string buf = make_canonicalBuffer(req.getMethod(),getDateString(),new string[]{});
        string signature  = make_sig(buf);      
        
        req.setHeader('authorization','AWS '+getAccessKey()+':'+signature);
    }
    
    public static string getAuthorizationPath(){
        system.debug('getSunrunS3FolderName()' +getSunrunS3FolderName());
        String authorizationPath = '';
        authorizationPath += (sunrunS3BucketName != null) ? sunrunS3BucketName  : ''; 
        authorizationPath += (getSunrunS3FolderName() != null) ? ('/' + getSunrunS3FolderName()) : ''; 
        
        String tempFilePath = '';
        tempFilePath += (proposalName != null) ? ('/' + proposalName) : ''; 
        tempFilePath += '/' ; 
        authorizationPath += EncodingUtil.urlEncode(tempFilePath, 'UTF-8');
        //authorizationPath += fileName.replaceAll(' ', '%20');
        authorizationPath += encodeFileName();
        
        
        return authorizationPath;
    }
    public static String encodeFileName(){
        System.debug('fileName: ' + fileName);
        fileName = (fileName != null ) ? fileName.replaceAll(' ', '%20') : fileName;
        String modifiedFileName = (fileName != null) ? EncodingUtil.urlEncode(fileName, 'UTF-8').replaceall('%2520', '%20') : fileName;
        System.debug('modifiedFileName: ' + modifiedFileName);
        return modifiedFileName;
    }

    public static string getEndPoint() {
        string endPoint='';
        endPoint += (proxyEndpoint != null) ? proxyEndpoint + '/' : ''; 
        endPoint += (getSunrunS3FolderName() != null) ? getSunrunS3FolderName() + '/' : ''; 
        endPoint += (proposalName != null) ? proposalName + '/' : ''; 
        //endPoint += (fileName != null) ? fileName.replaceAll(' ', '%20') : '';
        endPoint += (fileName != null) ? encodeFileName() : '';
        return endPoint;
    }
    
    
    public static String make_canonicalBuffer(string method, string datestr, string[] aws_headers) {
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
        canonicalBuffer += '/' + getAuthorizationPath();
        System.debug('canonicalBuffer: ' + canonicalBuffer);
        return  canonicalBuffer;
    }

               
    
     private static string make_sig(string canonicalBuffer) {
        system.debug(canonicalBuffer);
        String macUrl ;
        Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(canonicalBuffer),blob.valueof(sunrunS3ProxySetting.Secret_Key__c));  
        macUrl = EncodingUtil.base64Encode(mac);        
       
        return macUrl;
    }   
    
    
     public static void makeRequest(string method) {
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
             
         }
         system.debug('getEndPoint()' + getEndPoint() );
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
                 system.debug('reqsunruns3>>' + req);
                 res = http.send(req); 
                 system.debug('reqsunruns3>>' + req);
                 
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
             system.debug('eeeeeeeee' +  e);
             if (res != null && res.getStatus()=='OK') { 
                 system.debug(res.toString()); // for some reason HEAD ends up here
             } else { 
                 errorMessage = e.getMessage();
                 System.debug('ERROR: '+ e);
                
             }
         }
         headers.clear(); 
    }
    
    public static void makeRequest(String method, Blob blobValue, Map<String, String> header) {
  
        if (blobValue != null){ 
            documentBlob = blobValue ;
        }
        if (header != null ) setHeaders(header);  
        makeRequest(method);       
    }

    public static void getUploadS3Document(SR_Attachment__c srAttachmentObj, Boolean masterDoc){
   
        fileName = srAttachmentObj.Document_Name_On_File_Server__c;
         proposalName = srAttachmentObj.Parent_Proposal_Name__c;
        if(srAttachmentObj.Wet_Sign_Status__c == null || srAttachmentObj.Wet_Sign_Status__c == '' ){
            String tempProposalName = proposalName;
            Integer index = tempProposalName.indexOf('-');
            proposalName = tempProposalName.substring(0, index);
        }
        String documentSource = srAttachmentObj.Document_Source__c;
        proxySetting =SRAttachmentManager.getSunRunS3ProxySettingsName(srAttachmentObj, masterDoc);
        sunrunS3ProxySetting = sunrunS3ProxySettings.get(proxySetting);
        system.debug('sunrunS3ProxySettingName'+proxySetting);
        makeRequest('GET');
        if(documentBlob!=null){  		
	     makeRequest('PUT', documentBlob,new Map<String, String>{'content-type'=>'application/pdf'});
			
		}	
		
    }
    
 
    
    
    
}