public class HomeDepotLeadLookupSchedule implements Schedulable
{
   public void execute(SchedulableContext sc)
   {
   	   Integer recLimit = Integer.valueOf(label.Home_Depot_Lead_Sync_Limit);
       HomeDepotLeadLookupBatch batchable = new HomeDepotLeadLookupBatch();
       database.executebatch(batchable, recLimit);
   }
}