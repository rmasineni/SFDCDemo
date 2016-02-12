public class HomeDepotErrorLookupLeadSchedule implements Schedulable
{
   public void execute(SchedulableContext sc)
   {
       Integer recLimit = Integer.valueOf(label.Home_Depot_Lead_Sync_Limit);
       HomeDepotErrorLookupLeadBatch batchable = new HomeDepotErrorLookupLeadBatch();
       database.executebatch(batchable);
   }

}