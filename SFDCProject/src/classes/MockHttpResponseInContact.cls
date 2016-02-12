@isTest
global class MockHttpResponseInContact implements HttpCalloutMock {
      global HTTPResponse respond(HTTPRequest req)
    {
        String response = '{"resultSet":{"listId":"4811","importStatus":"true","procRecords":"1","validRecords":"1","invalidRecords":"0","errorResults":""}}';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(response);
        res.setStatusCode(200);
        return res;
    }

}