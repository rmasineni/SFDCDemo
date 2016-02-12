public class HomeDepotSCESyncSchedule implements Schedulable
{
   public void execute(SchedulableContext sc)
   {
        Integer batchSize = Integer.valueOf(label.Home_Depot_Lead_Sync_Limit); 
       HomeDepotSCESyncBatch batchable = new HomeDepotSCESyncBatch();
       database.executebatch(batchable, batchSize);
   }
}