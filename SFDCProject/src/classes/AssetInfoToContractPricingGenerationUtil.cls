public class AssetInfoToContractPricingGenerationUtil {

    private static Map<String, String> assetInfoToContractPricingFieldMap = new Map<String, String>();

    static
    {                      
        Map<String, AssetInfoToContractPricingFields__c> assetInfoToContractPricingFields = AssetInfoToContractPricingFields__c.getAll();
        
        for (String assetInformationField: assetInfoToContractPricingFields.keySet()) {       
            AssetInfoToContractPricingFields__c assetInfoToContractPricingField = AssetInfoToContractPricingFields__c.getInstance(assetInformationField);
            assetInfoToContractPricingFieldMap.put(assetInfoToContractPricingField.Asset_Information_Field__c, assetInfoToContractPricingField.Contract_Pricing_Field__c);           
        }               
    }
    
    public static Set<String> getAssetInformationFields() { 
        return assetInfoToContractPricingFieldMap.keySet();
    }    
    
    public static List<String> getContractPricingFields() {
        return assetInfoToContractPricingFieldMap.values();
    }       
    
    public static String getAssetInformationFieldsString() {    
        String fields = '';
        for (String field : getAssetInformationFields()) {
            fields += ', ' + field;
        }
        return fields; 
    }

    public static String getContractPricingFieldsString() {    
        String fields = '';
        for (String field : getContractPricingFields()) {
            fields += ', ' + field;
        }
        return fields; 
    }    
    
    public static String getAssetInformationFieldMapTo(String assetInformationField) {
        return assetInfoToContractPricingFieldMap.get(assetInformationField);
    } 

}