public with sharing class wfTaskSearchNew
 {
       
    public set<string> crrntUserGrpList{get;set;}
    public  set<string> chngUserGrpList{get;set;} 
    public String errorMessage{get;set;}
    public task__c taskObj;
    public Integer noOfRecords{get; set;}
    public Integer size{get;set;}
    public String urlPrefix {get;set;}
    public String viewName{get;set;}
    public String searchValue{get;set;}
   public String searchValue2{get;set;}
    public boolean displaytaskName{get;set;}
    public String userName;
    public String QueryString;
    public Set<String> taskStages;
    Set<String> taskStagesForSearch;
    public String QueryStringOffset;
    public List<task__c> taskListnew {get;set;}
    public List<tasks> taskListdisp {get;set;}
    private List<tasks> taskList {get;set;}
    private String tasksIdLike = '%%';
    private String projectLike = '%%';
     private String projectLike2 = '%%';
    private String addrLike = '%%';
    private String brnchLike = '%%';
    private String phaseLike= '%%';  
    private String groupLike = '%%';
    private String  customerNameLike = '%%';
    private String  installpartnerLike = '%%';
    private String  ownerLike = '%%';
     private String salesPartnerLike = '%%';
     private String slaStatusLike = '%%';
     private String openDateLike = '';
     private datetime taskOpenDate = datetime.now();
     private String taskStatusLike = '%%';
    public integer numOfRows = 2;
    set<string> gNames = new set<string>();
    set<string> pStatus = new set<string>();
   public boolean checkUserGroup{get;set;}
     
    set<string>  bNames =new set<string>();
    public boolean selected{get; set;}
    public list<task__c>selectedtask{get; set;}
    public boolean IsEditMode {get;set;}
    public boolean editModeSec{get;set;}
    private map<Id,Id> inLineUpdateList = new map<Id,Id>();
    public date myDate = date.today();
    
    public  Integer total_size = 2000;
    private Integer list_size = 20; //Number of rows per page
    public Integer counter = 0; //Offset counter
    public String searchColumnName{get;set;}
    public String searchColumnName2{get;set;}
     public list<String> selectColNames{get; set;}
     public list<String> searchVal{get;set;}
     public list<wrapper> tableList {get; set;}
     
     private Integer AddedRowCount;
     private Integer RemoveRowCount;
     
     public wfTaskSearchNew () { 
        viewName ='myOpenTasks';
        userActions();
        AddedRowCount = 0;
         RemoveRowCount = 1;
         userActions();
       }
   
    public list<Wrapper> getloadtable(){
            if (tableList == null) {
                AddedRowCount = 1;
                tableList = new list<wrapper>();
                wrapper wrap = new wrapper();
                wrap.AddedRowNumber = String.valueOf(AddedRowCount);
                tableList.add(wrap);       
            }
            return tableList;
        
    } 
    
  /*  public task__c clonedTask {
    get{
    return clonedTask; 
    } set;} //= new task__c(); */
     
     
   // public task__c originalTask {get; set;}
    public task__c newTask {get; set;}
    // if returns false, means duplicate values found in selections
    public boolean selectionCheck(){
        boolean bool = false;
        set<string> dupCheck = new set<string>();
         for(wrapper wr : tableList){
            if(dupCheck.add(wr.selectedValue)){
                bool = false;
            }
            else
                bool = true;  
         }
         system.debug('bool::'+bool);
         return bool; 
    }
    
    
    public PageReference DoAdd() {
        PageReference pgref;
        wrapper wrap = new wrapper();
        if(AddedRowCount == 5){
            String errorMessage = 'Maximum 5 selections allowed';
            Exception expObj = new BaseException(errorMessage);
            expObj.setMessage(errorMessage);
            ApexPages.addMessages(expObj);
            return null;    
        }
        else{
            AddedRowCount += 1;
            Wrap.AddedRowNumber = String.valueOf(AddedRowCount);
            if(tableList.size() > 0  )
            tableList.add(wrap);
            system.debug('tableList::'+tableList);
            system.debug('>> AddedRowCount'+AddedRowCount);
            RemoveRowCount = AddedRowCount;
            
        }
       return null; 
        
    }
     
     public PageReference removeRow() {
        PageReference pgref;
      
        if(tableList.size() == 1){
            String errorMessage = 'Cannot remove this row ';
            Exception expObj = new BaseException(errorMessage);
            expObj.setMessage(errorMessage);
            ApexPages.addMessages(expObj);
            return null;    
        }
        else{
            AddedRowCount -= AddedRowCount;
            tableList.remove(tableList.size() - 1);
            system.debug('tableList'+tableList);
        }
       return null; 
        
    }
    
    public class Wrapper { 
        public string selectedValue {get;set;}
        public string searchText {get;set;}
        public String AddedRowNumber {get; set;}
        public Wrapper() {
        }
    }
    
      public class BaseException extends Exception {}
      public PageReference doSearch() 
        {
        try{

                
                if(selectionCheck()){
                    String errorMessage = 'Please select different values in drop downs';
                    Exception expObj = new BaseException(errorMessage);
                    expObj.setMessage(errorMessage);
                    ApexPages.addMessages(expObj);
                    return null;        
                }
            userActions();    
        }catch(Exception exceptionObj){
            ApexPages.addMessages(exceptionObj);    
        }
        return null;
    }
    
      public list<integer> getMytableRecords(){ 
          numOfRows = 2;
        list<integer> intList = new list<integer>();
        for(integer j=0; j<=numOfRows-1; j++){
            intList.add(j);
        }
      //  initialize();
        return intList;    
    } 
    
    public ApexPages.StandardSetController con {
        get {
            
            if(con == null){
                String userId = UserInfo.getUserId();
                String userIdTemp = userId.substring(0, 15);                    
                if(viewName == '' || viewName == null){
                    viewName = 'myOpenTasks';
                    displaytaskName = true;
                    system.debug('printing con'+con);
                }
                //string queryString = 'SELECT Name, Id, Phase__c, Task_Owner__c, Related_Task__c,Phase__r.Project__r.name,Phase__r.Project__r.id, Status__c, Group_Name__c FROM Task__c order by Name';
                con = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                size = list_size;
                con.setPageSize(size);
                noOfRecords = con.getResultSize();
    
                
            }
            
            return con;
        }
        set;
    }       

    public class tasks{
        public Boolean checked{ get; set; }
        public task__c taskObj{get;set;} 
        public Boolean IsEditMode {get; set;}
        public String AddedRowNumber {get; set;}
        public tasks(){}
        public tasks(task__c tsk, Boolean IsEditMode){
            taskObj = tsk;
            checked = false;
            this.IsEditMode = IsEditMode;
        }
          
   
          
    }
      /*private ApexPages.StandardSetController createSQOLConnection(){
        ApexPages.StandardSetController tempConnection;
        
        String soqlQuery;
      
        
        if(viewName == '' || viewName == null){
            viewName = 'myOpenTasks';
            displaytaskName = true;
        }
        
        String userName = UserInfo.getName();
        soqlQuery = getSelectionQuery();
        
        Set<String> taskStages = initializetaskStages();
        System.debug('soqlQuery: ' + soqlQuery);
        tempConnection = new ApexPages.StandardSetController(Database.getQueryLocator(soqlQuery));
        return tempConnection;          
    } */
    
     public List<tasks> getTasks(){
        taskList = new List<tasks>();
        if(!taskListnew.isEmpty()){
            List<task__c> temptasks = taskListnew;
            if(temptasks == null)
                temptasks = new List<task__c>();
            taskList =  populateTaskList(temptasks); 
          
        }
        return taskList;
    }
    
    private List<tasks> populateTaskList(List<Task__c> taskList){
        List<tasks> temptaskList = new List<tasks>();
        tasks temptasks = null;
        for(task__c taskObj : taskList){
            temptasks = new tasks();
            temptasks.taskObj  = taskObj;
             temptasks.IsEditMode = true;
            temptaskList.add(temptasks);
        }
        return temptaskList;
    }

     
    public List<SelectOption> getViews() {
        List<SelectOption> Views = new List<SelectOption>();

        
        Views.add(new SelectOption('myOpenTasks', 'My Open Tasks'));
        //Views.add(new SelectOption('myChange', 'My Change Orders'));      
        Views.add(new SelectOption('myGroupTasks','My Group Tasks'));
        Views.add(new SelectOption('AllTasks', 'All Tasks'));
   
        return Views;
    } 
   
   //Following is to get the selected views
    public Pagereference userActions(){
        System.debug('Entering function userActions ViewName Sample:  ' + viewName);
        Pagereference pageRef = null;
       // searchValue = '';
        if(viewName == null || viewName == ''){
            return null;
        }else{
            pageRef = getTasksForSelectedView();
            return pageRef;         
            }
        }
        
  //Following is to get the list of tasks for the selected views
    public PageReference getTasksForSelectedView() {
        //Reset-initialize counters
        counter =0;  //Reset offset counter
        list_size =20; //Reset Number of rows per page
        total_size = 2000; //Reset Total number of record to be displayed


        userName = UserInfo.getName();
        QueryString = getSelectionQuery();
        taskStages = initializetaskStages();
        
        system.debug('Entering function getTasksForSelectedView:  '+QueryString);
        
        String[] squery1 = QueryString.split('from');
        String QueryStringcount = 'Select count() from ' + squery1[1];
        String[] squery2 = QueryStringcount.split('ORDER BY');
        QueryStringcount = squery2[0] + ' LIMIT 2000';
        system.debug('Count QueryString  '+QueryStringcount);
        total_size = Database.countQuery(QueryStringcount);            
        MainFunction(); 
        return null;
    }
        
          //Following is to build the Searchby options picklist
    public List<SelectOption> getSearchBy() {
        List<SelectOption> searchBy = new List<SelectOption>();
        searchBy.add(new SelectOption('CustomerName', 'Customer Full Name'));
        searchBy.add(new SelectOption('Group', 'Group'));
        searchBy.add(new SelectOption('InstallBranch', 'Install Branch'));
        searchBy.add(new SelectOption('InstallPartner', 'Install Partner'));
        searchBy.add(new SelectOption('TaskOwner', 'Owner '));
        searchBy.add(new SelectOption('Project', 'Project Name'));
        searchBy.add(new SelectOption('SalesParnter', 'Sales partner '));
        searchBy.add(new SelectOption('SlaStatus', 'SLA status'));
        searchBy.add(new SelectOption('Task','Task Name')); 
       // searchBy.add(new SelectOption('OpenDate', 'Task Open Date'));
        searchBy.add(new SelectOption('TaskStatus', 'Task status'));
        
     //   searchBy.add(new SelectOption('Phase','Phase'));     
        return searchBy;
    }
    
   
    
    public Set<String> initializetaskStages(){
        
        if(taskStagesForSearch == null || taskStagesForSearch.isEmpty()){
            taskStagesForSearch = new Set<String>();
            taskStagesForSearch.add('Blocked');
            taskStagesForSearch.add('Complete');
            taskStagesForSearch.add('Open');
            taskStagesForSearch.add('Wait');
            taskStagesForSearch.add('Inactive');
             taskStagesForSearch.add('Closed');
            
        }
        return taskStagesForSearch;
    } 
    
   /*  private String getDateFormat(String startDate) {
         String taskStartDate = startDate.substring(0,10);
         list<string> dateList = taskStartDate.split('/');
         string mnth = dateList[0];
         string dte = dateList[1];
         string year = dateList[2];
         string formattedDate = year + '-' + mnth + '-' + dte;
        
         Date convertFromDate;
         DateTime convertFromDateTime;
          if(taskStartDate != null) { 
            convertFromDate = Date.parse(taskStartDate);
            convertFromDateTime = DateTime.newInstanceGMT(convertFromDate , Time.newInstance(00, 01, 01, 01));
             System.debug('>>convertFromDateTime' + convertFromDateTime); 
        }
         return formattedDate;
     } */
    
    //Follwoing is to build the query dynamically to fetch records based on the selected view and entered search string
    private String getSelectionQuery(){
        tasksIdLike = '%%';
        projectLike = '%%';
        projectLike2 = '%%';
        phaseLike = '%%';
        addrLike = '%%';
        brnchLike = '%%';
        groupLike = '%%';
        //salesRepLike = '%%';
        customerNameLike = '%%';
        installpartnerLike = '%%';
        ownerLike = '%%';
        salesPartnerLike = '%%';
        slaStatusLike = '%%';
        openDateLike = '';
        taskStatusLike = '%%';
            
        String userId = UserInfo.getUserId();
        String userName = UserInfo.getName();
        String searchCondition = '';
        system.debug('wrapper::'+tablelist);
        if(tableList != null){
            for(wrapper wr: tablelist){
                system.debug('wr.selectedValue>>'+wr.selectedValue);
                if(string.isNotBlank(wr.selectedValue) && string.isNotBlank(wr.searchText)){
                    if(wr.selectedValue == 'Task'){
                        tasksIdLike = '\'%' + wr.searchText + '%\'';
                        searchCondition += ' AND Name like '+tasksIdLike;
                        continue;   
                    }
                    if(wr.selectedValue == 'Project'){
                        projectLike = '\'%' + wr.searchText + '%\'';
                        searchCondition += ' AND Phase__r.Project__r.name like '+projectLike;
                        continue;   
                    }
                    if(wr.selectedValue == 'InstallBranch'){
                        brnchLike = '\'%' + wr.searchText + '%\'';
                        searchCondition += ' AND Install_Branch__c like '+brnchLike;
                        continue;   
                    }
                    if(wr.selectedValue == 'Phase'){
                        phaseLike = '\'%' + wr.searchText + '%\'';
                        searchCondition += ' AND Phase__r.name like '+phaseLike;
                        continue;   
                    }
                    if(wr.selectedValue == 'Group'){
                        groupLike = '\'%' + wr.searchText + '%\'';
                        searchCondition += ' AND Group_Name__c like '+groupLike;
                        continue;   
                    }
                    if(wr.selectedValue == 'CustomerName'){
                        customerNameLike = '\'%' + wr.searchText + '%\'';
                        searchCondition += ' AND phase__r.project__r.Proposal__r.Homeowner_Name__c like '+customerNameLike;
                        continue;   
                    }
                    if(wr.selectedValue == 'InstallPartner'){
                        installPartnerLike = '\'%' + wr.searchText + '%\'';
                        searchCondition += ' AND Phase__r.Project__r.Install_Partner__c like '+installpartnerLike;
                        continue;   
                    }
                     if(wr.selectedValue == 'TaskOwner'){
                        ownerLike = '\'%' + wr.searchText + '%\'';
                        searchCondition += ' AND Task_Owner__r.name like '+ownerLike;
                        continue;   
                    }
                    if(wr.selectedValue == 'SalesParnter'){
                        salesPartnerLike = '\'%' + wr.searchText + '%\'';
                        searchCondition += ' AND Phase__r.Project__r.Sales_Partner__c like '+salesPartnerLike;
                        continue;   
                    }
                    if(wr.selectedValue == 'SlaStatus'){
                        slaStatusLike = '\'%' + wr.searchText + '%\'';
                        searchCondition += ' AND SLA_Status__c like '+slaStatusLike;
                        continue;   
                    }
                  /* if(wr.selectedValue == 'OpenDate'){
                      // String searchText = wr.searchText.substring(0,8)
                       openDateLike = '\'%' + getDateFormat(wr.searchText)  + '%\'';
                        system.debug('>>openDateLike' + openDateLike);
                        searchCondition +=  ' AND Task_Start_Date__c = :openDateLike ';
                        continue;
                        /*.openDateLike = '\''+  wr.searchText + '\'' ;
                        system.debug('>>openDateLike ' +openDateLike);
                        taskOpenDate = datetime.valueOf(openDateLike);
                        system.debug('>>taskOpenDate ' +taskOpenDate);
                        openDateLike = taskOpenDate.format('MM/DD/yyyy', 'UTC');
                       // system.debug('>>DateTime.parse(openDateLike) ' + DateTime.parse(openDateLike));
                        searchCondition +=  ' AND Task_Start_Date__c = :openDateLike ';
                        continue;   
                    }*/
                    if(wr.selectedValue == 'TaskStatus'){
                        taskStatusLike = '\'%' + wr.searchText + '%\'';
                        searchCondition += ' AND Status__c like '+taskStatusLike;
                        continue;   
                    }
                    
                }
            
            }//for loop ends here
        searchCondition += getSearchConditionByViewName(userId,userName);
        }
   
        else{
         
            searchCondition = getSearchConditionByViewName(userId,userName);
         } 
            
        pStatus = wfUtil.getActiveProjectStages();
             
        String soqlQuery = 'Select  Name, Id, Phase__c, Phase__r.Project__r.name,Phase__r.Project__r.Status__c , Task_Owner__c, Related_Task__c,Group_Name__c,Branch__c, Type__c, SLA_Status__c, Open_Date__c, Category__c, Task_Number__c,Start_Date__c,Project_Name__c, '; 
        soqlQuery += ' Phase__r.Project__r.Sales_Partner__c,Phase__r.Project__r.Install_Partner__c,Status__c, Phase__r.Project__r.CreatedDate, phase__r.project__r.Proposal__r.Homeowner_Name__c from task__c ';
        soqlQuery += ' where status__c in :taskStages';  
        
        soqlQuery += searchCondition;
         if (!pStatus.isEmpty() ) 
        soqlQuery += ' AND Phase__r.Project__r.Status__c in :pStatus';
        soqlQuery += ' ORDER BY Phase__r.Project__r.CreatedDate ASC, Status__c DESC ' ;
        system.debug('Searchcondition******' + searchCondition);
        system.debug('soqlQuery ******' + soqlQuery );
        return soqlQuery;
     }
    
    
     

     //Following is to build the Search condition based on the viwes selected
    private String getSearchConditionByViewName(String userId, String userName){
        String searchCondition = '';
	     displaytaskName = false;
        if(viewName == 'myOpenTasks'){
            displaytaskName = true;
            searchCondition += ' AND Status__c= \'Open\' ' ;
            searchCondition += ' AND (Task_Owner__c = \''+ userId +'\' '; 
            searchCondition +=  ') ' ;
            searchCondition += ' AND  Utility_Delay_Until__c <= today' ;
         	
                  
            system.debug('Searchcondition******' + searchCondition);
        }
        
        
        else if(viewName == 'AllTasks'){
        
            displaytaskName = true;
            
            //searchCondition += ' AND Original_task_ID__c = NULL ' ;
            searchCondition += searchCondition  ;
        }
        
        
        else if(viewName == 'myGroupTasks'){
        
       
        gNames = getGroupNames(userInfo.getUserId());
      //  bNames = getBranchNames(userInfo.getUserId());
            if (!gNames.isEmpty() ) {
             searchCondition += ' AND Group_Name__c in :gNames';  
             searchCondition += ' AND Status__c= \'Open\' ' ;
               //searchCondition +=  ') ' ;
             }
             else {
             searchCondition += '  AND (Group_Name__c = \''+ 'abcd'+'\' ';
             searchCondition +=  ') ' ;
             }
              system.debug('Searchcondition******' + searchCondition);
        }
        
        else{     
                    Date requestedDate = Date.today().addDays(-7);
                    searchCondition +=   ' AND CreatedDate = LAST_N_DAYS:7 ';
                }
 
        return searchCondition;
 
  }
     
    
    
    private set<string> getGroupNames( String uid){
    System.debug('>>>>>>>>>>>uId' + uid);
    set<string> groupNames = new set<string>();
    For(User_Group__c uGroup : [SELECT Group__c,Id,Name,User_Active__c,User__c FROM User_Group__c where User__c =: uid]){
        if(string.isNotBlank(uGroup.Group__c))
        groupNames.add(uGroup.Group__c);
        system.debug('>>>>>>>>>>>>>>>'+ groupNames);
         }
    return groupNames;
  }
    
    private void MainFunction(){
        QueryStringOffset = QueryString + ' LIMIT '+ list_size +' OFFSET '+ counter;
        System.debug('Offset Query is    '+QueryStringOffset);
            taskListnew = Database.query(QueryStringOffset);
           
            taskListdisp = getTasks();
            inLineUpdateList = getInlineList(taskListdisp);
            system.debug('inLineUpdateList list size   '+inLineUpdateList.size());
    
    }
    
    private map<Id,Id> getInlineList(list<tasks> tskList){
        map<Id,Id> taskList = new map<Id,Id>();
        if(tskList.size()>0){
            for(tasks tsk: tskList){
                taskList.put(tsk.taskObj.Id, tsk.taskObj.Task_Owner__c);        
            }
        }
        system.debug('@@@#####'+taskList);  
        return taskList;
    }
    
        
    public PageReference AssignTasks() {
    List <task__c> updateTask = new List<task__c> ();
        List<task__c> TasktoUpdate = new List<task__c>();
        System.Savepoint sp1 = Database.setSavepoint();
    System.Debug('>>>>>>>>>Selectedtask'+ taskListdisp.isEmpty() );
    for(tasks tc: taskListdisp){
        if (tc.checked){
            String userId = UserInfo.getUserId();
             tc.taskObj.Task_Owner__c = userId ;
             
             System.debug ('>>>>>>>>>>>>>UserId' + userId);
             updateTask.add(tc.taskObj);
           
            }         
              tc.checked = false;
           
        } 
        try {
        if(updateTask.size() >0){
          update updateTask; 
        }
        
        }catch (System.DmlException e) {
            system.debug('error: ' + e);
            Database.rollback(sp1);
            for (Integer i=0; i < e.getNumDml(); i++) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getDmlMessage(i)));
            }
            return null;
        }catch(Exception expObj){
            ApexPages.addMessages(expObj);   
             return null;
        }    
    
        
    
      return null;
    }
    
         
    /***
    * DoSave - Save edited and added records. 
    **/
    public class MyException extends Exception{}
    
    
    public pageReference DoSave() {
        IsEditMode = false;
        list<task__c> UpdateList = new list<task__c>();
        list<task__c> InsertList = new list<task__c>();
        System.debug('<<<>>>>>>> UpdateList'+inLineUpdateList);
        System.Savepoint sp1 = Database.setSavepoint();
        try {
        for (tasks t :taskListdisp) {
            if (t.taskobj.Id != null && inLineUpdateList.size()>0) {
                System.debug('>>>>>>> inLineUpdateList '+inLineUpdateList );
                
                if(inLineUpdateList.containsKey(t.taskobj.Id)  && t.taskObj.Task_Owner__c != inLineUpdateList.get(t.taskObj.Id))
                     {
                         checkUserGroup = false;
                         if(t.taskObj.Group_Name__c != Null) {
                              string grp = t.taskObj.Group_Name__c;
                             System.debug('>> Task group Name' + grp);
                             chngUserGrpList = getGroupNames(t.taskObj.Task_Owner__c);
                             System.debug('>> chngUserGrpList.size()' + chngUserGrpList.size());
                             if (chngUserGrpList.size()>0)
                                 checkUserGroup =  chngUserGrpList.contains(grp);

                                if ( !checkUserGroup && t.taskObj.Task_Owner__c != null )     { 
                                 system.debug ('>>>>>>>>>Not a Valid User');
                                   errorMessage = 'Please select users belonging to the Task Group. Owner update not saved.';
                                    Exception expObj = new BaseException(errorMessage);
                                    expObj.setMessage(errorMessage);
                                    ApexPages.addMessages(expObj);
                                    return null; 
                                    
                                 } else if (t.taskobj.Status__c == wfUtil.COMPLETE ) {
                                    errorMessage = 'You may not update the owner for a Task in Complete status. Owner update not saved.';
                                    Exception expObj = new BaseException(errorMessage);
                                    expObj.setMessage(errorMessage);
                                    ApexPages.addMessages(expObj);
                                    return null; 
    
    
                                 } else{
                             
                                    System.debug('>>> Updating Owner....');
                                    UpdateList.add(t.taskobj);                         
                       }
                     }  
                   }
               }
        }

            system.debug('UpdateList: ' + UpdateList);
            system.debug('InsertList: ' + InsertList);
        // try{
            if (UpdateList.size() > 0) {
                update UpdateList;
                 
            }
            else if (InsertList.size() > 0) {
                insert InsertList;
                //return null;
            }
         } catch (System.DmlException e) {
            system.debug('error: ' + e);
            Database.rollback(sp1);
            for (Integer i=0; i < e.getNumDml(); i++) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getDmlMessage(i)));
            }
            return null;
        }catch(Exception expObj){
            ApexPages.addMessages(expObj);   
         
        }  

        return null;
    } 

    
    /*
    
    public PageReference cloneTask() {
       editModeSec = true;
       clonedTask = new task__c();
       originalTask = new task__c();
        integer i=0;
        System.Debug('>>>>>>>>>Selectedtask'+ taskListdisp.isEmpty() );
        try { 
        for(tasks tc: taskListdisp){
            if (tc.checked){
                i++;
                System.debug ('>>>>>>>>>>>>>UserId' + i);
                if(i>1){
                    String errorMessage ='Please select only one task';
                    Exception expObj = new BaseException(errorMessage);
                    expObj.setMessage(errorMessage);
                    ApexPages.addMessages(expObj);
                    
                    system.debug('>>> i>1 >>>>>>>');
                    break;
                    return null;
                }
                else{
                    originalTask = tc.taskObj;
                    system.debug('>>> i==1 >>>>>>>');
                    if(originalTask.id != null){
                        system.debug('>>>INSERT >>>>>>>');
                        originalTask = [SELECT Group_Name__c,Id,Name,Phase__r.name,Phase__r.Project__r.name, Task_Number__c, Related_Task__c,Task_Description__c,Task_Owner__c,Type__c,Status__c, SLA_Status__c, Open_Date__c, Category__c,Start_Date__c FROM Task__c where Id=:originalTask.id];
                        clonedTask = originalTask.clone(false);
                        clonedTask.Type__c = 'Adhoc';
                        //insert clonedTask;
                    }
                     
                    
                    
                    system.debug('InsertedTASK:: '+clonedTask);
                }
              }
            }
      
        }  catch (Exception e){}

            return page.TaskCloneForm;
        
    } */
    /*
     public PageReference newTask() {
       editModeSec = true;
       newTask = new task__c();
       newTask.Type__c = 'Adhoc';
       newTask.Category__c = 'Required';
       newTask.Start_Date__c = myDate;
        
       return page.createAdhocTask;
        
    }
    
 
      public PageReference backClone() {
      editModeSec = true;
      return page.TaskSearchOffset;
      
      }
    public void saveClone() {
                    editModeSec = false;
                    if(clonedTask != null){
                   // clonedTask.Type__c = 'Adhoc';
                    insert clonedTask;
                    String errorMessage ='Task Cloned Successfully';
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.Info, 'Success', errormessage);
                    ApexPages.addMessage(myMsg);
                    }
                    else if (newTask != null) {
                    insert newTask;
                    String errorMessage ='Task Cloned Successfully';
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.Info, 'Success', errormessage);
                    ApexPages.addMessage(myMsg);
                     }
    }
    
    public  void saveAdhocTask(){

       
       try{
       
       editModeSec = false;
        insert newTask;
        system.debug('Inserted Task:: '+newTask);
        String errorMessage ='Task Cloned Successfully';
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.Info, 'Success', errormessage);
        ApexPages.addMessage(myMsg);
        if(newTask.id != null)
        newTask = [select id, name, Type__c,Status__c,Phase__r.name,Group_Name__c,Task_Description__c,phase__r.Project__r.name,Task_Owner__c, Category__c,Open_Date__c,Start_Date__c from task__c where id =: newTask.Id];  
        }
      catch(Exception e){
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, e.getmessage() ));
            }

    }
    
    */

        
     
      public PageReference first() { //user clicked beginning
        counter = 0;
        MainFunction();
        return null;
    }   
    
    public PageReference previous() { //user clicked previous button
        counter -= list_size;
        if(counter >= 0){
            MainFunction();    
        }
        else{
            counter = 0;        
        }
        return null;
    }
    

    public PageReference Next() {
      counter += list_size;
       if (counter <= total_size){
         MainFunction();
         }
    else if (total_size > 2000){
       counter = 2000 - math.mod(2000, list_size);
       system.debug('');
    }
    return null ;
   }
    
    
    
    public PageReference last() { //user clicked end
        if (total_size <= 2000){
        counter = total_size - math.mod(total_size, list_size);
        }
        else if (total_size > 2000){
        counter = 1990;
  
        }
        MainFunction();
        return null;
    }
    
    public Boolean getHasPrevious() { 
        //this will disable the previous and beginning buttons
        if (counter > 0) return true; else return false;
    }
    
    public Boolean getHasNext() { //this will disable the next and end buttons
        if (counter + list_size <= total_size) return true; else return false;
    }
    
    public Integer getTotal_size() {
       return total_size;
    } 
    
   
    public Integer getPageNumber() {
        if (total_size > 0 ) {
            if(counter >= 1990){
                return (counter / list_size);
            } else{
              return ((counter / list_size) + 1);
                }
        } else {
            return 0;
        }
      
    }
    
    public Integer getTotalPages() {
        if (math.mod(total_size, list_size) > 0) {
            return total_size/list_size + 1;
        } else {
            return (total_size/list_size);
      }
    }  
  
}