@istest
public with sharing class ScheduleBatchApexWarningEmailTest {
	static testmethod void ScheduleBatchApexMonitorAccreditatiTest(){	 		
            test.starttest();
        	ScheduleBatchApexWaringEmail sch = new ScheduleBatchApexWaringEmail();   
         	String chron = '0 0 23 * * ?';        
         	system.schedule('Test Sched', chron, sch);
         	test.stopTest();
	}
}