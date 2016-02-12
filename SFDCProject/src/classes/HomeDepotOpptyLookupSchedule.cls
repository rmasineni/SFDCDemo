public class HomeDepotOpptyLookupSchedule implements Schedulable
{
   public void execute(SchedulableContext sc)
   {
   	   Integer recLimit = Integer.valueOf(label.Home_Depot_Lead_Sync_Limit);
       HomeDepotOpportunityLookupBatch batchable = new HomeDepotOpportunityLookupBatch();
       database.executebatch(batchable, recLimit);
   }

}