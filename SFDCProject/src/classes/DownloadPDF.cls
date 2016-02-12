public class DownloadPDF {
    
    public Attachment attachedFiles{get;set;}
    
    public DownloadPDF() {
        attachedFiles = [select Id,body,ContentType,name from Attachment where Id = :ApexPages.currentPage().getParameters().get('id') Limit 1];
    }
    
}