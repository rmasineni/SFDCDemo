@isTest
global class DocuSignInpersonUrlMockResponse implements HttpCalloutMock
{
    global HTTPResponse respond(HTTPRequest req)
    {
        String response = '{"url": "https://demo.docusign.net/Signing/startinsession.aspx?t=e2e41e4f-7be9-41e9-aa81-f7e7565f4188"}';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(response);
        res.setStatusCode(200);
        return res;
    }
}