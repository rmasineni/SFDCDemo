global class ScheduleBatchApexCallCDYNE implements Schedulable{
	public set<String> leadSet;
	public string query;
	global void execute(SchedulableContext SC) {
	   		BatchApexCallCDYNE batch=new BatchApexCallCDYNE(query);
	   		batch.leadSet=leadSet;
	   		if(leadset!=null)
	   		database.executeBatch(batch,10);
	}
	
}