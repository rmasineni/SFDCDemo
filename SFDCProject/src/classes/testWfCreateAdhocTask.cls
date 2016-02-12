@ isTest (seeAllData = true)
public class testWfCreateAdhocTask {
    
    public static Project__c createProject(){
               Profile p = [select id from profile where Name ='System Administrator' limit 1]; 
       User pu = new User(profileId = p.id, username ='testemail', email ='one@email.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US',  languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',  alias='cspu', lastname='lastname', firstname = 'firstname', title = 'developer');
		
        Account a = new Account(name='Test Acct1');
	        insert a;
	        
	        Opportunity oppty = new Opportunity();
	        oppty.AccountId = a.Id;
	        oppty.Name = 'NewCC Test';
	        oppty.StageName = 'Qualified';
	        oppty.CloseDate = Date.Today().addDays(18);
	        insert oppty;
	        //
			//Proposal__c proposal = UnitTest_ServiceContractUtil.createProposal(oppty.Id);
			//
			Proposal__c proposal = new Proposal__c();
		    proposal.Opportunity__c = oppty.Id;
		    proposal.Sales_Rep_Email__c = 'Salesrep@repsfortesting.com';
		    proposal.Date_Issued__c = Date.Today().addDays(18);
		    proposal.Mode_Name__c = 'Mode323';
		    proposal.System_Size_STC_DC__c = 1290;
		    proposal.Upfront_Payment__c = 1290;
           	//proposal__c proposal = UnitTest_ServiceContractUtil.createTestProposal();
			insert proposal;   
           
            ServiceContract scAssetRec = new ServiceContract();
            scAssetRec.accountId = a.Id;
           // scAssetRec.contactId = contactRec.Id;  
           	scAssetRec.Proposal__c = proposal.id;
           	scAssetRec.Opportunity__c = oppty.Id;
           	insert scAssetRec;
                
       		 project__c project = new project__c ( name = 'test project', Account__c= a.Id , Opportunity__c= oppty.id, Proposal__c = proposal.id, service_contract__c = scAssetRec.id); 
       		insert project;	
        return project;
    }
 
       public static testmethod void wfCreateAdhocTask_Test1(){
       
		   Project__c prjct = createProject();
           Phase__c phase = new phase__c( name = 'test phase' , project__c = prjct.id);
           insert phase;
 
           task__c tsk = new task__c();
           ApexPages.StandardController con = new ApexPages.standardController(tsk);
           ApexPages.currentPage().getParameters().put('projectId',prjct.id);
           wfcreateAdhocTaskClass adhoctask = new wfcreateAdhocTaskClass(con);
           adhoctask.newtask.name = 'Test Task';
           adhoctask.newtask.Group_Name__c = 'Branch manager';
           adhoctask.newtask.phase__c = phase.id;
           adhoctask.saveAdhocTask();
           adhoctask.backToSearch();
      
       }  
    
    public static testmethod void wfCreateAdhocTask_Test2(){
        
        project__c prjct = createProject();
        Phase__c phase = new phase__c( name = 'test phase' , project__c = prjct.id);
        insert phase;

        task__c tsk = new task__c();
        tsk.name = 'Test Task';
        tsk.Group_Name__c = 'Branch manager';
        tsk.phase__c = phase.id;
        tsk.project_Name__c = prjct.id;
        insert tsk;
        
        ApexPages.StandardController con = new ApexPages.standardController(tsk);
        ApexPages.currentPage().getParameters().put('projectId',prjct.id);
        wfcreateAdhocTaskClass adhoctask = new wfcreateAdhocTaskClass(con);
        adhoctask.saveAdhocTask();
        
    }  
    
}