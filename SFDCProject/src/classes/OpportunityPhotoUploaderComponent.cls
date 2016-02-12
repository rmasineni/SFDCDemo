global class OpportunityPhotoUploaderComponent {
    public Set<String> documentTypes;
    public String docSignStatus {get;set;}
    public List<SelectOption> Status {get;set;}
    public String salesPartnerId {get;set;}
    public String installPartnerId {get;set;}       
    public Map<String, SR_Gen_Asset_Attachment__c> existingSRAttachments = new Map<String, SR_Gen_Asset_Attachment__c>();
    public Map<String, SR_Gen_Asset_Attachment__c> getExistingSRAttachments(){ return existingSRAttachments; }  
    public Map<String, Document_Classification__c> documentClasification = new Map<String, Document_Classification__c>();
    public Map<String, Document_Classification__c> getDocumentClasification() { return documentClasification; }
    public List<UploadedPhotos> listUploadedPhotos{get;set;}
    public Opportunity optyObj {get;set;}
    public Set<String> setValidFileTypes{get;set;}
    private ApexPages.StandardSetController photoSet;
    public Map<Id, UploadedPhotos> photoMap {get;set;}
    public List<UploadedPhotos> attPhotos {get;set;}
    public String objectType {get;set;}
	public boolean isSystemAdmin;
	   
    //CONSTRUCTOR
    public OpportunityPhotoUploaderComponent(){
		//objectType = SRAttachmentManager.getSObjectType(relatedObject);	
    }
    public OpportunityPhotoUploaderComponent(Apexpages.Standardcontroller optyObj) {
        this.optyObj = (Opportunity)optyObj.getRecord();
		//objectType = SRAttachmentManager.getSObjectType(relatedObject);	
    }

	public boolean getIsSystemAdmin(){
		isSystemAdmin = false;
		Id profileId = UserInfo.getProfileId();
		Profile profileObj = [Select Name from Profile where Id =:profileId];
		if(profileObj.name == 'System Administrator'){
			isSystemAdmin = true;
		}
		return isSystemAdmin;
	}
    
    public String relatedObject{
        get;
        set{
            relatedObject = value;
            if(relatedObject != null && relatedObject != ''){
                opportunityObj = [Select Id, Name, Account.Name, Prospect_Id__c, 
                						(Select Id, name, description__c, Size__c from SR_Gen_Asset_Attachments__r )  from Opportunity where Id =:relatedObject];
				GenAssetName = opportunityObj.Name;
                GenAssetPhotoCount = (opportunityObj != null && opportunityObj.SR_Gen_Asset_Attachments__r != null && opportunityObj.SR_Gen_Asset_Attachments__r.size() > 0) ? opportunityObj.SR_Gen_Asset_Attachments__r.size() : 0;
                existingSRAttachments = SRAttachmentManager.getSRGenAssetAttachmentsInfo(relatedObject);
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
        relatedObject = optyObj.Id;
        listUploadedPhotos = new List<UploadedPhotos>();    
		objectType = SRAttachmentManager.getSObjectType(relatedObject);	
		List<SR_Gen_Asset_Attachment__c> photoList = new List<SR_Gen_Asset_Attachment__c> ();
		String soqlStr = 'select Id, Name, Document_Name__c, description__c, Size__c, Active__c, Generation_Asset__r.Id, Generation_Asset__r.Name, Opportunity__r.Id, Opportunity__r.Prospect_Id__c, Service_Contract__r.Id, Service_Contract__r.Agreement_Number__c, Service_Contract__r.Name, Document_Name_On_File_Server__c, Thumbnail__c from SR_Gen_Asset_Attachment__c ';
		System.debug('objectType: ' + objectType);
		if(objectType == 'ServiceContract'){
			soqlStr += '  where service_contract__c =:relatedObject ';
		}else if(objectType == 'Opportunity'){
			soqlStr += '  where opportunity__c =:relatedObject ';
		}else{
			soqlStr += '  where Generation_Asset__c =:relatedObject ';
		}

		soqlStr += '  order by Active__c desc ';
		for(SR_Gen_Asset_Attachment__c photo : Database.query(soqlStr)){
			listUploadedPhotos.add(new UploadedPhotos(photo));
		}        
 
        return listUploadedPhotos;
    }
    
    public static Map<Id, UploadedPhotos> buildAttIdToUploadedPhotoMap(List<SR_Gen_Asset_Attachment__c> attPhotoList) {
        Map<Id, UploadedPhotos> photoMap = new Map<Id, UploadedPhotos>();
        for (SR_Gen_Asset_Attachment__c p : attPhotoList) {
                UploadedPhotos photo = new UploadedPhotos(p);
                photoMap.put(p.Id, photo);                
        }
        return photoMap;
    }
    
    public List<UploadedPhotos> getPhotoListsToDisplay() {
       List<UploadedPhotos> listPhotos = new List<UploadedPhotos>();
       List<UploadedPhotos> photos = new List<UploadedPhotos>();
       objectType = SRAttachmentManager.getSObjectType(relatedObject);	
       //List<SR_Gen_Asset_Attachment__c> photoList = [select Id, Name, Document_Name__c, Size__c, Active__c, Generation_Asset__r.Name, Document_Name_On_File_Server__c, Thumbnail__c from SR_Gen_Asset_Attachment__c where Generation_Asset__c = :relatedObject order by Active__c desc];
		List<SR_Gen_Asset_Attachment__c> photoList = new List<SR_Gen_Asset_Attachment__c> ();
		String soqlStr = 'select Id, Name, Document_Name__c, Size__c, Active__c, Generation_Asset__r.Id, Generation_Asset__r.Name, Opportunity__r.Id, Opportunity__r.Name, Opportunity__r.Prospect_Id__c,  Service_Contract__r.Id, ';
		soqlStr += 'Service_Contract__r.Name, Service_Contract__r.Agreement_Number__c, Document_Name_On_File_Server__c, Thumbnail__c from SR_Gen_Asset_Attachment__c ';
		System.debug('objectType: ' + objectType);
		if(objectType == 'ServiceContract'){
			soqlStr += '  where service_contract__c =:relatedObject ' ;
		}else if(objectType == 'Opportunity'){
			soqlStr += '  where Opportunity__c =:relatedObject ' ;
		}else{
			soqlStr += '  where Generation_Asset__c =:relatedObject ' ;
		}
		soqlStr += '  order by Active__c desc ';
		for(SR_Gen_Asset_Attachment__c photo : Database.query(soqlStr)){
			photoList.add(photo);
		}        
		
		photoMap = buildAttIdToUploadedPhotoMap(photoList);       
       photoSet = PaginationHelper.getStdSetController(photoList, Integer.valueOf(System.Label.PhotosPerPage));
       List<SR_Gen_Asset_Attachment__c> listAtt = photoSet.getRecords();
       for (SR_Gen_Asset_Attachment__c att: listAtt) {
            if (photoMap.containsKey(att.Id)) 
                photos.add(photoMap.get(att.Id));
       }

       return photos;
    }    
        
    public List<UploadedPhotos> getAttachedPhotos(){  
        listUploadedPhotos = new List<UploadedPhotos>();    
		objectType = SRAttachmentManager.getSObjectType(relatedObject);	
		String soqlStr = 'select Id, Name, Document_Name__c, Size__c, Active__c, Generation_Asset__r.Id, Generation_Asset__r.Name, Opportunity__r.Id, Opportunity__r.Name, Opportunity__r.Prospect_Id__c, Service_Contract__r.Id, Service_Contract__r.Name, Document_Name_On_File_Server__c, Thumbnail__c, Service_Contract__r.Agreement_Number__c from SR_Gen_Asset_Attachment__c ';
		System.debug('objectType: ' + objectType);
		if(objectType == 'ServiceContract'){
			soqlStr += '  where service_contract__c =:relatedObject ';
		}else if(objectType == 'Opportunity'){
			soqlStr += '  where Opportunity__c =:relatedObject ' ;
		}else{
			soqlStr += '  where Generation_Asset__c =:relatedObject ' ;
		}
		soqlStr += '  and Active__c = true ';
		for(SR_Gen_Asset_Attachment__c photo : Database.query(soqlStr)){
			listUploadedPhotos.add(new UploadedPhotos(photo));
		}           
        return listUploadedPhotos;
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
        public String description{get;set;}
        public SR_Gen_Asset_Attachment__c thephoto{get;set;}
        public UploadedPhotos(SR_Gen_Asset_Attachment__c photo){
            id = photo.Id;
            name = photo.Name;
            filename = photo.Document_Name__c;
            s3filename = photo.Document_Name_On_File_Server__c;
            filesize = photo.Size__c;
            filestatus = photo.Active__c;
            signedURL = photo.Document_Name__c;           
            AttachedPhotoId = photo.Id;
            thephoto = photo;
            String parentObjectName =  '';
            if(photo.Service_Contract__r.Id != null){
            	parentObjectName =  photo.Service_Contract__r.Agreement_Number__c;
            }else if(photo.Opportunity__r.Id != null){
            	parentObjectName =  photo.Opportunity__r.Prospect_Id__c;
            }else{
            	parentObjectName = photo.Generation_Asset__r.Name;
            }
            description = (String.isEmpty(photo.description__c) || photo.description__c.length() <= 75) ? photo.description__c : photo.description__c.substring(70) + '...';
            thumbnail = SunRunS3RestConnection.getPhotoURL('GET', SunRunS3RestConnection.OPPORTUNITY_DOCS_SETTINGS_NAME, parentObjectName, s3filename);
            thumbnail = thumbnail.Replace('%26', '&');
            QSurl = thumbnail.Replace('&','%26');   
        }
    }
    
    public PageReference UploadNewPhotos(){
        PageReference pr = new PageReference('/apex/GenAsset_PhotoUploader?id=' + optyObj.Id);       
        return pr;
    }

    public PageReference SaveChangesToAllUploadedPhotos(){
        List<SR_Gen_Asset_Attachment__c> listPhotos = new List<SR_Gen_Asset_Attachment__c>();
        Map<Id, Boolean> mapPhotoStatus = new Map<Id, Boolean>();       
        for(UploadedPhotos photo:listUploadedPhotos)
        {
           mapPhotoStatus.put(photo.Id, photo.filestatus);
        }
        if(!mapPhotoStatus.isEmpty())
        {
            for(SR_Gen_Asset_Attachment__c gap:[select Id, Name, Active__c from SR_Gen_Asset_Attachment__c where id in :mapPhotoStatus.keySet()])
            {
                gap.Active__c = mapPhotoStatus.get(gap.Id);
                listPhotos.add(gap);
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
        List<SR_Gen_Asset_Attachment__c> listPhotos = new List<SR_Gen_Asset_Attachment__c>();
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
            for(SR_Gen_Asset_Attachment__c gap:[select Id, Name, Active__c from SR_Gen_Asset_Attachment__c where id in :setIds])
            {
                gap.Active__c = false;
                listPhotos.add(gap);
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

    public Opportunity opportunityObj{get;set;}
    public String GenAssetName {get;set;}
    public Integer GenAssetPhotoCount {get;set;}
    public String ProposalName {get;set;}
    
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
            if(relatedObject == null || relatedObject == ''){
                relatedObject = System.currentPagereference().getParameters().get('id');
            }
            try{
	            opportunityObj = [Select Id, Name, Account.Name, Prospect_Id__c from Opportunity where Id =:relatedObject];
	            GenAssetName = opportunityObj.Prospect_Id__c;
	            System.Debug('GA Name = ' + GenAssetName);
	            Set<String> modes = new Set<String>();
	            modes.add('Edit');
            }
            catch(Exception e){
                
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
        List<SR_Gen_Asset_Attachment__c> listSRGAA = new List<SR_Gen_Asset_Attachment__c>();
        Set<String> setIds = new Set<String>();
        setIds.addAll(listToUpdate);
        System.Debug('set to inactivate: ' + setIds);
        for(SR_Gen_Asset_Attachment__c srgaa:[select Id, Name, Active__c from SR_Gen_Asset_Attachment__c where Id in :setIds]){
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
    global static List<UploadedPhotos> getAttachedPhotosAfterUpload(String gaId){
        List<UploadedPhotos> listUploadedPhotosAfterUpload = new List<UploadedPhotos>();
        for(SR_Gen_Asset_Attachment__c photo:[select Id, Name, Document_Name__c, Size__c, Active__c,Opportunity__r.Id,Opportunity__r.Name, Opportunity__r.Prospect_Id__c, Service_Contract__r.Id,Service_Contract__r.Name, Service_Contract__r.Agreement_Number__c, Generation_Asset__r.Id, Generation_Asset__r.Name, Document_Name_On_File_Server__c, 
                                                Thumbnail__c, description__c from SR_Gen_Asset_Attachment__c
                                                where Opportunity__c = :gaId 
                                                  and Active__c = true
                                                  order by CreatedDate desc])
        {
            listUploadedPhotosAfterUpload.add(new UploadedPhotos(photo));
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
        
        Map<String, SR_Gen_Asset_Attachment__c> tempExistingSRAttachments = SRAttachmentManager.getSRGenAssetAttachmentsInfo(relatedObjectId);
        System.debug('tempExistingSRAttachments'+ tempExistingSRAttachments);
        
        Map<String, Document_Classification__c> documentClasification = new Map<String, Document_Classification__c>();
        documentClasification = getDocumentClassificationByCategroy(relatedObjectId);
        System.debug('documentClasification'+ documentClasification);
        
        ServiceContract opportunityObj = [Select Id, Status__c from ServiceContract where Id =:relatedObjectId];
        System.debug('Gen Asset Object: '+opportunityObj);
        
        Map<Id, String> docTypeIdToName = new Map<Id, String>();
        for(Document_Classification__c docTypeAndId:[select Id, name from Document_Classification__c]){
            docTypeIdToName.put(docTypeAndId.Id, docTypeAndId.name);
        }

        if(tempExistingSRAttachments == null || tempExistingSRAttachments.size() == 0) {
            System.debug('inside tempExistingSRAttachments');
            return responseObj;
        }
        
        Set<String> existingSignedDocs = new Set<String>();
        for(SR_Gen_Asset_Attachment__c srAttachmentObj : tempExistingSRAttachments.values()){
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

            SR_Gen_Asset_Attachment__c attchInfo = tempExistingSRAttachments.get(newDocuTypeName);
            
            system.debug('Attach Info= '+attchInfo);
            boolean allowToOverWrite = false;
            boolean isInFlight = false;
            String docuSignStatus = '';
            String genAssetStatus = '';
            if(attchInfo != null && opportunityObj != null) {
                System.debug('newDocumentType'+ newDocumentType);
                if(newDocumentType != EDPUtil.OTHER){
                    System.debug('In Side not Others');
                    System.debug('attchInfo Document_Name__c:.....:'+attchInfo.Document_Name__c);
                    System.debug('NEW FILE NAME:.....:'+newFileName);
                    //if(attchInfo.Document_Name__c != null && attchInfo.Document_Name__c != '' && attchInfo.Document_Name__c != newFileName){
                    System.debug('In side Document_Name__c');
                    
                    docuSignStatus = attchInfo.DocuSign_Status__c;
                    genAssetStatus = opportunityObj.Status__c;
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
        requestInfo = SunRunS3RestConnection.getPhotoURL('PUT', SunRunS3RestConnection.OPPORTUNITY_DOCS_SETTINGS_NAME, GenAssetName, objectName, mimeType);
        return requestInfo;
    }
    
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
        Boolean result = SRAttachmentManager.upsertSRGenAssetAttachment(requestObj);
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
    
    @RemoteAction
    global static Map<String, String> getSunRunProxyDetails(String objectName, String mimeType){
        Map<String, String> resultMap = new Map<String, String>(); 
		return resultMap;
    }
}