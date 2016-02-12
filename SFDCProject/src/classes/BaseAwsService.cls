/**
 * This is the base class which handles the AWS Version 4 Authentication as described at
 * http://docs.aws.amazon.com/general/latest/gr/signature-version-4.html
 * 
 * AWS Authentication process is extremely complex process and any small change would result
 * in mismatched signature. So please refer to the AWS signing spec before updating the code.
 */ 
public virtual class BaseAwsService extends BaseClass {

    public class AwsConfig {
        public String accessKey {get;set;}
        public String secretKey {get;set;}
        
        public AwsConfig(String accessKey, String secretKey) {
            this.accessKey = accessKey;
            this.secretKey = secretKey;
        }
    }
    
    public class AwsRequest {
        public String region {get;set;}
        public String service {get;set;}
        public String method {get;set;}
        public String url {get;set;} 
        public Map<String, String> headers {get;set;} 
        public Map<String, String> queryParams {get;set;} 
        public Map<String, String> bodyParams {get;set;} 
        public String requestPayload {get;set;}
        public DateTime requestDateTime {get;set;}

        public String canonicalUri {get;set;}
        public String canonicalQueryString {get;set;}
        public String canonicalHeaders {get;set;}
        public String signedHeaders {get;set;}
        public String requestPayloadHash {get;set;}
        public String canonicalRequest {get;set;}
        public String canonicalRequestHash {get;set;}
        public String stringToSign {get;set;}
        public String signature {get;set;}
        public String authorizationHeader {get;set;}
        
        public AwsRequest() {
            headers = new Map<String, String>();
            queryParams = new Map<String, String>();
            bodyParams = new Map<String, String>();
        }
        
        public String getFormattedDateTime() {
            return requestDateTime.formatGmt('yyyyMMdd\'T\'HHmmss\'Z\'');
        }

        public String getFormattedDate() {
            return requestDateTime.formatGmt('yyyyMMdd');
        }
    }
    
    public String awsSendSqsMessage(String sqsUrl, String body, AwsConfig awsConfig, SyncJobInfo syncJob) {
        AwsRequest awsRequest = new AwsRequest();
        awsRequest.url = sqsUrl;
        awsRequest.bodyParams.put('Action', 'SendMessage');
        awsRequest.bodyParams.put('MessageBody', body);
        awsRequest.bodyParams.put('Version', '2012-11-05');
        
        if (syncJob != null) {
	        syncJob.log('Sending sqs request url=' + sqsUrl + ', body=' + body);
        }
        
        String response = awsHttpPost(awsConfig, awsRequest);

        if (syncJob != null) {
	        syncJob.log('Received sqs response ' + response);
        }
        
        return response;
    }
    
    /**
     * Sends the Aws Http Post request and returns the response body.
     */
    public String awsHttpPost(AwsConfig awsConfig, AwsRequest awsRequest) {
        awsRequest.method = 'POST';
        signAwsRequest(awsConfig, awsRequest);
        return httpPost(awsRequest.url, awsRequest.requestPayload, awsRequest.headers, 1000*30);
    }

    /**
     * Signs the given AWS Request using AWS Version 4 Signature Process. All intermediate
     * request responses are stored in the AWS Request. After signing, the Authorization
     * header is added to the AwsRequest.headers parameters.
     * 
     * Implementation of
     * http://docs.aws.amazon.com/general/latest/gr/sigv4_signing.html
     */    
    public AwsRequest signAwsRequest(AwsConfig awsConfig, AwsRequest awsRequest) {
        
        initRequest(awsConfig, awsRequest);
        
        createCanonicalRequest(awsConfig, awsRequest);
        createStringToSign(awsConfig, awsRequest);
        createSignature(awsConfig, awsRequest);
        createAuthorizationHeader(awsConfig, awsRequest);
        
        info('Signed Aws Request ' + awsRequest);
        
        return awsRequest;
    }

    public void initRequest(AwsConfig awsConfig, AwsRequest awsRequest) {
        
        //derive the region based on the url
        if (awsRequest.region == null) {
	        awsRequest.region = awsRequest.url.substringBetween('sqs.', '.amazonaws.com');
        }
        
        if (awsRequest.service == null) {
            //Hardcoded to sqs at this time and will have to be updated later.
	        awsRequest.service = 'sqs';
        }
        
        awsConfig.accessKey = awsConfig.accessKey.trim();
        awsConfig.secretKey = awsConfig.secretKey.trim();
        
        if (!awsRequest.headers.containsKey('Host')) {
            awsRequest.headers.put('Host', new System.Url(awsRequest.url).getHost());
        }
    
        if (!awsRequest.headers.containsKey('Date') && !awsRequest.headers.containsKey('date')) {
            awsRequest.requestDateTime = (DateTime) firstNonNull(awsRequest.requestDateTime, getCurrentDateTime());
            
            //Date time should be formatted as defined in  RFC 7231
            //http://en.wikipedia.org/wiki/List_of_HTTP_header_fields#Request_fields
            awsRequest.headers.put('Date', awsRequest.getFormattedDateTime());
        }
        
        //Stupid AWS. 09 Sep 2011 is Fri but in the signing doc, they treat it as Mon.
        //Unless the string matches exactly, the signature will fail so we had to overwrite
        //that calculated value with hardcoded string.        
        if (Test.isRunningTest()) {
            String httpDateHeaderValue = (String) BaseClass.testParams.get('HttpDateHeaderValue');
            info('Test header ' + httpDateHeaderValue);
            if (httpDateHeaderValue != null) {
                awsRequest.headers.put('Date', httpDateHeaderValue);
            }
        }
        
        //Body params is convenience way accept values that needs to be sent in the request body
        //If Request Payload is not set, then let's derive the request body and 
        //set it as Request Payload.
        if (awsRequest.requestPayload == null) {
            awsRequest.requestPayload = createCanonicalParamsString(awsRequest.bodyParams);
        }
    }
    
    /**
     * Creates a Canonical Request from given AwsConfig and AwsRequest and stores the
     * created canonical request in the AwsRequest.
     * 
     * Implementation of 
     * http://docs.aws.amazon.com/general/latest/gr/sigv4-create-canonical-request.html
     */
    public AwsRequest createCanonicalRequest(AwsConfig awsConfig, AwsRequest awsRequest) {
        
        createCanonicalUri(awsConfig, awsRequest);

        createCanonicalQueryString(awsConfig, awsRequest);

        createCanonicalHeadersAndSignedHeaders(awsConfig, awsRequest);

        createRequestPayloadHash(awsConfig, awsRequest);

        awsRequest.canonicalRequest = 
            awsRequest.method + '\n' 
            + awsRequest.canonicalUri + '\n'
            + awsRequest.canonicalQueryString + '\n'
            + awsRequest.canonicalHeaders + '\n'
            + awsRequest.signedHeaders + '\n'
            + awsRequest.requestPayloadHash;
        
        awsRequest.canonicalRequestHash = sha256HashHex(awsRequest.canonicalRequest.trim()).toLowerCase();
        
        return awsRequest;
    }
    
    public void createCanonicalUri(AwsConfig awsConfig, AwsRequest awsRequest) {
        awsRequest.canonicalUri = '/' + awsRequest.url.replace('https://', '').substringAfter('/');
    }
    
    public void createCanonicalQueryString(AwsConfig awsConfig, AwsRequest awsRequest) {
        awsRequest.canonicalQueryString = createCanonicalParamsString(awsRequest.queryParams);
        
        //Replace all & with &amp;
        awsRequest.canonicalQueryString = awsRequest.canonicalQueryString.replaceAll('&', '&amp;');
        
        //Replace all + with %20
        awsRequest.canonicalQueryString = awsRequest.canonicalQueryString.replaceAll('\\+', '%20');
    }

    public void createCanonicalHeadersAndSignedHeaders(AwsConfig awsConfig, AwsRequest awsRequest) {
        Map<String, String> processedHeaders = new Map<String, String>();
        List<String> canonicalHeaderNames = new List<String>();
        for (String header : awsRequest.headers.keySet()) {
            String processedHeader = header.trim().toLowerCase();
            processedHeaders.put(processedHeader, awsRequest.headers.get(header));
            canonicalHeaderNames.add(processedHeader);
        }
        
        canonicalHeaderNames.sort();
        
        awsRequest.canonicalHeaders = '';
        for (String header : canonicalHeaderNames) {
            awsRequest.canonicalHeaders += header + ':' + processedHeaders.get(header) + '\n';
        }
        
        awsRequest.signedHeaders = join(canonicalHeaderNames, ';');
    }

    public void createRequestPayloadHash(AwsConfig awsConfig, AwsRequest awsRequest) {
        awsRequest.requestPayloadHash = sha256HashHex(awsRequest.requestPayload).toLowerCase();
    }
    
    /**
     * Implementation of 
     * http://docs.aws.amazon.com/general/latest/gr/sigv4-create-string-to-sign.html
     */
    public void createStringToSign(AwsConfig awsConfig, AwsRequest awsRequest) {
        awsRequest.stringToSign = 
            'AWS4-HMAC-SHA256' + '\n'
            + awsRequest.getFormattedDateTime() + '\n'
            + awsRequest.getFormattedDate() + '/'  + awsRequest.region + '/' + awsRequest.service + '/aws4_request' + '\n'
            + awsRequest.canonicalRequestHash;
    }
    
    /**
     * Implementation of 
     * http://docs.aws.amazon.com/general/latest/gr/sigv4-calculate-signature.html
     */
    public void createSignature(AwsConfig awsConfig, AwsRequest awsRequest) {
        Blob derivedSigningKey = deriveSigningKey(awsConfig, awsRequest);
        Blob signedData = hmacSha256(awsRequest.stringToSign, derivedSigningKey);
        awsRequest.signature = EncodingUtil.convertToHex(signedData).toLowerCase();
    }
    
    /**
     * Implementation of
     * http://docs.aws.amazon.com/general/latest/gr/signature-v4-examples.html#signature-v4-examples-java
     */
    public Blob deriveSigningKey(AwsConfig awsConfig, AwsRequest awsRequest) {
         String kSecret = 'AWS4' + awsConfig.secretKey;
         Blob kDate    = hmacSHA256(awsRequest.getFormattedDate(), kSecret);
         Blob kRegion  = hmacSHA256(awsRequest.region, kDate);
         Blob kService = hmacSHA256(awsRequest.service, kRegion);
         Blob kSigning = hmacSHA256('aws4_request', kService);
         return kSigning;
    }
    
    /**
     * Implements 
     * http://docs.aws.amazon.com/general/latest/gr/sigv4-add-signature-to-request.html
     */
    public void createAuthorizationHeader(AwsConfig awsConfig, AwsRequest awsRequest) {
        awsRequest.authorizationHeader = 
            'AWS4-HMAC-SHA256 Credential=' 
                + awsConfig.accessKey + '/' + awsRequest.getFormattedDate() 
                + '/' + awsRequest.region + '/' + awsRequest.service + '/aws4_request, SignedHeaders=' 
                + awsRequest.signedHeaders + ', Signature=' + awsRequest.signature;
        
        awsRequest.headers.put('Authorization', awsRequest.authorizationHeader);
    }
    
    /**
     * Given parameters map, creates a canonicalized string.
     */    
    public String createCanonicalParamsString(Map<String, String> params) {
        Map<String, String> processedParams = new Map<String, String>();
        List<String> paramNames = new List<String>();
        for (String param : params.keySet()) {
            String processedParam = urlEncode(param);
            paramNames.add(processedParam);
            processedParams.put(processedParam, urlEncode(params.get(param)));
        }


        paramNames.sort();
        
        String canonicalQueryString = null;
        for (String param : paramNames) {
            if (canonicalQueryString == null) {
                canonicalQueryString = '';
            } else {
                canonicalQueryString += '&';
            }
            
            canonicalQueryString += param + '=' + processedParams.get(param);
        }
        
        if (canonicalQueryString == null) {
            canonicalQueryString = '';
        }
        
        info('Canonical Query String ' + canonicalQueryString);
        
        return canonicalQueryString;
    }
    
}