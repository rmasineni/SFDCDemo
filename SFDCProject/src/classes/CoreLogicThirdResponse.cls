public class CoreLogicThirdResponse {
    
    public cls_AdminLocation AdminLocation;
    public cls_GeneralPropertyTax GeneralPropertyTax;
    public cls_Location Location;
    
   public class cls_AdminLocation {
        public String cityClass;	
        public String cityName;	
        public String cityType;	
        public String countyName;	
        public String gnisfeatureID;	
        public String incorporationFlag;	
        public String placeFIPSCode;	
        public String stateCountyFIPSCode;	
        public String stateName;	
    }
   public class cls_GeneralPropertyTax {
        public String dateAnnexed;	
        public String dateUpdated;	
        public String dateVerified;	
        public Integer distanceTaxBoundaryFeet;	
        public String genPropTaxAuthorityFIPSCode;	
        public String genPropTaxAuthorityName;	
        public String genPropTaxRendition;	
        public String genPropTaxRenditionFIPSCode;	
        public String intangibles;	
        public String schoolDistrictID;	
        public String schoolDistrictName;	
        public String schoolDistrictType;	
        public String stateSchoolDistrictNumericID;	
        public String townshipFIPSCode;	
        public String townshipName;	
    }
   public class cls_Location {
        public Double latitude;	
        public Double longitude;	
    }
    
}