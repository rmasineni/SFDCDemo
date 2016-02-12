@IsTest
public class SfTest {
    
    testmethod public static void test() {
        System.assertNotEquals(null, Sf.settingsService);
        System.assertNotEquals(null, Sf.addressService);
        System.assertNotEquals(null, Sf.paymentService);
        System.assertNotEquals(null, Sf.paymentWsService);
        System.assertNotEquals(null, Sf.iknockLeadSyncService);
        System.assertNotEquals(null, Sf.googleCalendarService);
        System.assertNotEquals(null, Sf.auditService);
        System.assertNotEquals(null, Sf.awsSyncService);
        System.assertNotEquals(null, Sf.ambassadorSyncService);
        System.assertNotEquals(null, Sf.costcoSyncService);
        System.assertNotEquals(null, Sf.homeDepotSyncService);
        System.assertNotEquals(null, Sf.schedulerService);
        System.assertNotEquals(null, Sf.appLogger);
        System.assertNotEquals(null, Sf.nearbyCustomersViewerService);
        System.assertNotEquals(null, Sf.syncService);
        System.assertNotEquals(null, Sf.commonScheduler);
        System.assertNotEquals(null, Sf.coreLogicService);

        try {
            Sf.createInstance('NonExisting');
            System.assert(false, 'Expecting exception as we are trying to create instance of non-existing class');
        } catch (Exception e) {
            //expected
        }
    }
}