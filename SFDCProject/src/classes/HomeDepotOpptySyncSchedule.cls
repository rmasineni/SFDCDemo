public class HomeDepotOpptySyncSchedule implements Schedulable
{
   public void execute(SchedulableContext sc)
   {
       Integer batchSize = Integer.valueOf(label.Home_Depot_Lead_Sync_Limit); 
       HomeDepotOpportunitySyncBatch batchable = new HomeDepotOpportunitySyncBatch();
       database.executebatch(batchable, batchSize);
   }

}