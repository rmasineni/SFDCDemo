public interface AddressService {

    /**
     * Calculates the as-the-crow-flies (http://en.wikipedia.org/wiki/As_the_crow_flies) distance between
     * two geographical locations in miles.
     * 
     * It uses the Haversine formula (http://en.wikipedia.org/wiki/Haversine_formula) to calculate the distance, and is
     * the same formula used by Salesforce for its Distance soql formula implementation
     * 
     * The distance calculated is only approximate and should only be used for non-critical applications.
     */
    Decimal calculateDistance(Decimal fromLat, Decimal fromLng, Decimal toLat, Decimal toLng);
    
    /**
     * Checks if Address standardization is enabled or disabled in the Custom Settings.
     * 
     * To enable, look into the Settings__c custom settings.
     */
    Boolean isAddressStandardizationForLeadsEnabled();
    Boolean isAddressStandardizationForAccountsEnabled();
    
    /**
     * Implements the logic to handle the lead trigger invocation. This process needs, before insert, after insert, 
     * before update, after update events.
     */
    void handleLeadsTrigger();
    
    /**
     * Standardizes the address in the specified leads as per current address status.
     */
    void standardizeLeadsAddress(List<Id> leadIds);
	void standardizeLeadsAddressWithoutSave(Lead lead);
    
    /**
     * Implements the logic to handle the account triggers invocation.
     */
    void handleAccountsTrigger();

    /**
     * Standardizes the address in the specified accounts as per current address status.
     */
    void standardizeAccountsAddress(List<Id> accountIds);
	
    /**
     * Standardizes the given generic address and returns the response. It uses Google Maps (primary) 
     * and CDyne (secondary) source to standardize the address, retrieve additional data elements
     * with address.
     */ 
    AddressServiceDto.StandardizeAddressResponse standardizeAddress(AddressServiceDto.Address address);
    
    Boolean isAddressUpdated(Account oldAccount, Account newAccount);
    
    AddressServiceDto.DrivingDetails calculateDrivingDetails(AddressServiceDto.DrivingDetails drivingDetails);
    List<AddressServiceDto.DrivingDetails> calculateDrivingDetails(List<AddressServiceDto.DrivingDetails> drivingDetails);
    List<AddressServiceDto.DrivingDetails> calculateDrivingDetails(String origin, List<String> destinations);
    
}