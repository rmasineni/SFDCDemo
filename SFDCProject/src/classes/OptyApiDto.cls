public class OptyApiDto {
    public static Map<String, String> getOptyApiOptyFieldMapping() {
	   return RestServiceDto.getFieldMapping('Opty Api', 'Opportunity');
    }

    public static Map<String, String> getOptyApiContactFieldMapping() {
	    return RestServiceDto.getFieldMapping('Opty Api', 'Contact');
    }

    public static Map<String, String> getOptyApiContactRoleFieldMapping() {
        return new Map<String, String>{'role'=>'Role','primary'=>'IsPrimary'};
    }

    public static Map<String, String> getOptyApiAccountFieldMapping() {
	    return RestServiceDto.getFieldMapping('Opty Api', 'Account');
    }

    public static Map<String, String> getOptyApiPaymentFieldMapping() {
	    return RestServiceDto.getFieldMapping('Payment Api', 'Payment_Transaction__c');
    }
    
    public static Map<String, String> getOptyApiContactCreditFieldMapping() {
	    return RestServiceDto.getFieldMapping('Credit Api', 'Customer_Credit__c');
    }

    public static List<String> getOptyApiContactRequiredFields() {
	    return RestServiceDto.getRequiredFields('Opty Api', 'Contact');
    }
    
    public static List<String> getOptyApiContactRoleRequiredFields() {
        return new String[]{'role'};
    }
}