public class HomeDepotLeadScheduleBatch {
    
    public static void scheduleHomeDepotLeadBatch(){
        System.schedule('HDLeadSyncBatch1', '0 00 20 * * ?', new HomeDepotLeadSyncSchedule());
        System.schedule('HDLeadSyncBatch2', '0 30 20 * * ?', new HomeDepotLeadSyncSchedule());
        System.schedule('HDLeadSyncBatch3', '0 00 21 * * ?', new HomeDepotLeadSyncSchedule());
        System.schedule('HDLeadSyncBatch4', '0 30 21 * * ?', new HomeDepotLeadSyncSchedule());
        System.schedule('HDLeadSyncBatch5', '0 00 22 * * ?', new HomeDepotLeadSyncSchedule());
        System.schedule('HDLeadSyncBatch6', '0 30 22 * * ?', new HomeDepotLeadSyncSchedule());
        System.schedule('HDLeadSyncBatch7', '0 00 23 * * ?', new HomeDepotLeadSyncSchedule());
        System.schedule('HDLeadSyncBatch8', '0 30 23 * * ?', new HomeDepotLeadSyncSchedule());
        System.schedule('HDLeadSyncBatch9', '0 00 00 * * ?', new HomeDepotLeadSyncSchedule());
        System.schedule('HDLeadSyncBatch10', '0 30 00 * * ?', new HomeDepotLeadSyncSchedule());

    //    System.schedule('HDLeadLookupBatch', '0 00 12 * * ?', new HomeDepotLeadLookupSchedule());
    //    System.schedule('HDLeadErrorLookupBatch', '0 05 16 * * ?', new HomeDepotErrorLookupLeadSchedule());
    }
    
    public static void scheduleHomeDepotOpptyBatch(){
        System.schedule('HDOpptySyncBatch1', '0 00 01 * * ?', new HomeDepotOpptySyncSchedule());
        System.schedule('HDOpptySyncBatch2', '0 30 01 * * ?', new HomeDepotOpptySyncSchedule());
        System.schedule('HDOpptySyncBatch3', '0 00 02 * * ?', new HomeDepotOpptySyncSchedule());
        System.schedule('HDOpptySyncBatch4', '0 30 02 * * ?', new HomeDepotOpptySyncSchedule());
        System.schedule('HDOpptySyncBatch5', '0 00 03 * * ?', new HomeDepotOpptySyncSchedule());
        System.schedule('HDOpptySyncBatch6', '0 30 03 * * ?', new HomeDepotOpptySyncSchedule());
        System.schedule('HDOpptySyncBatch7', '0 00 04 * * ?', new HomeDepotOpptySyncSchedule());
        System.schedule('HDOpptySyncBatch8', '0 30 04 * * ?', new HomeDepotOpptySyncSchedule());
        System.schedule('HDOpptySyncBatch9', '0 00 05 * * ?', new HomeDepotOpptySyncSchedule());
        System.schedule('HDOpptySyncBatch10', '0 30 05 * * ?', new HomeDepotOpptySyncSchedule());
         
   //     System.schedule('HDOpptyLookupBatch', '0 05 17 * * ?', new HomeDepotOpptyLookupSchedule());
   //     System.schedule('HDOpptyErrorLookupBatch', '0 50 15 * * ?', new HomeDepotErrorLookupOpptySchedule());
    }
    
    public static void scheduleHomeDepotSCEBatch(){
        System.schedule('HDSCESyncBatch1', '0 00 06 * * ?', new HomeDepotSCESyncSchedule());
        System.schedule('HDSCESyncBatch2', '0 30 06 * * ?', new HomeDepotSCESyncSchedule());
        System.schedule('HDSCESyncBatch3', '0 00 07 * * ?', new HomeDepotSCESyncSchedule());
        System.schedule('HDSCESyncBatch4', '0 30 07 * * ?', new HomeDepotSCESyncSchedule());
        System.schedule('HDSCESyncBatch5', '0 00 08 * * ?', new HomeDepotSCESyncSchedule());
        
    }
}