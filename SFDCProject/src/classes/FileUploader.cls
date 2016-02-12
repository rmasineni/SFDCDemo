public class FileUploader {
	public Id relatedObjectId {get;set;}
	public Id fileUploadType {get;set;}
	
	public FileUploader(ApexPages.StandardController stdController){
	 	relatedObjectId = System.currentPagereference().getParameters().get('id');
	 	System.debug('fileUploadType: ' + fileUploadType);
	} 
	
	public FileUploader(){
		relatedObjectId = System.currentPagereference().getParameters().get('id');
	}
}