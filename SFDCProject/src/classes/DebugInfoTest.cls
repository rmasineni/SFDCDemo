@IsTest
public class DebugInfoTest {
	
    testmethod public static void testDebugInfo() {
       	Test.setCurrentPage(new PageReference('/apex/Test?id=' + UserInfo.getUserId()));
        DebugInfoController controller = new DebugInfoController();
		System.assertNotEquals(null, controller.record);

        Test.setCurrentPage(new PageReference('/apex/Test'));
        controller = new DebugInfoController();
		System.assertEquals(null, controller.record);
    }
    
    testmethod public static void testIncrease() {
        DebugInfoController.increase();
    }
}