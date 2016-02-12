public class PhotoUploader {
	public Id relatedObjectId {get;set;}

	public PhotoUploader(ApexPages.StandardController stdController){
	 	relatedObjectId = System.currentPagereference().getParameters().get('id');
	} 
	
	public PhotoUploader(){
		relatedObjectId = System.currentPagereference().getParameters().get('id');
	}
}