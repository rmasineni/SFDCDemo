@IsTest
public class FlexibleCalloutMock implements HttpCalloutMock {
	
    public class FlexibleCalloutMockException extends Exception {}
    
    public List<MockConfig> mockConfigs {get;set;}
    public MockResponse defaultResponse {get;set;}
    public List<CalloutRequest> calloutRequests {get;set;}
    
    public FlexibleCalloutMock() {
        this(null);
    }
    
    public FlexibleCalloutMock(Integer statusCode, String body) {
        this(new MockResponse(statusCode, body));
    }

    public FlexibleCalloutMock(MockResponse defaultResponse) {
        mockConfigs = new List<MockConfig>();
        calloutRequests = new List<CalloutRequest>();
        this.defaultResponse = defaultResponse;
        
        setAsMock();
    }

    public FlexibleCalloutMock addConfig(RequestMatch reqMatch, MockResponse resp) {
        mockConfigs.add(new MockConfig(reqMatch, resp));
        
        return this;
    }

    public FlexibleCalloutMock ifUrlContainsReturn(String url, String body) {
        mockConfigs.add(new MockConfig(new UrlContainsMatch(url), new MockResponse(body)));
        
        return this;
    }
    public FlexibleCalloutMock ifUrlContainsReturnResource(String body, String staticResource) {
        mockConfigs.add(new MockConfig(new UrlContainsMatch(body), new MockResponse(getStaticResourceAsString(staticResource))));
        
        return this;
    }

    public FlexibleCalloutMock ifUrlEndsWithReturn(String url, String body) {
        mockConfigs.add(new MockConfig(new UrlEndsWithMatch(url), new MockResponse(body)));
        
        return this;
    }
    
    public FlexibleCalloutMock ifUrlStartsWithReturn(String url, String body) {
        mockConfigs.add(new MockConfig(new UrlStartsWithMatch(url), new MockResponse(body)));
        
        return this;
    }

    public FlexibleCalloutMock ifUrlEndsWithReturnResource(String body, String staticResource) {
        mockConfigs.add(new MockConfig(new UrlEndsWithMatch(body), new MockResponse(getStaticResourceAsString(staticResource))));
        
        return this;
    }

    public FlexibleCalloutMock ifUrlEqualsReturn(String url, String body) {
        mockConfigs.add(new MockConfig(new UrlEqualsMatch(url), new MockResponse(body)));
        
        return this;
    }
    
    public FlexibleCalloutMock ifUrlEqualsReturn(String url, Integer httpCode, String body) {
        mockConfigs.add(new MockConfig(new UrlEqualsMatch(url), new MockResponse(httpCode, body)));
        
        return this;
    }

    public FlexibleCalloutMock ifUrlEqualsCountReturn(String url, Integer count, Integer httpStatus, String body) {
        mockConfigs.add(new MockConfig(new UrlEqualsCountMatch(url, count, this), new MockResponse(httpStatus, body)));
        
        return this;
    }

    public FlexibleCalloutMock ifUrlEqualsReturnResource(String body, String staticResource) {
        mockConfigs.add(new MockConfig(new UrlEqualsMatch(body), new MockResponse(getStaticResourceAsString(staticResource))));
        
        return this;
    }

    public FlexibleCalloutMock ifBodyContainsReturn(String reqBody, String body) {
        mockConfigs.add(new MockConfig(new BodyContainsMatch(reqBody), new MockResponse(body)));
        
        return this;
    }
    
    public FlexibleCalloutMock ifBodyContainsReturnResource(String body, String staticResource) {
        mockConfigs.add(new MockConfig(new BodyContainsMatch(body), new MockResponse(getStaticResourceAsString(staticResource))));
        
        return this;
    }

    public FlexibleCalloutMock ifBodyEqualsReturn(String reqBody, String body) {
        mockConfigs.add(new MockConfig(new BodyEqualsMatch(reqBody), new MockResponse(body)));
        
        return this;
    }
    public FlexibleCalloutMock ifBodyEqualsReturnResource(String body, String staticResource) {
        mockConfigs.add(new MockConfig(new BodyEqualsMatch(body), new MockResponse(getStaticResourceAsString(staticResource))));
        
        return this;
    }

	public HTTPResponse respond(HTTPRequest req) {

        System.debug('Received a http request ' + req + '. going to process using mock configs ' + mockConfigs);

        HttpResponse resp = new HttpResponse();
        calloutRequests.add(new CalloutRequest(req, resp));
        
        MockConfig mockConfig = null;
        MockResponse mockResp = null;

        for (MockConfig config : mockConfigs) {
            //System.debug('Checking is requestMatch [' + config.requestMatch +'] matches the http request ' + req);
            if (config.requestMatch.isMatches(req)) {
                mockConfig = config;
                break;
            }
        }
        
        if (mockConfig == null) {
        	System.debug('None of the configured mock responses matches the http request ' + req 
                         + ' so going to use the default response (if configured) ' + defaultResponse);
            mockResp = defaultResponse;
        } else {
            mockResp = mockConfig.mockResponse;
        }

        if (mockResp == null) {
            throw new FlexibleCalloutMockException('Couldnot identify a mock response for ' + req);
        }
        
        resp.setBody(mockResp.body);
        resp.setStatusCode(mockResp.statusCode);
        Map<String, String> headers = mockResp.headers;
        if (headers.isEmpty() && defaultResponse != null) {
            headers = defaultResponse.headers;
        }
        
        for (String headerName : headers.keySet()) {
            resp.setHeader(headerName, headers.get(headerName));
        }
        
        return resp;
    }
    
    public static String getStaticResourceAsString(String staticResourceName) {
        List<StaticResource> srs = [select id, body from StaticResource Where Name = :staticResourceName];
        if (srs.isEmpty()) {
            throw new FlexibleCalloutMockException('Static Resource ' + staticResourceName + ' is not defined.');
        }
        
        String contents = srs.get(0).body.toString();
        return contents;
    }
 	
    public FlexibleCalloutMock setAsMock() {
        Test.setMock(HttpCalloutMock.class, this);
        return this;
    }
    
    public Boolean isUrlInvoked(String url) {
        return getUrlInvokedCount(url) > 0;
    }
    
    public Integer getUrlInvokedCount(String url) {
        Integer count = 0;
        for (CalloutRequest req : calloutRequests) {
            if (req.request.getEndpoint() == url) {
                count++;
            }
        }
        
        return count;
    }
    
    public virtual class RequestMatch {
        public virtual Boolean isMatches(HttpRequest req) {
            return true;
        }
    }

    public virtual class UrlEqualsMatch extends RequestMatch {
        public String url {get;set;}

        public UrlEqualsMatch(String url) {
            this.url = url;
        }
        
        public override Boolean isMatches(HttpRequest req) {
            return req.getEndpoint() == url;
        }
    }

    //This mock allows to match response only after certain number of
    //url invocations are met. For instance, if you say 2 matches for URL,
    //then first invoation of url wont match but second same url invocation
    //will match the response. This can be used to handle error retry 
    //scenarios.
    public virtual class UrlEqualsCountMatch extends RequestMatch {
        public String url {get;set;}
        public Integer count {get;set;}
        public FlexibleCalloutMock mock {get;set;}		
        
        public UrlEqualsCountMatch(String url, Integer count, FlexibleCalloutMock mock) {
            this.url = url;
            this.count = count;
            this.mock = mock;
        }
        
        public override Boolean isMatches(HttpRequest req) {
            if (req.getEndpoint() == url) {
                if (count == mock.getUrlInvokedCount(url)) {
                    return true;
                }
            }
            
            return false;
        }
    }

    public virtual class UrlEndsWithMatch extends RequestMatch {
        public String url {get;set;}

        public UrlEndsWithMatch(String url) {
            this.url = url;
        }
        
        public override Boolean isMatches(HttpRequest req) {
            return req.getEndpoint().endsWith(url);
        }
    }

    public virtual class UrlStartsWithMatch extends RequestMatch {
        public String url {get;set;}

        public UrlStartsWithMatch(String url) {
            this.url = url;
        }
        
        public override Boolean isMatches(HttpRequest req) {
            return req.getEndpoint().startsWith(url);
        }
    }

    public virtual class BodyEqualsMatch  extends RequestMatch {
        public String body {get;set;}

        public BodyEqualsMatch(String body) {
            this.body = body;
        }
        
        public override Boolean isMatches(HttpRequest req) {
            return req.getBody() == body;
        }
    }

    public virtual class BodyContainsMatch  extends RequestMatch {
        public String body {get;set;}

        public BodyContainsMatch(String body) {
            this.body = body;
        }
        
        public override Boolean isMatches(HttpRequest req) {
            return req.getBody().indexOf(body) >= 0;
        }
    }
    
    public virtual class UrlContainsMatch  extends RequestMatch {
        public String url {get;set;}

        public UrlContainsMatch(String url) {
            this.url = url;
        }
        
        public override Boolean isMatches(HttpRequest req) {
            Boolean matches = req.getEndpoint().indexOf(url) >= 0;
            //System.debug('Doing url contains match urlcontains=' + url + ', httpurl='+req.getEndpoint() +' with resopnse ' + matches);
            return matches;
        }
    }
    
    public class MockResponse {
        public String body {get;set;}
        public Integer statusCode {get;set;}
    	public Map<String, String> headers {get;set;}
        
        public MockResponse () {
            this(null, null);
        }
        
        public MockResponse (String body) {
            this(null, body);
        }
        
        public MockResponse (Integer statusCode, String body) {
            this.body = body;
            if (statusCode == null) {
                statusCode = 200;
            }
            this.statusCode = statusCode;
            this.headers = new Map<String, String>();
        }
        
        public MockResponse addHeader(String key, String value) {
            headers.put(key, value);
            
            return this;
        }
    }
    
    public class MockConfig {
        public RequestMatch requestMatch {get;set;}
        public MockResponse mockResponse {get;set;}
        
        public MockConfig(RequestMatch requestMatch, MockResponse mockResponse) {
            this.requestMatch = requestMatch;
            this.mockResponse = mockResponse;
        }
    }
   
    public class CalloutRequest {
        public HttpRequest request {get;set;}
        public HttpResponse response {get;set;}
        public DateTime timeInvoked {get;set;}
        
        public CalloutRequest (HttpRequest request, HttpResponse response) {
            timeInvoked = DateTime.now();
            this.request = request;
            this.response = response;
        }
    }

}