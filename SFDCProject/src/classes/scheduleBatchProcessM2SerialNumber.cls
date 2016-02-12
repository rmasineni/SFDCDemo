global class scheduleBatchProcessM2SerialNumber implements Schedulable 
{
    global void execute(SchedulableContext ctx)
    {
        batchProcessM2SerialNumber.processM2SerialNumber();
    }
    
     public static void startScheduleBatchProcessM2SerialNumber()
    {
        //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        System.schedule('Batch Process M2 Serial Number - 0', '0 0 0-23 * * ?', new scheduleBatchProcessM2SerialNumber());
//        System.schedule('Batch Process M2 Serial Number - 15', '0 15 0-23 * * ?', new scheduleBatchProcessM2SerialNumber());
//        System.schedule('Batch Process M2 Serial Number - 30', '0 30 0-23 * * ?', new scheduleBatchProcessM2SerialNumber());
//        System.schedule('Batch Process M2 Serial Number - 45', '0 45 0-23 * * ?', new scheduleBatchProcessM2SerialNumber());
    }
}