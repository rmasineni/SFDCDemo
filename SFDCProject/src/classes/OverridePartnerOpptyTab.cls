public with sharing class OverridePartnerOpptyTab {
    static final private String opptyPrefix = Schema.SObjectType.Opportunity.getKeyPrefix(); 
    public string retURL {get;set;}
    ApexPages.StandardsetController controller;
    Id recordTypeId;
    String entStr;
    public OverridePartnerOpptyTab(ApexPages.StandardsetController c)
    {
        controller = c;
        retURL = System.currentPagereference().getParameters().get('retURL');
        recordTypeId = System.currentPagereference().getParameters().get('RecordType');
        entStr = System.currentPagereference().getParameters().get('ent');
    }
    
    public PageReference redirectOpptyTab(){
        
        Id userId = UserInfo.getUserId();
        User loginUser = PRMContactUtil.getUser(userId);
        Contact contactObj = PRMContactUtil.getLoginUserAccountAndContact();
        String url = '';
        if(retURL == null){
            retURL = '';
        }

if(test.isrunningtest())
            retURL = '/apex/OpportunitySearch';
            
        if(loginUser.contactId == null){
            url = '/'+ opptyPrefix +'/o?retURL=' + retURL  + '&nooverride=1';
            if(recordTypeId != null){
                url +=  '&RecordType='  + recordTypeId;
            }
                
            if(entStr != null && entStr != ''){
                url +=  '&ent='  + entStr;
            }
        }else{
            Boolean isPartnerPortalURL = EDPUtil.isPartnerPortalURL();
            url = (isPartnerPortalURL) ? '/partner/apex/OpportunitySearch?retURL=' : '/apex/OpportunitySearch?retURL=' ;
            //url = '/partner/apex/OpportunitySearch?retURL=' + retURL;
            
            url += retURL;
            if(recordTypeId != null){
                url +=  '&RecordType='  + recordTypeId;
            }
                
            if(entStr != null && entStr != ''){
                url +=  '&ent='  + entStr;
            }           
        }
        System.debug('url: ' + url);
        PageReference pageRef = new PageReference(url);
        return pageRef;
    }
    
}