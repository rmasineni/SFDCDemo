@isTest(seeAllData=true)
public with sharing class ScheduleBatchApexCallCDYNETest {
static testmethod void ScheduleBatchApexCallCDYNETest(){	 		
            test.starttest();
        	ScheduleBatchApexCallCDYNE sch = new ScheduleBatchApexCallCDYNE ();   
         	String chron = '0 0 23 * * ?';        
         	system.schedule('Test Sched', chron, sch);
         	test.stopTest();
	}
}