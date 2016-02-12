@isTest(SeeAllData=true)
public with sharing class Test_AssetInfoToAssetGenerationUtil {
    public static testmethod void Test_AssetInfoToAssetGenerationUtil(){
        Test.StartTest();
        AssetInformationToAssetGenerationUtil assetinfo = new AssetInformationToAssetGenerationUtil();
        Set<String> assetset = AssetInformationToAssetGenerationUtil.getAssetInformationFields();
         List<String> assetlist = AssetInformationToAssetGenerationUtil.getAssetFields();
         AssetInformationToAssetGenerationUtil.getAssetInformationFieldsString();
         AssetInformationToAssetGenerationUtil.getAssetFieldsString();
         Test.Stoptest();
        
    }

}