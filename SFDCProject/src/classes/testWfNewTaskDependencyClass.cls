@ isTest (seeAllData = true)

public class testWfNewTaskDependencyClass {
    
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
    
    public static testmethod void wfNewTaskDependencyClass_Test1(){
       
            Project__c prjct = createProject();
            Phase__c phase = new phase__c( name = 'test phase' , project__c = prjct.id);
            insert phase;
 
            task__c tsk = new task__c();
            tsk.name = 'Test Task';
            tsk.Group_Name__c = 'Branch manager';
            tsk.phase__c = phase.id;
            tsk.project_Name__c = prjct.id;
            insert tsk;
        
            task_dependency__c tdpncy = new task_dependency__c(); 
            ApexPages.StandardController con = new ApexPages.standardController(tdpncy);
            
            String TaskDependencyLkp = Label.wfTaskDependencyLkpId;
            //ApexPages.currentPage().getParameters().put('CF00Ng00000010Dzb',tsk.name);
            ApexPages.currentPage().getParameters().put(TaskDependencyLkp, tsk.Id);
            wfNewTaskDependencyClass newTaskDependent = new wfNewTaskDependencyClass(con);
            wfNewTaskDependencyClass newTaskDependent2 = new wfNewTaskDependencyClass(tsk.Id);
            newTaskDependent.taskDepend.name = 'task Dependent';
            newTaskDependent.taskDepend.project_name__c = prjct.id;
            newTaskDependent.taskDepend.Parent_Task__c = tsk.Id;
            newTaskDependent.taskDepend.Task__c = tsk.Id; 
            newTaskDependent.taskSave();           
                  
       }  
    
     public static testmethod void wfNewTaskDependencyClass_Test2(){
       
            Project__c prjct = createProject();
            Phase__c phase = new phase__c( name = 'test phase' , project__c = prjct.id);
            insert phase;
 
            task__c tsk = new task__c();
            tsk.name = 'Test Task';
            tsk.Group_Name__c = 'Branch manager';
            tsk.phase__c = phase.id;
            tsk.project_Name__c = prjct.id;
            insert tsk;
            
             task__c tsk2 = new task__c();
            tsk2.name = 'Test Task';
            tsk2.Group_Name__c = 'Branch manager';
            tsk2.phase__c = phase.id;
            tsk2.project_Name__c = prjct.id;
            insert tsk2;
        
            task_dependency__c tdpncy = new task_dependency__c(); 
            ApexPages.StandardController con = new ApexPages.standardController(tdpncy);
            
            String TaskDependencyLkp = Label.wfTaskDependencyLkpId;
            //ApexPages.currentPage().getParameters().put('CF00Ng00000010Dzb',tsk.name);
            ApexPages.currentPage().getParameters().put(TaskDependencyLkp, tsk.Id);
            wfNewTaskDependencyClass newTaskDependent = new wfNewTaskDependencyClass(con);
            wfNewTaskDependencyClass newTaskDependent2 = new wfNewTaskDependencyClass(tsk.Id);
          
            newTaskDependent.taskDepend.name = 'task Dependent';
            newTaskDependent.taskDepend.project_name__c = prjct.id;
            newTaskDependent.taskDepend.Parent_Task__c = tsk.Id;
            newTaskDependent.taskDepend.Task__c = tsk2.Id; 
            newTaskDependent.taskSave();
        
            newTaskDependent.backToTask();
         //  adhoctask.saveAdhocTask();
         
       }  
    public static testmethod void wfNewTaskDependencyClass_Test3(){
        
        Project__c prjct = createProject();
        Phase__c phase = new phase__c( name = 'test phase' , project__c = prjct.id);
        insert phase;
        
        task__c tsk = new task__c();
        tsk.name = 'Test Task';
        tsk.Group_Name__c = 'Branch manager';
        tsk.phase__c = phase.id;
        tsk.project_Name__c = prjct.id;
        insert tsk;
        
        task__c tsk2 = new task__c();
        tsk2.name = 'Test Task';
        tsk2.Group_Name__c = 'Branch manager';
        tsk2.phase__c = phase.id;
        tsk2.project_Name__c = prjct.id;
        insert tsk2;
        
        task_dependency__c tdpncy = new task_dependency__c(); 
        ApexPages.StandardController con = new ApexPages.standardController(tdpncy);
        
        String TaskDependencyLkp = Label.wfTaskDependencyLkpId;
        //ApexPages.currentPage().getParameters().put('CF00Ng00000010Dzb',tsk.name);
        ApexPages.currentPage().getParameters().put(TaskDependencyLkp, tsk.Id);
        wfNewTaskDependencyClass newTaskDependent = new wfNewTaskDependencyClass(con);
        wfNewTaskDependencyClass newTaskDependent2 = new wfNewTaskDependencyClass(tsk.Id);
        
        newTaskDependent.taskDepend.name = 'task Dependent';
        newTaskDependent.taskDepend.project_name__c = prjct.id;
        newTaskDependent.taskDepend.Parent_Task__c = tsk.Id;
        //newTaskDependent5.taskDepend.Task__c = null; 
        newTaskDependent.taskSave();
        
        newTaskDependent.backToTask();
        //  adhoctask.saveAdhocTask();
   
    } 

}