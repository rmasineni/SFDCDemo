@isTest
global class DocumentUploadApiMockResponse implements HttpCalloutMock
{
    global HTTPResponse respond(HTTPRequest req)
    {
        String response = '[{"contentMd5":"8b5f1ec077763d164d7d3b4362125731","url":"https://devmaj-sunrun.s3-us-west-2.amazonaws.com/qualificationDoc/1705931771/Utility_Bill_12_29_2015_12%3A11%3A11?AWSAccessKeyId=AKIAI3TSGQR3IGCH3C4Q&Expires=1453279029&Signature=SZHqql0D5hErI%2F0DbiVXVOHJVCw%3D"}]';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(response);
        res.setStatusCode(201);
        return res;
    }
}