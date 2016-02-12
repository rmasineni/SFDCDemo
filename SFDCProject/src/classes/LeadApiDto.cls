global class LeadApiDto {
	
	public static final String RestField_leadOrgLocationId = 'leadOrgLocationId';	
	public static final String RestField_leadOrgLocationName = 'leadOrgLocationName';	
	public static final String RestField_consultationDateTime = 'consultationDateTime';

    public static Map<String, String> getLeadApiLeadFieldMapping() {
	   return RestServiceDto.getFieldMapping('Lead Api', 'Lead');
    }

    public static List<String> getLeadApiLeadRequiredFields() {
		List<String> requiredFields = RestServiceDto.getRequiredFields('Lead Api', 'Lead');
       	requiredFields.add('customerPrimaryPhone|customerEmail');
       
        return requiredFields;
    }
}