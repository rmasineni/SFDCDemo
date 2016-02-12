@IsTest
public class RestServiceTest {
	
    testmethod public static void testRequestObject() {
        RestRequest restReq = new RestRequest();
        
		RestServiceDto.Request req = new RestServiceDto.Request(restReq);
		
        //Check required param test
        try {
            req.checkForRequiredParam('foo');
            System.assert(false, 'Should have thrown exception as there is no required parameter foo');
        } catch (Exception e) {
            //Expected
        }
        restReq.params.put('foo', 'bar');
		System.assertEquals('foo', req.checkForRequiredParam('foo'));
		
        //Test getString and getRequiredString 
        restReq.params.remove('foo');
        restReq.requestURI = '/test';
        try {
            req.getRequiredStringParam('foo');
            System.assert(false, 'Should have thrown exception as there is no required parameter foo');
        } catch (Exception e) {
            //Expected
        }
        System.assertEquals(null, req.getStringParam('foo'));
        
        restReq.params.put('foo', 'bar');
		System.assertEquals('bar', req.getRequiredStringParam('foo'));
        System.assertEquals('bar', req.getStringParam('foo'));

        //Test getDate and getRequiredDate
        restReq.params.remove('foo');
        try {
            req.getRequiredDateParam('foo');
            System.assert(false, 'Should have thrown exception as there is no required parameter foo');
        } catch (Exception e) {
            //Expected
        }
        System.assertEquals(null, req.getDateParam('foo'));
        
        restReq.params.put('foo', '2015-09-10');
		System.assertEquals(Date.newInstance(2015, 09, 10), req.getRequiredDateParam('foo'));
		System.assertEquals(Date.newInstance(2015, 09, 10), req.getDateParam('foo'));

        //Test getInteger and getRequiredInteger
        restReq.params.remove('foo');
        try {
            req.getRequiredIntegerParam('foo');
            System.assert(false, 'Should have thrown exception as there is no required parameter foo');
        } catch (Exception e) {
            //Expected
        }
        System.assertEquals(null, req.getIntegerParam('foo'));
        
        restReq.params.put('foo', '10');
		System.assertEquals(10, req.getRequiredIntegerParam('foo'));
		System.assertEquals(10, req.getIntegerParam('foo'));

        //Test getBoolean
        restReq.params.remove('foo');
        System.assertEquals(false, req.getBooleanParam('foo'));
        
        restReq.params.put('foo', 'false');
        System.assertEquals(false, req.getBooleanParam('foo'));

        restReq.params.put('foo', 'true');
        System.assertEquals(true, req.getBooleanParam('foo'));

        //Test getList and getRequiredList
        restReq.params.remove('foo');
        try {
            req.getRequiredListParam('foo');
            System.assert(false, 'Should have thrown exception as there is no required parameter foo');
        } catch (Exception e) {
            //Expected
        }
        System.assertEquals(0, req.getListParam('foo').size());
        
        restReq.params.put('foo', '10,20');
		System.assertEquals(2, req.getRequiredListParam('foo').size());
		System.assertEquals(2, req.getListParam('foo').size());
    }
    
    testmethod public static void testResponseObject() {
        RestResponse restResp = new RestResponse();
 		RestServiceDto.Response resp = new RestServiceDto.Response(restResp);
        resp.setError('Code', 'Message');
        System.assertEquals('Code', resp.errorCode);
        System.assertEquals('Message', resp.message);
       
        resp.setError(404, 'Code', 'Message');
        System.assertEquals(404, resp.httpStatus);
        System.assertEquals('Code', resp.errorCode);
        System.assertEquals('Message', resp.message);
        
        resp.setResponse('Body');
        System.assertEquals(200, resp.httpStatus);
        System.assertEquals('Body', resp.restResp.responseBody.toString());
   }
    
}