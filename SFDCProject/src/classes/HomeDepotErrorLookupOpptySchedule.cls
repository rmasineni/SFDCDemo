public class HomeDepotErrorLookupOpptySchedule implements Schedulable
{
   public void execute(SchedulableContext sc)
   {
       Integer recLimit = Integer.valueOf(label.Home_Depot_Lead_Sync_Limit);
       HomeDepotErrorLookupOpptyBatch batchable = new HomeDepotErrorLookupOpptyBatch();
       database.executebatch(batchable);
   }

}