public class UnsuccessfulHttpResponseException extends SystemException {
    
    private HttpRequest request = null;
    private HttpResponse response = null;
    private Map<String, String> requestHeaders {get;set;}
    
    public UnsuccessfulHttpResponseException (HttpResponse response) {
    	this(null, response);
    }
    
    public UnsuccessfulHttpResponseException (HttpRequest request, HttpResponse response) {
    	this(request, response, null);
    }
    
    public UnsuccessfulHttpResponseException (HttpRequest request, HttpResponse response, Map<String, String> requestHeaders) {
        super(response.toString() + ' [' + response.getBody() + ']');
        this.response = response;
        this.request = request;
        this.requestHeaders = requestHeaders;
    }

    public HttpRequest getRequest() {
        return request;
    }
    
    public HttpResponse getResponse() {
        return response;
    }
    
    public Integer getStatusCode() {
        return response.getStatusCode();
    }

    public Boolean isStatusCode(Integer code) {
        return response.getStatusCode() == code;
    }
    
    /**
     * Checks if http response body contains the specified string, case sensitive and return true
     * if it does and false otherwise.
     */
    public Boolean isResponseContains(String value) {
		return response.getBody().contains(value);
    }
    
    /**
     * Checks if http response body contains the specified string, case insensitive (it converts body/value into lowercase and compares) and return true
     * if it does and false otherwise.
     */
    public Boolean isResponseContainsIc(String value) {
		return response.getBody().toLowerCase().contains(value.toLowerCase());
    }
    
    public String toString() {
        
        String requestHeaderString = null;
        if (requestHeaders != null) {
            for (String header : requestHeaders.keySet()) {
                if (header == null) {
                    continue; //sometimes headers are null
                }
                requestHeaderString = (requestHeaderString==null?'':requestHeaderString + ', ') + header + '=' + requestHeaders.get(header);
            }
        }

        String responseHeaderString = null;
        for (String header : response.getHeaderKeys()) {
            if (header == null) {
                continue; //sometimes headers are null
            }
            responseHeaderString = (responseHeaderString==null?'':responseHeaderString + ', ') + header + '=' + response.getHeader(header);
        }
        
        String value = 'Request:\nMethod: ' + request.getMethod() + '\nUrl: ' + request.getEndpoint() 
            + '\nHeaders: ' + requestHeaderString + '\nBody:\n' + request.getBody() + '\n\n\nResponse:\nStatus: ' + response.getStatusCode() + ' ' + response.getStatus()
            + '\nHeaders: ' + responseHeaderString + '\nResponse:\n' + response.getBody();
       
        return value;
    }
}