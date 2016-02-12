@istest(seeAllData=true)
public with sharing class Test_CreateCase {
	public static testMethod void Test_CreateCase(){
		generation_assets__c g=new generation_assets__c(name='Test',Home_Address__c='Test',city__c='San Jose',zip__c='12344'); 
		insert g;
		Case c=new case(status='Open',origin='Call',Generation_Asset__c=g.id,Reason='Customer',Subset_Reasons__c='Panel Washing',Amount__c=10);
		insert c;
		ApexPages.StandardController controller = new Apexpages.Standardcontroller(c);       
    	//system.currentPageReference().getParameters().put('genid',g.id);    
    	CreateCase cas=new CreateCase(controller);
    	cas.getInvRec();
    	cas.cancel();
    	cas.saveCreate(); 
    	system.currentPageReference().getParameters().put('genid',g.id);
    	CreateCase cas1=new CreateCase(controller);
    	Case c1=new case();  
    	ApexPages.StandardController controller1 = new Apexpages.Standardcontroller(c1);   
    	CreateCase cas2=new CreateCase(controller1);	 	
	
	}
	
	public static testMethod void testCaseRecordTypes(){
		CaseUtil.getCaseRecordTypeByName('Standard');
	}
}