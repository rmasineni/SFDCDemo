public with sharing class MeterRegistrationController {

    public string fullPathFileName {get;set;}   
    public transient Blob fileBody {get;set;}  
    public string acctName {get;set;}
    public string custRefNum {get;set;}
    public string custMailAddress {get;set;}
    private List<GenerationAsset> genAssets;
    public String selCC {get;set;}
    public string finalMsg {get; set;}
    //public String errorMessage{get;set;}
    static final String cancelledStatus1 = 'Deal Cancelled';
    static final String cancelledStatus2 = 'Deal Cancelled due to credit';
    public string subject;
    public string emailBody;
    public string toAddress = Label.SunrunOperationEmail;
    
    public String serialNumber{get;set;}
    public String ssiCode{get;set;}
    public String notes{get;set;}
    
    public boolean showEditSec {get; set;}
    public boolean showReadSec {get; set;}
    public boolean showUploadButton {get; set;}
    public boolean showSaveButton {get; set;}
    public boolean confirmSave {get;set;}
    public boolean dupSerialNum {get;set;}
    public String tempSerialNum {get;set;}
    public RecordType meterRegisRecType {get;set;}
    //public boolean flag = false;
    
    public Generation_Assets__c selectedGenAsset{
        get{
            if(selectedGenAsset == null){
                selectedGenAsset = new Generation_Assets__c();
            }
            return selectedGenAsset;
        }
        set;
    }
    
    public Generation_Assets__c inputGenAsset{
        get{
            if(inputGenAsset == null){
                inputGenAsset = new Generation_Assets__c();
            }
            return inputGenAsset;
        }
        set;
        
    }
    
    public MeterRegistrationController(){
        initDisplayValues();        
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
        checkLoginUser();
        meterRegisRecType = [Select Id,name from RecordType Where SobjectType = 'Case' and Name = 'Meter Registration'];
    }
    
    public void checkLoginUser(){
        Id userId = UserInfo.getUserId();
        User userObj = [Select Id, contactId, companyname from User where Id =:userId ];
        if(userObj.contactId != null){
            Contact contactObj = [Select Id, Ultimate_Parent_Account__c, Ultimate_Parent_Account__r.name from Contact where Id =:userObj.contactId];
            if(contactObj.Ultimate_Parent_Account__r.name == 'REC Solar' || 
            	contactObj.Ultimate_Parent_Account__r.name == 'Verengo' || 
            	contactObj.Ultimate_Parent_Account__r.name == 'Sunrun')
            {
            showUploadButton = true;
            } 
                    
        }
    }
    
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
    Public Pagereference uploadMeterRegistrationDetails()
    {
        system.debug('File Upload-1...');
        if (fileBody != null && fullPathFileName != null && fileBody.size() > 5242880 ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Max attachment size is 5Mb'));
            return NULL;
        }
        else{
            Case attach2Case = new Case();
            attach2Case.Subject = 'For Batch Upload of Meter Registration';
            attach2Case.Description = 'User:' + UserInfo.getName() + ', Requested for a batch Upload of Meter Registration.';
            attach2Case.RecordTypeID = meterRegisRecType.id;
            insert attach2Case;
            Case tempCaseRec = [Select id,CaseNumber From Case Where Id = :attach2Case.Id];

           
            attachmentFile.Body = fileBody;   
            attachmentFile.Name = fullPathFileName;   
            system.debug('case id..'+tempCaseRec.Id);
            attachmentFile.ParentId = tempCaseRec.Id;
    
            try {
                insert attachmentFile;
                attachmentFile = new  Attachment();             
            }      
            catch (DMLException e) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading file'));
                return null;
            }
        
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'File uploaded successfully')); 

            system.debug('File Upload-2 ...');
            Id userId = UserInfo.getUserId();
            User userObj = [Select Id, contactId, companyname from User where Id =:userId ];
            Contact contactObj;
            if(userObj.contactId != null){
                contactObj = [Select Id, Ultimate_Parent_Account__c, Ultimate_Parent_Account__r.name from Contact where Id =:userObj.contactId];
            }
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            system.debug('Email Start.....');
            List<String> toAddresses = new List<String>();  
            toAddresses.add(toAddress);
            String subject = 'Meter Registration in Batches';
            String htmlBody = '<html>';
            htmlBody += EmailService.getHTMLHeader();
            htmlBody += '<p></p>';
            htmlBody += 'Hi SunRun Ops Team,';
            htmlBody += '<br/> <br/>';
            htmlBody += UserInfo.getName() + ' Uploaded file for Batch Meter Registration ';
            htmlBody += '<br/> <br/> Partner Name : '+ contactObj.Ultimate_Parent_Account__r.name;
            htmlBody += '<br/> <br/> A Case is opened for this and the case id is ' + tempCaseRec.CaseNumber;
            htmlBody += '<br/> The Uploaded File has been attaced to this Email and to the Case Created.';
            htmlBody += '<br/> <br/>';
            htmlBody += 'Thank you';
            htmlBody += '<br/> From <br/> SFDC Portal <br/> <br/>';
            htmlBody += EmailService.getHTMLFooter();
            htmlBody += '</html>';
            mail.setHtmlBody(htmlBody);
            mail.setSubject(subject);
            mail.setToAddresses(toAddresses);

            /** Attaching the File to Email**/
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            blob b = filebody;
            system.debug('Attaching to email...'+filebody);
            efa.setFileName(fullPathFileName);
            efa.setBody(b);
            system.debug('Attaching to email starts...');
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            system.debug('Attaching to email ends....');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            fileBody = null;
            fullPathFileName = null;
            return NULL;
        }
    }
    
    public List<GenerationAsset> getGenAssets(){
        genAssets = new List<GenerationAsset>();
        if(con != null){
            List<Generation_Assets__c> tempGenAssets = con.getRecords();
            genAssets =  populateGenerationAssetsList(tempGenAssets);           
        }
        return genAssets;
    }
    
    private List<GenerationAsset> populateGenerationAssetsList(List<Generation_Assets__c> genAssetList){
        List<GenerationAsset> tempGenAssetList = new List<GenerationAsset>();
        GenerationAsset tempGenAsset = null;
        for(Generation_Assets__c genAssetObj : genAssetList){
            tempGenAsset = new GenerationAsset();
            tempGenAsset.genAssetObj  = genAssetObj;
            tempGenAssetList.add(tempGenAsset);
        }
        return tempGenAssetList;
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
        return null;
    }
    
    public String getSelectionQuery(){ 
        String sqlQuery = 'Select Id, Install_Partner__c, Account_Name__r.Name, Name, Cust_Ref_Num__c , ' ;
        sqlQuery = sqlQuery + 'Customer_Name_Formula__c, Home_Address__c, M1_Proof_Upload_Date__c, M2_Proof_Upload_Date__c, ';
        sqlQuery = sqlQuery + 'M3_Proof_Upload_Date__c, M1_proof_panel_inverter_delivery__c, M2_proof_substantial_completion__c, '; 
        sqlQuery = sqlQuery + 'Meter_Serial_Num__c, ';
        sqlQuery = sqlQuery + 'Number_of_Sunrun_owned_Modules__c, System_Size_DC__c, Meter_Test_Date__c, PTO__c, Partner_PTO_proof_date__c, NTP_Granted__c, Rebate_Form_Sent__c ' ;
        sqlQuery = sqlQuery + 'From Generation_Assets__c Where NTP_Granted__c != null And ';
        sqlQuery = sqlQuery + 'Asset_Status__c NOT IN (' + '\'' + String.escapeSingleQuotes(cancelledStatus1) + '\'';
        sqlQuery = sqlQuery + ',' + '\'' + String.escapeSingleQuotes(cancelledStatus2) + '\'' + ')';
        //sqlQuery = sqlQuery + ' And Meter_Serial_Num__c = null ';
        
        if (acctName != null && acctName != '')
        {
            String likeQryString = '%' + acctName + '%';
             sqlQuery = sqlQuery + ' And Customer_Name_Formula__c Like ' + '\'' + String.escapeSingleQuotes(likeQryString) + '\'';
        }
        
        if (custRefNum != null && custRefNum != '')
        {
            String likeQryString = '%' + custRefNum + '%';
            sqlQuery = sqlQuery + ' And Cust_Ref_Num__c Like ' + '\'' + String.escapeSingleQuotes(likeQryString) + '\'';
        }

        if (custMailAddress != null && custMailAddress != '')
        {
            String likeQryString = '%' + custMailAddress + '%';
            sqlQuery = sqlQuery + ' And Customer_Mailing_Address__c Like ' + '\'' + String.escapeSingleQuotes(likeQryString) + '\'';
        }
        
        if((acctName == null || acctName == '') 
            && (custMailAddress == null || custMailAddress == '') 
            && (custRefNum == null || custRefNum == '')){
            sqlQuery = sqlQuery + ' And Meter_Serial_Num__c = null ';
        }
        
 
        /**if (!Test.isRunningTest())
        {
            sqlQuery = sqlQuery + ' Limit 1000';
        }
        else
        {
            sqlQuery = sqlQuery + ' Limit 10';
        }**/
        
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
    
    public class GenerationAsset{
        public GenerationAsset(){
            selected = false;
        }
        public Boolean selected{get;set;}
        public Generation_Assets__c genAssetObj{get;set;}   
    }

    public Pagereference meterregistration(){
        if(selCC == null || selCC == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Select a Generation Asset for meter registration'));
            return null;
        }

        String sqlQuery = 'Select Id, Install_Partner__c, Account_Name__r.Name, Name, Cust_Ref_Num__c , ' ;
        sqlQuery = sqlQuery + 'Customer_Name_Formula__c, Home_Address__c, M1_Proof_Upload_Date__c, M2_Proof_Upload_Date__c, ';
        sqlQuery = sqlQuery + 'M3_Proof_Upload_Date__c, M1_proof_panel_inverter_delivery__c, M2_proof_substantial_completion__c, '; 
        sqlQuery = sqlQuery + 'Meter_Serial_Num__c, ';
        sqlQuery = sqlQuery + 'Number_of_Sunrun_owned_Modules__c, System_Size_DC__c, Meter_Test_Date__c, PTO__c, Partner_PTO_proof_date__c, NTP_Granted__c, Rebate_Form_Sent__c ' ;
        sqlQuery = sqlQuery + 'From Generation_Assets__c Where Id =:selCC ';
        try{
        selectedGenAsset = (Generation_Assets__c) Database.query(sqlQuery);}
        catch (Exception e) {}
        return Page.MeterRegistrationSubmitform;
    }
    
     public Pagereference batchUpload(){
         return Page.MeterRegistrationFileUpload;
     }
    
    public Pagereference back(){
        System.debug('Meter registration back button ...');
        selCC = null;
        initDisplayValues();
        return Page.MeterRegistration;
    }
    public static void sendEmail2Sunops(Case caseRec, Generation_Assets__c genAssetRec, String toAdd, String Sub, String emailBody){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> toAddresses = new List<String>();
            toAddresses.add(toAdd);
            String subject = sub;
            String htmlBody = '<html>';
            htmlBody += EmailService.getHTMLHeader();
            htmlBody += '<p></p>';
            htmlBody += 'Hi SunRun Ops Team, <br/>';
            htmlBody += '<br/>';
            htmlBody += emailBody;
            htmlBody += '<br/> <br/> Generation Asset Name : '+ genAssetRec.Name;
            htmlBody += '<br/> Customer Name : '+ genAssetRec.Customer_Name_Formula__c;
            htmlBody += '<br/> <br/> A Case is opened for this and the case id is ' + caseRec.CaseNumber;
            htmlBody += '<br/> <br/>';
            htmlBody += 'Thank you';
            htmlBody += '<br/> From <br/> SFDC Portal <br/> <br/>';
            htmlBody += EmailService.getHTMLFooter();
            htmlBody += '</html>';
            mail.setHtmlBody(htmlBody);
            mail.setSubject(subject);
            mail.setToAddresses(toAddresses);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });         
            
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
        
        if((selectedGenAsset.Meter_Serial_Num__c != Null) && confirmSave == false){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'The Meter Serial Number has already been registered for the Selected Generation Asset. If this is a second meter for the same project or a replacement meter click Save to continue.'));
            confirmSave = true;
            tempSerialNum = serialNumber;
            return null;
        }
        if((selectedGenAsset.Meter_Serial_Num__c != Null) && confirmSave == true){   
            confirmSave = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The Online Meter Registration is only for New brand System. \n The entered details has been Sent for review and You will be soon contacted by SunRun Operations. Thank you!'));
            Case newcase = new Case();
            newcase.Subject = 'Online Meter Registration for Existing Project';
            newcase.Description = 'User tried to Register Meter Serial Number for an Exisitng Project which has meter registered already .\r\n'+'Meter Serial Number Entered by User : '+serialNumber + '\r\n Meter Serial Number for '+ selectedGenAsset.Name +' : '+selectedGenAsset.Meter_Serial_Num__c;
            newcase.notes__c = notes;
            newcase.Generation_Asset__c = selectedGenAsset.Id;
            newcase.RecordTypeID = meterRegisRecType.id;
            insert newcase;
            Case tempCaseRec = [Select id,CaseNumber,notes__c From Case Where Id = :newcase.Id];
            system.debug('Inserted Case....'+tempCaseRec.id+'and'+tempCaseRec.CaseNumber);
            //createCase(caseSub,caseDesc,inputGenAsset, selectedGenAsset);
            subject = 'Online Meter Registration for Existing Project';
            //String emailBody ;
            emailBody = UserInfo.getName() + ' Tried to register meter for an Exiting Project for the below customer';                    
            sendEmail2Sunops(tempCaseRec, selectedGenAsset, toAddress, subject, emailBody);
            showEditSec = false;
            showReadSec = true;
            showSaveButton = false;
            return null;
        }    
        
        if((selectedGenAsset.PTO__c != Null) && confirmSave == false){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'The PTO date has been updated for the Selected Asset for which Meter Registration cannot be done.To continue with the data entered, click Save!'));
            confirmSave = true;
            tempSerialNum = serialNumber;
            return null;
        }
        if((selectedGenAsset.PTO__c != Null) && confirmSave == true){   
            confirmSave = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The Online Meter Registration is only for New brand System. \n The entered details has been Sent for review and You will be soon contacted by SunRun Operations. Thank you!'));
            Case newcase = new Case();
            newcase.Subject = 'Online Meter Registration for Existing Project with has PTO date';
            newcase.Description = 'User tried to Register Meter Serial Number for an Exisitng Project which has PTO date .\r\n'+'Meter Serial Number Entered by User : '+serialNumber + '\r\n Meter Serial Number for '+ selectedGenAsset.Name +' : '+selectedGenAsset.Meter_Serial_Num__c;
            newcase.notes__c = notes;
            newcase.Generation_Asset__c = selectedGenAsset.Id;
            newcase.RecordTypeID = meterRegisRecType.id;
            insert newcase;
            Case tempCaseRec = [Select id,CaseNumber,notes__c From Case Where Id = :newcase.Id];
            system.debug('Inserted Case....'+tempCaseRec.id+'and'+tempCaseRec.CaseNumber);
            //createCase(caseSub,caseDesc,inputGenAsset, selectedGenAsset);
            subject = 'Online Meter Registration for Existing Project with has PTO date';
            //String emailBody ;
            emailBody = UserInfo.getName() + ' Tried to register meter for an Exiting Project for the below customer';                    
            sendEmail2Sunops(tempCaseRec, selectedGenAsset, toAddress, subject, emailBody);
            showEditSec = false;
            showReadSec = true;
            showSaveButton = false;
            return null;
        }
        
        if(serialNumber.length() != 8 && confirmSave == false)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'The Serial Number you have entered is not equal to 8 digits, which seems to be a non-Itron Meter.Please confirm the data again. If this is a non-Itron meter and you would like to continue click Save!'));
            confirmSave = true;
            tempSerialNum = serialNumber;
            return null;
        }
        if(serialNumber.length() != 8 && confirmSave == true) {
            confirmSave = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Online Meter Registration is for Itron Meters which holds only 8 digit Serial number. \n The entered details has been Sent for review and You will be soon contacted by SunRun Operations. Thank you!'));
            //PageReference dispMsg = new ApexPages.StandardController()
            Case newcase = new Case();
            newcase.Subject = 'Online Meter Registration for Non-Itron Meters';
            newcase.Description = 'User Entered an Meter Serial Number which is Not for Itron Meters.\r\n'+'Meter Serial Number Entered by User:'+serialNumber;
            newcase.notes__c = notes;
            newcase.Generation_Asset__c = selectedGenAsset.Id;
            newcase.RecordTypeID = meterRegisRecType.id;
            insert newcase;
            Case tempCaseRec = [Select id,CaseNumber,notes__c From Case Where Id = :newcase.Id];
            system.debug('Inserted Case....'+tempCaseRec.id+'and'+tempCaseRec.CaseNumber);
            subject = 'Online Meter Registration for Non-Itron Meters';
            //String emailBody ;
            emailBody = UserInfo.getName() + ' Tried to register meter for Non-Itron Meter for the below customer';                   
            sendEmail2Sunops(tempCaseRec, selectedGenAsset, toAddress, subject, emailBody);
            showEditSec = false;
            showReadSec = true;
            showSaveButton = false;
            return null;
        }
       
        
        List<Generation_Assets__c> allGenAsset = new List<Generation_Assets__c>();
        allGenAsset = [Select Meter_Serial_Num__c from Generation_Assets__c where Meter_Serial_Num__c != Null];
        for(Generation_Assets__c checkSerial : allGenAsset)
        {
            if(serialNumber == checkSerial.Meter_Serial_Num__c)
            {
                if(confirmSave == true)
                {
                    dupSerialNum = true;
                    if(tempSerialNum == serialNumber)
                    {confirmSave = true;}
                    else
                    {confirmSave = false;}
                }
                else
                {
                    dupSerialNum = true;
                }
            }
        }        
                 
        if(dupSerialNum == true && confirmSave == false){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'The Serial Number ' + serialNumber+ ' you have entered is associated with another project, please confirm the data again.To continue with the data entered, click Save!'));
            tempSerialNum = serialNumber;
            confirmSave = true;
            dupSerialNum = false;
            return null;
        }
        
            if(dupSerialNum == true && confirmSave == true){    
            confirmSave = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The Meter Serial Number Entered exists already with  another project,hence the details has been Sent for review and You will be contacted by SunRun Operations. Thank you!'));
            Case newcase = new Case();
            newcase.Subject = 'Duplicate Meter Serial Number Registration';
            newcase.Description = 'User Entered an Meter Serial Number which Exists Already with another Asset.\r\n'+'Meter Serial Number Entered by User:'+serialNumber;
            newcase.notes__c = notes;
            newcase.Generation_Asset__c = selectedGenAsset.Id;
            newcase.RecordTypeID = meterRegisRecType.id;
            insert newcase;
            Case tempCaseRec = [Select id,CaseNumber,notes__c From Case Where Id = :newcase.Id];
            system.debug('Inserted Case....'+tempCaseRec.id+'and'+tempCaseRec.CaseNumber);
            //createCase(caseSub,caseDesc,inputGenAsset, selectedGenAsset);
            subject = 'Duplicate Meter Serial Number Registration';
            //String emailBody ;
            emailBody = UserInfo.getName() + ' Tried to register a duplicate meter serial number for the below customer';                    
            sendEmail2Sunops(tempCaseRec, selectedGenAsset, toAddress, subject, emailBody);
            showEditSec = false;
            showReadSec = true;
            showSaveButton = false;
            return null;
        }
                                        
        system.debug('Copying the Input Values to Selected Asset....');
        selectedGenAsset.SSI_Code__c = ssiCode;
        selectedGenAsset.Meter_Test_Date__c = date.Today();
        selectedGenAsset.Meter_Serial_Num__c = serialNumber;
        //selectedGenAsset.Notes_M_Registration__c = notes;
        try{
            system.debug('Updating Record...');
            update selectedGenAsset; 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The Meter Registration is Completed Successfully. Thank you!'));
            Case newcase = new Case();
            newcase.Subject = 'New Meter Serial Number is Registered'; 
            newcase.Description = 'New Meter Serial Number is Registered for Generation Asset' + selectedGenAsset.name +'\r\n'+' The Meter Serial Number registered :'+serialNumber;
            newcase.notes__c = notes;
            newcase.Generation_Asset__c = selectedGenAsset.Id;
            newcase.RecordTypeID = meterRegisRecType.id;
            newcase.Status = 'Closed';
            insert newcase;
            Case tempCaseRec = [Select id,CaseNumber,notes__c From Case Where Id = :newcase.Id];
            system.debug('Inserted Case....'+tempCaseRec.id+'and'+tempCaseRec.CaseNumber);
            //createCase(caseSub,caseDesc,inputGenAsset, selectedGenAsset);
            subject = 'New Meter Serial Number is Registered';
            //String emailBody ;
            emailBody = UserInfo.getName() + ' Registered New Meter for Generation Asset' + selectedGenAsset.name;                    
            sendEmail2Sunops(tempCaseRec, selectedGenAsset, toAddress, subject, emailBody);
            showEditSec = false;
            showReadSec = true; 
            showSaveButton = false;  
        }   
        catch(Exception e){
        System.debug('Exception: '+e);
        }
       /** catch (System.DmlException exp){
            System.debug('Exception: ' + exp);
            if(exp != Null)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Duplicate value found:The Serial Number you have entered is associated with other Asset'));
            initDisplayValues(); 
        }  **/     
        
        //return page.meterregistrationsubmitform;
        system.debug('Saving Completed....');
        return null;
    }        

    public class BaseException extends Exception {} 
}