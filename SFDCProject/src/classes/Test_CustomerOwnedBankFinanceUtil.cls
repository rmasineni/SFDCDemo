@isTest
public class Test_CustomerOwnedBankFinanceUtil {
    public static testmethod void  Test_CustomerOwnedBankFinance(){
        Account acc = new Account(name = 'Test Account');
        insert acc;
        Opportunity opp = new Opportunity (Name ='Test Opportunity', CloseDate = system.today() +90,StageName = 'Created',Accountid = acc.Id);
        insert opp;
        Proposal__c proposal = new Proposal__c(Agreement_Type__c = 'Customer Owned - Bank Financed' ,Opportunity__c = opp.Id,Sales_Rep_Email__c = 'test@yopmail.com',Date_Issued__c = date.today() ,Mode_Name__c = 'Mode1111',System_Size_STC_DC__c = 2.0 ,Upfront_Payment__c =120.0);
		insert proposal;
        Document_Classification__c  DocClassification1 = new Document_Classification__c (Name = 'Bank Approval Document',Document_Name__c = 'Bank Approval Document');
        insert DocClassification1;
        List<SR_Attachment__c> SRAttachmentList  = new List<SR_Attachment__c>();
        SR_Attachment__c srAttachment1 =  new SR_Attachment__c(Document_Classification__c = DocClassification1.Id,Document_Source__c = 'Manual Upload',Active__c = true, Proposal__c =proposal.Id);
        SRAttachmentList.add(srAttachment1);
        insert SRAttachmentList;
        proposal.Stage__c = 'SR Approved';
        try {
        update proposal;
        }
        catch(Exception e){
            system.debug('Cause of Exception'+e.getCause());
            }
    }
     public static testmethod void  Test_CustomerOwnedBankFinance1 (){
        Account acc = new Account(name = 'Test Account');
        insert acc;
        Opportunity opp = new Opportunity (Name ='Test Opportunity', CloseDate = system.today() +90,StageName = 'Created',Accountid = acc.Id);
        insert opp;
        Proposal__c proposal = new Proposal__c(Agreement_Type__c = 'Customer Owned - Bank Financed' ,Opportunity__c = opp.Id,Sales_Rep_Email__c = 'test@yopmail.com',Date_Issued__c = date.today() ,Mode_Name__c = 'Mode1111',System_Size_STC_DC__c = 2.0 ,Upfront_Payment__c =120.0);
		insert proposal;
        Document_Classification__c  DocClassification1 = new Document_Classification__c (Name = 'Customer Agreement',Document_Name__c = 'Customer Agreement');
        insert DocClassification1;
        List<SR_Attachment__c> SRAttachmentList  = new List<SR_Attachment__c>();
        SR_Attachment__c srAttachment1 =  new SR_Attachment__c(Document_Classification__c = DocClassification1.Id,Document_Source__c = 'Manual Upload',Active__c = true, Proposal__c =proposal.Id);
        SRAttachmentList.add(srAttachment1);
        insert SRAttachmentList;
        proposal.Stage__c = 'SR Approved';
        try {
        update proposal;
        }
        catch(Exception e){}
    
}
}