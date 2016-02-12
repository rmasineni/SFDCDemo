public class HomeDepotLeadSyncSchedule implements Schedulable
{
   public void execute(SchedulableContext sc)
   {
   	   Integer batchSize = Integer.valueOf(label.Home_Depot_Lead_Sync_Limit); 
       HomeDepotLeadSyncBatch batchable = new HomeDepotLeadSyncBatch();
       database.executebatch(batchable, batchSize);
   }
}