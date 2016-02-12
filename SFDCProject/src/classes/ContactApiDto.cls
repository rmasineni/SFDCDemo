global class ContactApiDto {
    public static Map<String, String> getContactApiContactFieldMapping() {
	    return RestServiceDto.getFieldMapping('Contact Api', 'Contact');
    }
    
    public static List<String> getContactApiContactRequiredFields() {
        return RestServiceDto.getRequiredFields('Contact Api', 'Contact');
    }
}