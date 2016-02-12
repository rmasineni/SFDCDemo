public with sharing class OpportunityOverride {
    public opportunity opptyObj;    
    public boolean isNewLeadPageProfile;
    private String displayName;
    Public OpportunityOverride(ApexPages.StandardController controller){
        opptyObj = (Opportunity) controller.getRecord();
        if(opptyObj.id!=null){
        opptyObj=[select id,name,RecordTypeId from opportunity where id=:opptyObj.id];
        displayName = opptyObj.name == null ? '' : (opptyObj.name);        
        }
        isNewLeadPageProfile=false;
        checkUserProfile();
    }
     private String customPPEditPage {
         get {
            String editPPPageURL = '';
            editPPPageURL =  '/apex/PartnerOpportunityCreate?id='+opptyObj.id;
            return editPPPageURL;
        }
        set;
    }
    public PageReference goRedirectCustomOpptyEdit() {
        PageReference ref = null;
        if(isNewLeadPageProfile&&Userinfo.getusertype()!='PowerPartner'){
            String EditPageURL = CustomOpptyEditPage;
            ref = new PageReference(EditPageURL);
            ref.setRedirect(true);  
        }
        else if(userinfo.getusertype()=='PowerPartner'){
            String EditPageURL = customPPEditPage;
            ref = new PageReference(EditPageURL);
            ref.setRedirect(true);          
        }
        else{
            String EditPageURL = '/'+opptyObj.id+'?nooverride=1';
            ref = new PageReference(EditPageURL);
            ref.setRedirect(true);
        }
        return ref;
    }
    private String CustomOpptyEditPage {
         get {
            String OpptyPageEditURL = '';
            OpptyPageEditURL =  '/apex/OpportunityPage?id='+opptyObj.id+'&OpptyEdit=false&object=Opportunity&objectId='+opptyObj.id+'&objectName='+EncodingUtil.urlEncode(displayName,'UTF-8');             
            return OpptyPageEditURL;
        }
        set;
    }
    public void checkUserProfile(){
        Id profileId = UserInfo.getProfileId();
        String tempProfileId = profileId;
        tempProfileId = tempProfileId.substring(0,15);
        String profileLike = '%'+ tempProfileId +'%';                   
        List<Lead_Custom_Page_Profiles__c> leadPageProfileList=[Select Id, profile_Id__c from Lead_Custom_Page_Profiles__c where profile_Id__c like :profileLike];
        if(leadPageProfileList != null && leadPageProfileList.size() > 0){
            if(UserInfo.getName() != 'Edward Smith')
                isNewLeadPageProfile = true;
        }           
    }

}