public with sharing class OverrideFSDispatch {
     static final private String FSDispatchesSearchPrefix = Schema.SObjectType.FS_Dispatch__c.getKeyPrefix();
     public string retURL {get;set;}
         ApexPages.StandardController controller;
         Id recordTypeId;
         String entStr;
     public OverrideFSDispatch(ApexPages.StandardController c){
         controller = c;
         retURL = System.currentPagereference().getParameters().get('retURL');
         recordTypeId = System.currentPagereference().getParameters().get('RecordType');
         entStr = System.currentPagereference().getParameters().get('ent');
    }
     public PageReference redirectFSDispatchTab(){
         String redirectUrl = System.URL.getCurrentRequestUrl().getPath();
         Boolean isPartnerPortalURL = false;
        
        if(redirectUrl.startsWith(' /partner ')){
          isPartnerPortalURL = true;
        }
      Id userId = UserInfo.getUserId();
         User loginUser = PRMContactUtil.getUser(userId);
         String url = '';
         if(retURL == null){
            retURL = '';  
    }
         if(loginUser.contactId == null){
                url = '/'+ FSDispatchesSearchPrefix +'/e?retURL=' + retURL  + '&nooverride=1';
           if(recordTypeId != null){
                url +=  '&RecordType='  + recordTypeId;
            }
         if(entStr != null && entStr != ''){
                url +=  '&ent='  + entStr;
            }
            
          }else{

            url = (isPartnerPortalURL) ? '/partner/apex/FSDispatchesSearch?retURL=' : '/apex/FSdispatchesSearch?retURL=' ;
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