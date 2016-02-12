public with sharing class EmployeeRoleCustomSetting {

Public List<user> userList1{set;get;}
Public List<List<user>> grandList{set;get;}
Public Map<Integer,List<user>> grandListMap{set;get;}
Public list<string> username{set;get;}
Public Id superMgerId;
public Map<Integer,Integer> summaryMap{set;get;}

public EmployeeRoleCustomSetting(){

}
        
public String xlsHeader {
        get {
            String strHeader = '';
            strHeader += '<?xml version="1.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
}   
 
public Pagereference exportAll(){
    return new Pagereference('/apex/EmployeeRoleReportingExcel');
}
 
    Map<Id, List<User>> allEmployees = new Map<Id, List<User>>();
    Map<Id, List<User>> employeesByVP = new Map<Id, List<User>>();
    integer incrementer=0;
    
    public void buildOrgChart(){
        
        username = new list<string>();
        grandListMap=new Map<Integer,List<user>>();
        summaryMap=new Map<Integer,Integer>();
        set<Id> viceIds = new Set<Id>();
        List<User> usrList = new List<User>();
        Set<String> mgremailset = new Set<String>();
          
        for(Employee_Role__c er : Employee_Role__c.getAll().Values()){
            viceIds.add(er.Manager_Id__c);
            username.add(er.Name);
        }
        
        allEmployees = new Map<Id, List<User>>();
        for(User userObj : [Select Id, Manager.Id, Email, Name,profile.UserLicense.name from User where Manager.Id != null and contactId = null and isactive=true]){
            List<User> tempEmployees = allEmployees.containsKey(userObj.Manager.Id) ? 
                                            allEmployees.get(userObj.Manager.Id) : new List<User>();
            tempEmployees.add(userObj);
            allEmployees.put(userObj.Manager.Id, tempEmployees);
        }
        
        for(Id vpId : viceIds){
           sortEmployeesByVP(vpId,true);
        }
      
        for(id vpid1 : viceIds){
          userList1 = employeesByVP.get(vpid1);
          Set<User> tempSet=new Set<user>();
          tempset.addall(userList1);
          userList1=new List<user>();
          userList1.addall(tempset);
          grandListMap.put(incrementer,userList1);
          summaryMap.put(incrementer,userList1.size());
          incrementer++;
        }
    }
    
    private void sortEmployeesByVP(Id managerId,Boolean superManager){
        List<User> tempEmployees = new List<user>();
        tempEmployees = allEmployees.get(managerId);
        if(tempEmployees != null && !tempEmployees.isEmpty()){
            if(superManager){
            employeesByVP.put(managerId, tempEmployees);  
            superMgerId=managerId;
            }
            else{
            List<user> templist= new List<user>();
            templist=employeesByVP.get(superMgerId);            
            templist.addall(tempEmployees);
            employeesByVP.put(superMgerId,templist);
            }   
            for(Integer i=0;i<tempEmployees.size();i++){
                sortEmployeesByVP2(superMgerId,tempEmployees[i].Id,false);
            }
        }
    }
     private void sortEmployeesByVP2(Id superManagerId,Id managerId,Boolean superManager){
     List<User> tempEmployees = new List<user>();
        tempEmployees = allEmployees.get(managerId);
        if(tempEmployees != null && !tempEmployees.isEmpty()){
            
            List<user> templist= new List<user>();
            templist=employeesByVP.get(superManagerId);            
            templist.addall(tempEmployees);
            employeesByVP.put(superManagerId,templist);
            }   
     }

    
}