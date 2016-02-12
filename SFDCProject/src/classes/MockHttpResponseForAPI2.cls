@isTest
global class MockHttpResponseForAPI2 implements HttpCalloutMock
{
    global HTTPResponse respond(HTTPRequest req)
    {
        String response = '[{"response": {"code": "200","message": "OK: The request was successful. See response body for additional data.","data": {"message": "Commission created successfully.","commission_uid": 4981886}}}]';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(response);
        res.setStatusCode(200);
        return res;
    }
}