public class AssetInformationToAssetGenerationUtil {

    private static Map<String, String> assetInformationToAssetFieldMap = new Map<String, String>();

    static
    {                      
        Map<String, AssetInformationToAssetFields__c> assetInformationToAssetFields = AssetInformationToAssetFields__c.getAll();
        
        for (String assetInformationField: assetInformationToAssetFields.keySet()) {
            AssetInformationToAssetFields__c assetInformationToAssetField = AssetInformationToAssetFields__c.getInstance(assetInformationField);
            assetInformationToAssetFieldMap.put(assetInformationToAssetField.Asset_Information_Field__c, assetInformationToAssetField.Asset_Field__c);           
        }               
    }
    
    public static Set<String> getAssetInformationFields() { 
        return assetInformationToAssetFieldMap.keySet();
    }    
    
    public static List<String> getAssetFields() {
        return assetInformationToAssetFieldMap.values();
    }       
    
    public static String getAssetInformationFieldsString() {    
        String fields = '';
        for (String field : getAssetInformationFields()) {
            fields += ', ' + field;
        }
        return fields; 
    }

    public static String getAssetFieldsString() {    
        String fields = '';
        for (String field : getAssetFields()) {
            fields += ', ' + field;
        }
        return fields; 
    }    
    
    public static String getAssetInformationFieldMapTo(String assetInformationField) {
        return assetInformationToAssetFieldMap.get(assetInformationField);
    } 

}