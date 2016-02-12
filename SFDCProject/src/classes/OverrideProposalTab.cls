public with sharing class OverrideProposalTab {

    static final private String proposalPrefix = Schema.SObjectType.Proposal__c.getKeyPrefix(); 
    public string retURL {get;set;}
    ApexPages.StandardController controller;
    Id recordTypeId;
    String entStr;
    public OverrideProposalTab(ApexPages.StandardController c){
        controller = c;
        retURL = System.currentPagereference().getParameters().get('retURL');
        recordTypeId = System.currentPagereference().getParameters().get('RecordType');
        entStr = System.currentPagereference().getParameters().get('ent');
    }
    public PageReference redirectProposalTab(){

        String redirectUrl = System.URL.getCurrentRequestUrl().getPath();
        Boolean isPartnerPortalURL = false;
        if(redirectUrl.startsWith('/partner')){
            isPartnerPortalURL = true;
        }
    
        Id userId = UserInfo.getUserId();
        User loginUser = PRMContactUtil.getUser(userId);
        String url = '';
        if(retURL == null){
            retURL = '';
        }
        
        if(loginUser.contactId == null){
            url = '/'+ proposalPrefix +'/o?retURL=' + retURL  + '&nooverride=1';
          if(recordTypeId != null){
                url +=  '&RecordType='  + recordTypeId;
            }
                
            if(entStr != null && entStr != ''){
                url +=  '&ent='  + entStr;
            }
        }else{

            url = (isPartnerPortalURL) ? '/partner/apex/proposalSearchoffset?retURL=' : '/apex/proposalSearchoffset?retURL=' ;
            url += retURL;

            //url = '/partner/apex/proposalSearch?retURL=' + retURL;
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