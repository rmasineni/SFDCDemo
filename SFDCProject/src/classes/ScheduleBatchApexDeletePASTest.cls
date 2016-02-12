@istest
public with sharing class ScheduleBatchApexDeletePASTest {
	static testmethod void ScheduleBatchApexDeletePASTest(){	 		
            test.starttest();
        	ScheduleBatchApexDeletePAS sch = new ScheduleBatchApexDeletePAS ();   
         	String chron = '0 0 23 * * ?';        
         	system.schedule('Test Sched', chron, sch);
         	test.stopTest();
	}
}