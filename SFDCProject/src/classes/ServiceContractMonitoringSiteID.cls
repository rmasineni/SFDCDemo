public with sharing class ServiceContractMonitoringSiteID {

    public string fullPathFileName {get;set;}   
    public transient Blob fileBody {get;set;}   
    public string acctName {get;set;}
    public string custRefNum {get;set;}
    public string custMailAddress {get;set;}
    private List<ServiceContractWrapper> serviceContracts;
    public String selCC {get;set;}
    public string finalMsg {get; set;}
    static final String cancelledStatus1 = 'Deal Cancelled'; 
    static final String cancelledStatus2 = 'Deal Cancelled due to credit';
    public string subject;
    public string emailBody;
    public string toAddress = Label.SunrunOperationEmail;
    
    public String serialNumber{get;set;}
    public String ssiCode{get;set;}
    public String notes{get;set;}
    public Boolean displayServiceContracts{get;set;}
    public boolean showEditSec {get; set;}
    public boolean showReadSec {get; set;}
    public boolean showUploadButton {get; set;}
    public boolean showSaveButton {get; set;}
    public boolean confirmSave {get;set;}
    public boolean dupSerialNum {get;set;}
    public String tempSerialNum {get;set;}
    public RecordType meterRegisRecType {get;set;}
    List<Asset__c> selectedAssetList {get;set;}
       public String meterTypeName{get;set;}
    private String first_picklist_option = ''; 
    private final Asset__c asset1 = new Asset__c();
    public string customerName {get;set;} 
    public List<Asset__c> getAllAssetList {get;set;}
     
    
    public Generation_Assets__c selectedGenAsset{
        get{
            if(selectedGenAsset == null){
                selectedGenAsset = new Generation_Assets__c();
            }
            return selectedGenAsset;
        }
        set;
    }
    
    public Service_Contract_Event__c selectedSCEvent{
        get{
            if(selectedSCEvent == null){
                selectedSCEvent = new Service_Contract_Event__c();
                selectedAssetList = new List<Asset__c>();
            }
            return selectedSCEvent;
        }
        set;
    }
    
    public Service_Contract_Event__c inputSCEvent{
        get{
            if(inputSCEvent == null){
                inputSCEvent = new Service_Contract_Event__c();
            }
            return inputSCEvent;
        }
        set;
        
    }
    
    public ServiceContractMonitoringSiteID(){
        System.debug('toAddress: ' + toAddress);
        initDisplayValues();       
        getAllAssetList = new  List<Asset__c>(); 
    }
    
    private void initDisplayValues(){
        showEditSec = true;
        showReadSec = false;
        showUploadButton = false;
        showSaveButton = true;
        confirmSave = false;
        dupSerialNum = false;
        serialNumber = '';
        tempSerialNum = '';
        ssiCode = '';
        notes = '';
        first_picklist_option = '';
        displayServiceContracts = false;
       // checkLoginUser();
        meterTypeName ='SS iTRon';
        meterRegisRecType = [Select Id,name from RecordType Where SobjectType = 'Case' and Name = 'Meter Registration'];
    }
    
 /*   public void checkLoginUser(){
        Id userId = UserInfo.getUserId();
        //User userObj = [Select Id, contactId, companyname from User where Id =:userId ];
        Contact contactObj = PRMContactUtil.getLoginUserAccountAndContact();
        if(contactObj != null && contactObj.Id != null){
            //Contact contactObj = [Select Id, Ultimate_Parent_Account__c, Ultimate_Parent_Account__r.name from Contact where Id =:contactObj.Id];
            if(contactObj.Ultimate_Parent_Account__r.name == 'REC Solar' || 
                contactObj.Ultimate_Parent_Account__r.name == 'Verengo' || 
                contactObj.Ultimate_Parent_Account__r.name == 'Sunrun')
            {
            showUploadButton = true;
            } 
                    
        }
    }*/
    
    /*** File Attachment ***/
    public Attachment attachmentFile
    {
        get 
        {
            if (attachmentFile == null)
            {
                attachmentFile = new Attachment();
            }
        return attachmentFile;
        }
      set;
    }

    public List<ServiceContractWrapper> getServiceContracts(){
        serviceContracts = new List<ServiceContractWrapper>();
        if(con != null){
            List<Service_Contract_Event__c> tempServiceContracts = con.getRecords();
            serviceContracts =  populateServiceContractWrappersList(tempServiceContracts);           
        }
        return serviceContracts;
    }
    
    private List<ServiceContractWrapper> populateServiceContractWrappersList(List<Service_Contract_Event__c> scEventList){
        System.debug('toAddress: ' + toAddress);
        List<ServiceContractWrapper> tempSCEventWrapperList = new List<ServiceContractWrapper>();
        ServiceContractWrapper tempWrapperObj = null;
        for(Service_Contract_Event__c scEventObject : scEventList){
            tempWrapperObj = new ServiceContractWrapper(null,scEventObject, null);
            tempSCEventWrapperList.add(tempWrapperObj);
        }
        return tempSCEventWrapperList;
    }

    public PageReference setSelCon()
    {
        return null;
    } 
    
    public PageReference doSearch() 
    {
        con = null;
        con = createSQOLConnection();   
        con.setPageSize(10);
        displayServiceContracts = true;
        return null;
        
    }
    
    
    //Get the List "Monitoring Service" assets based on customer name 
    public void getSelectionQueryforAsset(string accName){
        if(getAllAssetList!=null)  
            getAllAssetList = new  List<Asset__c>(); 
         String Meter='Monitoring Service';
         String sqlQuery = '';
         String originalAssetQuery = ServiceContractUtil.getAssetSOQL();
         String SQLWhereQuery = ' where Type__c = ' + '\'' + String.escapeSingleQuotes(Meter) + '\'';
         String scSQLWhereQuery = '';
          if (accName != null && accName != ''){
            scSQLWhereQuery += ' And ServiceContract__r.Customer_Name__c = ' + '\'' + String.escapeSingleQuotes(accName) + '\'';
         }
         string sqlOrderby=' order by LastModifiedDate desc';
         sqlQuery = originalAssetQuery;
         sqlQuery += SQLWhereQuery;
         sqlQuery += scSQLWhereQuery;
         sqlQuery += sqlOrderby;
         getAllAssetList= Database.query(sqlQuery);
                       
    }
    
    public String getSelectionQuery(){ 
        String scEventSQLQuery = ServiceContractUtil.getServiceContractEventSOQL();
        String scSQLWhereQuery = ' ';
        
     //  scSQLWhereQuery = ' Where ';
        if (acctName != null && acctName != '')
        {
            String likeQryString = '%' + acctName + '%';
            scSQLWhereQuery += ' Where Service_Contract__r.Customer_Name__c Like ' + '\'' + String.escapeSingleQuotes(likeQryString) + '\'';
        }
        if (custRefNum != null && custRefNum != '')
        {
            String likeQryString = '%' + custRefNum + '%';
          //  scSQLWhereQuery += ' And Service_Contract__r.Cust_Ref_Num__c Like ' + '\'' + String.escapeSingleQuotes(likeQryString) + '\'';
          //  scSQLWhereQuery += ' Where Service_Contract__r.Cust_Ref_Num__c Like ' + '\'' + String.escapeSingleQuotes(likeQryString) + '\'';
            if (acctName != null && acctName != '')
               {
                    scSQLWhereQuery += ' And Service_Contract__r.Cust_Ref_Num__c Like ' + '\'' + String.escapeSingleQuotes(likeQryString) + '\'';
               }
            else
            {
                scSQLWhereQuery += ' Where Service_Contract__r.Cust_Ref_Num__c Like ' + '\'' + String.escapeSingleQuotes(likeQryString) + '\'';
            }
        }        
        if (custMailAddress != null && custMailAddress != '')
        {
            String likeQryString = '%' + custMailAddress + '%';
            if (custRefNum != null && custRefNum != '')
             {
                  scSQLWhereQuery +=  ' And Service_Contract__r.Customer_Mailing_Address__c Like ' + '\'' + String.escapeSingleQuotes(likeQryString) + '\'';
             }
            else
            {
               scSQLWhereQuery +=  ' Where Service_Contract__r.Customer_Mailing_Address__c Like ' + '\'' + String.escapeSingleQuotes(likeQryString) + '\'';   
            }
            
        }
        
        String numberOfRows = '';
        if (!Test.isRunningTest())
        {
            numberOfRows += ' Limit 1000';
        }
        else
        {
            numberOfRows += ' Limit 10';
        }

        String sqlQuery = '';
        sqlQuery = scEventSQLQuery;
     //   sqlQuery += scEventSQLWhereQuery;
        sqlQuery += scSQLWhereQuery;
        sqlQuery += numberOfRows;
        system.debug(sqlQuery);

        return sqlQuery;
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

    private ApexPages.StandardSetController createSQOLConnection(){
        ApexPages.StandardSetController tempConnection;        
        String soqlQuery = getSelectionQuery();
        system.debug('----->'+soqlQuery );
        tempConnection = new ApexPages.StandardSetController(Database.getQueryLocator(soqlQuery));
        return tempConnection;          
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

    public class ServiceContractEventWrapper{
        public ServiceContractEventWrapper(){
            selected = false;
            assetList = new List<Asset__c>();
        }
        public Boolean selected{get;set;}
        public Service_Contract_Event__c scEventObj{get;set;}
        public List<Asset__c> assetList {get;set;}   
    }

    public Pagereference meterregistration(){
        if(selCC == null || selCC == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Select a Service Contract for Site  ID registration'));
            return null;
        }
        
        System.debug('selCC: ' + selCC);
        String sqlQuery = ServiceContractUtil.getServiceContractEventSOQL();
        String sqlWhere = ' Where Id =:selCC ';
        sqlQuery += sqlWhere;
            
        try{
            selectedSCEvent = (Service_Contract_Event__c) Database.query(sqlQuery);
            Set<Id> scIds = new Set<Id>();
            if(selectedSCEvent != null && selectedSCEvent.Id != null && 
                selectedSCEvent.service_Contract__c != null){
                scIds.add(selectedSCEvent.service_Contract__c);
                Map<Id, List<Asset__c>> scAssetMap = initializeMeterAssets(scIds);
                System.debug('scAssetMap: ' + scAssetMap);
                selectedAssetList = (scAssetMap != null && scAssetMap.containsKey(selectedSCEvent.service_Contract__c)) ? 
                                    scAssetMap.get(selectedSCEvent.service_Contract__c) : new list<Asset__c>();
                    system.debug(selectedSCEvent.service_Contract__r.Customer_Name__c);
                    //get the selected customer assets
                     customerName = selectedSCEvent.service_Contract__r.Customer_Name__c;
                    getSelectionQueryforAsset(customerName );
              
            }
        
        }catch (Exception e) {}
        return Page.ServiceContractSiteIDRegistrationForm;
    }
    
     public Pagereference batchUpload(){
         return Page.ServiceContractMeterRegFileUpload;
     }
    
    public Pagereference back(){
        System.debug('Meter registration back button ...');
        selCC = null;
        initDisplayValues();
        return Page.ServiceContractMonitoringSiteID;
    }
  
    public Pagereference SaveMeterRegis(){
            
        system.debug('Saving Start....'+serialNumber);
        system.debug('tempSerialNum..:' +tempSerialNum);
        if(tempSerialNum == serialNumber)
                    {confirmSave = true;}
                    else
                    {confirmSave = false;}  
                        
        if(serialNumber == Null || serialNumber == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter values for the required fields.'));
            return null;
        }
        
        if(meterTypeName == Null || meterTypeName == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter values for the required fields.'));
            return null;
        }
        String meterSerialNumbers = getSerialNumber(selectedAssetList);
       
                                        
        system.debug('Copying the Input Values to Selected Asset....');
        //TODO
        //if(selectedSCEvent.Meter_Registration_Date__c == null){
            selectedSCEvent.Meter_Registration_Date__c = date.Today();
        //}
        //selectedGenAsset.Notes_M_Registration__c = notes;
    //    try{
            system.debug('Updating Record...');
            String result = updateSerialNumber(serialNumber, ssiCode, selectedAssetList, meterSerialNumbers);
            if(result == null || result != ProposalUtil.SUCCESS){
                return null;    
                     }

            update selectedSCEvent; 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The Site ID Registration is Completed Successfully. Thank you!'));
        
        /*    Case newcase = new Case();
            newcase.Subject = 'New Meter Serial Number is Registered'; 
            newcase.Description = 'New Meter Serial Number is Registered for Service Contract' + selectedSCEvent.Service_Contract__r.name +'\r\n'+' The Meter Serial Number registered :'+serialNumber;
            newcase.notes__c = notes;
            newcase.Service_Contract__c = selectedSCEvent.Service_Contract__r.Id;
            newcase.RecordTypeID = meterRegisRecType.id;
            newcase.Status = 'Closed';
            insert newcase;
            Case tempCaseRec = [Select id,CaseNumber,notes__c From Case Where Id = :newcase.Id];
            system.debug('Inserted Case....'+tempCaseRec.id+'and'+tempCaseRec.CaseNumber);
            //createCase(caseSub,caseDesc,inputGenAsset, selectedGenAsset);
            subject = 'New Meter Serial Number is Registered';
            //String emailBody ;
            emailBody = UserInfo.getName() + ' Registered New Meter for Service Contract' + selectedSCEvent.Service_Contract__r.name;                    
            sendEmail2Sunops(tempCaseRec, selectedSCEvent, toAddress, subject, emailBody);
            showEditSec = false;
            showReadSec = true; 
            showSaveButton = false;  */
             //get recently saved meter details
          //  getSelectionQueryforAsset(customerName);
       // }   
      //  catch(Exception e){
      //  System.debug('Exception: '+e);
      //  }
       /** catch (System.DmlException exp){
            System.debug('Exception: ' + exp);
            if(exp != Null)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Duplicate value found:The Serial Number you have entered is associated with other Asset'));
            initDisplayValues(); 
        }  **/     
        return null;
    }        

    public class ServiceContractWrapper{
        public ServiceContract scAssetRec{get; set;}
        public Service_Contract_Event__c scEventRec{get; set;}
        public List<Asset__c> assetList{get; set;}
        public Boolean selected{get;set;}
        
        public Boolean recSelected {get; set;}
        public ServiceContractWrapper(){
            assetList = new List<Asset__c>();
        }
        public ServiceContractWrapper(ServiceContract scObj, Service_Contract_Event__c scEventObj, List<Asset__c> assets){
            scAssetRec = scObj;
            scEventRec = scEventObj;
            assetList = assets; 
            recSelected = false;
            selected = false;
        }
    }
    
      public void processDuplicateSerialNumber(){
        confirmSave = false;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The Monitoring ID Number Entered exists already with  another project,hence the details has been Sent for review and You will be contacted by SunRun Operations. Thank you!'));
        Case newcase = new Case();
         newcase.Subject = 'Duplicate Monitoring Site ID Number Registration';
         newcase.Description = 'User Entered Monitoring ID which Exists Already with another Asset.\r\n'+'Monitoring ID Number Entered by User:'+serialNumber;
         newcase.notes__c = notes;
         newcase.Service_Contract__c = selectedSCEvent.Service_Contract__r.Id;
         newcase.RecordTypeID = meterRegisRecType.id;
         insert newcase;
        Case tempCaseRec = [Select id,CaseNumber,notes__c From Case Where Id = :newcase.Id];
        system.debug('Inserted Case....'+tempCaseRec.id+'and'+tempCaseRec.CaseNumber);
        //createCase(caseSub,caseDesc,inputGenAsset, selectedGenAsset);
        subject = 'Duplicate Meter Serial Number Registration';
        //String emailBody ;
        emailBody = UserInfo.getName() + ' Tried to register a duplicate meter serial number for the below customer';                    
       // sendEmail2Sunops(tempCaseRec, selectedSCEvent, toAddress, subject, emailBody);
        showEditSec = false;
        showReadSec = true;
        showSaveButton = false;     
    } 
    
    private Map<Id, List<Asset__c>> initializeMeterAssets(set<Id> serviceCntractIds) {
        Map<Id, List<Asset__c>> scMeterAssetsMap = new Map<Id, List<Asset__c>>();
        if(serviceCntractIds != null && !serviceCntractIds.isEmpty()){
            String meterType = ServiceContractUtil.ASSET_TYPE_METER;
            String activeStr = ServiceContractUtil.ACTIVE;
            for(Asset__c assetObj :[Select Id, name, type__c, ServiceContract__c, Serial_Number__c,Monitoring_Site_ID__c,Vendor__c, SSI_Code__c, Status__c from Asset__c where status__c =:activeStr and ServiceContract__c in :serviceCntractIds]){
                List<Asset__c> meterAssets = (scMeterAssetsMap.containsKey(assetObj.ServiceContract__c)) ? scMeterAssetsMap.get(assetObj.ServiceContract__c) : new List<Asset__c>();
                meterAssets.add(assetObj);
                scMeterAssetsMap.put(assetObj.ServiceContract__c, meterAssets);
            }
        }
        return scMeterAssetsMap;
    }

    public String updateSerialNumber(String serialNumberStr, String ssiCodeStr, List<Asset__c> assetList, String meterSerialNumbers){
        String result = ProposalUtil.SUCCESS ;
        List<Asset__c> modifiedAssets = new List<Asset__c>();
        Asset__C parentAsset = null;
        Asset__c newMeterAsset = new Asset__c();
        newMeterAsset.Monitoring_Site_ID__c = serialNumberStr;
        newMeterAsset.Vendor__c = meterTypeName;
        newMeterAsset.Site_ID_Registration_Date__c = date.today();
        newMeterAsset.Type__c = 'Monitoring Service';
      //  newMeterAsset.SSI_Code__c = ssiCodeStr;
        newMeterAsset.ServiceContract__c = selectedSCEvent.service_contract__r.Id;
     //   newMeterAsset.Type__c = ServiceContractUtil.ASSET_TYPE_METER;
     //   newMeterAsset.Meter_Type__c = meterTypeName;
        
        System.debug('assetList: ' + assetList);
        if(assetList != null && !assetList.isEmpty()){
            for(Asset__c assetObj : assetList){
                if(assetObj.Type__c == ServiceContractUtil.ASSET && assetObj.status__c == ServiceContractUtil.ACTIVE){
                    parentAsset = assetObj;
                    newMeterAsset.Asset__c = assetObj.Id; 
                    break;
                }
            }   
        }
        try
        {
            insert newMeterAsset;
            
        }
        catch(exception ex)
        {
        return null;
      ///  ApexPages.addMessage();
         //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ''));
        }
        System.debug('>>> newMeterAsset ID ' + newMeterAsset.Id);
       /* if(selectedSCEvent.Meter_Registration_Date__c == null){
            selectedSCEvent.Meter_Registration_Date__c = Date.Today();
        } */
        
        Asset_Activity__c assetActivityObj = new Asset_Activity__c();
        assetActivityObj.Asset__c = newMeterAsset.Id;
        assetActivityObj.Meter_Registration_Date__c = Date.Today();
        assetActivityObj.Type__c = 'Meter Registration';
        assetActivityObj.Subtype__c = 'Meter Registration';
        //insert assetActivityObj;
        return result;
    }

    public String getSerialNumber(List<Asset__c> assetList){
        String tempSerialNumbers = '';
        if(assetList != null && !assetList.isEmpty()){
            for(Asset__c assetObj : assetList){
                if(assetObj.Type__c == ServiceContractUtil.ASSET_TYPE_METER && assetObj.Serial_Number__c != null 
                &&  assetObj.Serial_Number__c != ''){
                    tempSerialNumbers += (tempSerialNumbers != '') ? ' , ' + assetObj.Serial_Number__c : assetObj.Serial_Number__c ;
                }
            }           
        }   
        return tempSerialNumbers;       
    }

    public class BaseException extends Exception {} 
    
   
    
     public List<SelectOption> getVendor() {
        List<SelectOption> Vendors = new List<SelectOption>();
        Vendors.add(new SelectOption('', '')); 
        Vendors.add(new SelectOption('ABB', 'ABB')); 
         Vendors.add(new SelectOption('Enphase', 'Enphase'));
         Vendors.add(new SelectOption('Locus', 'Locus'));
         Vendors.add(new SelectOption('SolarEdge', 'SolarEdge'));
        
        return Vendors;
    } 
    

}