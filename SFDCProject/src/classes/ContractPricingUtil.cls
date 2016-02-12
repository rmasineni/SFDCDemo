public class ContractPricingUtil {
    
    
    public static List<Asset_Information__c> getAssetInformationForProposalForPricing(String fieldsString, Id proposalId)
    {
        String assetInformationSelectStatement = 'select Id, Name' + fieldsString + ' from Asset_Information__c where ProposalName__r.Id = \'' + proposalId + '\'';      
        return (List<Asset_Information__c>)Database.query(assetInformationSelectStatement);          
    } 
    
    
    public static Contract_Pricing__c createContractPricing(Set<String> assetInformationFields, ServiceContract serviceContract, Asset_Information__c assetInformation)
    {
        Contract_Pricing__c contractPricing = new  Contract_Pricing__c (Service_Contract__c = serviceContract.Id);
        
        for (String assetInformationField: assetInformationFields) {
            String contractPricingField = AssetInfoToContractPricingGenerationUtil.getAssetInformationFieldMapTo(assetInformationField);
            Object assetInformationFieldValue = assetInformation.get(assetInformationField);
            Object contractPricingFieldValue = contractPricing.get(contractPricingField);
            if(assetInformationFieldValue  == null)
                contractPricing.put(contractPricingField, null);
            else
                contractPricing.put(contractPricingField, assetInformationFieldValue);
        }
   
        return contractPricing;
    }
    
     public static Contract_pricing__c createInstallationPricing( ServiceContract parentServiceContract, proposal__c proposalobj )
    {
     
        return new Contract_Pricing__c(Service_Contract__c = parentServiceContract.Id, Asset_Type__c = 'Installation', 	Total_Price__c = proposalobj.Installation_Price__c , Tax_on_Installation__c = proposalObj.Tax_on_Installation__c,  Count__c = 1 );

    }

}