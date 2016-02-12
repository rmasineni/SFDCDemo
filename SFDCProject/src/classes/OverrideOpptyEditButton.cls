public with sharing class OverrideOpptyEditButton {

static final private String Opportunity = Schema.SObjectType.Opportunity.getKeyPrefix(); 
public string retURL {get;set;}
    ApexPages.StandardController controller;
    Id recordTypeId;
    String entStr;
    String EditRetURL;
public OverrideOpptyEditButton(ApexPages.StandardController c)
    {
        controller = c;
        retURL = System.currentPagereference().getParameters().get('retURL');
        recordTypeId = System.currentPagereference().getParameters().get('RecordType');
        entStr = System.currentPagereference().getParameters().get('ent');
    }
    /*
public PageReference redirectEditPage(){

        Id userId = UserInfo.getUserId();
        User loginUser = PRMContactUtil.getUser(userId);
        String url = '';
        if(retURL == null){
            retURL = '';
            
        }        
        if(loginUser.contactId == null){
            if(retURL!='')            
            url = retURL.substring(0,19)+'/e?retURL=' + retURL  + '&nooverride=1';                     
            if(recordTypeId != null){
                url +=  '&RecordType='  + recordTypeId;
            }
                
            if(entStr != null && entStr != ''){
                url +=  '&ent='  + entStr;
            }
        }else{
            system.debug('reURL:' + retURL);
            EditRetURL = retURL.substring(9, 24);
            system.debug('EditRetURL:' + EditRetURL);
               url = '/partner/apex/NewCustomOpportunity?OpptyId=' + EditRetURL;
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
*/
public PageReference redirectEditPage(){
       Id userId = UserInfo.getUserId();
       User loginUser = PRMContactUtil.getUser(userId);
       PageReference ref = null;
        String editPageParaeters = '?retURL=' + retURL + '&nooverride=1';
        if(recordTypeId != null && recordTypeId != ''){
            editPageParaeters += '&RecordType=' + recordTypeId;
        }        
        editPageParaeters += '&ent=Opportunity';
        
        if(loginUser.ContactId !=null ){
        /*    String editURL = customEditPage + editPageParaeters;
            if(controller != null && controller.getId() != null){
                editURL += '&id=' + controller.getId() ;
            }*/
            String editURL; 
            if(controller != null && controller.getId() != null){
                editURL = customEditPage + '?OpptyId=' + controller.getId() + '&gmaps=1' ;
            }
            ref = new PageReference(editURL);
            ref.setRedirect(true);          
        }else{
            String editURL = standardEditPage + editPageParaeters;
            ref = new PageReference(editURL);
            ref.setRedirect(true);
        }
        return ref;
}

private String customEditPage {
         get {
            String editPageURL = '';
            //editPageURL =  '/partner/apex/NewCustomOpportunity';
            editPageURL =  '/apex/NewCustomOpportunity';
            return editPageURL;
        }
        set;
    }
        
    private String standardEditPage {
         get {
            String editPageURL = '';
            editPageURL =  '/006/e';
            if(controller != null && controller.getID() != null){
                editPageURL =   '/' + controller.getId() + '/e';
            }
            return editPageURL;
        }
        set;
    }
}