public class SRAttachmentManager {
	
	public static Map<String, SR_Audit_Attachment__c> getSRAuditAttachmentsInfo(String relatedObjectId){        
        Map<String, SR_Audit_Attachment__c> srAttachmentsInfo = new Map<String, SR_Audit_Attachment__c>();
        //
        try { 
            String soqlStr = getSRAuditAttachmentSOQL();
            soqlStr += '  where InstallAudit__c =:relatedObjectId ' ;
            soqlStr += '  AND Active__c = true';
            for(SR_Audit_Attachment__c srAttachment : Database.query(soqlStr)){
                srAttachmentsInfo.put(srAttachment.Document_Type_Name__c, srAttachment);
            }
        } catch( Exception ee) { 
            return srAttachmentsInfo;
        }
        System.debug(srAttachmentsInfo);
        return srAttachmentsInfo;
    }  
	
	public static Map<String, SR_Gen_Asset_Attachment__c> getSRGenAssetAttachmentsInfo(String relatedObjectId){       
       Map<String, SR_Gen_Asset_Attachment__c> srAttachmentsInfo = new Map<String, SR_Gen_Asset_Attachment__c>();
       //
       try { 
			
			String soqlStr = getSRGenAssetAttachmentSOQL();
			String objectType = getSObjectType(relatedObjectId);
			System.debug('objectType: ' + objectType);
			if(objectType == 'ServiceContract'){
				soqlStr += '  where service_contract__c =:relatedObjectId '; 
			}else if(objectType == 'Opportunity'){
				soqlStr +='  where Opportunity__c =:relatedObjectId ' ;
			}else{
				soqlStr +='  where Generation_Asset__c =:relatedObjectId ' ;
			}
			soqlStr += '  AND active__c = true';
	  		System.debug('objectType: ' + objectType);
	  		System.debug('soqlStr: ' + soqlStr);
	  
			for(SR_Gen_Asset_Attachment__c srAttachment : Database.query(soqlStr)){
				srAttachmentsInfo.put(srAttachment.Document_Type_Name__c, srAttachment);
			}
        } catch( Exception ee) { 
      		return srAttachmentsInfo;
        }
        System.debug(srAttachmentsInfo);
       return srAttachmentsInfo;
    }
    
    public static Boolean upsertSRAuditAttachment(FileUploaderComponent.UpsertRequest requestObj){
         System.Debug('Beginning of upsertSRGenAssetAttachment');
         try { 
            List<SR_Audit_Attachment__c> srAttachments = new List<SR_Audit_Attachment__c>();
            String soqlStr = getSRAuditAttachmentSOQL();
            String documentType = requestObj.documentType;
            String fileName = requestObj.fileName;
            String relatedObjectId = requestObj.relatedObjectId;
            String gaName = '';
                soqlStr += ' where active__c = true ' ;
                soqlStr += ' AND InstallAudit__c =: relatedObjectId ' ;         
                srAttachments =  Database.query(soqlStr);
                for(SR_Audit_Attachment__c srAttachmentobj : srAttachments){
                    //srAttachmentobj.Active__c = false;
                    srAttachmentobj.Document_Name_On_File_Server__c = (srAttachmentobj.Document_Name_On_File_Server__c == null 
                                                                        || srAttachmentobj.Document_Name_On_File_Server__c == '') ? 
                                                                        srAttachmentobj.Document_Name__c :  srAttachmentobj.Document_Name_On_File_Server__c;
                }

            SR_Audit_Attachment__c tempSRAttachment = new SR_Audit_Attachment__c();     
            tempSRAttachment.Document_Name__c = requestObj.fileName;            
            tempSRAttachment.Document_Name_On_File_Server__c = requestObj.amazonS3FileName;
            tempSRAttachment.Document_Type_Name__c= requestObj.documentTypeName; 
            tempSRAttachment.Size__c = requestObj.size;
            tempSRAttachment.Document_Source__c = EDPUtil.MANUAL_UPLOAD_SOURCE;
            if(requestObj.relatedObjectId != null && requestObj.relatedObjectId != ''){
                tempSRAttachment.InstallAudit__c = requestObj.relatedObjectId;
            }
            srAttachments.add(tempSRAttachment);            
            upsert srAttachments;
        } catch( Exception ee) { 
            System.debug('Error Message: ' + ee.getMessage());
            return false;
        }
        return true;
    }      

   
  public static Boolean upsertSRGenAssetAttachment(FileUploaderComponent.UpsertRequest requestObj){
     System.Debug('Beginning of upsertSRGenAssetAttachment');
         try { 
          List<SR_Gen_Asset_Attachment__c> srAttachments = new List<SR_Gen_Asset_Attachment__c>();
          String soqlStr = getSRGenAssetAttachmentSOQL();
          String documentType = requestObj.documentType;
          String fileName = requestObj.fileName;
          String relatedObjectId = requestObj.relatedObjectId;
          String objectType = getSObjectType(relatedObjectId);
          
          String gaName = '';
          System.Debug('requestObj ' + requestObj);
          Document_Classification__c classificationObj = [Select Id,   ESignature_allowed__c from Document_Classification__c 
                                    where Name = :requestObj.documentType];

			if(classificationObj != null && classificationObj.ESignature_allowed__c == true){
         		soqlStr += ' where Document_Classification__c = :documentType AND active__c = true ' ;
         		if(objectType != null && objectType == 'ServiceContract'){
         			soqlStr +=  ' AND service_contract__c =: relatedObjectId ' ; 
         		}else if(objectType != null && objectType == 'Opportunity'){
         			soqlStr +=  ' AND Opportunity__c =: relatedObjectId ' ; 
         		}else{
         			soqlStr +=  ' AND generation_asset__c =: relatedObjectId ' ; 
         		}
        	System.debug('soqlStr: ' + soqlStr);
        	srAttachments =  Database.query(soqlStr);
         for(SR_Gen_Asset_Attachment__c srAttachmentobj : srAttachments){
          srAttachmentobj.active__c = false;
          srAttachmentobj.Document_Name_On_File_Server__c = (srAttachmentobj.Document_Name_On_File_Server__c == null 
                                    || srAttachmentobj.Document_Name_On_File_Server__c == '') ? 
                                       srAttachmentobj.Document_Name__c :  srAttachmentobj.Document_Name_On_File_Server__c;
        }
          }
      SR_Gen_Asset_Attachment__c tempSRAttachment = new SR_Gen_Asset_Attachment__c();   
      tempSRAttachment.Document_Name__c = requestObj.fileName;    
      tempSRAttachment.Document_Name_On_File_Server__c = requestObj.amazonS3FileName;
      
      tempSRAttachment.Size__c = requestObj.size;
      tempSRAttachment.Document_Source__c = EDPUtil.MANUAL_UPLOAD_SOURCE;
      if(requestObj.relatedObjectId != null && requestObj.relatedObjectId != '' && (objectType != null && objectType == 'ServiceContract')){
        tempSRAttachment.Service_Contract__c = requestObj.relatedObjectId;
      }else if(requestObj.relatedObjectId != null && requestObj.relatedObjectId != '' && (objectType != null && objectType == 'Opportunity')){
        tempSRAttachment.Opportunity__c = requestObj.relatedObjectId;
      }else if(requestObj.relatedObjectId != null && requestObj.relatedObjectId != '' && (objectType != null && objectType == 'Generation_Assets__c')){
        tempSRAttachment.Generation_Asset__c = requestObj.relatedObjectId;
      }
      
      tempSRAttachment.Wet_Sign_Status__c = requestObj.wetSign;
      if(requestObj.wetSign == EDPUtil.SIGNED){
        //setWetSignatureStatus(requestObj, tempSRAttachment); NOT NEEDED FOR GA Photos
      }
      System.debug('tempSRAttachment: ' + tempSRAttachment);
      srAttachments.add(tempSRAttachment);
      
      upsert srAttachments;
        } catch( Exception ee) { 
          System.debug('Error Message: ' + ee.getMessage());
      return false;
        }
       return true;
    }  
  
    public Static String getBaseURL() {
        String baseURL = EDPUtil.getBaseURL();
        return baseURL;
    }
    
    public static Messaging.EmailFileAttachment getEmailAttachments(SR_Attachment__C srAttachment){
      return null;
    }
  

    public static Messaging.EmailFileAttachment getEmailAttachments(SR_Attachment__C srAttachment, EDPUtil.WelcomeDocS3Status statusObj){
      
      try{
          SunRunS3RestConnection connectionObj;
          connectionObj = getDocumentFromS3ForWelcomeEmail(srAttachment, false);
          if(connectionObj.getResponse().getStatusCode() != 200){
              String statusCode = String.valueOf(connectionObj.getResponse().getStatusCode());
              String errorMessage = connectionObj.getResponse().getStatus() + ' -- Unable to download the file from server' ;
              System.debug('statusCode: ' + statusCode);
              System.debug('errorMessage: ' + errorMessage);
              return null;
      }
          Blob responseBlob = connectionObj.documentBlob;
          Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
          efa.setFileName(srAttachment.document_name__c);
          efa.setBody(responseBlob);
          return efa;
        } catch( Exception expObj) { 
      String maximSizeError = CustomErrorMessages.S3_MaximumSizeError;
      if(expObj != null){
        String errorMessage = expObj.getMessage();
        if(errorMessage != null && (errorMessage.contains(CustomErrorMessages.MAXIMUM_REQUEST_SIZE) || errorMessage.contains(maximSizeError))){
          statusObj.statusMessage = errorMessage;
        }
      }
      return null;
        }
    }

    public static Map<String, SR_Attachment__c> getSRAttachmentsInfoForOpty(String relatedObjectId){       
        Map<String, SR_Attachment__c> srAttachmentsInfo = new Map<String, SR_Attachment__c>();
        String documentSource = EDPUtil.PROPOSAL_TOOL_SOURCE;
        try { 
            String soqlStr = getOptyAttachmentSOQL();
            soqlStr += '  where Opportunity__c =:relatedObjectId ' ;
            soqlStr += '  AND active__c = true AND document_source__c != :documentSource ' ;
            for(SR_Attachment__c srAttachment : Database.query(soqlStr)){
                srAttachmentsInfo.put(srAttachment.Document_Type_Name__c, srAttachment);
            }
        } catch( Exception ee) { 
            return srAttachmentsInfo;
        }
        System.debug(srAttachmentsInfo);
        return srAttachmentsInfo;
    }

    public static Map<String, SR_Attachment__c> getSRAttachmentsInfoForSC(String relatedObjectId){       
        Map<String, SR_Attachment__c> srAttachmentsInfo = new Map<String, SR_Attachment__c>();
        String documentSource = EDPUtil.PROPOSAL_TOOL_SOURCE;
        try { 
            String soqlStr = getSCAttachmentSOQL();
            soqlStr += '  where service_contract__c =:relatedObjectId ' ;
            soqlStr += '  AND active__c = true AND document_source__c != :documentSource ' ;
            for(SR_Attachment__c srAttachment : Database.query(soqlStr)){
                srAttachmentsInfo.put(srAttachment.Document_Type_Name__c, srAttachment);
            }
        } catch( Exception ee) { 
            return srAttachmentsInfo;
        }
        System.debug(srAttachmentsInfo);
        return srAttachmentsInfo;
    }
  
    public static Map<String, SR_Attachment__c> getSRAttachmentsInfo(String relatedObjectId){       
        Map<String, SR_Attachment__c> srAttachmentsInfo = new Map<String, SR_Attachment__c>();
        String documentSource = EDPUtil.PROPOSAL_TOOL_SOURCE;
        try { 
            String soqlStr = getSRAttachmentSOQL();
            soqlStr += '  where proposal__c =:relatedObjectId ' ;
            soqlStr += '  AND active__c = true AND document_source__c != :documentSource ' ;
            for(SR_Attachment__c srAttachment : Database.query(soqlStr)){
                srAttachmentsInfo.put(srAttachment.Document_Type_Name__c, srAttachment);
            }
        } catch( Exception ee) { 
            return srAttachmentsInfo;
        }
        System.debug(srAttachmentsInfo);
        return srAttachmentsInfo;
    }

    // adding method to insert photo upload along with photo types
     public static Boolean upsertSRGenAssetPhoto(FileUploaderComponent.UpsertRequest requestObj){
     System.Debug('Beginning of upsertSRGenAssetPhoto');
         try { 
          List<SR_Gen_Asset_Attachment__c> srAttachments = new List<SR_Gen_Asset_Attachment__c>();
          String soqlStr = getSRGenAssetAttachmentSOQL();
          String documentType = requestObj.documentTypeName;
            String documentId = requestObj.documenttype;
          String fileName = requestObj.fileName;
          String relatedObjectId = requestObj.relatedObjectId;
          String objectType = getSObjectType(relatedObjectId);
          system.debug('documentType>>>>' +  documentType);
          String gaName = '';
          System.Debug('requestObj ' + requestObj);
          Document_Classification__c classificationObj = [Select Id,   ESignature_allowed__c from Document_Classification__c 
                                    where Name = :requestObj.documentTypeName];
        
        system.debug('classificationObj>>>>>' +  classificationObj);     
            if(classificationObj != null){
                soqlStr += ' where Document_Classification__c = :documentId AND active__c = true ' ;
                if(objectType != null && objectType == 'ServiceContract'){
                    soqlStr +=  ' AND service_contract__c =: relatedObjectId ' ; 
                }else if(objectType != null && objectType == 'Opportunity'){
                    soqlStr +=  ' AND Opportunity__c =: relatedObjectId ' ; 
                }else{
                    soqlStr +=  ' AND generation_asset__c =: relatedObjectId ' ; 
                }
            System.debug('soqlStr: ' + soqlStr);
            srAttachments =  Database.query(soqlStr);
         for(SR_Gen_Asset_Attachment__c srAttachmentobj : srAttachments){
         // srAttachmentobj.active__c = false;
          srAttachmentobj.Document_Name_On_File_Server__c = (srAttachmentobj.Document_Name_On_File_Server__c == null 
                                    || srAttachmentobj.Document_Name_On_File_Server__c == '') ? 
                                       srAttachmentobj.Document_Name__c :  srAttachmentobj.Document_Name_On_File_Server__c;
        }
          }
      SR_Gen_Asset_Attachment__c tempSRAttachment = new SR_Gen_Asset_Attachment__c();   
      tempSRAttachment.Document_Name__c = requestObj.fileName;    
      tempSRAttachment.Document_Name_On_File_Server__c = requestObj.amazonS3FileName;
      tempSRAttachment.Document_Classification__c = requestObj.documenttype;
      tempSRAttachment.Size__c = requestObj.size;
      tempSRAttachment.Document_Source__c = EDPUtil.MANUAL_UPLOAD_SOURCE;
      if(requestObj.relatedObjectId != null && requestObj.relatedObjectId != '' && (objectType != null && objectType == 'ServiceContract')){
        tempSRAttachment.Service_Contract__c = requestObj.relatedObjectId;
      }else if(requestObj.relatedObjectId != null && requestObj.relatedObjectId != '' && (objectType != null && objectType == 'Opportunity')){
        tempSRAttachment.Opportunity__c = requestObj.relatedObjectId;
      }else if(requestObj.relatedObjectId != null && requestObj.relatedObjectId != '' && (objectType != null && objectType == 'Generation_Assets__c')){
        tempSRAttachment.Generation_Asset__c = requestObj.relatedObjectId;
      }
      
      tempSRAttachment.Wet_Sign_Status__c = requestObj.wetSign;
      if(requestObj.wetSign == EDPUtil.SIGNED){
        //setWetSignatureStatus(requestObj, tempSRAttachment); NOT NEEDED FOR GA Photos
      }
      System.debug('tempSRAttachment: ' + tempSRAttachment);
      srAttachments.add(tempSRAttachment);
       System.debug('srAttachments: ' + srAttachments);
      upsert srAttachments;
        } catch( Exception ee) { 
          System.debug('Error Message: ' + ee.getMessage());
      return false;
        }
      
       return true;
    } 
    


    public static Boolean upsertSRAttachment(FileUploaderComponent.UpsertRequest requestObj){
         String documentSource = EDPUtil.PROPOSAL_TOOL_SOURCE;
         try { 
            List<SR_Attachment__c> srAttachments = new List<SR_Attachment__c>();
            String soqlStr = getSRAttachmentSOQL();
            String documentType = requestObj.documentType;
            String fileName = requestObj.fileName;
            String relatedObjectId = requestObj.relatedObjectId;
			String objectType = getSObjectType(relatedObjectId);
             
            Document_Classification__c classificationObj = [Select Id,  ESignature_allowed__c from Document_Classification__c 
                                                                where Id =:requestObj.documentType];
            if(classificationObj != null && classificationObj.ESignature_allowed__c == true){
                soqlStr += ' where Document_Classification__c = :documentType AND active__c = true ' ;
                soqlStr += ' AND document_source__c != :documentSource  ';
                if(objectType != null && objectType == 'ServiceContract'){
                	soqlStr += ' AND service_contract__c =: relatedObjectId ' ;
                }else if(objectType != null && objectType == 'Opportunity'){
                	soqlStr += ' AND Opportunity__c =: relatedObjectId ' ;
                }else{
                	soqlStr += ' AND proposal__c =: relatedObjectId ' ;
                }         

                System.debug('soqlStr: ' + soqlStr);
                srAttachments =  Database.query(soqlStr);
                for(SR_Attachment__c srAttachmentobj : srAttachments){
                    srAttachmentobj.active__C = false;
                    srAttachmentobj.Document_Name_On_File_Server__c = (srAttachmentobj.Document_Name_On_File_Server__c == null 
                                                                        || srAttachmentobj.Document_Name_On_File_Server__c == '') ? 
                                                                        srAttachmentobj.Document_Name__c :  srAttachmentobj.Document_Name_On_File_Server__c;
                }

            }
            SR_Attachment__c tempSRAttachment = new SR_Attachment__c();     
            tempSRAttachment.Document_Classification__c = requestObj.documentType;
            tempSRAttachment.Document_Name__c = requestObj.fileName;
            tempSRAttachment.Document_Name_On_File_Server__c = requestObj.amazonS3FileName;
            tempSRAttachment.Size__c = requestObj.size;
            tempSRAttachment.Document_Source__c = EDPUtil.MANUAL_UPLOAD_SOURCE;
            if(requestObj.relatedObjectId != null && requestObj.relatedObjectId != ''){
             	if(objectType != null && objectType == 'ServiceContract'){
                	tempSRAttachment.service_contract__c = requestObj.relatedObjectId;
             	}else if(objectType != null && objectType == 'Opportunity'){
                	tempSRAttachment.Opportunity__c = requestObj.relatedObjectId;
             	}else{
             		tempSRAttachment.Proposal__c = requestObj.relatedObjectId;
             	}
            }
            
      		tempSRAttachment.Wet_Sign_Status__c = requestObj.wetSign;
            if(requestObj.wetSign == EDPUtil.SIGNED || requestObj.wetSign == EDPUtil.SR_COUNTERSIGNED){
              tempSRAttachment.Wet_Sign_Status__c = EDPUtil.SIGNED;
                setWetSignatureStatus(requestObj, tempSRAttachment);
            }
            System.debug('tempSRAttachment: ' + tempSRAttachment);
            srAttachments.add(tempSRAttachment);
			upsert srAttachments;
        } catch( Exception ee) { 
            System.debug('Error Message: ' + ee.getMessage());
            return false;
        }
        return true;
    }
    
    private static void  setWetSignatureStatus(FileUploaderComponent.UpsertRequest requestObj, SR_Attachment__c srAttachment){
        
        Proposal__c proposalObject = EDPUtil.getProposalObject(requestObj.relatedObjectId);
        if(proposalObject == null || requestObj.documentType == null || requestObj.documentType == '')
            return;
            
        String categoryType = EDPDocumentSettings.REQUIRES_SIGNATURE;
        String requiredForSubmission = null;
        Set<String> modes = new Set<String>();
        modes.add(EDPUtil.READ);
        modes.add(EDPUtil.EDIT);
        modes.add(EDPUtil.NONE);
        Map<String, Document_Classification__c> documentClassificationIdMap;
        documentClassificationIdMap = EDPDocumentSettings.getDocumentClassificationIdMapByCategroy(categoryType, requiredForSubmission,modes,
                                                                                            proposalObject.Sales_Partner__c,
                                                                                            proposalObject.Install_Partner__c);
        Document_Classification__c documentClassificationObj = documentClassificationIdMap.get(requestObj.documentType);
        if(documentClassificationObj != null){
            List<Partner_Document_Relationship__c> partnerDocumentRelationships =   documentClassificationObj.Partner_Document_Relationships__r;
            if(partnerDocumentRelationships != null && partnerDocumentRelationships.size() > 0){
                Partner_Document_Relationship__c ptrRelationshipObj = partnerDocumentRelationships[0];          
                if(ptrRelationshipObj.Partner_signature_required__c == true){
                    srAttachment.Partner_Signed__c = EDPUtil.WET_SIGNED;
                }else{
                    srAttachment.Partner_Signed__c = 'N/A';
                }
                if(ptrRelationshipObj.Customer_signature_required__c == true){
                    srAttachment.Customer_Signed__c = EDPUtil.WET_SIGNED;
                }else{
                    srAttachment.Customer_Signed__c = 'N/A';
                }
                System.debug('requestObj.wetSign: ' + requestObj.wetSign);
                if(ptrRelationshipObj.SR_Ops_signature_required__c == true 
                    && requestObj.wetSign == EDPUtil.SR_COUNTERSIGNED){
                    srAttachment.SunRun_Signed__c = EDPUtil.WET_SIGNED;
                    srAttachment.DocuSign_Status__c = EDPUtil.WET_SIGNED;
                }else if(ptrRelationshipObj.SR_Ops_signature_required__c == false){
                    srAttachment.DocuSign_Status__c = EDPUtil.WET_SIGNED;
                     srAttachment.SunRun_Signed__c = 'N/A';
                }
                System.debug('srAttachment: ' + srAttachment);
            }
        }
    }


    public static SunRunS3RestConnection getDocumentFromS3ForWelcomeEmail(SR_Attachment__c srAttachmentObj, Boolean masterDoc){
        String fileName = srAttachmentObj.Document_Name_On_File_Server__c;
        //String proposalName = srAttachmentObj.Proposal__r.name;
        String proposalName = srAttachmentObj.Parent_Proposal_Name__c;
        if(srAttachmentObj.Document_Source__c == EDPUtil.PROPOSAL_TOOL_SOURCE){
            proposalName = SunRunS3RestConnection.getProposalNameForMasterDocs(proposalName);               
        }
        String documentSource = srAttachmentObj.Document_Source__c;
        String sunrunS3ProxySettingName = getSunRunS3ProxySettingsName(srAttachmentObj, masterDoc);
        SunRunS3RestConnection conn = new SunRunS3RestConnection(sunrunS3ProxySettingName); 
        conn.makeRequest('GET', proposalName , fileName);
        return conn;
    }
    
    
    public static SunRunS3RestConnection getDocumentFromS3(SR_Attachment__c srAttachmentObj, Boolean masterDoc){
        String fileName = srAttachmentObj.Document_Name_On_File_Server__c;
        String proposalName = srAttachmentObj.Parent_Proposal_Name__c;
        if(srAttachmentObj.Wet_Sign_Status__c == null || srAttachmentObj.Wet_Sign_Status__c == '' ){
            String tempProposalName = proposalName;
            Integer index = tempProposalName.indexOf('-');
            proposalName = tempProposalName.substring(0, index);
        }
        String documentSource = srAttachmentObj.Document_Source__c;
        String sunrunS3ProxySettingName = getSunRunS3ProxySettingsName(srAttachmentObj, masterDoc);
      //  system.debug('sunrunS3ProxySettingName' + sunrunS3ProxySettingName);
       // SunRunS3RestConnection.proxySetting = sunrunS3ProxySettingName;
        SunRunS3RestConnection conn = new SunRunS3RestConnection(sunrunS3ProxySettingName); 
        system.debug('proposalNamegetDocumentFromS3' +  proposalName);
        system.debug('fileNamegetDocumentFromS3' +  fileName);
        conn.makeRequest('GET', proposalName , fileName);
        return conn;
    }   

    public static String getSunRunS3ProxySettingsName(SR_Attachment__c srAttachmentObj, boolean masterDoc){
        String sunrunS3ProxySettingName = ''; 
        if(masterDoc == true){
            if(srAttachmentObj.Wet_Sign_Status__c != null && srAttachmentObj.Wet_Sign_Status__c != ''){
                return SunRunS3RestConnection.UPLOADED_DOCS_SETTINGS_NAME;
            }else{
                return SunRunS3RestConnection.PROPOSAL_DOCS_SETTINGS_NAME;
            }
        }else{
            if(srAttachmentObj.Document_Source__c == EDPUtil.PROPOSAL_TOOL_SOURCE){
                sunrunS3ProxySettingName = SunRunS3RestConnection.PROPOSAL_DOCS_SETTINGS_NAME;
            }else if(srAttachmentObj.DocuSign_Status__c == EDPUtil.COMPLETED){
                sunrunS3ProxySettingName = SunRunS3RestConnection.COMPLETED_SIGNED_DOCS_SETTINGS_NAME;
            }else if(srAttachmentObj.Document_Source__c == EDPUtil.MANUAL_UPLOAD_SOURCE && 
            	!String.isEmpty(srAttachmentObj.Parent_Proposal_Name__c) &&
            	!String.isEmpty(srAttachmentObj.Folder_Name__c)){
				sunrunS3ProxySettingName =  srAttachmentObj.Folder_Name__c;
            }else if(srAttachmentObj.Document_Source__c == EDPUtil.MANUAL_UPLOAD_SOURCE && srAttachmentObj.Service_Contract__c != null){
				sunrunS3ProxySettingName =  SunRunS3RestConnection.SERVICE_CONTRACT_DOCS_SETTINGS_NAME;
            }else if(srAttachmentObj.Document_Source__c == EDPUtil.MANUAL_UPLOAD_SOURCE && srAttachmentObj.Opportunity__c != null){
				sunrunS3ProxySettingName =  SunRunS3RestConnection.OPPORTUNITY_DOCS_SETTINGS_NAME;
            }else if(srAttachmentObj.Document_Source__c == EDPUtil.MANUAL_UPLOAD_SOURCE){
                sunrunS3ProxySettingName =  SunRunS3RestConnection.UPLOADED_DOCS_SETTINGS_NAME;
            }else{
                sunrunS3ProxySettingName = SunRunS3RestConnection.INCOMPLETE_DOCS_SETTINGS_NAME;
            }           
        }
        System.debug('sunrunS3ProxySettingName: ' + sunrunS3ProxySettingName);
        return sunrunS3ProxySettingName;
    }

	public static String getOptyAttachmentSOQL(){
        String soqlStr = '';
        soqlStr += ' Select Id, name, CreatedDate, LastModifiedById, LastModifiedDate, Active__c, Bucket_Name__c, Customer_Signed__c,Folder_name__c, ' ;
        soqlStr += ' Description__c, Document_Classification__c, Document_Id__c, Document_Name__c, Document_Name_On_File_Server__c, ' ;
        soqlStr += ' Document_Source__c, Document_Type_Name__c, DocuSign_Error_Code__c, DocuSign_Error_Message__c, DocuSign_Status__c, ';
        soqlStr += ' Envelop_Id__c, ETag__c, Service_Contract__C, Proposal_Document_Type__c, Secondary_Customer_Status__c, Parent_proposal_name__c, ';
        soqlStr += ' Parent_SR_Attachment__c, Proposal_Source__c, Opportunity__r.name, Opportunity__c, ';
        soqlStr += ' Size__c, SunRun_Signed__c, Wet_Sign_Status__c, Opportunity__r.Id, Opportunity__r.Prospect_Id__c, ';
        soqlStr += ' Document_Classification__r.ESignature_allowed__c, Document_Classification__r.Category__c ';
		soqlStr += ' FROM SR_Attachment__c  ';
		return soqlStr;
    }

	public static String getSCAttachmentSOQL(){
        String soqlStr = '';
        soqlStr += ' Select Id, name, CreatedDate, LastModifiedById, LastModifiedDate, Active__c, Bucket_Name__c, Customer_Signed__c, Folder_name__c, ' ;
        soqlStr += ' Description__c, Document_Classification__c, Document_Id__c, Document_Name__c, Document_Name_On_File_Server__c, ' ;
        soqlStr += ' Document_Source__c, Document_Type_Name__c, DocuSign_Error_Code__c, DocuSign_Error_Message__c, DocuSign_Status__c, ';
        soqlStr += ' Envelop_Id__c, ETag__c, Service_Contract__C, Proposal_Document_Type__c, Secondary_Customer_Status__c, Parent_proposal_name__c, ';
        soqlStr += ' Parent_SR_Attachment__c, Proposal_Source__c, Service_Contract__r.name, Opportunity__c, ';
        soqlStr += ' Size__c, SunRun_Signed__c, Wet_Sign_Status__c, Service_Contract__r.Id,  ';
        soqlStr += ' Document_Classification__r.ESignature_allowed__c, Document_Classification__r.Category__c ';
		soqlStr += ' FROM SR_Attachment__c  ';
        return soqlStr;
    }
	
	public static String getSRAttachmentSOQL(){
        String soqlStr = '';
		soqlStr += ' Select Id, name, CreatedDate, LastModifiedById, LastModifiedDate, Active__c, Bucket_Name__c, Customer_Signed__c,Folder_name__c, ' ;
        soqlStr += ' Description__c, Document_Classification__c, Document_Id__c, Document_Name__c, Document_Name_On_File_Server__c, ' ;
        soqlStr += ' Document_Source__c, Document_Type_Name__c, DocuSign_Error_Code__c, DocuSign_Error_Message__c, DocuSign_Status__c, ';
        soqlStr += ' Envelop_Id__c, ETag__c, Partner_Signed__c, Proposal__c, Proposal_Document_Type__c, Secondary_Customer_Status__c, Parent_proposal_name__c, ';
        soqlStr += ' Parent_SR_Attachment__c, Proposal_Source__c, Service_Contract__c, Service_Contract__r.name, Proposal__R.Opportunity__r.Purchased_Thru__c, ';
        soqlStr += ' Size__c, SunRun_Signed__c, Wet_Sign_Status__c, proposal__r.name, proposal__r.Id, proposal__r.stage__c,  proposal__r.state__c, ';
        soqlStr += ' Document_Classification__r.ESignature_allowed__c, Proposal__r.proposal_source__c, Document_Classification__r.Category__c, ';
        soqlStr += ' Proposal__r.Signed__c, Proposal__r.Change_Order_Information__c, Opportunity__r.Id, Opportunity__r.Prospect_Id__c, Opportunity__r.name, Opportunity__c,';
		soqlStr += ' Proposal__R.Opportunity__r.Sales_Partner__c, Proposal__R.Opportunity__r.Account.BillingCity, ';
		soqlStr += ' proposal__r.Sales_Partner__c, proposal__r.Sales_Partner_Name__c, proposal__r.Install_Partner__c, proposal__r.Agreement_Type__c,  proposal__r.Program_Type__c,proposal__r.Utility__c  FROM SR_Attachment__c  ';
        return soqlStr;
    }
    
    public static String getSRAuditAttachmentSOQL(){
        String soqlStr = '';
        soqlStr += ' Select Id, Name, CreatedDate, LastModifiedById, LastModifiedDate, Active__c,';
        soqlStr += ' Document_Name__c, Document_Name_On_File_Server__c, parent_name__c, ';
        soqlStr += ' Size__c, InstallAudit__r.Generation_Asset__r.name, InstallAudit__r.Generation_Asset__c, ';
        soqlStr += ' InstallAudit__r.Service_Contract__r.name, InstallAudit__r.Service_Contract__c ';
        soqlStr += ' FROM SR_Audit_Attachment__c  ';
        return soqlStr;
    }    
    
    public static String getSRGenAssetAttachmentSOQL(){
        String soqlStr = '';
        soqlStr += ' Select Id, Name, CreatedDate, LastModifiedById, LastModifiedDate, Active__c, Bucket_Name__c, Customer_Signed__c, ' ;
        soqlStr += ' Description__c, Document_Classification__c, Document_Id__c, Document_Name__c, Document_Name_On_File_Server__c, ' ;
        soqlStr += ' Document_Source__c, Document_Type_Name__c, DocuSign_Error_Code__c, DocuSign_Error_Message__c, DocuSign_Status__c, ';
        soqlStr += ' Envelop_Id__c, ETag__c, Partner_Signed__c, Generation_Asset__c, Gen_Asset_Document_Type__c, Secondary_Customer_Status__c, Parent_Gen_Asset_Name__c, ';
        soqlStr += ' Size__c, SunRun_Signed__c, Wet_Sign_Status__c, Generation_Asset__r.name, Generation_Asset__r.Id, ';
        soqlStr += ' Service_Contract__c, Service_Contract__r.name, Service_Contract__r.Id ';
        soqlStr += ' FROM SR_Gen_Asset_Attachment__c  ';
        return soqlStr;
    }    
    public static Map<Id, SR_Attachment__c> getSRAttachmentsByEnvelopId(List<String> envelopIds, Set<String> documentTypes){
        Map<Id, SR_Attachment__c> srAttachmentMap = new Map<Id, SR_Attachment__c>([Select Id, name,Bucket_Name__c, Customer_Signed__c, Description__c, Document_Id__c,Active__c,
                                                    Document_Name__c, Document_Source__c, DocuSign_Error_Code__c, DocuSign_Error_Message__c,Document_Name_On_File_Server__c,
                                                    Document_Classification__c, DocuSign_Status__c, Envelop_Id__c, ETag__c, Opportunity__c, Partner_Signed__c, Parent_Proposal_Name__c,
                                                    Proposal_Document_Type__c, Proposal__c, Secondary_Customer_Status__c, Size__c, SunRun_Signed__c, 
                                                    Document_Type_Name__c, OSA_URL__c, Wet_Sign_Status__c, proposal__r.name                                     
                                                    FROM SR_Attachment__c where Envelop_Id__c in :envelopIds and Document_Type_Name__c in :documentTypes]);
        return srAttachmentMap;
    }

    public static Map<Id, SR_Attachment__c> getSRAttachments(Set<String> envelopIds){
        Map<Id, SR_Attachment__c> srAttachmentMap = new Map<Id, SR_Attachment__c>([Select Id, name,Bucket_Name__c, Customer_Signed__c, Description__c, Document_Id__c,Active__c,
                                                    Document_Name__c, Document_Source__c, DocuSign_Error_Code__c, DocuSign_Error_Message__c,Document_Name_On_File_Server__c,
                                                    Document_Classification__c, DocuSign_Status__c, Envelop_Id__c, ETag__c, Opportunity__c, Partner_Signed__c, Parent_Proposal_Name__c,
                                                    Proposal_Document_Type__c, Proposal__c, Secondary_Customer_Status__c, Size__c, SunRun_Signed__c, 
                                                    Document_Type_Name__c, OSA_URL__c, Wet_Sign_Status__c, proposal__r.name                                     
                                                    FROM SR_Attachment__c where Envelop_Id__c in :envelopIds]);
        return srAttachmentMap;
    }
    
    public static String verifyDocumentSignatures(List<Id> proposalIds){
    	String sunrunId = System.Label.Sunrun_Inc_Id;
        String errorMessage = EDPUtil.SUCCESS;
        String soqlStr ;
        String sunrunRecipientEmail = Label.SunRun_DocuSign_Email; 
        String documentSource = EDPUtil.PROPOSAL_TOOL_SOURCE;
        soqlStr = SRAttachmentManager.getSRAttachmentSOQL();
        soqlStr += '  where proposal__c in :proposalIds ' ;
        soqlStr += '  AND document_source__c != :documentSource ' ;
        soqlStr += '  AND Envelop_Id__c != null AND Envelop_Id__c != \'\' ' ;
        soqlStr += '  AND active__c = true ' ;  
        Map<Id, String> documentToEnvelopMap = new Map<Id, String>();
        for(SR_Attachment__c attachmentObj : Database.query(soqlStr)){      
			
			String installPartner = (attachmentObj.proposal__r.install_partner__C == null) ? '' : attachmentObj.proposal__r.install_partner__C; 
			if(!String.isEmpty(installPartner) && installPartner.length() >= 15){
				installPartner = installPartner.substring(0,15);
			}
			System.debug('attachmentObj.Document_Name__c: ' + attachmentObj.Document_Name__c);
			System.debug('installPartner: ' + installPartner);
			System.debug('sunrunId: ' + sunrunId);
			if(attachmentObj.Document_Type_Name__c == 'EPC' && !String.isEmpty(installPartner) && sunrunId.contains(installPartner)){
				continue;
			}
            documentToEnvelopMap.put(attachmentObj.Id, attachmentObj.Envelop_Id__c);
        }
		
		if(documentToEnvelopMap != null && !documentToEnvelopMap.isEmpty()){
			Map<Id, dsfs__DocuSign_Status__c> docuSignStatusMap = new Map<Id, dsfs__DocuSign_Status__c>([Select Id, name, SR_Attachment__c from dsfs__DocuSign_Status__c where SR_Attachment__c in :documentToEnvelopMap.keySet()]);
	
	        if(docuSignStatusMap != null && !docuSignStatusMap.isEmpty()){
		        List<dsfs__DocuSign_Recipient_Status__c> recipeintList = [Select Id, dsfs__DocuSign_Recipient_Email__c,dsfs__Parent_Status_Record__c, Name, dsfs__Recipient_Status__c,
		                                                                    dsfs__DocuSign_Routing_Order__c from dsfs__DocuSign_Recipient_Status__c 
		                                                                    where dsfs__Parent_Status_Record__c in :docuSignStatusMap.keySet() and 
		                                                                    dsfs__Envelope_Id__c =:documentToEnvelopMap.values()
		                                                                    and dsfs__Recipient_Status__c != 'Completed'
		                                                                    and dsfs__DocuSign_Recipient_Email__c =:sunrunRecipientEmail];
		        if(recipeintList.size() > 0){
		            errorMessage =  CustomErrorMessages.MISSING_SUNRUN_SIGNATURES;
		        }
	        }
		}
        return errorMessage;
    }
	
	public static String getSObjectType(String id){
		String objectName = '';
		if(id != null && id != ''){
			Schema.DescribeSObjectResult genResult = Generation_Assets__c.sObjectType.getDescribe();
			Schema.DescribeSObjectResult proposalResult = Proposal__c.sObjectType.getDescribe();
			Schema.DescribeSObjectResult fsDispatchResult = FS_Dispatch__c.sObjectType.getDescribe();
			Schema.DescribeSObjectResult scResult = ServiceContract.sObjectType.getDescribe();
			Schema.DescribeSObjectResult iaResult = Install_Audit__c.sObjectType.getDescribe();
			Schema.DescribeSObjectResult optyResult = Opportunity.sObjectType.getDescribe();
			
			String genKeyPrefix = genResult.getKeyPrefix();
			String fsDispatchKeyPrefix = fsDispatchResult.getKeyPrefix();            
			String scKeyPrefix = scResult.getKeyPrefix();
			String proposalKeyPrefix = proposalResult.getKeyPrefix();
			String iaKeyPrefix = iaResult.getKeyPrefix();
			String optyKeyPrefix = optyResult.getKeyPrefix();
                     
			if(id.startsWith(genKeyPrefix)){
				objectName = genResult.getName();
			}else if(id.startsWith(scKeyPrefix)){
				objectName = scResult.getName();
			}else if(id.startsWith(fsDispatchKeyPrefix)){
				objectName = fsDispatchResult.getName();
			}else if(id.startsWith(iaKeyPrefix)){
				objectName = iaResult.getName();
			}else if(id.startsWith(proposalKeyPrefix)){
				objectName = proposalResult.getName();
			}else if(id.startsWith(optyKeyPrefix)){
				objectName = optyResult.getName();
			}
		}
		return objectName;
    }
    
}