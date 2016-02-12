@ isTest (seeAllData = true)
public class testWfTaskSearch {
  
    public static testmethod void unitTestOne(){
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
                
             project__c proj = new project__c ( name = 'test project', Account__c= a.Id , Opportunity__c= oppty.id, Proposal__c = proposal.id, service_contract__c = scAssetRec.id); 
             
           insert proj;
        
        
        Phase__c phase = new Phase__c(name='testPhase', Project__c=proj.Id);
        insert phase;
        
           task__c tasklocal = new task__c();
           tasklocal.name = 'testTask';
           tasklocal.Group_Name__c = 'Branch manager';
           tasklocal.phase__c = phase.id;
           tasklocal.project_Name__c = proj.id;
           insert tasklocal;
        
        wfTaskSearchNew tsksearch  = new wfTaskSearchNew();
        Test.startTest();
        PageReference pageRef = Page.wfTaskSearch;
        Test.setCurrentPage(pageRef);
        
        tsksearch.getViews();
        tsksearch.getSearchBy();
        //tsksearch.getTasksForSelectedView();
        
       // tsksearch.taskListdisp[0].taskObj.name =   tw = new tsksearch.tasks();
      //  System.assertEquals(tw.checked,false);

       // tsksearch.tasks cw2 = new tsksearch.tasks(new task__c(name='Tast Task'), false);
        //System.assertEquals(tsksearch.taskListdisp.isEmpty(),false);
        tsksearch.doSearch();
        tsksearch.userActions();
        tsksearch.viewName = 'AllTasks';
         if(tsksearch.taskListdisp.size() >= 2  ) {
        tsksearch.taskListdisp[0].taskObj.Task_Owner__c = null;
        tsksearch.taskListdisp[0].checked = true;
        tsksearch.taskListdisp[1].checked = true;
        tsksearch.DoSave();
        tsksearch.taskListdisp[0].taskObj.Task_Owner__c = pu.id;
        tsksearch.DoSave();
        tsksearch.taskListdisp[0].taskObj.Task_Owner__c = null;
        tsksearch.DoSave();
        //tsksearch.clonedTask = tasklocal ;
        tsksearch.getloadtable();
          
          wfTaskSearchNew.wrapper testTable3 = new wfTaskSearchNew.wrapper();
          testTable3.selectedValue ='InstallBranch';
          testTable3.searchText = 'test';
          tsksearch.tableList.add(testTable3);
          wfTaskSearchNew.wrapper testTable4 = new wfTaskSearchNew.wrapper();
          testTable4.selectedValue ='Phase';
          testTable4.searchText = 'test';
          tsksearch.tableList.add(testTable4);
          wfTaskSearchNew.wrapper testTable5 = new wfTaskSearchNew.wrapper();
          testTable5.selectedValue ='Group';
          testTable5.searchText = 'Add Values';
           tsksearch.tableList.add(testTable5);
           wfTaskSearchNew.wrapper testTable6 = new wfTaskSearchNew.wrapper();
          testTable6.selectedValue ='CustomerName';
          testTable6.searchText = 'test';
           tsksearch.tableList.add(testTable6);
         
           
        tsksearch.DoAdd();
        tsksearch.removeRow();
        tsksearch.DoAdd();
        tsksearch.DoAdd();
        tsksearch.DoAdd();
        tsksearch.DoAdd();
        tsksearch.DoAdd();
        
        tsksearch.getMytableRecords();
        
        
       
      
        //tsksearch.saveClone();
        
       
        tsksearch.first();
        tsksearch.Next();
        tsksearch.previous();
        tsksearch.last();
        tsksearch.getHasNext();
        tsksearch.getHasPrevious();
        tsksearch.getTotal_size();
        tsksearch.getPageNumber();
        tsksearch.getTotalPages();
        tsksearch.getTasks();
        }
        Test.StopTest();

    }
    
    public static testmethod void unitTestTwo(){
        Profile p = [select id from profile where Name ='System Administrator' limit 1];   
        User pu = new User(profileId = p.id, username ='testemail', email ='one@email.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US',  languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',  alias='cspu', lastname='lastname', firstname = 'firstname', title = 'developer');
        Account a = new Account (Name ='Test12345');
        try{
          insert a ;
        }
        catch(exception e){}
        
        Project__c proj = new Project__c(name='testProp');
        insert proj;
        Phase__c phase = new Phase__c(name='testPhase', Project__c=proj.Id);
        insert phase;
        Task__c tasklocal = new Task__c(name='testTask', Project_Name__c =proj.id, Phase__c = phase.Id);
        insert tasklocal;
        wfTaskSearchNew tsksearch  = new wfTaskSearchNew();
        Test.startTest();
        PageReference pageRef = Page.wfTaskSearch;
        Test.setCurrentPage(pageRef);
        tsksearch.errorMessage ='test eror';
        tsksearch.noOfRecords =20;
        tsksearch.size =10;
        tsksearch.getViews();
        tsksearch.getSearchBy();
        //tsksearch.getTasksForSelectedView();
        
       // tsksearch.taskListdisp[0].taskObj.name =   tw = new tsksearch.tasks();
      //  System.assertEquals(tw.checked,false);

       // tsksearch.tasks cw2 = new tsksearch.tasks(new task__c(name='Tast Task'), false);
        //System.assertEquals(tsksearch.taskListdisp.isEmpty(),false);
        tsksearch.getloadtable();
        tsksearch.DoAdd();
          wfTaskSearchNew.wrapper testTable27 = new wfTaskSearchNew.wrapper();
          testTable27.selectedValue ='InstallPartner';
          testTable27.searchText = 'test';
          tsksearch.tableList.add(testTable27);
        tsksearch.DoAdd();
          wfTaskSearchNew.wrapper testTable17 = new wfTaskSearchNew.wrapper();
          testTable17.selectedValue ='InstallPartner';
          testTable17.searchText = 'test';
          tsksearch.tableList.add(testTable17);
        tsksearch.DoAdd();
        tsksearch.DoAdd();
        tsksearch.DoAdd();
        tsksearch.DoAdd();
        
          wfTaskSearchNew.wrapper testTable7 = new wfTaskSearchNew.wrapper();
          testTable7.selectedValue ='InstallPartner';
          testTable7.searchText = 'test';
           //tsksearch.tableList.add(testTable7); 
         /*  wfTaskSearchNew.wrapper testTable8 = new wfTaskSearchNew.wrapper();
          testTable8.selectedValue ='TaskOwner';
          testTable8.searchText = '005600000034S8I';
           tsksearch.tableList.add(testTable8); */
           wfTaskSearchNew.wrapper testTable1 = new wfTaskSearchNew.wrapper();
          testTable1.selectedValue ='Task';
          testTable1.searchText = 'test5';
          tsksearch.tableList.add(testTable1);
          wfTaskSearchNew.wrapper testTable2 = new wfTaskSearchNew.wrapper();
          testTable2.selectedValue ='Project';
          testTable2.searchText = '1222';
          tsksearch.tableList.add(testTable2);
          wfTaskSearchNew.wrapper testTable3 = new wfTaskSearchNew.wrapper();
          testTable3.selectedValue ='InstallBranch';
          testTable3.searchText = 'test';
          tsksearch.tableList.add(testTable3);
          wfTaskSearchNew.wrapper testTable4 = new wfTaskSearchNew.wrapper();
          testTable4.selectedValue ='Phase';
          testTable4.searchText = 'test';
          tsksearch.tableList.add(testTable4);
          wfTaskSearchNew.wrapper testTable5 = new wfTaskSearchNew.wrapper();
          testTable5.selectedValue ='Group';
          testTable5.searchText = 'Add Values';
           tsksearch.tableList.add(testTable5);
           wfTaskSearchNew.wrapper testTable6 = new wfTaskSearchNew.wrapper();
          testTable6.selectedValue ='CustomerName';
          testTable6.searchText = 'test';
           tsksearch.tableList.add(testTable6);
           WfTaskSearchNew.wrapper testTable9 = new wfTaskSearchNew.wrapper();
          testTable9.selectedValue ='SalesPartner';
          testTable9.searchText = 'test';
           tsksearch.tableList.add(testTable9); 
           wfTaskSearchNew.wrapper testTable10 = new wfTaskSearchNew.wrapper();
          testTable10.selectedValue ='SlaStatus';
          testTable10.searchText = 'Missed SLA';
           tsksearch.tableList.add(testTable10);
           wfTaskSearchNew.wrapper testTable11 = new wfTaskSearchNew.wrapper();
          testTable11.selectedValue ='TaskStatus';
          testTable11.searchText = 'Complete';
           tsksearch.tableList.add(testTable11); 
        tsksearch.viewName = 'AllTasks';
         if(tsksearch.taskListdisp.size() > 0  ) {
        tsksearch.taskListdisp[0].taskObj.Task_Owner__c = null;
        tsksearch.DoSave();
        tsksearch.taskListdisp[0].taskObj.Task_Owner__c = pu.id;
        tsksearch.DoSave();
        tsksearch.taskListdisp[0].taskObj.Task_Owner__c = null;
        tsksearch.DoSave();
        }
        //tsksearch.clonedTask = tasklocal ;
        tsksearch.getMytableRecords();
        tsksearch.doSearch();
        
        tsksearch.viewName = 'myOpenTasks';
        //tsksearch.doSearch();
        tsksearch.userActions();
        tsksearch.viewName = 'myGroupTasks';
        //tsksearch.doSearch();
        tsksearch.userActions();
        tsksearch.viewName = '';
        tsksearch.userActions(); 
        //tsksearch.doSearch();
       
        tsksearch.first();
        tsksearch.Next();
        tsksearch.previous();
        tsksearch.last();
        tsksearch.getHasNext();
        tsksearch.getHasPrevious();
        tsksearch.getTotal_size();
        tsksearch.getPageNumber();
        tsksearch.getTotalPages();
        tsksearch.getTasks();
        
        Test.StopTest();

    }
  
  public static testmethod void unitTestThird(){
        Profile p = [select id from profile where Name ='System Administrator' limit 1];   
        User pu = new User(profileId = p.id, username ='testemail', email ='one@email.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US',  languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',  alias='cspu', lastname='lastname', firstname = 'firstname', title = 'developer');
        Account a = new Account (Name ='Test12345');
        try{
          insert a ;
        }
        catch(exception e){}
        Project__c proj = new Project__c(name='testProp');
        insert proj;
        Phase__c phase = new Phase__c(name='testPhase', Project__c=proj.Id);
        insert phase;
        Task__c tasklocal = new Task__c(name='testTask', Project_Name__c =proj.id, Phase__c = phase.Id);
        insert tasklocal;
        wfTaskSearchNew tsksearch  = new wfTaskSearchNew();
        Test.startTest();
        PageReference pageRef = Page.wfTaskSearch;
        Test.setCurrentPage(pageRef);
        
        tsksearch.getViews();
        tsksearch.getSearchBy();
        
       // tsksearch.tasks cw2 = new tsksearch.tasks(new task__c(name='Tast Task'), false);
        //System.assertEquals(tsksearch.taskListdisp.isEmpty(),false);
        tsksearch.doSearch();
        tsksearch.userActions();
        tsksearch.viewName = 'AllTasks';
         if(tsksearch.taskListdisp.size() >= 3  ) {
        tsksearch.taskListdisp[0].taskObj.Task_Owner__c = null;
        tsksearch.taskListdisp[0].checked = true;
        tsksearch.taskListdisp[1].checked = true;
        tsksearch.taskListdisp[2].checked = true;
        tsksearch.DoSave();
        tsksearch.taskListdisp[0].taskObj.Task_Owner__c = pu.id;
        tsksearch.DoSave();
        tsksearch.taskListdisp[0].taskObj.Task_Owner__c = null;
        tsksearch.DoSave();
        //tsksearch.clonedTask = tasklocal ;
        tsksearch.getloadtable();
      }
       // tsksearch.AssignTasks();
        //tsksearch.cloneTask();
        test.stopTest();
        
  }
    
    
}