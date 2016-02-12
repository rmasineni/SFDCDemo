public class AddressServiceDto {
    
    public static String Status_StandardizationRequired = 'Standardization Required';
    public static String Status_DetailsRequired = 'Details Required';
    public static String Status_Standardized = 'Standardized';
    public static String Status_StandardizedByUI = 'Standardized by UI';
    public static String Status_StandardizationNoMatch = 'Standardization No Match';
    public static String Status_StandardizationMissingAddress = 'Standardization Missing Address';
    public static String Status_StandardizationError = 'Standardization Error';
    public static String Status_StandardizationOverridden = 'Standardization Overridden';
    
    public static String Status_DrivingDetailsToBeCalculated = 'Driving Details to be Calculated';
    public static String Status_DrivingDetailsCalculated = 'Driving Details Calculated';
    public static String Status_DrivingDetailsCalculationError = 'Driving Details Calculation Error';
	public static String Status_DrivingDetailsMissingInstallBranch = 'Install Branch Missing';
    public static String Status_DrivingDetailsAddressMissing = 'Address Missing';
    public static String Status_DrivingDetailsNoMatch = 'Driving Details No Match';
    
    public class AddressStandardizationLeadsJob implements Queueable, Database.AllowsCallouts {
        public List<Id> leadIds {get;set;}
        
        public AddressStandardizationLeadsJob(List<Id> leadIds) {
            this.leadIds = leadIds;
        }
        
        public void execute(QueueableContext qc) {
            Sf.addressService.standardizeLeadsAddress(leadIds);
        }
    }
    
    public class AddressStandardizationAccountsJob implements Queueable, Database.AllowsCallouts {
        public List<Id> accountIds {get;set;}
        
        public AddressStandardizationAccountsJob(List<Id> accountIds) {
            this.accountIds = accountIds;
        }
        
        public void execute(QueueableContext qc) {
            Sf.addressService.standardizeAccountsAddress(accountIds);
        }
    }

    public class DrivingDetails {
        public String origin {get;set;}
        public String destination {get;set;}
        public Datetime departureTime {get;set;}
        public String distanceText {get;set;}
        public Integer distance {get;set;}
        public String drivingTimeText {get;set;}
        public Integer drivingTime {get;set;}
        public String status {get;set;}
        public String message {get;set;}
        
        public DrivingDetails () {
            //default
        }
            
        public DrivingDetails (String origin, String destination) {
        	this.origin = origin;
            this.destination = destination;
        }
    }

    public class Address {
        public String street {get;set;}
        public String city {get;set;}
        public String county {get;set;}
        public String state {get;set;}
        public String postalCode {get;set;}
        public String country {get;set;}
        public String addressToken {get;set;}
        
        public Address () {
            //default
        }
            
        public Address (String street, String city, String state, String postalCode) {
        	this(street, city, state, postalCode, null);
        }
            
        public Address (String street, String city, String state, String postalCode, String country) {
            this.street = street;
            this.city = city;
            this.state = state;
            this.postalCode = postalCode;
            this.country = country;
        }
    }

    public class AddressAdditionalInfo {
        public Decimal latitude {get;set;}
        public Decimal longitude {get;set;}
        public String timeZone {get;set;}
        public String areaCode {get;set;}
        public Boolean hasDaylightSavings {get;set;}
        public String congressionalDistrictNumber {get;set;}
        public String stateLegislativeLower {get;set;}
        public String stateLegislativeUpper {get;set;}
    }

    public class StandardizeAddressResponse {
        public String status {get;set;}
        public String cdyneMessage {get;set;}
        public String googleMapsMessage {get;set;}
        public String source {get;set;}
        public String confidenceLevel {get;set;}
        public Address address {get;set;}
    	public AddressAdditionalInfo addressAdditionalInfo {get;set;}
        
        public StandardizeAddressResponse() {
        }
        
        public StandardizeAddressResponse(CdyneResponse cdyneResponse) {
            cdyneMessage = cdyneResponse.responseMessage;
            address = new Address(cdyneResponse.PrimaryDeliveryLine,
                                 cdyneResponse.CityName,
                                 cdyneResponse.StateAbbreviation,
                                 cdyneResponse.ZipCode,
                                 cdyneResponse.Country);
            address.county = cdyneResponse.county;
            addressAdditionalInfo = new AddressAdditionalInfo();
            addressAdditionalInfo.latitude = cdyneResponse.geoLocationInfo.AvgLatitude;
            addressAdditionalInfo.longitude = cdyneResponse.geoLocationInfo.AvgLongitude;
            addressAdditionalInfo.timeZone = cdyneResponse.geoLocationInfo.TimeZone;
            addressAdditionalInfo.hasDaylightSavings = cdyneResponse.geoLocationInfo.HasDaylightSavings;
            addressAdditionalInfo.areaCode = cdyneResponse.geoLocationInfo.AreaCode;
            addressAdditionalInfo.congressionalDistrictNumber = cdyneResponse.legislativeInfo.CongressionalDistrictNumber;
            addressAdditionalInfo.stateLegislativeLower = cdyneResponse.legislativeInfo.StateLegislativeLower;
            addressAdditionalInfo.stateLegislativeUpper = cdyneResponse.legislativeInfo.StateLegislativeUpper;
        }
    }
    
    public class CdyneRequest {
        public String LicenseKey {get;set;}
        public String PrimaryAddressLine {get;set;}
        public String SecondaryAddressLine {get;set;}
        public String CityName {get;set;}
        public String State {get;set;}
        public String ZipCode {get;set;}
        public Boolean ReturnCaseSensitive {get;set;}
        public Boolean ReturnCensusInfo {get;set;}
        public Boolean ReturnCityAbbreviation {get;set;}
        public Boolean ReturnGeoLocation {get;set;}
        public Boolean ReturnLegislativeInfo {get;set;}
        public Boolean ReturnMailingIndustryInfo {get;set;}
        public Boolean ReturnResidentialIndicator {get;set;}
        public Boolean ReturnStreetAbbreviated {get;set;}
        
        public CdyneRequest() {
        	ReturnCaseSensitive = true;
            ReturnCensusInfo = true;
            ReturnCityAbbreviation = true;
            ReturnGeoLocation = true;
            ReturnLegislativeInfo = true;
            ReturnMailingIndustryInfo = true;
            ReturnResidentialIndicator = true;
            ReturnStreetAbbreviated = true;
        }

        public CdyneRequest(AddressServiceDto.Address address) {
            this(); //This is required to initialize all boolean variables
            PrimaryAddressLine = address.street;
            CityName = address.city;
            State = address.state;
            ZipCode = address.postalCode;
        }
    }
    
    public class CdyneResponse {
        public String responseMessage {get;set;}
        public Integer ReturnCode {get;set;}
        public String PrimaryDeliveryLine {get;set;}
        public String SecondaryDeliveryLine {get;set;}
        public String CityName {get;set;}
        public String StateAbbreviation {get;set;}
        public String ZipCode {get;set;}
        public String Country {get;set;}
        public String County {get;set;}
        public CdyneLegislativeInfo legislativeInfo {get{if(legislativeInfo==null) legislativeInfo = new CdyneLegislativeInfo();return legislativeInfo;}set;}
        public CdyneGeoLocationInfo geoLocationInfo {get{if(geoLocationInfo==null) geoLocationInfo = new CdyneGeoLocationInfo();return geoLocationInfo;}set;}
    }
    
    public class CdyneLegislativeInfo {
        public String CongressionalDistrictNumber {get;set;}
        public String StateLegislativeLower {get;set;}
        public String StateLegislativeUpper {get;set;}
    }

    public class CdyneGeoLocationInfo {
        public String AreaCode {get;set;}
        public Decimal AvgLatitude {get;set;}
        public Decimal AvgLongitude {get;set;}
        public Decimal FromLatitude {get;set;}
        public Decimal FromLongitude {get;set;}
        public Boolean HasDaylightSavings {get;set;}
        public String TimeZone {get;set;}
        public Decimal ToLatitude {get;set;}
        public Decimal ToLongitude {get;set;}
    }
    
    public class GoogleMapsTimezoneResponse {
        public String status {get;set;}
        public String timeZoneId {get;set;}
        public String timeZoneName {get;set;}
        public Integer dstOffset {get;set;}
        public Integer rawOffset {get;set;}
        
    }
}