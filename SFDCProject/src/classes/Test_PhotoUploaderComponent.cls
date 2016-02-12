@isTest (SeeAllData=true)
public with sharing class Test_PhotoUploaderComponent {
	
	/*
	public static testmethod void TestPhotoUploaderComponent(){
        
	    Account a = new Account(name='Test Acct1');
	    insert a;
	    Generation_Assets__c ga = new Generation_Assets__c(Account_Name__c=a.id, Name='99887'); 
	    insert ga;
	    SR_Gen_Asset_Attachment__c srgaa = new SR_Gen_Asset_Attachment__c();
	    srgaa.Active__c = true;
	    srgaa.Generation_Asset__c = ga.id;
	    srgaa.Document_Name__c = 'test.jpg';
	    insert srgaa;
        
        ApexPages.StandardController stdcon = new ApexPages.StandardController(ga);
        PhotoUploader PhotoUploaderObj1 = new PhotoUploader(stdcon);
        PhotoUploader PhotoUploaderObj2 = new PhotoUploader(stdcon);
        Id relatedObjectId = PhotoUploaderObj2.relatedObjectId;
        
        PhotoUploaderComponent PhotoUploaderComponentObj = New PhotoUploaderComponent(stdcon);
        PhotoUploaderComponentObj.relatedObject = PhotoUploaderComponentObj.relatedObject;
        
        PhotoUploaderComponent.UploadedPhotos up = new PhotoUploaderComponent.UploadedPhotos(srgaa);
        PhotoUploaderComponentObj.ga = ga;
        PhotoUploaderComponentObj.init();
        PageReference pr1 = PhotoUploaderComponentObj.doNothing();
        String strBaseURL = PhotoUploaderComponentObj.getBaseURL();
        Set<String> setDocTypes = PhotoUploaderComponentObj.getDocumentTypes();
        Map<String, SR_Gen_Asset_Attachment__c> mapGAAttach = PhotoUploaderComponentObj.getExistingSRAttachments();
        Map<String, Document_Classification__c> mapDC = PhotoUploaderComponentObj.getDocumentClasification();
        PageReference pr2 = PhotoUploaderComponentObj.UploadNewPhotos();
        PhotoUploaderComponentObj.GenAssetName = ga.Name;
        PhotoUploaderComponentObj.GenAssetPhotoCount = 0;
        List<PhotoUploaderComponent.UploadedPhotos> listAll = PhotoUploaderComponentObj.getAllAttachedPhotos();
        List<PhotoUploaderComponent.UploadedPhotos> listPhotos = PhotoUploaderComponentObj.getAttachedPhotos();
        Boolean bIsPartner = PhotoUploaderComponentObj.getIsPartnerUser();
        PhotoUploaderComponentObj.initializeAssetobject();
        //
        List<PhotoUploaderComponent.UploadedPhotos> listUpPhoto = new List<PhotoUploaderComponent.UploadedPhotos>();
        listUpPhoto.add(new PhotoUploaderComponent.UploadedPhotos(srgaa));
        PhotoUploaderComponentObj.listUploadedPhotos = new List<PhotoUploaderComponent.UploadedPhotos>();
        PhotoUploaderComponentObj.listUploadedPhotos.add(new PhotoUploaderComponent.UploadedPhotos(srgaa)); // = listUpPhoto;
        //
        //photo.filestatus
        for(PhotoUploaderComponent.UploadedPhotos uphoto:PhotoUploaderComponentObj.listUploadedPhotos)
        {
           uphoto.filestatus = false;   
        }
        PageReference pr3 = PhotoUploaderComponentObj.SaveChangesToAllUploadedPhotos();
        //
        List<PhotoUploaderComponent.UploadedPhotos> listUpPhoto2 = new List<PhotoUploaderComponent.UploadedPhotos>();
        listUpPhoto2.add(new PhotoUploaderComponent.UploadedPhotos(srgaa));
        PhotoUploaderComponentObj.listUploadedPhotos = new List<PhotoUploaderComponent.UploadedPhotos>();
        PhotoUploaderComponentObj.listUploadedPhotos.add(new PhotoUploaderComponent.UploadedPhotos(srgaa)); // = listUpPhoto;               
        //
        PageReference pr4 = PhotoUploaderComponentObj.SaveChangesToUploadedPhotos();    
        //
        List<String> listUpdate = new List<String>();
        listUpdate.add(String.ValueOf(srgaa.Id));
        PhotoUploaderComponent.updateStatus(listUpdate);
        List<PhotoUploaderComponent.UploadedPhotos> listUpPhoto3 = new List<PhotoUploaderComponent.UploadedPhotos>();
        listUpPhoto3 = PhotoUploaderComponent.getAttachedPhotosAfterUpload(ga.Id);
        Map<String, Document_Classification__c> mapDocs = new Map<String, Document_Classification__c>();
        mapDocs = PhotoUploaderComponent.getDocumentClassificationByCategroy(ga.Id);
        PhotoUploaderComponent.ExistingAttachmentsResponse ear = new PhotoUploaderComponent.ExistingAttachmentsResponse();
        Map<String,String> mapNewAtt = new Map<String,String>();
        mapNewAtt.put(ga.Id, srgaa.Id);
        ear = PhotoUploaderComponent.checkexistingSRAttachments(ga.Id, mapNewAtt);
        SunRunProxyRequestInfo spri = new SunRunProxyRequestInfo();
        spri = PhotoUploaderComponent.getS3ProxyInfoForPut(ga.Name, 'file.jpg', 'image');
        PhotoUploaderComponent.SRUpsertResponse sur = new PhotoUploaderComponent.SRUpsertResponse();
        sur = PhotoUploaderComponent.upsertSRGenAssetAttachment(relatedObjectId, 'file.jpg', 'amazonfile.jpg', 'Customer Agreement', 'jpg', '100k', 'false');
        String sDelete = PhotoUploaderComponent.deleteSelectedRecords(srgaa.Id);
        String sDocSign = PhotoUploaderComponent.DocSignStatus('image');
        PhotoUploaderComponent.UpsertRequest uReq = new PhotoUploaderComponent.UpsertRequest();
        uReq.amazonS3FileName = 'amazonfile.jpg';
        uReq.documentType = 'image';
        uReq.documentTypeName = 'image';
        uReq.fileName = 'file.jpg';
        uReq.relatedObjectId = String.ValueOf(ga.Id);
        uReq.size = '100 kb';
        uReq.wetSign = 'false';              
    }
	*/
	
	public static testmethod void testSRServiceContractPhotouploadComponent(){
        
	   // Account a = new Account(name='Test Acct1');
	   // insert a;
	   // ServiceContract sc = new ServiceContract(AccountId=a.id, Name='99887'); 
	   // insert sc;
		ServiceContract sc;
		Test_Partner_User__c testPartnerUserObj = UnitTest_ServiceContractUtil.getBlackBirdSalesRep();
		User u = [Select Id from User where ContactID != NULL and IsActive = true and Id =:testPartnerUserObj.User_Id__c  limit 1];
		Service_Contract_Event__c scEventObj;
		String custRefNum = '';
		String acctName = '';
		String custMailAddress = '';
		System.runAs(u) {  
			Test.startTest();
        		UnitTest_ServiceContractUtil.createServiceContractData();
        		sc = UnitTest_ServiceContractUtil.scObj;
				scEventObj = UnitTest_ServiceContractUtil.scEventObj;
				System.currentPagereference().getParameters().put('id', sc.Id);
				custRefNum = sc.Cust_Ref_Num__c;
				acctName = sc.Customer_Name__c;
				custMailAddress = sc.Customer_Mailing_Address__c;
         	Test.stopTest();
         	System.debug('custMailAddress: ' + custMailAddress);
	    
		    SR_Gen_Asset_Attachment__c srgaa = new SR_Gen_Asset_Attachment__c();
		    srgaa.Active__c = true;
		    srgaa.Service_Contract__c = sc.id;
		    srgaa.Document_Name__c = 'test.jpg';
		    insert srgaa;
	        
	        ApexPages.StandardController stdcon = new ApexPages.StandardController(sc);
	        ServiceContractPhotoUploader ServiceContractPhotoUploaderObj1 = new ServiceContractPhotoUploader(stdcon);
	        ServiceContractPhotoUploader ServiceContractPhotoUploaderObj2 = new ServiceContractPhotoUploader(stdcon);
	        Id relatedObjectId = ServiceContractPhotoUploaderObj2.relatedObjectId;    
	        ServiceContractPhotoUploaderComponent ServiceContractPhotoUploaderComponentObj = New ServiceContractPhotoUploaderComponent(stdcon);
	        ServiceContractPhotoUploaderComponentObj.relatedObject = ServiceContractPhotoUploaderComponentObj.relatedObject;
	        
	        ServiceContractPhotoUploaderComponent.UploadedPhotos up = new ServiceContractPhotoUploaderComponent.UploadedPhotos(srgaa);
	        ServiceContractPhotoUploaderComponentObj.sc = sc;
	        ServiceContractPhotoUploaderComponentObj.init();
	        PageReference pr1 = ServiceContractPhotoUploaderComponentObj.doNothing();
	        String strBaseURL = ServiceContractPhotoUploaderComponentObj.getBaseURL();
	        Set<String> setDocTypes = ServiceContractPhotoUploaderComponentObj.getDocumentTypes();
	        Map<String, SR_Gen_Asset_Attachment__c> mapGAAttach = ServiceContractPhotoUploaderComponentObj.getExistingSRAttachments();
	        Map<String, Document_Classification__c> mapDC = ServiceContractPhotoUploaderComponentObj.getDocumentClasification();
	        PageReference pr2 = ServiceContractPhotoUploaderComponentObj.UploadNewPhotos();
	        ServiceContractPhotoUploaderComponentObj.GenAssetName = sc.Name;
	        ServiceContractPhotoUploaderComponentObj.GenAssetPhotoCount = 0;
	        List<ServiceContractPhotoUploaderComponent.UploadedPhotos> listAll = ServiceContractPhotoUploaderComponentObj.getAllAttachedPhotos();
	        List<ServiceContractPhotoUploaderComponent.UploadedPhotos> listPhotos = ServiceContractPhotoUploaderComponentObj.getAttachedPhotos();
	        Boolean bIsPartner = ServiceContractPhotoUploaderComponentObj.getIsPartnerUser();
	       // ServiceContractPhotoUploaderComponentObj.initializeAssetobject();
	        //
	        List<ServiceContractPhotoUploaderComponent.UploadedPhotos> listUpPhoto = new List<ServiceContractPhotoUploaderComponent.UploadedPhotos>();
	        listUpPhoto.add(new ServiceContractPhotoUploaderComponent.UploadedPhotos(srgaa));
	        ServiceContractPhotoUploaderComponentObj.listUploadedPhotos = new List<ServiceContractPhotoUploaderComponent.UploadedPhotos>();
	        ServiceContractPhotoUploaderComponentObj.listUploadedPhotos.add(new ServiceContractPhotoUploaderComponent.UploadedPhotos(srgaa)); // = listUpPhoto;
	        //
	        //photo.filestatus
	        for(ServiceContractPhotoUploaderComponent.UploadedPhotos uphoto:ServiceContractPhotoUploaderComponentObj.listUploadedPhotos)
	        {
	           uphoto.filestatus = false;   
	        }
	        PageReference pr3 = ServiceContractPhotoUploaderComponentObj.SaveChangesToAllUploadedPhotos();
	        //
	        List<ServiceContractPhotoUploaderComponent.UploadedPhotos> listUpPhoto2 = new List<ServiceContractPhotoUploaderComponent.UploadedPhotos>();
	        listUpPhoto2.add(new ServiceContractPhotoUploaderComponent.UploadedPhotos(srgaa));
	        ServiceContractPhotoUploaderComponentObj.listUploadedPhotos = new List<ServiceContractPhotoUploaderComponent.UploadedPhotos>();
	        ServiceContractPhotoUploaderComponentObj.listUploadedPhotos.add(new ServiceContractPhotoUploaderComponent.UploadedPhotos(srgaa)); // = listUpPhoto;               
	        //
	        PageReference pr4 = ServiceContractPhotoUploaderComponentObj.SaveChangesToUploadedPhotos();    
	        //
	        List<String> listUpdate = new List<String>();
	        listUpdate.add(String.ValueOf(srgaa.Id));
	        ServiceContractPhotoUploaderComponent.updateStatus(listUpdate);
	        List<ServiceContractPhotoUploaderComponent.UploadedPhotos> listUpPhoto3 = new List<ServiceContractPhotoUploaderComponent.UploadedPhotos>();
	        listUpPhoto3 = ServiceContractPhotoUploaderComponent.getAttachedPhotosAfterUpload(sc.Id);
	        Map<String, Document_Classification__c> mapDocs = new Map<String, Document_Classification__c>();
	        mapDocs = ServiceContractPhotoUploaderComponent.getDocumentClassificationByCategroy(sc.Id);
	        ServiceContractPhotoUploaderComponent.ExistingAttachmentsResponse ear = new ServiceContractPhotoUploaderComponent.ExistingAttachmentsResponse();
	        Map<String,String> mapNewAtt = new Map<String,String>();
	        mapNewAtt.put(sc.Id, srgaa.Id);
	        ear = ServiceContractPhotoUploaderComponent.checkexistingSRAttachments(sc.Id, mapNewAtt);
	        SunRunProxyRequestInfo spri = new SunRunProxyRequestInfo();
	        spri = ServiceContractPhotoUploaderComponent.getS3ProxyInfoForPut(sc.Name, 'file.jpg', 'image');
	        ServiceContractPhotoUploaderComponent.SRUpsertResponse sur = new ServiceContractPhotoUploaderComponent.SRUpsertResponse();
	        sur = ServiceContractPhotoUploaderComponent.upsertSRGenAssetAttachment(relatedObjectId, 'file.jpg', 'amazonfile.jpg', 'Customer Agreement', 'jpg', '100k', 'false');
	        String sDelete = ServiceContractPhotoUploaderComponent.deleteSelectedRecords(srgaa.Id);
	        String sDocSign = ServiceContractPhotoUploaderComponent.DocSignStatus('image');
	        ServiceContractPhotoUploaderComponent.UpsertRequest uReq = new ServiceContractPhotoUploaderComponent.UpsertRequest();
	        uReq.amazonS3FileName = 'amazonfile.jpg';
	        uReq.documentType = 'image';
	        uReq.documentTypeName = 'image';
	        uReq.fileName = 'file.jpg';
	        uReq.relatedObjectId = String.ValueOf(sc.Id);
	        uReq.size = '100 kb';
	        uReq.wetSign = 'false';              
			
			List<SR_Gen_Asset_Attachment__c> attPhotoList = new List<SR_Gen_Asset_Attachment__c>();
	        attPhotoList.add(srgaa);
			ServiceContractPhotoUploaderComponent.buildAttIdToUploadedPhotoMap(attPhotoList);   
			ServiceContractPhotoUploaderComponentObj.getPhotoListsToDisplay();
			ear = ServiceContractPhotoUploaderComponent.checkexistingSRAttachments(sc.Id, mapNewAtt);
        }
    }


}