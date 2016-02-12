public class AuditPhotoUploader {
	public Id relatedObjectId {get;set;}

	public AuditPhotoUploader(ApexPages.StandardController stdController){
	 	relatedObjectId = System.currentPagereference().getParameters().get('id');
	} 
	
	public AuditPhotoUploader(){
		relatedObjectId = System.currentPagereference().getParameters().get('id');
	}
}