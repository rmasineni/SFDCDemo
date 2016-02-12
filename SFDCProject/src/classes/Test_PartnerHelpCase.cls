@isTest (SeeAllData=true)
public with sharing class Test_PartnerHelpCase {
	public static testmethod void CaseSearchTest(){
		CaseSearch caseSearchObj = new caseSearch();
		Boolean hasNext = caseSearchObj.hasNext;
		Boolean hasPrevious = caseSearchObj.hasPrevious;
		Integer pageNumber = caseSearchObj.pageNumber;
		caseSearchObj.doNewCase();
		caseSearchObj.doSearch();
		caseSearchObj.doviewCase();
		caseSearchObj.first();
		caseSearchObj.getcases();
		caseSearchObj.getSearchBy();
		caseSearchObj.last();
		caseSearchObj.next();
		caseSearchObj.previous();
		caseSearchObj.redirectToDoc();
		
		caseSearchObj.searchValue = '';
		caseSearchObj.doSearch();
		caseSearchObj.searchValue = 'O';
		caseSearchObj.doSearch();
		caseSearchObj.searchValue = 'Open';
		caseSearchObj.searchColumnName = 'case';
		caseSearchObj.doSearch();
		caseSearchObj.searchColumnName = 'subj';
		caseSearchObj.doSearch();
		caseSearchObj.searchColumnName = 'status';
		caseSearchObj.doSearch();
		caseSearchObj.searchColumnName = 'propsId';
		caseSearchObj.doSearch();
		caseSearchObj.searchColumnName = 'propCustName';
		caseSearchObj.doSearch();

	}
	
	public static testmethod void PartnerCaseDetailTest(){
		Test.startTest();
		
		Case caseobj = new case();
		caseobj.Status = 'open';
		caseobj.Subject = 'Testing123';
		caseobj.Description = 'Testing123';
		caseobj.Help_Category__c = 'other';
		caseobj.Help_Category_Type__c = 'Electronic Deal Processing';
		
		insert caseobj;
		ApexPages.StandardController stdController = new ApexPages.StandardController(caseobj);
		PartnerCaseDetail CaseDetailObj = new PartnerCaseDetail(stdController);
		CaseDetailObj.doClose();
		CaseDetailObj.editCase();
		CaseDetailObj.getCaseComment();
		CaseDetailObj.getCaseId();
		CaseDetailObj.initialize();
		
		Test.stopTest();
	}
	
	public static testmethod void PartnerCreateCaseTest(){
		
		Id userId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
    	User partnerUser = [Select id, name, email from User where Id =:userId];
    	
		Test.startTest();
		
		System.runAs(partnerUser){
		Case caseobj2 = new case();

		ApexPages.StandardController stdController1 = new ApexPages.StandardController(caseobj2);
		PartnerCreateCase CreateCaseObj1 = new PartnerCreateCase(stdController1);
		CreateCaseObj1.checkLoginUser();
		CreateCaseObj1.submitCase();
		CreateCaseObj1.doCancel();
		CreateCaseObj1.getpriorityOption();
		
		CreateCaseObj1.caseRec.Help_Category__c = '';
		CreateCaseObj1.submitCase();
		CreateCaseObj1.caseRec.Subject ='';
		CreateCaseObj1.caseRec.Description = '';
		CreateCaseObj1.submitCase();
		CreateCaseObj1.caseRec.Help_Category__c = 'eSignatures';
		CreateCaseObj1.caseRec.Proposal__c = null;
		CreateCaseObj1.submitCase();
		CreateCaseObj1.doCancel();
		
		CreateCaseObj1.caseRec.Help_Category__c = 'Other';
		CreateCaseObj1.caseRec.Subject ='Testing1234';
		CreateCaseObj1.caseRec.Description = 'Testing1234';
		CreateCaseObj1.submitCase();
		}
		
		Proposal__c propObj = [Select Id, Homeowner_Name__c from Proposal__c limit 1];
		Case caseobj1 = new case();
		caseobj1.Status = 'open';
		caseobj1.Subject = 'Testing123';
		caseobj1.Description = 'Testing123';
		caseobj1.Help_Category__c = 'eSignatures';
		caseobj1.Help_Category_Type__c = 'Electronic Deal Processing';

		insert caseobj1;
		
		ApexPages.currentPage().getParameters().put('caseId', caseobj1.Id);
		ApexPages.StandardController stdController = new ApexPages.StandardController(caseobj1);
		PartnerCreateCase CreateCaseObj = new PartnerCreateCase(stdController);

		CreateCaseObj.checkLoginUser();
		CreateCaseObj.doCancel();
		CreateCaseObj.getpriorityOption();
		CreateCaseObj.submitCase();
		CreateCaseObj.caseRec.Description = 'Testing123456';
		CreateCaseObj.caseRec.Proposal__c = propObj.id;
		CreateCaseObj.submitCase();
		
		String customername = CreateCaseObj.propCustomerName;
		
		Test.stopTest();
	}
	
	public static testmethod void PartnerCreateCaseCommentTest(){
		
		Id userId1 = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
    	User partnerUser1 = [Select id, name, email from User where Id =:userId1];
    	
		Test.startTest();
		
		System.runAs(partnerUser1){
		Case caseobj3 = new case();
		caseobj3.Status = 'open';
		caseobj3.Subject = 'Testing123';
		caseobj3.Description = 'Testing123';
		caseobj3.Help_Category__c = 'eSignatures';
		caseobj3.Help_Category_Type__c = 'Electronic Deal Processing';

		insert caseobj3;
		
		ApexPages.StandardController stdController3 = new ApexPages.StandardController(caseobj3);
		PartnerCreateCaseComment CaseCommentObj = new PartnerCreateCaseComment(stdController3);
		
		CaseCommentObj.saveComment();
		
		}
	}
	
	
}