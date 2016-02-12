@IsTest
public class BusinessExceptionTest {
    testmethod static void testException() {
        BusinessException be = new BusinessException();
        System.assertEquals(null, be.errorCode);
        
		be = new BusinessException('errorCode', 'message');
        System.assertEquals('errorCode', be.errorCode);
        System.assertEquals('message', be.getMessage());
         
		be = BusinessException.Create('errorCode', 'message');
        System.assertEquals('errorCode', be.errorCode);
        System.assertEquals('message', be.getMessage());

        be = new BusinessException('statusCode', 'errorCode', 'message');
        System.assertEquals('statusCode', be.statusCode);
        System.assertEquals('errorCode', be.errorCode);
        System.assertEquals('message', be.getMessage());
        
		be = BusinessException.create('statusCode', 'errorCode', 'message');
        System.assertEquals('statusCode', be.statusCode);
        System.assertEquals('errorCode', be.errorCode);
        System.assertEquals('message', be.getMessage());
        
		be = BusinessException.create('statusCode', 'errorCode', 'message', new SystemException());
        System.assertEquals('statusCode', be.statusCode);
        System.assertEquals('errorCode', be.errorCode);
        System.assertEquals('message', be.getMessage());
        System.assertNotEquals(null, be.getCause());

        be = BusinessException.create('errorCode', 'message', new SystemException());
        System.assertEquals('errorCode', be.errorCode);
        System.assertEquals('message', be.getMessage());
        System.assertNotEquals(null, be.getCause());
    }
}