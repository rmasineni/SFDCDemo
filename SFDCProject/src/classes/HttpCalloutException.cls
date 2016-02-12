public class HttpCalloutException extends SystemException {
    public BaseClassDto.HttpDetails httpDetails {get;set;}
    
    public HttpCalloutException(BaseClassDto.HttpDetails httpDetails) {
        this.httpDetails = httpDetails;
    }
     
    public HttpCalloutException(BaseClassDto.HttpDetails httpDetails, Exception e) {
        super(e);
        this.httpDetails = httpDetails;
    }

    public String toString() {
        return httpDetails.getDetails();
    }
}