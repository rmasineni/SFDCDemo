@istest(seeAllData=true)
public with sharing class ScheduleBatchApexMonitorAccreditatiTest {
	static testmethod void ScheduleBatchApexMonitorAccreditatiTest(){	 		
            test.starttest();
        	ScheduleBatchApexMonitorAccreditation sch = new ScheduleBatchApexMonitorAccreditation ();   
         	String chron = '0 0 23 * * ?';        
         	system.schedule('Test Sched', chron, sch);
         	test.stopTest();
	}
}