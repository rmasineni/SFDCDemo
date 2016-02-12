@IsTest
public class StopWatchTest {
	static BaseClass utils = new BaseClass();
    
    testmethod public static void testStopWatch() {
        StopWatch sw = new StopWatch();
		
        utils.sleep(1000);
        
        Integer elapsedTime = sw.elapsedTime();
        Integer subElapsedTime = sw.subElapsedTime();
        
        System.assert(elapsedTime > 0);
        
        //Since we fetched sub-elapsed time after elapsed time
        System.assert(subElapsedTime >= elapsedTime); 
        
        sw.reset();

        Integer elapsedTime2 = sw.elapsedTime();
        Integer subElapsedTime2 = sw.subElapsedTime();
        
        //Since we didn't put any delay after reset before getting the elapsed time
        System.assert(elapsedTime > elapsedTime2);
		System.assert(elapsedTime2 <= subElapsedTime2);

		sw.markSubElapsedTime();
		sw.markSubElapsedTime();

		System.assertEquals(2, sw.timeEntries.size());        
    }
}