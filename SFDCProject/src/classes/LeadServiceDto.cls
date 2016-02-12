global class LeadServiceDto {

    global class CreateLeadResponse {
        public String status {get;set;}
        public String errorCode {get;set;}
        public String message {get;set;}
        public String leadId {get;set;}
        public String prospectId {get;set;}
        public Long expires {get;set;}
        public String signature{get;set;}
        public String leadOrgLocationId{get;set;}
    
        //We don't want the lead to get serialized into json when we return the response
        //as that would expose all internal field api names etc, which makes it tight coupling
        public transient Lead lead {get;set;}
        public transient Map<String, Object> restReq {get;set;}
        
        public void setError(String message) {
            setError('GENERIC_EXCEPTION', message);
        }
        
        public void setError(String errorCode, String message) {
            status = 'error';
            this.message = message;
            this.errorCode = errorCode;
        }
    }    
}