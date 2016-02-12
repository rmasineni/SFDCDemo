public class BusinessException extends Exception {
    public String statusCode {get;set;}
    public String errorCode {get;set;}
    
    public BusinessException(String errorCode, String message) {
        this(null, errorCode, message);
    }
    
    public BusinessException(String statusCode, String errorCode, String message) {
        this.errorCode = errorCode;
        this.statusCode = statusCode;
        setMessage(message);
    }

    public static BusinessException create(String errorCode, String message) {
    	return create(null, errorCode, message, null);
    }
    
    public static BusinessException create(String errorCode, String message, Exception e) {
        return create(null, errorCode, message, e);
    }

    public static BusinessException create(String statusCode, String errorCode, String message) {
    	return create(statusCode, errorCode, message, null);
    }
    
    public static BusinessException create(String statusCode, String errorCode, String message, Exception e) {
        BusinessException be = e==null?new BusinessException(message):new BusinessException(message, e);
        be.errorCode = errorCode;
        be.statusCode = statusCode;
        return be;
    }
}