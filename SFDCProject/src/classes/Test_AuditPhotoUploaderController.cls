@isTest (SeeAllData=true)
public class Test_AuditPhotoUploaderController {
    public static testmethod void Test_AuditPhotoUploaderController(){
        
    Account a = new Account(name='Test Acct1');
    insert a;
    
    Generation_Assets__c ga = new Generation_Assets__c(Account_Name__c=a.id, Name='99887'); 
    insert ga;
    
    Install_Audit__c  ia = new Install_Audit__c();
    ia.Generation_Asset__c = ga.Id;
    insert ia;     
    
    SR_Audit_Attachment__c  sraa = new SR_Audit_Attachment__c();
    sraa.Active__c = true;
    sraa.InstallAudit__c = ia.id;
    sraa.Document_Name__c = 'test.jpg';
    insert sraa;
    
   ServiceContract sc = New ServiceContract(Name = 'Testsc',AccountId =a.Id,Legacy_Asset_Number__c = '12222006');
        insert sc; 
    
         
    ApexPages.StandardController stdcon = new ApexPages.StandardController(ga);
    AuditPhotoUploader PhotoUploaderObj1 = new AuditPhotoUploader(stdcon);
    AuditPhotoUploader PhotoUploaderObj2 = new AuditPhotoUploader();
    Id relatedObjectId = PhotoUploaderObj2.relatedObjectId;
    
     
    AuditPhotoUploaderController AuditPhotoUploaderControllerObj = New AuditPhotoUploaderController();
    AuditPhotoUploaderControllerObj.relatedObject = AuditPhotoUploaderControllerObj.relatedObject;
        
    AuditPhotoUploaderController.UploadedPhotos up = new AuditPhotoUploaderController.UploadedPhotos(sraa);
    AuditPhotoUploaderControllerObj.ia= ia;
    AuditPhotoUploaderControllerObj.init();
    PageReference pr1 = AuditPhotoUploaderControllerObj.doNothing();
    String strBaseURL = AuditPhotoUploaderControllerObj.getBaseURL();
    Set<String> setDocTypes = AuditPhotoUploaderControllerObj.getDocumentTypes();
    Map<String, SR_Audit_Attachment__c> mapIAAttach = AuditPhotoUploaderControllerObj.getExistingSRAttachments();
    Map<String, Document_Classification__c> mapDC = AuditPhotoUploaderControllerObj.getDocumentClasification();
    PageReference pr2 = AuditPhotoUploaderControllerObj.UploadNewPhotos();
    AuditPhotoUploaderControllerObj.GenAssetName = ga.Name;
    AuditPhotoUploaderControllerObj.installAuditObj = ia;
    AuditPhotoUploaderControllerObj.SiteVisitDate = null;
    
    AuditPhotoUploaderControllerObj.GenAssetPhotoCount = Integer.ValueOf(ia.Number_of_Photos_Uploaded__c);
    List<AuditPhotoUploaderController.UploadedPhotos> listAll = AuditPhotoUploaderControllerObj.getAllAttachedPhotos();
    List<AuditPhotoUploaderController.UploadedPhotos> listPhotos = AuditPhotoUploaderControllerObj.getAttachedPhotos();
    List<AuditPhotoUploaderController.UploadedPhotos> listPhotos1 = AuditPhotoUploaderControllerObj.PhotoListsToDisplay();
    Boolean bIsPartner = AuditPhotoUploaderControllerObj.getIsPartnerUser();
        //
    List<AuditPhotoUploaderController.UploadedPhotos> listUpPhoto = new List<AuditPhotoUploaderController.UploadedPhotos>();
    listUpPhoto.add(new AuditPhotoUploaderController.UploadedPhotos(sraa));
    AuditPhotoUploaderControllerObj.listUploadedPhotos = new List<AuditPhotoUploaderController.UploadedPhotos>();
    AuditPhotoUploaderControllerObj.listUploadedPhotos.add(new AuditPhotoUploaderController.UploadedPhotos(sraa)); 
    Pagereference pr3 = AuditPhotoUploaderControllerObj.nextPhotosPage();
    Pagereference pg1 = AuditPhotoUploaderControllerObj.previousPhotosPage() ;
    // = listUpPhoto;
        //
        //photo.filestatus
    for(AuditPhotoUploaderController.UploadedPhotos uphoto:AuditPhotoUploaderControllerObj.listUploadedPhotos)
    {
        uphoto.filestatus = false;   
    }
    PageReference pr4 = AuditPhotoUploaderControllerObj.SaveChangesToAllUploadedPhotos();
        //
    List<AuditPhotoUploaderController.UploadedPhotos> listUpPhoto2 = new List<AuditPhotoUploaderController.UploadedPhotos>();
    listUpPhoto2.add(new AuditPhotoUploaderController.UploadedPhotos(sraa));
    AuditPhotoUploaderControllerObj.listUploadedPhotos = new List<AuditPhotoUploaderController.UploadedPhotos>();
    AuditPhotoUploaderControllerObj.listUploadedPhotos.add(new AuditPhotoUploaderController.UploadedPhotos(sraa)); // = listUpPhoto;               
        //
    PageReference pr5 = AuditPhotoUploaderControllerObj.SaveChangesToUploadedPhotos();    
        //
    List<String> listUpdate = new List<String>();
    listUpdate.add(String.ValueOf(sraa.Id));
    AuditPhotoUploaderController.updateStatus(listUpdate);
    List<AuditPhotoUploaderController.UploadedPhotos> listUpPhoto3 = new List<AuditPhotoUploaderController.UploadedPhotos>();
    listUpPhoto3 = AuditPhotoUploaderController.getAttachedPhotosAfterUpload(ia.Id);
    Map<String, Document_Classification__c> mapDocs = new Map<String, Document_Classification__c>();
    mapDocs = AuditPhotoUploaderController.getDocumentClassificationByCategroy(ga.Id);
    AuditPhotoUploaderController.ExistingAttachmentsResponse ear = new AuditPhotoUploaderController.ExistingAttachmentsResponse();
    Map<String,String> mapNewAtt = new Map<String,String>();
    mapNewAtt.put(ia.Id, sraa.Id);
    ear = AuditPhotoUploaderController.checkexistingSRAttachments(ia.Id, mapNewAtt);
    
    SunRunProxyRequestInfo spri = new SunRunProxyRequestInfo();
    spri = AuditPhotoUploaderController.getS3ProxyInfoForPut(ga.Name, 'file.jpg', 'image');
    AuditPhotoUploaderController.SRUpsertResponse sur = new AuditPhotoUploaderController.SRUpsertResponse();
    sur = AuditPhotoUploaderController.upsertSRGenAssetAttachment(relatedObjectId, 'file.jpg', 'amazonfile.jpg', 'jpg', 'jpg', '100k', 'false');
    String sDelete = AuditPhotoUploaderController.deleteSelectedRecords(sraa.Id);
    String sDocSign = AuditPhotoUploaderController.DocSignStatus('image');
    Map<String, String> mapDetailsDocs = new Map<String, String>();
    mapDetailsDocs = AuditPhotoUploaderController.getSunRunProxyDetails('Install_Audit__c', 'image');
    AuditPhotoUploaderController.UpsertRequest uReq = new AuditPhotoUploaderController.UpsertRequest();
    uReq.amazonS3FileName = 'amazonfile.jpg';
    uReq.documentType = 'image';
    uReq.documentTypeName = 'image';
    uReq.fileName = 'file.jpg';
    uReq.relatedObjectId = String.ValueOf(ga.Id);
    uReq.size = '100 kb';
    uReq.wetSign = 'false';  
                 
    }
}