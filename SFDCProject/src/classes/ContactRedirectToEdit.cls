public class ContactRedirectToEdit {
    public string contactId ;
    private Boolean systemAdmin = false;
    private Contact contactObj;     
    private boolean isaee;
    public Boolean isPartnerUser {get;set;} 
    public ContactRedirectToEdit(){
        initialize();
    }

    public ContactRedirectToEdit(ApexPages.StandardController controller) {
        contactObj = (Contact) controller.getRecord();
        if (contactId == null) {
            contactId = contactObj.Id;
        }
        initialize();
    }
    
    private void initialize(){
        User userObj = PRMContactUtil.getLoginUser();
        isPartnerUser = false;
        if(userObj != null && userObj.ContactId != null){
            isPartnerUser = true;
        }
        if(userObj != null && userObj.User_Division_Custom__c != null){
            isaee= String.valueof(userObj.User_Division_Custom__c).EqualsIgnoreCase(System.label.AEE_label)?true:false;     
        }      
    }

    private String editURL {
        get {
            return '/' + contactId + '/e?nooverride=1' +  '&retURL=%2F' + contactId ;
        }
        set;
    }  

    private String customEditURL {
        get {
            String communitybase=isaee?'/aeepartner':'/partner';
            return communitybase+'/apex/NewCustomerContactOverridden?contactId=' + contactId + '&retURL=%2F' + contactId ;
        }
        set;
    } 

    public PageReference getContactEditPage() {
        PageReference ref = null;
        System.debug('isPartnerUser: ' + isPartnerUser);
        System.debug('customEditURL: ' + customEditURL);
        if(isPartnerUser == true ){
            ref = new PageReference(customEditURL);
            ref.setRedirect(true);      
        }else{
            ref = new PageReference(editURL);
            ref.setRedirect(true);          
        }
        return ref;
    }
}