public class LeadOverride {
  private Boolean systemAdmin;
  public string relationshipID ;
  public boolean isGoogleAddressProfile {get;set;}
  public boolean isNewLeadPageProfile {get;set;}
  public Lead leadObj {get;set;}
  public String retURL = '';
  private String displayName;
  String recordTypeId = '';
  Public LeadOverride(ApexPages.StandardController controller){
    leadObj = (Lead) controller.getRecord();
    if(leadObj.id!=null){
    leadObj=[select id,firstName,lastName,RecordTypeId from lead where id=:leadObj.id];
    displayName = leadObj.firstName == null ? '' : (leadObj.firstName + ' ');
        displayName = displayName + (leadObj.lastName == null ? '' : leadObj.lastName);
    }
    retURL = ApexPages.currentPage().getParameters().get('retURL');
    if(leadObj != null && leadObj.RecordTypeId != null){
      recordTypeId = leadObj.RecordTypeId;
    }else{
      recordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
      if(recordTypeId != null){
        leadObj.RecordTypeId = recordTypeId;
      }
    }
    systemAdmin = false;
    isGoogleAddressProfile = false;
    isNewLeadPageProfile=false;
    //getUserProfile();
    checkUserProfile();
  }
  
  public void getUserProfile(){
        Profile p = [select Id, name from Profile where id = :UserInfo.getProfileId()];
        if(p.name == 'System Administrator'){
            this.systemAdmin = true;
        }
        System.debug('this.systemAdmin: ' + this.systemAdmin);
    }
  
  public PageReference goRedirectLeadEdit() {
       PageReference ref = null;
        String editPageParaeters = '?retURL=' + retURL + '&nooverride=1';
    if(recordTypeId != null && recordTypeId != ''){
       editPageParaeters += '&RecordType=' + recordTypeId;
    }        
        editPageParaeters += '&ent=Lead';
        
        if(isGoogleAddressProfile == true ){
      String editURL = customEditPage + editPageParaeters;
      if(leadObj != null && leadObj.Id != null){
             editURL += '&id=' + leadObj.Id ;
           }
      ref = new PageReference(editURL);
      ref.setRedirect(true);          
        }        
        else{
      String editURL = standardEditPage + editPageParaeters;
      ref = new PageReference(editURL);
      ref.setRedirect(true);
        }
        if(isNewLeadPageProfile){
          String newPageURL = customLeadPage + editPageParaeters;
          ref = new PageReference(newPageURL);
      ref.setRedirect(true);  
        }
        return ref;
     }
  public PageReference goRedirectCustomLeadEdit() {
    PageReference ref = null;
    if(isNewLeadPageProfile&&Userinfo.getusertype()!='PowerPartner'){
      String EditPageURL = CustomLeadEditPage;
          ref = new PageReference(EditPageURL);
      ref.setRedirect(true);  
    }
    else if(userinfo.getusertype()=='PowerPartner'){
      String EditPageURL = customPPEditPage;       
          ref = new PageReference(EditPageURL);
      ref.setRedirect(true);       
    }
    else{
      String EditPageURL = '/'+leadObj.id+'?nooverride=1';
      ref = new PageReference(EditPageURL);
      ref.setRedirect(true);
    }
    return ref;
  }
  private String customEditPage {
         get {
           String editPageURL = '';
           editPageURL =  '/apex/EditLead';
      return editPageURL;
        }
        set;
    }
    private String customPPEditPage {
         get {
           String editPPPageURL = '';
           editPPPageURL =  '/apex/customizeLeadDetailPage?id='+leadObj.id;
      return editPPPageURL;
        }
        set;
    }
  private String customLeadPage {
         get {
           String leadPageURL = '';
           leadPageURL =  '/apex/LeadPage';
      return leadPageURL;
        }
        set;
    }  
  private String standardEditPage {
         get {
           String editPageURL = '';
           editPageURL =  '/00Q/e';
           if(leadObj != null && leadObj.Id != null){
             editPageURL =   '/' + leadObj.Id + '/e';
           }
      return editPageURL;
        }
        set;
    }
  private String CustomLeadEditPage {
         get {
           String leadPageEditURL = '';
           leadPageEditURL =  '/apex/LeadPage?id='+leadObj.id+'&LeadEdit=false&object=Lead&objectId='+leadObj.id+'&objectName='+EncodingUtil.urlEncode(displayName,'UTF-8');           
      return leadPageEditURL;
        }
        set;
    }
  public void checkUserProfile(){
    Id profileId = UserInfo.getProfileId();
    String tempProfileId = profileId;
    tempProfileId = tempProfileId.substring(0,15);
    String profileLike = '%'+ tempProfileId +'%';
    System.debug('profileLike: ' + profileLike);
    List<Google_Address_Profile__c> googleAddressProfileList = [Select Id, profile_Id__c from Google_Address_Profile__c where profile_Id__c like :profileLike];
    if(googleAddressProfileList != null && googleAddressProfileList.size() > 0){
      if(UserInfo.getName() != 'Edward Smith')
        isGoogleAddressProfile = true;
    }    
    List<Lead_Custom_Page_Profiles__c> leadPageProfileList=[Select Id, profile_Id__c from Lead_Custom_Page_Profiles__c where profile_Id__c like :profileLike];
    if(leadPageProfileList != null && leadPageProfileList.size() > 0){
      if(UserInfo.getName() != 'Edward Smith')
        isNewLeadPageProfile = true;
    }  
    System.debug('isGoogleAddressProfile: ' + isGoogleAddressProfile);
  }
}