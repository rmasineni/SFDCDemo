global class AuditPhotoUploaderController {
    public Set<String> documentTypes;
    public String docSignStatus {get;set;}
    public List<SelectOption> Status {get;set;}
    public String salesPartnerId {get;set;}
    public String installPartnerId {get;set;}       
    public Map<String, SR_Audit_Attachment__c> existingSRAttachments = new Map<String, SR_Audit_Attachment__c>();
    public Map<String, SR_Audit_Attachment__c> getExistingSRAttachments(){ return existingSRAttachments; }  
    public Map<String, Document_Classification__c> documentClasification = new Map<String, Document_Classification__c>();
    public Map<String, Document_Classification__c> getDocumentClasification() { return documentClasification; }
    public List<UploadedPhotos> listUploadedPhotos{get;set;}
    public Install_Audit__c ia {get;set;}
    public Set<String> setValidFileTypes{get;set;}
    private ApexPages.StandardSetController photoSet;
    public Map<Id, UploadedPhotos> photoMap {get;set;}
    public List<UploadedPhotos> attPhotos {get;set;}
    public Install_Audit__c installAuditObj{get;set;}
    public String GenAssetName {get;set;}
    public String SiteVisitDate {get;set;}
    public Integer GenAssetPhotoCount {get;set;}
    public String ProposalName {get;set;}
    public string accountName {get;set;}
	public string s3FolderName {get;set;}
         
    //CONSTRUCTOR
    public AuditPhotoUploaderController(){}
    public AuditPhotoUploaderController(Apexpages.Standardcontroller sc) {
        this.ia = (Install_Audit__c)sc.getRecord();
        attPhotos = PhotoListsToDisplay();
    }
    
    public String relatedObject{
        get;
        set{
            relatedObject = value;
            System.debug('relatedObject: ' + relatedObject);
            if(relatedObject != null && relatedObject != ''){
                installAuditObj = [Select Id, Name, Service_Contract__r.Id, Service_Contract__r.Agreement_Number__c, Service_Contract__r.Name, Service_Contract__r.Account.Name, Generation_Asset__r.Id, 
                                    Generation_Asset__r.Name, Generation_Asset__r.Account_Name__r.Name, Site_Visit_Date__c, 
                                    (Select Id, name from SR_Audit_Attachments__r where active__c = true)
                                    from Install_Audit__c where Id =:relatedObject];
                
                if(installAuditObj.Generation_Asset__r != null && installAuditObj.Generation_Asset__r.Id != null){
                    GenAssetName =  installAuditObj.Generation_Asset__r.Name;
                    s3FolderName = installAuditObj.Generation_Asset__r.Name;
                    accountName = installAuditObj.Generation_Asset__r.Account_Name__r.Name;
                }else if(installAuditObj.Service_Contract__r != null && installAuditObj.Service_Contract__r.Id != null){
                    GenAssetName =  installAuditObj.Service_Contract__r.Name;
                    accountName = installAuditObj.Service_Contract__r.Account.Name;
                    s3FolderName = installAuditObj.Service_Contract__r.Agreement_Number__c;
                }
                
                //GenAssetPhotoCount = Integer.ValueOf(installAuditObj.Number_of_Photos_Uploaded__c);
                GenAssetPhotoCount = 0;
                if(installAuditObj.SR_Audit_Attachments__r != null){
                    GenAssetPhotoCount = installAuditObj.SR_Audit_Attachments__r.size();
                }
                
                existingSRAttachments = SRAttachmentManager.getSRAuditAttachmentsInfo(relatedObject);
                setValidFileTypes = new Set<String>();
                for(ValidFileTypesForUpload__c vft:[select id, Name, FileTypes__c from ValidFileTypesForUpload__c where Name = 'PhotoUpload'])
                {
                    for(String s:vft.FileTypes__c.Split(';'))
                    {
                       setValidFileTypes.add(s);
                    }
                }                
            }
        }
    }

    public boolean getIsPartnerUser(){
        Boolean ispartnerUser = false;
        String userType = UserInfo.getUserType();
        if(userType != null && userType != ''){
            if(userType.contains('Partner'))
                return true;
        }
        return ispartnerUser;
    }
    
    public List<UploadedPhotos> getAllAttachedPhotos(){  
        relatedObject = ia.Id;
        listUploadedPhotos = new List<UploadedPhotos>();    
        for(SR_Audit_Attachment__c photo:[select Id, Name, Document_Name__c, Size__c, Active__c, Grand_Parent_Name__c, InstallAudit__r.Name, 
                                            InstallAudit__r.Service_Contract__r.Id, InstallAudit__r.Service_Contract__r.Name, InstallAudit__r.Service_Contract__r.Agreement_Number__c,
                                            InstallAudit__r.Generation_Asset__r.Id,  InstallAudit__r.Generation_Asset__r.Name, 
                                            Document_Name_On_File_Server__c, Thumbnail__c ,Document_Type_Name__c
                                            from SR_Audit_Attachment__c where InstallAudit__c = :relatedObject order by Active__c desc])
        {
            listUploadedPhotos.add(new UploadedPhotos(photo));
        }       
        return listUploadedPhotos;
    }
    
    public static Map<Id, UploadedPhotos> buildAttIdToUploadedPhotoMap(List<SR_Audit_Attachment__c> attPhotoList) {
        Map<Id, UploadedPhotos> photoMap = new Map<Id, UploadedPhotos>();
        for (SR_Audit_Attachment__c p : attPhotoList) {
                UploadedPhotos photo = new UploadedPhotos(p);
                photoMap.put(p.Id, photo);                
        }
        return photoMap;
    }
    
    
    
    public List<UploadedPhotos> PhotoListsToDisplay() {
       List<UploadedPhotos> listPhotos = new List<UploadedPhotos>();
       List<SR_Audit_Attachment__c> photoList = [select Id, Name, Document_Name__c, Size__c, Active__c, InstallAudit__r.Service_Contract__r.Name, InstallAudit__r.Service_Contract__r.Agreement_Number__c, InstallAudit__r.Generation_Asset__r.Name, Grand_Parent_Name__c, Document_Name_On_File_Server__c, Thumbnail__c,Document_Type_Name__c from SR_Audit_Attachment__c where InstallAudit__c = :relatedObject and Active__c = true order by Active__c desc];
       photoMap = buildAttIdToUploadedPhotoMap(photoList);       
       photoSet = PaginationHelper.getStdSetController(photoList, Integer.valueOf(System.Label.PhotosPerPage));
       List<UploadedPhotos> photos = new List<UploadedPhotos>();
       List<SR_Audit_Attachment__c> listAtt = photoSet.getRecords();
       for (SR_Audit_Attachment__c att: listAtt) {
            if (photoMap.containsKey(att.Id)) 
                photos.add(photoMap.get(att.Id));
       }
       return photos;
    }    
        
    public List<UploadedPhotos> getAttachedPhotos(){  
        listUploadedPhotos = new List<UploadedPhotos>();    
        for(SR_Audit_Attachment__c photo:[select Id, Name, Document_Name__c, Size__c, Active__c, Grand_Parent_Name__c, InstallAudit__r.Service_Contract__r.Agreement_Number__c, InstallAudit__r.Service_Contract__r.Name, InstallAudit__r.Generation_Asset__r.Name, Document_Name_On_File_Server__c, Thumbnail__c,Document_Type_Name__c from SR_Audit_Attachment__c where InstallAudit__c = :relatedObject and Active__c = true])
        {
            listUploadedPhotos.add(new UploadedPhotos(photo));
        }       
        return listUploadedPhotos;
    }
    
    // returns true if there are pages greater than the one being displayed.
    public Boolean hasNextPhotos {
        get {
            if(photoSet != null)
                return photoSet.getHasNext();
            else
                return false;
        } private set;
    }
    
    // returns true if there are pages less than the one being displayed.
    public Boolean hasPreviousPhotos {
        get {
            if(photoSet != null)
                return photoSet.getHasPrevious();
            else
                return false;
        } private set;
    }
    
    public PageReference nextPhotosPage() { 
        attPhotos = getPhotoListFromCompleteList(PaginationHelper.getNextSetOfRecords(photoSet), photoMap);        
        System.Debug('Photo Count: ' + attPhotos.size());                    
        return null;
    }
    
    public PageReference previousPhotosPage() {
        attPhotos = getPhotoListFromCompleteList(PaginationHelper.getPreviousSetOfRecords(photoSet), photoMap);
        return null;
    }    
    
     // get page number that is being displayed in results device table.
    public Integer photosPageNumber {
        get {
            if(photoSet != null)
                return photoSet.getPageNumber();
            else
                return 0;
        } set;
    }
    
    // get the total pages that were returned for photos.
    public Integer photosTotalPageNumber {
        get {
            if(photoSet != null)
                return PaginationHelper.getTotalNumberOfPages(photoSet);
            else
                return 0;
        } set;
    }
    
    public static List<UploadedPhotos> getPhotoListFromCompleteList(List<SR_Audit_Attachment__c> photoList, 
                                                                          Map<Id, UploadedPhotos> photoMap) {
        List<UploadedPhotos> attPhotos = new List<UploadedPhotos>();
        for (SR_Audit_Attachment__c p : photoList) {
            if (photoMap.containsKey(p.Id)) 
                attPhotos.add(photoMap.get(p.Id));
        }
        return attPhotos;
    }    
    
    global class UploadedPhotos
    {
        public String id{get;set;}
        public String name{get;set;}
        public String filename{get;set;}
        public String s3filename{get;set;}
        public String filesize{get;set;}
        public Boolean filestatus{get;set;} 
        public String signedURL{get;set;}
        public String thumbnail{get;set;}
        public String QSurl{get;set;}
        public String AttachedPhotoId{get;set;}
        public String testlink{get;set;}
        public SR_Audit_Attachment__c thephoto{get;set;}
        public String PhotoType {get;set;}
        public UploadedPhotos(SR_Audit_Attachment__c photo){
            id = photo.Id;
            name = photo.Name;
            filename = photo.Document_Name__c;
            s3filename = photo.Document_Name_On_File_Server__c;
            filesize = photo.Size__c;
            filestatus = photo.Active__c;
            signedURL = photo.Document_Name__c;           
            AttachedPhotoId = photo.Id;
            thephoto = photo;
            PhotoType =photo.Document_Type_Name__c;
            //thumbnail = 'http://c.cs17.content.force.com/servlet/rtaImage?eid=a1Jg0000000dCsV&amp;feoid=00Ng0000000U4iL&amp;refid=0EMg00000009Dm3';    
            //String parentObjectName = (photo.InstallAudit__r.Generation_Asset__r.Id != null ) ? photo.InstallAudit__r.Generation_Asset__r.Name : photo.InstallAudit__r.Service_Contract__r.Name;
            String parentObjectName =  photo.Grand_Parent_Name__c;
            System.debug('parentObjectName: ' + parentObjectName);
            System.debug('s3filename: ' + s3filename);
            thumbnail = SunRunS3RestConnection.getPhotoURL('GET', SunRunS3RestConnection.UPLOADED_PHOTOS_SETTINGS_NAME, parentObjectName, s3filename);
            thumbnail = thumbnail.Replace('%26', '&');
            QSurl = thumbnail.Replace('&','%26');   
        }
    }
    
    public PageReference UploadNewPhotos(){
        PageReference pr = new PageReference('/apex/GenAsset_PhotoUploader?id=' + ia.Id);       
        return pr;
    }

    public PageReference SaveChangesToAllUploadedPhotos(){
        List<SR_Audit_Attachment__c> listPhotos = new List<SR_Audit_Attachment__c>();
        Map<Id, Boolean> mapPhotoStatus = new Map<Id, Boolean>();       
        for(UploadedPhotos photo:listUploadedPhotos)
        {
           mapPhotoStatus.put(photo.Id, photo.filestatus);
        }
        if(!mapPhotoStatus.isEmpty())
        {
            for(SR_Audit_Attachment__c iap:[select Id, Name, Active__c from SR_Audit_Attachment__c where id in :mapPhotoStatus.keySet()])
            {
                iap.Active__c = mapPhotoStatus.get(iap.Id);
                listPhotos.add(iap);
            }  
            if(!listPhotos.isEmpty())
            {   
                System.Debug('list to update: ' + listPhotos);
                listUploadedPhotos = null;
                update listPhotos;
            }
        }           
        return null;
    }
        
    public PageReference SaveChangesToUploadedPhotos(){
        List<SR_Audit_Attachment__c> listPhotos = new List<SR_Audit_Attachment__c>();
        Set<Id> setIds = new Set<Id>();     
        for(UploadedPhotos photo:listUploadedPhotos)
        {
            if(!photo.filestatus)
            {
               setIds.add(photo.AttachedPhotoId); //listPhotos.add(photo.AttachedPhoto);
            }
        }
        if(!setIds.isEmpty())
        {
            for(SR_Audit_Attachment__c iap:[select Id, Name, Active__c from SR_Audit_Attachment__c where id in :setIds])
            {
                iap.Active__c = false;
                listPhotos.add(iap);
            }  
            if(!listPhotos.isEmpty())
            {   
                System.Debug('list to deactivate: ' + listPhotos);
                listUploadedPhotos = null;
                update listPhotos;
            }
        }           
        return null;
    }
    
    public PageReference doNothing(){
        List<UploadedPhotos> listPhotos = new List<UploadedPhotos>();
        listPhotos = getAttachedPhotos();
        return null;
    }

    public Set<String> getDocumentTypes(){
        init();        
        return documentTypes;
    }
    
    public void init(){
        if(documentTypes == null){
            documentTypes = new Set<String>();      
        }
        if(documentTypes.size() == 0){
            System.debug('relatedObject: ' + relatedObject);
            //installPartnerId = proposalObj.Install_Partner__c;
            //salesPartnerId = proposalObj.Sales_Partner__c;
            if(relatedObject == null || relatedObject == '')
            {
                relatedObject = System.currentPagereference().getParameters().get('id');
            }
            try{
            installAuditObj = [Select Id, Name, Generation_Asset__r.Account_Name__r.Name, Site_Visit_Date__c from Install_Audit__c where Id =:relatedObject];
            GenAssetName = installAuditObj.Name;
            s3FolderName = installAuditObj.Name;
            //SiteVisitDate = installAuditObj.Site_Visit_Date__c.format('MM/dd/yyyy');
            Set<String> modes = new Set<String>();
            modes.add('Edit');
            attPhotos = PhotoListsToDisplay();
            }
            catch(Exception e)
            {
                
            }
        }
    }
    public String getBaseURL() {
        String baseURL = EDPUtil.getBaseURL();
        return baseURL;
    } 
    
    @RemoteAction
    global static String updateStatus(List<String> listToUpdate){
        try{
        List<SR_Audit_Attachment__c> listSRGAA = new List<SR_Audit_Attachment__c>();
        Set<String> setIds = new Set<String>();
        setIds.addAll(listToUpdate);
        System.Debug('set to inactivate: ' + setIds);
        for(SR_Audit_Attachment__c srgaa:[select Id, Name, Active__c from SR_Audit_Attachment__c where Id in :setIds]){
            srgaa.Active__c = false;
            listSRGAA.add(srgaa);
        }
        if(!listSRGAA.isEmpty())
        {
            update listSRGAA;
        }
        }
        catch(DMLException dmlex)
        {
            return dmlex.getMessage();
        }
        catch(Exception ex)
        {
            return ex.getMessage();
        }
        return 'Success';
    }
    
    @RemoteAction
    global static List<UploadedPhotos> getAttachedPhotosAfterUpload(String iaId){
        List<UploadedPhotos> listUploadedPhotosAfterUpload = new List<UploadedPhotos>();
        for(SR_Audit_Attachment__c photo:[select Id, Name, Document_Name__c, Size__c, Active__c, InstallAudit__r.Generation_Asset__r.Id, InstallAudit__r.Service_Contract__r.Id,  
                                            InstallAudit__r.Generation_Asset__r.Name, InstallAudit__r.Service_Contract__r.Name, InstallAudit__r.Service_Contract__r.Agreement_Number__c, Grand_Parent_Name__c,
                                            Document_Name_On_File_Server__c, Thumbnail__c,Document_Type_Name__c
                                                from SR_Audit_Attachment__c
                                                where InstallAudit__c = :iaId 
                                                  and Active__c = true
                                                  order by CreatedDate desc])
        {
            Install_Audit__c instObj = [Select Id, Generation_Asset__r.Id, Service_Contract__r.Id from  Install_Audit__c where Id =:iaId];
            
            System.debug('instObj.InstallAudit__r.Service_Contract__r.Id: ' + instObj.Service_Contract__r.Id);
            System.debug('photo.InstallAudit__r.Service_Contract__r.Name: ' + photo.InstallAudit__r.Service_Contract__r.Name);
            listUploadedPhotosAfterUpload.add(new UploadedPhotos(photo));
            System.debug('photo.Thumbnail__c: ' + photo.Thumbnail__c);
        } 
        return listUploadedPhotosAfterUpload;
    }

    @RemoteAction
    global static Map<String, Document_Classification__c> getDocumentClassificationByCategroy(String proposalId){
        //Proposal__c proposalObj = [Select Id, Install_Partner__c, Sales_Partner__c from Proposal__c where Id =:proposalId];
        String categoryType = EDPDocumentSettings.MANUAL_UPLOAD;
        Set<String> modes = new Set<String>();
        modes.add(EDPUtil.EDIT);
        Map<String, Document_Classification__c> docClassificationMap = EDPDocumentSettings.getDocumentClassificationByCategroy(
                                                    categoryType, null, modes, 
                                                    null,
                                                    null);
        return docClassificationMap;
    }
    
    //added method to getphototypes
     @RemoteAction
    global static Map<String, Document_Classification__c> getPhotoTypes(String proposalId){
        //Proposal__c proposalObj = [Select Id, Install_Partner__c, Sales_Partner__c from Proposal__c where Id =:proposalId];
        String categoryType = EDPDocumentSettings.PHOTO_TYPE;
        Set<String> modes = new Set<String>();
        modes.add(EDPUtil.EDIT);
        Map<String, Document_Classification__c> docClassificationMap = EDPDocumentSettings.getPhotoTypes(categoryType);
        system.debug('docClassificationMap>>' +  docClassificationMap);
        return docClassificationMap;
    }

    
    
    @RemoteAction
    global static ExistingAttachmentsResponse checkexistingSRAttachments(String relatedObjectId, Map<String, String> newAttachments){ 
        ExistingAttachmentsResponse responseObj = new ExistingAttachmentsResponse();
        system.debug('relatedObjectId'+relatedObjectId);
        String result = '';
        String overwriteExistingDocs = '';
        String errMsg = '';
        
        Set<String> proposalStagesAllowedForUplaod = new Set<String>();
        
        proposalStagesAllowedForUplaod.add(EDPUtil.CREATED);
        proposalStagesAllowedForUplaod.add(EDPUtil.ON_HOLD);
        proposalStagesAllowedForUplaod.add(EDPUtil.PENDING);
        proposalStagesAllowedForUplaod.add(EDPUtil.SR_DECLINED);
            
        Set<String> proposalStagesCondAllowedForUplaod = new Set<String>();
        
        proposalStagesCondAllowedForUplaod.add(EDPUtil.SUBMITTED);
        proposalStagesCondAllowedForUplaod.add(EDPUtil.CREDIT_APPROVED);
        proposalStagesCondAllowedForUplaod.add(EDPUtil.CREDIT_REVIEW);
        proposalStagesCondAllowedForUplaod.add(EDPUtil.SR_OPS_RECEIVED);
        proposalStagesCondAllowedForUplaod.add(EDPUtil.SR_OPS_REVIEWED);
        proposalStagesCondAllowedForUplaod.add(EDPUtil.SR_OPS_APPROVED);
        proposalStagesCondAllowedForUplaod.add(EDPUtil.PENDING_TASK_COMPLETED);
            
        Set<String> eSignStatusNotInProgress = new Set<String>();
            
        eSignStatusNotInProgress.add(EDPUtil.VOIDED);
        eSignStatusNotInProgress.add(EDPUtil.NOT_SENT);
        
        Map<String, SR_Audit_Attachment__c> tempExistingSRAttachments = SRAttachmentManager.getSRAuditAttachmentsInfo(relatedObjectId);
        System.debug('tempExistingSRAttachments'+ tempExistingSRAttachments);
        
        Map<String, Document_Classification__c> documentClasification = new Map<String, Document_Classification__c>();
        documentClasification = getDocumentClassificationByCategroy(relatedObjectId);
        System.debug('documentClasification'+ documentClasification);
        
        Install_Audit__c installAuditObj = [Select Id from Install_Audit__c where Id =:relatedObjectId];
        
        Map<Id, String> docTypeIdToName = new Map<Id, String>();
        for(Document_Classification__c docTypeAndId:[select Id, name from Document_Classification__c]){
            docTypeIdToName.put(docTypeAndId.Id, docTypeAndId.name);
        }

        if(tempExistingSRAttachments == null || tempExistingSRAttachments.size() == 0) {
            System.debug('inside tempExistingSRAttachments');
            return responseObj;
        }
        
        Set<String> existingSignedDocs = new Set<String>();
        for(SR_Audit_Attachment__c srAttachmentObj : tempExistingSRAttachments.values()){
            Document_Classification__c classificationObj = documentClasification.get(srAttachmentObj.Document_Type_Name__c);
            if(classificationObj != null && classificationObj.ESignature_allowed__c == true){
                existingSignedDocs.add(srAttachmentObj.Document_Type_Name__c);
            }
        }

        for(String newDocumentType : newAttachments.keySet()){
            System.debug('newDocumentType'+ newDocumentType);
            String newFileName = newAttachments.get(newDocumentType);
            String newDocuTypeName = docTypeIdToName.get(newDocumentType);
            
            if(existingSignedDocs.contains(newDocuTypeName)){
                overwriteExistingDocs +=  newDocuTypeName + '\n';
            }

            SR_Audit_Attachment__c attchInfo = tempExistingSRAttachments.get(newDocuTypeName);
            
            system.debug('Attach Info= '+attchInfo);
            boolean allowToOverWrite = false;
            boolean isInFlight = false;
            String docuSignStatus = '';
            if(attchInfo != null && installAuditObj != null) {
                System.debug('newDocumentType'+ newDocumentType);
                if(newDocumentType != EDPUtil.OTHER){
                    System.debug('In Side not Others');
                    System.debug('attchInfo Document_Name__c:.....:'+attchInfo.Document_Name__c);
                    System.debug('NEW FILE NAME:.....:'+newFileName);
                    //if(attchInfo.Document_Name__c != null && attchInfo.Document_Name__c != '' && attchInfo.Document_Name__c != newFileName){
                        System.debug('In side Document_Name__c');
                        
                        //docuSignStatus = attchInfo.DocuSign_Status__c;
                        system.debug('Esignature Status:' + docuSignStatus);
                        
                        if(docuSignStatus != null && docuSignStatus != '' && !eSignStatusNotInProgress.contains(docuSignStatus)) {
                            isInFlight = true;
                        }
                        if(documentClasification != null && documentClasification.get(newDocuTypeName) != null) {
                            
                            allowToOverWrite = documentClasification.get(newDocuTypeName).Allow_To_Over_Write__c;
                            System.debug('allowToOverWrite INSIDE If'+allowToOverWrite);
                        }
                        System.debug('allowToOverWrite'+allowToOverWrite);
                        System.debug('isInFlight'+isInFlight);
                        
                        
                        //Checking Whether Document eSign In in Progress or Completed
                        if(isInFlight){
                            //System.debug('Err Msg: '+ CustomErrorMessages.IN_FLIGHT_ERROR);
                            errMsg = CustomErrorMessages.eSignature_ERROR(newDocuTypeName);
                            result += (result == '' ) ? errMsg : ' \n ' + errMsg ;
                            continue;
                        }
                        /*if(proposalStagesAllowedForUplaod.contains(proposalStage)){
                            if( !isInFlight ){
                                //result = '';
                                system.debug('if not in flight');
                                continue;
                            }
                        }
                        
                        if(proposalStagesCondAllowedForUplaod.contains(proposalStage)){
                            system.debug('Conditional Allow Starts...');
                            System.debug('documentClasification.get(newDocumentType)'+documentClasification.get(newDocuTypeName));
                            System.debug('documentClasification.get(newDocumentType).Partner_Document_Relationships__r'+documentClasification.get(newDocuTypeName).Partner_Document_Relationships__r);
                            Partner_Document_Relationship__c ptrDocRelObj;
                            if(documentClasification != null && documentClasification.get(newDocuTypeName).Partner_Document_Relationships__r != null 
                                && documentClasification.get(newDocuTypeName).Partner_Document_Relationships__r.size() > 0){
                                ptrDocRelObj = documentClasification.get(newDocuTypeName).Partner_Document_Relationships__r[0];
                                
                                system.debug('ptrDocRelObj:....'+ptrDocRelObj);
                            }
                            
                            system.debug('ptrDocRelObj.Mandatory_Document__c:....'+ptrDocRelObj.Mandatory_Document__c);
                            // When Doc is Mandatory
                            if(ptrDocRelObj != null && ptrDocRelObj.Mandatory_Document__c == true ){
                                //TODO
                                system.debug('Err Msg: '+ CustomErrorMessages.MANDATORY_ERROR);
                                errMsg =  newDocuTypeName + ' - ' + CustomErrorMessages.MANDATORY_ERROR ;
                                result += (result == '' ) ? errMsg : ' \n ' + errMsg;   
                                continue;                   
                            }
                            
                            //When Not Mandatory, is not in flight and is not overwritten
                            if(!isInFlight && ptrDocRelObj != null && ptrDocRelObj.Mandatory_Document__c == false ){
                                
                                system.debug('Inside Not Mandatory...');
                                if(!allowToOverWrite){
                                //TODO
                                    system.debug('Err Msg: '+ CustomErrorMessages.EXISTING_ERROR);
                                    errMsg =  newDocuTypeName + ' - ' + CustomErrorMessages.EXISTING_ERROR ;
                                    result += (result == '' ) ? errMsg : ' \n ' + errMsg;   
                                    continue;   
                                }
                                else if(allowToOverWrite) {
                                    system.debug('if overwrite is true');
                                    continue;
                                }
                            }
                            
                            
                        }*/
                        
                    //}
                }
            }   
        } 
        
        if(result != ''){
            responseObj.errorMessage = result;
            responseObj.status = 'Error';
        }else if(overwriteExistingDocs != ''){
            overwriteExistingDocs = 'Would you like to replace the following document(s) ? \n ' + overwriteExistingDocs;
            responseObj.errorMessage = overwriteExistingDocs;
            responseObj.status = 'Confirm';
        }

        system.debug('RESULT...:'+result);
        return responseObj; 
    }  

    @RemoteAction
    global static SunRunProxyRequestInfo getS3ProxyInfoForPut(String GenAssetName, String objectName, String mimeType){
        SunRunProxyRequestInfo requestInfo;
        System.Debug('mimeType = ' + mimeType);
        requestInfo = SunRunS3RestConnection.getPhotoURL('PUT', SunRunS3RestConnection.UPLOADED_PHOTOS_SETTINGS_NAME, GenAssetName, objectName, mimeType);
        return requestInfo;
    }
    
    //@RemoteAction
    //global static String getSignedURL(String actionType, String objectName, String mimeType){
    //  String url;
    //  if(actionType != null && actionType != '' && actionType == 'PUT'){
    //          url = S3GateKeeper.getSignedUrlForPut(objectName, mimeType);
    //          return url;
    //  }else if(actionType != null && actionType != '' && actionType == 'GET'){
    ///     url = S3GateKeeper.getSignedUrlForGET(objectName);
    //      return url;      
    //  }
    //  return ''; 
    //}

    @RemoteAction
    global static SRUpsertResponse upsertSRGenAssetAttachment(String parentObjectId, String fileName, String amazonS3FileName, 
                                                    String contactDocumentType, String contactDocumentTypeName, 
                                                    String fileSize, String contactDocumentWetSign){
        System.Debug('inside the upsertSRAttachment call from VF');
        FileUploaderComponent.UpsertRequest requestObj = new FileUploaderComponent.UpsertRequest();
        requestObj.relatedObjectId = parentObjectId;
        requestObj.fileName = fileName;
        requestObj.amazonS3FileName = amazonS3FileName;
        requestObj.documentType = contactDocumentType;
        requestObj.documentTypeName = contactDocumentTypeName; 
        requestObj.size = fileSize;
        requestObj.wetSign = contactDocumentWetSign;
        
        System.debug('requestObj: ' + requestObj);
        Boolean result = SRAttachmentManager.upsertSRAuditAttachment(requestObj);
        SRUpsertResponse responseObj = new SRUpsertResponse();
        responseObj.fileName = requestObj.fileName;
        if(result == true){
          responseObj.status = 'Success';
    
        }else{
          responseObj.status = 'Failure';
        }
        return responseObj;
    }

    global class UpsertRequest{
        public String relatedObjectId{get;set;} 
        public String fileName{get;set;}
        public String amazonS3FileName{get;set;}
        public String documentType{get;set;}
        public String documentTypeName{get;set;}
        public String size{get;set;}
        public String wetSign{get;set;}
    }
    
    global class SRUpsertResponse{
        public String status{get;set;}
        public String fileName{get;set;}
    }
    
    global class ExistingAttachmentsResponse{
        public ExistingAttachmentsResponse(){
            errorMessage = '';
            status = '';
        }
        public String status {get;set;}
        public String errorMessage {get;set;}
    }   
    
    
    @RemoteAction
    global static String deleteSelectedRecords(String test){
        Set<Id> selectedIds = new Set<Id>(); 
        System.debug('selectedIds: ' + selectedIds);
        String statusMessage = '';
        if(selectedIds == null || selectedIds.size() == 0){
            statusMessage = 'Select a record to delete';
        }else{
            /*Map<Id, SR_Audit_Attachment__c> selectedSRAttachments = new Map<Id, SR_Audit_Attachment__c>();
            
            String soqlStr = SRAttachmentManager.getSRAttachmentSOQL();
            soqlStr += '  where Id in : selectedIds ' ;
            for(SR_Audit_Attachment__c srAttachmentObj : Database.query(soqlStr)){
                selectedSRAttachments.put(srAttachmentObj.Id, srAttachmentObj);
            }
            if(selectedSRAttachments.size() > 0){
                delete selectedSRAttachments.values(); 
            }
            statusMessage = 'Selected records have been deleted successfully';*/
        }
        return statusMessage;    
    }
    
    @RemoteAction
    global static String DocSignStatus(String strDocType){
        system.debug('In DocSignStatus :: '+ strDocType);
        Map<String, Document_Classification__c> mapDocDetails = EDPDocumentSettings.getDocumentSettingsInformation();
        system.debug('In DocSignStatus 1:: '+ mapDocDetails);
        if(strDocType == null || strDocType == '')
            return 'Document Type is not selected.';
        
        Document_Classification__c documentClassificationObj = mapDocDetails.get(strDocType);
        system.debug('In DocSignStatus 2:: '+ documentClassificationObj);
        if(documentClassificationObj != null){
            List<Partner_Document_Relationship__c> partnerDocumentRelationships =  documentClassificationObj.Partner_Document_Relationships__r;     
            if(partnerDocumentRelationships != null && partnerDocumentRelationships.size() > 0){
                Partner_Document_Relationship__c ptrRelationshipObj = partnerDocumentRelationships[0];
                if(ptrRelationshipObj.Customer_signature_required__c || 
                    ptrRelationshipObj.Partner_signature_required__c || 
                    ptrRelationshipObj.SR_Ops_signature_required__c){
                    if(documentClassificationObj.Source_System__c == EDPUtil.PROPOSAL_TOOL_SOURCE){
                        return EDPUtil.SIGNED;
                    }else{
                        return EDPUtil.SIGNED + ',' + EDPUtil.UNSIGNED;
                    }
                }else{
                    return EDPUtil.NA;
                }               
            }       
        }
        return EDPUtil.NA;

    }

    //static String awsFolderName =  'incompleteSignedDoc';
    //static String SunRunProxyAccessKey = 'AKIAI6QXLSPZQUZUDNOQ';
    //static String SunRunProxySecretAccessKey = 'DealDocManager-secretAccessKey-client';    
    
    @RemoteAction
    global static Map<String, String> getSunRunProxyDetails(String objectName, String mimeType){
        Map<String, String> resultMap = new Map<String, String>(); 
        /*
        String fileName = objectName ;
        DateTime d = System.now();
        String timeFormat = d.formatGmt('EEE, dd MMM yyyy HH:mm:ss') + ' GMT';
        resultMap.put('Timestamp', timeFormat);

        System.debug('timeFormat: ' + timeFormat);
        string serviceEndPoint = 'http://ec2-54-235-57-215.compute-1.amazonaws.com:8080/' + awsFolderName + '/' + fileName;
        resultMap.put('Endpoint', serviceEndPoint);
        String encodedPath = 'sparrowproxytest-dest-sunrun/' + awsFolderName + '/'+ fileName ;

        String buf = 'PUT' + '\n\n' + 'application/pdf' + '\n' + timeFormat + '\n' + '/' + encodedPath;
        System.debug('buf : ' + buf);
        string signature  = S3GateKeeper.make_sig2(buf);        
        resultMap.put('Authorization', signature);
        */
                
        return resultMap;
    }
}