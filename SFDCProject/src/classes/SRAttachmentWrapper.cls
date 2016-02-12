public class SRAttachmentWrapper {
    public SR_Attachment__C srAttachment{get;set;}
    public String partnerName {get;set;}
    public String partnerEmail {get;set;}
    public String partnerStatus {get;set;}
    
    public String primaryCustomerName {get;set;}
    public String primaryCustomerEmail {get;set;}
    public String primaryCustomerStatus {get;set;}

    public String secondaryCustomerName {get;set;}
    public String secondaryCustomerEmail {get;set;}
    public String secondaryCustomerStatus {get;set;}

    public String sunrunOperationName {get;set;}
    public String sunrunOperationEmail {get;set;}
    public String sunrunOperationStatus {get;set;}
    public Boolean readyForSubmission {get;set;}
    public Boolean signatureRequired {get;set;}
    
    public Boolean selected {
        get; 
        set{selected = value;}
    }
    public String signedURL {get;set;}
    public SRAttachmentWrapper(SR_Attachment__C srAttachmentObj)
    {
        sunrunOperationName = '';
        primaryCustomerName = '';
        secondaryCustomerName = '';
        partnerName = '';
        readyForSubmission = true;
        signatureRequired = true;
        
        srAttachment = srAttachmentObj;
        selected = false;
        if(srAttachment != null){
            String proxySettingName = SRAttachmentManager.getSunRunS3ProxySettingsName(srAttachmentObj, false);
            String proposalName = srAttachmentObj.Parent_Proposal_Name__c ;
            String fileName = (srAttachmentObj.Document_Name_On_File_Server__c == null 
                                || srAttachmentObj.Document_Name_On_File_Server__c == '') ? srAttachmentObj.Document_Name__c : srAttachmentObj.Document_Name_On_File_Server__c;
            if(srAttachmentObj.Document_Source__c == EDPUtil.PROPOSAL_TOOL_SOURCE){
                proposalName = SunRunS3RestConnection.getProposalNameForMasterDocs(proposalName);               
            }
            System.debug('proposalName: ' + proposalName);
            signedURL = SunRunS3RestConnection.getSignedURL('GET', proxySettingName, proposalName, fileName);
            if(srAttachmentObj.Wet_Sign_Status__c == EDPUtil.SIGNED){
                if(srAttachmentObj.Partner_Signed__c == EDPUtil.COMPLETED){
                    partnerStatus = srAttachmentObj.Partner_Signed__c; 
                }
                
                if(srAttachmentObj.Customer_Signed__c == EDPUtil.COMPLETED){
                    primaryCustomerStatus = srAttachmentObj.Customer_Signed__c; 
                }
            }
            
            if(srAttachmentObj != null && (srAttachmentObj.Wet_Sign_Status__c == EDPUtil.SIGNED 
                || srAttachmentObj.Wet_Sign_Status__c == EDPUtil.SR_COUNTERSIGNED)){
                sunrunOperationName = srAttachmentObj.SunRun_Signed__c;
                partnerName = srAttachmentObj.Partner_Signed__c;
                primaryCustomerName = srAttachmentObj.Customer_Signed__c;
                secondaryCustomerName = 'N/A';                  
            }
        }
    }
    
    public SRAttachmentWrapper(SR_Attachment__C srAttachmentObj,boolean IsOpportunity)
    {
        sunrunOperationName = '';
        primaryCustomerName = '';
        secondaryCustomerName = '';
        partnerName = '';
        readyForSubmission = true;
        signatureRequired = true;
        
        srAttachment = srAttachmentObj;
        selected = false;
        if(srAttachment != null){
            
            String proxySettingName;
            if(!String.isEmpty(srAttachmentObj.folder_name__c)){
            	proxySettingName = srAttachmentObj.folder_name__c;
            }else if(IsOpportunity){
                proxySettingName =  'Prospects';
            }else{
                proxySettingName = SRAttachmentManager.getSunRunS3ProxySettingsName(srAttachmentObj, false);
        	}
        	System.debug('srAttachmentObj1: ' + srAttachmentObj);
        	
            String proposalName = (String.isEmpty(srAttachmentObj.Parent_Proposal_Name__c)) ? srAttachmentObj.Opportunity__c + '' : srAttachmentObj.Parent_Proposal_Name__c;
            String fileName = (srAttachmentObj.Document_Name_On_File_Server__c == null 
                                || srAttachmentObj.Document_Name_On_File_Server__c == '') ? srAttachmentObj.Document_Name__c : srAttachmentObj.Document_Name_On_File_Server__c;
           
            System.debug('proposalName: ' + proposalName);
            signedURL = SunRunS3RestConnection.getSignedURL('GET', proxySettingName, proposalName, fileName);
            if(srAttachmentObj.Wet_Sign_Status__c == EDPUtil.SIGNED){
                if(srAttachmentObj.Partner_Signed__c == EDPUtil.COMPLETED){
                    partnerStatus = srAttachmentObj.Partner_Signed__c; 
                }
                
                if(srAttachmentObj.Customer_Signed__c == EDPUtil.COMPLETED){
                    primaryCustomerStatus = srAttachmentObj.Customer_Signed__c; 
                }
            }
            
            if(srAttachmentObj != null && (srAttachmentObj.Wet_Sign_Status__c == EDPUtil.SIGNED 
                || srAttachmentObj.Wet_Sign_Status__c == EDPUtil.SR_COUNTERSIGNED)){
                sunrunOperationName = srAttachmentObj.SunRun_Signed__c;
                partnerName = srAttachmentObj.Partner_Signed__c;
                primaryCustomerName = srAttachmentObj.Customer_Signed__c;
                secondaryCustomerName = 'N/A';                  
            }
        }
    }
    
}