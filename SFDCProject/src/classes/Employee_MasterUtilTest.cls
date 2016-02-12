@isTest
public class Employee_MasterUtilTest
{
   //settingup the data to test Employee_MasterUtil functinality
    public static void setupData()
    {
        Employee_Master__c Em = new Employee_Master__c();
        em.EMAIL_ADDRESS__c = 'amen.ra@sunrunhome.com';
        em.Deactivate__c = 'TRUE';
        em.Termination_Status__c = 'test';
        insert em;
    }

    public static testMethod void testEmpMasterController() {
        setupData();
        test.startTest();
        // Instantiate a new controller with all parameters in the page
        Employee_MasterUtil Emputil = new Employee_MasterUtil();
        Emputil.Beginning();
        Emputil.Previous();
        Emputil.Next();
        Emputil.End();
        Emputil.getthousandBlocks();
        Emputil.getDisablePrevious();
        Emputil.getDisableNext();
        Emputil.getTotal_size();
        Emputil.getPageNumber();
        Emputil.getTotalPages();
        Emputil.deactivateUser();
        Emputil.truncateAllData();
        test.stopTest();
    
    }
}