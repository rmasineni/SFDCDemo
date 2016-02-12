public class ServiceContractPhotoUploader {
	public Id relatedObjectId {get;set;}

	public ServiceContractPhotoUploader(ApexPages.StandardController stdController){
	 	relatedObjectId = System.currentPagereference().getParameters().get('id');
	} 
	
	public ServiceContractPhotoUploader(){
		relatedObjectId = System.currentPagereference().getParameters().get('id');
	}
}