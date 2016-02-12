public class CustomerOwnedBankFinanceUtil {
    public static void setCountBankFinancedProposal(List<Proposal__c> PropList){
        Integer counter = 0;
        Set<Id> ProposalSet = new set<Id>();
        for (Proposal__c proptemp: PropList){
            if(proptemp.Agreement_Type__c =='Customer Owned - Bank Financed'){
                ProposalSet.add(proptemp.Id);
            }
        }
        if (!ProposalSet.isEmpty()){
            Map <Id,List<SR_Attachment__c>> SrAttachmentmap =  new Map <Id,List<SR_Attachment__c>>(); 
            List <SR_Attachment__c> SrAttachmentList = [Select Id, Active__c , Document_Type_Name__c ,Proposal__c , Document_Source__c  from SR_Attachment__c where Proposal__c IN: ProposalSet AND Document_Type_Name__c = 'Bank Approval Document' ];
            if (!SrAttachmentList.isEmpty()){
                for (SR_Attachment__c srtemp : SrAttachmentList){
                    if (srtemp.Active__c == true && srtemp.Document_Type_Name__c == 'Bank Approval Document' && srtemp.Document_Source__c == 'Manual Upload'){
                        List<SR_Attachment__c> SrAttachmentListtemp = SrAttachmentmap.get(srtemp.Proposal__c);
                        If (SrAttachmentListtemp != null) {
                            SrAttachmentListtemp.add(srtemp);
                            SrAttachmentmap.put(srtemp.Proposal__c,srAttachmentListtemp);
                        }else {
                            SrAttachmentListtemp = new List<SR_Attachment__c>();
                            SrAttachmentListtemp.add(srtemp);
                            SrAttachmentmap.put(srtemp.Proposal__c,srAttachmentListtemp);
                        }
                        
                    }
                }
            }
            for (Proposal__c proptemp: PropList){
                if(proptemp.Agreement_Type__c =='Customer Owned - Bank Financed' && (proptemp.SR_Ops_Actions__c == 'SR Approved' || proptemp.Stage__c == 'SR Approved')){
                    List<SR_Attachment__c> SrAttachmentListcount = SrAttachmentmap.get(proptemp.Id);
                    if (SrAttachmentListcount != null){
                        counter = SrAttachmentListcount.size();  
                        proptemp.Number_of_Active_Bank_Approval_Documents__c = counter;
                        system.debug('No. of documents is '+proptemp.Number_of_Active_Bank_Approval_Documents__c);}
                        else{
                        counter = 0;
                        proptemp.Number_of_Active_Bank_Approval_Documents__c = counter;
                        system.debug('No. of documents is '+proptemp.Number_of_Active_Bank_Approval_Documents__c);
                        proptemp.addError('Customer Owned Bank Financed proposal needs to have Bank Approval Document attached before SR Approval.');
                    }
                }
            }
        }
        
    }
    
}