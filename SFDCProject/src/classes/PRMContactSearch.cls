public class PRMContactSearch {

    private Id accountId;
    private Id parentAccountId;
    public Account accountObj;
    public Account parentAccountObj;
    public boolean isPartnerConcierge {get;set;}
    public boolean accessibleUser{get;set;}
    private String firstNameLike = '%%';
    private String firstNameEq = null;
    private String lastNameLike = '%%';
    private String lastNameEq = null; 
    private String emailLike = '%%';
    private String emailEq = null;  

    private Id userId;
    private List<PRMContact> allPRMContacts;
    private List<PRMContact> prmContacts;
    public CustomLookup__c customLookup{get;set;}
    
    Contact loginUserContact;
    User loginUser;

    public String actionName{get;set;}
    public String searchColumnName{get;set;}
    public String searchValue{get;set;}
    public Boolean exactSearch{get;set;}
    public Boolean activeContacts{get;set;}
    
    public String deactivationComments{ get;set; }
    public String deactivationReason{get;set;}

    public boolean displayReasonPopup {get; set;}
    public boolean displayErrorPopup {get; set;}       
    public boolean displayAVLPopup {get; set;}
    public string displayAVLPopupMessage {get; set;}
    public boolean isSPOCUser {get; set;}
    
    public Pagereference applySearchFilter(){
        if(isPartnerConcierge == true){
            accountId = customLookup.account__c;
            if(accountId != null){
                accountObj = [Select Id, Name, OwnerId, Partner_Status__c from Account 
                                where Id =:customLookup.account__c];
            }
        }
        con = null;
        return null;
    }   

    public ApexPages.StandardSetController con {
        get {
            if(con != null)
            {
                return con;
            }
            con = createSQOLConnection();
            con.setPageSize(10);
            return con;
        }
        set;
    }    
    public Account getAccountObj(){
        return accountObj;
    }

    public PRMContactSearch(){
        isPartnerConcierge = false;
        accessibleUser = true;
        activeContacts = true;
        exactSearch = false;
        isSPOCUser = false;
        
        if(customLookup == null){
            customLookup = new CustomLookup__c();
        }
        accountId = System.currentPagereference().getParameters().get('accountId');
        initializeLoginUser();
        if(accountObj == null){
            accountObj = new Account();
        }
        
        if(accountId != null && customLookup != null){
            customLookup.account__c = accountId;
        }
    }

    private void initializeLoginUser(){
        loginUser = PRMContactUtil.getLoginUser();
        
        Set<String> spocUserIdSet = new Set<String>();
        for(SPOCUsers__c obj : SPOCUsers__c.getAll().values()){
            if(obj.SPOC_User_ID__c != null && string.valueOf(obj.SPOC_User_ID__c).length() >= 15)
                spocUserIdSet.add(string.valueOf(obj.SPOC_User_ID__c).subString(0,15));
        }
        
        isSPOCUser = (spocUserIdSet.contains(string.valueOf(UserInfo.getUserId()).subString(0,15))) ? true : false;
        
        if(loginUser != null && loginUser.ContactId == null){
            isPartnerConcierge = true;
        }else if(loginUser != null && loginUser.ContactId != null){
            isPartnerConcierge = false;
            List<Contact> contactObjList = new List<Contact>();
            contactObjList = [Select Id, email, AccountId, Managing_Partner_AVL_Costs__c, Managing_Partner_AVL_Prices__c from Contact where Id = :loginUser.ContactId]; 
            if(contactObjList.size() > 0)
            {
                
              if(spocUserIdSet.contains(string.valueOf(UserInfo.getUserId()).subString(0,15))){
                if(contactObjList[0].Managing_Partner_AVL_Costs__c=='Granted' || contactObjList[0].Managing_Partner_AVL_Prices__c=='Granted'){
                accessibleUser = true;
                }
                if(contactObjList[0].Managing_Partner_AVL_Costs__c!='Granted' && contactObjList[0].Managing_Partner_AVL_Prices__c!='Granted'){
                accessibleUser = false;
                }
              }  
                
                loginUserContact = contactObjList[0];
                if(customLookup.Account__c != null){
                    accountId = customLookup.Account__c;
                }else if(accountId == null && customLookup.Account__c == null){
                    accountId = loginUserContact.AccountId;
                }
                if(accountId != null){
                    accountObj = [Select Id, name, accountnumber, 
                                Partner_Status__c, OwnerId
                                from Account where id =:accountId];
                }
             }
        }

    }   
 
    public List<SelectOption> getActions() {
        List<SelectOption> actions = new List<SelectOption>();
        actions.add(new SelectOption('', '-- None --'));
        actions.add(new SelectOption('activate', 'Activate Employee'));
        actions.add(new SelectOption('create', 'New Employee'));
        actions.add(new SelectOption('deactivate', 'Deactivate Employee'));
         actions.add(new SelectOption('reset the password(s)', 'Reset Partner Portal Password'));
       // actions.add(new SelectOption('Export To Excel','exporttoexcel'));
        return actions;
    }   
        
    public List<SelectOption> getSearchBy() {
        List<SelectOption> searchBy = new List<SelectOption>();
        searchBy.add(new SelectOption('firstName', 'First Name'));
        searchBy.add(new SelectOption('lastName', 'Last Name'));
        searchBy.add(new SelectOption('email','Email'));
        return searchBy;
    }   
    private ApexPages.StandardSetController createSQOLConnection(){
        ApexPages.StandardSetController tempConnection;
        List<Id> contactids = getContactIds();
        Boolean hasContactIds = false;
        if(contactids != null && contactids.size() > 0){
            hasContactIds = true;
        }
        String soqlQuery = getSelectionQuery(hasContactIds);
        System.debug('accountId: ' + accountId);
        System.debug('soqlQuery: ' + soqlQuery);
        
        tempConnection = new ApexPages.StandardSetController(Database.getQueryLocator(soqlQuery));
        return tempConnection;          
    }
    
    private List<Id> getContactIds(){
        List<Id> contactIds = new List<Id>();
        Account tempAccountObj = getAccountObj();
        if(tempAccountObj != null){
            for(Contact contactObj: [Select Id from Contact where accountId = :tempAccountObj.Id]){
                contactIds.add(contactObj.Id);
            }
        }
        System.debug('contactIds: ' + contactIds);
        return contactIds;
    }
    
    private String getSelectionQuery(Boolean hasContactIds){
        firstNameLike = '%%';
        firstNameEq = null;
        lastNameLike = '%%';
        lastNameEq = null; 
        emailLike = '%%';
        emailEq = null; 
        
        String searchCondition = '';
        if(searchColumnName == 'firstName' && searchValue != null && searchValue != ''){
            firstNameLike = '%' + searchValue + '%';
            firstNameEq = searchValue;
            if(exactSearch){
                searchCondition = ' AND (firstname = :firstNameEq) ';
             }else{
                searchCondition = ' AND (firstname like :firstNameLike OR firstname = :firstNameEq) ';
            }
            
        }else if(searchColumnName == 'lastName' && searchValue != null && searchValue != ''){
            lastNameLike = '%' + searchValue + '%';
            lastNameEq = searchValue;
             if(exactSearch){
                searchCondition = ' AND (lastName = :lastNameEq) ';                 
             }else{
                searchCondition = ' AND (lastName like :lastNameLike OR lastName = :lastNameEq) ';              
             }
            
        }else if(searchColumnName == 'email' && searchValue != null && searchValue != ''){
            emailLike = '%' + searchValue + '%';
            emailEq = searchValue;
            if(exactSearch){
                searchCondition = ' AND (email = :emailEq) ';               
            }else{
                searchCondition = ' AND (email like :emailLike OR email = :emailEq) ';              
            }
            
        }     
        System.debug('activeContacts: ' + activeContacts);
        if(activeContacts){
            searchCondition += ' AND active__c=true ';
        }

        String soqlQuery = 'select Id,name, accountId, firstName,lastName,email,title, phone, active__c ,'; 
        soqlQuery += ' Proposal_Tool_Access__c, Design_Tool_Access__c, Partner_Portal_Access__c, ';
        soqlQuery += ' Design_New_Proposal__c,Modify_Proposal__c,Manual_Design__c,As_Built__c,eAudit__c,ePermitting__c,Managing_Partner_AVL_Costs__c,Managing_Partner_AVL_Prices__c, ';//Santosh Changes
        soqlQuery += ' Delegated_Admin_Access__c, Can_Run_Change_Orders__c, e_sign_documents_access__c, profile__c';
        soqlQuery += ' from Contact ';
        soqlQuery += ' where accountId != null ';
        soqlQuery += ' and accountId = :accountId ';
        soqlQuery += searchCondition;
        soqlQuery += ' ORDER BY firstName, lastName' ;
        return soqlQuery;
    }
    
    public PageReference createUser() {
        String urlString = '/apex/PRMCreateContact';
        if(customLookup.account__c != null){
            urlString += '?accountId=' + customLookup.account__c;
        }
        PageReference pageRef = new PageReference( urlString);
        pageRef.setRedirect(true);
        return pageRef;            
    } 

    public Pagereference resetPasswords(){
        PageReference pageRef = null; 
        List<User> passwordRestUsers = new List<User>();
        List<Id> passwordRestIds = null;
        if(prmContacts != null){
            Map<Id, User> selectedUsers = getPartnerUsersForSelectedContacts();
            System.debug('selectedUsers: ' + selectedUsers);
            for(User userObj : selectedUsers.values()){
                if(userObj.id == UserInfo.getUserId() && userObj.IsActive == true){
                    pageRef = new PageReference('/_ui/system/security/ChangePassword');
                    return pageRef;
                }
                System.debug('userObj: ' + userObj);
                System.resetPassword(userObj.id, true);
            }
        }
        pageRef = getContactSearchPage();
        return pageRef;
    }
    
    private Pagereference getContactSearchPage(){
        String urlString = '/apex/PRMContactSearch';
        String params = '';
        if(accountId != null){
            urlString += '?accountId=' + accountId;
        }
        Pagereference pageRef = new PageReference( urlString);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public Pagereference deactivateUserNew(){
        displayReasonPopup = false;  
        displayErrorPopup = false;
        String modifyStatus = 'Deactivate';
        System.debug('Reason: ' + deactivationReason);
        System.debug('Comments: ' + deactivationComments);
        Pagereference pageRef = modifyContactStatus(modifyStatus);
        return pageRef;
    }

    public Pagereference deactivateUser(){
        displayReasonPopup = false;  
        displayErrorPopup = false;
        String modifyStatus = 'Deactivate';
        
        System.debug('Reason: ' + deactivationReason);
        System.debug('Comments: ' + deactivationComments);

        Pagereference pageRef = modifyContactStatus(modifyStatus);
        pageRef = getContactSearchPage();
        return pageRef;
    }

    /*
    public Pagereference deactivateUser(){
        displayReasonPopup = false;  
        displayErrorPopup = false;
        String modifyStatus = 'Deactivate';
        Pagereference pageRef = modifyUserStatus(modifyStatus);
        return pageRef;
    }
    */

    public Pagereference userActions(){
        System.debug('actionName: ' + actionName);
        Pagereference pageRef = null;
        if(actionName == null){
            return null;
        }else if(actionName == 'create'){
            pageRef = createUser();
            return pageRef;
        }else if(actionName == 'activate'){
            pageRef = activateUser();
            return pageRef;
        }else if(actionName == 'deactivate'){
            pageRef = deactivateUserNew();
            return pageRef;
        }else if(actionName == 'reset the password(s)'){
            pageRef = resetPasswords();
            return pageRef;
        }else{
            return null;
        }
        
    }

    public Pagereference activateUser(){
        String modifyStatus = 'Activate';
        Pagereference pageRef = modifyContactStatus(modifyStatus);
        return pageRef;
    }

    private Pagereference modifyContactStatus(String actionType){

        System.debug('actionType: ' + actionType);
        PageReference pageRef = null; 
        pageRef = getContactSearchPage();
        Boolean activateUser = false;
   
        if(actionType == 'Activate'){
            activateUser = true;
        }else if(actionType == 'Deactivate'){
            activateUser = false;
        }else{
            pageRef.setRedirect(true);
            return pageRef;         
        }
           
        List<Contact> modifyContactList = new List<Contact>();
        Set<Id> userIds = new Set<Id>();
        List<Id> modifyUserIds = null;
        if(prmContacts == null){
            pageRef.setRedirect(true);
            return pageRef;       
        }

        List<Contact> selectedUserContactList = new List<Contact>();
        Set<Id> selectedContactIds = new Set<Id>();
        for(PRMContact prmContactObj :prmContacts){
            if(prmContactObj.selected){
                selectedUserContactList.add(prmContactObj.ContactObj);
                selectedContactIds.add(prmContactObj.ContactObj.Id);
            }
        }  

        Map<Id, Id> contactAccountManagerMap = new Map<Id, Id>();
        for(Contact contactObj : selectedUserContactList){
            contactObj.active__c = activateUser;
            if(contactObj.active__c == false){
                contactObj.Deactivation_Reason__c = deactivationReason;
            }else{
                contactObj.Deactivation_Reason__c = '';
            }
            modifyContactList.add(contactObj);
            if(contactObj.Account.Account_Manager__c != null){
                contactAccountManagerMap.put(contactObj.Id, contactObj.Account.Account_Manager__c);
            }
        }
        
        List<Database.Saveresult> updateContactResults = Database.update(modifyContactList, false);
        boolean displayError = false;
        for(Database.Saveresult resultObj: updateContactResults){
            if(!resultObj.isSuccess()){
                List<Database.Error> databaseErrors = resultObj.getErrors();
                String errorMessage = 'Unable to Save the record. ';
                if(databaseErrors != null && databaseErrors.size() > 0){
                    errorMessage += databaseErrors[0].getMessage();
                }
                System.debug('Save error: ' + errorMessage);
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
                displayError = true;
            }
        }
        if(displayError){
            return null;
        }
        pageRef.setRedirect(true);
        return pageRef;
        
    }
    
    public PageReference exportToExcel() {
        return null;
        //return Page.PRMUserSearchExportToExcel;
    }

    public PageReference exportToPDF() {
        return null;
        //return Page.PRMUserSearchExportToPDF;
    }

    public void closePopup() {        
        displayReasonPopup = false;  
        displayErrorPopup = false;  
        displayAVLPopup= false;
    }     
    
    public void showPopup() {
        Boolean result = hasSelectedUsers();   
        System.debug('Result: ' + result);
        if(result){
            displayReasonPopup = true; 
        }else{
            displayErrorPopup = true; 
        }   
    }
    
    private boolean hasSelectedUsers(){
       Boolean result = false;
        if(prmContacts != null){
            for(PRMContact prmContactObj :prmContacts){
                if(prmContactObj.selected){
                    result = true;
                    break;
                }
            }
        }
        return result;
    }

    public Boolean hasNext
    {
        get
        {
            return con.getHasNext();
        }
        set;
    }
 

    public Boolean hasPrevious
    {
        get
        {
            return con.getHasPrevious();
        }
        set;
    }
 
    
    public Integer pageNumber
    {
        get
        {
            return con.getPageNumber();
        }
        set;
    }

    public void first()
    {
        con.first();
    }  
 
    public void last()
    {
        con.last();
    }
        
    public void previous()
    {
        con.previous();
    }
 

    public void next()
    {
        con.next();
    }   

    public List<SelectOption> getDeactivationReasons() {
        List<SelectOption> deactivationReasons = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Contact.Deactivation_Reason__c.getDescribe();
        List<Schema.PicklistEntry> deactivationList = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry picklistVal : deactivationList)
        {
            deactivationReasons.add(new SelectOption(picklistVal.getValue(), picklistVal.getLabel()));
        }      
        return deactivationReasons;
    }

    public List<PRMContact> getAllPRMContacts(){
        List<Contact> contacts = new List<Contact>();
        allPRMContacts = new List<PRMContact>();
        
        ApexPages.StandardSetController exportConnection = createSQOLConnection();
        Integer resultSize = exportConnection.getResultSize();
        while(resultSize > 0){
            contacts.addall((List<Contact>)exportConnection.getRecords());
            resultSize = resultSize - exportConnection.getPageSize();
        }
        allPRMContacts = populatePRMContactList(contacts);       
        return allPRMContacts;
    }
    
    private List<PRMContact> populatePRMContactList(List<Contact> contacts){
        List<PRMContact> tempPRMContacts = new List<PRMContact>();
        PRMContact prmContact = null;
        for(Contact contactObj : contacts){
            if(contactObj.AccountId == null)
                continue;
            prmContact = new PRMContact();
            
            if(loginUser.ContactId != null &&
                contactObj.id == loginUser.ContactId){
                prmContact.displayCheckBox = false;
            }else{
                prmContact.displayCheckBox = true;
            }            

            prmContact.contactObj  = contactObj;
            prmContact.isActive = contactObj.active__c;
            tempPRMContacts.add(prmContact);
        }
        return tempPRMContacts;
    }
    
    public List<PRMContact> getPRMContacts(){
        System.debug('Invoking getPRMContacts');
        List<Contact> contacts = con.getRecords();
        prmContacts =  populatePRMContactList(contacts);
        return prmContacts;
    }
    public pagereference redirectAVLCosts(){
        String urlString=ManagingPartnerAVLUrl.getAVLUrl(loginUserContact.accountId, 'ManagingPartnerAVLCosts');
        if(urlString.contains('Failure')){
            displayAVLPopupMessage='Account Not Eligible for AVL cost Changes';
            displayAVLPopup=true;           
        }
        else if(urlString.contains('You are not eligible')){
            displayAVLPopupMessage='You are not eligible to manage AVL Costs';
            displayAVLPopup=true;           
        }
        else{
        Pagereference pageRef = new PageReference( urlString);
        pageRef.setRedirect(true);
        return pageRef;
        }
        return null;
    }
    /*
    public pagereference redirectAVLPrices(){
        String urlString=ManagingPartnerAVLUrl.getAVLUrl(loginUserContact.accountId, 'ManagingPartnerAVLPrices');
        if(urlString.contains('Failure')){
            displayAVLPopupMessage='Account Not Eligible for AVL price Changes';
            displayAVLPopup=true;           
        }
        else if(urlString.contains('You are not eligible')){
            displayAVLPopupMessage='You are not eligible to manage AVL Prices';
            displayAVLPopup=true;           
        }
        else{
        Pagereference pageRef = new PageReference( urlString);
        pageRef.setRedirect(true);
        return pageRef;
        }
        return null;
    }
    */
    private Map<Id, User> getPartnerUsersForSelectedContacts(){
        Map<Id, User> selectedUsers = new Map<Id, User>();
        List<Id> selectedContactIds = null;
        if(prmContacts != null){
            selectedContactIds = new List<Id>();
            for(PRMContact prmContactObj :prmContacts){
                if(prmContactObj.selected){
                    selectedContactIds.add(prmContactObj.contactObj.Id);
                }
            }
            for(User userObj : [Select Id,IsPortalEnabled, contactId, email,
                                    name, firstname, lastname, 
                                    isactive from User where contactId in : selectedContactIds]){
                selectedUsers.put(userObj.Id, userObj);
            }
        }
        return selectedUsers;
    }

}