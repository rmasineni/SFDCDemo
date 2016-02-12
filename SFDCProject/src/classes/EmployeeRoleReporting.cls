public with sharing class EmployeeRoleReporting {

Public List<user> userList1{set;get;}
Public List<List<user>> grandList{set;get;}
Public Map<Integer,List<user>> grandListMap{set;get;}
Public list<string> username{set;get;}
Public Id superMgerId;
public integer totalLicencesUsed{set;get;}
public integer sForceCount{set;get;}
public integer sForcePlatformCount{set;get;}
public Map<Integer,Integer> licenseMap1{set;get;}
public Map<Integer,Integer> licenseMap2{set;get;}
Public Map<Integer,Integer> summaryMap{set;get;}

public EmployeeRoleReporting(){

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
        licenseMap1=new Map<Integer,Integer>();
        licenseMap2=new Map<Integer,Integer>();
        summaryMap=new Map<Integer,Integer>();
        totalLicencesUsed=0;
        sForceCount=0;
        sForcePlatformCount=0;
        set<Id> viceIds = new Set<Id>();
        List<User> usrList = new List<User>();
          
        for(User us : [Select Id,name, Is_Vice_President__c from User where Is_Vice_President__c = true order by createddate asc]){
            viceIds.add(us.Id);
            username.add(us.name);            
        }
        
        allEmployees = new Map<Id, List<User>>();
        for(User userObj : [Select Id, Manager.Id, Name, Email, Manager.Name, profile.UserLicense.name from User where Manager.Id != null and contactId = null and isactive=true]){
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
          for(user u1 : userlist1){
            if(u1.profile.UserLicense.name == 'Salesforce'){
              sForceCount++;
            }
            else if(u1.profile.UserLicense.name == 'Salesforce Platform'){
              sForcePlatformCount++;
            }
          licenseMap1.put(incrementer,sForceCount);
          licenseMap2.put(incrementer,sForcePlatformCount);
          }
          sForceCount=0;
          sForcePlatformCount=0;
          summaryMap.put(incrementer,userList1.size());
          totalLicencesUsed+=userList1.size();
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