public with sharing class quickCase 
{
    public final Generation_Assets__c genAsset;
    public List<qCaseWrapper> qCaseTemplates = new List<qCaseWrapper>();
    public String srchCaseReason {get;set;}
    public String caseReason {get;set;}
    public String privateCustomerCareDesc{get;set;}
    public String caseSubsetReason {get;set;}
    public String caseOrigin {get;set;}
    public String caseSubject {get;set;}
    public String caseDescription {get;set;}
    public String casePriority{get;set;}
    public String fsTicket {get;set;}
    public String recTypeName {get;set;}    
    public String fsInitialDiagnosis {get;set;}
    public String sortField {get; set;}
    public String previousSortField {get; set;}
    public Boolean pageLoad {get; set;}
	List<Quick_Case_Template__c> qCaseTemplateList;
        
    public quickCase(ApexPages.StandardController stdController) 
    {
        this.genAsset = (Generation_Assets__c)stdController.getRecord();
        fsTicket = ApexPages.currentPage().getParameters().get('fsTicket');
        if (fsTicket == null)
        {
            fsTicket = '';
        }
        pageLoad = true;
    }

    public class qCaseWrapper
    {
        public Quick_Case_Template__c qCaseTemplateRec{get; set;}
        public Boolean recSelected {get; set;}

        public qCaseWrapper(Quick_Case_Template__c qCaseTemplate)
        {
            qCaseTemplateRec = qCaseTemplate;
            recSelected = false;
        }
    }

    public List<qCaseWrapper> getqCaseTemplates() 
    {
        if ((qCaseTemplates == null || qCaseTemplates.size() <= 0) && pageLoad)
        {
        	pageLoad = false;
//            Quick_Case_Template__c[] qCaseTemplateList;
			system.debug('fsTicket : ' + fsTicket);
            if (fsTicket != null && fsTicket != '')
            {
                qCaseTemplateList = [Select Name, Priority__c, Private_Customer_Care_Description__c, Case_Origin__c, Case_Reason__c, Description__c, Subject__c, Subset_Reason__c,FS_Initial_Diagnosis__c,Case_Record_Type__c From Quick_Case_Template__c where Case_Record_Type__c = 'FS Ticket'];
            }
            else
            {
                qCaseTemplateList = [Select Name, Priority__c, Private_Customer_Care_Description__c, Case_Origin__c, Case_Reason__c, Description__c, Subject__c, Subset_Reason__c,FS_Initial_Diagnosis__c,Case_Record_Type__c From Quick_Case_Template__c where Case_Record_Type__c != 'FS Ticket'];
            }
            for(Quick_Case_Template__c qCaseTemplateRec : qCaseTemplateList)
            {
                qCaseTemplates.add(new qCaseWrapper(qCaseTemplateRec));
            }    
        }
        return qCaseTemplates;
    }

    public PageReference refreshTemplates() 
    {
        if (srchCaseReason != null)
        {
            qCaseTemplateList.clear();
            
            if (srchCaseReason != '---All---')
            {
	            if (fsTicket != null && fsTicket != '')
	            {
	                qCaseTemplateList = [Select Name, Priority__c, Private_Customer_Care_Description__c, Case_Origin__c, Case_Reason__c, Description__c, Subject__c, Subset_Reason__c,FS_Initial_Diagnosis__c,Case_Record_Type__c From Quick_Case_Template__c where Case_Record_Type__c = 'FS Ticket' And Case_Reason__c = :srchCaseReason];
	            }
	            else
	            {
	                qCaseTemplateList = [Select Name, Priority__c, Private_Customer_Care_Description__c, Case_Origin__c, Case_Reason__c, Description__c, Subject__c, Subset_Reason__c,FS_Initial_Diagnosis__c,Case_Record_Type__c From Quick_Case_Template__c where Case_Record_Type__c != 'FS Ticket' And Case_Reason__c = :srchCaseReason];
	            }
            }
            else
            {
	            if (fsTicket != null && fsTicket != '')
	            {
	                qCaseTemplateList = [Select Name, Priority__c, Private_Customer_Care_Description__c, Case_Origin__c, Case_Reason__c, Description__c, Subject__c, Subset_Reason__c,FS_Initial_Diagnosis__c,Case_Record_Type__c From Quick_Case_Template__c where Case_Record_Type__c = 'FS Ticket'];
	            }
	            else
	            {
	                qCaseTemplateList = [Select Name, Priority__c, Private_Customer_Care_Description__c, Case_Origin__c, Case_Reason__c, Description__c, Subject__c, Subset_Reason__c,FS_Initial_Diagnosis__c,Case_Record_Type__c From Quick_Case_Template__c where Case_Record_Type__c != 'FS Ticket'];
	            }
            }
            qCaseTemplates.clear();
            for(Quick_Case_Template__c qCaseTemplateRec : qCaseTemplateList)
            {
                qCaseTemplates.add(new qCaseWrapper(qCaseTemplateRec));
            }    
        }
        return null;
    }

    public PageReference GetSelectedTemplate()
    {
        caseReason = '';
        caseSubsetReason = '';
        caseOrigin = '';
        caseSubject = '';
        casePriority = '';
        recTypeName = '';
        fsInitialDiagnosis = '';
        privateCustomerCareDesc = '';
        for(qCaseWrapper qCaseTemplateWrapperRec : qCaseTemplates)
        {
            if(qCaseTemplateWrapperRec.recSelected == true)
            {
                caseReason = qCaseTemplateWrapperRec.qCaseTemplateRec.Case_Reason__c;
                caseSubsetReason = qCaseTemplateWrapperRec.qCaseTemplateRec.Subset_Reason__c;
                caseOrigin = qCaseTemplateWrapperRec.qCaseTemplateRec.Case_Origin__c;
                privateCustomerCareDesc = qCaseTemplateWrapperRec.qCaseTemplateRec.Private_Customer_Care_Description__c;
                caseSubject = qCaseTemplateWrapperRec.qCaseTemplateRec.Subject__c;
                caseDescription = qCaseTemplateWrapperRec.qCaseTemplateRec.Description__c;
                casePriority = qCaseTemplateWrapperRec.qCaseTemplateRec.Priority__c;
                recTypeName = qCaseTemplateWrapperRec.qCaseTemplateRec.Case_Record_Type__c;
                fsInitialDiagnosis = qCaseTemplateWrapperRec.qCaseTemplateRec.FS_Initial_Diagnosis__c;
                break;
            }
        }
        return null;
    }

    public PageReference createCase()
    {
        try
        {
            Generation_Assets__c genAssetRec = [Select Account_Name__c, Customer_Contact__c From Generation_Assets__c Where Id = :genAsset.Id];
            System.debug('Record type : ' + recTypeName);

            Case caseRec = new Case();
            RecordType stdRecType = [Select Id from RecordType where Name = :recTypeName and SobjectType = 'Case']; 
            
            caseRec.RecordTypeId = stdRecType.Id;
            caseRec.AccountId = genAssetRec.Account_Name__c;
            caseRec.ContactId = genAssetRec.Customer_Contact__c;
            caseRec.Generation_Asset__c = genAsset.Id;
            caseRec.Reason = caseReason;
            caseRec.Subset_Reasons__c = caseSubsetReason;
            caseRec.Origin = caseOrigin;
            caseRec.Customer_Care_Description__c = privateCustomerCareDesc;
            caseRec.Subject = caseSubject;
            caseRec.Status = 'Open';
            caseRec.Description = caseDescription;
            caseRec.FS_Initial_Diagnosis__c = fsInitialDiagnosis;
            caseRec.Priority = casePriority;
            insert caseRec;
            
            PageReference casePage = new ApexPages.StandardController(caseRec).view();
            casePage.setRedirect(true);
            return casePage;
        }
        catch(Exception ex)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getMessage()));
            return null;
        }
    }
    
    public List<SelectOption> getCaseReasons() 
    {
        Schema.DescribeFieldResult fieldResult = Quick_Case_Template__c.Case_Reason__c.getDescribe();
        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption( '---All---', '---All---'));
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        } 
        return options;    
    }    
 
	public void doSort()
	{

        String order = 'asc';
        /*This checks to see if the same header was click two times in a row, if so
        it switches the order.*/
        if(previousSortField == sortField){
            order = 'desc';
            previousSortField = null;
        }else{
            previousSortField = sortField;
        }
        //To sort the table we simply need to use this one line, nice!
        superSort.sortList(qCaseTemplateList,sortField,order);
        qCaseTemplates.clear();
        for(Quick_Case_Template__c qCaseTemplateRec : qCaseTemplateList)
        {
            qCaseTemplates.add(new qCaseWrapper(qCaseTemplateRec));
        }    
        
	}
     
    
    public static testMethod void quickCaseTest()
    {
        Test.startTest();
        
        Account accountRec = new Account();
        accountRec.Name = 'Test Class';
        insert accountRec;
 
        Contact contactRec = new Contact();
        contactRec.FirstName = 'DSG';
        contactRec.LastName = 'Test';
        contactRec.AccountId = accountRec.Id;
        insert contactRec;
     
        Generation_Assets__c genAssetRec = new Generation_Assets__c();
        genAssetRec.Account_Name__c = accountRec.Id;
        genAssetRec.Customer_Contact__c = contactRec.Id;
        genAssetRec.Name = 'DSG Test';
        genAssetRec.Home_Address__c = '123 Main Street';
        genAssetRec.City__c = 'Los Gatos';
        genAssetRec.Zip__c = '95032';
        insert genAssetRec;
 
        ApexPages.StandardController stdCont = new ApexPages.StandardController(genAssetRec);
        quickCase qCaseTestController = new quickCase(stdCont);
        qCaseTestController.getCaseReasons();
 		qCaseTestController.srchCaseReason = '---All---';
 		qCaseTestController.fsTicket = '';
        List<qCaseWrapper> qCaseTemplates = qCaseTestController.getqCaseTemplates();
        qCaseTestController.refreshTemplates();
		qCaseTestController.sortField = 'Case_Reason__c';
//		qCaseTestController.doSort();
        for(qCaseWrapper qCaseWrapperRec : qCaseTemplates)
        {
            qCaseWrapperRec.recSelected = true;
            break;
        }
        qCaseTestController.qCaseTemplates = qCaseTemplates;
        qCaseTestController.GetSelectedTemplate();
        qCaseTestController.createCase();

 		qCaseTestController.fsTicket = 'FST';
 		qCaseTestController.getCaseReasons();
 		qCaseTestController.srchCaseReason = 'Metering';
        qCaseTemplates = qCaseTestController.getqCaseTemplates();
		qCaseTestController.refreshTemplates();        
		qCaseTestController.sortField = 'Case_Reason__c';
//		qCaseTestController.doSort();
        for(qCaseWrapper qCaseWrapperRec : qCaseTemplates)
        {
            qCaseWrapperRec.recSelected = true;
            break;
        }
		qCaseTestController.qCaseTemplates = qCaseTemplates;
        qCaseTestController.GetSelectedTemplate();
        qCaseTestController.createCase();

        Test.stopTest();
    }
}