@isTest(seealldata=true)
public class Test_EmployeeRole {

  public static testmethod void employeeReportLevel(){
  
 //List<user> userList = [Select Id, Manager.Id, Name, Email, Manager.Name, profile.UserLicense.name from User where Manager.Id != null and contactId = null and isactive=true limit 10];
  
  EmployeeRoleReporting1 err = new EmployeeRoleReporting1();
  err.buildOrgChart();
  
  }

}