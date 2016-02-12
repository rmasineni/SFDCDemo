public class OrgChartImpl {
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
public Integer vpLevel2;
    Map<Id, List<User>> allEmployees = new Map<Id, List<User>>();
    Map<Id, List<User>> employeesByVP = new Map<Id, List<User>>();
    Integer counter = 0;
    integer incrementer=0;
public OrgChartImpl(){

}    
public String xlsHeader {
        get {
            String strHeader = '';
            strHeader += '<?xml version="1.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
}    
    
    public void sortEmployeesByVP(Id managerId){
        counter++;
        //System.debug('Entering: ' + counter);
        List<User> tempEmployees = allEmployees.get(managerId);
        if(tempEmployees != null && !tempEmployees.isEmpty()){
            if(counter == 6){
                //System.debug('tempEmployees: ' + tempEmployees);
            }
            employeesByVP.put(managerId, tempEmployees);
            for(User userObj : tempEmployees){
                sortEmployeesByVP(userObj.Id);
            }
        }
        counter --;
        //System.debug('Exiting: ' + counter);
    }
    
    public void buildOrgChart(){
        username = new list<string>();
        grandListMap=new Map<Integer,List<user>>();
        summaryMap=new Map<Integer,Integer>();
        licenseMap1=new Map<Integer,Integer>();
        licenseMap2=new Map<Integer,Integer>();
        totalLicencesUsed=0;
        sForceCount=0;
        sForcePlatformCount=0;
        set<Id> viceIds = new Set<Id>();
        Map<Id,Decimal> viceMap = new Map<Id,Decimal>();
        List<User> usrList = new List<User>();
          
        for(User us : [Select Id,name, Is_Vice_President__c,Employee_Report_Level__c from User where Is_Vice_President__c = true order by createddate asc ]){
            viceIds.add(us.Id);
            viceMap.put(us.Id,us.Employee_Report_Level__c);
            username.add(us.name);            
        }
        
        allEmployees = new Map<Id, List<User>>();
        for(User userObj : [Select Id, Manager.Id, Name, Email, Manager.Name, profile.UserLicense.name from User where Manager.Id != null and contactId = null and isactive=true]){
            List<User> tempEmployees = allEmployees.containsKey(userObj.Manager.Id) ? 
                                            allEmployees.get(userObj.Manager.Id) : new List<User>();
            tempEmployees.add(userObj);
            allEmployees.put(userObj.Manager.Id, tempEmployees);
        }
        System.debug('allEmployees: ' + allEmployees);
        System.debug('allEmployees.size(): ' + allEmployees.size());
        for(Id vpId : viceIds){
            employeesByVP = new Map<Id, List<User>>();
            counter = 0;
            sortEmployeesByVP(vpId);
            System.debug('List of employees for VP Id: '+ vpId);
            System.debug('Employee List: '+ employeesByVP);
        }
        system.debug('==>VP Empl'+employeesByVP.get('00560000001MtWGAA0').size());
    }
}