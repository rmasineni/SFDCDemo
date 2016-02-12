@IsTest
public class BaseApiTest {

    public static JsonReader assertSuccessResponse() {
        String body = RestContext.response.responseBody.toString();
        if (body.indexOf('errorCode') >= 0) {
            System.assert(false, 'Rest call failed with response ' + body);
        }
        
        return new JsonReader(body);
    }
    
    public static JsonReader assertErrorResponse(Integer httpCode) {
        System.assertEquals(httpCode, RestContext.response.statusCode);
        
        String body = RestContext.response.responseBody.toString();
        if (body.indexOf('errorCode') < 0) {
            System.assert(false, 'Expected a error response but there is no error code in body ' + body);
        }
        
        return new JsonReader(body);
    }

    public static JsonReader assertErrorResponse(Integer httpCode, String errorCode) {
        System.assertEquals(httpCode, RestContext.response.statusCode);
        
        String body = RestContext.response.responseBody.toString();
        if (body.indexOf('errorCode') < 0) {
            System.assert(false, 'Expected a error response but there is no error code in body ' + body);
        }
        
        JsonReader reader = new JsonReader(body);
        System.assertEquals(errorCode, reader.getString('errorCode'));
        return reader;
    }

    public static void assertAuditFieldsExists(JsonReader jsonReader) {
    	System.assertNotEquals(null, jsonReader.getString('createdBy'));
    	System.assertNotEquals(null, jsonReader.getString('createdDate'));
    	System.assertNotEquals(null, jsonReader.getString('lastModifiedBy'));
    	System.assertNotEquals(null, jsonReader.getString('lastModifiedDate'));
    }
    
    public static void setRequest(String url) {
        setRequest(url, null);
    }
    
    public static void setRequest(String url, String body) {
        baseInit();
	    RestContext.request.requestURI = '/services/apexrest' + url;
        RestContext.request.requestBody = body==null?null:Blob.valueOf(body);
    }
    
    public static void setParam(String key, String value) {
        baseInit();
        RestContext.request.params.put(key, value);
    }

    public static void baseInit() {
        if (RestContext.request == null) {
	        RestContext.request = new RestRequest();
        }
        if (RestContext.response == null) {
	        RestContext.response = new RestResponse();
        }
    }
}