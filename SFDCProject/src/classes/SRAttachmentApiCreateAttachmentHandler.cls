public class SRAttachmentApiCreateAttachmentHandler extends ProposalBaseHandler {

    override public String getApiName() {
        return 'SRAttachmentApiCreateAttachment';
    }
	
	public void validateRequest(RestServiceDto.Request req) {
        List<String> requriedFields = new List<String>();
        requriedFields.add('parentId');
		validateRequiredFields(requriedFields, req);
	}

    public void setProposalData(List<SR_Attachment__c> srAttachments, Proposal__c proposalObj){
		for(SR_Attachment__c srAttachmentObj : srAttachments){
			srAttachmentObj.proposal__c = proposalObj.Id;
		}
    }
    
    public void setOpportunityData(List<SR_Attachment__c> srAttachments, Opportunity optyObj){
		for(SR_Attachment__c srAttachmentObj : srAttachments){
			srAttachmentObj.opportunity__c = optyObj.Id;
		}
    }
	
    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
		resp.jsonWriter = new JsonWriter(true);
		validateRequest(req);
		String parentId = req.jsonReader.getString('parentId');
		String proposalId = '';
		String optyId = '';
		List<SR_Attachment__c> srAttachmentList = getSRAttachments(req);
		if(!String.isEmpty(parentId) && !srAttachmentList.isEmpty()){
			if(parentId.indexOf('P') == 0){
				Proposal__c proposalObj = getProposalByName(parentId);
				if(proposalObj == null){
					throw createBusinessException(RestServiceDto.Error_NotFound, 'Proposal with specified parentId [' + parentId + '] is not found');
				}
				setProposalData(srAttachmentList, proposalObj);
			}else{
				Opportunity optyObj = getOpportunity(parentId);
				if(optyObj == null){
					throw createBusinessException(RestServiceDto.Error_NotFound, 'Opportunity with specified parentId [' + parentId + '] is not found');
				}
				setOpportunityData(srAttachmentList, optyObj);
			}
			
			insert srAttachmentList;

			Integer i = 0;
			resp.jsonWriter.write('proposal', parentId);
			resp.jsonWriter.write('parentId', parentId);
			for (SR_Attachment__c srAttachmentObj : srAttachmentList) {
				resp.jsonWriter.newWith('sr_attachments[' + i + ']');
				resp.jsonWriter.write('srAttachmentId', srAttachmentObj.Id);
				i++;
			}
		}
    }
	
	public List<SR_Attachment__c> getSRAttachments(RestServiceDto.Request req){
		List<SR_Attachment__c> srAttachmentList = new List<SR_Attachment__c>();
		Map<String, Document_Classification__c> documentClassificationMap = EDPDocumentSettings.getDocumentClassificationByName();
        List<Object> objectList = req.JsonReader.getList('documents');
		for(Object currentObj : objectList){
			Map<String,Object> currentMap = (Map<String, Object>)currentObj;
			String documentType = (String) currentMap.get('documentType');
			String documentNameOnFileServer = (String) currentMap.get('documentNameOnFileServer');
			S3MetaData metadataObj = getS3MeataData(documentNameOnFileServer);
			String documentName = (String)  currentMap.get('documentName');
			Document_Classification__c classificatoinObj = documentClassificationMap.get(documentType);
			
			SR_Attachment__c srAttachmentObj = new SR_Attachment__c();
			srAttachmentObj.Document_Name_On_File_Server__c = metadataObj.fileName;
			srAttachmentObj.folder_name__c = metadataObj.folderName;
			srAttachmentObj.Parent_Proposal_Name__c = metadataObj.recordName;
			srAttachmentObj.Document_Source__c = EDPDocumentSettings.MANUAL_UPLOAD;
			srAttachmentObj.Wet_Sign_Status__c = EDPDocumentSettings.NA;
			srAttachmentObj.Document_Classification__c = documentClassificationMap.get(documentType).Id;
			srAttachmentObj.Document_Name__c = documentName;
			srAttachmentObj.active__c = true;
			srAttachmentObj.size__c = '1 MB';
			srAttachmentList.add(srAttachmentObj);
		}
		return srAttachmentList;
    }
    
	
	//Sample URL String: "https://devmaj-sunrun.s3-us-west-2.amazonaws.com/proposal/1705931771/Utility_Bill_12_29_2015_12%3A11%3A11?AWSAccessKeyId=AKIAI3TSGQR3IGCH3C4Q&Expires=1453084150&Signature=EKFHGzkgMl%2B8QVP%2F6dqxemf9a%2BY%3D"
    public S3MetaData getS3MeataData(String urlStr){
		S3MetaData result = new S3MetaData();
    	if(!String.isEmpty(urlStr)){
    		List<String> stringList1 = urlStr.split('\\?');
    		if(stringList1 != null && stringList1.size() > 0){
    			List<String> stringList2 = stringList1[0].split('/');
    			if(stringList2 != null && stringList2.size() >= 3){
    				Integer size = stringList2.size();
					String fileName = stringList2[size - 1];
					result.fileName = EncodingUtil.urlDecode(fileName, 'UTF-8');
					result.recordName = stringList2[size - 2];
					result.folderName = stringList2[size - 3];
    			}
    		}
    	}
    	return result;
    }
    
    class S3MetaData{
    	public string fileName{get;set;}
    	public string folderName{get;set;}
    	public string recordName{get;set;}
    }
}