public class PRMContactViewController {

    Id contactId;
    String syncModes;
    public Contact contactObj{get;set;}
    public String partnerSite {get;set;}
    public boolean isSPOCUser {get; set;}
     public boolean isAEEUser;
    
    public PRMContactViewController(){
        syncModes = '0';
        initializeLoginUser();
        
        isSPOCUser = false;
        isAEEUser = false;
        getIsAEEUser();        
        Set<String> spocUserIdSet = new Set<String>();
        for(SPOCUsers__c obj : SPOCUsers__c.getAll().values()){
            if(obj.SPOC_User_ID__c != null && string.valueOf(obj.SPOC_User_ID__c).length() >= 15)
                spocUserIdSet.add(string.valueOf(obj.SPOC_User_ID__c).subString(0,15));
        }
        isSPOCUser = (spocUserIdSet.contains(string.valueOf(UserInfo.getUserId()).subString(0,15))) ? true : false;
              
    }
    
    public boolean getIsAEEUser(){
    
    string AEElabel = label.AEE_Label;
    User u = [select id, User_Division_Custom__c from User where Id =: UserInfo.getUserId()];
    isAEEUser = u.User_Division_Custom__c.contains(AEElabel)?True:False;
    system.debug('==>isAEEUser'+isAEEUser);
    return isAEEUser;
    }
    
    Public Boolean isPartnerConcierge{
        get;set;
    }   

    public Pagereference init(){
        contactObj = null;
        
        partnerSite = '';
        contactId = System.currentPagereference().getParameters().get('contactId');
        syncModes = System.currentPagereference().getParameters().get('syncModes');
        if(contactId != null){
            Set<Id> contactIds = new Set<Id>();
            contactIds.add(contactId);
            List<Contact> contacts = PRMContactUtil.getContacts(contactIds);
            if(contacts != null && contacts.size() > 0){
                contactObj = contacts[0];
                initializeContactModeList();
                if(syncModes != '1' && hasUnprocessedModes()){
                    PRMContactModes prmContactModes = new PRMContactModes();
                    prmContactModes.sendContactModesToProposalTool(contactObj.Id, true);    
                }
                selectContactModeRelationships();
                initializeSiteInfo();
            }
        }
        
        if(contactObj == null){
            return Page.PRMCreateContact;
        }
        return null;
    }

    public String contactPageType{
        get{
            return 'Contact';
        }
    }

    public PageReference cancel() {
        String urlString = '/apex/PRMContactSearch';
        String params = '';
        if(contactObj != null && contactObj.accountId != null){
            urlString += '?accountId=' + contactObj.accountId;
        }
        PageReference pageRef = new PageReference( urlString);
        //return Page.PRMContactSearch; 
        return pageRef;  
    }

    public PageReference edit(){
        String urlString = '/apex/PRMCreateContact';
        String params = '';
        if(contactObj != null && contactObj.Id != null){
            urlString += '?contactId=' + contactObj.Id;
        }
        PageReference pageRef = new PageReference( urlString);
        pageRef.setRedirect(true);
        
        //return Page.PRMContactSearch; 
        return pageRef; 
    }

    public List<Contact_Mode_Rel__c> contactModesList;
    public List<Contact_Mode_Rel__c> getContactModesList(){
        System.debug('Start: initializeContactModeList');
        initializeContactModeList();
        System.debug('End: initializeContactModeList');     
        List<Contact_Mode_Rel__c> contactModesListForDisplay = new List<Contact_Mode_Rel__c>();
        for(Contact_Mode_Rel__c contactModeRelObj : contactModesList){
            if(contactModeRelObj.Isactive__c == true 
                || (contactModeRelObj.Isactive__c == false && contactModeRelObj.Status_Message__c != 'SUCCESS')){
                contactModesListForDisplay.add(contactModeRelObj);
            }
        }
        return contactModesListForDisplay;
    }
    
    public void initializeContactModeList(){
        Boolean activeMode = true;
        Boolean inActiveMode = false;
        selectContactModeRelationships();
        if(contactModesList == null){
            contactModesList = new List<Contact_Mode_Rel__c>(); 
        }
        System.debug('contactModesList: ' + contactModesList);
    }
    
    private Boolean hasUnprocessedModes(){
        List<Contact_Mode_Rel__c> tempContactModeList = [Select Id from Contact_Mode_Rel__c where Status_Message__c != 'SUCCESS'];
        if(tempContactModeList != null && tempContactModeList.size() > 0){
            return true;
        }else{
            return false;
        }
    }
    
    private void selectContactModeRelationships(){
        contactModesList = [Select Id, Mode_Id__c,Mode_Name__c, Isactive__c, 
                                    Ultimate_Parent_Account__c,
                                    Contact__c,Contact_Number__c,
                                    Status_Code__c, Status_Description__c,
                                    Status_Message__c,
                                    createddate,
                                    Active_Mode__c
                                    from Contact_Mode_Rel__c 
                                    where Contact__c =:contactId 
                                    //and (Isactive__c = :activeMode 
                                    //  OR (Isactive__c = :inActiveMode and Status_Message__c != 'SUCCESS')) 
                                    order by Mode_Name__c asc];     
    }   
    
    public PageReference syncContactModes(){
    
        /*
        System.debug('contactObj: ' + contactObj);      
        String urlString = '/apex/PRMViewContact';
        String params = '';
        if(contactObj != null && contactObj.Id != null){
            urlString += '?contactId=' + contactObj.Id ;
        }
        PageReference pageRef = new PageReference( urlString);
        pageRef.setRedirect(true);
        return pageRef;
        */

        PRMContactModes prmContactModes = new PRMContactModes();
        System.debug('contactObj: ' + contactObj);
        prmContactModes.sendContactModesToProposalTool(contactObj.Id, true);        
        String urlString = '/apex/PRMViewContact';
        String params = '';
        if(contactObj != null && contactObj.Id != null){
            urlString += '?contactId=' + contactObj.Id + '&syncModes=1&scontrolCaching=1';
        }
        PageReference pageRef = new PageReference( urlString);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /*
    private void sendContactModesToProposalTool(){
        
        prmContactModes.contactObj = contactObj;
        prmContactModes.contactModeList = contactModesList;
        Boolean syncContactModes = false;
        for(Contact_Mode_Rel__c contactMode : contactModesList){
            if('SUCCESS' != contactMode.Status_Message__c ){
                syncContactModes = true;
                break;
            }
        }
        if(syncContactModes && contactModesList != null && contactModesList.size() > 0){

        }       
    }
    */

    private void initializeLoginUser(){
        //Get login user's credentials
        Id userId = UserInfo.getUserId();
        Id profileId =  UserInfo.getProfileId();
        User loginUser = PRMContactUtil.getUser(userId);
        if(loginUser != null && loginUser.ContactId == null){
            isPartnerConcierge = true;
        }else if(loginUser != null && loginUser.ContactId != null){
            isPartnerConcierge = false;
        }                      
               
    } 

    public PageReference observingContacts(){
                
        String urlString = '/apex/ObservingContacts';
        String params = '';
        if(contactObj != null && contactObj.Id != null){
            urlString += '?id=' + contactObj.Id + '&scontrolCaching=1';
        }
        PageReference pageRef = new PageReference( urlString);
        pageRef.setRedirect(true);
        return pageRef;
    }


    public void sendContactToNetExam(){
        
        if(contactObj == null || contactObj.Id == null){
            return;
        }
        
        String stage = contactObj.Account.stage__c;
        if(stage == null || stage == '' || (stage != 'Confirmed' && stage.contains('Contract Negotiation') == false)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Contact details will be sent to NetExam only for the Partners in \'Contract Negotiation\' OR \'Confirmed\' stage'));
            System.currentPagereference().getParameters().put('contactId', contactObj.Id);
            return;
        }

        Set<Id> contactIds = new Set<Id>();
        Set<Id> activateContactIds = new Set<Id>();
        Set<Id> deActivateContactIds = new Set<Id>();
        if(contactObj.Active__C == true){
            contactIds.add(contactObj.Id);
            if(contactObj.sells_sunrun__c == PRMContactUtil.YES)
                activateContactIds.add(contactObj.Id);
        }if(contactObj.Active__C == false){
            deActivateContactIds.add(contactObj.Id);
        }
        
        String errorMessage = '';
        If(!Test.isRunningTest()){
            errorMessage =  NetExamWebServiceAPIHelper7.processContactForLMS(contactIds, activateContactIds, deActivateContactIds);
        }
                
        if(errorMessage != null && errorMessage != 'Success'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, errorMessage));
            return;
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Contact details have been sent to NetExam successfully'));
        return;
    }

    
    private void initializeSiteInfo(){
        
        if(contactObj == null || contactObj.id == null)
            return;
            
        List<AccountContactRole> contactRoles = [Select Id, contactId, accountId 
                                                    from AccountContactRole WHERE 
                                                    contactId =:contactObj.Id ];
        if(contactRoles.size() > 0 ){
            AccountContactRole contactRoleObj = contactRoles[0];
            if(contactRoleObj.AccountId != null){
                Account tempAccountObj = [Select Id, name, site from Account where 
                                            Id = :contactRoleObj.AccountId];
                partnerSite = tempAccountObj.Site;
            }
        }
    }
    
    public Boolean showSolarUniverseFields {
        get{
            Boolean show = false;
                system.debug('Account Name:' + contactObj.Account.Name);
                system.debug('isPartnerConcierge value:' + isPartnerConcierge);                 
                //isPartnerConcierge is set for the Partner Concierge
                if(isPartnerConcierge == false &&
                     contactObj.Account.Name.contains(PRMContactUtil.SOLAR_UNIVERSE)){
                        show = true;
                        return show;
                }       
            system.debug('Dont Show solar universe');
            return show;        
        }
        set;
     }
     
     public Boolean showLocation {
        get{
            Boolean show = false;
            System.debug('parentAccountObj.name: ' + contactObj.Account.Name);
            if(contactObj.Account.Name != null 
                && contactObj.Account.Name != '' ){

                if(contactObj.Account.Name.contains(PRMContactUtil.SOLAR_UNIVERSE)){
                    show = true;
                    return show;
                }       
            }
            return show;        
        }
        set;
     } 

}