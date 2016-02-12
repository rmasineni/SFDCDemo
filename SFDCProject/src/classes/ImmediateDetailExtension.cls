public with sharing class ImmediateDetailExtension {
    public List<MyWrapper> myWrappers {get; set;}
    public Integer pageNumber = 0;
    public Integer Count = 60;
    public Integer totalCount {get;set;}
    public Integer totalPageCount{get;set;}
    public Integer pageSize = 25;
    Public String Status='Open';
    public String urlPrefix {get;set;}
    Public String InstallPartner='Sunrun';
    Public String ReadyFor='Design';
    Public String ReadyForRedesign='Redesign';
    public String searchColumnName{get;set;}
    public String searchValue{get;set;}
    private String oppNameLike = '%%';
    private String SiteDesignPriority = '%%';
    private String LeadSourceLike = '%%';
    private String ChannelLike = '%%';
    private String SalesPartnerLike = '%%';
    public String userId{get;set;}
    Set<id> Ids=new Set<id>();
    public Id loginContactId {get;set;}
    public Set<id> PTOpptyIds=new Set<id>();
    public String SelectedOpportunityId  {get; set;}
    public Integer oppCount {get; set;}
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT id, name,account.billingstreet,account.billingcity,account.billingstate,account.billingpostalcode FROM Opportunity where LastModifiedDate=this_month limit 10000]));
            }
            return setCon;
        }
        set;
    }
    public ImmediateDetailExtension() {
        oppCount = 0;
        initialize();       
        queryLists();
        calculatePageCount();
        oppCount = ((myWrappers !=null && myWrappers.size() > 0) ? myWrappers.size() : 0);
        /*List<Lead> l1=[select id,name from lead where isconverted=false order by createddate desc limit 100];
        List<Opportunity> o1=[select id,name from opportunity order by createddate desc limit 100];
        MyWrapper wrap = new MyWrapper();
        wrap.leadList=l1;
        wrap.opptyList=o1;
        myWrappers.add(wrap);
        system.debug('---'+mywrappers);
        */
    } 
     
    public PageReference doSearch() 
    {
        try{
                if(searchValue != null && searchValue != '' && searchValue.Length() < 2){
                    String errorMessage = CustomErrorMessages.MINIMUM_SEARCH_STRING;
                    Exception expObj = new BaseException(errorMessage);
                    expObj.setMessage(errorMessage);
                    ApexPages.addMessages(expObj);
                    return null;
                }
                
                                 
                 userActions();              
                }catch(Exception exceptionObj){
            ApexPages.addMessages(exceptionObj);               
        }  
        return null;
    }    
    private void queryLists(){
        myWrappers = new List<MyWrapper>();
        Integer offset = pageNumber * pageSize;
     // String LeadbaseQuery = getLeadQuery();
     // String OpptybaseQuery =getOpptyQuery();k2
        String OpptybaseQuery =getSelectionQuery();
     // String LeadcountQuery=LeadbaseQuery+' LIMIT 100'; 
     // String OpptycountQuery=OpptybaseQuery+' LIMIT 100';
        String OpptycountQuery=OpptybaseQuery;
     // String Leadquery = LeadbaseQuery + ' LIMIT '+ pageSize +' OFFSET '+ offset;
        String SelectQuery =getSelectionQuery();
    //  String Opptyquery = OpptybaseQuery + SelectQuery + ' LIMIT '+ pageSize +' OFFSET '+ offset;
        String Opptyquery = SelectQuery + ' LIMIT '+ pageSize +' OFFSET '+ offset;
     // List<Lead> l1=Database.query(Leadquery);
        List<Opportunity> o1=Database.query(Opptyquery);
   //   List<Lead> countLeads=Database.query(LeadcountQuery);
        List<Opportunity> countOppty=Database.query(OpptycountQuery);
        //MyWrapper wrap = new MyWrapper();
        //wrap.leadList=l1;
        //wrap.opptyList=o1;
       /* for(lead l:l1){
            myWrappers.add(new myWrapper(l));
        } */
        
        for(Opportunity o:o1){
            myWrappers.add(new myWrapper(o));
        }
        //myWrappers.sort();
        //myWrappers.add(wrap);
        //SortWrapper();
       // totalCount=countLeads.size()+countOppty.size();
          totalCount=countOppty.size();
    }
    public boolean displayPopup {get;set;}
    public String displayPopupMessage {get;set;}
    public boolean displayWarningMessage {get;set;}
    public boolean displayURL {get; set;}
    public String redirectURL {get;set;}
    public boolean displaySalesRepURL {get;set;}
    public boolean displayTandCURL {get; set;}
    public boolean showConfirm {get;set;}
    public String SalesRepURL {get;set;}
    public String selectedOppId { get; set;}
    public Opportunity opptyObj {get;set;}
    public String selectedDesign{get;set;}
    public List<TermsConditions__c> PartnerTermsConditions;
    public Id partnerContactId{get;set;} 
      // Methods related to Partner Terms and Conditions
    public List<TermsConditions__c> getPartnerTermsConditions(){
        System.debug(LoggingLevel.INFO,'In getPartnerTermsandConditions()');

        PartnerTermsConditions = TermsConditionsUtil.fetchPartnerTermsConditions('PARTNER');
        return PartnerTermsConditions;         
    }

    public void acceptTermsandConditions() {

        system.debug(LoggingLevel.INFO,'In acceptTermsandConditions');
   //     String objectType = 'Lead'; 
        TermsConditionsUtil.updateTermsandConditions(partnerContactId);
        displayTandCURL = false;
        this.redirectDesignTool();
    }
    
    public void declineTermsandConditions() {
        system.debug(LoggingLevel.INFO,'In declineTermsandConditions');        
        displayTandCURL = false;
    }
   
    
    
    public PageReference redirectDesignToolSaveProject()
    {
        selectedDesign='SavedProject';
        return redirectDesignTool();
    }
    public pagereference clearOthers()
    {
        if(SelectedOpportunityId !=null && SelectedOpportunityId !='' && myWrappers !=null && myWrappers.size()>0)
        {
            for(MyWrapper wrap : myWrappers)
            {
                if(wrap.id!=SelectedOpportunityId)
                {
                    wrap.IsSelected = false;
                }
            }
        }
        return null;
        
    }
    public PageReference redirectDesignTool()
    {
        this.displayPopup = false;
        this.displayTandCURL=false;
        this.displayURL=false;
        this.displayWarningMessage = false;
        this.displaySalesRepUrl=false;      
        if(selectedOppId !=null && selectedOppId !='')
        {
            System.debug('selectedOppId====='+selectedOppId);
            List<Opportunity> lstLatest = [select id,name,Prospect_Id__c,Site_Designer__c,Site_Design_Status__c from Opportunity where Id=:selectedOppId];
            if(lstLatest !=null && lstLatest.size()>0)
            {
                opptyObj = lstLatest[0];
                if(lstLatest[0].Site_Design_Status__c=='In Progress')
                {
                    this.displayPopup = true;
                    this.displayPopupMessage = 'This site design is currently in progress!';
                    return null;
                }               
            }
            if(selectedDesign==null || selectedDesign=='')
                selectedDesign ='DesignNewProposal';
            String message=CDYNEStandardButtonCall.callOpportunity(selectedOppId);
            DesignToolWebservice.DesignToolWebserviceResponse responseObj;
            System.debug(LoggingLevel.INFO,'message : '+message);         
            if(message!='Success'&&message!='Sales Rep Message'&&message!='Sales Rep Division Message'&&message!='County Message'){
             displayPopupMessage=message;
             displayPopup=true; 
             return null;   
            }           
            
            boolean partnerTandCAccepted = false;
            String returnPageVal;
            list<Contact> CurrentContact=[select id, T_C_Accepted__c from Contact where Sunrun_User__c=:userinfo.getUserId() AND Email= :userinfo.getUserEmail() AND Contact_Type__c='Employee'];     
            if(CurrentContact.size() == 1){
               partnerContactId = CurrentContact[0].id;
               partnerTandCAccepted = CurrentContact[0].T_C_Accepted__c;   
            }else{
                 displayPopupMessage='The valid user contact is required';
                 displayPopup=true;
                 return null;   
            }                                   
         if(!partnerTandCAccepted && message != null && message.equalsIgnoreCase('Success')){          
                system.debug('In T&C not accepted');
                returnPageVal = 'Opty';
                PageReference partnerTandCPage = TermsConditionsUtil.redirectToTermsConditions(partnerContactId,opptyObj.Id,'Opty',selectedDesign,opptyObj.Prospect_Id__c,'PARTNER','P');                               
                redirectURL= partnerTandCPage.getUrl();
                displayTandCURL=true;
                return null;                 
         }else{
            responseObj = new DesignToolWebservice.DesignToolWebserviceResponse();
            selectedDesign=selectedDesign.trim();
            selectedDesign=selectedDesign.replaceAll('(\\s+)', '');
            if(selectedDesign!='--None--')
            DesignTool.function=selectedDesign;
            DesignToolWebservice.DesignToolWebserviceResponse responseObj2 = DesignTool.getDesignToolURL(opptyObj.id, opptyObj.Prospect_Id__c, 'Opportunity');
            if(responseObj2.errorMessage == 'InValidRange' ){
                String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000009').error_message__c;   
                displayPopupMessage=errorMessage ;
                displayPopup=true;                           
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));       
            }else if(responseObj2.errorMessage == 'NoTerritory' ){
                String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000010').error_message__c;    
                displayPopupMessage=errorMessage ;
                displayPopup=true;                           
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));       
             }
            else{
                responseObj = DesignTool.canUserCreateORModifyProposal(opptyObj.id);
                if(responseObj.status == ProposalUtil.SUCCESS){
                    redirectURL=responseObj2.url;
                    if(message=='Success'){
                    displayURL=true;  
                    If(opptyObj.Site_Designer__c==null)    
                    opptyObj.Site_Designer__c=UserInfo.getUserId();
                    If(opptyObj.Site_Design_Status__c=='Open')    
                    opptyObj.Site_Design_Status__c='In Progress';   
                    System.debug('This is Site Desinger:'+opptyObj.Site_Designer__c);    
                    update opptyObj;    
                    }                    
                }else if(responseObj.status == ProposalUtil.WARNING){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000022').error_message__c;  
                     displayPopupMessage=errorMessage ;
                     //displayPopup=true;
                     displayWarningMessage=true;
                     redirectURL=responseObj2.url; 
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));     
                     showConfirm = true;    
                     If(opptyObj.Site_Designer__c==null)    
                    opptyObj.Site_Designer__c=UserInfo.getUserId();
                    If(opptyObj.Site_Design_Status__c=='Open')    
                    opptyObj.Site_Design_Status__c='In Progress';   
                    System.debug('This is Site Desinger:'+opptyObj.Site_Designer__c);    
                    update opptyObj;
                }else if(responseObj.status == ProposalUtil.ERROR){
                    String errorMessage = SunrunErrorMessage.getErrorMessage('ERROR_000023').error_message__c;  
                    displayPopupMessage=errorMessage ;
                    displayPopup=true; 
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));                     
                }
                if((message=='Sales Rep Message'||message=='Sales Rep Division Message'&&userinfo.getUserType()!='PowerPartner')||message=='County Message'){
                    String partnerTCAccepted = partnerTandCAccepted ? 'true' : 'false';
                    returnPageVal = 'Opty';                    
                    displaySalesRepUrl=true;                     
                    SalesRepURL='/apex/SalesRepRedirect?Id='+OpptyObj.id+'&message='+message+'&redirectUrl='+redirectURL+'&partnerTandCAccepted='+partnerTCAccepted+'&partnerContactId='+partnerContactId;
                    return null;
                }
            }
         }   
        }
        
        
        return null;
    }
     private void initialize(){
        totalCount = 0;
        pageNumber = 0;
        totalPageCount = 0;
        //setOpptyCount();        
    }
  /*   private String getLeadQuery(){
       // return 'select id,name,createddate from lead where isconverted=false order by createddate desc';
          return 'select id,name,createddate,Lastmodifieddate from lead where isconverted=false order by Lastmodifieddate desc';
    } */
 /*  private String getOpptyQuery(){
        
      //  return 'select id,name,createddate,Site_Designer__c,Site_Design_Priority__c,Site_Design_Status__c from opportunity where Site_Design_Status__c=:Status order by createddate desc';
      //    return 'select id,name,createddate,Site_Designer__c,Site_Designer__r.name,Site_Design_Priority__c,Site_Design_Status__c,Lastmodifieddate,(select id,contact.name from OpportunityContactRoles) from opportunity where Site_Design_Status__c=:Status order by Lastmodifieddate desc';
        return 'select id,name,createddate,Site_Designer__c,Site_Designer__r.name,Site_Design_Priority__c,Site_Design_Status__c,Lastmodifieddate,(select id,contact.name from OpportunityContactRoles) from opportunity';
    } */
    public boolean getHasNext(){
        if((pageNumber + 1) < totalPageCount){
            return true;
        }else{
            return false;
        }
    }
    public PageReference first(){
        pageNumber = 0;
        queryLists();
        return null;
    }  
 
    public PageReference last(){
        pageNumber = totalPageCount - 1;
        queryLists();
        return null;
    } 
     public boolean getHasPrevious(){
        if(pageNumber <= 0){
            return false;
        }else{
            return true;
        }
    }   
    public PageReference previous(){
        pageNumber--;
        if (pageNumber < 0)
            return null;
        queryLists();
        return null;
    }

    public PageReference next(){
        pageNumber++;
        queryLists();
        return null;
    }   
    public Integer getTotalPageCount(){
        return totalPageCount;
    }
    
    public Integer getPageNumber(){
        return pageNumber+1;
    }    
   private void calculatePageCount(){
        if(totalCount <= 0)
            return;
        
        Integer tempValue = totalCount / pagesize;
        Integer reminderVal = math.mod(totalCount, pagesize);
        
        if(reminderVal > 0){
            totalPageCount = tempValue + 1;
        }else{
            totalPageCount = tempValue;
        }
        
    }
    
    public void RefereshInterval()
    {
        displayPopup=false;
        displayWarningMessage = false;
        displayURL = false;
        displaySalesRepURL = false;
        initialize();       
        queryLists();
        calculatePageCount();
        updateCounter();
        oppCount = ((myWrappers !=null && myWrappers.size() > 0) ? myWrappers.size() : 0);
    }
    public void SortWrapper()
    {
        Map<id,MyWrapper> TampWrapMap = new Map<Id,MyWrapper>();
        list<string> TempLst = new list<string>();
        for(MyWrapper TempObj : myWrappers)
        {
            TampWrapMap.put(TempObj.id,TempObj);
            TempLst.add(string.valueof(TempObj.ldate)+'_'+string.valueof(TempObj.id));
        }
        if(TempLst.size()>0)
        {   myWrappers = new list<MyWrapper>(); // empty the existing list, so we can fill it again with soreted data crated date vise
            TempLst.sort(); // sorting the lst of datetime_id 
            for(String TempStr : TempLst)
            {
                String[] SplitDateAndId = TempStr.split('_');
                if(SplitDateAndId.size() >1)
                {
                    if(TampWrapMap.containskey(SplitDateAndId[1]))
                    {
                        myWrappers.add(TampWrapMap.get(SplitDateAndId[1]));
                    }
                }
            }
        }
    }
    
    private String getSelectionQuery(){
        oppNameLike = '%%';
 SiteDesignPriority = '%%';
     LeadSourceLike = '%%';
   SalesPartnerLike = '%%';
        ChannelLike = '%%';
        String userName = UserInfo.getName();        
        
        String searchCondition = '';
        if(searchValue != null && searchValue != ''){
            if(searchColumnName == 'name' && searchValue != null && searchValue != ''){
                system.debug('Search value name...'+searchValue);
                oppNameLike = '%' + searchValue + '%';
                system.debug('Search value oppNameLike...'+oppNameLike);
                searchCondition = ' AND (Name like :oppNameLike) ';
                system.debug('Search value searchCondition...'+searchCondition);
             // searchCondition += getSearchConditionByViewName(userId,userName);
                            
            } 
            
            else if(searchColumnName == 'SalesPartner' && searchValue != null && searchValue != ''){
                system.debug('Search value accname...'+searchValue);
                SalesPartnerLike = '%' + searchValue + '%';
                searchCondition = ' AND (Sales_Partner__r.name like :SalesPartnerLike) ';
             //   searchCondition += getSearchConditionByViewName(userId,userName); 
                
            }
            
            else if(searchColumnName == 'Channel' && searchValue != null && searchValue != ''){
                system.debug('Search value stage...'+searchValue);
                ChannelLike = '%' + searchValue + '%';
                searchCondition = ' AND (Channel_2__c like :ChannelLike) ';
             //   searchCondition +=  getSearchConditionByViewName(userId,userName);        
                
            
            }else if(searchColumnName == 'LeadSource' && searchValue != null && searchValue != ''){
                system.debug('Search value stage...'+searchValue);
                LeadSourceLike = '%' + searchValue + '%';
                searchCondition = ' AND (Lead_Source_2__c like :LeadSourceLike) ';
            //    searchCondition +=  getSearchConditionByViewName(userId,userName);        
                
            }
            else if(searchColumnName == 'SiteDesignPriority' && searchValue != null && searchValue != '')
            {
                SiteDesignPriority = '%' + searchValue + '%';
                searchCondition = ' AND (Site_Design_Priority__c like :SiteDesignPriority) ';
                
            }
            
            
        }
        /* else{
                searchCondition = getSearchConditionByViewName(userId,userName);
        }  */         
        
        // String soqlQuery = 'Select ID,Name,Ready_For__c,address__c,Accountid,Account.name,Amount,StageName,CloseDate,CreatedDate,Homeowner_Full_Name__c,Homeowner_Email__c,Phone__c,Sales_Representative__c,Utility_Company__c,street__c,city__c,state__c,zip_code__C ,(select Contact.Name,Contact.email,Contact.phone from OpportunityContactRoles where isprimary=true)'; 
           String soqlQuery = 'Select id,name,createddate,Site_Designer__c,Account.name,Site_Designer__r.name,Site_Design_Priority__c,Site_Design_Status__c,Ready_for__c,Install_Partner__c,Install_Partner__r.name,Install_Branch_Id__c,Install_Branch_Id__r.name,Channel_2__c,Lead_Source_2__c,Sales_Partner__c,Sales_Partner__r.name,SalesRep__r.name,Site_Design_Requested__c,Lastmodifieddate,(select id,contact.name from OpportunityContactRoles where isprimary=true)';
        soqlQuery += ' from Opportunity ';
    //  soqlQuery += ' where Site_Design_Status__c=:Status';
    //  soqlQuery += ' where (Site_Design_Priority__c!=null AND Site_Design_Requested__c!=null AND Site_Design_Status__c=:Status AND Install_Partner__r.name=:InstallPartner AND Ready_for__c=:ReadyFor) OR(Site_Design_Priority__c!=null AND Ready_for__c=:ReadyForRedesign AND Site_Design_Requested__c!=null )';
        soqlQuery += ' where (Site_Design_Priority__c!=null AND Site_Design_Requested__c!=null AND Site_Design_Status__c=:Status AND Install_Partner__r.name=:InstallPartner AND Ready_for__c=:ReadyFor) ';
        soqlQuery += searchCondition;
  //    soqlQuery += ' ORDER BY LastModifiedDate desc' ;
        soqlQuery += ' ORDER BY Site_Design_Priority__c Desc, Site_Design_Requested__c Asc' ;
        System.debug('Return Query:'+ soqlQuery);
        return soqlQuery;
        
    }
    
    public List<SelectOption> getSearchBy() {
        List<SelectOption> searchBy = new List<SelectOption>();
        searchBy.add(new SelectOption('name', 'Opportunity Name'));  
        searchBy.add(new SelectOption('Channel', 'Channel'));
        searchBy.add(new SelectOption('LeadSource', 'Lead Source'));
        searchBy.add(new SelectOption('SalesPartner', 'Sales Partner'));
        searchBy.add(new SelectOption('SiteDesignPriority', 'Site Design Priority'));
        System.debug('This is search by:'+searchBy);
        return searchBy;
    }
    public Pagereference userActions(){
        initialize();
        queryLists();
      //  queryOpptyList();
        calculatePageCount();
        return null;

    }
    public PageReference updateCounter()
   {
      // countdown=30;
       return null;
   }
     @RemoteAction
    public static Opportunity getlatestOppRecord(String OpportunityId)
    {
        if(OpportunityId !=null && OpportunityId !='')
        {
            List<Opportunity> lstLatest = [select id,name,Site_Designer__c,Site_Design_Status__c from Opportunity where Id=:OpportunityId];
            if(lstLatest !=null && lstLatest.size()>0)
                return lstLatest[0];
        }
        return null;
    }
  
    public class BaseException extends Exception {} 
    
    
     public Class MyWrapper {
        public Id id { get; set; }
        public string name { get; set; }
         public string CDT { get; set; }
        public datetime cdate { get; set; }
        public DateTime CurrentDate { get; set; }
         public String SiteDesigner {get; set;}
         public String SiteDesignStatus {get; set;}
         public String SalesPartner {get; set;}
         public String SalesRep {get; set;}
         public String SiteDesignPriority {get; set;}
         public String ReadyFor {get; set;}
         public datetime SiteDesignRequested {get; set;}
         public datetime ldate { get; set; } 
         public string lmDT { get; set; }
         public string SiteDesignRequestedDT {get; set;}
        public List<Lead> leadList {get; set;}
        public List<Opportunity> OpptyList {get; set;}
        public string OppContactRoleName{get;set;}
        public boolean IsSelected {get; set;}
        public MyWrapper(Lead l){
        //leadList = new List<Lead>();
        //OpptyList = new List<Opportunity>();
        this.id=l.id;
        this.name=l.name;  
        this.cdate=l.createddate;      
        }
        public MyWrapper(Opportunity o){
        //leadList = new List<Lead>();
        //OpptyList = new List<Opportunity>();
        this.id=o.id;
        this.name=o.name;        
        this.cdate=o.createddate;//.format('MM/dd/yy HH:mm a', 'PST');//GMT
        this.CDT=cdate.format('E MMM dd hh:mm:ss a yyyy', 'PST');//GMT
      //  this.CurrentDate= DateTime.newinstance(o.createddate);   
        this.ldate=o.LastModifiedDate;
        this.lmDT=ldate.format('E MMM dd hh:mm:ss a yyyy', 'PST');  
        this.SiteDesignRequested=o.Site_Design_Requested__c;
        this.SiteDesignRequestedDT=SiteDesignRequested.format('E MMM dd hh:mm:ss a yyyy', 'PST');    
        this.SiteDesigner=o.Site_Designer__r.name; 
        this.SiteDesignStatus=o.Site_Design_Status__c;
        this.SiteDesignPriority=o.Site_Design_Priority__c;
        this.SalesPartner=o.Sales_Partner__r.name;    
        this.SalesRep=o.SalesRep__r.name;
        this.ReadyFor=o.Ready_for__c;    
        if(!(o.OpportunityContactRoles.isempty()))
            this.OppContactRoleName = o.OpportunityContactRoles[0].contact.name;    
        else 
        {
         this.OppContactRoleName= null;
        }
    }
     }
}