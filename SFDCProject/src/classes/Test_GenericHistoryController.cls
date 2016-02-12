@isTest (SeeAllData=true)
public class Test_GenericHistoryController {

  static testMethod void myTestGenericHistoryComponentController() {
         
        //create controller
        GenericHistoryComponentController controller = new GenericHistoryComponentController();
        //null myObject
        system.assert(controller.getObjectHistory().size() == 0);

        //Account allows for history in related lists in visualforce, this is simply a standard object being used to get code coverage so you can use the component for other custom and standard objects.
        system.assert([select Accountid from accounthistory where isdeleted=false limit 1].size() == 1); //limit in case of 50,000 record governor limit
        string accid = [select Accountid from accounthistory where isdeleted=false limit 1].accountid;
        
        //Set myObject
        controller.myObject = [select id from Account where id=:accid];             
        system.assert(controller.getObjectHistory().size() > 0);        
  }

}