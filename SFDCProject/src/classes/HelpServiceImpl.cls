public class HelpServiceImpl extends BaseClass {
	
    public Id findArtileId(String mode, String section, String target) {
        List<Help__kav> helps = [
            select 
                IsVisibleInApp,
                IsVisibleInCsp,
                IsVisibleInPkb,
                IsVisibleInPrm,
                KnowledgeArticleId
            from Help__kav 
            where PublishStatus = 'Online' and language = 'en_US' and IsLatestVersion = true and Section__c = :section and Target__c = :target
        ];
        
 		return helps.isEmpty()?null:helps.get(0).KnowledgeArticleId;
    }
}